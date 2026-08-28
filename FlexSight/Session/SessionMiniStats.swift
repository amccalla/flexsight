//
//  SessionMiniStats.swift
//  FlexSight
//

import SwiftUI

struct SessionMiniStats: View {
    let repCount: Int
    let bestPeak: Int?
    let averagePeak: Int?

    var body: some View {
        HStack {
            MiniStat(value: "\(repCount)", label: "REPS", alignment: .leading)
            Spacer()
            MiniStat(value: bestPeak.map { "\($0)°" } ?? "—", label: "BEST", alignment: .center)
            Spacer()
            MiniStat(value: averagePeak.map { "\($0)°" } ?? "—", label: "AVG PEAK", alignment: .trailing)
        }
    }

    private struct MiniStat: View {
        let value: String
        let label: String
        let alignment: HorizontalAlignment

        var body: some View {
            VStack(alignment: alignment, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .monospacedDigit()
                Text(label)
                    .font(.caption.weight(.medium))
                    .kerning(0.5)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}

#Preview {
    SessionMiniStats(repCount: 7, bestPeak: 94, averagePeak: 88)
        .padding()
        .background(Color.black)
}
