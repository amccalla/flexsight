//
//  OverviewPageView.swift
//  FlexSight
//

import SwiftUI

struct OverviewPageView: View {
    let onGetStarted: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            Text("How it works")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.labelPrimary)
            Text("We scan the video or your camera recording, detect the workout, and show you real-time results.")
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
                .padding(.top, 8)
            VStack(spacing: 12) {
                OnboardingFeatureRow(
                    systemImage: "video.fill",
                    title: "Scan",
                    subtitle: "Record live or analyze a saved video"
                )
                OnboardingFeatureRow(
                    systemImage: "figure.strengthtraining.functional",
                    title: "Detect",
                    subtitle: "Your workout is recognized automatically"
                )
                OnboardingFeatureRow(
                    systemImage: "chart.bar.fill",
                    title: "See results",
                    subtitle: "Watch joint angles and progress in real time"
                )
            }
            .padding(.top, 28)
            Spacer()
            Button("Get Started", action: onGetStarted)
                .buttonStyle(.flexPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 44)
    }
}

#Preview {
    OverviewPageView(onGetStarted: {})
        .background(Color.backgroundSecondary)
}
