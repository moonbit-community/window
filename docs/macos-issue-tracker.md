# macOS Issue Tracker

Last updated: 2026-03-31

This tracker records macOS-only gaps and fix progress in this repository.

## Status Legend

- `TODO`: not started
- `IN_PROGRESS`: currently being fixed
- `BLOCKED`: blocked by platform/public API limitations or external dependency constraints
- `DONE`: fixed and verified locally

## Issues

| ID | Source | Problem | Status | Notes |
| --- | --- | --- | --- | --- |
| MBW-MAC-001 | Local audit / event semantics | Drag-and-drop positions are emitted as `PhysicalPositionF64`, but the current path uses AppKit point-space values and does not apply scale factor. | DONE | Fixed in `macos/window_delegate.mbt` by scaling DnD points with per-window scale factor; covered by new wbtests |
| MBW-MAC-002 | Local audit / IME client | `NSTextInputClient` methods `attributedSubstringForProposedRange` and `characterIndexForPoint` still return placeholder values (`nil`/`0`). | DONE | Fixed in `macos/native_appkit.m` via marked-text snapshot + range clamping + selected-range based index query |
| MBW-MAC-003 | GitHub issue #8 | `pump_app_events` caveat/perf behavior differs from `run_app`, potentially causing high idle wake frequency and frame pacing constraints. | DONE | Behavior is now explicitly documented as caveat-heavy, with `run_app()` guidance for frame-driven apps |
| MBW-MAC-004 | GitHub issue #6 | `surface_size` point-vs-physical mismatch concerns. | DONE | Current code converts logical AppKit sizes to physical sizes before emitting `SurfaceResized` |
| MBW-MAC-013 | Upstream parity audit | Window/surface position APIs mixed AppKit bottom-left coordinates with expected top-left screen coordinates (`outer_position`, `set_outer_position`, `surface_position`, moved-event source coordinates). | DONE | Added explicit coordinate flipping against main display bounds and corrected surface-relative offset calculation in `window_delegate.mbt` |
| MBW-MAC-014 | Upstream parity audit | Cursor visibility used a global hide/unhide state, diverging from per-window visibility semantics and risking cross-window/global cursor state leakage. | DONE | Switched to per-window `cursor_visible` state and invisible-cursor application path; removed global hide/unhide behavior and added wbtests |
| MBW-MAC-015 | Upstream parity audit | `set_cursor_position` converted to physical coordinates before native dispatch, but native path expects logical (point-space) coordinates; this causes HiDPI cursor placement offsets. | DONE | Switched to logical conversion (`position.to_logical(scale_factor)`) and added wbtest coverage in `window_wbtest.mbt` |
| MBW-MAC-016 | Upstream parity audit | Window position setters (`set_outer_position`, initial `WindowAttributes::position`) converted to physical coordinates before AppKit calls, causing HiDPI positioning offsets. | DONE | Switched both paths to logical conversion (`position.to_logical(scale_factor)`) and added conversion wbtests in `window_delegate_wbtest.mbt` |
| MBW-MAC-017 | Upstream parity audit | `set_cursor_position` Y-axis warp conversion used AppKit bottom-left arithmetic (`content_y + content_height - y`) instead of winit-style top-left screen coordinates, producing mirrored Y placement. | DONE | Replaced with `flip_window_screen_coordinate_y(content_y, content_height) + y` conversion and added wbtests for monotonic cursor-offset behavior |
| MBW-MAC-018 | Upstream parity audit | Fullscreen/restore window positioning paths were passing physical monitor/window positions directly into AppKit logical setters (`setFrameOrigin`), causing HiDPI offset on enter/exit fullscreen. | DONE | Added physical→logical normalization helpers for monitor and saved outer positions, and updated fullscreen/simplified-fullscreen/exclusive restore call paths |
| MBW-MAC-019 | Upstream parity audit | Internal `set_window_position` helper still re-converted input coordinates from physical to logical, causing double scaling after callers were normalized to logical positions. | DONE | Simplified `set_window_position` to pass logical coordinates through directly and normalized the remaining fullscreen-creation monitor-position call site |
| MBW-MAC-020 | Upstream parity audit (`window_delegate.rs`) | Active window creation/focus path diverges from winit ordering, causing Space switch anomalies (`show_window` was activating app from create path; `focus_window` order differed). | DONE | Aligned `show_window`/`focus_window` to upstream order in `macos/window_delegate.mbt` (`show`: key/front only when active; `focus`: `activateIgnoringOtherApps(true)` then `makeKeyAndOrderFront`) |
| MBW-MAC-021 | Upstream commit `4d81f4aa` | Native view tracking still used legacy `addTrackingRect/removeTrackingRect`; missing `NSTrackingArea` (`ActiveAlways + InVisibleRect`) semantics from latest winit main. | DONE | Migrated to `NSTrackingArea` in `macos/native_appkit.m` with `MouseEnteredAndExited | MouseMoved | ActiveAlways | InVisibleRect`; removed legacy tracking-rect refresh path |
| MBW-MAC-022 | Upstream commit `a8c7d809` | Cursor mapping behind latest winit: missing macOS 15 frame-resize/row/column cursor paths and fallback branching for many cursor icons. | DONE | Completed cursor mapping in `macos/window_delegate.mbt` (macOS 15 frame-resize API + fallbacks, row/column/zoom paths, webkit move/cell), plus FFI bridge `appkit_objc_msg_send_u64_u64_u64` |
| MBW-MAC-023 | Upstream commit `0b6b794f` | IME toggling semantics need revalidation against latest upstream enable/disable handling. | DONE | Aligned `request_ime_update` flow in `macos/window.mbt`: `Enable/Update` gate on `ime_capabilities_state`, `Disable` clears state + native disable path; `set_ime_allowed` default request shape synced to upstream core helper |
| MBW-MAC-024 | Example parity requirement | Missing executable transcript diff workflow for upstream-vs-MoonBit example output comparison. | DONE | Added `scripts/check_example_transcripts.sh` (ANSI/prefix normalization + strict diff) and aligned `examples/pump_events/main.mbt`; current run result: `example transcript check passed` |
| MBW-MAC-025 | Upstream pin sync | `docs/upstream.md` and local parity baseline were pinned to old `winit` commit `5e2f421...`. | DONE | Updated upstream pin to `b5252f136632aac27937ad00fbd6764f812d4922`; local `winit-reference` checked out to this commit for audit |
| MBW-MAC-005 | GitHub issue #4 | `with_inner_size` not applied on window creation. | DONE | `with_inner_size` maps to `with_surface_size`, and creation path reads `attributes.surface_size()` |
| MBW-MAC-006 | GitHub issue #2 | `flagsChanged` path crash due invalid character extraction. | DONE | Current path handles modifier events without unsafe text extraction in `flagsChanged` |
| MBW-MAC-011 | GitHub issue #1 | `rwh_06_window_handle` should expose `NSView*` semantics instead of `NSWindow*`. | DONE | `Window::rwh_06_window_handle()` returns `raw_view_handle` first and only falls back to window handle |
| MBW-MAC-012 | GitHub issue #5 | Intermittent invalid memory access around callback bridge object lifetimes. | DONE | Added defensive retain/release around `NSEvent` and `NSDraggingInfo` callback handoff in `native_appkit.m` |
| MBW-MAC-007 | API parity gap | `CursorGrabMode::Confined` is not implemented on macOS. | DONE | Matches upstream winit (`window_delegate.rs`: `CursorGrabMode::Confined => Err(NotSupportedError)`) |
| MBW-MAC-008 | API parity gap | `drag_resize_window` and `show_window_menu` are stubs that do not perform native behavior. | DONE | Matches upstream winit (`drag_resize_window` returns `NotSupported`; `show_window_menu` is no-op) |
| MBW-MAC-009 | API parity gap | Custom cursor `Url`/`Animation` sources are unsupported on macOS backend. | DONE | Matches upstream winit cursor provider (`CustomCursorSource::Animation/Url => NotSupported`) |
| MBW-MAC-010 | API parity gap | `set_prefers_home_indicator_hidden` / `set_prefers_status_bar_hidden` / `set_preferred_screen_edges_deferring_system_gestures` are state-only no-op on macOS. | DONE | Contract documented as parity-state setters with no native AppKit effect |

## Current Work Queue

_empty_
