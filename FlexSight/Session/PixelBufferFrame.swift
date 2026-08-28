//
//  PixelBufferFrame.swift
//  FlexSight
//

import CoreVideo
import Foundation

/// A single frame handed from a capture/playback source to the pose pipeline.
/// CVPixelBuffer isn't Sendable; ownership transfers frame-by-frame and the
/// buffer is never mutated, so the unchecked conformance is safe in practice.
struct PixelBufferFrame: @unchecked Sendable {
    let buffer: CVPixelBuffer
    let timestamp: TimeInterval
}
