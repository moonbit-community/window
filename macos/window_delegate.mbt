///|
fn close_window(window_handle : NativeWindow) -> Unit {
  if native_window_objc_handle(window_handle) == (0 : Int).to_uint64() {
    return ()
  }
  native_window_forget_standard_frame(window_handle)
  clear_window_fullscreen_transition_state(
    native_window_identity(window_handle),
  )
  clear_window_platform_state(native_window_identity(window_handle))
  appkit_window_mark_closing(window_handle)
  appkit_window_destroy(window_handle)
}

///|
fn native_set_resizable(window_handle : NativeWindow, resizable : Bool) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_resizable(window_handle, resizable)
  }
}

///|
fn set_title(window_handle : NativeWindow, title : String) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_title(window_handle, title)
  }
}

///|
fn set_window_name(window_handle : NativeWindow, name : String) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_name(window_handle, name)
  }
}

///|
fn set_window_skip_taskbar(
  window_handle : NativeWindow,
  skip_taskbar : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_skip_taskbar(window_handle, skip_taskbar)
  }
}

///|
fn set_window_clip_children(
  window_handle : NativeWindow,
  clip_children : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_clip_children(window_handle, clip_children)
  }
}

///|
fn request_user_attention(
  window_handle : NativeWindow,
  request_type : Int,
) -> Unit {
  let _ = window_handle
  native_window_request_user_attention(request_type)
}

///|
fn window_native_scale_factor(window_handle : NativeWindow) -> Double {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    1.0
  } else {
    native_window_scale_factor(window_handle)
  }
}

///|
fn set_surface_size(
  window_handle : NativeWindow,
  width : Int,
  height : Int,
) -> Unit {
  let content_width = clamp_size(width)
  let content_height = clamp_size(height)
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_content_size(window_handle, content_width, content_height)
  }
}

///|
fn set_surface_resize_increments(
  window_handle : NativeWindow,
  width : Int,
  height : Int,
) -> Unit {
  let resize_width = if width > 0 { width } else { 0 }
  let resize_height = if height > 0 { height } else { 0 }
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_resize_increments(
      window_handle, resize_width, resize_height,
    )
  }
}

///|
fn set_min_surface_size(
  window_handle : NativeWindow,
  width : Int,
  height : Int,
) -> Unit {
  let min_width = if width > 0 { width } else { 0 }
  let min_height = if height > 0 { height } else { 0 }
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_min_content_size(window_handle, min_width, min_height)
  }
}

///|
fn set_max_surface_size(
  window_handle : NativeWindow,
  width : Int,
  height : Int,
) -> Unit {
  let max_width = if width > 0 { width } else { 0 }
  let max_height = if height > 0 { height } else { 0 }
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_max_content_size(window_handle, max_width, max_height)
  }
}

///|
fn set_window_position(window_handle : NativeWindow, x : Int, y : Int) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_position(window_handle, x, y)
  }
}

///|
fn set_window_outer_size(
  window_handle : NativeWindow,
  width : Int,
  height : Int,
) -> Unit {
  let logical_size = @dpi.PhysicalSize::PhysicalSize(width, height).to_logical(
    window_native_scale_factor(window_handle),
  )
  set_surface_size(
    window_handle,
    logical_size.width().to_int(),
    logical_size.height().to_int(),
  )
}

///|
fn set_window_maximized(window_handle : NativeWindow, maximized : Bool) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_maximized(window_handle, maximized)
  }
}

///|
fn set_window_decorations(
  window_handle : NativeWindow,
  decorated : Bool,
) -> Unit {
  if registered_native_handle(window_handle) == (0 : Int).to_uint64() {
    return ()
  }
  if window_fullscreen(window_handle) {
    return ()
  }
  let utility_window_mask = (16 : Int).to_uint64()
  let utility_window_bits = native_window_style_mask(window_handle) &
    utility_window_mask
  let mut style_mask = if decorated {
    // Titled | Closable | Miniaturizable
    (7 : Int).to_uint64()
  } else {
    // Borderless
    (0 : Int).to_uint64()
  }
  if native_window_is_resizable(window_handle) {
    // Resizable
    style_mask = style_mask | (8 : Int).to_uint64()
  }
  style_mask = style_mask | utility_window_bits
  native_window_set_style_mask(window_handle, style_mask)
}

