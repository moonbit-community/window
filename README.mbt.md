# Milky2018/window

`Milky2018/window` is a MoonBit port of `winit`. The current release targets
native builds and focuses on `macos-arm64`.

## Status

- Supported backend: macOS AppKit on the native target
- Current event surface: `CloseRequested`, `Destroyed`, `Focused`,
  `Ime`, `KeyboardInput`, `ModifiersChanged`, `Moved`,
  `DragEntered`, `DragMoved`, `DragDropped`, `DragLeft`,
  `PointerMoved`, `PointerEntered`, `PointerLeft`, `PointerButton`,
  `MouseWheel`, `PinchGesture`, `PanGesture`, `DoubleTapGesture`,
  `RotationGesture`, `TouchpadPressure`,
  `SurfaceResized`, `ScaleFactorChanged`, `ThemeChanged`,
  `Occluded`, `RedrawRequested`
- `winit`-style compatibility projections are available through
  `WindowEvent::into_winit_events()` and `DeviceEvent::into_winit_event()`
- Event loop support: `run_app`, `run_app_on_demand`, `pump_app_events`,
  `try_run_app`, `try_run_app_on_demand`, `try_pump_app_events`,
  `EventLoopProxy::wake_up()`,
  `ControlFlow::{Poll, Wait, WaitUntil}`, `EventLoop::system_theme`,
  `EventLoop::listen_device_events` (accepted as a no-op on macOS),
  `EventLoop::window_target`,
  `EventLoop::builder`, and
  `EventLoopBuilder::{with_activation_policy, with_default_menu,
  with_activate_ignoring_other_apps, build, try_build}`,
  `EventLoop::{new, try_new, new_with_platform_attributes,
  try_new_with_platform_attributes}`, and
  callback dispatch for `new_events`, `can_create_surfaces`, `about_to_wait`,
  `window_event`, `device_event`, `proxy_wake_up`, and
  `standard_key_binding` (when `macos_handler()` is enabled); on macOS,
  `resumed` / `destroy_surfaces` / `suspended` are currently not emitted, with
  `PumpStatus::{Continue, Exit(code)}`
- Runtime window control currently includes surface and frame sizing
  (`surface_size`, `outer_size`, `surface_position`, `safe_area`,
  `request_surface_size`,
  `set_min_surface_size`, `min_surface_size`, `set_max_surface_size`,
  `max_surface_size`,
  `set_surface_resize_increments`), position and focus (`outer_position`,
  `set_outer_position`, `focus_window`, `has_focus`),
  state (`set_minimized`, `is_minimized`, `set_maximized`, `is_maximized`,
  `set_fullscreen`, `fullscreen`, `is_fullscreen`), appearance (`set_title`,
  `title`, `set_theme`, `set_window_icon`, `set_cursor`,
  `set_cursor_position`, `set_cursor_grab`, `set_cursor_visible`,
  `is_cursor_visible`, `set_cursor_hittest`, `is_cursor_hittest`, `set_blur`,
  `set_transparent`, `set_decorations`, `set_window_level`,
  `set_unified_titlebar`, `unified_titlebar`, `request_user_attention`), raw
  handle bridge (`rwh_06_window_handle`,
  `rwh_06_display_handle`), visibility and
  capability flags (`set_visible`, `set_resizable`, `set_enabled_buttons`,
  `set_content_protected`), and IME control (`set_ime_purpose`,
  `set_ime_hints`, `set_ime_allowed`, `set_ime_cursor_area`,
  `set_ime_surrounding_text`, `ime_hints`, `ime_surrounding_text`,
  `request_ime_update`, `ime_capabilities`), plus raise-based
  `try_create_window`. Additional compatibility shims
  include `pre_present_notify`, `reset_dead_keys`, `drag_window`,
  `drag_resize_window` (NotSupported on macOS), and `show_window_menu`.
- Monitor APIs are available on macOS via `EventLoop::{available_monitors,
  primary_monitor}` and `Window::{available_monitors, primary_monitor,
  current_monitor}`; monitor handles include native id, name, position,
  surface size, scale factor, current video mode, and video mode list.
