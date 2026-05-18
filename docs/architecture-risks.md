# Architecture Risks

This document tracks macOS architecture risks that should remain explicit during
future parity work.

## Native Lifecycle And Callback Bridge

Risk: `macos/native_appkit.m` owns AppKit object lifetimes and calls back into
MoonBit. Incorrect ownership around `NSEvent`, `NSDraggingInfo`, delegates, or
views can cause invalid memory access that is hard to reproduce.

Current control:

- `scripts/check_ffi_surface.sh` prevents accidental FFI surface growth and
  payload-wrapper regressions.
- Native lifecycle responsibilities are split by ownership boundary:
  `native_appkit_callbacks.m` owns global MoonBit callback registration and
  trampoline invocation; `native_appkit_observers.m` owns notification/run-loop
  observer lifetimes; `native_appkit_window.m` owns `NSView`/`NSWindowDelegate`
  lifetimes and short-lived `NSEvent`/`NSDraggingInfo` handoff.
- Drag-and-drop callbacks snapshot `NSDraggingInfo` inside ObjC and pass only
  physical position plus UTF-8 path payloads to MoonBit.
- Global `sendEvent:` device-event interception snapshots `NSEvent` inside ObjC
  and passes only device-event kind, button, and motion delta to MoonBit.
- View-level mouse, scroll, gesture, key-up, and modifier events snapshot
  `NSEvent` inside ObjC and pass primitive payloads to MoonBit; IME key-down
  forwarding is tracked separately because it depends on the IME state machine.
- Native callback trampolines retain MoonBit closures for the duration of each
  invocation, so callback-driven teardown or observer removal cannot release a
  closure while it is still being invoked.
- GitHub issue #5 remains open until the reporter confirms the latest release
  no longer reproduces the callback lifetime failure.

Required direction:

- Keep ownership fixes in the bridge layer, not in MoonBit-side defensive
  workarounds.
- Prefer narrowing FFI entry points and centralizing callback payload ownership
  before adding more native callbacks.
- Do not move callback registry, AppKit observer ownership, and window delegate
  ownership back into the same native source file.

## AppState Runtime Reentrancy

Risk: `AppStateRuntime` is a singleton-style runtime that coordinates event
queueing, active loop state, callbacks, and exit semantics. Reentrant AppKit
callbacks can violate assumptions if queue transitions are not explicit.

Current control:

- macOS tests are compiled by `moon test --build-only`.
- Core/dpi tests execute through `scripts/check_ci.sh`.

Required direction:

- Treat new event-loop behavior as state-machine work and add white-box tests
  for queue ordering, exit, and callback reentrancy.
- Avoid spreading AppState mutation across unrelated window methods.

## Framework-Linked Native Test Execution

Risk: full `moon test` currently cannot execute AppKit-linked native tests
through the MoonBit native runner because the runner uses a `tcc -run` path that
fails on macOS framework arguments.

Current control:

- `scripts/check_ci.sh` uses `moon test --build-only` for macOS package test
  artifacts and executable tests for framework-free packages.
- `docs/testing.md` documents the exact limitation and the expected validation
  command.

Required direction:

- Replace the build-only macOS gate with executable macOS tests once the
  toolchain supports framework-linked native test execution.

## Opaque Native Handles

Risk: AppKit handles cross the MoonBit/native boundary as `UInt64`. This is
necessary at the raw FFI boundary, but leaking raw handles broadly makes
ownership and lifetime contracts ambiguous.

Current control:

- Public renderer integration uses explicit `Window::content_view_handle()`
  documentation.
- `Window::window_handle()` and `Window::content_view_handle()` both expose the
  AppKit content view, matching raw-window-handle AppKit semantics.

Required direction:

- Keep raw handle APIs narrow and document whether a handle is borrowed,
  retained, stable, or only valid during a callback.
- Do not expose internal selectors such as `rawId` as renderer integration API.

## Backend File Size And Responsibility Split

Risk: `macos/window_delegate.mbt` remains a large coordination point for window
state, AppKit dispatch, cursor behavior, fullscreen behavior, and event
translation.

Current control:

- Behavior-sensitive parity fixes are tracked in `docs/macos-issue-tracker.md`.

Required direction:

- Split by responsibility only when a behavior change or test requires touching
  the area. Avoid mechanical churn without better ownership boundaries.
- Good future seams are cursor mapping, fullscreen positioning, and window
  request/error handling.
