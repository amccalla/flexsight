//
//  OnboardingFeatureRow.swift
//  FlexSight
//

import SwiftUI

struct OnboardingFeatureRow: View {
    let systemImage: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            IconBadge(systemImage: systemImage)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.labelPrimary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.labelSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color.backgroundPrimary, in: .rect(cornerRadius: 16))
    }
}

#Preview {
    OnboardingFeatureRow(
        systemImage: "video.fill",
        title: "Scan",
        subtitle: "We scan your video or live camera recording"
    )
    .padding(20)
    .background(Color.backgroundSecondary)
}
