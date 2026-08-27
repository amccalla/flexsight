//
//  SessionSource.swift
//  FlexSight
//

import Foundation

/// How the user captures movement for a session.
enum SessionSource: String, CaseIterable, Identifiable {
    case camera
    case cameraRoll

    var id: String { rawValue }

    var title: String {
        switch self {
        case .camera: "Record with camera"
        case .cameraRoll: "Choose from Camera Roll"
        }
    }

    var subtitle: String {
        switch self {
        case .camera: "Capture the movement live"
        case .cameraRoll: "Pick a saved .mp4 or .mov"
        }
    }

    var systemImage: String {
        switch self {
        case .camera: "camera.fill"
        case .cameraRoll: "photo.on.rectangle"
        }
    }
}
