///|
/// Return the AppKit content view/window handle used by raw-window-handle 0.6.
///
/// This synchronously switches to the process main thread when called from a
/// worker thread. The returned handle is borrowed and must not be released.
pub fn Window::rwh_06_window_handle(self : Window) -> UInt64 {
  self.maybe_wait_on_main(fn(window) { window.rwh_06_window_handle_on_main() })
}

///|
/// Return the raw AppKit window/view handle for this window.
///
/// The returned value is borrowed from AppKit and remains owned by the windowing
/// backend. Do not release it.
pub fn Window::window_handle(self : Window) -> UInt64 {
  self.maybe_wait_on_main(fn(window) { window.window_handle_on_main() })
}

///|
/// Return the borrowed AppKit content view handle for this window.
///
/// The handle is not retained for the caller. Use it only while the `Window` is
/// alive, and do not release it.
pub fn Window::content_view_handle(
  self : Window,
) -> UInt64 raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(window) -> UInt64 raise @core.RequestError {
    window.content_view_handle_on_main()
  })
}

///|
pub fn Window::drop(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.drop_on_main() })
}

///|
pub fn Window::set_cursor(self : Window, cursor : @core.Cursor) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_cursor_on_main(cursor) })
}

///|
pub fn Window::set_cursor_icon(
  self : Window,
  cursor : @core.CursorIcon,
) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_cursor_icon_on_main(cursor) })
}

///|
pub fn Window::set_cursor_visible(self : Window, visible : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_cursor_visible_on_main(visible)
  })
}

///|
pub fn Window::set_cursor_hittest(
  self : Window,
  hittest : Bool,
) -> Unit raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(window) -> Unit raise @core.RequestError {
    window.set_cursor_hittest_on_main(hittest)
  })
}

///|
pub fn Window::set_cursor_position(
  self : Window,
  position : @dpi.Position,
) -> Unit raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(window) -> Unit raise @core.RequestError {
    window.set_cursor_position_on_main(position)
  })
}

///|
pub fn Window::set_cursor_grab(
  self : Window,
  mode : @core.CursorGrabMode,
) -> Unit raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(window) -> Unit raise @core.RequestError {
    window.set_cursor_grab_on_main(mode)
  })
}

///|
pub fn Window::drag_window(self : Window) -> Unit raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(window) -> Unit raise @core.RequestError {
    window.drag_window_on_main()
  })
}

///|
pub fn Window::drag_resize_window(
  self : Window,
  direction : @core.ResizeDirection,
) -> Unit raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(window) -> Unit raise @core.RequestError {
    window.drag_resize_window_on_main(direction)
  })
}

///|
pub fn Window::show_window_menu(
  self : Window,
  position : @dpi.Position,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.show_window_menu_on_main(position)
  })
}

///|
pub fn Window::cursor(self : Window) -> @core.Cursor {
  self.maybe_wait_on_main(fn(window) { window.cursor_on_main() })
}

///|
pub fn Window::is_cursor_visible(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.is_cursor_visible_on_main() })
}

///|
pub fn Window::is_cursor_hittest(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.is_cursor_hittest_on_main() })
}

///|
pub fn Window::set_ime_purpose(
  self : Window,
  purpose : @core.ImePurpose,
) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_ime_purpose_on_main(purpose) })
}

///|
pub fn Window::set_ime_hints(self : Window, hints : @core.ImeHint) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_ime_hints_on_main(hints) })
}

///|
pub fn Window::set_ime_allowed(self : Window, allowed : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_ime_allowed_on_main(allowed) })
}

///|
pub fn Window::ime_allowed(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.ime_allowed_on_main() })
}

///|
pub fn Window::set_ime_cursor_area(
  self : Window,
  position : @dpi.Position,
  size : @dpi.Size,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_ime_cursor_area_on_main(position, size)
  })
}

///|
pub fn Window::set_ime_surrounding_text(
  self : Window,
  surrounding_text : @core.ImeSurroundingText?,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_ime_surrounding_text_on_main(surrounding_text)
  })
}

