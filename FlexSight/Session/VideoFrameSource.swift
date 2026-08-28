//
//  VideoFrameSource.swift
//  FlexSight
//

import AVFoundation

/// Plays a video file and vends display-synced pixel buffers to the pose
/// pipeline, so the overlay always matches what's on screen.
@MainActor
final class VideoFrameSource {
    let player: AVPlayer
    private let output: AVPlayerItemVideoOutput
    private var timeObserver: Any?
    private var continuation: AsyncStream<PixelBufferFrame>.Continuation?

    /// Called ~30×/sec with the current playback time (main actor).
    var onTimeUpdate: ((TimeInterval) -> Void)?

    init(url: URL) {
        let item = AVPlayerItem(url: url)
        output = AVPlayerItemVideoOutput(pixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        ])
        item.add(output)
        player = AVPlayer(playerItem: item)
    }

    func frames() -> AsyncStream<PixelBufferFrame> {
        AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            self.continuation = continuation
            timeObserver = player.addPeriodicTimeObserver(
                forInterval: CMTime(value: 1, timescale: 30),
                queue: .main
            ) { [weak self] time in
                MainActor.assumeIsolated {
                    self?.emitFrame(at: time)
                }
            }
        }
    }

    func stop() {
        if let timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        timeObserver = nil
        continuation?.finish()
        player.pause()
    }

    private func emitFrame(at time: CMTime) {
        onTimeUpdate?(time.seconds)
        guard output.hasNewPixelBuffer(forItemTime: time),
              let buffer = output.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else {
            return
        }
        continuation?.yield(PixelBufferFrame(buffer: buffer, timestamp: time.seconds))
    }
}
