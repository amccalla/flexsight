//
//  TagChip.swift
//  FlexSight
//

import SwiftUI

/// Soft-teal pill label, matching the wireframes' Chip component.
struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(Color.accentDeep)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color.accentSoft, in: .capsule)
    }
}

#Preview {
    TagChip(text: "Knee flexion")
}
