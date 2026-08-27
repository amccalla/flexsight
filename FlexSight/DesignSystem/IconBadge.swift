//
//  IconBadge.swift
//  FlexSight
//

import SwiftUI

/// Circular soft-teal icon badge, matching the wireframes' IconCircle component.
struct IconBadge: View {
    let systemImage: String
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(Color.accentDeep)
            .frame(width: size, height: size)
            .background(Color.accentSoft, in: .circle)
    }
}

#Preview {
    IconBadge(systemImage: "figure.strengthtraining.functional", size: 88)
}
