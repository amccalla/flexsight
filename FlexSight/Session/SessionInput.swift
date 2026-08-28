//
//  SessionInput.swift
//  FlexSight
//

import Foundation

/// What feeds a measurement session: the live camera or a recorded video.
enum SessionInput: Identifiable, Hashable {
    case camera
    case video(URL)

    var id: String {
        switch self {
        case .camera: "camera"
        case .video(let url): url.absoluteString
        }
    }

    var isLive: Bool {
        if case .camera = self { return true }
        return false
    }
}
