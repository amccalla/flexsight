//
//  StatCard.swift
//  FlexSight
//

import SwiftUI

/// White rounded stat tile, matching the wireframes' StatCard component.
struct StatCard: View {
    let label: String
    let value: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.labelSecondary)
            Text(value)
                .font(.title.bold())
                .foregroundStyle(Color.labelPrimary)
            Text(detail)
                .font(.footnote)
                .foregroundStyle(Color.labelSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundPrimary, in: .rect(cornerRadius: 16))
    }
}

#Preview {
    StatCard(label: "BEST FLEXION", value: "108°", detail: "+6° vs Aug 22")
        .padding(20)
        .background(Color.backgroundSecondary)
}
