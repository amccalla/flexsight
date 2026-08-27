//
//  InsightsView.swift
//  FlexSight
//

import SwiftUI

/// Placeholder for the Insights screen (Figma frame "06 Insights – Trends") — built in a later step.
struct InsightsView: View {
    var body: some View {
        VStack(spacing: 12) {
            IconBadge(systemImage: "chart.bar.fill")
            Text("Insights coming soon")
                .font(.headline)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundSecondary)
    }
}

#Preview {
    InsightsView()
}
