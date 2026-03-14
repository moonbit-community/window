///|
// Port target:
// - winit-reference/winit/tests/send_objects.rs
// - winit-reference/winit/tests/sync_object.rs
// MoonBit adaptation: there is no Rust Send/Sync trait system, so these tests
// assert the same public object surface can be type-checked and passed through
// normal value paths.

///|
fn consume_event_loop_proxy(_proxy : EventLoopProxy) -> Unit {
  ()
}

///|
fn consume_window(_window : Window) -> Unit {
  ()
}

///|
fn consume_window_attributes(_attributes : @core.WindowAttributes) -> Unit {
  ()
}

///|
fn consume_window_id(_id : @core.WindowId) -> Unit {
  ()
}

///|
fn consume_device_id(_id : @core.DeviceId) -> Unit {
  ()
}

///|
fn consume_monitor_handle(_handle : @core.MonitorHandle) -> Unit {
  ()
}

///|
fn consume_custom_cursor_source(_source : @core.CustomCursorSource) -> Unit {
  ()
}

///|
fn consume_custom_cursor(_cursor : @core.CustomCursor) -> Unit {
  ()
}

///|
test "event_loop_proxy_send" {
  let _ : (EventLoopProxy) -> Unit = consume_event_loop_proxy
}

///|
test "window_send" {
  let _ : (Window) -> Unit = consume_window
}

///|
test "window_builder_send" {
  consume_window_attributes(@core.WindowAttributes::default())
}

///|
test "ids_send" {
  consume_window_id(@core.WindowId::from_raw(1))
  consume_device_id(@core.DeviceId::from_raw((1 : Int).to_int64()))
  let _ : (@core.MonitorHandle) -> Unit = consume_monitor_handle
}

///|
test "custom_cursor_send" {
  let source = @core.CustomCursorSource::Rgba(
    Bytes::make(4, (0 : Int).to_byte()),
    1,
    1,
    0,
    0,
  )
  consume_custom_cursor_source(source)
  consume_custom_cursor(@core.CustomCursor::from_raw((1 : Int).to_uint64()))
}

///|
test "event_loop_proxy_sync" {
  let _ : (EventLoopProxy) -> Unit = consume_event_loop_proxy
}

///|
test "window_sync" {
  let _ : (Window) -> Unit = consume_window
}

///|
test "window_builder_sync" {
  consume_window_attributes(@core.WindowAttributes::default())
}

///|
test "custom_cursor_sync" {
  let source = @core.CustomCursorSource::Rgba(
    Bytes::make(4, (0 : Int).to_byte()),
    1,
    1,
    0,
    0,
  )
  consume_custom_cursor_source(source)
  consume_custom_cursor(@core.CustomCursor::from_raw((1 : Int).to_uint64()))
}
