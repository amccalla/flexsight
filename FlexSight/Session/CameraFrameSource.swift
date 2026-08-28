//
//  CameraFrameSource.swift
//  FlexSight
//

import AVFoundation

/// Streams live camera frames into the same pose pipeline the video path uses.
final class CameraFrameSource: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    enum CameraError: Error {
        case unauthorized
        case unavailable
    }

    let session = AVCaptureSession()
    private(set) var position = AVCaptureDevice.Position.back
    private let sampleQueue = DispatchQueue(label: "com.disruptlogic.flexsight.camera-frames")
    // Serializes start/stop so a quick start->stop cannot leave the session running.
    private let sessionQueue = DispatchQueue(label: "com.disruptlogic.flexsight.camera-session")
    private var currentInput: AVCaptureDeviceInput?
    private var videoOutput: AVCaptureVideoDataOutput?
    // Set once before capture starts; read from the delegate queue afterward.
    nonisolated(unsafe) private var continuation: AsyncStream<PixelBufferFrame>.Continuation?

    func frames() -> AsyncStream<PixelBufferFrame> {
        AsyncStream { self.continuation = $0 }
    }

    func start() async throws {
        guard await AVCaptureDevice.requestAccess(for: .video) else {
            throw CameraError.unauthorized
        }
        guard let input = Self.input(for: position) else {
            throw CameraError.unavailable
        }
        session.beginConfiguration()
        session.sessionPreset = .high
        guard session.canAddInput(input) else {
            session.commitConfiguration()
            throw CameraError.unavailable
        }
        session.addInput(input)
        currentInput = input
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: sampleQueue)
        guard session.canAddOutput(output) else {
            session.commitConfiguration()
            throw CameraError.unavailable
        }
        session.addOutput(output)
        videoOutput = output
        configureOutputConnection()
        session.commitConfiguration()
        let session = session
        // startRunning blocks; keep it off the main actor, ordered against stop().
        sessionQueue.async { session.startRunning() }
    }

    /// Swaps between the back and front camera mid-session.
    func switchCamera() {
        let newPosition: AVCaptureDevice.Position = position == .back ? .front : .back
        guard let newInput = Self.input(for: newPosition) else { return }
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        if let currentInput {
            session.removeInput(currentInput)
        }
        if session.canAddInput(newInput) {
            session.addInput(newInput)
            currentInput = newInput
            position = newPosition
        } else if let currentInput, session.canAddInput(currentInput) {
            // Couldn't switch — restore the previous camera.
            session.addInput(currentInput)
        }
        configureOutputConnection()
    }

    func stop() {
        continuation?.finish()
        let session = session
        sessionQueue.async { session.stopRunning() }
    }

    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        continuation?.yield(PixelBufferFrame(buffer: buffer, timestamp: timestamp))
    }

    /// Rotation and mirroring must be re-applied whenever the input changes —
    /// the connection resets them. Mirroring the front camera's buffers keeps
    /// Vision's coordinates aligned with the (automatically mirrored) preview.
    private func configureOutputConnection() {
        guard let connection = videoOutput?.connection(with: .video) else { return }
        if connection.isVideoRotationAngleSupported(90) {
            // Bake portrait rotation into the buffers so Vision sees upright frames.
            connection.videoRotationAngle = 90
        }
        connection.automaticallyAdjustsVideoMirroring = false
        if connection.isVideoMirroringSupported {
            connection.isVideoMirrored = position == .front
        }
    }

    private static func input(for position: AVCaptureDevice.Position) -> AVCaptureDeviceInput? {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            return nil
        }
        return try? AVCaptureDeviceInput(device: device)
    }
}
