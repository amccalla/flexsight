//
//  SessionResultsContent.swift
//  FlexSight
//

import SwiftUI

/// The shared results layout — stats grid, workouts analyzed, flexion-by-rep
/// chart — used by the post-session summary and the Insights detail screen.
struct SessionResultsContent: View {
    let summary: SessionSummary

    var body: some View {
        VStack(spacing: 16) {
            statsGrid
            WorkoutsAnalyzedCard(breakdowns: summary.breakdowns)
            FlexionByRepChart(reps: summary.reps)
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())], spacing: 12) {
            StatCard(
                label: "REPS",
                value: "\(summary.confidentReps.count)",
                detail: summary.lowConfidenceCount > 0
                    ? "of \(summary.reps.count) scanned"
                    : "all confident"
            )
            StatCard(
                label: "BEST FLEXION",
                value: summary.bestFlexion.map { "\(Int($0.rounded()))°" } ?? "—",
                detail: "peak this session"
            )
            StatCard(
                label: "AVG PEAK",
                value: summary.averagePeak.map { "\(Int($0.rounded()))°" } ?? "—",
                detail: "across \(summary.confidentReps.count) reps"
            )
            StatCard(
                label: "CONFIDENCE",
                value: summary.meanConfidence.map { "\(Int(($0 * 100).rounded()))%" } ?? "—",
                detail: "mean joint confidence"
            )
        }
    }
}

#Preview {
    ScrollView {
        SessionResultsContent(
            summary: SessionSummary(
                date: .now,
                duration: 245,
                reps: [
                    Rep(number: 1, workout: .bodyweightSquat, peakFlexion: 88, meanConfidence: 0.92, isLowConfidence: false),
                    Rep(number: 2, workout: .bodyweightSquat, peakFlexion: 94, meanConfidence: 0.55, isLowConfidence: true),
                    Rep(number: 3, workout: .standingKneeRaise, peakFlexion: 104, meanConfidence: 0.91, isLowConfidence: false),
                ]
            )
        )
        .padding(20)
    }
    .background(Color.backgroundSecondary)
}
