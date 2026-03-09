///|
pub fn backend_available() -> Bool {
  false
}

///|
fn reset_proxy_wake_state() -> Unit {
  ()
}

///|
fn sleep_millis(_ms : Int) -> Unit {
  ()
}

///|
fn create_window(
  _width : Int,
  _height : Int,
  _visible : Bool,
  _resizable : Bool,
  _title : String,
) -> Int {
  abort("macos backend requires the native target")
}

///|
fn set_title(_window_id : Int, _title : String) -> Unit {
  abort("macos backend requires the native target")
}

///|
fn native_poll_window(_window_id : Int) -> Unit {
  abort("macos backend requires the native target")
}

///|
fn native_event_loop_take_proxy_wake_up() -> Bool {
  false
}

///|
fn native_event_loop_wake_up() -> Unit {
  ()
}

///|
fn native_window_width(_window_id : Int) -> Int {
  0
}

///|
fn native_window_height(_window_id : Int) -> Int {
  0
}

///|
fn native_window_should_close(_window_id : Int) -> Bool {
  true
}

///|
fn native_window_take_close_requested(_window_id : Int) -> Bool {
  false
}

///|
fn native_window_take_surface_resized(_window_id : Int) -> Bool {
  false
}

///|
fn native_window_take_redraw_requested(_window_id : Int) -> Bool {
  false
}

///|
fn native_window_request_redraw(_window_id : Int) -> Unit {
  ()
}

///|
fn native_set_visible(_window_id : Int, _visible : Bool) -> Unit {
  ()
}

///|
fn native_set_resizable(_window_id : Int, _resizable : Bool) -> Unit {
  ()
}
