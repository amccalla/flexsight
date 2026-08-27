//
//  SourceOptionRow.swift
//  FlexSight
//

import SwiftUI

struct SourceOptionRow: View {
    let source: SessionSource
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                IconBadge(systemImage: source.systemImage)
                VStack(alignment: .leading, spacing: 2) {
                    Text(source.title)
                        .font(.headline)
                        .foregroundStyle(Color.labelPrimary)
                    Text(source.subtitle)
                        .font(.footnote)
                        .foregroundStyle(Color.labelSecondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.labelTertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.backgroundSecondary, in: .rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SourceOptionRow(source: .camera, action: {})
        .padding(20)
}
