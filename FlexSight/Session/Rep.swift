//
//  Rep.swift
//  FlexSight
//

import Foundation

/// One completed repetition and its measured flexion metrics.
struct Rep: Identifiable, Sendable {
    let number: Int
    let workout: WorkoutKind
    let peakFlexion: Double
    let meanConfidence: Double
    let isLowConfidence: Bool

    var id: Int { number }
}
