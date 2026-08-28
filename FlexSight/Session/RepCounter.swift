//
//  RepCounter.swift
//  FlexSight
//

import Foundation

/// Workout-agnostic rep detection: a rep is one excursion of knee flexion above
/// the start threshold and back below the end threshold. Confidence is tracked
/// per rep so low-quality reps can be flagged rather than silently trusted.
struct RepCounter {
    struct CompletedRep {
        let peakFlexion: Double
        let startTime: TimeInterval
        let endTime: TimeInterval
        let meanConfidence: Double
        let lowConfidenceRatio: Double
    }

    private enum Phase {
        case idle
        case flexing
    }

    private var phase = Phase.idle
    private var peak = 0.0
    private var startTime: TimeInterval = 0
    private var frameCount = 0
    private var lowConfidenceFrames = 0
    private var confidenceSum = 0.0

    /// Feed one frame's reading. `flexion` is nil when the measurement is paused
    /// for low confidence; the in-progress rep is held open, not aborted.
    mutating func process(flexion: Double?, confidence: Double, at time: TimeInterval) -> CompletedRep? {
        let isConfident = confidence >= MeasurementThresholds.jointConfidence
        switch phase {
        case .idle:
            if isConfident, let flexion, flexion >= MeasurementThresholds.repStart {
                phase = .flexing
                peak = flexion
                startTime = time
                frameCount = 1
                lowConfidenceFrames = isConfident ? 0 : 1
                confidenceSum = confidence
            }
        case .flexing:
            frameCount += 1
            confidenceSum += confidence
            if !isConfident {
                lowConfidenceFrames += 1
            }
            if isConfident, let flexion {
                peak = max(peak, flexion)
                if flexion <= MeasurementThresholds.repEnd {
                    phase = .idle
                    let duration = time - startTime
                    guard peak >= MeasurementThresholds.repMinimumPeak,
                          duration >= MeasurementThresholds.repMinimumDuration else {
                        return nil
                    }
                    return CompletedRep(
                        peakFlexion: peak,
                        startTime: startTime,
                        endTime: time,
                        meanConfidence: confidenceSum / Double(frameCount),
                        lowConfidenceRatio: Double(lowConfidenceFrames) / Double(frameCount)
                    )
                }
            }
        }
        return nil
    }

    mutating func reset() {
        phase = .idle
        peak = 0
    }
}
