//
//  AppColor.swift
//  FlexSight
//

import SwiftUI

/// FlexSight palette, mirroring the Figma wireframe variables.
extension Color {
    /// accent/primary — #0D9488
    static let accentPrimary = Color(red: 13 / 255, green: 148 / 255, blue: 136 / 255)
    /// accent/deep — #0F766E
    static let accentDeep = Color(red: 15 / 255, green: 118 / 255, blue: 110 / 255)
    /// accent/soft — #CCFBF1
    static let accentSoft = Color(red: 204 / 255, green: 251 / 255, blue: 241 / 255)
    /// label/primary — #1C1C1E
    static let labelPrimary = Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
    /// label/secondary — #6E6E73
    static let labelSecondary = Color(red: 110 / 255, green: 110 / 255, blue: 115 / 255)
    /// label/tertiary — #AEAEB2
    static let labelTertiary = Color(red: 174 / 255, green: 174 / 255, blue: 178 / 255)
    /// background/primary — #FFFFFF
    static let backgroundPrimary = Color.white
    /// background/secondary — #F2F2F7
    static let backgroundSecondary = Color(red: 242 / 255, green: 242 / 255, blue: 247 / 255)
    /// separator/default — #E5E5EA
    static let separatorDefault = Color(red: 229 / 255, green: 229 / 255, blue: 234 / 255)
}
