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
            .background(configuration.isPressed ? Color.accentDeep : Color.accentPrimary)
            .clipShape(.capsule)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var flexPrimary: PrimaryButtonStyle { PrimaryButtonStyle() }
}
