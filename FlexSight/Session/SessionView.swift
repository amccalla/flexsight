//
//  SessionView.swift
//  FlexSight
//

import SwiftUI

/// Full-screen measurement session (Figma frames "03 Session – Active" and
/// "04 Session – Low Confidence"), transitioning to the summary when done.
struct SessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var store
    @State private var viewModel: SessionViewModel

    init(input: SessionInput) {
        _viewModel = State(initialValue: SessionViewModel(input: input))
    }

    var body: some View {
        ZStack {
            if let summary = viewModel.summary {
                SessionSummaryView(summary: summary, onDone: dismissSession)
                    .transition(.move(edge: .bottom))
            } else {
                sessionContent
            }
        }
        .animation(.easeInOut, value: viewModel.summary != nil)
        .task { await viewModel.start() }
        .onDisappear { viewModel.stop() }
    }

    private var sessionContent: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            mediaLayer
            if viewModel.isReady {
                overlayLayer
                scrimLayer
                VStack {
                    SessionTopBar(
                        workoutName: viewModel.currentWorkout?.displayName,
                        subtitle: viewModel.isLive ? "Live session" : "Recorded video",
                        tracking: viewModel.tracking,
                        onClose: close,
                        onSwitchCamera: switchCameraAction
                    )
                    .padding(.horizontal, 16)
                    Spacer()
                    bottomHUD
                }
                if viewModel.tracking == .low, !viewModel.poseUnavailable,
                   !viewModel.playbackFinished, viewModel.summary == nil {
                    RepositionBanner()
                }
                if viewModel.poseUnavailable, !viewModel.playbackFinished {
                    poseUnavailableNotice
                }
                if viewModel.playbackFinished {
                    playbackFinishedNotice
                }
            } else if !viewModel.cameraUnavailable {
                loadingOverlay
            }
            if viewModel.cameraUnavailable {
                cameraUnavailableNotice
            }
        }
    }

    private var loadingOverlay: some View {
        VStack(spacing: 14) {
            ProgressView()
                .controlSize(.large)
                .tint(.white)
            Text(viewModel.isLive ? "Starting camera…" : "Loading video…")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    @ViewBuilder private var mediaLayer: some View {
        if let player = viewModel.player {
            PlayerLayerView(player: player)
                .ignoresSafeArea()
        } else if let session = viewModel.cameraSession {
            CameraPreviewView(session: session)
                .ignoresSafeArea()
        }
    }

    @ViewBuilder private var overlayLayer: some View {
        if let pose = viewModel.currentPose, viewModel.contentSize != .zero {
            PoseOverlayView(
                pose: pose,
                contentSize: viewModel.contentSize,
                measuredSide: viewModel.measuredSide,
                flexionLabel: viewModel.displayFlexion.map { "Knee · \($0)°" }
            )
            .ignoresSafeArea()
        }
    }

    private var scrimLayer: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [.black.opacity(0.55), .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: 180)
            Spacer()
            LinearGradient(colors: [.clear, .black.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                .frame(height: 300)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private var bottomHUD: some View {
        VStack(spacing: 16) {
            AngleHUD(flexion: viewModel.displayFlexion)
            SessionMiniStats(
                repCount: viewModel.reps.count,
                bestPeak: viewModel.bestPeak,
                averagePeak: viewModel.averagePeak
            )
            if viewModel.isLive {
                Button("End Session", action: viewModel.endSession)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.white.opacity(0.16), in: .capsule)
            } else {
                PlaybackControlsBar(viewModel: viewModel)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private var poseUnavailableNotice: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(Color.orange)
            Text("Pose detection unavailable")
                .font(.headline)
                .foregroundStyle(.white)
            Text("This Simulator runtime can't run Vision's body-pose model. Run FlexSight on an iPhone to measure movement.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(.black.opacity(0.8), in: .rect(cornerRadius: 20))
        .padding(.horizontal, 36)
    }

    private var playbackFinishedNotice: some View {
        VStack(spacing: 8) {
            Text("Video complete")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Replay the video or continue to your results.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Button("View Results", action: viewModel.endSession)
                .buttonStyle(.flexPrimary)
                .padding(.top, 12)
            Button("Replay Video", action: viewModel.replay)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.white.opacity(0.16), in: .capsule)
        }
        .padding(24)
        .background(.black.opacity(0.8), in: .rect(cornerRadius: 20))
        .padding(.horizontal, 36)
    }

    private var cameraUnavailableNotice: some View {
        VStack(spacing: 12) {
            Image(systemName: "video.slash.fill")
                .font(.title)
                .foregroundStyle(.white)
            Text("Camera unavailable")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Run on a device, or analyze a saved video instead.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Button("Close", action: dismissSession)
                .buttonStyle(.flexPrimary)
                .padding(.top, 8)
        }
        .padding(24)
        .background(.black.opacity(0.75), in: .rect(cornerRadius: 20))
        .padding(40)
    }

    private var switchCameraAction: (() -> Void)? {
        guard viewModel.isLive else { return nil }
        return { viewModel.switchCamera() }
    }

    private func close() {
        if viewModel.closeTapped() {
            dismiss()
        }
    }

    private func dismissSession() {
        if let summary = viewModel.summary {
            store.add(summary)
        }
        dismiss()
    }
}
