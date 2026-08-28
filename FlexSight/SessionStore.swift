//
//  SessionStore.swift
//  FlexSight
//

import Foundation
import Observation

/// In-memory record of the sessions completed this launch, feeding Home and
/// Insights. Deliberately not persisted — the exercise brief excludes
/// persistence.
@MainActor
@Observable
final class SessionStore {
    private(set) var sessions: [SessionSummary] = []

    func add(_ summary: SessionSummary) {
        sessions.append(summary)
    }
}
