//
//  AngleHUD.swift
//  FlexSight
//

import SwiftUI

/// The big live angle readout with the measurement convention. When confidence
/// is low the number pauses to "—" rather than showing an untrustworthy value.
struct AngleHUD: View {
    let flexion: Int?

    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(flexion.map(String.init) ?? "—")
                    .font(.system(size: 84, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: flexion)
                Text("°")
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("KNEE FLEXION")
                    .font(.caption.weight(.medium))
                    .kerning(0.8)
                    .foregroundStyle(.white.opacity(0.6))
                Text(flexion == nil ? "Angle paused · low confidence" : "0° = straight leg")
                    .font(.footnote)
                    .foregroundStyle(flexion == nil ? Color.orange : .white.opacity(0.85))
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        AngleHUD(flexion: 56)
        AngleHUD(flexion: nil)
    }
    .padding()
    .background(Color.black)
}
