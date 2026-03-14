# macOS Alignment Gap Report (2026-03-13)

This document records the current mismatch set between this repository and the pinned upstream in `docs/upstream.md` (`rust-windowing/winit@5e2f421e...`, `winit-reference/winit-appkit/src`).

## Current Verdict

The implementation is **not yet 1:1 aligned** with `winit-reference` semantics.

## High-Priority Gaps

1. Event-loop core architecture is still runtime/wait-loop driven instead of upstream `NSApplication::run + MainRunLoopObserver + AppState` ownership model.
2. Full example behavior parity still has residual semantic differences in several demos (despite file-level coverage).

## Medium-Priority Gaps

1. Event-loop lifecycle flow still relies on a custom deferred-callback runtime rather than upstream run-loop observer ownership.
2. AppState/EventLoop ownership split is closer but still not fully converged to upstream shape.

## Low-Priority Gaps

1. Minor edge ordering/lifecycle differences still exist around startup/show timing in corner cases.

## Action Plan for This Iteration

1. Fix raw-handle correctness and parent-window safety in native/ffi/window layer.
2. Restore keyboard payload parity in callback ABI and MoonBit event creation path.
3. Implement option-as-alt effect at key event creation level.
4. Reconcile modifier state on focus loss.
5. Enforce display mode bit-depth matching.
6. Make build link-config emission deterministic and remove dead framework dependency.
7. Run one full validation pass after code convergence.

## Implementation Status (This Iteration)

