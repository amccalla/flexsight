//
//  SessionSummaryView.swift
//  FlexSight
//

import SwiftUI

/// Post-session results (Figma frame "05 Session Summary", adapted: no single
/// workout title — the session lists every workout analyzed).
struct SessionSummaryView: View {
    let summary: SessionSummary
    let onDone: () -> Void

    @State private var scrollPosition = ScrollPosition(edge: .top)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                hero
                SessionResultsContent(summary: summary)
                Button("Done", action: onDone)
                    .buttonStyle(.flexPrimary)
                    .padding(.top, 4)
            }
            .padding(20)
        }
        .scrollPosition($scrollPosition)
        .scrollEdgeEffectHidden(true, for: .top)
        .background(Color.backgroundSecondary)
        .task {
            // Reveal the Done button on arrival so it's clear the summary can
            // be dismissed; the content is taller than one screen.
            try? await Task.sleep(for: .milliseconds(700))
            withAnimation(.easeInOut(duration: 0.8)) {
                scrollPosition.scrollTo(edge: .bottom)
            }
        }
    }

    private var hero: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.accentDeep)
                .frame(width: 64, height: 64)
                .background(Color.accentSoft, in: .circle)
            Text("Session complete")
                .font(.title2.bold())
                .foregroundStyle(Color.labelPrimary)
            Text(subtitleLine)
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .padding(.top, 8)
    }

    private var subtitleLine: String {
        let date = summary.date.formatted(.dateTime.month(.abbreviated).day())
        let minutes = max(1, Int((summary.duration / 60).rounded()))
        return "\(date) · \(minutes) min"
    }
}

#Preview {
    SessionSummaryView(
        summary: SessionSummary(
            date: .now,
            duration: 245,
            reps: [
                Rep(number: 1, workout: .bodyweightSquat, peakFlexion: 88, meanConfidence: 0.92, isLowConfidence: false),
                Rep(number: 2, workout: .bodyweightSquat, peakFlexion: 94, meanConfidence: 0.94, isLowConfidence: false),
                Rep(number: 3, workout: .bodyweightSquat, peakFlexion: 97, meanConfidence: 0.9, isLowConfidence: false),
                Rep(number: 4, workout: .bodyweightSquat, peakFlexion: 99, meanConfidence: 0.55, isLowConfidence: true),
                Rep(number: 5, workout: .standingKneeRaise, peakFlexion: 104, meanConfidence: 0.91, isLowConfidence: false),
                Rep(number: 6, workout: .standingKneeRaise, peakFlexion: 108, meanConfidence: 0.93, isLowConfidence: false),
            ]
        ),
        onDone: {}
    )
}