- `WindowAttributes` supports initial surface sizing/constraints and position,
  title/visibility/resizable, focus/active, fullscreen, theme, cursor
  icon/visibility/hittest, blur/transparency/decorations/content protection,
  enabled buttons, window level, IME purpose, optional `parent_window`
  (native handle), and
  macOS platform attributes (such as `simple_fullscreen` and
  `unified_titlebar`, `panel`).
- `Fullscreen` supports both `Borderless(MonitorHandle?)` and
  `Exclusive(MonitorHandle, VideoMode)` payloads in the core API.
- Current keyboard support is macOS-first and now prefers native
  `NSEvent` text (`characters` / `charactersIgnoringModifiers`) for
  `logical_key` and `text`; `key_without_modifiers` uses Carbon
  `UCKeyTranslate`. Dead keys are surfaced as `Key::Dead` when applicable.
- macOS scancode bridge helpers are available as
  `physicalkey_to_scancode` / `scancode_to_physicalkey`.
- IME events are bridged from AppKit text input (`Enabled`, `Preedit`,
  `Commit`, `DeleteSurrounding`, `Disabled`), and IME update requests cover
  purpose, allowed state, hint/purpose pairs, cursor area, and surrounding
  text; `ImePurpose` includes `Normal`, `Password`, `Terminal`, `Number`,
  `Phone`, `Url`, `Email`, `Pin`, `Date`, `Time`, and `DateTime`.
- API errors use MoonBit `raise` with typed errors (for example
  `@core.BadIcon`, `@core.ImeSurroundingTextError`,
  `@core.ImeRequestError`, `@core.RequestError`) rather than `Result`; this
  includes APIs like `outer_position`, `set_cursor_hittest`,
  `set_cursor_position`, and `set_cursor_grab`.
- `EventLoop::create_custom_cursor` supports both RGBA and URL cursor sources
  on macOS; URL inputs accept regular URL strings and local file paths.
  Animation cursor sources are part of the API and currently raise
  `RequestError::NotSupported` on macOS.
  `Window::set_cursor` accepts `@core.Cursor::{Icon, Custom}`.
- `Cmd + keyUp` is forwarded to the key window in the event pump so key
  release events are not dropped while Command is held.
- Other platforms are planned but not implemented yet

## Packages

- `@Milky2018/window/core` provides `ControlFlow`, `StartCause`,
  `WindowAttributes`, `WindowEvent`, `WindowId`, and `MonitorHandle`
- `@Milky2018/window/macos` provides `EventLoop`, `Window`,
  `EventLoopProxy`, and `ApplicationHandler`
- `@Milky2018/window/dpi` provides size and scale-factor types
- `@Milky2018/window` exposes small convenience helpers

## Install

```bash
moon add Milky2018/window
```

## Examples

The upstream `winit/examples` set is ported under `examples/*`:

- `examples/application`
- `examples/child_window`
- `examples/control_flow`
- `examples/dnd`
- `examples/ime`
- `examples/pump_events`
- `examples/run_on_demand`
- `examples/window`
- `examples/x11_embed` (kept as an X11-only compatibility note on macOS)

Run an example with:

```bash
moon run examples/window --target native
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

You can still match the richer native event surface directly when you need
macOS-specific pointer, drag, or gesture details:

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

## Notes

- `ControlFlow::WaitUntil` takes an absolute monotonic timestamp (milliseconds)
- `pump_app_events(timeout_ms, app)` uses millisecond timeout:
  `Some(0)` is non-blocking; `None` follows current `ControlFlow`
- Native link flags for AppKit/CoreGraphics are injected by module prebuild
  metadata, so downstream apps do not need to repeat macOS framework flags in
  their own `moon.pkg`
- Use `EventLoop::builder()` when you need macOS startup attributes
  (`activation_policy`, default menu creation, activate-ignoring-other-apps)
- `ApplicationHandler` methods receive `ActiveEventLoop`, matching winit's
  active-loop callback shape
- Upstream AppKit type names are available as aliases:
  `WindowAttributesMacOS` and `PlatformSpecificEventLoopAttributes`
- `WindowEvent::into_winit_events()` can expand one richer event into multiple
  compatibility events, for example when a single drag enter contains multiple
  file paths
