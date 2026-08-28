//
//  RootView.swift
//  FlexSight
//

import SwiftUI

/// Switches between onboarding and the main app. Onboarding shows once per
/// launch — intentionally not persisted, per the exercise's no-persistence rule.
struct RootView: View {
    @State private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            MainTabView()
                .transition(.move(edge: .trailing))
        } else {
            OnboardingView(onFinished: completeOnboarding)
                .transition(.move(edge: .leading))
        }
    }

    private func completeOnboarding() {
        withAnimation(.easeInOut) {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    RootView()
        .environment(SessionStore())
}
