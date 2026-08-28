# FlexSight

**See your movement. Track your recovery.**

FlexSight is an iOS app that measures knee range of motion from video. Point the camera at a patient — or analyze a recorded clip — and it detects their body pose, measures knee flexion in real time, counts reps, recognizes the movement being performed, and rolls everything up into per-session results and longitudinal trends.

## What it does

- **Live or recorded analysis.** Record with the camera or pick a saved `.mp4`/`.mov` from the photo library. Both paths run through the exact same pose and measurement pipeline.
- **Real-time knee flexion.** A skeleton overlay tracks the subject, the measured leg is highlighted, and the current knee angle is displayed live. **Convention: 0° = fully straight leg**; flexion is 180° minus the interior hip–knee–ankle angle.
- **Workout-agnostic rep counting.** Reps are detected from flexion excursions, independent of which movement is being performed. The movement library (bodyweight squat, sit-to-stand squat, standing knee raise) is classified per rep, and the session UI reacts if the patient switches movements mid-session.
- **Confidence you can defend.** When joint tracking degrades, the angle readout pauses (`—°`) rather than showing an untrustworthy number, a "Move fully into frame" banner guides the patient, and affected reps are flagged — shown in results, marked orange, and excluded from headline metrics rather than silently trusted.
- **Session results & insights.** Each session ends with reps per workout, best/average peak flexion, mean tracking confidence, and a flexion-by-rep chart. The Insights tab lists completed sessions with drill-in detail; Home tracks best-flexion trend across sessions.

## Architecture

MVVM with SwiftUI, organized by feature (`Onboarding/`, `Home/`, `Session/`, `Insights/`, `DesignSystem/`). Views are thin and declarative; state and orchestration live in `@Observable` view models; measurement logic is in plain, testable value types.

### Measurement pipeline (Apple frameworks only)

```
Frame source                Pose               Geometry              Aggregation
─────────────               ────               ────────              ───────────
VideoFrameSource ─┐
 (AVPlayerItem-   ├─► PoseDetector ─► FlexionGeometry ─► RepCounter ─► SessionViewModel
  VideoOutput)    │    (Vision body    (hip–knee–ankle    (state         │
CameraFrameSource ┘     pose request)   angle, aspect-     machine)      ├─► WorkoutClassifier
 (AVCaptureVideo-                       ratio corrected)                 └─► SessionSummary → SessionStore
  DataOutput)
```

- **Frame sources** emit `(pixel buffer, timestamp)` via `AsyncStream`. The video source vends display-synced buffers so the overlay always matches what's on screen; the camera source bakes portrait rotation into the buffers. Frames are dropped (never queued) when detection can't keep up.
- **`PoseDetector`** wraps Vision's modern `DetectHumanBodyPoseRequest`, runs off the main actor (`@concurrent`), and maps joints into an app-level `PoseFrame` model. Video orientation is derived from the track's `preferredTransform` and passed to Vision so results are always in upright, normalized, bottom-left-origin coordinates.
- **`FlexionGeometry`** computes knee flexion at the joint. Vision normalizes points to the unit square regardless of image shape, which distorts angles — x is rescaled by the image aspect ratio before any trigonometry. The measured leg is the more-flexed leg among those whose full hip–knee–ankle chain is confidently tracked; chain confidence is the *minimum* joint confidence, because a chain is only as trustworthy as its weakest joint.
- **`RepCounter`** is a pure state machine: a rep is one excursion above a start threshold (40°) and back below an end threshold (20°), debounced by minimum peak and duration. Low-confidence frames hold a rep open rather than aborting it, and each rep records its low-confidence frame ratio.
- **`WorkoutClassifier`** uses deliberately readable heuristics over a rolling window of joint angles: bilateral knee flexion with hip descent → squat family (a sustained dwell near peak flexion — sitting — distinguishes sit-to-stand); deep single-knee flexion with level hips → standing knee raise. Classification runs live (for the session title) and per completed rep.
- **Overlay alignment.** `PoseOverlayView` maps normalized pose coordinates through the same aspect-fill transform `AVPlayerLayer` uses, so the skeleton stays glued to the subject at any screen size. All thresholds live in one reviewable place: `MeasurementThresholds`.
- **`SessionStore`** keeps completed sessions in memory for Home and Insights. There is intentionally no persistence layer.

