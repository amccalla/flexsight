//
//  MeasurementThresholds.swift
//  FlexSight
//

import Foundation

/// Tuning constants for the measurement pipeline, centralized so the clinical
/// thresholds are reviewable in one place.
enum MeasurementThresholds {
    /// Minimum per-joint Vision confidence for a leg reading to be trusted.
    static let jointConfidence = 0.3
    /// Flexion must rise above this angle (degrees) to begin a rep…
    static let repStart = 40.0
    /// …and return below this angle to complete it.
    static let repEnd = 20.0
    /// Completed reps with a peak below this are discarded as noise.
    static let repMinimumPeak = 45.0
    /// Completed reps shorter than this (seconds) are discarded as noise.
    static let repMinimumDuration = 0.4
    /// A rep counts as low-confidence when more than this fraction of its
    /// frames fell below `jointConfidence`.
    static let lowConfidenceRepRatio = 0.3
    /// Joints below this confidence aren't drawn in the overlay.
    static let overlayJointConfidence = 0.2
}
