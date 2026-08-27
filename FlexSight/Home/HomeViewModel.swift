//
//  HomeViewModel.swift
//  FlexSight
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    var isShowingSourceSheet = false

    let dateText: String
    let greeting: String

    // Sample data until sessions are recorded in-app; will be fed by the
    // session pipeline in a later step (no persistence, per the brief).
    let lastSessionStats: [StatItem] = [
        StatItem(label: "BEST FLEXION", value: "108°", detail: "+6° vs Aug 22"),
        StatItem(label: "REPS", value: "10", detail: "2 sets · Aug 24"),
    ]
    let trendPoints: [TrendPoint] = [
        TrendPoint(session: 1, degrees: 79),
        TrendPoint(session: 2, degrees: 72),
        TrendPoint(session: 3, degrees: 84),
        TrendPoint(session: 4, degrees: 88),
        TrendPoint(session: 5, degrees: 95),
        TrendPoint(session: 6, degrees: 101),
        TrendPoint(session: 7, degrees: 108),
    ]

    init(now: Date = .now) {
        dateText = now.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()).uppercased()
        greeting = switch Calendar.current.component(.hour, from: now) {
        case ..<12: "Good morning"
        case ..<17: "Good afternoon"
        default: "Good evening"
        }
    }

    func startSessionTapped() {
        isShowingSourceSheet = true
    }

    func choose(_ source: SessionSource) {
        isShowingSourceSheet = false
        // TODO: Route to the capture/measurement flow (next effort).
        _ = source
    }
}
