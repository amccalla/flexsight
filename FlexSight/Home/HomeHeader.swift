//
//  HomeHeader.swift
//  FlexSight
//

import SwiftUI

struct HomeHeader: View {
    let dateText: String
    let greeting: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dateText)
                .font(.caption.weight(.medium))
                .kerning(0.8)
                .foregroundStyle(Color.labelSecondary)
            Text(greeting)
                .font(.largeTitle.bold())
                .foregroundStyle(Color.labelPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    HomeHeader(dateText: "TUESDAY, AUG 26", greeting: "Good morning")
        .padding(20)
        .background(Color.backgroundSecondary)
}
