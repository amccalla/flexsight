//
//  HomeViewModel.swift
//  FlexSight
//

import Foundation
import Observation
import PhotosUI
import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    var isShowingSourceSheet = false
    var isShowingVideoPicker = false
    var pickedVideoItem: PhotosPickerItem?
    var activeSession: SessionInput?

    let dateText: String
    let greeting: String

    init(now: Date = .now) {
        dateText = now.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()).uppercased()
        greeting = switch Calendar.current.component(.hour, from: now) {
        case ..<12: "Good morning"
        case ..<17: "Good afternoon"
        default: "Good evening"
        }
    }

    // MARK: - Deriving cards from recorded sessions

    func lastSessionStats(from sessions: [SessionSummary]) -> [StatItem] {
        guard let latest = sessions.last else { return [] }
        var bestDetail = "no confident reps"
        if let best = latest.bestFlexion {
            if sessions.count >= 2, let previous = sessions[sessions.count - 2].bestFlexion {
                let delta = Int(best.rounded()) - Int(previous.rounded())
                bestDetail = "\(delta >= 0 ? "+" : "")\(delta)° vs last session"
            } else {
                bestDetail = "first session"
            }
        }
        let dateText = latest.date.formatted(.dateTime.month(.abbreviated).day())
        return [
            StatItem(
                label: "BEST FLEXION",
                value: latest.bestFlexion.map { "\(Int($0.rounded()))°" } ?? "—",
                detail: bestDetail
            ),
            StatItem(
                label: "REPS",
                value: "\(latest.reps.count)",
                detail: "\(latest.confidentReps.count) confident · \(dateText)"
            ),
        ]
    }

    func trendPoints(from sessions: [SessionSummary]) -> [TrendPoint] {
        sessions.suffix(7).enumerated().compactMap { index, session in
            session.bestFlexion.map { TrendPoint(session: index + 1, degrees: Int($0.rounded())) }
        }
    }

    // MARK: - Session launch

    func startSessionTapped() {
        isShowingSourceSheet = true
    }

    func choose(_ source: SessionSource) {
        isShowingSourceSheet = false
        // Let the sheet finish dismissing before presenting the next surface.
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            switch source {
            case .camera:
                activeSession = .camera
            case .cameraRoll:
                isShowingVideoPicker = true
            }
        }
    }

    func loadPickedVideo() async {
        guard let item = pickedVideoItem else { return }
        pickedVideoItem = nil
        guard let movie = try? await item.loadTransferable(type: MovieFile.self) else { return }
        // Presenting the full-screen session while the picker is still
        // dismissing corrupts the cover's safe-area context (chrome renders
        // edge-to-edge). Let the dismissal settle first.
        try? await Task.sleep(for: .milliseconds(700))
        activeSession = .video(movie.url)
    }
}