- Completed: Raw window handle now exposes content-view handle while keeping internal native box handle for backend operations.
- Completed: Parent window bridge now validates object type first and returns success/failure instead of blind fire-and-forget.
- Completed: Keyboard callback ABI now carries text payloads; MoonBit key event creation receives `text_with_all_modifiers`, `text_ignoring_modifiers`, and `text_without_modifiers`.
- Completed: `OptionAsAlt` now affects key text generation path for left/right/both option modes.
- Completed: Focus-loss now clears pressed modifiers and emits `ModifiersChanged(default)` to reduce stuck-modifier state.
- Completed: Display mode selection now filters by bit depth when provided.
- Completed: Build link config now derives package name from `moon.mod.json` and uses framework set without `Carbon`.
- Completed: Window creation sequence now defers showing until higher-level setup (including fullscreen decisions) is applied.
- Completed: Drag/drop native behavior tightened (empty file drags rejected, drag-exit keeps last pointer position).
- Completed: Fullscreen delegate lifecycle callbacks are now wired from native delegate into MoonBit callback stream.
- Completed: Fullscreen transition state is now tracked in native delegate; fullscreen requests issued during transition are queued and replayed when transition ends.
- Completed: Event-loop immediate-stop path no longer synthesizes proxy wake callbacks for internal stop points.
- Completed: Example parity improvements for `control_flow`, `pump_events`, `run_on_demand`, and `ime`.
- Completed: Example rendering helper now applies real color fills on macOS content views (instead of pure no-op).
- Completed: `EventLoop::system_theme` now reads app effective appearance via native bridge instead of hardcoded light theme.
- Completed: `stop_app_immediately` now maps to `NSApplication::stop + application-defined dummy event` behavior (matching upstream intent).
- Completed: `wakeup` now computes `StartCause` inside app-state dispatch path (closer ownership boundary to upstream).
- Completed: launch-stop path now triggers immediate stop behavior in `did_finish_launching` rather than mutating wait flags.
- Completed: event-loop outer run path now funnels terminal state through `finish_exit` for consistent teardown.
- Completed: example parity tightened for `window`, `dnd`, `pump_events`, and `control_flow`.
- Completed: animated fill in `application` example now uses real start time instead of constant zero.
- Completed: synthetic `NotificationObserver` wrappers were removed from `EventLoop` runtime state.
- Completed: appkit cursor source parity tightened: URL cursor creation is now `NotSupported` (matching reference backend behavior).
- Completed: native wait path now drains pending AppKit events after first wake event instead of processing a single event only.
- Completed: `application` example `about_to_wait`/continuous-redraw flow now follows upstream intent (exit-only about_to_wait; redraw chaining in redraw handler).
- Completed: `application` proxy wake path no longer creates synthetic windows; it now behaves as a message wake mechanism with side-effect-free handling.
- Completed: `run_iteration` post-wait order now dispatches `wakeup/new_events` before deferred event callbacks from the waited cycle, matching upstream intent more closely.
- Completed: post-wait phase now also dispatches window event queues in the same cycle (reducing one-iteration lag for native input/window events).
- Completed: `application` example now implements `device_event` and `standard_key_binding` callbacks for closer behavioral coverage to upstream demo.
- Completed: lifecycle notifications (`did_finish_launching` / `will_terminate`) are now fed directly into deferred callbacks; synthetic notification polling and the temporary `notification_center` bridge were removed.
- Completed: removed synthetic `hide_application` / `hide_other_applications` / `automatic_window_tabbing` shadow state caches from `event_loop`.
- Completed: moved `Window` cursor/IME API surface from `view.mbt` back into `window.mbt` to better match upstream file-level ownership.
- Completed: keyboard payload extraction in native AppKit view now uses guarded accessors for repeat/character fields, preventing `FlagsChanged` invalid-message crashes.
- Completed: monitor backend now enumerates native display modes (resolution/bit-depth/refresh-rate) via minimal mode-handle primitives instead of exposing only a single fallback mode.
- Completed: removed synthetic `will_terminate` injection from `EventLoop::finish_exit`; termination notification handling is now lifecycle-driven only.
- Completed: example rendering flow now calls `pre_present_notify()` explicitly in `RedrawRequested` handlers, matching upstream example structure more closely.
- Completed: moved window-id allocation from `EventLoop` runtime fields into `AppState`, reducing per-loop synthetic state.
- Completed: removed `EventLoop`-owned window-id list tracking; window-exit cleanup now iterates `AppState` handle registry directly.
- Completed: removed destroyed-window intermediate queue/filter pass from `dispatch_window_events`; destruction handling now flows through native callback + handle unregister path.
- Completed: relocated `dispatch_window_events` implementation from `window_delegate` back into `event_loop` to restore file-level ownership boundaries.
- Completed: removed synthetic `ApplicationHandler::macos_handler` gate; macOS standard key-binding callbacks now dispatch through the normal trait method path.
- Completed: removed duplicate deferred-callback dispatch in `run_iteration`; event delivery now uses a single `dispatch_window_events` pass per phase.
- Completed: removed synthetic `did_finish_launching` queue injection from `run_init_sequence`; initialization now prefers native lifecycle notification flow with a fallback path only when needed.
- Completed: monitor refresh-rate parity improved: when display-mode refresh is unavailable, backend now falls back to CoreVideo display-link nominal refresh rate (matching upstream strategy).
- Completed: `run_app_on_demand` no longer performs an extra post-run reset cycle; duplicate `internal_exit` side effects were removed.
- Completed: added native visibility/resizability getters and switched `Window::is_visible` / `Window::is_resizable` to query native state instead of relying on stale cached flags.
- Completed: `did_finish_launching` handling moved from pending-notification polling into the deferred callback stream, reducing synthetic lifecycle polling.
- Completed: `run_init_sequence` now drains deferred lifecycle callbacks before fallback initialization, allowing native launch notification flow to drive init events.
- Completed: `will_terminate` handling now also flows through deferred callbacks; event-loop notification polling hooks were removed.
- Completed: added native decoration-state getter and switched `Window::is_decorated` to query live AppKit state.
- Completed: `Window::drag_window` error mapping now distinguishes `RequestError::Ignored` (no current AppKit event) from unsupported cases, matching upstream semantics.
- Completed: `examples/ime` behavior now aligns more closely with upstream for IME hint cycling and `Ime::DeleteSurrounding` byte-range deletion semantics.
- Completed: event-loop exit finalization now closes all tracked windows before teardown and drains resulting callbacks, improving `Destroyed` delivery parity.
- Completed: deferred callback ordering was tightened by removing extra drains in `cleared`/`wakeup` and post-dispatch eager-drain in `maybe_queue_with_handler`; callback processing now stays in explicit event-loop dispatch phases.
- Completed: lifecycle `did_finish_launching` is now emitted from `NSApplicationDidFinishLaunchingNotification` observer path instead of manual `finishLaunching`-time synthetic emission.
- Completed: removed synthetic `pending_proxy_wake` stop-before-wait behavior in `cleared`; wait/continue decisions now rely on control-flow/timeout/exit semantics instead of proxy side flags.
- Completed: `will_terminate` notification queuing now guards on running state to avoid stale lifecycle callbacks leaking across non-running periods.
- Completed: `did_finish_launching` callback queueing now short-circuits once launch state is set, preventing duplicate lifecycle dispatch attempts.
- Completed: `notify_windows_of_exit` now closes all AppKit windows through the application-level native path before MoonBit handle cleanup, matching upstream exit intent more closely.
- Completed: redraw dispatch path now invokes handler directly (or queues only on active re-entrancy) instead of routing through generic window-event dispatch helper, reducing redraw ordering drift.
- Completed: `examples/application` now tracks modifier state per window (instead of one global modifier cache), reducing multi-window key/mouse binding drift relative to upstream `WindowState.modifiers`.
- Completed: `examples/child_window` now keeps per-window fixed colors using the upstream-style power-of-three progression and aligns pointer-enter logging wording.
- Completed: `examples/application` proxy wake handling now uses an explicit action queue drained in `proxy_wake_up`, replacing the previous single pending-message flag.
- Completed: `examples/application` cursor state (`cursor grab`, `named cursor index`, `custom cursor index`) now uses per-window storage instead of shared global state, matching upstream `WindowState` ownership more closely.
- Completed: `examples/application` cursor-grab cycling order now follows upstream (`None -> Confined -> Locked -> None`) and updates per-window state only after successful native request.
- Completed: `examples/application` `Alt+Left` drag-resize now computes edge/corner direction from pointer position and scale-aware border width, instead of forcing a fixed south-east direction.
- Completed: `examples/application` continuous-redraw toggle now explicitly requests a redraw when enabling, matching upstream redraw bootstrap behavior.
- Completed: removed the synthetic one-line wrapper layer at the end of `macos/app_state.mbt`; call sites now invoke `app_state_*` functions directly from `event_loop/view/window/window_delegate`, reducing non-upstream indirection and tightening ownership boundaries.
- Completed: `examples/application` window state now stores `animated_fill/continuous_redraw/emit_surface_size/occluded` per window entry instead of maintaining separate global `window_id` sets, moving the example closer to upstream `WindowState` ownership semantics.
- Completed: removed the synthetic fallback path that force-called `did_finish_launching` from `EventLoop::run_init_sequence`; initialization now relies on native lifecycle notification delivery for first-launch bootstrap.
- Completed: `EventLoop::notify_windows_of_exit` now mirrors upstream intent more directly by closing AppKit windows and leaving handle/event cleanup to normal callback/teardown paths, instead of force-unregistering handles in-place.
- Completed: `will_terminate` no longer calls `internal_exit` eagerly from the callback path; exit now flows through normal event-loop finalization, preventing deferred callbacks from being dropped prematurely.
- Completed: `app_state_cleared`/`app_state_wakeup` now additionally gate on launched state, preventing `about_to_wait/new_events` style loop activity before launch initialization is completed.
- Completed: startup running-state semantics now more closely follow upstream intent: `EventLoop::start_running` sets running state only when already launched; first-launch running transition is driven by `DidFinishLaunching`.
- Completed: deferred-callback dispatcher now allows lifecycle callbacks (`DidFinishLaunching` / `WillTerminate`) to be processed even before running state is set, enabling launch bootstrap without pre-init event dispatch.
- Completed: `DidFinishLaunching` notification queuing now always wakes the native loop, preventing missed bootstrap when the callback arrives before running state is set.
- Completed: `run_init_sequence` now branches by launched-state (`dispatch_init_events` for relaunch, deferred lifecycle dispatch for first launch) instead of always draining deferred callbacks first, reducing relaunch-path ordering drift.
- Completed: `WillTerminate` notification queuing no longer depends on running state, allowing lifecycle shutdown callbacks to propagate even during early launch/transition windows.
- Completed: `examples/control_flow` now logs incoming `WindowEvent` values like upstream, improving observable behavior parity for interactive control-flow transitions.
- Completed: `WillTerminate` callback dispatch no longer closes windows directly; window close/destroy now converges through the unified exiting/finalization path, reducing duplicate-close ordering drift.
- Completed: exiting handling in `app_state_cleared` now matches upstream ordering (`stop_app_immediately` before `notify_windows_of_exit`).
- Completed: redraw dispatch now follows upstream re-entrancy rule more closely: if handler is already in use, redraw is no longer re-queued; immediate redraw dispatch occurs only in non-reentrant path.
- Completed: `WillTerminate` dispatch has been re-aligned to upstream-style immediate shutdown semantics: close windows during lifecycle callback, then perform `internal_exit`.
- Completed: lifecycle queueing now deduplicates pending `DidFinishLaunching` / `WillTerminate` callbacks to avoid duplicate lifecycle dispatch under repeated native notifications.
- Completed: `examples/ime` key/IME update timing now more closely follows upstream sample behavior (removed extra Escape-exit path and removed non-upstream IME update requests on Backspace/DeleteSurrounding).
- Completed: `examples/application` cursor cycle list now covers the full upstream cursor icon set (including context/menu, directional resize, and table/selection cursors), reducing demo coverage gaps.
- Completed: `examples/application` now dumps monitor information at startup and logs `ScaleFactorChanged` / `MouseWheel` events in upstream-like form.
- Completed: `WillTerminate` handling has been re-aligned to immediate lifecycle shutdown semantics (close windows + `internal_exit`) to stay closer to upstream callback behavior.
- Completed: `examples/application` now tracks per-window theme state and uses it when filling redraws (instead of a single hardcoded color), reducing theme-related demo drift.
- Completed: `examples/ime` text-state output format now matches upstream style more closely (printing cursor-marked text directly, without extra synthetic metadata lines).
- Completed: `examples/child_window` child placement now derives from current child index (`windows.len() - 1`) instead of synthetic monotonic counters, matching upstream placement semantics more closely.
- Completed: `examples/ime` surface-creation path now follows upstream error-handling intent more closely by exiting gracefully on window creation failure instead of relying on unchecked creation.
- Completed: `examples/application` window creation helper now uses fallible creation and reports errors instead of relying on unchecked creation paths, matching upstream error-propagation intent more closely.
- Completed: removed redundant running-state teardown in `EventLoop::finish_exit` and now rely on `internal_exit` as the single exit-state reset point, reducing shutdown-path divergence.
- Completed: `examples/ime` now uses capability-builder composition (`default + with_*`) for IME enable requests, matching upstream capability declaration style more closely.
- Completed: `WillTerminate` notification queueing now ignores pre-launch state and deduplicates pending callbacks, reducing stale termination-callback leakage across startup phases.
- Completed: `examples/window` and `examples/dnd` close-request handling now exits loop without forcing an immediate local window drop, matching upstream sample flow more closely.
- Completed: `examples/child_window` now matches upstream sample flow more closely by keeping close-request behavior as the sole exit trigger and aligning child creation log wording.
- Completed: `examples/application` help text for Alt+Left drag-resize now reflects edge/corner-based direction selection behavior.
- Completed: removed synthetic handle-ID allocation in `window_delegate`; window handles now directly reuse native AppKit handles, reducing non-upstream indirection.
- Completed: removed synthetic cache fields for surface/min/max/increment/tab-count bookkeeping in `window_delegate`; these paths now forward directly to native operations/getters.
- Completed: title and tabbing identifier reads now come from native getters (`mbw_window_title_utf8` / `mbw_window_tabbing_identifier_utf8`) instead of MoonBit-side shadow caches.
- Completed: most `window_delegate` native operations now dispatch directly on native handles (without synthetic closure relays); synthetic runtime state is narrowed to only `disallow_hidpi` and queued fullscreen transition intent.
- Completed: native `Destroyed` callbacks now immediately drop `window_delegate` runtime state (`remove_window_runtime`) before unregistering handles, preventing stale per-window transition/HiDPI state.
- Completed: `EventLoop::start_running` no longer force-calls `internal_exit`/redraw reset at run start; run state bootstrap now avoids clearing queued lifecycle/deferred state before first dispatch.
- Completed: `disallow_hidpi` is now stored directly on `Window` state (instead of `window_delegate` synthetic runtime), reducing synthetic runtime ownership to fullscreen-transition queueing only.
- Completed: `EventLoop::finish_exit` no longer force-closes windows; close/destroy delivery is now fully lifecycle-driven from `app_state` exit paths.
- Completed: `app_state_internal_exit` no longer clears the window-handle registry, avoiding premature native-handle map teardown during shutdown/final callback delivery.
- Completed: `notify_windows_of_exit` is now a module-level event-loop primitive (instead of an `EventLoop` method), and `app_state` now calls that primitive directly, closer to upstream ownership shape.
- Completed: restored file-level parity for lifecycle observer ownership by reintroducing `macos/notification_center.mbt` and making `EventLoop` explicitly hold notification observer handles.
- Completed: removed implicit global lifecycle observer setup from `native_appkit.m`; lifecycle observers are now registered via explicit notification-center bridge calls.
- Completed: removed additional synthetic `Window` state caches (`visible/resizable/decorated/cursor-visible/cursor-hittest/ime-allowed/ime-purpose/ime-hints/ime-cursor-area`) and switched corresponding getters to live native queries.
- Completed: `WillTerminate` callback queueing no longer short-circuits on pre-launch state, reducing the chance of dropped lifecycle termination callbacks during startup edges.
- Completed: `app_state_cleared` / `app_state_wakeup` now gate only on handler readiness (`is_running && !in_handler`) and no longer duplicate an extra `is_launched` check, matching upstream trigger conditions more closely.
- Completed: `pump_app_events` bootstrap path now actively blocks until launch notification is delivered (when first run starts from pre-launch state), reducing first-pump launch ordering drift versus upstream `app.run()` bootstrap semantics.
- Completed: notification-center observer ownership in native backend now uses explicit `retain/release` (non-ARC safe) instead of ARC bridge casts, removing lifecycle-handle ambiguity and bridge warnings.
- Completed: native notification observers now register without sender filtering (`object:nil`), matching upstream notification-center observer semantics more closely.
- Completed: `EventLoop::try_new_with_platform_attributes` now performs `override_send_event` before installing lifecycle observers, matching upstream initialization order more closely.
- Completed: lifecycle notification wiring now uses observer-local callback bindings (passed at observer creation) instead of a global lifecycle callback registry, reducing synthetic global C runtime state.
- Completed: removed `mbw_install_lifecycle_callback` global registration API from the native bridge; launch/terminate notification delivery is now owned by `notification_center` observer handles.
- Completed: native app initialization no longer force-calls `finishLaunching` during early bridge setup; launch completion is now triggered lazily at first event-loop wait/stop path so `DidFinishLaunching` observers are installed before notification delivery.
- Completed: removed `window_delegate` local synthetic window runtime tables (`SyntheticWindow` handle/state arrays); handle validity now derives from `app_state` registered window-handle map.
- Completed: fullscreen transition replay queue is now owned by MoonBit `app_state` (`fullscreen_requests`) keyed by `raw_id`; C delegate only exposes transition-state primitive (`inFullscreenTransition`).
- Completed: fullscreen transition processing now happens in `app_state_queue_native_window_event` for callback kinds `11/12/13`, removing `window_delegate`-local synthetic queue state while preserving deferred replay semantics.
- Completed: window-handle registration now happens immediately after successful native creation/parent setup, so pre-show window attribute application (`theme`, `cursor`, `IME`, `tabbing`, `blur`, `transparent`, etc.) no longer gets dropped by liveness guards.
- Completed: maximized-state query now follows upstream `is_zoomed` semantics more closely by using a temporary `Titled|Resizable` style probe for borderless windows in native AppKit bridge.
- Completed: `set_enabled_buttons` now updates both style-mask capability bits (`Closable`/`Miniaturizable`) and zoom button enabled-state, matching upstream behavior boundaries more closely.
- Completed: decoration toggling now applies a full style-mask composition (`Titled|Closable|Miniaturizable|Resizable` vs `Borderless|Resizable`) and skips direct style mutation while fullscreen is active.
- Completed: bundled-app detection now uses `NSRunningApplication.currentApplication.bundleIdentifier` (upstream-aligned criterion) instead of bundle-path suffix heuristics.
- Completed: style-mask writes now consistently go through an internal helper that restores first-responder routing (`set_style_mask`, `clear_style_mask_bits`, `set_resizable`), reducing key-event routing drift after style transitions.
- Completed: `set_resizable` now avoids mutating style mask while native fullscreen is active, matching upstream’s “defer style changes during fullscreen transition/mode” boundary more closely.
- Completed: `current_monitor` lookup no longer force-falls back to main display when native monitor is unavailable; it now preserves `None` semantics closer to upstream `current_monitor_inner`.
- Completed: native `set_maximized` now follows upstream branch behavior for non-resizable windows by using frame-based maximize/restore (with stored standard frame) instead of always relying on `zoom`.
- Completed: main run-loop observer ownership has been introduced in the native bridge (`before waiting` / `after waiting`) and is now held/released by `EventLoop`, matching upstream observer-lifetime boundaries more closely.
- Completed: `about_to_wait`, queued redraw dispatch, and `new_events` cause generation are now driven from observer-triggered app-state hooks instead of explicit `run_iteration` pre/post-wait calls.
- Completed: native wait now uses `CFRunLoopRunInMode` instead of manual `nextEventMatchingMask` polling, reducing divergence from upstream run-loop progression semantics.
- Completed: app-state now supports a registered runtime dispatch handler (`dispatch_callback`) so native callback paths can dispatch immediately when safe and queue only on re-entrancy, reducing dependence on outer-loop polling for callback delivery.
- Completed: window/device/proxy/lifecycle/native-window callback enqueue sites now share one dispatch-or-queue path, improving event delivery consistency with upstream `EventHandler` behavior.
- Completed: `try_run_app` / `try_pump_app_events` now explicitly install/clear app-state dispatch handlers per run scope, tightening ownership boundaries between loop runtime and callback dispatch.
- Completed: native `NSApplication::run` invocation is now exposed and used by event-loop iterations/pump bootstrap instead of the old explicit wait-millis stepping path.
- Completed: the legacy wait-millis ABI (`mbw_event_loop_wait_millis`) has been removed from the MoonBit FFI surface and native bridge, reducing non-upstream runtime primitives.
- Completed: `try_run_app` now runs via a direct `NSApplication::run` cycle with explicit post-run deferred dispatch + unified `finish_exit` finalization, removing the previous manual outer `run_loop` stepping layer.
- Completed: `pump_app_events` control flow has been simplified to launch/rerun/timeout branches around direct `NSApplication::run`, and `try_pump_app_events` is now non-fallible (matching upstream pump semantics more closely).

## Remaining Structural Work

- Not completed: Final `run_app` / `run_app_on_demand` / `pump_app_events` control-flow parity cleanup (the backend now runs through `NSApplication::run`, but loop entry/exit orchestration still retains MoonBit-specific scaffolding).
- Not completed: Full example behavior parity for all upstream demo semantics.
