# macOS Alignment Gap Report (2026-03-13)

This document records the current mismatch set between this repository and the pinned upstream in `docs/upstream.md` (`rust-windowing/winit@5e2f421e...`, `winit-reference/winit-appkit/src`).

## Current Verdict

The implementation is **not yet 1:1 aligned** with `winit-reference` semantics.

## High-Priority Gaps

1. Full example behavior parity still has residual semantic differences in several demos (despite file-level coverage).
2. Lifecycle edge-ordering parity for `run/pump/on_demand` shutdown interleavings still needs end-to-end validation across all macOS examples.

## Medium-Priority Gaps

1. Deferred-callback queueing remains a MoonBit adaptation layer and may still diverge in rare re-entrancy corners.
2. A few module-level helper placements differ from upstream Rust file locality due MoonBit package constraints.

## Low-Priority Gaps

1. Minor startup/show timing differences may still exist in corner cases.

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
- Completed: `run_app_on_demand` now uses a dedicated on-demand run path (normalize pump flags, relaunch init-dispatch when already launched, then direct `NSApplication::run` + internal-exit) instead of reusing `try_run_app`.
- Completed: removed `EventLoop::run_init_sequence` and `EventLoop::finish_exit` scaffolding; run/pump/on-demand paths now follow a direct `dispatch-init (if launched) -> NSApplication::run -> deferred dispatch -> internal_exit` shape.
- Completed: `app_state_internal_exit` no longer clears the run-scope dispatch handler; dispatch handler lifetime is now owned by event-loop run scopes (set/clear around each run entry).
- Completed: `WillTerminate` lifecycle handling is now centralized in `app_state_will_terminate` (`notify_windows_of_exit` + deferred-callback termination + `internal_exit`), reducing split shutdown behavior across event-loop/app-state layers.
- Completed: deferred-callback draining now supports lifecycle callback dispatch (`DidFinishLaunching` / `WillTerminate`) even when non-running callbacks are queued ahead, preventing lifecycle-starvation races in stop/wake interleavings.
- Completed: added `macos/app_state_wbtest.mbt` whitebox coverage for wait-timeout selection, `StartCause` synthesis, lifecycle callback dedup, running-state callback gating, and deferred-callback dispatch ordering.
- Completed: added MoonBit-adapted upstream object tests:
  - `core/serde_objects_test.mbt` (maps `winit/tests/serde_objects.rs` intent to Show/Eq representability checks)
  - `macos/send_sync_objects_test.mbt` (maps `winit/tests/send_objects.rs` + `sync_object.rs` intent to value-surface/type-check coverage in MoonBit)
