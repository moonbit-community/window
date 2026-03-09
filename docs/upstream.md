# Upstream Pin

- Repository: `rust-windowing/winit`
- Commit: `5e2f421e346cae601a6211b43ff7a2f7c8e61a46`
- Workspace version: `0.31.0-beta.2`

# Migration Scope

This repository currently targets the smallest useful `macos-arm64` slice first:

- `dpi` value types and scale helpers
- core window/event/control-flow data structures
- a macOS backend that can create a window, poll AppKit events, and run a minimal `run_app` loop
- `ApplicationHandler::new_events` with `StartCause::{Init, Poll, WaitCancelled, ResumeTimeReached}`
- `EventLoopProxy::wake_up()` wired into `WaitUntil` wake-ups
- hidden macOS windows remain alive, while close requests now come from an `NSWindowDelegate`

Known deltas against upstream `winit`:

- Only the macOS backend is implemented.
- The current `ControlFlow::WaitUntil` payload is interpreted as a relative timeout in milliseconds.
- `ApplicationHandler` currently receives a concrete `EventLoop` instead of an `ActiveEventLoop` trait object.
- The initial event surface only includes `CloseRequested`, `SurfaceResized`, and `RedrawRequested`.
