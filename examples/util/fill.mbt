///|
// Port target: winit-reference/winit/examples/util/fill.rs::fill_window
pub fn fill_window(window : @macos.Window) -> Unit {
  // MoonBit adaptation:
  // upstream examples use a renderer helper; this package currently only emits
  // pre-present notifications to keep examples backend-agnostic.
  window.pre_present_notify()
}

///|
// Port target: winit-reference/winit/examples/util/fill.rs::fill_window_with_color
pub fn fill_window_with_color(window : @macos.Window, _color : Int) -> Unit {
  fill_window(window)
}

///|
// Port target: winit-reference/winit/examples/util/fill.rs::fill_window_with_animated_color
pub fn fill_window_with_animated_color(
  window : @macos.Window,
  _start_time_ms : Int64,
) -> Unit {
  fill_window(window)
}

///|
// Port target: winit-reference/winit/examples/util/fill.rs::cleanup_window
pub fn cleanup_window(_window : @macos.Window) -> Unit {
  ()
}
