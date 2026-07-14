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
- View-level mouse, scroll, gesture, key, modifier, and IME forwarding paths
  snapshot `NSEvent` inside ObjC and pass primitive/c-string payloads to
  MoonBit. IME key-down forwarding uses MoonBit pending key snapshot state
  instead of replaying an AppKit event handle.
- Native input callback payload normalization is isolated in
  `macos/native_input_payload.mbt`, keeping raw callback arguments, modifier
  text normalization, text-input callback payloads, pending-key snapshots, and
  event translation behind one MoonBit seam.
- Window close begins with an explicit native closing marker. The marker
  removes content-view frame observers, clears the content-view raw id, blocks
  normal delegate/drag event emission, and lets the delegate emit `Destroyed`
  at most once before clearing its raw id.
- `MBWWindowBox` is the single owner for the retained `NSWindow`, content view,
  and delegate graph after creation; local `alloc` ownership is released after
  property transfer, and box teardown releases its strong properties.
- MoonBit now stores owned macOS windows as the opaque `NativeWindow` external
  object, not as an owned `UInt64`. `mbw_create_window` returns an external
  object whose finalizer destroys the `MBWWindowBox`; `Window::drop` explicitly
  calls the same native destroy path for prompt teardown. If the finalizer runs
  off the AppKit main thread, teardown is transferred back to the main thread.
  Public raw handle getters still return borrowed `UInt64` AppKit pointers.
- Native callback trampolines retain MoonBit closures for the duration of each
  invocation, so callback-driven teardown or observer removal cannot release a
  closure while it is still being invoked.
- Native notification/run-loop observer creation consumes owned MoonBit
  closures on every failure path. Notification observers also retain themselves
  during callback dispatch so callback-driven observer removal cannot deallocate
  the observer before the Objective-C method returns.
- MoonBit stores notification and run-loop observers as opaque external objects
  with native finalizers. Explicit `EventLoop::drop` removal clears the native
  owner pointer first, so a later finalizer is idempotent instead of double
  releasing the observer or transferred closure.
- Copied `CGDisplayModeRef` values are represented as `NativeDisplayMode`
  external objects. Temporary video-mode enumeration still releases promptly,
  and the external finalizer covers fullscreen saved-mode state if explicit
  restore cleanup is skipped.
- Copied CoreFoundation objects that cross into MoonBit, such as
  `CGDisplayCreateUUIDFromDisplayID` results, are represented as private
  external objects. MoonBit can borrow the raw handle for CoreGraphics queries
  but never owns the `CFTypeRef` as a plain integer.
- Custom `NSCursor` values created from RGBA data are retained by a
  backend-agnostic `CustomCursorHandle` external object stored inside
  `core.CustomCursor`. `CustomCursor::into_raw()` remains a borrowed AppKit
  pointer projection used only at the platform edge.
- AppKit-backed external-object finalizers now share the same thread contract:
  prompt explicit cleanup clears the external wrapper immediately, and any
  AppKit/RunLoop teardown reached from a GC finalizer is transferred back to
  the main thread before releasing native objects or unregistering observers.
- Default-menu and unified-titlebar construction no longer carry owned
  `NSMenu`/`NSMenuItem`/`NSToolbar` objects as plain `UInt64`. Short-lived +1
  Objective-C objects are wrapped in a private `NativeObjcObject` external
  object; selector calls receive borrowed raw handles, and explicit
  release/finalizer cleanup is idempotent.
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

- macOS, core, and dpi tests execute through `moon test --release` in
  `scripts/check_ci.sh`.
- Deferred callback queue mutation is isolated in
  `macos/app_state_deferred_queue.mbt`; AppState dispatch code uses the queue
  seam instead of directly pushing, searching, or removing deferred callbacks.
- Event-loop run-state and handler-state mutation is isolated in
  `macos/app_state_run_state.mbt`; AppState dispatch code no longer directly
  mutates running, launched, stop, exit, will-terminate, or dispatch-handler
  fields.
- White-box AppState/View tests use local fixture helpers for runtime reset,
  dispatch callback setup, deferred queue inspection, and window identity
  fixtures; direct `app_state_runtime.val` access is confined to those helpers.
- Deferred callback draining re-checks that a registered dispatch handler still
  exists before each queue pop, so a callback that clears the handler cannot
  cause the next deferred event to be removed and dropped.

Required direction:

- Treat new event-loop behavior as state-machine work and add white-box tests
  for queue ordering, exit, and callback reentrancy.
- Avoid spreading AppState mutation across unrelated window methods.

## Framework-Linked Native Test Execution

Risk: default debug `moon test` can still fail AppKit-linked native tests through
the MoonBit native runner because that path can use `tcc -run`, which fails on
macOS framework arguments.

Current control:

- `scripts/check_ci.sh` uses `moon test --release`, which executes the
  framework-linked macOS tests reliably on the local target.
- `docs/testing.md` documents the debug-runner limitation and the expected
  validation command.

Required direction:

- Keep release-mode executable tests as the local gate until debug native test
  execution handles AppKit framework arguments consistently.

## Opaque Native Handles

Risk: AppKit handles cross the MoonBit/native boundary as `UInt64`. This is
necessary at the raw FFI boundary, but leaking raw handles broadly makes
ownership and lifetime contracts ambiguous.

Current control:

- Public renderer integration uses explicit `Window::content_view_handle()`
  documentation.
- Raw display/window/content-view/`NSScreen` accessors document that returned
  handles are borrowed and must not be released by callers.
- Internal high-traffic registered AppKit window lookup has a
  `BorrowedObjcHandle` adapter at the cursor hittest seam. Owned native
  resources still use external objects with finalizers instead of plain
  `UInt64`.

Required direction:

- Keep raw handle APIs narrow and document whether a handle is borrowed,
  retained, stable, or only valid during a callback.
- Do not represent owned native resources as plain `UInt64`; use external
  objects with finalizers and expose borrowed raw pointers only at the API edge.
- Do not expose internal selectors such as `rawId` as renderer integration API.

## Backend File Size And Responsibility Split

Risk: `macos/window_delegate.mbt` remains a large coordination point for window
state, AppKit dispatch, cursor behavior, fullscreen behavior, and event
translation.

Current control:

- Behavior-sensitive parity fixes are tracked in `docs/macos-issue-tracker.md`.
- Per-window platform state lives in focused state modules:
  `macos/window_platform_state.mbt` for IME/cursor/first-mouse state and
  `macos/window_fullscreen_state.mbt` for fullscreen transition and maximized
  standard frame state.
- Native window request error conversion lives in
  `macos/window_request_error.mbt`; cursor hittest, cursor position, cursor
  grab, drag, and drag-resize paths share the same status/result conversion
  policy.
- Cursor construction, selector fallback, system-resource loading, and retained
  cursor caching live in `macos/cursor.mbt`; the window delegate only applies
  the resolved AppKit cursor to a window.
- Fullscreen transition and queued target state are stored together per window
  in `macos/window_fullscreen_state.mbt`, matching the upstream delegate state
  model instead of leaking delayed requests into global application state.
- Drag-and-drop native payload conversion lives as a pure function in
  `macos/event.mbt`; callback sites only enqueue the resulting window event.

Required direction:

- Split by responsibility only when a behavior change or test requires touching
  the area. Avoid mechanical churn without better ownership boundaries.
- Good future seams are fullscreen positioning restore behavior and other
  native payload conversions that can be tested independently of AppKit.
