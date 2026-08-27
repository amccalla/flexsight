//
//  ContentView.swift
//  FlexSight
//
//  Created by Drew McCalla on 8/26/26.
//

import SwiftUI

/// Placeholder for the Home screen (Figma frame "01 Home") — built in a later step.
struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            IconBadge(systemImage: "house.fill")
            Text("Home coming soon")
                .font(.headline)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundSecondary)
    }
}

#Preview {
    ContentView()
}
