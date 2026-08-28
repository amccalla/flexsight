//
//  SessionSourceSheet.swift
//  FlexSight
//

import SwiftUI

/// Bottom sheet for choosing how to capture a session (Figma frame "02 Start Session – Source").
struct SessionSourceSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onChoose: (SessionSource) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Start session")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.labelPrimary)
                Text("Choose how you want to capture your movement")
                    .font(.subheadline)
                    .foregroundStyle(Color.labelSecondary)
            }
            .padding(.bottom, 10)
            ForEach(SessionSource.allCases) { source in
                SourceOptionRow(source: source) {
                    onChoose(source)
                }
            }
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.caption)
                Text("Recorded video runs through the same pose pipeline and angle overlays as the live camera.")
                    .font(.caption)
            }
            .foregroundStyle(Color.labelTertiary)
            .padding(.horizontal, 4)
            .padding(.vertical, 6)
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.flexSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    SessionSourceSheet(onChoose: { _ in })
        .background(Color.backgroundPrimary)
}
