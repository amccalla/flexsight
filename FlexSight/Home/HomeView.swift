//
//  HomeView.swift
//  FlexSight
//

import PhotosUI
import SwiftUI

/// Home screen (Figma frame "01 Home").
struct HomeView: View {
    @Environment(SessionStore.self) private var store
    @State private var viewModel = HomeViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HomeHeader(dateText: viewModel.dateText, greeting: viewModel.greeting)
                SessionCTACard(onStart: viewModel.startSessionTapped)
                if store.sessions.isEmpty {
                    HomeEmptyStateCard()
                } else {
                    HStack(spacing: 12) {
                        ForEach(viewModel.lastSessionStats(from: store.sessions)) { stat in
                            StatCard(label: stat.label, value: stat.value, detail: stat.detail)
                        }
                    }
                    if !trendPoints.isEmpty {
                        FlexionTrendCard(points: trendPoints)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color.backgroundSecondary)
        .sheet(isPresented: $viewModel.isShowingSourceSheet) {
            SessionSourceSheet(onChoose: viewModel.choose)
                .presentationBackground(Color.backgroundPrimary)
                .presentationDetents([.height(420), .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .photosPicker(
            isPresented: $viewModel.isShowingVideoPicker,
            selection: $viewModel.pickedVideoItem,
            matching: .videos
        )
        .onChange(of: viewModel.pickedVideoItem) {
            Task { await viewModel.loadPickedVideo() }
        }
        .fullScreenCover(item: $viewModel.activeSession) { input in
            SessionView(input: input)
        }
    }

    private var trendPoints: [TrendPoint] {
        viewModel.trendPoints(from: store.sessions)
    }
}

#Preview {
    HomeView()
        .environment(SessionStore())
}
