//
//  SessionDetailView.swift
//  FlexSight
//

import SwiftUI

/// Full results for one recorded session, reached from the Insights list.
struct SessionDetailView: View {
    let summary: SessionSummary

    var body: some View {
        ScrollView {
            SessionResultsContent(summary: summary)
                .padding(20)
        }
        .background(Color.backgroundSecondary)
        .navigationTitle(summary.date.formatted(.dateTime.month(.abbreviated).day().hour().minute()))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(
            summary: SessionSummary(
                date: .now,
                duration: 245,
                reps: [
                    Rep(number: 1, workout: .bodyweightSquat, peakFlexion: 88, meanConfidence: 0.92, isLowConfidence: false),
                    Rep(number: 2, workout: .bodyweightSquat, peakFlexion: 97, meanConfidence: 0.5, isLowConfidence: true),
                    Rep(number: 3, workout: .standingKneeRaise, peakFlexion: 104, meanConfidence: 0.91, isLowConfidence: false),
                ]
            )
        )
    }
}
