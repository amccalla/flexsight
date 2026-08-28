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
    SessionTopBar(workoutName: "Bodyweight squat", subtitle: "Recorded video", tracking: .high, onClose: {})
        .padding()
        .background(Color.black)
}
