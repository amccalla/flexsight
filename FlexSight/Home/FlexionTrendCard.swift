//
//  FlexionTrendCard.swift
//  FlexSight
//

import Charts
import SwiftUI

/// Bar chart of best knee flexion per session, matching the wireframes' TrendCard.
struct FlexionTrendCard: View {
    let points: [TrendPoint]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Flexion trend")
                    .font(.headline)
                    .foregroundStyle(Color.labelPrimary)
                Spacer()
                Text("Last \(points.count) sessions")
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Chart(points) { point in
                BarMark(
                    x: .value("Session", "\(point.session)"),
                    y: .value("Flexion", point.degrees),
                    width: .ratio(0.75)
                )
                .foregroundStyle(Color.accentPrimary)
                .cornerRadius(8)
                .annotation(position: .top) {
                    Text("\(point.degrees)°")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.accentDeep)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 120)
            Text("Best knee flexion per session")
                .font(.caption)
                .foregroundStyle(Color.labelSecondary)
        }
        .padding(20)
        .background(Color.backgroundPrimary, in: .rect(cornerRadius: 20))
    }
}

#Preview {
    FlexionTrendCard(points: [
        TrendPoint(session: 1, degrees: 79),
        TrendPoint(session: 2, degrees: 72),
        TrendPoint(session: 3, degrees: 84),
        TrendPoint(session: 4, degrees: 88),
        TrendPoint(session: 5, degrees: 95),
        TrendPoint(session: 6, degrees: 101),
        TrendPoint(session: 7, degrees: 108),
    ])
    .padding(20)
    .background(Color.backgroundSecondary)
}
