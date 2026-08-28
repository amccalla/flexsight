//
//  RepositionBanner.swift
//  FlexSight
//

import SwiftUI

/// Actionable guidance shown while tracking confidence is low.
struct RepositionBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.subheadline)
            Text("Move fully into frame")
                .font(.subheadline.weight(.semibold))
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.orange, in: .capsule)
    }
}

#Preview {
    RepositionBanner()
        .padding()
        .background(Color.black)
}
