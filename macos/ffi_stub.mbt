///|
pub fn backend_available() -> Bool {
  false
}

///|
fn reset_proxy_wake_state() -> Unit {
  ()
}

///|
fn runtime_now_ms() -> Int64 {
  0L
}

///|
fn window_theme(_window_id : Int) -> Int {
  0
}

///|
fn window_title(_window_id : Int) -> Bytes {
  Bytes::make(0, (0 : Int).to_byte())
}

///|
fn available_monitor_count() -> Int {
  0
}

///|
fn monitor_id_at(_index : Int) -> UInt64 {
  (0 : Int).to_uint64()
}

///|
fn primary_monitor_id() -> UInt64 {
  (0 : Int).to_uint64()
}

///|
fn window_current_monitor_id(_window_id : Int) -> UInt64 {
  (0 : Int).to_uint64()
}

///|
fn monitor_name(_monitor_id : UInt64) -> Bytes {
  Bytes::make(0, (0 : Int).to_byte())
}

///|
fn monitor_position_x(_monitor_id : UInt64) -> Int {
  0
}

///|
fn monitor_position_y(_monitor_id : UInt64) -> Int {
  0
}

///|
fn monitor_width(_monitor_id : UInt64) -> Int {
  0
}

///|
fn monitor_height(_monitor_id : UInt64) -> Int {
  0
}

///|
fn monitor_scale_factor(_monitor_id : UInt64) -> Double {
  1.0
}

///|
fn monitor_video_mode_count(_monitor_id : UInt64) -> Int {
  0
}

///|
fn monitor_video_mode_width(_monitor_id : UInt64, _index : Int) -> Int {
  0
}

///|
fn monitor_video_mode_height(_monitor_id : UInt64, _index : Int) -> Int {
  0
}

///|
fn monitor_video_mode_bit_depth(_monitor_id : UInt64, _index : Int) -> Int {
  0
}

///|
fn monitor_video_mode_refresh_rate_millihertz(
  _monitor_id : UInt64,
  _index : Int,
) -> Int {
  0
}

///|
fn monitor_current_video_mode_index(_monitor_id : UInt64) -> Int {
  -1
}

///|
fn window_scale_factor(_window_id : Int) -> Double {
  1.0
}

///|
fn take_moved(_window_id : Int) -> Bool {
  false
}

///|
fn pending_move_x(_window_id : Int) -> Int {
  0
}

///|
fn pending_move_y(_window_id : Int) -> Int {
  0
}

///|
fn take_destroyed(_window_id : Int) -> Bool {
  false
}

///|
fn take_focused_changed(_window_id : Int) -> Bool {
  false
}

///|
fn pending_focused(_window_id : Int) -> Bool {
  false
}

///|
fn window_has_focus(_window_id : Int) -> Bool {
  false
}

///|
fn window_visible(_window_id : Int) -> Bool {
  false
}

///|
fn window_resizable(_window_id : Int) -> Bool {
  false
}

///|
fn window_content_protected(_window_id : Int) -> Bool {
  false
}

///|
fn window_occluded(_window_id : Int) -> Bool {
  false
}

///|
fn window_minimized(_window_id : Int) -> Bool {
  false
}

///|
fn window_maximized(_window_id : Int) -> Bool {
  false
}

///|
fn window_fullscreen(_window_id : Int) -> Bool {
  false
}

///|
fn window_decorated(_window_id : Int) -> Bool {
  false
}

///|
fn window_close_button_enabled(_window_id : Int) -> Bool {
  true
}

///|
fn window_minimize_button_enabled(_window_id : Int) -> Bool {
  true
}

///|
fn window_maximize_button_enabled(_window_id : Int) -> Bool {
  true
}

///|
fn window_blur(_window_id : Int) -> Bool {
  false
}

///|
fn window_cursor(_window_id : Int) -> Int {
  0
}

///|
fn window_cursor_visible(_window_id : Int) -> Bool {
  true
}

///|
fn window_cursor_hittest(_window_id : Int) -> Bool {
  true
}

///|
fn window_transparent(_window_id : Int) -> Bool {
  false
}

///|
fn window_level(_window_id : Int) -> Int {
  0
}

///|
fn window_ime_allowed(_window_id : Int) -> Bool {
  false
}

///|
fn window_ime_purpose(_window_id : Int) -> Int {
  0
}

///|
fn window_ime_hints(_window_id : Int) -> Int {
  0
}

///|
fn window_ime_cursor_area_x(_window_id : Int) -> Int {
  0
}

