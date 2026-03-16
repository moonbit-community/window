# Milky2018/window

`Milky2018/window` is a MoonBit windowing library modeled after `winit`.
It currently targets **native macOS (AppKit)**.

## Platform Support

- Supported: `native` target on macOS
- Not supported yet: Linux, Windows, Web backends

## Install

```bash
moon add Milky2018/window
```

You do **not** need to manually add AppKit/CoreGraphics link flags in your app;
the subpackages provide native link configuration.

## Quick Start

```mbt nocheck
import {
  "Milky2018/window/core",
  "Milky2018/window/macos",
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
  for compat_event in event.into_winit_events() {
    match compat_event {
      @core.WinitWindowEvent::CloseRequested => event_loop.exit()
      @core.WinitWindowEvent::Resized(_) =>
        match self.window {
          Some(window) => window.request_redraw()
          None => ()
        }
      @core.WinitWindowEvent::RedrawRequested => println("redraw requested")
      _ => ()
    }
  }
}

fn main {
  let event_loop = @macos.EventLoop::new()
  event_loop.run_app({ window: None })
}
```

## Error Model

This library follows MoonBit `raise`-based error handling (typed errors), not
`Result`. For example:

- `EventLoop::try_new()` may raise `@core.EventLoopError`
- `Window::set_cursor_position(...)` may raise `@core.RequestError`
- `Window::request_ime_update(...)` may raise `@core.ImeRequestError`

## API Overview

- `@Milky2018/window/core`: core event/types (`WindowEvent`, `ControlFlow`,
  `WindowAttributes`, keyboard/mouse/IME data types)
- `@Milky2018/window/macos`: macOS runtime API (`EventLoop`, `ActiveEventLoop`,
  `Window`, `EventLoopProxy`, `ApplicationHandler`)
- `@Milky2018/window/dpi`: logical/physical size and position types

`WindowEvent::into_winit_events()` is available when you want a
`winit`-style compatibility projection.

## Rich Event Matching

You can also match native event variants directly:

```mbt nocheck
///|
pub impl @macos.ApplicationHandler for App with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::PointerMoved(_, position, _, _) =>
      println("pointer moved: \{position}")
    @core.WindowEvent::DragEntered(paths, position) =>
      println("drag entered at \{position}: \{paths}")
    @core.WindowEvent::CloseRequested => event_loop.exit()
    _ => ()
  }
}
```

## Repository Examples

The repository includes runnable examples under `examples/*`.

```bash
moon run examples/window --target native
```