///|
fn set_window_panel(window_handle : NativeWindow, panel : Bool) -> Unit {
  if registered_native_handle(window_handle) == (0 : Int).to_uint64() {
    return ()
  }
  let utility_window_mask = (16 : Int).to_uint64()
  let mut style_mask = native_window_style_mask(window_handle)
  if panel {
    style_mask = style_mask | utility_window_mask
  } else if (style_mask & utility_window_mask) != (0 : Int).to_uint64() {
    style_mask = style_mask - utility_window_mask
  }
  native_window_set_style_mask(window_handle, style_mask)
}

///|
fn set_window_enabled_buttons(
  window_handle : NativeWindow,
  close : Bool,
  minimize : Bool,
  maximize : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_enabled_buttons(window_handle, close, minimize, maximize)
  }
}

///|
fn set_window_accepts_first_mouse(
  window_handle : NativeWindow,
  accepts_first_mouse : Bool,
) -> Unit {
  set_window_accepts_first_mouse_state(
    native_window_identity(window_handle),
    accepts_first_mouse,
  )
}

///|
fn set_window_movable_by_window_background(
  window_handle : NativeWindow,
  movable_by_window_background : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_movable_by_background(
      window_handle, movable_by_window_background,
    )
  }
}

///|
fn set_window_titlebar_hidden(
  window_handle : NativeWindow,
  titlebar_hidden : Bool,
) -> Unit {
  if registered_native_handle(window_handle) == (0 : Int).to_uint64() {
    return ()
  }
  set_window_title_hidden(window_handle, titlebar_hidden)
  set_window_titlebar_transparent(window_handle, titlebar_hidden)
  set_window_fullsize_content_view(window_handle, titlebar_hidden)
}

///|
fn set_window_titlebar_buttons_hidden(
  window_handle : NativeWindow,
  titlebar_buttons_hidden : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_titlebar_buttons_hidden(
      window_handle, titlebar_buttons_hidden,
    )
  }
}

///|
fn set_window_fullsize_content_view(
  window_handle : NativeWindow,
  fullsize_content_view : Bool,
) -> Unit {
  if registered_native_handle(window_handle) == (0 : Int).to_uint64() {
    return ()
  }
  let fullsize_mask = (32768 : Int).to_uint64()
  if fullsize_content_view {
    native_window_set_style_mask(
      window_handle,
      native_window_style_mask(window_handle) | fullsize_mask,
    )
  } else {
    native_window_clear_style_mask_bits(window_handle, fullsize_mask)
  }
}

///|
fn set_window_has_shadow(
  window_handle : NativeWindow,
  has_shadow : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_has_shadow(window_handle, has_shadow)
  }
}

///|
fn set_window_document_edited(
  window_handle : NativeWindow,
  edited : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_document_edited(window_handle, edited)
  }
}

///|
fn set_window_unified_titlebar(
  window_handle : NativeWindow,
  unified_titlebar : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_unified_titlebar(window_handle, unified_titlebar)
  }
}

///|
fn set_window_tabbing_identifier(
  window_handle : NativeWindow,
  identifier : String,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_tabbing_identifier(window_handle, identifier)
  }
}

///|
fn set_window_tabbing_mode_preferred(window_handle : NativeWindow) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_tabbing_mode_preferred(window_handle)
  }
}

///|
fn select_window_next_tab(window_handle : NativeWindow) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_select_next_tab(window_handle)
  }
}

///|
fn select_window_previous_tab(window_handle : NativeWindow) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_select_previous_tab(window_handle)
  }
}

///|
fn select_window_tab_at_index(
  window_handle : NativeWindow,
  index : Int,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_select_tab_at_index(window_handle, index)
  }
}

///|
fn set_window_option_as_alt(
  window_handle : NativeWindow,
  option_as_alt : Int,
) -> Unit {
  set_window_option_as_alt_state(
    native_window_identity(window_handle),
    option_as_alt,
  )
}

///|
fn set_window_cursor(
  window_handle : NativeWindow,
  cursor : @core.CursorIcon,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_cursor(window_handle, cursor)
  }
}

///|
fn set_window_cursor_visible(
  window_handle : NativeWindow,
  visible : Bool,
) -> Unit {
  let native_handle = registered_native_handle(window_handle)
  if native_handle != (0 : Int).to_uint64() {
    native_window_set_cursor_visible(window_handle, visible)
  }
}

///|
fn window_cursor_visible(window_handle : NativeWindow) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    true
  } else {
    native_window_cursor_visible(window_handle)
  }
}

