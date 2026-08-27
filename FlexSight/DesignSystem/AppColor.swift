//
//  AppColor.swift
//  FlexSight
//

import SwiftUI
import UIKit

/// FlexSight palette, mirroring the Figma wireframe variables.
/// Neutral tokens map to system semantic colors so they adapt to dark mode
/// (including elevated contexts like sheets). Brand accents carry explicit
/// dark variants.
extension Color {
    /// accent/primary — #0D9488 (dark: #14B8A6)
    static let accentPrimary = Color(
        light: UIColor(red: 13, green: 148, blue: 136),
        dark: UIColor(red: 20, green: 184, blue: 166)
    )
    /// accent/deep — #0F766E; used as tinted foreground on accentSoft (dark: #5EEAD4)
    static let accentDeep = Color(
        light: UIColor(red: 15, green: 118, blue: 110),
        dark: UIColor(red: 94, green: 234, blue: 212)
    )
    /// accent/soft — #CCFBF1 (dark: #134E4A)
    static let accentSoft = Color(
        light: UIColor(red: 204, green: 251, blue: 241),
        dark: UIColor(red: 19, green: 78, blue: 74)
    )
    /// label/primary — #1C1C1E
    static let labelPrimary = Color(uiColor: .label)
    /// label/secondary — #6E6E73
    static let labelSecondary = Color(uiColor: .secondaryLabel)
    /// label/tertiary — #AEAEB2
    static let labelTertiary = Color(uiColor: .tertiaryLabel)
    /// background/primary (cards, sheets) — #FFFFFF
    static let backgroundPrimary = Color(uiColor: .secondarySystemGroupedBackground)
    /// background/secondary (screens) — #F2F2F7
    static let backgroundSecondary = Color(uiColor: .systemGroupedBackground)
    /// separator/default — #E5E5EA
    static let separatorDefault = Color(uiColor: .separator)
}

private extension Color {
    init(light: UIColor, dark: UIColor) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}

private extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: 1
        )
    }
}
