//
//  WorkoutClassifier.swift
//  FlexSight
//

import Foundation

/// Heuristic movement classification over a rolling window of joint-angle
/// samples. Deliberately simple and readable rather than learned: bilateral
/// knee flexion with hip descent is a squat family movement (a sustained dwell
/// near peak flexion — sitting — distinguishes sit-to-stand), while deep
/// single-knee flexion with level hips is a standing knee raise.
struct WorkoutClassifier {
    struct Sample {
        let time: TimeInterval
        /// Confident flexion readings only; nil when that leg wasn't trustworthy.
        let leftFlexion: Double?
        let rightFlexion: Double?
        /// Mid-hip height in normalized (0–1, up-positive) coordinates.
        let hipHeight: Double?
    }

    private var samples: [Sample] = []
    private let maxAge: TimeInterval = 30

    mutating func add(_ sample: Sample) {
        samples.append(sample)
        if let cutoff = samples.last.map({ $0.time - maxAge }) {
            samples.removeAll { $0.time < cutoff }
        }
    }

    mutating func reset() {
        samples.removeAll()
    }

    /// Classifies the movement inside a completed rep's time window.
    func classify(from start: TimeInterval, to end: TimeInterval) -> WorkoutKind? {
        classify(samples.filter { $0.time >= start - 0.3 && $0.time <= end + 0.3 })
    }

    /// Classifies the most recent movement, for the live session title.
    func classifyRecent(endingAt time: TimeInterval, window: TimeInterval = 2.0) -> WorkoutKind? {
        classify(samples.filter { $0.time >= time - window })
    }

    private func classify(_ window: [Sample]) -> WorkoutKind? {
        guard window.count >= 5 else { return nil }
        let lefts = window.compactMap(\.leftFlexion)
        let rights = window.compactMap(\.rightFlexion)
        let hips = window.compactMap(\.hipHeight)
        guard let maxLeft = lefts.max(), let maxRight = rights.max(),
              let maxHip = hips.max(), let minHip = hips.min() else {
            return nil
        }
        let hipDrop = maxHip - minHip
        let isBilateral = min(maxLeft, maxRight) >= 35 && abs(maxLeft - maxRight) <= 30

        if isBilateral && hipDrop >= 0.05 {
            // Sitting shows as a sustained dwell near peak flexion; a squat
            // bottom is brief.
            let peak = max(maxLeft, maxRight)
            let dwellSamples = window.filter { max($0.leftFlexion ?? 0, $0.rightFlexion ?? 0) >= peak * 0.8 }
            let dwell: TimeInterval
            if let first = dwellSamples.first, let last = dwellSamples.last {
                dwell = last.time - first.time
            } else {
                dwell = 0
            }
            return dwell >= 0.6 ? .sitToStandSquat : .bodyweightSquat
        }
        if max(maxLeft, maxRight) >= 50, min(maxLeft, maxRight) <= 25, hipDrop <= 0.04 {
            return .standingKneeRaise
        }
        return nil
    }
}
