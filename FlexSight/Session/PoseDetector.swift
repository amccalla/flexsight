//
//  PoseDetector.swift
//  FlexSight
//

import CoreML
import ImageIO
import Vision

/// Runs Vision body-pose detection off the main actor and maps results into
/// the app's `PoseFrame` model.
///
/// A `.success(nil)` means Vision ran but saw no person; `.failure` means the
/// request itself couldn't run (some Simulator runtimes can't load the body-
/// pose model at all), which callers surface rather than treat as "no person."
struct PoseDetector: Sendable {
    @concurrent
    func detectPose(
        in frame: PixelBufferFrame,
        orientation: CGImagePropertyOrientation
    ) async -> Result<PoseFrame?, any Error> {
        var request = DetectHumanBodyPoseRequest()
        #if targetEnvironment(simulator)
        // The Simulator often lacks a usable GPU/Neural Engine for Vision's
        // main stage; route processing to the CPU there. Real devices keep
        // the default device selection.
        let cpu = MLComputeDevice.allComputeDevices.first { device in
            if case .cpu = device { return true }
            return false
        }
        if let cpu {
            request.setComputeDevice(cpu, for: .main)
            request.setComputeDevice(cpu, for: .postProcessing)
        }
        #endif
        let observation: HumanBodyPoseObservation?
        do {
            observation = try await request.perform(on: frame.buffer, orientation: orientation).first
        } catch {
            return .failure(error)
        }
        guard let observation else { return .success(nil) }
        var joints: [BodyJoint: PoseFrame.Joint] = [:]
        for bodyJoint in BodyJoint.allCases {
            guard let joint = observation.joint(for: bodyJoint.visionName) else { continue }
            joints[bodyJoint] = PoseFrame.Joint(
                position: CGPoint(x: joint.location.x, y: joint.location.y),
                confidence: Double(joint.confidence)
            )
        }
        return .success(joints.isEmpty ? nil : PoseFrame(timestamp: frame.timestamp, joints: joints))
    }
}
