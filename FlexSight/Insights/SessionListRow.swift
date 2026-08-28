//
//  SessionListRow.swift
//  FlexSight
//

import SwiftUI

struct SessionListRow: View {
    let summary: SessionSummary

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemImage: summary.breakdowns.first?.workout.systemImage ?? "figure.strengthtraining.functional")
            VStack(alignment: .leading, spacing: 2) {
                Text(summary.date.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.labelPrimary)
                Text("^[\(summary.reps.count) rep](inflect: true) · \(workoutNames)")
                    .font(.footnote)
                    .foregroundStyle(Color.labelSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Text(summary.bestFlexion.map { "\(Int($0.rounded()))°" } ?? "—")
                .font(.headline)
                .foregroundStyle(Color.accentDeep)
        }
        .padding(.vertical, 4)
    }

    private var workoutNames: String {
        let names = summary.breakdowns.map(\.workout.displayName)
        return names.isEmpty ? "No movements recognized" : names.joined(separator: ", ")
    }
}

#Preview {
    List {
        SessionListRow(
            summary: SessionSummary(
                date: .now,
                duration: 245,
                reps: [
                    Rep(number: 1, workout: .bodyweightSquat, peakFlexion: 88, meanConfidence: 0.92, isLowConfidence: false),
                    Rep(number: 2, workout: .standingKneeRaise, peakFlexion: 104, meanConfidence: 0.91, isLowConfidence: false),
                ]
            )
        )
    }
}