## Running the app

- **Recommended: a physical iPhone.** The full experience — live camera and video analysis — works on device.
- **Simulator caveat:** in our testing, Vision's body-pose model cannot initialize in the iOS Simulator — verified on the iOS 18.4, 26.2, 26.4.1, and 26.5 Simulator runtimes with Xcode 26, failing with `Error Domain=com.apple.Vision Code=12 "No available compute device for VNComputeStageMain"` even with explicit CPU compute-device routing. Apple doesn't document Simulator support for the 2D body-pose request either way, but an Apple Vision framework engineer has confirmed the companion 3D body-pose request "is not supported on simulator, and requires a device with a neural engine" ([Apple Developer Forums](https://developer.apple.com/forums/thread/743402)), and other developers report the same 2D initialization failures in the Simulator ([thread 697307](https://developer.apple.com/forums/thread/697307), [thread 764948](https://developer.apple.com/forums/thread/764948)). FlexSight detects this at runtime and shows a "Pose detection unavailable" notice instead of failing silently; video playback, UI, and all non-ML flows work fully in the Simulator.
- To analyze a clip: drag a video onto the Simulator (or AirDrop to a device) to add it to Photos, then **Start Session → Choose from Camera Roll**.

## Self-review

*Reviewing this the way I'd review a colleague's PR.*

**What holds up.** The measurement core is the strongest part of this submission. The app is explicit about what it's measuring — 0° means a straight leg, and that convention is shown on screen, so a clinician and the app can't quietly disagree about what "90° of flexion" means. The math accounts for the ways video can mislead: angles are computed in the image's true proportions, video rotation is handled correctly, and the skeleton overlay stays locked onto the person at any screen size — which is also the honest visual proof that the numbers come from where the app says they do. Most importantly, the app knows when to say "I don't know": if it loses a clear view of the hip, knee, or ankle, the angle pauses instead of guessing, the patient is coached back into frame, and any rep measured under those conditions is flagged in the results rather than blended into the averages. Live camera and recorded video run through the same measurement code, so a clip reviewed later means the same thing as a live session. The measuring logic is separate from the app "plumbing," so it can be tested on its own.

**What would not survive clinical scrutiny yet.** The honest limitation: this measures angles as seen by a single camera, in 2D. The numbers are trustworthy when the patient is viewed from the side (the plane of movement facing the camera); if the camera is at an oblique angle, the measured flexion reads lower than reality — and right now the app doesn't detect or warn when that's happening. Readings also aren't smoothed over time yet, so a single noisy frame can inflate a rep's "peak" by a few degrees. The movement-recognition rules (e.g., "a long pause at the deepest bend means sit-to-stand rather than a squat") are reasonable but were tuned on limited footage — they'd need validation against a real set of labeled sessions before anyone treats them as ground truth. And the "confidence" score comes from Apple's model; it's a useful signal, not a calibrated clinical measure of uncertainty.

**What I'd do next.** In order: first, unit tests for the angle math and rep counting, driven by synthetic movement traces — these numbers are what a clinician would act on, so their correctness should be provable on every build without needing a camera or a volunteer. Second, smoothing readings across frames: a rep's "peak" is currently set by whichever single frame was highest, so one noisy frame can add phantom degrees to a patient's chart; smoothing makes peaks reflect the movement rather than the noise. Third, detecting a badly angled camera — today this is the largest source of *silent* error, because an oblique view quietly under-measures flexion with no warning; catching it and coaching the user to reposition (the same way the app already coaches "move fully into frame") turns the biggest accuracy risk into a guided fix. Finally, evaluate Apple's 3D body-pose detection, which estimates joint angles in space rather than as flattened by the camera — that would remove the 2D limitation at its root instead of just warning about it.

## Time spent

Roughly 2.5 hours.

## Tool note

- Built with Claude (Anthropic's Claude Code, driven from Xcode) as a pair-programming agent, with Figma MCP for design specs, Apple documentation search, and simulator tooling for build/verify loops. All architecture decisions and code were reviewed and directed by me.
- GitHub Copilot reviewed pull requests into `main` (see `.github/copilot-instructions.md`), acting as a second set of eyes on each merge.