///|
fn window_ime_cursor_area_y(_window_id : Int) -> Int {
  0
}

///|
fn window_ime_cursor_area_width(_window_id : Int) -> Int {
  1
}

///|
fn window_ime_cursor_area_height(_window_id : Int) -> Int {
  1
}

///|
fn window_has_ime_surrounding_text(_window_id : Int) -> Bool {
  false
}

///|
fn window_ime_surrounding_text(_window_id : Int) -> Bytes {
  Bytes::make(0, (0 : Int).to_byte())
}

///|
fn window_ime_surrounding_cursor(_window_id : Int) -> Int {
  0
}

///|
fn window_ime_surrounding_anchor(_window_id : Int) -> Int {
  0
}

///|
fn take_scale_factor_changed(_window_id : Int) -> Bool {
  false
}

///|
fn pending_scale_factor(_window_id : Int) -> Double {
  1.0
}

///|
fn pending_scale_width(_window_id : Int) -> Int {
  0
}

///|
fn pending_scale_height(_window_id : Int) -> Int {
  0
}

///|
fn window_resize_increment_width(_window_id : Int) -> Int {
  0
}

///|
fn window_resize_increment_height(_window_id : Int) -> Int {
  0
}

///|
fn take_theme_changed(_window_id : Int) -> Bool {
  false
}

///|
fn pending_theme(_window_id : Int) -> Int {
  0
}

///|
fn take_occluded_changed(_window_id : Int) -> Bool {
  false
}

///|
fn pending_occluded(_window_id : Int) -> Bool {
  false
}

///|
fn take_input_event(_window_id : Int) -> Bool {
  false
}

///|
fn input_event_kind(_window_id : Int) -> Int {
  0
}

///|
fn input_event_x(_window_id : Int) -> Double {
  0.0
}

///|
fn input_event_y(_window_id : Int) -> Double {
  0.0
}

///|
fn input_event_state(_window_id : Int) -> Int {
  0
}

///|
fn input_event_button(_window_id : Int) -> Int {
  0
}

///|
fn input_event_pointer_source(_window_id : Int) -> Int {
  0
}

///|
fn input_event_pointer_kind(_window_id : Int) -> Int {
  0
}

///|
fn input_event_scroll_delta_kind(_window_id : Int) -> Int {
  0
}

///|
fn input_event_scroll_delta_x(_window_id : Int) -> Double {
  0.0
}

///|
fn input_event_scroll_delta_y(_window_id : Int) -> Double {
  0.0
}

///|
fn input_event_phase(_window_id : Int) -> Int {
  0
}

///|
fn input_event_modifiers(_window_id : Int) -> Int {
  0
}

///|
fn input_event_scancode(_window_id : Int) -> Int {
  0
}

///|
fn input_event_repeat(_window_id : Int) -> Bool {
  false
}

///|
fn input_event_text_with_all_modifiers(_window_id : Int) -> Bytes {
  Bytes::make(0, (0 : Int).to_byte())
}

///|
fn input_event_text_ignoring_modifiers(_window_id : Int) -> Bytes {
  Bytes::make(0, (0 : Int).to_byte())
}

///|
fn input_event_text_without_modifiers(_window_id : Int) -> Bytes {
  Bytes::make(0, (0 : Int).to_byte())
}

///|
fn input_event_ime_kind(_window_id : Int) -> Int {
  0
}

///|
fn input_event_ime_text(_window_id : Int) -> Bytes {
  Bytes::make(0, (0 : Int).to_byte())
}

///|
fn input_event_path(_window_id : Int) -> Bytes {
  Bytes::make(0, (0 : Int).to_byte())
}

///|
fn input_event_ime_cursor_start(_window_id : Int) -> Int {
  -1
}

///|
fn input_event_ime_cursor_end(_window_id : Int) -> Int {
  -1
}

///|
fn wait_for_events(_timeout_ms : Int) -> Bool {
  false
}

///|
fn set_surface_size(_window_id : Int, _width : Int, _height : Int) -> Unit {
  ()
}

///|
fn set_surface_resize_increments(
  _window_id : Int,
  _width : Int,
  _height : Int,
) -> Unit {
  ()
}

///|
fn set_min_surface_size(_window_id : Int, _width : Int, _height : Int) -> Unit {
  ()
}

///|
fn set_max_surface_size(_window_id : Int, _width : Int, _height : Int) -> Unit {
  ()
}

///|
fn window_x(_window_id : Int) -> Int {
  0
}

///|
fn window_y(_window_id : Int) -> Int {
  0
}

///|
fn window_min_surface_width(_window_id : Int) -> Int {
  0
}

