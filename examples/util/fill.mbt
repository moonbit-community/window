///|
extern "C" fn native_fill_window_with_color(
  raw_view_handle : UInt64,
  color : UInt64,
) -> Unit = "mbw_examples_fill_window_with_color"

///|
extern "C" fn native_now_millis() -> Int64 = "mbw_examples_now_millis"

///|
pub fn now_millis() -> Int64 {
  native_now_millis()
}

///|
fn fill_window_with_argb(window : @macos.Window, color : UInt64) -> Unit {
  native_fill_window_with_color(window.window_handle(), color)
}

///|
pub fn fill_window(window : @macos.Window) -> Unit {
  fill_window_with_argb(window, 0xFF181818L.reinterpret_as_uint64())
}

///|
// Port target: winit-reference/winit/examples/util/fill.rs::fill_window_with_color
pub fn fill_window_with_color(window : @macos.Window, color : Int) -> Unit {
  fill_window_with_argb(window, color.to_int64().reinterpret_as_uint64())
}

///|
// Port target: winit-reference/winit/examples/util/fill.rs::fill_window_with_animated_color
pub fn fill_window_with_animated_color(
  window : @macos.Window,
  start_time_ms : Int64,
) -> Unit {
  let elapsed_seconds = (now_millis() - start_time_ms).to_double() / 1000.0
  let time = elapsed_seconds * 1.5
  let blue = (@math.sin(time) * 255.0).to_int()
  let green = (@math.cos(time) * 255.0).to_int() << 8
  let red = ((1.0 - @math.sin(time)) * 255.0).to_int() << 16
  let alpha = 0xFF << 24
  fill_window_with_color(window, alpha | red | green | blue)
}

///|
// Port target: winit-reference/winit/examples/util/fill.rs::cleanup_window
pub fn cleanup_window(window : @macos.Window) -> Unit {
  native_fill_window_with_color(
    window.window_handle(),
    0L.reinterpret_as_uint64(),
  )
}
