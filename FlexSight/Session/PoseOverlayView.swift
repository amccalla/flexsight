//
//  PoseOverlayView.swift
//  FlexSight
//

import SwiftUI

/// Draws the detected skeleton over the video, with the measured leg
/// highlighted and a floating chip labeling the live knee angle.
struct PoseOverlayView: View {
    let pose: PoseFrame
    /// Upright pixel dimensions of the video/camera content.
    let contentSize: CGSize
    let measuredSide: BodySide?
    /// e.g. "Knee · 56°"; nil hides the chip (low confidence).
    let flexionLabel: String?

    var body: some View {
        GeometryReader { proxy in
            let viewSize = proxy.size
            Canvas { context, _ in
                drawSkeleton(in: &context, viewSize: viewSize)
            }
            if let flexionLabel,
               let side = measuredSide,
               let knee = pose[side.knee],
               knee.confidence >= MeasurementThresholds.overlayJointConfidence {
                Text(flexionLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.6), in: .capsule)
                    .position(chipPosition(for: knee, in: viewSize))
            }
        }
        .allowsHitTesting(false)
    }

    private func drawSkeleton(in context: inout GraphicsContext, viewSize: CGSize) {
        let legJoints = Set(measuredSide?.legJoints ?? [])
        for (a, b) in BodyJoint.skeletonEdges {
            guard let jointA = pose[a], let jointB = pose[b],
                  jointA.confidence >= MeasurementThresholds.overlayJointConfidence,
                  jointB.confidence >= MeasurementThresholds.overlayJointConfidence else {
                continue
            }
            let isMeasuredLeg = legJoints.contains(a) && legJoints.contains(b)
            var path = Path()
            path.move(to: mapPoint(jointA.position, in: viewSize))
            path.addLine(to: mapPoint(jointB.position, in: viewSize))
            context.stroke(
                path,
                with: .color(isMeasuredLeg ? .yellow : .white.opacity(0.85)),
                style: StrokeStyle(lineWidth: isMeasuredLeg ? 4 : 3, lineCap: .round)
            )
        }
        for (joint, detected) in pose.joints
        where detected.confidence >= MeasurementThresholds.overlayJointConfidence {
            let isLegJoint = legJoints.contains(joint)
            let radius: CGFloat = isLegJoint ? 6 : 5
            let center = mapPoint(detected.position, in: viewSize)
            let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
            context.fill(Path(ellipseIn: rect), with: .color(isLegJoint ? .yellow : .white))
        }
    }

    private func chipPosition(for knee: PoseFrame.Joint, in viewSize: CGSize) -> CGPoint {
        let point = mapPoint(knee.position, in: viewSize)
        return CGPoint(x: point.x, y: max(point.y - 44, 20))
    }

    /// Maps a Vision-normalized point (origin bottom-left) onto this view,
    /// mirroring the aspect-fill crop the video layer applies.
    private func mapPoint(_ point: CGPoint, in viewSize: CGSize) -> CGPoint {
        guard contentSize.width > 0, contentSize.height > 0 else { return .zero }
        let scale = max(viewSize.width / contentSize.width, viewSize.height / contentSize.height)
        let drawnSize = CGSize(width: contentSize.width * scale, height: contentSize.height * scale)
        let xOffset = (drawnSize.width - viewSize.width) / 2
        let yOffset = (drawnSize.height - viewSize.height) / 2
        return CGPoint(
            x: point.x * drawnSize.width - xOffset,
            y: (1 - point.y) * drawnSize.height - yOffset
        )
    }
}

#Preview {
    PoseOverlayView(
        pose: PoseFrame(timestamp: 0, joints: [
            .nose: .init(position: CGPoint(x: 0.5, y: 0.85), confidence: 0.9),
            .neck: .init(position: CGPoint(x: 0.5, y: 0.75), confidence: 0.9),
            .leftShoulder: .init(position: CGPoint(x: 0.42, y: 0.74), confidence: 0.9),
            .rightShoulder: .init(position: CGPoint(x: 0.58, y: 0.74), confidence: 0.9),
            .root: .init(position: CGPoint(x: 0.5, y: 0.52), confidence: 0.9),
            .leftHip: .init(position: CGPoint(x: 0.45, y: 0.52), confidence: 0.9),
            .rightHip: .init(position: CGPoint(x: 0.55, y: 0.52), confidence: 0.9),
            .leftKnee: .init(position: CGPoint(x: 0.42, y: 0.32), confidence: 0.9),
            .rightKnee: .init(position: CGPoint(x: 0.58, y: 0.32), confidence: 0.9),
            .leftAnkle: .init(position: CGPoint(x: 0.42, y: 0.12), confidence: 0.9),
            .rightAnkle: .init(position: CGPoint(x: 0.58, y: 0.12), confidence: 0.9),
        ]),
        contentSize: CGSize(width: 1080, height: 1920),
        measuredSide: .left,
        flexionLabel: "Knee · 56°"
    )
    .background(Color.black)
}
