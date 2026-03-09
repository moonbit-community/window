///|
pub fn backend_available() -> Bool {
  native_backend_available()
}

///|
fn reset_proxy_wake_state() -> Unit {
  native_event_loop_reset_proxy()
}

///|
fn runtime_now_ms() -> Int64 {
  native_runtime_now_ms()
}

///|
fn window_theme(window_id : Int) -> Int {
  native_window_theme(window_id)
}

///|
fn window_scale_factor(window_id : Int) -> Double {
  native_window_scale_factor(window_id)
}

///|
fn take_moved(window_id : Int) -> Bool {
  native_window_take_moved(window_id)
}

///|
fn pending_move_x(window_id : Int) -> Int {
  native_window_pending_move_x(window_id)
}

///|
fn pending_move_y(window_id : Int) -> Int {
  native_window_pending_move_y(window_id)
}

///|
fn take_destroyed(window_id : Int) -> Bool {
  native_window_take_destroyed(window_id)
}

///|
fn take_focused_changed(window_id : Int) -> Bool {
  native_window_take_focused_changed(window_id)
}

///|
fn pending_focused(window_id : Int) -> Bool {
  native_window_pending_focused(window_id)
}

///|
fn take_scale_factor_changed(window_id : Int) -> Bool {
  native_window_take_scale_factor_changed(window_id)
}

///|
fn pending_scale_factor(window_id : Int) -> Double {
  native_window_pending_scale_factor(window_id)
}

///|
fn pending_scale_width(window_id : Int) -> Int {
  native_window_pending_scale_width(window_id)
}

///|
fn pending_scale_height(window_id : Int) -> Int {
  native_window_pending_scale_height(window_id)
}

///|
fn take_theme_changed(window_id : Int) -> Bool {
  native_window_take_theme_changed(window_id)
}

///|
fn pending_theme(window_id : Int) -> Int {
  native_window_pending_theme(window_id)
}

///|
fn take_occluded_changed(window_id : Int) -> Bool {
  native_window_take_occluded_changed(window_id)
}

///|
fn pending_occluded(window_id : Int) -> Bool {
  native_window_pending_occluded(window_id)
}

///|
fn take_input_event(window_id : Int) -> Bool {
  native_window_take_input_event(window_id)
}

///|
fn input_event_kind(window_id : Int) -> Int {
  native_window_input_event_kind(window_id)
}

///|
fn input_event_x(window_id : Int) -> Double {
  native_window_input_event_x(window_id)
}

///|
fn input_event_y(window_id : Int) -> Double {
  native_window_input_event_y(window_id)
}

///|
fn input_event_state(window_id : Int) -> Int {
  native_window_input_event_state(window_id)
}

///|
fn input_event_button(window_id : Int) -> Int {
  native_window_input_event_button(window_id)
}

///|
fn input_event_pointer_source(window_id : Int) -> Int {
  native_window_input_event_pointer_source(window_id)
}

///|
fn input_event_pointer_kind(window_id : Int) -> Int {
  native_window_input_event_pointer_kind(window_id)
}

///|
fn input_event_scroll_delta_kind(window_id : Int) -> Int {
  native_window_input_event_scroll_delta_kind(window_id)
}

///|
fn input_event_scroll_delta_x(window_id : Int) -> Double {
  native_window_input_event_scroll_delta_x(window_id)
}

///|
fn input_event_scroll_delta_y(window_id : Int) -> Double {
  native_window_input_event_scroll_delta_y(window_id)
}

///|
fn input_event_phase(window_id : Int) -> Int {
  native_window_input_event_phase(window_id)
}

///|
fn input_event_modifiers(window_id : Int) -> Int {
  native_window_input_event_modifiers(window_id)
}

///|
fn wait_for_events(timeout_ms : Int) -> Bool {
  native_event_loop_wait_millis(timeout_ms)
}

///|
fn set_surface_size(window_id : Int, width : Int, height : Int) -> Unit {
  native_window_set_surface_size(window_id, width, height)
}

///|
fn close_window(window_id : Int) -> Unit {
  native_window_close(window_id)
}

///|
fn create_window(
  width : Int,
  height : Int,
  visible : Bool,
  resizable : Bool,
  title : String,
) -> Int {
  let title_bytes = @utf8.encode(title[:], bom=false)
  native_create_window(
    width,
    height,
    visible,
    resizable,
    title_bytes,
    title_bytes.length().to_uint64(),
  )
}

///|
fn set_title(window_id : Int, title : String) -> Unit {
  let title_bytes = @utf8.encode(title[:], bom=false)
  native_set_title(window_id, title_bytes, title_bytes.length().to_uint64())
}

///|
pub extern "C" fn native_backend_available() -> Bool = "mbw_backend_available"

///|
pub extern "C" fn native_event_loop_reset_proxy() -> Unit = "mbw_event_loop_reset_proxy"

///|
pub extern "C" fn native_event_loop_take_proxy_wake_up() -> Bool = "mbw_event_loop_take_proxy_wake_up"

///|
pub extern "C" fn native_event_loop_peek_proxy_wake_up() -> Bool = "mbw_event_loop_peek_proxy_wake_up"

///|
pub extern "C" fn native_event_loop_wake_up() -> Unit = "mbw_event_loop_wake_up"

///|
pub extern "C" fn native_runtime_now_ms() -> Int64 = "mbw_runtime_now_ms"

///|
extern "C" fn native_event_loop_wait_millis(timeout_ms : Int) -> Bool = "mbw_event_loop_wait_millis"

///|
pub extern "C" fn native_sleep_millis(ms : Int) -> Unit = "mbw_sleep_millis"