///|
fn set_window_level(window_handle : NativeWindow, level : Int) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_level(window_handle, level)
  }
}

///|
fn set_window_theme(window_handle : NativeWindow, theme : Int) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_theme(window_handle, theme)
  }
}

///|
fn set_window_content_protected(
  window_handle : NativeWindow,
  content_protected : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_content_protected(window_handle, content_protected)
  }
}

///|
fn set_ime_purpose(window_handle : NativeWindow, purpose : Int) -> Unit {
  set_window_ime_purpose_state(native_window_identity(window_handle), purpose)
}

///|
fn window_ime_purpose(window_handle : NativeWindow) -> Int {
  window_ime_purpose_state(native_window_identity(window_handle))
}

///|
fn set_ime_hints(window_handle : NativeWindow, hints : Int) -> Unit {
  set_window_ime_hints_state(native_window_identity(window_handle), hints)
}

///|
fn window_ime_hints(window_handle : NativeWindow) -> Int {
  window_ime_hints_state(native_window_identity(window_handle))
}

///|
fn window_ime_allowed(window_handle : NativeWindow) -> Bool {
  window_ime_allowed_state(native_window_identity(window_handle))
}

///|
fn window_ime_cursor_x(window_handle : NativeWindow) -> Int {
  window_ime_cursor_x_state(native_window_identity(window_handle))
}

///|
fn window_ime_cursor_y(window_handle : NativeWindow) -> Int {
  window_ime_cursor_y_state(native_window_identity(window_handle))
}

///|
fn window_ime_cursor_width(window_handle : NativeWindow) -> Int {
  window_ime_cursor_width_state(native_window_identity(window_handle))
}

///|
fn window_ime_cursor_height(window_handle : NativeWindow) -> Int {
  window_ime_cursor_height_state(native_window_identity(window_handle))
}

///|
fn window_surface_width(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    800
  } else {
    native_window_content_width(window_handle)
  }
}

///|
fn window_surface_height(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    600
  } else {
    native_window_content_height(window_handle)
  }
}

///|
fn window_min_surface_width(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_min_content_width(window_handle)
  }
}

///|
fn window_min_surface_height(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_min_content_height(window_handle)
  }
}

///|
fn window_max_surface_width(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_max_content_width(window_handle)
  }
}

///|
fn window_max_surface_height(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_max_content_height(window_handle)
  }
}

///|
fn window_outer_width(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    window_surface_width(window_handle)
  } else {
    native_window_outer_width(window_handle)
  }
}

///|
fn window_outer_height(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    window_surface_height(window_handle)
  } else {
    native_window_outer_height(window_handle)
  }
}

///|
fn window_surface_x(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_surface_x(window_handle)
  }
}

///|
fn window_surface_y(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_surface_y(window_handle)
  }
}

///|
fn window_safe_area_top(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_safe_area_top(window_handle)
  }
}

///|
fn window_safe_area_left(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_safe_area_left(window_handle)
  }
}

///|
fn window_safe_area_bottom(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_safe_area_bottom(window_handle)
  }
}

///|
fn window_safe_area_right(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_safe_area_right(window_handle)
  }
}

///|
fn window_resize_increment_width(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_resize_increment_width(window_handle)
  }
}

///|
fn window_resize_increment_height(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_resize_increment_height(window_handle)
  }
}

///|
fn window_x(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_x(window_handle)
  }
}

///|
fn window_y(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_y(window_handle)
  }
}

///|
fn window_theme(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_theme(window_handle)
  }
}

///|
fn window_has_shadow(window_handle : NativeWindow) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_has_shadow(window_handle)
  }
}

///|
fn window_document_edited(window_handle : NativeWindow) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_document_edited(window_handle)
  }
}

///|
fn window_level_value(window_handle : NativeWindow) -> @core.WindowLevel {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    Normal
  } else {
    window_level_from_native(native_window_level(window_handle))
  }
}

///|
fn window_option_as_alt(window_handle : NativeWindow) -> @core.OptionAsAlt {
  option_as_alt_from_native(
    window_option_as_alt_native(native_window_identity(window_handle)),
  )
}

///|
fn window_enabled_buttons(window_handle : NativeWindow) -> @core.WindowButtons {
  let native_handle = registered_native_handle(window_handle)
  let bits = if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_enabled_buttons_mask(window_handle)
  }
  @core.WindowButtons::none()
  .with_close((bits & 1) != 0)
  .with_minimize((bits & 2) != 0)
  .with_maximize((bits & 4) != 0)
}

