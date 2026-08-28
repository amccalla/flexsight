//
//  HomeEmptyStateCard.swift
//  FlexSight
//

import SwiftUI

/// Shown in place of the stats and trend cards until the first session of
/// this launch is recorded.
struct HomeEmptyStateCard: View {
    var body: some View {
        VStack(spacing: 10) {
            IconBadge(systemImage: "chart.line.uptrend.xyaxis")
            Text("No sessions yet")
                .font(.headline)
                .foregroundStyle(Color.labelPrimary)
            Text("Complete your first session to see your stats and flexion trend here.")
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.backgroundPrimary, in: .rect(cornerRadius: 20))
    }
}

#Preview {
    HomeEmptyStateCard()
        .padding(20)
        .background(Color.backgroundSecondary)
}
