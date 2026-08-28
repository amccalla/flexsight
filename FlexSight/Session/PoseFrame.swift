//
//  PoseFrame.swift
//  FlexSight
//

import CoreGraphics
import Foundation

/// A detected body pose for a single frame.
struct PoseFrame: Sendable {
    struct Joint: Sendable {
        /// Normalized position with origin at the bottom-left (Vision's convention),
        /// in the upright (display-oriented) image space.
        let position: CGPoint
        let confidence: Double
    }

    let timestamp: TimeInterval
    let joints: [BodyJoint: Joint]

    subscript(joint: BodyJoint) -> Joint? { joints[joint] }
}
