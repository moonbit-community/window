# Milky2018/window

`Milky2018/window` is a MoonBit port of `winit`. The current release targets
native builds and focuses on `macos-arm64`.

## Status

- Supported backend: macOS AppKit on the native target
- Current event surface: `CloseRequested`, `Destroyed`, `Focused`,
  `Ime`, `KeyboardInput`, `ModifiersChanged`, `Moved`, `PointerMoved`,
  `PointerEntered`, `PointerLeft`, `PointerButton`, `MouseWheel`,
  `SurfaceResized`, `ScaleFactorChanged`, `ThemeChanged`,
  `Occluded`, `RedrawRequested`
- Event loop support: `run_app`, `EventLoopProxy::wake_up()`,
  `ControlFlow::{Poll, Wait, WaitUntil}`
- Runtime window control currently includes surface and frame sizing
  (`surface_size`, `outer_size`, `surface_position`, `request_surface_size`,
  `set_min_surface_size`, `min_surface_size`, `set_max_surface_size`,
  `max_surface_size`,
  `set_surface_resize_increments`), position and focus (`outer_position`,
  `set_outer_position`, `focus_window`, `has_focus`),
  state (`set_minimized`, `is_minimized`, `set_maximized`, `is_maximized`,
  `set_fullscreen`, `fullscreen`, `is_fullscreen`), appearance (`set_title`,
  `set_theme`, `set_window_icon`, `set_cursor`, `set_cursor_visible`,
  `is_cursor_visible`, `set_cursor_hittest`, `is_cursor_hittest`, `set_blur`,
  `set_transparent`, `set_decorations`, `set_window_level`), visibility and
  capability flags (`set_visible`, `set_resizable`, `set_enabled_buttons`,
  `set_content_protected`), and IME control (`set_ime_purpose`,
  `set_ime_allowed`, `set_ime_cursor_area`).
- `WindowAttributes` supports initial surface sizing/constraints and position,
  title/visibility/resizable, focus/active, fullscreen, theme, cursor/icon,
  blur/transparency/decorations/content protection, enabled buttons, window
  level, IME purpose, and macOS platform attributes (such as
  `simple_fullscreen`).
- Current keyboard support is macOS-first and now prefers native
  `NSEvent` text (`characters` / `charactersIgnoringModifiers`) for
  `logical_key` and `text`; `key_without_modifiers` uses Carbon
  `UCKeyTranslate` and falls back to scancode mapping when needed. Dead keys
  are surfaced as `Key::Dead` when applicable.
- Basic IME events are bridged from AppKit text input (`Enabled`, `Preedit`,
  `Commit`, `Disabled`).
- `Cmd + keyUp` is forwarded to the key window in the event pump so key
  release events are not dropped while Command is held.
- Other platforms are planned but not implemented yet

## Packages

- `@Milky2018/window/core` provides `ControlFlow`, `StartCause`,
  `WindowAttributes`, `WindowEvent`, and `WindowId`
- `@Milky2018/window/macos` provides `EventLoop`, `Window`,
  `EventLoopProxy`, and `ApplicationHandler`
- `@Milky2018/window/dpi` provides size and scale-factor types
- `@Milky2018/window` exposes small convenience helpers

## Install

```bash
moon add Milky2018/window
```

## Example

```mbt nocheck
import {
  "Milky2018/window/core" @core,
  "Milky2018/window/macos" @macos,
}

struct App {
  mut window : @macos.Window?
}

pub impl @macos.ApplicationHandler for App with can_create_surfaces(
  self,
  event_loop,
) {
  let attrs =
    @core.WindowAttributes::default()
    .with_title("window demo")
  let window = event_loop.create_window(attrs)
  self.window = Some(window)
  window.request_redraw()
}

pub impl @macos.ApplicationHandler for App with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::CloseRequested => event_loop.exit()
    @core.WindowEvent::SurfaceResized(_) =>
      match self.window {
        Some(window) => window.request_redraw()
        None => ()
      }
    @core.WindowEvent::RedrawRequested => println("redraw requested")
  }
}

fn main {
  let event_loop = @macos.EventLoop::new()
  event_loop.run_app({ window: None })
}
```

## Notes

- `ControlFlow::WaitUntil` takes an absolute monotonic timestamp (milliseconds)
- `ApplicationHandler` methods receive `ActiveEventLoop` (currently an alias
  of `EventLoop`)
