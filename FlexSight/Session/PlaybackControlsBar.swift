//
//  PlaybackControlsBar.swift
//  FlexSight
//

import SwiftUI

/// Scrub bar + replay control shown for pre-recorded video sessions.
struct PlaybackControlsBar: View {
    @Bindable var viewModel: SessionViewModel

    var body: some View {
        HStack(spacing: 12) {
            Button("Replay", systemImage: "arrow.counterclockwise", action: viewModel.replay)
                .labelStyle(.iconOnly)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(.white.opacity(0.15), in: .circle)
            Slider(
                value: $viewModel.currentTime,
                in: 0...max(viewModel.duration, 0.01)
            ) { isEditing in
                if isEditing {
                    viewModel.beginScrubbing()
                } else {
                    viewModel.endScrubbing()
                }
            }
            .tint(.white)
            Text(timeText)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var timeText: String {
        "\(Self.format(viewModel.currentTime)) / \(Self.format(viewModel.duration))"
    }

    private static func format(_ time: TimeInterval) -> String {
        let seconds = max(0, Int(time.rounded()))
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}
