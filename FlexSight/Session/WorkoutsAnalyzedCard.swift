//
//  WorkoutsAnalyzedCard.swift
//  FlexSight
//

import SwiftUI

struct WorkoutsAnalyzedCard: View {
    let breakdowns: [SessionSummary.WorkoutBreakdown]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Workouts analyzed")
                .font(.headline)
                .foregroundStyle(Color.labelPrimary)
            if breakdowns.isEmpty {
                Text("No movements were recognized this session.")
                    .font(.subheadline)
                    .foregroundStyle(Color.labelSecondary)
            } else {
                ForEach(breakdowns) { breakdown in
                    WorkoutBreakdownRow(breakdown: breakdown)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundPrimary, in: .rect(cornerRadius: 20))
    }
}

#Preview {
    WorkoutsAnalyzedCard(breakdowns: [
        SessionSummary.WorkoutBreakdown(workout: .bodyweightSquat, repCount: 4, bestPeak: 99, averagePeak: 93),
        SessionSummary.WorkoutBreakdown(workout: .standingKneeRaise, repCount: 2, bestPeak: 108, averagePeak: 106),
    ])
    .padding(20)
    .background(Color.backgroundSecondary)
}
