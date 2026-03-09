# Milky2018/window

`Milky2018/window` is a MoonBit port of `winit`. The current release targets
native builds and focuses on `macos-arm64`.

## Status

- Supported backend: macOS AppKit on the native target
- Current event surface: `CloseRequested`, `SurfaceResized`, `RedrawRequested`
- Event loop support: `run_app`, `EventLoopProxy::wake_up()`,
  `ControlFlow::{Poll, Wait, WaitUntil}`
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

- `ControlFlow::WaitUntil` currently takes a relative timeout in milliseconds
- `ApplicationHandler` currently receives a concrete `EventLoop`
