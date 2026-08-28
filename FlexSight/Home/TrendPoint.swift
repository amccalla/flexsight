//
//  TrendPoint.swift
//  FlexSight
//

import Foundation

/// Best knee flexion achieved in one session, for trend charts.
struct TrendPoint: Identifiable {
    let session: Int
    let degrees: Int

    var id: Int { session }
}
