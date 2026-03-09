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
fn window_title(window_id : Int) -> Bytes {
  native_window_title_utf8(window_id)
}

///|
fn available_monitor_count() -> Int {
  native_monitor_count()
}

///|
fn monitor_id_at(index : Int) -> UInt64 {
  native_monitor_id_at(index)
}

///|
fn primary_monitor_id() -> UInt64 {
  native_primary_monitor_id()
}

///|
fn window_current_monitor_id(window_id : Int) -> UInt64 {
  native_window_current_monitor_id(window_id)
}

///|
fn monitor_name(monitor_id : UInt64) -> Bytes {
  native_monitor_name_utf8(monitor_id)
}

///|
fn monitor_position_x(monitor_id : UInt64) -> Int {
  native_monitor_position_x(monitor_id)
}

///|
fn monitor_position_y(monitor_id : UInt64) -> Int {
  native_monitor_position_y(monitor_id)
}

///|
fn monitor_width(monitor_id : UInt64) -> Int {
  native_monitor_width(monitor_id)
}

///|
fn monitor_height(monitor_id : UInt64) -> Int {
  native_monitor_height(monitor_id)
}

///|
fn monitor_scale_factor(monitor_id : UInt64) -> Double {
  native_monitor_scale_factor(monitor_id)
}

///|
fn monitor_video_mode_count(monitor_id : UInt64) -> Int {
  native_monitor_video_mode_count(monitor_id)
}

///|
fn monitor_video_mode_width(monitor_id : UInt64, index : Int) -> Int {
  native_monitor_video_mode_width(monitor_id, index)
}

///|
fn monitor_video_mode_height(monitor_id : UInt64, index : Int) -> Int {
  native_monitor_video_mode_height(monitor_id, index)
}

///|
fn monitor_video_mode_bit_depth(monitor_id : UInt64, index : Int) -> Int {
  native_monitor_video_mode_bit_depth(monitor_id, index)
}

///|
fn monitor_video_mode_refresh_rate_millihertz(
  monitor_id : UInt64,
  index : Int,
) -> Int {
  native_monitor_video_mode_refresh_rate_millihertz(monitor_id, index)
}

