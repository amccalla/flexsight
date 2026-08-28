//
//  InsightsView.swift
//  FlexSight
//

import SwiftUI

/// Sessions recorded this launch, with per-session detail (in-memory only —
/// the exercise brief excludes persistence).
struct InsightsView: View {
    @Environment(SessionStore.self) private var store

    var body: some View {
        NavigationStack {
            Group {
                if store.sessions.isEmpty {
                    emptyState
                } else {
                    sessionList
                }
            }
            .background(Color.backgroundSecondary)
            .navigationTitle("Insights")
        }
    }

    private var sessionList: some View {
        List {
            ForEach(store.sessions.reversed()) { summary in
                NavigationLink {
                    SessionDetailView(summary: summary)
                } label: {
                    SessionListRow(summary: summary)
                }
                .listRowBackground(Color.backgroundPrimary)
            }
        }
        .scrollContentBackground(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            IconBadge(systemImage: "chart.bar.fill")
            Text("No sessions yet")
                .font(.headline)
                .foregroundStyle(Color.labelPrimary)
            Text("Sessions you complete will appear here.")
                .font(.subheadline)
                .foregroundStyle(Color.labelSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    InsightsView()
        .environment(SessionStore())
}
