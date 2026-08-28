//
//  WorkoutKind.swift
//  FlexSight
//

import Foundation

/// The library of lower-body movements FlexSight can recognize.
enum WorkoutKind: String, CaseIterable, Identifiable, Sendable {
    case bodyweightSquat
    case sitToStandSquat
    case standingKneeRaise
    case unclassified

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .bodyweightSquat: "Bodyweight squat"
        case .sitToStandSquat: "Sit-to-stand squat"
        case .standingKneeRaise: "Standing knee raise"
        case .unclassified: "Unclassified movement"
        }
    }

    var systemImage: String {
        switch self {
        case .bodyweightSquat: "figure.strengthtraining.functional"
        case .sitToStandSquat: "figure.stand"
        case .standingKneeRaise: "figure.walk"
        case .unclassified: "questionmark.circle"
        }
    }
}
