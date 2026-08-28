//
//  SecondaryButtonStyle.swift
//  FlexSight
//

import SwiftUI

/// Full-width soft-teal capsule button, matching the wireframes' Button/Secondary component.
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.accentDeep)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.accentSoft.opacity(configuration.isPressed ? 0.6 : 1))
            .clipShape(.capsule)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var flexSecondary: SecondaryButtonStyle { SecondaryButtonStyle() }
}
