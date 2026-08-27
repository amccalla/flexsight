//
//  HomeView.swift
//  FlexSight
//

import SwiftUI

/// Home screen (Figma frame "01 Home").
struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HomeHeader(dateText: viewModel.dateText, greeting: viewModel.greeting)
                SessionCTACard(onStart: viewModel.startSessionTapped)
                HStack(spacing: 12) {
                    ForEach(viewModel.lastSessionStats) { stat in
                        StatCard(label: stat.label, value: stat.value, detail: stat.detail)
                    }
                }
                FlexionTrendCard(points: viewModel.trendPoints)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color.backgroundSecondary)
        .sheet(isPresented: $viewModel.isShowingSourceSheet) {
            SessionSourceSheet(onChoose: viewModel.choose)
                .presentationBackground(Color.backgroundPrimary)
                .presentationDetents([.height(420)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
    }
}

#Preview {
    HomeView()
}
