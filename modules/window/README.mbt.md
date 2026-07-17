# Milky2018/window

This repository is a MoonBit workspace containing:

- `modules/window`: the `Milky2018/window` library modeled after `winit`
- `modules/windowing`: the backend-neutral `Milky2018/windowing` handle module

The window backend currently targets **native macOS (AppKit)**.

## Platform Support

- Supported: `native` target on macOS
- Placeholder handle types: Windows, Wayland, Xlib, and Xcb
- Not supported yet: Linux, Windows, and Web window backends

## Install

```bash
moon add Milky2018/window
```

You do **not** need to manually add AppKit/CoreGraphics link flags in your app;
the subpackages provide native link configuration.

Import the subpackages you need directly. This module does **not** expose a
root `@Milky2018/window` package.

## Quick Start

Use explicit subpackage imports in your package's `moon.pkg`:

```moonbit
import {
  "Milky2018/window/core",
  "Milky2018/window/macos",
}

supported_targets = "native"

options("is-main": true)
```

Then write the app in `main.mbt`:

```moonbit
///|
struct App {
  mut window : @macos.Window?
}

///|
pub impl @macos.ApplicationHandler for App with can_create_surfaces(
  self,
  event_loop,
) {
  let attrs = @core.WindowAttributes::default().with_title("window demo")
  let window : @macos.Window? = Some(event_loop.try_create_window(attrs)) catch {
    err => {
      println("error creating window: \{err}")
      event_loop.exit()
      None
    }
  }
  self.window = window
}

///|
pub impl @macos.ApplicationHandler for App with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    CloseRequested => event_loop.exit()
    SurfaceResized(_) =>
      match self.window {
        Some(window) => window.request_redraw()
        None => ()
      }
    RedrawRequested => println("redraw requested")
    _ => ()
  }
}

///|
fn main {
  let event_loop = @macos.EventLoop::EventLoop()
  event_loop.run_app({ window: None })
}
```

## Error Model

This library follows MoonBit `raise`-based error handling (typed errors), not
`Result`. For example:

- `EventLoop::try_new()` may raise `@core.EventLoopError`
- `Window::set_cursor_position(...)` may raise `@core.RequestError`
- `Window::request_ime_update(...)` may raise `@core.ImeRequestError`

## macOS Caveats

- `EventLoop` must be created and run on the process main thread.
  `EventLoopBuilder::with_any_thread(true)` does not relax this AppKit
  requirement.
- Methods on an existing `Window` may be called from worker threads.
  AppKit-backed operations synchronously execute on the process main thread,
  matching winit's macOS behavior. Do not block the main thread while waiting
  for a worker that is calling a `Window` method.
- `monitor_ns_screen(...)` returns a retained `NSScreenHandle` snapshot. Keep
  that handle alive while using `objc_handle()`, and resolve it again after a
  display reconfiguration.
- `EventLoop::pump_app_events(...)` is for host-loop integration, not frame-by-frame rendering.
  For frame-driven apps, prefer `run_app()` with `ControlFlow::Poll` or `ControlFlow::WaitUntil`.
- `Window::set_cursor_grab(@core.CursorGrabMode::Confined)` raises `@core.RequestError::NotSupported`.
- `Window::drag_resize_window(...)` raises `@core.RequestError::NotSupported` on macOS.
- `Window::show_window_menu(...)` currently has no native AppKit implementation.
- `@core.CustomCursorSource::Url(...)` and animation cursors are not supported on macOS.
- `Window::set_prefers_home_indicator_hidden(...)`,
  `Window::set_prefers_status_bar_hidden(...)`,
  and `Window::set_preferred_screen_edges_deferring_system_gestures(...)`
  are parity state setters on macOS (no native AppKit effect).

## macOS Renderer Integration

`@macos.Window` implements the `Milky2018/windowing` `HasWindowHandle` and
`HasDisplayHandle` contracts. `Window::window_handle()` returns a structured
`WindowHandle` whose provider keeps the window owner reachable. Resolve the
platform handle only at the renderer boundary. Renderer packages should import
`"Milky2018/windowing"` in their `moon.pkg`:

```moonbit
let raw = try! window.window_handle().as_raw()
match raw {
  @windowing.RawWindowHandle::AppKit(handle) => {
    let ns_view = handle.ns_view()
    // Create the renderer surface from ns_view.
  }
  _ => abort("renderer does not support this window backend")
}
```

The AppKit variant contains the window content view (`NSView*`). It is borrowed:
do not release it or retain it beyond the lifetime of the `WindowHandle`.
Explicitly dropping the underlying window invalidates subsequent `as_raw()`
calls with `HandleError::Unavailable`.

For platform-specific integrations that cannot consume `windowing`,
`Window::content_view_handle()` remains an AppKit escape hatch and raises
`@core.RequestError` if the handle is unavailable.

The window package owns the AppKit window/content-view lookup. Renderer
packages such as `wgpu_mbt` should own Metal or `wgpu` surface setup on top of
that handle. In particular, downstream code should not scan
`NSApplication.windows` or use the internal `rawId` selector to find a window.

For `CAMetalLayer` integration, create/attach/sync the layer in the renderer
layer using the content-view handle. Keep the layer synchronized with:

- `Window::scale_factor()` for `contentsScale`
- `Window::surface_size()` for physical drawable size
- `WindowEvent::SurfaceResized` and `WindowEvent::ScaleFactorChanged` for
  resize/scale resync
- the content view bounds for the layer frame
- autoresizing or an explicit renderer-side sync step for future view resizes

## API Overview

Import only the subpackages you need:

- `@Milky2018/window/core`: core event/types (`WindowEvent`, `ControlFlow`,
  `WindowAttributes`, keyboard/mouse/IME data types)
- `@Milky2018/window/macos`: macOS runtime API (`EventLoop`, `ActiveEventLoop`,
  `Window`, `EventLoopProxy`, `ApplicationHandler`)
- `@Milky2018/window/dpi`: logical/physical size and position types
- `@Milky2018/windowing`: structured raw handles and provider traits

`WindowEvent::into_winit_events()` is available when you want a
`winit`-style compatibility projection.

## Rich Event Matching

You can also match native event variants directly:

```moonbit
///|
pub impl @macos.ApplicationHandler for App with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    PointerMoved(_, position, _, _) =>
      println("pointer moved: \{position}")
    DragEntered(paths, position) =>
      println("drag entered at \{position}: \{paths}")
    CloseRequested => event_loop.exit()
    _ => ()
  }
}
```

## Repository Examples

The window module includes runnable examples under `modules/window/examples/*`.
From the repository root, run:

```bash
moon run modules/window/examples/window --target native
```

## Validation

Use the repository gate before publishing or committing backend changes:

```bash
scripts/check_ci.sh
```

For the slower upstream-vs-MoonBit example transcript comparison:

```bash
RUN_EXAMPLE_TRANSCRIPTS=1 scripts/check_ci.sh
```

See the repository's `docs/testing.md` for why the local gate uses
`moon test --release` for framework-linked macOS tests.