///|
fn window_content_protected(window_handle : NativeWindow) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_content_protected(window_handle)
  }
}

///|
fn window_has_focus(window_handle : NativeWindow) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_has_focus(window_handle)
  }
}

///|
fn window_occluded(window_handle : NativeWindow) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_occluded(window_handle)
  }
}

///|
fn window_minimized(window_handle : NativeWindow) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_minimized(window_handle)
  }
}

///|
fn window_maximized(window_handle : NativeWindow) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_maximized(window_handle)
  }
}

///|
fn window_fullscreen(window_handle : NativeWindow) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_fullscreen(window_handle)
  }
}

///|
fn window_num_tabs(window_handle : NativeWindow) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    1
  } else {
    native_window_num_tabs(window_handle)
  }
}

///|
fn window_style_mask_bits(window_handle : NativeWindow) -> UInt64 {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    (0 : Int).to_uint64()
  } else {
    native_window_style_mask(window_handle)
  }
}

///|
fn set_window_style_mask_bits(
  window_handle : NativeWindow,
  style_mask : UInt64,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_style_mask(window_handle, style_mask)
  }
}

///|
fn clear_window_style_mask_bits(
  window_handle : NativeWindow,
  style_mask : UInt64,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_clear_style_mask_bits(window_handle, style_mask)
  }
}

///|
fn set_window_movable(window_handle : NativeWindow, movable : Bool) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_movable(window_handle, movable)
  }
}

///|
fn window_current_monitor_id(window_handle : NativeWindow) -> UInt64 {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    (0 : Int).to_uint64()
  } else {
    native_window_current_monitor_id(window_handle)
  }
}

///|
pub fn Window::surface_size(self : Window) -> @dpi.PhysicalSize {
  self.maybe_wait_on_main(fn(window) {
    @dpi.LogicalSize::LogicalSize(
      window_surface_width(window.raw_window_handle).to_double(),
      window_surface_height(window.raw_window_handle).to_double(),
    ).to_physical(window.scale_factor())
  })
}

///|
pub fn Window::inner_size(self : Window) -> @dpi.PhysicalSize {
  self.maybe_wait_on_main(fn(window) { window.surface_size() })
}

///|
pub fn Window::outer_size(self : Window) -> @dpi.PhysicalSize {
  self.maybe_wait_on_main(fn(window) {
    @dpi.LogicalSize::LogicalSize(
      window_outer_width(window.raw_window_handle).to_double(),
      window_outer_height(window.raw_window_handle).to_double(),
    ).to_physical(window.scale_factor())
  })
}

///|
pub fn Window::surface_position(self : Window) -> @dpi.PhysicalPosition {
  self.maybe_wait_on_main(fn(window) {
    @dpi.LogicalPosition::LogicalPosition(
      window_surface_x(window.raw_window_handle).to_double(),
      window_surface_y(window.raw_window_handle).to_double(),
    ).to_physical(window.scale_factor())
  })
}

///|
pub fn Window::inner_position(self : Window) -> @dpi.PhysicalPosition {
  self.maybe_wait_on_main(fn(window) { window.surface_position() })
}

///|
pub fn Window::safe_area(self : Window) -> @dpi.PhysicalInsets {
  self.maybe_wait_on_main(fn(window) {
    let scale_factor = window.scale_factor()
    PhysicalInsets(
      (window_safe_area_top(window.raw_window_handle).to_double() * scale_factor).to_int(),
      (window_safe_area_left(window.raw_window_handle).to_double() *
      scale_factor).to_int(),
      (window_safe_area_bottom(window.raw_window_handle).to_double() *
      scale_factor).to_int(),
      (window_safe_area_right(window.raw_window_handle).to_double() *
      scale_factor).to_int(),
    )
  })
}

///|
pub fn Window::request_surface_size(
  self : Window,
  size : @dpi.Size,
) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) {
    let logical_size = size.to_logical(window.scale_factor())
    set_surface_size(
      window.raw_window_handle,
      logical_size.width().to_int(),
      logical_size.height().to_int(),
    )
    None
  })
}

///|
pub fn Window::request_inner_size(
  self : Window,
  size : @dpi.Size,
) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) { window.request_surface_size(size) })
}

