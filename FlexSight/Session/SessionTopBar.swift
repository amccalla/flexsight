//
//  SessionTopBar.swift
//  FlexSight
//

import SwiftUI

struct SessionTopBar: View {
    let workoutName: String?
    let subtitle: String
    let tracking: SessionViewModel.TrackingQuality
    let onClose: () -> Void
    var onSwitchCamera: (() -> Void)?

    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(.white.opacity(0.15), in: .circle)
                }
                .accessibilityLabel("Close session")
                Spacer()
                if let onSwitchCamera {
                    Button(action: onSwitchCamera) {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.camera.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(.white.opacity(0.15), in: .circle)
                    }
                    .accessibilityLabel("Switch camera")
                }
            }
            VStack(spacing: 5) {
                Text(workoutName ?? "Detecting movement…")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .contentTransition(.opacity)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                ConfidenceBadge(tracking: tracking)
            }
            .animation(.easeInOut, value: workoutName)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        SessionTopBar(workoutName: "Bodyweight squat", subtitle: "Recorded video", tracking: .high, onClose: {})
        SessionTopBar(workoutName: "Bodyweight squat", subtitle: "Live session", tracking: .high, onClose: {}, onSwitchCamera: {})
    }
    .padding()
    .background(Color.black)
}