///|
pub fn Window::ime_cursor_area_position(self : Window) -> @dpi.PhysicalPosition {
  self.maybe_wait_on_main(fn(window) {
    window.ime_cursor_area_position_on_main()
  })
}

///|
pub fn Window::ime_cursor_area_size(self : Window) -> @dpi.PhysicalSize {
  self.maybe_wait_on_main(fn(window) { window.ime_cursor_area_size_on_main() })
}

///|
pub fn Window::ime_surrounding_text(self : Window) -> @core.ImeSurroundingText? {
  self.maybe_wait_on_main(fn(window) { window.ime_surrounding_text_on_main() })
}

///|
pub fn Window::ime_purpose(self : Window) -> @core.ImePurpose {
  self.maybe_wait_on_main(fn(window) { window.ime_purpose_on_main() })
}

///|
pub fn Window::ime_hints(self : Window) -> @core.ImeHint {
  self.maybe_wait_on_main(fn(window) { window.ime_hints_on_main() })
}

///|
pub fn Window::request_ime_update(
  self : Window,
  request : @core.ImeRequest,
) -> Unit raise @core.ImeRequestError {
  self.maybe_wait_on_main_result(fn(
    window,
  ) -> Unit raise @core.ImeRequestError {
    window.request_ime_update_on_main(request)
  })
}

///|
pub fn Window::ime_capabilities(self : Window) -> @core.ImeCapabilities? {
  self.maybe_wait_on_main(fn(window) { window.ime_capabilities_on_main() })
}

///|
pub fn Window::surface_size(self : Window) -> @dpi.PhysicalSize {
  self.maybe_wait_on_main(fn(window) { window.surface_size_on_main() })
}

///|
pub fn Window::inner_size(self : Window) -> @dpi.PhysicalSize {
  self.maybe_wait_on_main(fn(window) { window.inner_size_on_main() })
}

///|
pub fn Window::outer_size(self : Window) -> @dpi.PhysicalSize {
  self.maybe_wait_on_main(fn(window) { window.outer_size_on_main() })
}

///|
pub fn Window::surface_position(self : Window) -> @dpi.PhysicalPosition {
  self.maybe_wait_on_main(fn(window) { window.surface_position_on_main() })
}

///|
pub fn Window::inner_position(self : Window) -> @dpi.PhysicalPosition {
  self.maybe_wait_on_main(fn(window) { window.inner_position_on_main() })
}

///|
pub fn Window::safe_area(self : Window) -> @dpi.PhysicalInsets {
  self.maybe_wait_on_main(fn(window) { window.safe_area_on_main() })
}

///|
pub fn Window::request_surface_size(
  self : Window,
  size : @dpi.Size,
) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) {
    window.request_surface_size_on_main(size)
  })
}

///|
pub fn Window::request_inner_size(
  self : Window,
  size : @dpi.Size,
) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) { window.request_inner_size_on_main(size) })
}

///|
pub fn Window::set_surface_resize_increments(
  self : Window,
  size : @dpi.Size?,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_surface_resize_increments_on_main(size)
  })
}

///|
pub fn Window::set_resize_increments(self : Window, size : @dpi.Size?) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_resize_increments_on_main(size)
  })
}

///|
pub fn Window::surface_resize_increments(self : Window) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) {
    window.surface_resize_increments_on_main()
  })
}

///|
pub fn Window::resize_increments(self : Window) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) { window.resize_increments_on_main() })
}

///|
pub fn Window::set_min_surface_size(self : Window, size : @dpi.Size?) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_min_surface_size_on_main(size)
  })
}

///|
pub fn Window::set_min_inner_size(self : Window, size : @dpi.Size?) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_min_inner_size_on_main(size) })
}

///|
pub fn Window::set_max_surface_size(self : Window, size : @dpi.Size?) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_max_surface_size_on_main(size)
  })
}

///|
pub fn Window::set_max_inner_size(self : Window, size : @dpi.Size?) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_max_inner_size_on_main(size) })
}

///|
pub fn Window::min_surface_size(self : Window) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) { window.min_surface_size_on_main() })
}

///|
pub fn Window::min_inner_size(self : Window) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) { window.min_inner_size_on_main() })
}

///|
pub fn Window::max_surface_size(self : Window) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) { window.max_surface_size_on_main() })
}

