//
//  OnboardingView.swift
//  FlexSight
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    let onFinished: () -> Void

    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            Tab(value: OnboardingPage.welcome) {
                WelcomePageView(onContinue: advance)
            }
            Tab(value: OnboardingPage.overview) {
                OverviewPageView(onGetStarted: onFinished)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(Color.backgroundSecondary.ignoresSafeArea())
        .animation(.easeInOut, value: viewModel.currentPage)
    }

    private func advance() {
        viewModel.advance()
    }
}

#Preview {
    OnboardingView(onFinished: {})
}
