//
//  PrimaryButtonStyle.swift
//  FlexSight
//

import SwiftUI

/// Full-width teal capsule button, matching the wireframes' Button/Primary component.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.accentPrimary.opacity(configuration.isPressed ? 0.75 : 1))
            .clipShape(.capsule)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var flexPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}