///|
pub fn Window::set_surface_resize_increments(
  self : Window,
  size : @dpi.Size?,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    match size {
      Some(size) => {
        let logical_size = size.to_logical(window.scale_factor())
        set_surface_resize_increments(
          window.raw_window_handle,
          logical_size.width().to_int(),
          logical_size.height().to_int(),
        )
      }
      None => set_surface_resize_increments(window.raw_window_handle, 0, 0)
    }
  })
}

///|
pub fn Window::set_resize_increments(self : Window, size : @dpi.Size?) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.set_surface_resize_increments(size)
  })
}

///|
pub fn Window::surface_resize_increments(self : Window) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) {
    let width = window_resize_increment_width(window.raw_window_handle)
    let height = window_resize_increment_height(window.raw_window_handle)
    if width > 0 && height > 0 {
      Some(
        @dpi.LogicalSize::LogicalSize(width.to_double(), height.to_double()).to_physical(
          window.scale_factor(),
        ),
      )
    } else {
      None
    }
  })
}

///|
pub fn Window::resize_increments(self : Window) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) { window.surface_resize_increments() })
}

///|
pub fn Window::set_min_surface_size(self : Window, size : @dpi.Size?) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    match size {
      Some(size) => {
        let logical_size = size.to_logical(window.scale_factor())
        set_min_surface_size(
          window.raw_window_handle,
          logical_size.width().to_int(),
          logical_size.height().to_int(),
        )
      }
      None => set_min_surface_size(window.raw_window_handle, 0, 0)
    }
  })
}

///|
pub fn Window::set_min_inner_size(self : Window, size : @dpi.Size?) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_min_surface_size(size) })
}

///|
pub fn Window::set_max_surface_size(self : Window, size : @dpi.Size?) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    match size {
      Some(size) => {
        let logical_size = size.to_logical(window.scale_factor())
        set_max_surface_size(
          window.raw_window_handle,
          logical_size.width().to_int(),
          logical_size.height().to_int(),
        )
      }
      None => set_max_surface_size(window.raw_window_handle, 0, 0)
    }
  })
}

///|
pub fn Window::set_max_inner_size(self : Window, size : @dpi.Size?) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_max_surface_size(size) })
}

///|
pub fn Window::min_surface_size(self : Window) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) {
    let width = window_min_surface_width(window.raw_window_handle)
    let height = window_min_surface_height(window.raw_window_handle)
    if width > 0 && height > 0 {
      Some(
        @dpi.LogicalSize::LogicalSize(width.to_double(), height.to_double()).to_physical(
          window.scale_factor(),
        ),
      )
    } else {
      None
    }
  })
}

///|
pub fn Window::min_inner_size(self : Window) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) { window.min_surface_size() })
}

///|
pub fn Window::max_surface_size(self : Window) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) {
    let width = window_max_surface_width(window.raw_window_handle)
    let height = window_max_surface_height(window.raw_window_handle)
    if width > 0 && height > 0 {
      Some(
        @dpi.LogicalSize::LogicalSize(width.to_double(), height.to_double()).to_physical(
          window.scale_factor(),
        ),
      )
    } else {
      None
    }
  })
}

///|
pub fn Window::max_inner_size(self : Window) -> @dpi.PhysicalSize? {
  self.maybe_wait_on_main(fn(window) { window.max_surface_size() })
}

///|
pub fn Window::outer_position(
  self : Window,
) -> @dpi.PhysicalPosition raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(
    window,
  ) -> @dpi.PhysicalPosition raise @core.RequestError {
    let raw_id = window.raw_window_handle
    if native_window_objc_handle(raw_id) == (0 : Int).to_uint64() {
      raise Ignored
    }
    @dpi.LogicalPosition::LogicalPosition(
      window_x(raw_id).to_double(),
      window_y(raw_id).to_double(),
    ).to_physical(window.scale_factor())
  })
}

///|
pub fn Window::set_outer_position(
  self : Window,
  position : @dpi.Position,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    let logical_position = window_position_to_logical(
      position,
      window.scale_factor(),
    )
    set_window_position(
      window.raw_window_handle,
      logical_position.x().to_int(),
      logical_position.y().to_int(),
    )
  })
}

///|
pub fn Window::focus_window(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    let raw_id = window.raw_window_handle
    let is_minimized = window_minimized(raw_id)
    let is_visible = native_window_is_visible(raw_id)
    if is_minimized == false && is_visible {
      focus_window(raw_id)
    }
  })
}