///|
fn window_min_surface_height(_window_id : Int) -> Int {
  0
}

///|
fn window_max_surface_width(_window_id : Int) -> Int {
  0
}

///|
fn window_max_surface_height(_window_id : Int) -> Int {
  0
}

///|
fn window_outer_width(_window_id : Int) -> Int {
  0
}

///|
fn window_outer_height(_window_id : Int) -> Int {
  0
}

///|
fn window_surface_x(_window_id : Int) -> Int {
  0
}

///|
fn window_surface_y(_window_id : Int) -> Int {
  0
}

///|
fn window_safe_area_top(_window_id : Int) -> Int {
  0
}

///|
fn window_safe_area_left(_window_id : Int) -> Int {
  0
}

///|
fn window_safe_area_bottom(_window_id : Int) -> Int {
  0
}

///|
fn window_safe_area_right(_window_id : Int) -> Int {
  0
}

///|
fn set_window_position(_window_id : Int, _x : Int, _y : Int) -> Unit {
  ()
}

///|
fn focus_window(_window_id : Int) -> Unit {
  ()
}

///|
fn set_window_minimized(_window_id : Int, _minimized : Bool) -> Unit {
  ()
}

///|
fn set_window_maximized(_window_id : Int, _maximized : Bool) -> Unit {
  ()
}

///|
fn set_window_fullscreen(_window_id : Int, _fullscreen : Bool) -> Unit {
  ()
}

///|
fn set_window_decorations(_window_id : Int, _decorated : Bool) -> Unit {
  ()
}

///|
fn set_window_enabled_buttons(
  _window_id : Int,
  _close : Bool,
  _minimize : Bool,
  _maximize : Bool,
) -> Unit {
  ()
}

///|
fn set_window_blur(_window_id : Int, _blur : Bool) -> Unit {
  ()
}

///|
fn set_window_cursor(_window_id : Int, _cursor : Int) -> Unit {
  ()
}

///|
fn set_window_cursor_visible(_window_id : Int, _visible : Bool) -> Unit {
  ()
}

///|
fn set_window_cursor_hittest(_window_id : Int, _hittest : Bool) -> Unit {
  ()
}

///|
fn set_cursor_position(_window_id : Int, _x : Int, _y : Int) -> Bool {
  false
}

///|
fn set_cursor_grab(_window_id : Int, _mode : Int) -> Bool {
  false
}

///|
fn drag_window(_window_id : Int) -> Bool {
  false
}

///|
fn drag_resize_window(_window_id : Int, _direction : Int) -> Bool {
  false
}

///|
fn show_window_menu(_window_id : Int, _x : Int, _y : Int) -> Bool {
  false
}

///|
fn set_window_transparent(_window_id : Int, _transparent : Bool) -> Unit {
  ()
}

///|
fn set_window_level(_window_id : Int, _level : Int) -> Unit {
  ()
}

///|
fn set_window_theme(_window_id : Int, _theme : Int) -> Unit {
  ()
}

///|
fn set_window_icon(_window_id : Int, _window_icon : @core.Icon?) -> Unit {
  ()
}

///|
fn set_window_content_protected(
  _window_id : Int,
  _content_protected : Bool,
) -> Unit {
  ()
}

///|
fn set_ime_purpose(_window_id : Int, _purpose : Int) -> Unit {
  ()
}

///|
fn set_ime_hints(_window_id : Int, _hints : Int) -> Unit {
  ()
}

///|
fn set_ime_allowed(_window_id : Int, _allowed : Bool) -> Unit {
  ()
}

///|
fn set_ime_cursor_area(
  _window_id : Int,
  _x : Int,
  _y : Int,
  _width : Int,
  _height : Int,
) -> Unit {
  ()
}

///|
fn set_ime_surrounding_text(
  _window_id : Int,
  _text : String,
  _cursor : Int,
  _anchor : Int,
) -> Unit {
  ()
}

///|
fn clear_ime_surrounding_text(_window_id : Int) -> Unit {
  ()
}

///|
fn close_window(_window_id : Int) -> Unit {
  ()
}

///|
fn create_window(
  _width : Int,
  _height : Int,
  _visible : Bool,
  _active : Bool,
  _resizable : Bool,
  _decorations : Bool,
  _title : String,
) -> Int {
  abort("macos backend requires the native target")
}

///|
fn set_title(_window_id : Int, _title : String) -> Unit {
  abort("macos backend requires the native target")
}

///|
fn request_user_attention(_window_id : Int, _request_type : Int) -> Unit {
  ()
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
