//
//  SessionSummary.swift
//  FlexSight
//

import Foundation

/// Aggregated results of a completed session.
struct SessionSummary: Identifiable, Sendable {
    let id = UUID()

    struct WorkoutBreakdown: Identifiable {
        let workout: WorkoutKind
        let repCount: Int
        let bestPeak: Double?
        let averagePeak: Double?

        var id: WorkoutKind { workout }
    }

    let date: Date
    let duration: TimeInterval
    let reps: [Rep]

    var confidentReps: [Rep] { reps.filter { !$0.isLowConfidence } }
    var lowConfidenceCount: Int { reps.count - confidentReps.count }

    /// Headline metrics use confident reps only, matching the clinical stance
    /// that uncertain measurements are shown but not celebrated.
    var bestFlexion: Double? { confidentReps.map(\.peakFlexion).max() }
    var averagePeak: Double? {
        let peaks = confidentReps.map(\.peakFlexion)
        guard !peaks.isEmpty else { return nil }
        return peaks.reduce(0, +) / Double(peaks.count)
    }
    var meanConfidence: Double? {
        guard !reps.isEmpty else { return nil }
        return reps.map(\.meanConfidence).reduce(0, +) / Double(reps.count)
    }

    /// Workouts in first-seen order, each with confident-rep flexion metrics.
    var breakdowns: [WorkoutBreakdown] {
        var order: [WorkoutKind] = []
        var grouped: [WorkoutKind: [Rep]] = [:]
        for rep in reps {
            if grouped[rep.workout] == nil { order.append(rep.workout) }
            grouped[rep.workout, default: []].append(rep)
        }
        return order.compactMap { workout in
            guard let group = grouped[workout] else { return nil }
            let peaks = group.filter { !$0.isLowConfidence }.map(\.peakFlexion)
            return WorkoutBreakdown(
                workout: workout,
                repCount: group.count,
                bestPeak: peaks.max(),
                averagePeak: peaks.isEmpty ? nil : peaks.reduce(0, +) / Double(peaks.count)
            )
        }
    }
}