///|
pub fn Window::has_focus(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    window_has_focus(window.raw_window_handle)
  })
}

///|
pub fn Window::set_minimized(self : Window, minimized : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_window_minimized(window.raw_window_handle, minimized)
  })
}

///|
pub fn Window::is_minimized(self : Window) -> Bool? {
  self.maybe_wait_on_main(fn(window) {
    Some(window_minimized(window.raw_window_handle))
  })
}

///|
pub fn Window::set_maximized(self : Window, maximized : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_window_maximized(window.raw_window_handle, maximized)
  })
}

///|
pub fn Window::is_maximized(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    window_maximized(window.raw_window_handle)
  })
}

///|
pub fn Window::is_decorated(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    native_window_is_decorated(window.raw_window_handle)
  })
}

///|
pub fn Window::enabled_buttons(self : Window) -> @core.WindowButtons {
  self.maybe_wait_on_main(fn(window) {
    window_enabled_buttons(window.raw_window_handle)
  })
}

///|
pub fn Window::is_blurred(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.blur_state })
}

///|
pub fn Window::set_transparent(self : Window, transparent : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_window_transparent(window.raw_window_handle, transparent)
  })
}

///|
pub fn Window::is_transparent(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    window_transparent(window.raw_window_handle)
  })
}

///|
pub fn Window::set_window_level(
  self : Window,
  level : @core.WindowLevel,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_window_level(
      window.raw_window_handle,
      normalize_window_level_native(window_level_to_native(level)),
    )
  })
}

///|
pub fn Window::window_level(self : Window) -> @core.WindowLevel {
  self.maybe_wait_on_main(fn(window) {
    window_level_value(window.raw_window_handle)
  })
}

///|
pub fn Window::scale_factor(self : Window) -> Double {
  self.maybe_wait_on_main(fn(window) {
    if window.disallow_hidpi_state {
      1.0
    } else {
      native_window_scale_factor(window.raw_window_handle)
    }
  })
}

///|
pub fn Window::request_redraw(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    app_state_queue_redraw(window.id.into_raw())
  })
}

///|
pub fn Window::pre_present_notify(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(_window) { () })
}

///|
pub fn Window::reset_dead_keys(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(_window) { () })
}

///|
pub fn Window::set_title(self : Window, title : String) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_title(window.raw_window_handle, title)
  })
}

///|
pub fn Window::title(self : Window) -> String {
  self.maybe_wait_on_main(fn(window) { window_title(window.raw_window_handle) })
}

///|
pub fn Window::set_window_icon(
  self : Window,
  _window_icon : @core.Icon?,
) -> Unit {
  self.maybe_wait_on_main(fn(_window) { () })
}

///|
pub fn Window::set_content_protected(
  self : Window,
  content_protected : Bool,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_window_content_protected(window.raw_window_handle, content_protected)
  })
}

///|
pub fn Window::set_visible(self : Window, visible : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    native_set_visible(window.raw_window_handle, visible)
  })
}

///|
pub fn Window::is_visible(self : Window) -> Bool? {
  self.maybe_wait_on_main(fn(window) {
    Some(native_window_is_visible(window.raw_window_handle))
  })
}

///|
pub fn Window::set_resizable(self : Window, resizable : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    native_set_resizable(window.raw_window_handle, resizable)
  })
}

///|
pub fn Window::is_resizable(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    native_window_is_resizable(window.raw_window_handle)
  })
}

///|
pub fn Window::is_content_protected(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    window_content_protected(window.raw_window_handle)
  })
}

///|
pub fn Window::is_document_edited(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    window_document_edited(window.raw_window_handle)
  })
}

///|
pub fn Window::set_document_edited(self : Window, edited : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_window_document_edited(window.raw_window_handle, edited)
  })
}

///|
pub fn Window::set_option_as_alt(
  self : Window,
  option_as_alt : @core.OptionAsAlt,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_window_option_as_alt(
      window.raw_window_handle,
      normalize_option_as_alt_native(option_as_alt_to_native(option_as_alt)),
    )
  })
}

///|
pub fn Window::option_as_alt(self : Window) -> @core.OptionAsAlt {
  self.maybe_wait_on_main(fn(window) {
    window_option_as_alt(window.raw_window_handle)
  })
}

