//
//  ConfidenceBadge.swift
//  FlexSight
//

import SwiftUI

struct ConfidenceBadge: View {
    let tracking: SessionViewModel.TrackingQuality

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(tracking == .high ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            Text(tracking == .high ? "Tracking: High" : "Tracking: Low")
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(.black.opacity(0.5), in: .capsule)
    }
}

#Preview {
    VStack(spacing: 12) {
        ConfidenceBadge(tracking: .high)
        ConfidenceBadge(tracking: .low)
    }
    .padding()
    .background(Color.gray)
}