///|
pub fn Window::max_inner_size(self : Window) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) { window.max_inner_size_on_main() })
}

///|
pub fn Window::outer_position(
  self : Window,
) -> @dpi.PhysicalPosition raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(
    window,
  ) -> @dpi.PhysicalPosition raise @core.RequestError {
    window.outer_position_on_main()
  })
}

///|
pub fn Window::set_outer_position(
  self : Window,
  position : @dpi.Position,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_outer_position_on_main(position)
  })
}

///|
pub fn Window::focus_window(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.focus_window_on_main() })
}

///|
pub fn Window::has_focus(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.has_focus_on_main() })
}

///|
pub fn Window::set_minimized(self : Window, minimized : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_minimized_on_main(minimized) })
}

///|
pub fn Window::is_minimized(self : Window) -> Bool? {
  self.maybe_wait_on_main(fn(window) { window.is_minimized_on_main() })
}

///|
pub fn Window::set_maximized(self : Window, maximized : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_maximized_on_main(maximized) })
}

///|
pub fn Window::is_maximized(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.is_maximized_on_main() })
}

///|
pub fn Window::is_decorated(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.is_decorated_on_main() })
}

///|
pub fn Window::enabled_buttons(self : Window) -> @core.WindowButtons {
  self.maybe_wait_on_main(fn(window) { window.enabled_buttons_on_main() })
}

///|
pub fn Window::is_blurred(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.is_blurred_on_main() })
}

///|
pub fn Window::set_transparent(self : Window, transparent : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_transparent_on_main(transparent)
  })
}

///|
pub fn Window::is_transparent(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.is_transparent_on_main() })
}

///|
pub fn Window::set_window_level(
  self : Window,
  level : @core.WindowLevel,
) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_window_level_on_main(level) })
}

///|
pub fn Window::window_level(self : Window) -> @core.WindowLevel {
  self.maybe_wait_on_main(fn(window) { window.window_level_on_main() })
}

///|
pub fn Window::scale_factor(self : Window) -> Double {
  self.maybe_wait_on_main(fn(window) { window.scale_factor_on_main() })
}

///|
pub fn Window::request_redraw(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.request_redraw_on_main() })
}

///|
pub fn Window::pre_present_notify(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.pre_present_notify_on_main() })
}

///|
pub fn Window::reset_dead_keys(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.reset_dead_keys_on_main() })
}

///|
pub fn Window::set_title(self : Window, title : String) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_title_on_main(title) })
}

///|
pub fn Window::title(self : Window) -> String {
  self.maybe_wait_on_main(fn(window) { window.title_on_main() })
}

///|
pub fn Window::set_window_icon(
  self : Window,
  window_icon : @core.Icon?,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_window_icon_on_main(window_icon)
  })
}

///|
pub fn Window::set_content_protected(
  self : Window,
  content_protected : Bool,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_content_protected_on_main(content_protected)
  })
}

///|
pub fn Window::set_visible(self : Window, visible : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_visible_on_main(visible) })
}

///|
pub fn Window::is_visible(self : Window) -> Bool? {
  self.maybe_wait_on_main(fn(window) { window.is_visible_on_main() })
}

///|
pub fn Window::set_resizable(self : Window, resizable : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_resizable_on_main(resizable) })
}

///|
pub fn Window::is_resizable(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.is_resizable_on_main() })
}

///|
pub fn Window::is_content_protected(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.is_content_protected_on_main() })
}

///|
pub fn Window::is_document_edited(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.is_document_edited_on_main() })
}

///|
pub fn Window::set_document_edited(self : Window, edited : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_document_edited_on_main(edited)
  })
}

///|
pub fn Window::set_option_as_alt(
  self : Window,
  option_as_alt : @core.OptionAsAlt,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_option_as_alt_on_main(option_as_alt)
  })
}

///|
pub fn Window::option_as_alt(self : Window) -> @core.OptionAsAlt {
  self.maybe_wait_on_main(fn(window) { window.option_as_alt_on_main() })
}

///|
pub fn Window::set_prefers_home_indicator_hidden(
  self : Window,
  hidden : Bool,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_prefers_home_indicator_hidden_on_main(hidden)
  })
}