///|
#borrow(title)
pub extern "C" fn native_create_window(
  width : Int,
  height : Int,
  visible : Bool,
  resizable : Bool,
  title : Bytes,
  title_len : UInt64,
) -> Int = "mbw_window_create_utf8"

///|
pub extern "C" fn native_poll_window(window_id : Int) -> Unit = "mbw_window_poll"

///|
pub extern "C" fn native_window_width(window_id : Int) -> Int = "mbw_window_width"

///|
pub extern "C" fn native_window_height(window_id : Int) -> Int = "mbw_window_height"

///|
extern "C" fn native_window_theme(window_id : Int) -> Int = "mbw_window_theme"

///|
extern "C" fn native_window_scale_factor(window_id : Int) -> Double = "mbw_window_scale_factor"

///|
pub extern "C" fn native_window_should_close(window_id : Int) -> Bool = "mbw_window_should_close"

///|
pub extern "C" fn native_window_take_close_requested(window_id : Int) -> Bool = "mbw_window_take_close_requested"

///|
extern "C" fn native_window_take_moved(window_id : Int) -> Bool = "mbw_window_take_moved"

///|
extern "C" fn native_window_pending_move_x(window_id : Int) -> Int = "mbw_window_pending_move_x"

///|
extern "C" fn native_window_pending_move_y(window_id : Int) -> Int = "mbw_window_pending_move_y"

///|
extern "C" fn native_window_take_destroyed(window_id : Int) -> Bool = "mbw_window_take_destroyed"

///|
extern "C" fn native_window_take_focused_changed(window_id : Int) -> Bool = "mbw_window_take_focused_changed"

///|
extern "C" fn native_window_pending_focused(window_id : Int) -> Bool = "mbw_window_pending_focused"

///|
extern "C" fn native_window_take_scale_factor_changed(window_id : Int) -> Bool = "mbw_window_take_scale_factor_changed"

///|
extern "C" fn native_window_pending_scale_factor(window_id : Int) -> Double = "mbw_window_pending_scale_factor"

///|
extern "C" fn native_window_pending_scale_width(window_id : Int) -> Int = "mbw_window_pending_scale_width"

///|
extern "C" fn native_window_pending_scale_height(window_id : Int) -> Int = "mbw_window_pending_scale_height"

///|
extern "C" fn native_window_take_theme_changed(window_id : Int) -> Bool = "mbw_window_take_theme_changed"

///|
extern "C" fn native_window_pending_theme(window_id : Int) -> Int = "mbw_window_pending_theme"

///|
extern "C" fn native_window_take_occluded_changed(window_id : Int) -> Bool = "mbw_window_take_occluded_changed"

///|
extern "C" fn native_window_pending_occluded(window_id : Int) -> Bool = "mbw_window_pending_occluded"

///|
extern "C" fn native_window_take_input_event(window_id : Int) -> Bool = "mbw_window_take_input_event"

///|
extern "C" fn native_window_input_event_kind(window_id : Int) -> Int = "mbw_window_input_event_kind"

///|
extern "C" fn native_window_input_event_x(window_id : Int) -> Double = "mbw_window_input_event_x"

///|
extern "C" fn native_window_input_event_y(window_id : Int) -> Double = "mbw_window_input_event_y"

///|
extern "C" fn native_window_input_event_state(window_id : Int) -> Int = "mbw_window_input_event_state"

///|
extern "C" fn native_window_input_event_button(window_id : Int) -> Int = "mbw_window_input_event_button"

///|
extern "C" fn native_window_input_event_pointer_source(window_id : Int) -> Int = "mbw_window_input_event_pointer_source"

///|
extern "C" fn native_window_input_event_pointer_kind(window_id : Int) -> Int = "mbw_window_input_event_pointer_kind"

///|
extern "C" fn native_window_input_event_scroll_delta_kind(
  window_id : Int,
) -> Int = "mbw_window_input_event_scroll_delta_kind"

///|
extern "C" fn native_window_input_event_scroll_delta_x(
  window_id : Int,
) -> Double = "mbw_window_input_event_scroll_delta_x"

///|
extern "C" fn native_window_input_event_scroll_delta_y(
  window_id : Int,
) -> Double = "mbw_window_input_event_scroll_delta_y"

///|
extern "C" fn native_window_input_event_phase(window_id : Int) -> Int = "mbw_window_input_event_phase"

///|
extern "C" fn native_window_input_event_modifiers(window_id : Int) -> Int = "mbw_window_input_event_modifiers"

///|
pub extern "C" fn native_window_take_surface_resized(window_id : Int) -> Bool = "mbw_window_take_surface_resized"

///|
pub extern "C" fn native_window_take_redraw_requested(window_id : Int) -> Bool = "mbw_window_take_redraw_requested"

///|
pub extern "C" fn native_window_request_redraw(window_id : Int) -> Unit = "mbw_window_request_redraw"

///|
extern "C" fn native_window_set_surface_size(
  window_id : Int,
  width : Int,
  height : Int,
) -> Unit = "mbw_window_set_surface_size"

///|
extern "C" fn native_window_close(window_id : Int) -> Unit = "mbw_window_close"

///|
#borrow(title)
pub extern "C" fn native_set_title(
  window_id : Int,
  title : Bytes,
  title_len : UInt64,
) -> Unit = "mbw_window_set_title_utf8"

///|
pub extern "C" fn native_set_visible(window_id : Int, visible : Bool) -> Unit = "mbw_window_set_visible"

///|
pub extern "C" fn native_set_resizable(
  window_id : Int,
  resizable : Bool,
) -> Unit = "mbw_window_set_resizable"
