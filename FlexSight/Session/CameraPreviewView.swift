//
//  CameraPreviewView.swift
//  FlexSight
//

import AVFoundation
import SwiftUI

/// Full-bleed live camera preview, aspect-filled to match the overlay mapping.
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewContainerUIView {
        let view = PreviewContainerUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewContainerUIView, context: Context) {
        uiView.previewLayer.session = session
    }

    final class PreviewContainerUIView: UIView {
        override static var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}
