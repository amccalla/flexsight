//
//  StatItem.swift
//  FlexSight
//

import Foundation

/// Data backing one StatCard tile.
struct StatItem: Identifiable {
    let label: String
    let value: String
    let detail: String

    var id: String { label }
}