- Completed: `DidFinishLaunching` dispatch order now matches upstream intent more closely by dispatching init callbacks before `stop_on_launch` shutdown handling.
- Completed: re-entrant `RedrawRequested` callbacks are now dropped (instead of deferred) while a handler is in use, matching upstream `handle_redraw` behavior boundaries.
- Completed: expanded `macos/app_state_wbtest.mbt` coverage for launch-dispatch ordering and re-entrant redraw-vs-non-redraw queue behavior.
- Completed: callback bridge lifetime ownership is now explicit and symmetric across MoonBit/C boundaries (`#owned(callback)` in FFI declarations; C callback registration paths no longer double-`incref` callback closures), reducing invalid callback pointer risk in long-running event loops.
- Completed: added macOS monitor extension parity for `MonitorHandleExtMacOS::ns_screen` via MoonBit adaptation function `monitor_ns_screen(monitor)` (foreign-type method extension is disallowed), with native `NSScreen*` lookup by display ID and a primary-monitor whitebox assertion.
- Completed: monitor `NSScreen` lookup now matches upstream strategy more closely by resolving screen identity via display UUID matching (not raw display-id equality), reducing stale-screen mismatch risk across display reconfiguration.
- Completed: expanded `app_state` whitebox coverage for run-loop observer behavior (`before_waiting` redraw/about-to-wait ordering, `after_waiting` `StartCause` propagation, and launch-notification immediate dispatch when a handler is installed), improving confidence in stop/wake interleaving parity.
- Completed: `examples/x11_embed` non-X11 fallback message now matches upstream wording (`This example is only supported on X11 platforms.`).
- Completed: `app_state_handler_ready` now requires a registered dispatch handler in addition to running/not-in-handler state, aligning with upstream `EventHandler::ready()` gating and preventing observer callbacks from being processed during `pump_app_events` idle gaps with no active handler.
- Completed: added whitebox coverage for dispatch-handler gating (`handler_ready_requires_registered_dispatch_handler`, plus before/after waiting no-op behavior when handler is absent).
- Completed: callback enqueue behavior without active handler has been tightened: running callbacks are now dropped (not deferred), while lifecycle callbacks still advance launch/termination state, reducing cross-pump stale-event leakage and aligning closer to upstream `EventHandler` readiness semantics.
- Completed: added whitebox tests for no-handler callback behavior (`running_callbacks_are_dropped_when_dispatch_handler_absent`, `did_finish_launching_updates_state_without_dispatch_handler`).
- Completed: callback queueing now avoids eager same-stack deferred drains; re-entrant callbacks are queued and drained from observer dispatch phases, with whitebox coverage for nested proxy wake/redraw behavior in `app_state`.
- Completed: `DidFinishLaunching` init callback dispatch (`NewEvents(Init)` + `CanCreateSurfaces`) now uses direct handler dispatch instead of re-entrant maybe-queueing, restoring upstream launch-order behavior while keeping deferred queueing for other re-entrant callbacks.
- Completed: `examples/control_flow` log phrasing and startup hints now match upstream wording style more closely (`mode:`/`request_redraw:` plus quoted key-help lines).
- Completed: `examples/application` monitor dump/log flow now follows upstream intent more closely (`Monitors information`, primary-vs-monitor labeling, position/scale reporting, and full available video-mode listing with bit-depth/refresh-rate suffixes), and startup/empty-window lifecycle logs now include upstream-style messages.
- Completed: `examples/application` now initializes proxy/custom-cursor state from `main` via `window_target()` (closer to upstream constructor-time setup), while `can_create_surfaces` owns monitor dump + initial window creation.
- Completed: `examples/application` close/exit and lifecycle logs were tightened again (`Created new window with id=...`, no immediate `CloseWindow` hard-exit), and monitor dump was moved back to `can_create_surfaces` to match upstream stage ordering.
- Completed: `examples/application` action/event logging now tracks upstream observable flow more closely (`Executing action`, close request logs, pointer moved/left/button logs, and modifier/theme change logs).
- Completed: `examples/application` no longer emits extra drag/drop compatibility logs that are not printed by upstream, reducing observable behavior drift.
- Completed: `examples/application` now handles gesture events (`PinchGesture`, `RotationGesture`, `PanGesture`, `DoubleTapGesture`) with upstream-like state/log updates (`zoom`/`rotated`/`panned` tracking), reducing interactive-demo parity gaps.
- Completed: `examples/application` window-state/action logs were further aligned to upstream (`Loading cursor assets`, per-window `Theme: ...`, resize-increment toggle logs, borderless-game toggle logs, cursor/cursor-grab logs, resize-request logs, surface-resized logs, and occluded-draw skip logs).
- Completed: `examples/application` now schedules periodic proxy wake behavior in `about_to_wait` (once per second) and logs startup/shutdown messages (`Starting to send user event every second`, `Application exited`) for closer parity with upstream sample intent.
- Completed: `examples/application` help output headings now use upstream wording (`Keyboard bindings` / `Mouse bindings`).
- Completed: input-event callback ABI was flattened from `payload_handle + N getters` to direct scalar arguments plus text handles (`raw_id/kind/coords/modifiers/text_handles`), removing `MBWInputEventPayload` and the `mbw_input_event_payload_*` export family from native stubs.
- Completed: callback/install/application FFI bridge wrappers in `ffi.mbt` were reduced by converting pure-forward wrappers to direct `extern` declarations (`native_install_*`, `native_application_*`, `native_override_send_event`).
- Completed: production native stubs no longer export test-only C symbols (`mbw_test_*`); corresponding whitebox tests were rewritten to validate behavior through normal backend APIs.
- Completed: added `scripts/check_ffi_surface.sh` and `docs/ffi-export-allowlist.txt` to guard against reintroducing payload-style bindings and to block unreviewed new high-level native export families (`mbw_window_*`, `mbw_application_*`).
- Completed: added `docs/ffi-native-wrapper-allowlist.txt` and extended `scripts/check_ffi_surface.sh` to fail when new `fn native_*` wrappers appear in `ffi.mbt` outside the approved low-level conversion set.
- Completed: removed an additional batch of `ffi.mbt` pure-forward wrappers in window geometry/style/tabs/IME getter-setter paths by binding those `native_window_*` names directly via `extern`, reducing non-semantic MoonBit bridge code.
- Completed: removed another broad set of `ffi.mbt` pure-forward adapters (`Int<->Bool` only) by promoting visibility/resizability/fullscreen/shadow/document/titlebar/cursor/parent/content-protection paths to direct `native_*` `extern` bindings; remaining `fn native_*` wrappers are now limited to UTF-8/byte conversion, null-handle guards, and monitor-id width normalization.
- Completed: introduced minimal ObjC runtime bridge primitives (`class` lookup, selector registration handle, fixed-signature `objc_msgSend` variants) so MoonBit can compose simple AppKit calls without dedicated per-feature C wrappers.
- Completed: migrated application presentation/hide/tabbing controls from `mbw_application_*` dedicated C exports into MoonBit-composed ObjC primitive calls (`sharedApplication`, `presentationOptions`, `hide:`, `hideOtherApplications:`, `setAllowsAutomaticWindowTabbing:`, `allowsAutomaticWindowTabbing`); removed those high-level C exports.
- Completed: further migrated `application_is_bundled`, `application_set_activation_policy`, and `application_set_activate_ignoring_other_apps` into MoonBit-composed ObjC primitive calls; corresponding dedicated C exports were removed.
- Completed: migrated `application_close_all_windows` to MoonBit-composed ObjC primitive calls (`windows` + `makeObjectsPerformSelector:` + `close`), removing the dedicated high-level C export and loop implementation.
- Completed: migrated `window_request_user_attention` to MoonBit-composed ObjC primitive calls (`requestUserAttention:`), with explicit AppKit enum mapping (`critical=0`, `informational=10`); removed the dedicated C export.
- Completed: migrated `application_theme` and `window_theme` from dedicated C exports into MoonBit-composed ObjC primitive calls (`effectiveAppearance` + `name`), with MoonBit-side theme mapping based on appearance-name classification.
- Completed: migrated simple window-state getters (`is_visible`, `has_focus`, `is_occluded`, `is_minimized`) from dedicated C exports into MoonBit-composed ObjC primitive calls, removing corresponding C-side passthrough exports.
- Completed: migrated style-mask-only getters (`is_resizable`, `is_decorated`) from C exports into MoonBit bitmask checks over existing `style_mask` primitive, removing additional C-side passthrough exports.
- Completed: removed legacy no-op C exports for unsupported operations (`window_drag_resize_window`, `window_show_window_menu`) and moved their `NotSupported` behavior directly to MoonBit.
- Completed: migrated additional window property bridge paths (`set/has_shadow`, `set/is_document_edited`, `set_movable_by_window_background`, `set_movable`, `set/is_content_protected`) from dedicated C exports into MoonBit-composed ObjC primitive calls.
- Completed: migrated content-view scalar property bridges (`set_accepts_first_mouse`, `set/get_option_as_alt`, `set/get_ime_purpose`, `set/get_ime_hints`) from dedicated C exports into MoonBit-composed ObjC primitive calls.
- Completed: migrated window visibility/fullscreen/minimize bridge paths (`show`, `set_visible`, `set_minimized`, `set_fullscreen`, `is_fullscreen`, `in_fullscreen_transition`) from dedicated C exports into MoonBit-composed ObjC primitive calls and style-mask checks.
- Completed: migrated additional window interaction/titlebar state bridges (`focus`, `set/get_cursor_hittest`, `is_transparent`, `set_fullsize_content_view`, `set_titlebar_transparent`, `set_title_hidden`, `set_titlebar_hidden`) from dedicated C exports into MoonBit-composed ObjC primitive calls.
- Completed: ran macOS example smoke checks for `pump_events`, `application`, `control_flow`, `run_on_demand`, `ime`, `window`, `dnd`, and `child_window`; each ran for 4 seconds without crash/regression in this iteration.
- Completed: added two low-level ObjC runtime primitive signatures (`objc_msgSend` returning `u64` with one `u64` arg, and `objc_msgSend` `void` with two `u64` args) so MoonBit can compose more AppKit calls without dedicated per-feature C exports.
- Completed: migrated additional window bridge paths from high-level C exports to MoonBit-composed ObjC primitive calls: `style_mask/set_style_mask`, `num_tabs`, `set_tabbing_mode_preferred`, `select_next_tab`, `select_previous_tab`, `select_tab_at_index`, `set_titlebar_buttons_hidden`, `set_enabled_buttons`, `enabled_buttons_mask`, `set_transparent`, and `set_parent`.
- Completed: removed corresponding dedicated `mbw_window_*` C exports/implementations for the above paths in `native_appkit.m`; C now keeps only low-level primitives and remaining platform-necessary bridges.
- Completed: migrated `set_resizable`, `set_skip_taskbar`, and `set_clip_children` from dedicated C exports into MoonBit-composed ObjC primitive calls (style-mask bit update, collection-behavior mutation, and view-layer mask control).
- Completed: removed corresponding C exports/implementations (`mbw_window_set_resizable`, `mbw_window_set_skip_taskbar`, `mbw_window_set_clip_children`) and dropped now-unused `MBWWindowBox` state fields (`skipTaskbar`, `clipChildren`).
- Completed: added a low-level ObjC primitive signature for `objc_msgSend` returning `u64` with `const char*` argument (`mbw_objc_msg_send_u64_bytes`), used as generic UTF-8 bridge input for class/message construction in MoonBit.
- Completed: migrated window string bridge paths from dedicated C exports into MoonBit-composed ObjC primitive calls: `set_title`, `set_name`, `title`, `set_tabbing_identifier`, and `tabbing_identifier`.
- Completed: removed corresponding dedicated C exports/implementations (`mbw_window_set_title`, `mbw_window_set_name`, `mbw_window_title_utf8`, `mbw_window_set_tabbing_identifier`, `mbw_window_tabbing_identifier_utf8`) and dropped now-unused native string-bytes helper.
- Completed: migrated `set_theme` from dedicated C export into MoonBit-composed ObjC primitive calls (`NSAppearance appearanceNamed` + `setAppearance:`), preserving light/dark/system mapping in MoonBit.
- Completed: migrated `set_unified_titlebar` from dedicated C export into MoonBit-composed ObjC primitive calls (`NSToolbar alloc/initWithIdentifier` + `setToolbar:` + optional `setToolbarStyle:`), and removed the corresponding C export/implementation.
- Completed: removed the redundant content-view handle export (`mbw_window_content_view_handle`) by switching window creation flow to the existing MoonBit ObjC primitive path (`native_window_content_view_objc_handle`) and deleting the dedicated C passthrough.
- Completed: added low-level ObjC primitive signatures for struct-by-value message arguments (`objc_msgSend` `void` with `NSSize` and with `NSPoint` payload), exposed as `mbw_objc_msg_send_void_size` and `mbw_objc_msg_send_void_point`.
- Completed: migrated geometry setter bridge paths `set_content_size`, `set_min_content_size`, `set_resize_increments`, and `set_position` from dedicated C exports into MoonBit-composed ObjC primitive calls over the new `NSSize/NSPoint` primitives.
- Completed: removed corresponding dedicated C exports/implementations (`mbw_window_set_content_size`, `mbw_window_set_min_content_size`, `mbw_window_set_resize_increments`, `mbw_window_set_position`).
- Completed: added a small numeric primitive export `mbw_cgfloat_max` and migrated `set_max_content_size` to MoonBit-composed ObjC `NSSize` call path, then removed dedicated C export/implementation `mbw_window_set_max_content_size`.
- Completed: migrated `set_level` from dedicated C export to MoonBit-composed ObjC `setLevel:` call path by introducing minimal level-constant primitives (`mbw_window_level_normal`, `mbw_window_level_floating`, `mbw_window_level_below_normal`), and removed `mbw_window_set_level`.
- Completed: migrated `drag_window` from dedicated C export into MoonBit-composed ObjC primitive calls (`currentEvent`, `respondsToSelector`, `performWindowDragWithEvent:`) while preserving status mapping (`1`/`0`/`-1`), and removed `mbw_window_drag_window`.
- Completed: migrated `window_level`, `window_is_maximized` probe logic (with temporary titled+resizable mask), `window_clear_style_mask_bits`, `window_current_monitor_id`, and `window_scale_factor` from dedicated C exports into MoonBit-composed ObjC primitive paths; removed the corresponding C exports/implementations.
- Completed: added low-level numeric ObjC primitives (`mbw_objc_msg_send_i64`, `mbw_objc_msg_send_double`) to avoid high-level C passthrough logic for scalar property reads.
- Completed: added low-level struct-return ObjC primitives (`rect/size/edgeInsets` component readers) and migrated window geometry/safe-area getter bridge paths into MoonBit (`content/min/max/outer/resize-increment/safe-area/x/y`), then removed the corresponding `mbw_window_*` C getter exports.
- Completed: migrated cursor-visibility state (`set_cursor_visible` / `cursor_visible`) from dedicated C exports into MoonBit-managed state (`Ref[Bool]`) plus ObjC primitive calls (`NSCursor hide/unhide`), and removed the corresponding high-level C exports.
- Completed: added low-level no-argument ObjC primitive `mbw_objc_msg_send_void` for class/instance side-effect messages that return no value, reducing the need for ad-hoc one-off C wrappers.
- Completed: migrated IME property/cursor-area bridges (`ime_allowed`, `set_ime_cursor_area`, `ime_cursor_{x,y,width,height}`) from dedicated C exports into MoonBit-composed ObjC primitive calls (`imeAllowed`, `setImeCursor*`, `inputContext.invalidateCharacterCoordinates`).
- Completed: migrated `set_cursor_grab` mode mapping (`None/Locked`) from dedicated C export into MoonBit logic over CoreGraphics primitive `CGAssociateMouseAndMouseCursorPosition`, and removed `mbw_window_set_cursor_grab`.
- Completed: migrated `set_blur` policy path from dedicated C export into MoonBit (`windowNumber` + radius selection), while reducing native code to a CoreGraphics/CGS raw primitive (`mbw_cgs_set_window_background_blur_radius`).
- Completed: migrated cursor-setting bridge paths (`set_cursor`, `set_custom_cursor`) from dedicated C exports into MoonBit-composed ObjC primitive calls (cursor-kind selector mapping, `isKindOfClass:` validation, and content-view `addCursorRect:cursor:` update), and removed `mbw_window_set_cursor`/`mbw_window_set_custom_cursor`.
- Completed: added low-level ObjC primitive `mbw_objc_msg_send_void_rect_u64` (`objc_msgSend` with `NSRect` + object arg) to support rect-based message sends from MoonBit without feature-specific C wrappers.
- Completed: migrated `set_cursor_position` from dedicated C export into MoonBit-composed geometry conversion (`frame` + `contentRectForFrameRect:`) and CoreGraphics raw call path, and removed `mbw_window_set_cursor_position`.
- Completed: added low-level primitives for cursor-position migration: `mbw_cg_warp_mouse_cursor_position` and rect-return-with-rect-arg ObjC readers (`mbw_objc_msg_send_rect_{x,y,height}_rect` via `NSInvocation`).
- Completed: migrated `set_maximized` from dedicated C export into MoonBit logic, including non-resizable-window standard-frame caching/restore and fullscreen-visible-frame selection; corresponding high-level C export was removed.
- Completed: `close_window` is now MoonBit-wrapped to clear maximized-frame cache before delegating to native close, so maximized-state bookkeeping lives on the MoonBit side.
- Completed: migrated `set_ime_allowed` state transition handling from dedicated C export into MoonBit-composed ObjC calls (`imeState`, `setMarkedText:`, `discardMarkedText`, `setInputSource:`, `setImeAllowed:` + text-input emission), removing the remaining high-level `mbw_window_set_ime_allowed` export.
- Completed: added low-level ObjC primitive signatures required by the above migrations (`mbw_objc_msg_send_void_rect_bool` and `mbw_objc_msg_send_void_i32_u64_i32_u64_i32_i32_u64`).
- Completed: window-level constants were further normalized by replacing `mbw_window_level_{normal,floating,below_normal}` with a single primitive `mbw_appkit_window_level(kind)`, consumed from MoonBit for both set/get level paths.
- Completed: after this batch, `native_appkit.m` no longer exports any `mbw_window_*` symbol family.
- Completed: migrated `application_run` and `application_stop_immediately` control flow from dedicated C exports into MoonBit (`finishLaunching`-once tracking + `run`/`stop:` dispatch), removing `mbw_application_run` and `mbw_application_stop_immediately`.
- Completed: event-loop wake-up posting is now fully MoonBit-owned: `native_event_loop_wake_up_appkit` / stop-immediately paths construct and post `NSEventTypeApplicationDefined` via ObjC primitives, and the dedicated native helper `mbw_event_loop_wake_up_with_start` was removed.
- Completed: removed now-unused native launch-finished state and helper (`g_app_launch_finished`, `mbw_finish_launching_if_needed`) after moving launch/run ownership to MoonBit.
- Completed: removed the remaining dedicated native default-menu installer export; `native_application_initialize_default_menu` now builds menu structure entirely in MoonBit via ObjC primitives (`NSMenu/NSMenuItem` alloc-init, selector wiring, submenu wiring, and `setMainMenu:`), eliminating `mbw_appkit_install_default_menu`.
- Completed: text-input callback ABI now carries raw handles (`event_handle` + `text_handle`/`path_handle`) and minimal scalar state fields; MoonBit `view.mbt` performs text/path decoding and event construction.
- Completed: handle transport stability was restored by retaining/releasing callback-side `NSString` objects around trampoline invocation; `examples/run_on_demand` smoke validation stays stable after this change.
- Completed: DnD path extraction is no longer assembled as newline-joined strings in ObjC; native now forwards the raw filename property-list handle and MoonBit enumerates paths for `DragEntered`/`DragDropped` construction.
- Completed: DnD position conversion (`draggingLocation` + `convertPoint:fromView:`) is now MoonBit-owned via low-level ObjC primitives, so ObjC no longer computes DnD `x/y` payload fields.
- Completed: IME `set_ime_allowed` transition sequencing ownership moved from `ffi.mbt` wrapper logic into `window_delegate.mbt`, and the text-input emission call path now uses the new `eventHandle` selector ABI (`mbw_emitTextInputWithKind:eventHandle:state:text:cursorStart:cursorEnd:pathHandle:`).
- Completed: IME cursor-area update sequencing (`setImeCursor{X,Y,Width,Height}` + `inputContext.invalidateCharacterCoordinates`) ownership moved from `ffi.mbt` into `window_delegate.mbt`, removing another behavior wrapper from `ffi`.
- Completed: IME purpose/hints and IME state getter paths (`ime_purpose`, `ime_hints`, `ime_allowed`, `ime_cursor_{x,y,width,height}`) are now resolved in `window_delegate.mbt` via ObjC primitives instead of `ffi.mbt` behavior wrappers.
- Completed: window appearance/interaction paths (`set_blur`, `set_cursor_hittest`/`cursor_hittest`, `is_transparent`, `set_fullsize_content_view`, `set_titlebar_transparent`, `set_title_hidden`, `set_titlebar_hidden`) were moved from `ffi.mbt` wrappers into `window_delegate.mbt`.
- Completed: `set_parent_window` and `set_window_transparent` ownership moved from `ffi.mbt` wrappers into `window_delegate.mbt` via direct ObjC primitive composition.
- Completed: replaced pointer-based UTF-8 copier export (`mbw_copy_bytes_from_utf8_ptr`) with object-based primitive `mbw_objc_copy_utf8_bytes`, removing direct string-pointer ABI usage from MoonBit call sites.
- Completed: menu removal path (`enabled = false`) remains MoonBit-owned through direct primitive call (`setMainMenu:nil`) without dedicated C behavior wrapper.
- Completed: device-event callback ABI was narrowed to raw `NSEvent` handle delivery from C (no pre-mapped `kind/button/delta` payload); MoonBit now derives `type/button/delta` and performs event-kind mapping before queueing `DeviceEvent`.
- Completed: migrated monitor `display_id -> NSScreen` resolution from dedicated C helper (`mbw_monitor_ns_screen`) to MoonBit-composed ObjC/CoreGraphics primitives (`NSScreen.screens`, `deviceDescription["NSScreenNumber"]`, UUID normalization), removing another behavior-level native export.
- Completed: removed dead native refresh-rate export `mbw_display_refresh_rate_millihertz`; refresh-rate fallback now stays entirely in MoonBit (`maximumFramesPerSecond` via ObjC primitives on resolved screen/main screen).
- Completed: migrated `close_window` lifecycle path from dedicated C export (`mbw_close_window`) into MoonBit-composed ObjC primitive calls (`setAllowClose:`, `close`, `setDelegate:nil`, `setWindow:nil`), with only a generic runtime primitive `mbw_objc_release` added for owned-handle release.
- Completed: narrowed `mbw_create_window` ABI by removing unused visibility/activation/title arguments; initial title application now occurs in MoonBit immediately after handle registration (`set_title`), reducing C-side window-attribute semantics.
- Completed: removed now-unused native UTF-8 title helper from `native_appkit.m` after moving initial title ownership into MoonBit.
- Completed: further narrowed `mbw_create_window` ABI by removing `resizable`/`decorations` parameters; these style decisions are now applied in MoonBit immediately after handle registration (`native_set_resizable` + `set_window_decorations`), with utility-panel bit preservation handled in MoonBit style-mask composition.
- Completed: narrowed `mbw_create_window` ABI again by removing `panel`; utility-window style selection is now applied in MoonBit (`set_window_panel`) as part of post-registration style assembly.
- Completed: narrowed `mbw_create_window` ABI again by removing `raw_id`; raw-id wiring is now MoonBit-owned via ObjC primitive calls (`setRawId:` on delegate/content-view) after parent setup, so creation-time event identity is no longer assigned in C.
- Completed: moved window-close lifecycle sequencing (allow-close toggle, close/delegate-detach/setWindow:nil/release, and maximized-frame cleanup) from `ffi.mbt` helper into `window_delegate` MoonBit flow, reducing `ffi` business-level ownership.
- Completed: moved show/focus/visibility sequencing from `ffi.mbt` helpers into `window_delegate` MoonBit flow (ObjC primitive composition for `makeKeyAndOrderFront:`/`orderFront:`/`orderOut:` + app activation), and removed `native_show_window` / `native_window_set_visible` / `native_window_focus` wrappers.
- Completed: moved minimize/unminimize sequencing from `ffi.mbt` helper into `window_delegate` MoonBit flow (`miniaturize:` / `deminiaturize:` ObjC primitive calls), removing `native_window_set_minimized` wrapper.
- Completed: moved fullscreen transition probing + toggle sequencing from `ffi.mbt` helpers into MoonBit (`window_delegate`/`app_state`) via ObjC primitives (`inFullscreenTransition`, `setInFullscreenTransition:`, `toggleFullScreen:`), removing `native_window_in_fullscreen_transition` / `native_window_set_fullscreen` wrappers while preserving queued replay behavior.
- Completed: narrowed input callback ABI from decoded scalar payloads to `raw_id + kind + event_handle`; keyboard/pointer/gesture field decoding (modifiers/scancode/repeat/text/scroll/phase/pressure) now runs in MoonBit `view.mbt`, and C `MBWContentView` no longer performs event semantic mapping for that path.
- Completed: moved a broad remaining window semantic wrapper set from `ffi.mbt` into `window_delegate.mbt` (title/name/tabbing id, geometry/safe-area reads, style/theme/level/button/tab operations, request-attention, focus/visibility/state getters, cursor+maximize state paths), leaving `ffi` focused on ObjC/runtime primitives and app/monitor bridge helpers.
- Completed: tightened `docs/ffi-native-wrapper-allowlist.txt` to the current reduced wrapper set so removed `native_window_*` wrappers cannot be reintroduced silently.
- Completed: moved monitor/display-mode wrapper logic (`native_find/copy/release/set/capture_*`, `native_monitor_ns_screen`, refresh-rate fallback) from `ffi.mbt` into `monitor.mbt`, and moved additional module-local wrappers (`native_create_window`, cursor-kind mapping, custom-cursor RGBA bridge, observer/notification remove guards, presentation-options accessors) to their owning modules.
- Completed: moved app-state/menu-owned application wrappers out of `ffi.mbt` (`is_bundled`, activation-policy/app-activation setup, default-menu construction helpers), reducing `ffi` wrapper surface to 14 shared helpers (application run/wakeup/shared-handle and window-handle resolution primitives).
- Completed: moved event-loop-owned application control wrappers (`run/stop`, app-defined wake event posting, hide/theme/tabbing controls, close-all-windows) from `ffi.mbt` into `event_loop.mbt`; `ffi` wrapper layer is now reduced to 4 shared handle-resolution helpers (`application_shared_handle`, `window_objc_handle`, `window_content_view_objc_handle`, `window_delegate_objc_handle`).
- Completed: moved the final 4 shared handle-resolution helpers out of `ffi.mbt` into `util.mbt`; `ffi` now contains only low-level primitive bindings (`extern`) and primitive conversion helpers, with zero `fn native_*` behavior wrappers.
- Completed: moved the remaining non-`native_*` helper wrappers (`cg_*`, `objc_*`, and theme/string helpers) from `ffi.mbt` into `util.mbt`; `ffi.mbt` now contains only `extern` primitive bindings.
- Completed: aligned `WillTerminate` handling to avoid handler-in-use re-entrancy coupling in the MoonBit callback bridge: termination is now handled directly with one-time guard (`will_terminate_handled`), reducing risk of close/destroy callbacks being queued and then discarded during shutdown.
- Completed: aligned window-creation sizing with upstream `window_delegate::new_window`: `surface_size` is now the only explicit creation-size source, and missing size falls back directly to `800x600` (removed MoonBit-only `inner_size` fallback).
- Completed: aligned termination handler ownership with upstream `event_handler.terminate()` intent by clearing the registered dispatch handler during `WillTerminate`, and termination no longer force-sets `exit_requested` (it now only follows terminate + `internal_exit` flow).

## Remaining Structural Work

- Not completed: Full example behavior parity for all upstream demo semantics.