///|
pub fn Window::set_prefers_status_bar_hidden(
  self : Window,
  hidden : Bool,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_prefers_status_bar_hidden_on_main(hidden)
  })
}

///|
pub fn Window::set_preferred_screen_edges_deferring_system_gestures(
  self : Window,
  edges : @core.ScreenEdge,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_preferred_screen_edges_deferring_system_gestures_on_main(edges)
  })
}

///|
pub fn Window::request_user_attention(
  self : Window,
  request_type : @core.UserAttentionType?,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.request_user_attention_on_main(request_type)
  })
}

///|
pub fn Window::current_monitor(self : Window) -> @core.MonitorHandle? {
  self.maybe_wait_on_main(fn(window) { window.current_monitor_on_main() })
}

///|
pub fn Window::available_monitors(self : Window) -> Array[@core.MonitorHandle] {
  self.maybe_wait_on_main(fn(window) { window.available_monitors_on_main() })
}

///|
pub fn Window::primary_monitor(self : Window) -> @core.MonitorHandle? {
  self.maybe_wait_on_main(fn(window) { window.primary_monitor_on_main() })
}

///|
pub fn Window::set_fullscreen(
  self : Window,
  fullscreen : @core.Fullscreen?,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_fullscreen_on_main(fullscreen)
  })
}

///|
pub fn Window::fullscreen(self : Window) -> @core.Fullscreen? {
  self.maybe_wait_on_main(fn(window) { window.fullscreen_on_main() })
}

///|
pub fn Window::is_fullscreen(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.is_fullscreen_on_main() })
}

///|
pub fn Window::simple_fullscreen(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.simple_fullscreen_on_main() })
}

///|
pub fn Window::set_simple_fullscreen(self : Window, fullscreen : Bool) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    window.set_simple_fullscreen_on_main(fullscreen)
  })
}

///|
pub fn Window::set_borderless_game(
  self : Window,
  borderless_game : Bool,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_borderless_game_on_main(borderless_game)
  })
}

///|
pub fn Window::is_borderless_game(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.is_borderless_game_on_main() })
}

///|
pub fn Window::set_unified_titlebar(
  self : Window,
  unified_titlebar : Bool,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_unified_titlebar_on_main(unified_titlebar)
  })
}

///|
pub fn Window::unified_titlebar(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.unified_titlebar_on_main() })
}

///|
pub fn Window::set_tabbing_identifier(
  self : Window,
  identifier : String,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_tabbing_identifier_on_main(identifier)
  })
}

///|
pub fn Window::tabbing_identifier(self : Window) -> String {
  self.maybe_wait_on_main(fn(window) { window.tabbing_identifier_on_main() })
}

///|
pub fn Window::select_next_tab(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.select_next_tab_on_main() })
}

///|
pub fn Window::select_previous_tab(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.select_previous_tab_on_main() })
}

///|
pub fn Window::select_tab_at_index(self : Window, index : Int) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.select_tab_at_index_on_main(index)
  })
}

///|
pub fn Window::num_tabs(self : Window) -> Int {
  self.maybe_wait_on_main(fn(window) { window.num_tabs_on_main() })
}

///|
pub fn Window::set_decorations(self : Window, decorations : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_decorations_on_main(decorations)
  })
}

///|
pub fn Window::set_enabled_buttons(
  self : Window,
  buttons : @core.WindowButtons,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_enabled_buttons_on_main(buttons)
  })
}

///|
pub fn Window::set_blur(self : Window, blur : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_blur_on_main(blur) })
}

///|
pub fn Window::has_shadow(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.has_shadow_on_main() })
}

///|
pub fn Window::set_has_shadow(self : Window, has_shadow : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_has_shadow_on_main(has_shadow)
  })
}

///|
pub fn Window::set_theme(self : Window, theme : @core.Theme?) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_theme_on_main(theme) })
}

///|
pub fn Window::theme(self : Window) -> @core.Theme? {
  self.maybe_wait_on_main(fn(window) { window.theme_on_main() })
}

///|
pub fn Window::is_occluded(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.is_occluded_on_main() })
}