///|
pub fn Window::set_prefers_home_indicator_hidden(
  self : Window,
  hidden : Bool,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    // AppKit has no home-indicator API; keep state for cross-platform parity.
    window.prefers_home_indicator_hidden_state = hidden
  })
}

///|
pub fn Window::set_prefers_status_bar_hidden(
  self : Window,
  hidden : Bool,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    // AppKit has no status-bar API; keep state for cross-platform parity.
    window.prefers_status_bar_hidden_state = hidden
  })
}

///|
pub fn Window::set_preferred_screen_edges_deferring_system_gestures(
  self : Window,
  edges : @core.ScreenEdge,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    // AppKit has no system-gesture deferral API; keep state for parity.
    window.preferred_screen_edges_deferring_system_gestures_state = edges
  })
}

///|
pub fn Window::request_user_attention(
  self : Window,
  request_type : @core.UserAttentionType?,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    request_user_attention(
      window.raw_window_handle,
      user_attention_type_to_native(request_type),
    )
  })
}

///|
pub fn Window::current_monitor(self : Window) -> @core.MonitorHandle? {
  self.maybe_wait_on_main(fn(window) {
    let monitor_id = window_current_monitor_id(window.raw_window_handle)
    if monitor_id == (0 : Int).to_uint64() {
      None
    } else {
      monitor_from_native_id(monitor_id)
    }
  })
}

///|
pub fn Window::available_monitors(self : Window) -> Array[@core.MonitorHandle] {
  self.maybe_wait_on_main(fn(window) {
    let _ = window
    available_monitors()
  })
}

///|
pub fn Window::primary_monitor(self : Window) -> @core.MonitorHandle? {
  self.maybe_wait_on_main(fn(window) {
    let _ = window
    Some(primary_monitor())
  })
}

///|
pub fn Window::set_unified_titlebar(
  self : Window,
  unified_titlebar : Bool,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.unified_titlebar_state = unified_titlebar
    set_window_unified_titlebar(window.raw_window_handle, unified_titlebar)
  })
}

///|
pub fn Window::unified_titlebar(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.unified_titlebar_state })
}

///|
pub fn Window::set_tabbing_identifier(
  self : Window,
  identifier : String,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_window_tabbing_identifier(window.raw_window_handle, identifier)
  })
}

///|
pub fn Window::tabbing_identifier(self : Window) -> String {
  self.maybe_wait_on_main(fn(window) {
    window_tabbing_identifier(window.raw_window_handle)
  })
}

///|
pub fn Window::select_next_tab(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    select_window_next_tab(window.raw_window_handle)
  })
}

///|
pub fn Window::select_previous_tab(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    select_window_previous_tab(window.raw_window_handle)
  })
}

///|
pub fn Window::select_tab_at_index(self : Window, index : Int) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    if index >= 0 {
      select_window_tab_at_index(window.raw_window_handle, index)
    }
  })
}

///|
pub fn Window::num_tabs(self : Window) -> Int {
  self.maybe_wait_on_main(fn(window) {
    window_num_tabs(window.raw_window_handle)
  })
}

///|
pub fn Window::set_decorations(self : Window, decorations : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.toggle_window_decorations(decorations)
  })
}

///|
fn Window::toggle_window_decorations(self : Window, decorations : Bool) -> Unit {
  set_window_decorations(self.raw_window_handle, decorations)
}

///|
pub fn Window::set_enabled_buttons(
  self : Window,
  buttons : @core.WindowButtons,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_window_enabled_buttons(
      window.raw_window_handle,
      buttons.close(),
      buttons.minimize(),
      buttons.maximize(),
    )
  })
}

///|
pub fn Window::set_blur(self : Window, blur : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.blur_state = blur
    set_window_blur(window.raw_window_handle, blur)
  })
}

///|
pub fn Window::has_shadow(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    window_has_shadow(window.raw_window_handle)
  })
}

///|
pub fn Window::set_has_shadow(self : Window, has_shadow : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_window_has_shadow(window.raw_window_handle, has_shadow)
  })
}

///|
pub fn Window::set_theme(self : Window, theme : @core.Theme?) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_window_theme(window.raw_window_handle, theme_to_native(theme))
  })
}

///|
pub fn Window::theme(self : Window) -> @core.Theme? {
  self.maybe_wait_on_main(fn(window) {
    theme_from_native(window_theme(window.raw_window_handle))
  })
}

///|
pub fn Window::is_occluded(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    window_occluded(window.raw_window_handle)
  })
}
