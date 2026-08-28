//
//  MainTabView.swift
//  FlexSight
//

import SwiftUI

/// Root tab container: Home and Insights, per the wireframes' TabBar.
struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            Tab("Insights", systemImage: "chart.bar.fill") {
                InsightsView()
            }
        }
        .tint(Color.accentPrimary)
    }
}

#Preview {
    MainTabView()
        .environment(SessionStore())
}