///|
fn monitor_current_video_mode_index(monitor_id : UInt64) -> Int {
  native_monitor_current_video_mode_index(monitor_id)
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
fn window_has_focus(window_id : Int) -> Bool {
  native_window_has_focus(window_id)
}

///|
fn window_visible(window_id : Int) -> Bool {
  native_window_visible(window_id)
}

///|
fn window_resizable(window_id : Int) -> Bool {
  native_window_resizable(window_id)
}

///|
fn window_content_protected(window_id : Int) -> Bool {
  native_window_content_protected(window_id)
}

///|
fn window_occluded(window_id : Int) -> Bool {
  native_window_occluded(window_id)
}

///|
fn window_minimized(window_id : Int) -> Bool {
  native_window_minimized(window_id)
}

///|
fn window_maximized(window_id : Int) -> Bool {
  native_window_maximized(window_id)
}

///|
fn window_fullscreen(window_id : Int) -> Bool {
  native_window_fullscreen(window_id)
}

///|
fn window_decorated(window_id : Int) -> Bool {
  native_window_decorated(window_id)
}

///|
fn window_close_button_enabled(window_id : Int) -> Bool {
  native_window_close_button_enabled(window_id)
}

///|
fn window_minimize_button_enabled(window_id : Int) -> Bool {
  native_window_minimize_button_enabled(window_id)
}

///|
fn window_maximize_button_enabled(window_id : Int) -> Bool {
  native_window_maximize_button_enabled(window_id)
}

///|
fn window_blur(window_id : Int) -> Bool {
  native_window_blur(window_id)
}

///|
fn window_cursor(window_id : Int) -> Int {
  native_window_cursor(window_id)
}

///|
fn window_cursor_visible(window_id : Int) -> Bool {
  native_window_cursor_visible(window_id)
}

///|
fn window_cursor_hittest(window_id : Int) -> Bool {
  native_window_cursor_hittest(window_id)
}

///|
fn window_transparent(window_id : Int) -> Bool {
  native_window_transparent(window_id)
}

///|
fn window_level(window_id : Int) -> Int {
  native_window_level(window_id)
}

///|
fn window_ime_allowed(window_id : Int) -> Bool {
  native_window_ime_allowed(window_id)
}

///|
fn window_ime_purpose(window_id : Int) -> Int {
  native_window_ime_purpose(window_id)
}

///|
fn window_ime_cursor_area_x(window_id : Int) -> Int {
  native_window_ime_cursor_area_x(window_id)
}

///|
fn window_ime_cursor_area_y(window_id : Int) -> Int {
  native_window_ime_cursor_area_y(window_id)
}

///|
fn window_ime_cursor_area_width(window_id : Int) -> Int {
  native_window_ime_cursor_area_width(window_id)
}

///|
fn window_ime_cursor_area_height(window_id : Int) -> Int {
  native_window_ime_cursor_area_height(window_id)
}

///|
fn window_has_ime_surrounding_text(window_id : Int) -> Bool {
  native_window_has_ime_surrounding_text(window_id)
}

///|
fn window_ime_surrounding_text(window_id : Int) -> Bytes {
  native_window_ime_surrounding_text(window_id)
}

///|
fn window_ime_surrounding_cursor(window_id : Int) -> Int {
  native_window_ime_surrounding_cursor(window_id)
}

///|
fn window_ime_surrounding_anchor(window_id : Int) -> Int {
  native_window_ime_surrounding_anchor(window_id)
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
fn window_resize_increment_width(window_id : Int) -> Int {
  native_window_resize_increment_width(window_id)
}

///|
fn window_resize_increment_height(window_id : Int) -> Int {
  native_window_resize_increment_height(window_id)
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
fn input_event_scancode(window_id : Int) -> Int {
  native_window_input_event_scancode(window_id)
}

///|
fn input_event_repeat(window_id : Int) -> Bool {
  native_window_input_event_repeat(window_id)
}

///|
fn input_event_text_with_all_modifiers(window_id : Int) -> Bytes {
  native_window_input_event_text_with_all_modifiers(window_id)
}

///|
fn input_event_text_ignoring_modifiers(window_id : Int) -> Bytes {
  native_window_input_event_text_ignoring_modifiers(window_id)
}

///|
fn input_event_text_without_modifiers(window_id : Int) -> Bytes {
  native_window_input_event_text_without_modifiers(window_id)
}

///|
fn input_event_ime_kind(window_id : Int) -> Int {
  native_window_input_event_ime_kind(window_id)
}

///|
fn input_event_ime_text(window_id : Int) -> Bytes {
  native_window_input_event_ime_text(window_id)
}

///|
fn input_event_path(window_id : Int) -> Bytes {
  native_window_input_event_path(window_id)
}

///|
fn input_event_ime_cursor_start(window_id : Int) -> Int {
  native_window_input_event_ime_cursor_start(window_id)
}

///|
fn input_event_ime_cursor_end(window_id : Int) -> Int {
  native_window_input_event_ime_cursor_end(window_id)
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
fn set_surface_resize_increments(
  window_id : Int,
  width : Int,
  height : Int,
) -> Unit {
  native_window_set_surface_resize_increments(window_id, width, height)
}

///|
fn set_min_surface_size(window_id : Int, width : Int, height : Int) -> Unit {
  native_window_set_min_surface_size(window_id, width, height)
}

///|
fn set_max_surface_size(window_id : Int, width : Int, height : Int) -> Unit {
  native_window_set_max_surface_size(window_id, width, height)
}

///|
fn window_x(window_id : Int) -> Int {
  native_window_x(window_id)
}

///|
fn window_y(window_id : Int) -> Int {
  native_window_y(window_id)
}

///|
fn window_min_surface_width(window_id : Int) -> Int {
  native_window_min_surface_width(window_id)
}

///|
fn window_min_surface_height(window_id : Int) -> Int {
  native_window_min_surface_height(window_id)
}

///|
fn window_max_surface_width(window_id : Int) -> Int {
  native_window_max_surface_width(window_id)
}

///|
fn window_max_surface_height(window_id : Int) -> Int {
  native_window_max_surface_height(window_id)
}

///|
fn window_outer_width(window_id : Int) -> Int {
  native_window_outer_width(window_id)
}

///|
fn window_outer_height(window_id : Int) -> Int {
  native_window_outer_height(window_id)
}

///|
fn window_surface_x(window_id : Int) -> Int {
  native_window_surface_x(window_id)
}

///|
fn window_surface_y(window_id : Int) -> Int {
  native_window_surface_y(window_id)
}

///|
fn window_safe_area_top(window_id : Int) -> Int {
  native_window_safe_area_top(window_id)
}

///|
fn window_safe_area_left(window_id : Int) -> Int {
  native_window_safe_area_left(window_id)
}

///|
fn window_safe_area_bottom(window_id : Int) -> Int {
  native_window_safe_area_bottom(window_id)
}

///|
fn window_safe_area_right(window_id : Int) -> Int {
  native_window_safe_area_right(window_id)
}

///|
fn set_window_position(window_id : Int, x : Int, y : Int) -> Unit {
  native_window_set_position(window_id, x, y)
}

///|
fn focus_window(window_id : Int) -> Unit {
  native_window_focus(window_id)
}

///|
fn set_window_minimized(window_id : Int, minimized : Bool) -> Unit {
  native_window_set_minimized(window_id, minimized)
}

///|
fn set_window_maximized(window_id : Int, maximized : Bool) -> Unit {
  native_window_set_maximized(window_id, maximized)
}

///|
fn set_window_fullscreen(window_id : Int, fullscreen : Bool) -> Unit {
  native_window_set_fullscreen(window_id, fullscreen)
}

///|
fn set_window_decorations(window_id : Int, decorated : Bool) -> Unit {
  native_window_set_decorations(window_id, decorated)
}

///|
fn set_window_enabled_buttons(
  window_id : Int,
  close : Bool,
  minimize : Bool,
  maximize : Bool,
) -> Unit {
  native_window_set_enabled_buttons(window_id, close, minimize, maximize)
}

///|
fn set_window_blur(window_id : Int, blur : Bool) -> Unit {
  native_window_set_blur(window_id, blur)
}

///|
fn set_window_cursor(window_id : Int, cursor : Int) -> Unit {
  native_window_set_cursor(window_id, cursor)
}

///|
fn set_window_cursor_visible(window_id : Int, visible : Bool) -> Unit {
  native_window_set_cursor_visible(window_id, visible)
}

///|
fn set_window_cursor_hittest(window_id : Int, hittest : Bool) -> Unit {
  native_window_set_cursor_hittest(window_id, hittest)
}

///|
fn set_cursor_position(window_id : Int, x : Int, y : Int) -> Bool {
  native_window_set_cursor_position(window_id, x, y)
}

///|
fn set_cursor_grab(window_id : Int, mode : Int) -> Bool {
  native_window_set_cursor_grab(window_id, mode)
}

///|
fn drag_window(window_id : Int) -> Bool {
  native_window_drag_window(window_id)
}

///|
fn drag_resize_window(window_id : Int, direction : Int) -> Bool {
  native_window_drag_resize_window(window_id, direction)
}

///|
fn show_window_menu(window_id : Int, x : Int, y : Int) -> Unit {
  native_window_show_window_menu(window_id, x, y)
}

///|
fn set_window_transparent(window_id : Int, transparent : Bool) -> Unit {
  native_window_set_transparent(window_id, transparent)
}

///|
fn set_window_level(window_id : Int, level : Int) -> Unit {
  native_window_set_window_level(window_id, level)
}

///|
fn set_window_theme(window_id : Int, theme : Int) -> Unit {
  native_window_set_theme(window_id, theme)
}

///|
fn set_window_icon(window_id : Int, window_icon : @core.Icon?) -> Unit {
  match window_icon {
    Some(icon) => {
      let rgba = icon.rgba()
      native_window_set_icon_rgba(
        window_id,
        rgba,
        rgba.length(),
        icon.width(),
        icon.height(),
      )
    }
    None =>
      native_window_set_icon_rgba(
        window_id,
        Bytes::make(0, (0 : Int).to_byte()),
        0,
        0,
        0,
      )
  }
}

///|
fn set_window_content_protected(
  window_id : Int,
  content_protected : Bool,
) -> Unit {
  native_window_set_content_protected(window_id, content_protected)
}

///|
fn set_ime_purpose(window_id : Int, purpose : Int) -> Unit {
  native_window_set_ime_purpose(window_id, purpose)
}

///|
fn set_ime_allowed(window_id : Int, allowed : Bool) -> Unit {
  native_window_set_ime_allowed(window_id, allowed)
}

///|
fn set_ime_cursor_area(
  window_id : Int,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Unit {
  native_window_set_ime_cursor_area(window_id, x, y, width, height)
}

///|
fn set_ime_surrounding_text(
  window_id : Int,
  text : String,
  cursor : Int,
  anchor : Int,
) -> Unit {
  let text_bytes = @utf8.encode(text[:], bom=false)
  native_window_set_ime_surrounding_text(
    window_id,
    text_bytes,
    text_bytes.length(),
    cursor,
    anchor,
  )
}

///|
fn clear_ime_surrounding_text(window_id : Int) -> Unit {
  native_window_clear_ime_surrounding_text(window_id)
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
  active : Bool,
  resizable : Bool,
  decorations : Bool,
  title : String,
) -> Int {
  let title_bytes = @utf8.encode(title[:], bom=false)
  native_create_window(
    width,
    height,
    visible,
    active,
    resizable,
    decorations,
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
fn request_user_attention(window_id : Int, request_type : Int) -> Unit {
  native_window_request_user_attention(window_id, request_type)
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
  active : Bool,
  resizable : Bool,
  decorations : Bool,
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
extern "C" fn native_window_min_surface_width(window_id : Int) -> Int = "mbw_window_min_surface_width"

///|
extern "C" fn native_window_min_surface_height(window_id : Int) -> Int = "mbw_window_min_surface_height"

///|
extern "C" fn native_window_max_surface_width(window_id : Int) -> Int = "mbw_window_max_surface_width"

///|
extern "C" fn native_window_max_surface_height(window_id : Int) -> Int = "mbw_window_max_surface_height"

///|
extern "C" fn native_window_outer_width(window_id : Int) -> Int = "mbw_window_outer_width"

///|
extern "C" fn native_window_outer_height(window_id : Int) -> Int = "mbw_window_outer_height"

///|
extern "C" fn native_window_surface_x(window_id : Int) -> Int = "mbw_window_surface_x"

///|
extern "C" fn native_window_surface_y(window_id : Int) -> Int = "mbw_window_surface_y"

///|
extern "C" fn native_window_safe_area_top(window_id : Int) -> Int = "mbw_window_safe_area_top"

///|
extern "C" fn native_window_safe_area_left(window_id : Int) -> Int = "mbw_window_safe_area_left"

///|
extern "C" fn native_window_safe_area_bottom(window_id : Int) -> Int = "mbw_window_safe_area_bottom"

///|
extern "C" fn native_window_safe_area_right(window_id : Int) -> Int = "mbw_window_safe_area_right"

///|
extern "C" fn native_window_resize_increment_width(window_id : Int) -> Int = "mbw_window_resize_increment_width"

///|
extern "C" fn native_window_resize_increment_height(window_id : Int) -> Int = "mbw_window_resize_increment_height"

///|
extern "C" fn native_window_x(window_id : Int) -> Int = "mbw_window_x"

///|
extern "C" fn native_window_y(window_id : Int) -> Int = "mbw_window_y"

///|
extern "C" fn native_window_theme(window_id : Int) -> Int = "mbw_window_theme"

///|
extern "C" fn native_window_title_utf8(window_id : Int) -> Bytes = "mbw_window_title_utf8"

///|
extern "C" fn native_monitor_count() -> Int = "mbw_monitor_count"

///|
extern "C" fn native_monitor_id_at(index : Int) -> UInt64 = "mbw_monitor_id_at"

///|
extern "C" fn native_primary_monitor_id() -> UInt64 = "mbw_primary_monitor_id"

///|
extern "C" fn native_window_current_monitor_id(window_id : Int) -> UInt64 = "mbw_window_current_monitor_id"

///|
extern "C" fn native_monitor_name_utf8(monitor_id : UInt64) -> Bytes = "mbw_monitor_name_utf8"

///|
extern "C" fn native_monitor_position_x(monitor_id : UInt64) -> Int = "mbw_monitor_position_x"

///|
extern "C" fn native_monitor_position_y(monitor_id : UInt64) -> Int = "mbw_monitor_position_y"

///|
extern "C" fn native_monitor_width(monitor_id : UInt64) -> Int = "mbw_monitor_width"

///|
extern "C" fn native_monitor_height(monitor_id : UInt64) -> Int = "mbw_monitor_height"

///|
extern "C" fn native_monitor_scale_factor(monitor_id : UInt64) -> Double = "mbw_monitor_scale_factor"

///|
extern "C" fn native_monitor_video_mode_count(monitor_id : UInt64) -> Int = "mbw_monitor_video_mode_count"

///|
extern "C" fn native_monitor_video_mode_width(
  monitor_id : UInt64,
  index : Int,
) -> Int = "mbw_monitor_video_mode_width"

///|
extern "C" fn native_monitor_video_mode_height(
  monitor_id : UInt64,
  index : Int,
) -> Int = "mbw_monitor_video_mode_height"

///|
extern "C" fn native_monitor_video_mode_bit_depth(
  monitor_id : UInt64,
  index : Int,
) -> Int = "mbw_monitor_video_mode_bit_depth"

///|
extern "C" fn native_monitor_video_mode_refresh_rate_millihertz(
  monitor_id : UInt64,
  index : Int,
) -> Int = "mbw_monitor_video_mode_refresh_rate_millihertz"

///|
extern "C" fn native_monitor_current_video_mode_index(
  monitor_id : UInt64,
) -> Int = "mbw_monitor_current_video_mode_index"

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
extern "C" fn native_window_has_focus(window_id : Int) -> Bool = "mbw_window_has_focus"

///|
extern "C" fn native_window_visible(window_id : Int) -> Bool = "mbw_window_visible"

///|
extern "C" fn native_window_resizable(window_id : Int) -> Bool = "mbw_window_resizable"

///|
extern "C" fn native_window_content_protected(window_id : Int) -> Bool = "mbw_window_content_protected"

///|
extern "C" fn native_window_occluded(window_id : Int) -> Bool = "mbw_window_is_occluded"

///|
extern "C" fn native_window_minimized(window_id : Int) -> Bool = "mbw_window_minimized"

///|
extern "C" fn native_window_maximized(window_id : Int) -> Bool = "mbw_window_maximized"

///|
extern "C" fn native_window_fullscreen(window_id : Int) -> Bool = "mbw_window_fullscreen"

///|
extern "C" fn native_window_decorated(window_id : Int) -> Bool = "mbw_window_decorated"

///|
extern "C" fn native_window_close_button_enabled(window_id : Int) -> Bool = "mbw_window_close_button_enabled"

///|
extern "C" fn native_window_minimize_button_enabled(window_id : Int) -> Bool = "mbw_window_minimize_button_enabled"

///|
extern "C" fn native_window_maximize_button_enabled(window_id : Int) -> Bool = "mbw_window_maximize_button_enabled"

///|
extern "C" fn native_window_blur(window_id : Int) -> Bool = "mbw_window_blur"

///|
extern "C" fn native_window_cursor(window_id : Int) -> Int = "mbw_window_cursor"

///|
extern "C" fn native_window_cursor_visible(window_id : Int) -> Bool = "mbw_window_cursor_visible"

///|
extern "C" fn native_window_cursor_hittest(window_id : Int) -> Bool = "mbw_window_cursor_hittest"

///|
extern "C" fn native_window_transparent(window_id : Int) -> Bool = "mbw_window_transparent"

///|
extern "C" fn native_window_level(window_id : Int) -> Int = "mbw_window_level"

///|
extern "C" fn native_window_ime_allowed(window_id : Int) -> Bool = "mbw_window_ime_allowed"

///|
extern "C" fn native_window_ime_purpose(window_id : Int) -> Int = "mbw_window_ime_purpose"

///|
extern "C" fn native_window_ime_cursor_area_x(window_id : Int) -> Int = "mbw_window_ime_cursor_area_x"

///|
extern "C" fn native_window_ime_cursor_area_y(window_id : Int) -> Int = "mbw_window_ime_cursor_area_y"

///|
extern "C" fn native_window_ime_cursor_area_width(window_id : Int) -> Int = "mbw_window_ime_cursor_area_width"

///|
extern "C" fn native_window_ime_cursor_area_height(window_id : Int) -> Int = "mbw_window_ime_cursor_area_height"

///|
extern "C" fn native_window_has_ime_surrounding_text(window_id : Int) -> Bool = "mbw_window_has_ime_surrounding_text"

///|
extern "C" fn native_window_ime_surrounding_text(window_id : Int) -> Bytes = "mbw_window_ime_surrounding_text_utf8"

///|
extern "C" fn native_window_ime_surrounding_cursor(window_id : Int) -> Int = "mbw_window_ime_surrounding_cursor"

///|
extern "C" fn native_window_ime_surrounding_anchor(window_id : Int) -> Int = "mbw_window_ime_surrounding_anchor"

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
extern "C" fn native_window_input_event_scancode(window_id : Int) -> Int = "mbw_window_input_event_scancode"

///|
extern "C" fn native_window_input_event_repeat(window_id : Int) -> Bool = "mbw_window_input_event_repeat"

///|
extern "C" fn native_window_input_event_text_with_all_modifiers(
  window_id : Int,
) -> Bytes = "mbw_window_input_event_text_with_all_modifiers"

///|
extern "C" fn native_window_input_event_text_ignoring_modifiers(
  window_id : Int,
) -> Bytes = "mbw_window_input_event_text_ignoring_modifiers"

///|
extern "C" fn native_window_input_event_text_without_modifiers(
  window_id : Int,
) -> Bytes = "mbw_window_input_event_text_without_modifiers"

///|
extern "C" fn native_window_input_event_ime_kind(window_id : Int) -> Int = "mbw_window_input_event_ime_kind"

///|
extern "C" fn native_window_input_event_ime_text(window_id : Int) -> Bytes = "mbw_window_input_event_ime_text"

///|
extern "C" fn native_window_input_event_path(window_id : Int) -> Bytes = "mbw_window_input_event_path"

///|
extern "C" fn native_window_input_event_ime_cursor_start(
  window_id : Int,
) -> Int = "mbw_window_input_event_ime_cursor_start"

///|
extern "C" fn native_window_input_event_ime_cursor_end(window_id : Int) -> Int = "mbw_window_input_event_ime_cursor_end"

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
extern "C" fn native_window_set_surface_resize_increments(
  window_id : Int,
  width : Int,
  height : Int,
) -> Unit = "mbw_window_set_surface_resize_increments"

///|
extern "C" fn native_window_set_min_surface_size(
  window_id : Int,
  width : Int,
  height : Int,
) -> Unit = "mbw_window_set_min_surface_size"

///|
extern "C" fn native_window_set_max_surface_size(
  window_id : Int,
  width : Int,
  height : Int,
) -> Unit = "mbw_window_set_max_surface_size"

///|
extern "C" fn native_window_set_position(
  window_id : Int,
  x : Int,
  y : Int,
) -> Unit = "mbw_window_set_position"

///|
extern "C" fn native_window_focus(window_id : Int) -> Unit = "mbw_window_focus"

///|
extern "C" fn native_window_set_minimized(
  window_id : Int,
  minimized : Bool,
) -> Unit = "mbw_window_set_minimized"

///|
extern "C" fn native_window_set_maximized(
  window_id : Int,
  maximized : Bool,
) -> Unit = "mbw_window_set_maximized"

///|
extern "C" fn native_window_set_fullscreen(
  window_id : Int,
  fullscreen : Bool,
) -> Unit = "mbw_window_set_fullscreen"

///|
extern "C" fn native_window_set_decorations(
  window_id : Int,
  decorated : Bool,
) -> Unit = "mbw_window_set_decorations"

///|
extern "C" fn native_window_set_enabled_buttons(
  window_id : Int,
  close : Bool,
  minimize : Bool,
  maximize : Bool,
) -> Unit = "mbw_window_set_enabled_buttons"

///|
extern "C" fn native_window_set_blur(window_id : Int, blur : Bool) -> Unit = "mbw_window_set_blur"

///|
extern "C" fn native_window_set_cursor(window_id : Int, cursor : Int) -> Unit = "mbw_window_set_cursor"

///|
extern "C" fn native_window_set_cursor_visible(
  window_id : Int,
  visible : Bool,
) -> Unit = "mbw_window_set_cursor_visible"

///|
extern "C" fn native_window_set_cursor_hittest(
  window_id : Int,
  hittest : Bool,
) -> Unit = "mbw_window_set_cursor_hittest"

///|
extern "C" fn native_window_set_cursor_position(
  window_id : Int,
  x : Int,
  y : Int,
) -> Bool = "mbw_window_set_cursor_position"

///|
extern "C" fn native_window_set_cursor_grab(
  window_id : Int,
  mode : Int,
) -> Bool = "mbw_window_set_cursor_grab"

///|
extern "C" fn native_window_drag_window(window_id : Int) -> Bool = "mbw_window_drag_window"

///|
extern "C" fn native_window_drag_resize_window(
  window_id : Int,
  direction : Int,
) -> Bool = "mbw_window_drag_resize_window"

///|
extern "C" fn native_window_show_window_menu(
  window_id : Int,
  x : Int,
  y : Int,
) -> Unit = "mbw_window_show_window_menu"

///|
extern "C" fn native_window_set_transparent(
  window_id : Int,
  transparent : Bool,
) -> Unit = "mbw_window_set_transparent"

///|
extern "C" fn native_window_set_window_level(
  window_id : Int,
  level : Int,
) -> Unit = "mbw_window_set_window_level"

///|
extern "C" fn native_window_set_theme(window_id : Int, theme : Int) -> Unit = "mbw_window_set_theme"

///|
#borrow(rgba)
extern "C" fn native_window_set_icon_rgba(
  window_id : Int,
  rgba : Bytes,
  rgba_len : Int,
  width : Int,
  height : Int,
) -> Unit = "mbw_window_set_icon_rgba"

///|
extern "C" fn native_window_set_content_protected(
  window_id : Int,
  content_protected : Bool,
) -> Unit = "mbw_window_set_content_protected"

///|
extern "C" fn native_window_set_ime_purpose(
  window_id : Int,
  purpose : Int,
) -> Unit = "mbw_window_set_ime_purpose"

///|
extern "C" fn native_window_set_ime_allowed(
  window_id : Int,
  allowed : Bool,
) -> Unit = "mbw_window_set_ime_allowed"

///|
extern "C" fn native_window_set_ime_cursor_area(
  window_id : Int,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Unit = "mbw_window_set_ime_cursor_area"

///|
#borrow(text)
extern "C" fn native_window_set_ime_surrounding_text(
  window_id : Int,
  text : Bytes,
  text_len : Int,
  cursor : Int,
  anchor : Int,
) -> Unit = "mbw_window_set_ime_surrounding_text_utf8"

///|
extern "C" fn native_window_clear_ime_surrounding_text(window_id : Int) -> Unit = "mbw_window_clear_ime_surrounding_text"

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
extern "C" fn native_window_request_user_attention(
  window_id : Int,
  request_type : Int,
) -> Unit = "mbw_window_request_user_attention"

///|
pub extern "C" fn native_set_visible(window_id : Int, visible : Bool) -> Unit = "mbw_window_set_visible"

///|
pub extern "C" fn native_set_resizable(
  window_id : Int,
  resizable : Bool,
) -> Unit = "mbw_window_set_resizable"
