//
//  WelcomePageView.swift
//  FlexSight
//

import SwiftUI

struct WelcomePageView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            IconBadge(systemImage: "figure.strengthtraining.functional", size: 88)
            Text("FlexSight")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.labelPrimary)
                .padding(.top, 24)
            Text("See your movement. Track your recovery.")
                .font(.title3)
                .foregroundStyle(Color.labelSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
            Spacer()
            Button("Continue", action: onContinue)
                .buttonStyle(.flexPrimary)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 44)
    }
}

#Preview {
    WelcomePageView(onContinue: {})
        .background(Color.backgroundSecondary)
}
