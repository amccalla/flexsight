//
//  SessionCTACard.swift
//  FlexSight
//

import SwiftUI

/// Primary call-to-action card for starting a measurement session.
struct SessionCTACard: View {
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                IconBadge(systemImage: "angle")
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ready when you are")
                        .font(.headline)
                        .foregroundStyle(Color.labelPrimary)
                    Text("Measure your knee range of motion")
                        .font(.subheadline)
                        .foregroundStyle(Color.labelSecondary)
                }
            }
            HStack(spacing: 8) {
                TagChip(text: "Knee flexion")
                TagChip(text: "Real-time results")
            }
            Button("Start Session", action: onStart)
                .buttonStyle(.flexPrimary)
            HStack(spacing: 6) {
                Image(systemName: "video.fill")
                    .font(.caption2)
                Text("Record live or analyze a saved video")
                    .font(.caption)
            }
            .foregroundStyle(Color.labelTertiary)
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(Color.backgroundPrimary, in: .rect(cornerRadius: 20))
    }
}

#Preview {
    SessionCTACard(onStart: {})
        .padding(20)
        .background(Color.backgroundSecondary)
}
