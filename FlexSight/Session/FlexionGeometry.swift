//
//  FlexionGeometry.swift
//  FlexSight
//

import CoreGraphics
import Foundation

/// Knee flexion math. Convention: 0° = fully straight leg; larger values mean a
/// deeper bend. Flexion is 180° minus the interior hip–knee–ankle angle.
enum FlexionGeometry {
    struct LegReading {
        let flexion: Double
        /// The weakest joint confidence in the hip–knee–ankle chain — a chain is
        /// only as trustworthy as its least certain joint.
        let confidence: Double
    }

    static func legReading(for side: BodySide, in pose: PoseFrame, aspectRatio: Double) -> LegReading? {
        guard let hip = pose[side.hip], let knee = pose[side.knee], let ankle = pose[side.ankle] else {
            return nil
        }
        let flexion = kneeFlexion(
            hip: scaled(hip.position, by: aspectRatio),
            knee: scaled(knee.position, by: aspectRatio),
            ankle: scaled(ankle.position, by: aspectRatio)
        )
        return LegReading(
            flexion: flexion,
            confidence: min(hip.confidence, knee.confidence, ankle.confidence)
        )
    }

    static func kneeFlexion(hip: CGPoint, knee: CGPoint, ankle: CGPoint) -> Double {
        let femur = CGVector(dx: hip.x - knee.x, dy: hip.y - knee.y)
        let shank = CGVector(dx: ankle.x - knee.x, dy: ankle.y - knee.y)
        let magnitudes = hypot(femur.dx, femur.dy) * hypot(shank.dx, shank.dy)
        guard magnitudes > 0 else { return 0 }
        let dot = femur.dx * shank.dx + femur.dy * shank.dy
        let interiorAngle = acos(min(max(dot / magnitudes, -1), 1)) * 180 / .pi
        return max(0, 180 - interiorAngle)
    }

    /// Vision points are normalized to the unit square regardless of image shape,
    /// which distorts angles. Scaling x by the image aspect ratio restores true
    /// image geometry before any trigonometry.
    private static func scaled(_ point: CGPoint, by aspectRatio: Double) -> CGPoint {
        CGPoint(x: point.x * aspectRatio, y: point.y)
    }
}
