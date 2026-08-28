//
//  PlayerLayerView.swift
//  FlexSight
//

import AVFoundation
import SwiftUI

/// Full-bleed video layer. SwiftUI's VideoPlayer doesn't expose the layer
/// geometry the pose overlay needs to stay aligned, so this wraps AVPlayerLayer
/// with the same aspect-fill the overlay mapping assumes.
struct PlayerLayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> PlayerContainerUIView {
        let view = PlayerContainerUIView()
        view.playerLayer.player = player
        view.playerLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PlayerContainerUIView, context: Context) {
        uiView.playerLayer.player = player
    }

    final class PlayerContainerUIView: UIView {
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }
}
