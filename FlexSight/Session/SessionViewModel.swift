//
//  SessionViewModel.swift
//  FlexSight
//

import AVFoundation
import Foundation
import ImageIO
import Observation
import os

/// Orchestrates a measurement session: pulls frames from the camera or a video,
/// runs pose detection, and folds the results into reps, workout classification,
/// and confidence state for the UI.
@MainActor
@Observable
final class SessionViewModel {
    enum TrackingQuality {
        case high
        case low
    }

    let input: SessionInput

    private let detector = PoseDetector()
    private var repCounter = RepCounter()
    private var classifier = WorkoutClassifier()
    private var videoSource: VideoFrameSource?
    private var cameraSource: CameraFrameSource?
    private var frameTask: Task<Void, Never>?
    private var playbackEndTask: Task<Void, Never>?
    private var isProcessingFrame = false
    private var orientation = CGImagePropertyOrientation.up
    private var firstTimestamp: TimeInterval?
    private var lastTimestamp: TimeInterval = 0
    private var detectionFailures = 0
    private let logger = Logger(subsystem: "com.disruptlogic.FlexSight", category: "SessionViewModel")

    private(set) var currentPose: PoseFrame?
    private(set) var measuredSide: BodySide?
    private(set) var displayFlexion: Int?
    private(set) var tracking = TrackingQuality.low
    private(set) var reps: [Rep] = []
    private(set) var currentWorkout: WorkoutKind?
    private(set) var contentSize = CGSize.zero
    private(set) var duration: TimeInterval = 0
    var currentTime: TimeInterval = 0
    private(set) var isScrubbing = false
    private(set) var playbackFinished = false
    private(set) var summary: SessionSummary?
    private(set) var cameraUnavailable = false
    /// True when Vision itself cannot run (e.g. Simulator runtimes without a
    /// compute device for the body-pose model) — distinct from low confidence.
    private(set) var poseUnavailable = false
    /// False until the media source is ready to display; the session chrome
    /// stays hidden behind a loading state until then.
    private(set) var isReady = false

    var player: AVPlayer? { videoSource?.player }
    var cameraSession: AVCaptureSession? { cameraSource?.session }
    var isLive: Bool { input.isLive }
    var bestPeak: Int? {
        let peaks = reps.filter { !$0.isLowConfidence }.map(\.peakFlexion)
        return peaks.max().map { Int($0.rounded()) }
    }
    var averagePeak: Int? {
        let peaks = reps.filter { !$0.isLowConfidence }.map(\.peakFlexion)
        guard !peaks.isEmpty else { return nil }
        return Int((peaks.reduce(0, +) / Double(peaks.count)).rounded())
    }

    init(input: SessionInput) {
        self.input = input
    }

    func start() async {
        switch input {
        case .video(let url):
            await startVideo(url)
        case .camera:
            await startCamera()
        }
    }

    /// Ends the session and builds the summary. Idempotent.
    func endSession() {
        guard summary == nil else { return }
        stopSources()
        let elapsed: TimeInterval = if isLive {
            lastTimestamp - (firstTimestamp ?? lastTimestamp)
        } else {
            duration > 0 ? min(currentTime, duration) : currentTime
        }
        summary = SessionSummary(date: .now, duration: max(elapsed, 0), reps: reps)
    }

    /// Returns true when the view should dismiss immediately (nothing to summarize).
    func closeTapped() -> Bool {
        if reps.isEmpty {
            stopSources()
            return true
        }
        endSession()
        return false
    }

    func replay() {
        guard case .video = input, let videoSource else { return }
        reps = []
        repCounter.reset()
        classifier.reset()
        currentWorkout = nil
        firstTimestamp = nil
        currentTime = 0
        playbackFinished = false
        videoSource.player.seek(to: .zero)
        videoSource.player.play()
    }

    func switchCamera() {
        cameraSource?.switchCamera()
    }

    func beginScrubbing() {
        isScrubbing = true
    }

