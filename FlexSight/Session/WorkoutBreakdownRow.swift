//
//  WorkoutBreakdownRow.swift
//  FlexSight
//

import SwiftUI

struct WorkoutBreakdownRow: View {
    let breakdown: SessionSummary.WorkoutBreakdown

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemImage: breakdown.workout.systemImage)
            VStack(alignment: .leading, spacing: 2) {
                Text(breakdown.workout.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.labelPrimary)
                Text("^[\(breakdown.repCount) rep](inflect: true)")
                    .font(.footnote)
                    .foregroundStyle(Color.labelSecondary)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 2) {
                Text("best \(Int(breakdown.bestPeak.rounded()))°")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.labelPrimary)
                Text("avg \(Int(breakdown.averagePeak.rounded()))°")
                    .font(.footnote)
                    .foregroundStyle(Color.labelSecondary)
            }
        }
    }
}

#Preview {
    WorkoutBreakdownRow(
        breakdown: SessionSummary.WorkoutBreakdown(workout: .bodyweightSquat, repCount: 4, bestPeak: 99, averagePeak: 93)
    )
    .padding(20)
}
