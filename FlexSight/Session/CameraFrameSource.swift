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
    private let sampleQueue = DispatchQueue(label: "com.disruptlogic.flexsight.camera-frames")
    // Set once before capture starts; read from the delegate queue afterward.
    nonisolated(unsafe) private var continuation: AsyncStream<PixelBufferFrame>.Continuation?

    func frames() -> AsyncStream<PixelBufferFrame> {
        AsyncStream { self.continuation = $0 }
    }

    func start() async throws {
        guard await AVCaptureDevice.requestAccess(for: .video) else {
            throw CameraError.unauthorized
        }
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            throw CameraError.unavailable
        }
        session.beginConfiguration()
        session.sessionPreset = .high
        guard session.canAddInput(input) else {
            session.commitConfiguration()
            throw CameraError.unavailable
        }
        session.addInput(input)
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: sampleQueue)
        guard session.canAddOutput(output) else {
            session.commitConfiguration()
            throw CameraError.unavailable
        }
        session.addOutput(output)
        if let connection = output.connection(with: .video), connection.isVideoRotationAngleSupported(90) {
            // Bake portrait rotation into the buffers so Vision sees upright frames.
            connection.videoRotationAngle = 90
        }
        session.commitConfiguration()
        let session = session
        Task.detached {
            // startRunning blocks; keep it off the main actor.
            session.startRunning()
        }
    }

    func stop() {
        continuation?.finish()
        let session = session
        Task.detached {
            session.stopRunning()
        }
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
}