    func endScrubbing() {
        isScrubbing = false
        player?.seek(to: CMTime(seconds: currentTime, preferredTimescale: 600))
        if playbackFinished, currentTime < duration - 0.05 {
            playbackFinished = false
            player?.play()
        }
    }

    func stop() {
        stopSources()
        playbackEndTask?.cancel()
    }

    // MARK: - Sources

    private func startVideo(_ url: URL) async {
        let asset = AVURLAsset(url: url)
        if let track = try? await asset.loadTracks(withMediaType: .video).first,
           let (naturalSize, transform) = try? await track.load(.naturalSize, .preferredTransform) {
            orientation = Self.orientation(from: transform)
            let transformed = naturalSize.applying(transform)
            contentSize = CGSize(width: abs(transformed.width), height: abs(transformed.height))
        }
        duration = (try? await asset.load(.duration).seconds) ?? 0
        let source = VideoFrameSource(url: url)
        videoSource = source
        source.onTimeUpdate = { [weak self] time in
            guard let self, !isScrubbing else { return }
            currentTime = time
        }
        observePlaybackEnd(of: source.player)
        let stream = source.frames()
        // Wait (bounded) for the item to become playable before revealing the
        // session UI; picked videos can take a moment to stage locally.
        if let item = source.player.currentItem {
            for _ in 0..<100 where item.status != .readyToPlay {
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
        isReady = true
        source.player.play()
        frameTask = Task { [weak self] in
            for await frame in stream {
                await self?.process(frame)
            }
        }
    }

    private func startCamera() async {
        let source = CameraFrameSource()
        cameraSource = source
        let stream = source.frames()
        do {
            try await source.start()
        } catch {
            cameraUnavailable = true
            return
        }
        orientation = .up  // Rotation is baked into the buffers by the capture connection.
        isReady = true
        frameTask = Task { [weak self] in
            for await frame in stream {
                await self?.process(frame)
            }
        }
    }

    private func stopSources() {
        frameTask?.cancel()
        playbackEndTask?.cancel()
        videoSource?.stop()
        cameraSource?.stop()
    }

    private func observePlaybackEnd(of player: AVPlayer) {
        guard let item = player.currentItem else { return }
        playbackEndTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(
                named: AVPlayerItem.didPlayToEndTimeNotification,
                object: item
            ) {
                guard let self, self.summary == nil else { continue }
                // Offer a choice — replay or continue to results — instead of
                // jumping straight to the summary.
                self.playbackFinished = true
            }
        }
    }

    // MARK: - Frame processing

    private func process(_ frame: PixelBufferFrame) async {
        guard !isProcessingFrame, summary == nil else { return }
        isProcessingFrame = true
        defer { isProcessingFrame = false }

        if contentSize == .zero {
            contentSize = uprightSize(of: frame)
        }
        let pose: PoseFrame?
        switch await detector.detectPose(in: frame, orientation: orientation) {
        case .failure(let error):
            detectionFailures += 1
            if detectionFailures >= 10, !poseUnavailable {
                poseUnavailable = true
                logger.error("Pose detection unavailable: \(error)")
            }
            pauseMeasurement(at: frame.timestamp)
            return
        case .success(let detected):
            detectionFailures = 0
            pose = detected
        }
        guard let pose else {
            pauseMeasurement(at: frame.timestamp)
            return
        }
        if firstTimestamp == nil {
            firstTimestamp = frame.timestamp
        }
        lastTimestamp = frame.timestamp
        currentPose = pose

        let aspect = contentSize.height > 0 ? contentSize.width / contentSize.height : 1
        let left = FlexionGeometry.legReading(for: .left, in: pose, aspectRatio: aspect)
        let right = FlexionGeometry.legReading(for: .right, in: pose, aspectRatio: aspect)

        // Measure the more flexed leg, preferring legs whose whole joint chain
        // is confidently tracked.
        let candidates: [(side: BodySide, reading: FlexionGeometry.LegReading)] =
            [(BodySide.left, left), (BodySide.right, right)].compactMap { side, reading in
                reading.map { (side, $0) }
            }
        let confident = candidates.filter { $0.reading.confidence >= MeasurementThresholds.jointConfidence }
        let chosen = (confident.isEmpty ? candidates : confident).max { $0.reading.flexion < $1.reading.flexion }
        measuredSide = chosen?.side

        let reading = chosen?.reading
        let isConfident = (reading?.confidence ?? 0) >= MeasurementThresholds.jointConfidence
        tracking = isConfident ? .high : .low
        displayFlexion = isConfident ? reading.map { Int($0.flexion.rounded()) } : nil

        classifier.add(WorkoutClassifier.Sample(
            time: frame.timestamp,
            leftFlexion: confidentFlexion(left),
            rightFlexion: confidentFlexion(right),
            hipHeight: hipHeight(in: pose)
        ))
        if let liveKind = classifier.classifyRecent(endingAt: frame.timestamp) {
            currentWorkout = liveKind
        }

        let completed = repCounter.process(
            flexion: isConfident ? reading?.flexion : nil,
            confidence: reading?.confidence ?? 0,
            at: frame.timestamp
        )
        if let completed {
            let kind = classifier.classify(from: completed.startTime, to: completed.endTime)
                ?? currentWorkout
                ?? .unclassified
            currentWorkout = kind
            reps.append(Rep(
                number: reps.count + 1,
                workout: kind,
                peakFlexion: completed.peakFlexion,
                meanConfidence: completed.meanConfidence,
                isLowConfidence: completed.lowConfidenceRatio > MeasurementThresholds.lowConfidenceRepRatio
            ))
        }
    }

    private func pauseMeasurement(at time: TimeInterval) {
        currentPose = nil
        displayFlexion = nil
        tracking = .low
        _ = repCounter.process(flexion: nil, confidence: 0, at: time)
    }

    private func confidentFlexion(_ reading: FlexionGeometry.LegReading?) -> Double? {
        guard let reading, reading.confidence >= MeasurementThresholds.jointConfidence else { return nil }
        return reading.flexion
    }

    private func hipHeight(in pose: PoseFrame) -> Double? {
        if let root = pose[.root], root.confidence >= MeasurementThresholds.jointConfidence {
            return root.position.y
        }
        let hips = [pose[.leftHip], pose[.rightHip]]
            .compactMap { $0 }
            .filter { $0.confidence >= MeasurementThresholds.jointConfidence }
        guard !hips.isEmpty else { return nil }
        return hips.map(\.position.y).reduce(0, +) / Double(hips.count)
    }

    private func uprightSize(of frame: PixelBufferFrame) -> CGSize {
        let width = CGFloat(CVPixelBufferGetWidth(frame.buffer))
        let height = CGFloat(CVPixelBufferGetHeight(frame.buffer))
        switch orientation {
        case .left, .right, .leftMirrored, .rightMirrored:
            return CGSize(width: height, height: width)
        default:
            return CGSize(width: width, height: height)
        }
    }

    private static func orientation(from transform: CGAffineTransform) -> CGImagePropertyOrientation {
        // A negative determinant means the track is mirrored; strip the
        // reflection before reading the rotation, then return the mirrored
        // EXIF variant so Vision interprets the buffer the way it displays.
        let isMirrored = (transform.a * transform.d - transform.b * transform.c) < 0
        let a = isMirrored ? -transform.a : transform.a
        let b = isMirrored ? -transform.b : transform.b
        let angle = atan2(b, a) * 180 / .pi
        switch Int(angle.rounded()) {
        case 90: return isMirrored ? .rightMirrored : .right
        case -90, 270: return isMirrored ? .leftMirrored : .left
        case 180, -180: return isMirrored ? .downMirrored : .down
        default: return isMirrored ? .upMirrored : .up
        }
    }
}
