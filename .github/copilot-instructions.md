# Copilot PR Review Instructions

## Project context

FlexSight is a clinical body scan app exercise for iOS, built with SwiftUI. It uses the camera and Apple's Vision framework (body pose detection) to derive body measurements. Because the output is clinical in nature, **measurement correctness is the highest-priority review concern** — a subtle math or coordinate-space bug is worse than a crash.

## When reviewing pull requests

- Look for crashes, force unwraps, unsafe array access, and threading issues.
- Flag incorrect Swift concurrency usage.
- Check @MainActor and UI state mutations for thread safety.
- Look for retain cycles and memory leaks.
- Flag unnecessary complexity and over-engineering.
- Look for SwiftUI state-management issues.
- Ensure async/await and Task usage follows structured concurrency principles.
- Check error handling and edge cases.
- Prefer idiomatic Swift and Apple's API design guidelines.
- Pay particular attention to Vision coordinate conversions and measurement accuracy.
- Call out code that could produce incorrect clinical measurements.
- Distinguish blocking issues from optional suggestions.

## Vision & measurement specifics

- Vision returns **normalized coordinates with a lower-left origin**; UIKit/SwiftUI use an upper-left origin. Flag any conversion that doesn't account for the Y-axis flip, or that mixes coordinate spaces (image space vs. view space vs. capture buffer space).
- Conversions must account for the video/image aspect ratio and any `videoGravity`/content-mode scaling or cropping — normalized points scaled to the wrong rect produce silently wrong measurements.
- Check that landmark **confidence values** are validated before use; low-confidence joints should not silently feed into clinical measurements.
- Watch for unit mix-ups: degrees vs. radians, points vs. pixels, metric vs. imperial. Unit conversions should be explicit and centralized, not scattered inline.
- Angle/distance math should be verifiable: prefer small pure functions with unit tests over math embedded in view or capture code.
- Flag floating-point comparisons with `==` and accumulation patterns that can drift.

## Concurrency & capture pipeline

- Vision requests and frame processing must not run on the main thread; UI updates from the capture pipeline must hop to `@MainActor` explicitly.
- Prefer structured concurrency (`async let`, task groups) over detached tasks; flag `Task.detached` without justification.
- Watch for data races on mutable state shared between the capture callback queue and UI — prefer `Sendable` types and actor isolation over locks.
- Flag unbounded frame processing (no back-pressure/frame dropping) that can queue up work and balloon memory.

## Testing & style

- Measurement and conversion logic should come with unit tests (Swift Testing framework); flag untested math changes.
- Follow the project conventions: 4-space indentation, `@State private var` for SwiftUI state, no Combine (prefer async/await), avoid force unwrapping.
- Flag hardcoded secrets, API keys, or credentials.
- Camera and health-adjacent data are sensitive: flag missing usage descriptions, unnecessary data retention, or measurement data leaving the device without clear purpose.

## Review output

- Lead with blocking issues (correctness, safety, crashes), then optional suggestions — clearly labeled as such.
- For measurement-related findings, explain the failure mode (e.g., "mirrored X coordinates on front camera → left/right joints swapped") rather than just pointing at the line.
