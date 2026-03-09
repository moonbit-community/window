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
fn wait_for_events(timeout_ms : Int) -> Bool {
  native_event_loop_wait_millis(timeout_ms)
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
pub extern "C" fn native_window_should_close(window_id : Int) -> Bool = "mbw_window_should_close"

///|
pub extern "C" fn native_window_take_close_requested(window_id : Int) -> Bool = "mbw_window_take_close_requested"

///|
pub extern "C" fn native_window_take_surface_resized(window_id : Int) -> Bool = "mbw_window_take_surface_resized"

///|
pub extern "C" fn native_window_take_redraw_requested(window_id : Int) -> Bool = "mbw_window_take_redraw_requested"

///|
pub extern "C" fn native_window_request_redraw(window_id : Int) -> Unit = "mbw_window_request_redraw"

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
