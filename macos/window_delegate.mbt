///|
// Port target: winit-reference/winit-appkit/src/window_delegate.rs
let next_synthetic_handle : Ref[UInt64] = Ref::new((1 : Int).to_uint64())

///|
priv struct SyntheticWindow {
  native_handle : UInt64
  mut title : String
  mut tabbing_identifier : String
  mut width : Int
  mut height : Int
  mut visible : Bool
  mut min_width : Int
  mut min_height : Int
  mut max_width : Int
  mut max_height : Int
  mut resize_increment_width : Int
  mut resize_increment_height : Int
  mut num_tabs : Int
  mut disallow_hidpi : Bool
  mut exclusive_display_id : UInt64
}

///|
let synthetic_window_handles : Ref[Array[UInt64]] = Ref::new([])

///|
let synthetic_windows : Ref[Array[SyntheticWindow]] = Ref::new([])

///|
let synthetic_presentation_options : Ref[UInt64] = Ref::new(
  (0 : Int).to_uint64(),
)

///|
fn allocate_synthetic_handle() -> UInt64 {
  let handle = next_synthetic_handle.val
  next_synthetic_handle.val = handle + (1 : Int).to_uint64()
  handle
}

///|
fn synthetic_window_index(window_handle : UInt64) -> Int? {
  synthetic_window_handles.val.search_by(handle => handle == window_handle)
}

///|
fn synthetic_window(window_handle : UInt64) -> SyntheticWindow? {
  match synthetic_window_index(window_handle) {
    Some(index) => Some(synthetic_windows.val[index])
    None => None
  }
}

///|
fn synthetic_native_handle(window_handle : UInt64) -> UInt64 {
  match synthetic_window(window_handle) {
    Some(window) => window.native_handle
    None => (0 : Int).to_uint64()
  }
}

///|
fn synthetic_update_window(
  window_handle : UInt64,
  f : (SyntheticWindow) -> Unit,
) -> Unit {
  match synthetic_window_index(window_handle) {
    Some(index) => {
      let window = synthetic_windows.val[index]
      f(window)
      synthetic_windows.val[index] = window
    }
    None => ()
  }
}

///|
fn clamp_size(size : Int) -> Int {
  if size <= 0 {
    1
  } else {
    size
  }
}

///|
fn window_title(window_handle : UInt64) -> String {
  match synthetic_window(window_handle) {
    Some(window) => window.title
    None => ""
  }
}

///|
fn window_tabbing_identifier(window_handle : UInt64) -> String {
  match synthetic_window(window_handle) {
    Some(window) => window.tabbing_identifier
    None => ""
  }
}

///|
fn is_main_thread() -> Bool {
  pthread_is_main_thread()
}

///|
fn create_window(
  raw_id : Int,
  width : Int,
  height : Int,
  visible : Bool,
  active : Bool,
  resizable : Bool,
  decorations : Bool,
  panel : Bool,
  title : String,
) -> UInt64 {
  let initial_width = clamp_size(width)
  let initial_height = clamp_size(height)
  let native_handle = native_create_window(
    raw_id, initial_width, initial_height, visible, active, resizable, decorations,
    panel, title,
  )
  if native_handle == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let handle = allocate_synthetic_handle()
  synthetic_window_handles.val.push(handle)
  synthetic_windows.val.push({
    native_handle,
    title,
    tabbing_identifier: "",
    width: initial_width,
    height: initial_height,
    visible,
    min_width: 0,
    min_height: 0,
    max_width: 0,
    max_height: 0,
    resize_increment_width: 0,
    resize_increment_height: 0,
    num_tabs: 1,
    disallow_hidpi: false,
    exclusive_display_id: (0 : Int).to_uint64(),
  })
  handle
}

///|
fn close_window(window_handle : UInt64) -> Unit {
  match synthetic_window_index(window_handle) {
    Some(index) => {
      let window = synthetic_windows.val[index]
      native_close_window(window.native_handle)
      ignore(synthetic_window_handles.val.remove(index))
      ignore(synthetic_windows.val.remove(index))
    }
    None => ()
  }
}

///|
fn show_window(window_handle : UInt64, active : Bool) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_show_window(window.native_handle, active)
    window.visible = true
  })
}

///|
fn native_set_visible(window_handle : UInt64, visible : Bool) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_visible(window.native_handle, visible)
    window.visible = visible
  })
}

///|
fn native_set_resizable(window_handle : UInt64, resizable : Bool) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_resizable(window.native_handle, resizable)
  })
}

///|
fn set_title(window_handle : UInt64, title : String) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_title(window.native_handle, title)
    window.title = title
  })
}

///|
fn focus_window(window_handle : UInt64) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    if window.visible {
      native_window_focus(window.native_handle)
    }
  })
}

///|
fn request_user_attention(window_handle : UInt64, request_type : Int) -> Unit {
  let _ = window_handle
  native_window_request_user_attention(request_type)
}

///|
fn set_surface_size(window_handle : UInt64, width : Int, height : Int) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    window.width = clamp_size(width)
    window.height = clamp_size(height)
    native_window_set_content_size(
      window.native_handle,
      window.width,
      window.height,
    )
  })
}

///|
fn set_surface_resize_increments(
  window_handle : UInt64,
  width : Int,
  height : Int,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    window.resize_increment_width = if width > 0 { width } else { 0 }
    window.resize_increment_height = if height > 0 { height } else { 0 }
  })
}

///|
fn set_min_surface_size(
  window_handle : UInt64,
  width : Int,
  height : Int,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    window.min_width = if width > 0 { width } else { 0 }
    window.min_height = if height > 0 { height } else { 0 }
  })
}

///|
fn set_max_surface_size(
  window_handle : UInt64,
  width : Int,
  height : Int,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    window.max_width = if width > 0 { width } else { 0 }
    window.max_height = if height > 0 { height } else { 0 }
  })
}

///|
fn set_window_position(window_handle : UInt64, x : Int, y : Int) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_position(window.native_handle, x, y)
  })
}

///|
fn set_window_outer_size(
  window_handle : UInt64,
  width : Int,
  height : Int,
) -> Unit {
  set_surface_size(window_handle, width, height)
}

///|
fn set_window_minimized(window_handle : UInt64, minimized : Bool) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_minimized(window.native_handle, minimized)
  })
}

///|
fn set_window_maximized(window_handle : UInt64, maximized : Bool) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_maximized(window.native_handle, maximized)
  })
}

///|
fn set_window_fullscreen(window_handle : UInt64, fullscreen : Bool) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_fullscreen(window.native_handle, fullscreen)
  })
}

///|
fn set_window_decorations(window_handle : UInt64, decorated : Bool) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    let style_mask = if decorated {
      (0x1 : Int).to_uint64()
    } else {
      (0 : Int).to_uint64()
    }
    native_window_set_style_mask(window.native_handle, style_mask)
  })
}

///|
fn set_window_enabled_buttons(
  window_handle : UInt64,
  close : Bool,
  minimize : Bool,
  maximize : Bool,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_enabled_buttons(
      window.native_handle,
      close,
      minimize,
      maximize,
    )
  })
}

///|
fn set_window_blur(window_handle : UInt64, blur : Bool) -> Unit {
  let _ = window_handle
  let _ = blur
}

///|
fn set_window_accepts_first_mouse(
  window_handle : UInt64,
  accepts_first_mouse : Bool,
) -> Unit {
  let _ = window_handle
  let _ = accepts_first_mouse
}

///|
fn set_window_disallow_hidpi(
  window_handle : UInt64,
  disallow_hidpi : Bool,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    window.disallow_hidpi = disallow_hidpi
  })
}

///|
fn set_window_movable_by_window_background(
  window_handle : UInt64,
  movable_by_window_background : Bool,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_movable_by_background(
      window.native_handle,
      movable_by_window_background,
    )
  })
}

///|
fn set_window_titlebar_transparent(
  window_handle : UInt64,
  titlebar_transparent : Bool,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_titlebar_transparent(
      window.native_handle,
      titlebar_transparent,
    )
  })
}

///|
fn set_window_title_hidden(window_handle : UInt64, title_hidden : Bool) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_title_hidden(window.native_handle, title_hidden)
  })
}

///|
fn set_window_titlebar_hidden(
  window_handle : UInt64,
  titlebar_hidden : Bool,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_titlebar_hidden(window.native_handle, titlebar_hidden)
  })
}

///|
fn set_window_titlebar_buttons_hidden(
  window_handle : UInt64,
  titlebar_buttons_hidden : Bool,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_titlebar_buttons_hidden(
      window.native_handle,
      titlebar_buttons_hidden,
    )
  })
}

///|
fn set_window_fullsize_content_view(
  window_handle : UInt64,
  fullsize_content_view : Bool,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_fullsize_content_view(
      window.native_handle,
      fullsize_content_view,
    )
  })
}

///|
fn set_window_has_shadow(window_handle : UInt64, has_shadow : Bool) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_has_shadow(window.native_handle, has_shadow)
  })
}

///|
fn set_window_document_edited(window_handle : UInt64, edited : Bool) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_document_edited(window.native_handle, edited)
  })
}

///|
fn set_window_borderless_game(
  window_handle : UInt64,
  borderless_game : Bool,
) -> Unit {
  let _ = window_handle
  let _ = borderless_game
}

///|
fn set_window_unified_titlebar(
  window_handle : UInt64,
  unified_titlebar : Bool,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_unified_titlebar(window.native_handle, unified_titlebar)
  })
}

///|
fn set_window_tabbing_identifier(
  window_handle : UInt64,
  identifier : String,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_tabbing_identifier(window.native_handle, identifier)
    window.tabbing_identifier = identifier
  })
}

///|
fn set_window_tabbing_mode_preferred(window_handle : UInt64) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_tabbing_mode_preferred(window.native_handle)
    if window.num_tabs <= 0 {
      window.num_tabs = 1
    }
  })
}

///|
fn select_window_next_tab(window_handle : UInt64) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_select_next_tab(window.native_handle)
  })
}

///|
fn select_window_previous_tab(window_handle : UInt64) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_select_previous_tab(window.native_handle)
  })
}

///|
fn select_window_tab_at_index(window_handle : UInt64, index : Int) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_select_tab_at_index(window.native_handle, index)
    if index >= 0 && window.num_tabs <= index {
      window.num_tabs = index + 1
    }
  })
}

///|
fn set_window_option_as_alt(
  window_handle : UInt64,
  option_as_alt : Int,
) -> Unit {
  let _ = window_handle
  let _ = option_as_alt
}

///|
fn set_window_cursor(window_handle : UInt64, cursor : Int) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_cursor(window.native_handle, cursor)
  })
}

///|
fn set_window_custom_cursor(
  window_handle : UInt64,
  custom_cursor : UInt64,
) -> Bool {
  match synthetic_window(window_handle) {
    Some(window) =>
      native_window_set_custom_cursor(window.native_handle, custom_cursor)
    None => false
  }
}

///|
fn set_parent_window(window_handle : UInt64, parent_window : UInt64) -> Bool {
  let native_handle = synthetic_native_handle(window_handle)
  let parent_handle = match synthetic_window(parent_window) {
    Some(parent) => parent.native_handle
    None => parent_window
  }
  if native_handle == (0 : Int).to_uint64() ||
    parent_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_set_parent(native_handle, parent_handle)
    true
  }
}

///|
fn set_window_cursor_visible(window_handle : UInt64, visible : Bool) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_cursor_visible(window.native_handle, visible)
  })
}

///|
fn set_window_cursor_hittest(window_handle : UInt64, hittest : Bool) -> Bool {
  match synthetic_window(window_handle) {
    Some(window) =>
      native_window_set_cursor_hittest(window.native_handle, hittest)
    None => false
  }
}

///|
fn set_cursor_position(window_handle : UInt64, x : Int, y : Int) -> Bool {
  match synthetic_window(window_handle) {
    Some(window) =>
      native_window_set_cursor_position(window.native_handle, x, y)
    None => false
  }
}

///|
fn set_cursor_grab(window_handle : UInt64, mode : Int) -> Bool {
  match synthetic_window(window_handle) {
    Some(window) => native_window_set_cursor_grab(window.native_handle, mode)
    None => false
  }
}

///|
fn drag_window(window_handle : UInt64) -> Bool {
  match synthetic_window(window_handle) {
    Some(window) => native_window_drag_window(window.native_handle)
    None => false
  }
}

///|
fn drag_resize_window(window_handle : UInt64, direction : Int) -> Bool {
  match synthetic_window(window_handle) {
    Some(window) =>
      native_window_drag_resize_window(window.native_handle, direction)
    None => false
  }
}

///|
fn show_window_menu(window_handle : UInt64, x : Int, y : Int) -> Bool {
  match synthetic_window(window_handle) {
    Some(window) => native_window_show_window_menu(window.native_handle, x, y)
    None => false
  }
}

///|
fn set_window_transparent(window_handle : UInt64, transparent : Bool) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_transparent(window.native_handle, transparent)
  })
}

///|
fn set_window_level(window_handle : UInt64, level : Int) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_level(window.native_handle, level)
  })
}

///|
fn set_window_theme(window_handle : UInt64, theme : Int) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_theme(window.native_handle, theme)
  })
}

///|
fn set_window_content_protected(
  window_handle : UInt64,
  content_protected : Bool,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_content_protected(window.native_handle, content_protected)
  })
}

///|
fn set_ime_purpose(window_handle : UInt64, purpose : Int) -> Unit {
  let _ = window_handle
  let _ = purpose
}

///|
fn set_ime_hints(window_handle : UInt64, hints : Int) -> Unit {
  let _ = window_handle
  let _ = hints
}

///|
fn set_ime_allowed(window_handle : UInt64, allowed : Bool) -> Unit {
  let _ = window_handle
  let _ = allowed
}

///|
fn set_ime_cursor_area(
  window_handle : UInt64,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Unit {
  let _ = window_handle
  let _ = x
  let _ = y
  let _ = width
  let _ = height
}

///|
fn native_window_width(window_handle : UInt64) -> Int {
  let native_handle = synthetic_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    800
  } else {
    native_window_content_width(native_handle)
  }
}

///|
fn native_window_height(window_handle : UInt64) -> Int {
  let native_handle = synthetic_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    600
  } else {
    native_window_content_height(native_handle)
  }
}

///|
fn window_min_surface_width(window_handle : UInt64) -> Int {
  match synthetic_window(window_handle) {
    Some(window) => window.min_width
    None => 0
  }
}

///|
fn window_min_surface_height(window_handle : UInt64) -> Int {
  match synthetic_window(window_handle) {
    Some(window) => window.min_height
    None => 0
  }
}

///|
fn window_max_surface_width(window_handle : UInt64) -> Int {
  match synthetic_window(window_handle) {
    Some(window) => window.max_width
    None => 0
  }
}

///|
fn window_max_surface_height(window_handle : UInt64) -> Int {
  match synthetic_window(window_handle) {
    Some(window) => window.max_height
    None => 0
  }
}

///|
fn window_outer_width(window_handle : UInt64) -> Int {
  native_window_width(window_handle)
}

///|
fn window_outer_height(window_handle : UInt64) -> Int {
  native_window_height(window_handle)
}

///|
fn window_surface_x(window_handle : UInt64) -> Int {
  let native_handle = synthetic_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_x(native_handle)
  }
}

///|
fn window_surface_y(window_handle : UInt64) -> Int {
  let native_handle = synthetic_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_y(native_handle)
  }
}

///|
fn window_safe_area_top(window_handle : UInt64) -> Int {
  let _ = window_handle
  0
}

///|
fn window_safe_area_left(window_handle : UInt64) -> Int {
  let _ = window_handle
  0
}

///|
fn window_safe_area_bottom(window_handle : UInt64) -> Int {
  let _ = window_handle
  0
}

///|
fn window_safe_area_right(window_handle : UInt64) -> Int {
  let _ = window_handle
  0
}

///|
fn window_resize_increment_width(window_handle : UInt64) -> Int {
  match synthetic_window(window_handle) {
    Some(window) => window.resize_increment_width
    None => 0
  }
}

///|
fn window_resize_increment_height(window_handle : UInt64) -> Int {
  match synthetic_window(window_handle) {
    Some(window) => window.resize_increment_height
    None => 0
  }
}

///|
fn window_x(window_handle : UInt64) -> Int {
  window_surface_x(window_handle)
}

///|
fn window_y(window_handle : UInt64) -> Int {
  window_surface_y(window_handle)
}

///|
fn window_theme(window_handle : UInt64) -> Int {
  let native_handle = synthetic_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_theme(native_handle)
  }
}

///|
fn window_has_focus(window_handle : UInt64) -> Bool {
  let native_handle = synthetic_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_has_focus(native_handle)
  }
}

///|
fn window_occluded(window_handle : UInt64) -> Bool {
  let native_handle = synthetic_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_occluded(native_handle)
  }
}

///|
fn window_minimized(window_handle : UInt64) -> Bool {
  let native_handle = synthetic_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_minimized(native_handle)
  }
}

///|
fn window_maximized(window_handle : UInt64) -> Bool {
  let native_handle = synthetic_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_maximized(native_handle)
  }
}

///|
fn window_fullscreen(window_handle : UInt64) -> Bool {
  let native_handle = synthetic_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_fullscreen(native_handle)
  }
}

///|
fn window_num_tabs(window_handle : UInt64) -> Int {
  let native_handle = synthetic_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    1
  } else {
    native_window_num_tabs(native_handle)
  }
}

///|
fn window_style_mask_bits(window_handle : UInt64) -> UInt64 {
  let native_handle = synthetic_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    (0 : Int).to_uint64()
  } else {
    native_window_style_mask(native_handle)
  }
}

///|
fn set_window_style_mask_bits(
  window_handle : UInt64,
  style_mask : UInt64,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_style_mask(window.native_handle, style_mask)
  })
}

///|
fn clear_window_style_mask_bits(
  window_handle : UInt64,
  style_mask : UInt64,
) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_clear_style_mask_bits(window.native_handle, style_mask)
  })
}

///|
fn set_window_movable(window_handle : UInt64, movable : Bool) -> Unit {
  synthetic_update_window(window_handle, fn(window) {
    native_window_set_movable(window.native_handle, movable)
  })
}

///|
fn application_presentation_options() -> UInt64 {
  synthetic_presentation_options.val
}

///|
fn set_application_presentation_options(options : UInt64) -> Unit {
  synthetic_presentation_options.val = options
}

///|
fn find_display_mode_handle(
  monitor_id : UInt64,
  width : Int,
  height : Int,
  bit_depth : Int,
  refresh_rate_millihertz : Int,
) -> UInt64 {
  let _ = monitor_id
  let _ = width
  let _ = height
  let _ = bit_depth
  let _ = refresh_rate_millihertz
  allocate_synthetic_handle()
}

///|
fn copy_current_display_mode_handle(monitor_id : UInt64) -> UInt64 {
  let _ = monitor_id
  allocate_synthetic_handle()
}

///|
fn release_display_mode_handle(mode_handle : UInt64) -> Unit {
  let _ = mode_handle
}

///|
fn capture_display(monitor_id : UInt64) -> Bool {
  let _ = monitor_id
  true
}

///|
fn set_display_mode_handle(monitor_id : UInt64, mode_handle : UInt64) -> Bool {
  let _ = monitor_id
  let _ = mode_handle
  true
}

///|
fn release_display_capture(monitor_id : UInt64) -> Bool {
  let _ = monitor_id
  true
}

///|
fn set_window_exclusive_runtime_state(
  window_handle : UInt64,
  exclusive_fullscreen : Bool,
  display_id : UInt64,
  saved_mode_handle : UInt64,
) -> Unit {
  let _ = exclusive_fullscreen
  let _ = saved_mode_handle
  synthetic_update_window(window_handle, fn(window) {
    window.exclusive_display_id = display_id
  })
}

///|
fn window_current_monitor_id(window_handle : UInt64) -> UInt64 {
  match synthetic_window(window_handle) {
    Some(window) if window.exclusive_display_id != (0 : Int).to_uint64() =>
      window.exclusive_display_id
    _ => cg_main_display_id()
  }
}

///|
fn window_scale_factor(window_handle : UInt64) -> Double {
  match synthetic_window(window_handle) {
    Some(window) =>
      if window.disallow_hidpi {
        1.0
      } else {
        native_window_scale_factor(window.native_handle)
      }
    None => 1.0
  }
}

///|
fn destroyed_window_ids_contains(
  destroyed_window_ids : Array[Int],
  raw_id : Int,
) -> Bool {
  match destroyed_window_ids.search_by(id => id == raw_id) {
    Some(_) => true
    None => false
  }
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_window_events(
  self : EventLoop,
  app : A,
) -> Unit {
  let active = self.as_active()
  dispatch_deferred_callbacks(app, active)
  let destroyed_window_ids = take_destroyed_window_ids()
  if destroyed_window_ids.is_empty() == false {
    let remaining_window_ids : Array[Int] = []
    for raw_id in self.window_ids {
      if destroyed_window_ids_contains(destroyed_window_ids, raw_id) == false {
        remaining_window_ids.push(raw_id)
      }
    }
    self.window_ids = remaining_window_ids
  }
}

///|
// Port target: window_delegate.rs::new
fn new_window(
  event_loop : EventLoop,
  attributes : @core.WindowAttributes,
) -> Window raise @core.RequestError {
  guard is_main_thread() else { raise @core.RequestError::Os }
  let raw_id = event_loop.next_window_id_
  event_loop.next_window_id_ = raw_id + 1
  let scale_factor = match event_loop.primary_monitor() {
    Some(monitor) => monitor.scale_factor()
    None => 1.0
  }
  let size = match attributes.surface_size() {
    Some(size) => size.to_physical(scale_factor)
    None => @dpi.PhysicalSize::new(800, 600)
  }
  let raw_window_handle = create_window(
    raw_id,
    size.width(),
    size.height(),
    attributes.visible(),
    attributes.active(),
    attributes.resizable(),
    attributes.decorations(),
    attributes.platform_attributes().panel(),
    attributes.title(),
  )
  guard raw_window_handle != 0 else { raise @core.RequestError::Ignored }
  match attributes.parent_window() {
    Some(parent_window) => {
      guard set_parent_window(raw_window_handle, parent_window.into_raw()) else {
        close_window(raw_window_handle)
        raise @core.RequestError::Os
      }
    }
    None => ()
  }
  set_window_borderless_game(
    raw_window_handle,
    attributes.platform_attributes().borderless_game(),
  )
  set_window_accepts_first_mouse(
    raw_window_handle,
    attributes.platform_attributes().accepts_first_mouse(),
  )
  set_window_disallow_hidpi(
    raw_window_handle,
    attributes.platform_attributes().disallow_hidpi(),
  )
  set_window_fullsize_content_view(
    raw_window_handle,
    attributes.platform_attributes().fullsize_content_view(),
  )
  set_window_has_shadow(
    raw_window_handle,
    attributes.platform_attributes().has_shadow(),
  )
  set_window_movable_by_window_background(
    raw_window_handle,
    attributes.platform_attributes().movable_by_window_background(),
  )
  set_window_option_as_alt(
    raw_window_handle,
    normalize_option_as_alt_native(
      option_as_alt_to_native(attributes.platform_attributes().option_as_alt()),
    ),
  )
  match attributes.platform_attributes().tabbing_identifier() {
    Some(identifier) => {
      set_window_tabbing_identifier(raw_window_handle, identifier)
      set_window_tabbing_mode_preferred(raw_window_handle)
    }
    None => ()
  }
  set_window_title_hidden(
    raw_window_handle,
    attributes.platform_attributes().title_hidden(),
  )
  set_window_titlebar_hidden(
    raw_window_handle,
    attributes.platform_attributes().titlebar_hidden(),
  )
  set_window_titlebar_buttons_hidden(
    raw_window_handle,
    attributes.platform_attributes().titlebar_buttons_hidden(),
  )
  set_window_titlebar_transparent(
    raw_window_handle,
    attributes.platform_attributes().titlebar_transparent(),
  )
  set_window_unified_titlebar(
    raw_window_handle,
    attributes.platform_attributes().unified_titlebar(),
  )
  set_window_theme(raw_window_handle, theme_to_native(attributes.theme()))
  set_window_content_protected(
    raw_window_handle,
    attributes.content_protected(),
  )
  set_window_blur(raw_window_handle, attributes.blur())
  let mut cursor_state = attributes.cursor()
  match attributes.cursor() {
    @core.Cursor::Icon(icon) =>
      set_window_cursor(raw_window_handle, cursor_icon_to_native(icon))
    @core.Cursor::Custom(custom_cursor) =>
      if set_window_custom_cursor(raw_window_handle, custom_cursor.into_raw()) ==
        false {
        set_window_cursor(
          raw_window_handle,
          cursor_icon_to_native(@core.CursorIcon::Default),
        )
        cursor_state = @core.Cursor::Icon(@core.CursorIcon::Default)
      }
  }
  set_window_cursor_visible(raw_window_handle, attributes.cursor_visible())
  ignore(
    set_window_cursor_hittest(raw_window_handle, attributes.cursor_hittest()),
  )
  let enabled_buttons = attributes.enabled_buttons()
  set_window_enabled_buttons(
    raw_window_handle,
    enabled_buttons.close(),
    enabled_buttons.minimize(),
    enabled_buttons.maximize(),
  )
  match attributes.surface_resize_increments() {
    Some(increments) => {
      let physical_increments = increments.to_physical(scale_factor)
      set_surface_resize_increments(
        raw_window_handle,
        physical_increments.width(),
        physical_increments.height(),
      )
    }
    None => ()
  }
  set_ime_purpose(
    raw_window_handle,
    normalize_ime_purpose_native(
      ime_purpose_to_native(attributes.ime_purpose()),
    ),
  )
  set_ime_hints(
    raw_window_handle,
    normalize_ime_hints_bits(attributes.ime_hints().bits()),
  )
  set_window_level(
    raw_window_handle,
    normalize_window_level_native(
      window_level_to_native(attributes.window_level()),
    ),
  )
  set_window_transparent(raw_window_handle, attributes.transparent())
  match attributes.fullscreen() {
    Some(@core.Fullscreen::Borderless(target_monitor)) => {
      match target_monitor {
        Some(monitor) =>
          set_window_position(
            raw_window_handle,
            monitor.position().x(),
            monitor.position().y(),
          )
        None => ()
      }
      set_window_fullscreen(raw_window_handle, true)
    }
    Some(@core.Fullscreen::Exclusive(_, _)) => ()
    None => ()
  }
  match attributes.min_surface_size() {
    Some(min_size) => {
      let physical_min = min_size.to_physical(scale_factor)
      set_min_surface_size(
        raw_window_handle,
        physical_min.width(),
        physical_min.height(),
      )
    }
    None => ()
  }
  match attributes.max_surface_size() {
    Some(max_size) => {
      let physical_max = max_size.to_physical(scale_factor)
      set_max_surface_size(
        raw_window_handle,
        physical_max.width(),
        physical_max.height(),
      )
    }
    None => ()
  }
  match attributes.position() {
    Some(position) => {
      let physical_position = position.to_physical(scale_factor)
      set_window_position(
        raw_window_handle,
        physical_position.x(),
        physical_position.y(),
      )
    }
    None => ()
  }
  if attributes.visible() {
    show_window(raw_window_handle, attributes.active())
  }
  if attributes.maximized() {
    set_window_maximized(raw_window_handle, true)
  }
  event_loop.window_ids.push(raw_id)
  register_window_handle(raw_id, raw_window_handle)
  let window : Window = {
    id: @core.WindowId::from_raw(raw_id),
    raw_window_handle,
    visible_state: attributes.visible(),
    resizable_state: attributes.resizable(),
    decorated_state: attributes.decorations(),
    enabled_buttons_state: attributes.enabled_buttons(),
    window_level_state: attributes.window_level(),
    cursor_state,
    fullscreen_state: initial_fullscreen_state(attributes),
    ime_capabilities_state: None,
    ime_cursor_area_position_state: @dpi.PhysicalPosition::new(0, 0),
    ime_cursor_area_size_state: @dpi.PhysicalSize::new(1, 1),
    ime_surrounding_text_state: None,
    content_protected_state: attributes.content_protected(),
    blur_state: attributes.blur(),
    has_shadow_state: attributes.platform_attributes().has_shadow(),
    document_edited_state: false,
    option_as_alt_state: attributes.platform_attributes().option_as_alt(),
    borderless_game_state: attributes.platform_attributes().borderless_game(),
    unified_titlebar_state: attributes.platform_attributes().unified_titlebar(),
    cursor_visible_state: attributes.cursor_visible(),
    cursor_hittest_state: attributes.cursor_hittest(),
    transparent_state: attributes.transparent(),
    ime_allowed_state: false,
    ime_purpose_state: attributes.ime_purpose(),
    ime_hints_state: attributes.ime_hints(),
    simple_fullscreen_state: false,
    simple_fullscreen_saved_style_mask_state: None,
    simple_fullscreen_saved_presentation_options_state: None,
    simple_fullscreen_saved_outer_position_state: None,
    simple_fullscreen_saved_outer_size_state: None,
    exclusive_fullscreen_state: false,
    exclusive_fullscreen_display_id_state: None,
    exclusive_fullscreen_saved_mode_state: None,
    exclusive_fullscreen_saved_style_mask_state: None,
    exclusive_fullscreen_saved_outer_position_state: None,
    exclusive_fullscreen_saved_outer_size_state: None,
  }
  match attributes.fullscreen() {
    Some(@core.Fullscreen::Exclusive(target_monitor, video_mode)) =>
      ignore(window.enter_exclusive_fullscreen(target_monitor, video_mode))
    _ => ()
  }
  window
}

///|
pub fn Window::surface_size(self : Window) -> @dpi.PhysicalSize {
  @dpi.PhysicalSize::new(
    native_window_width(self.raw_window_handle),
    native_window_height(self.raw_window_handle),
  )
}

///|
pub fn Window::inner_size(self : Window) -> @dpi.PhysicalSize {
  self.surface_size()
}

///|
pub fn Window::outer_size(self : Window) -> @dpi.PhysicalSize {
  @dpi.PhysicalSize::new(
    window_outer_width(self.raw_window_handle),
    window_outer_height(self.raw_window_handle),
  )
}

///|
pub fn Window::surface_position(self : Window) -> @dpi.PhysicalPosition {
  @dpi.PhysicalPosition::new(
    window_surface_x(self.raw_window_handle),
    window_surface_y(self.raw_window_handle),
  )
}

///|
pub fn Window::inner_position(self : Window) -> @dpi.PhysicalPosition {
  self.surface_position()
}

///|
pub fn Window::safe_area(self : Window) -> @dpi.PhysicalInsets {
  @dpi.PhysicalInsets::new(
    window_safe_area_top(self.raw_window_handle),
    window_safe_area_left(self.raw_window_handle),
    window_safe_area_bottom(self.raw_window_handle),
    window_safe_area_right(self.raw_window_handle),
  )
}

///|
pub fn Window::request_surface_size(
  self : Window,
  size : @dpi.Size,
) -> @dpi.PhysicalSize? {
  let physical_size = size.to_physical(self.scale_factor())
  set_surface_size(
    self.raw_window_handle,
    physical_size.width(),
    physical_size.height(),
  )
  None
}

///|
pub fn Window::request_inner_size(
  self : Window,
  size : @dpi.Size,
) -> @dpi.PhysicalSize? {
  self.request_surface_size(size)
}

///|
pub fn Window::set_surface_resize_increments(
  self : Window,
  size : @dpi.Size?,
) -> Unit {
  match size {
    Some(size) => {
      let physical_size = size.to_physical(self.scale_factor())
      set_surface_resize_increments(
        self.raw_window_handle,
        physical_size.width(),
        physical_size.height(),
      )
    }
    None => set_surface_resize_increments(self.raw_window_handle, 0, 0)
  }
}

///|
pub fn Window::set_resize_increments(self : Window, size : @dpi.Size?) -> Unit {
  self.set_surface_resize_increments(size)
}

///|
pub fn Window::surface_resize_increments(self : Window) -> @dpi.PhysicalSize? {
  let width = window_resize_increment_width(self.raw_window_handle)
  let height = window_resize_increment_height(self.raw_window_handle)
  if width > 0 && height > 0 {
    Some(@dpi.PhysicalSize::new(width, height))
  } else {
    None
  }
}

///|
pub fn Window::resize_increments(self : Window) -> @dpi.PhysicalSize? {
  self.surface_resize_increments()
}

///|
pub fn Window::set_min_surface_size(self : Window, size : @dpi.Size?) -> Unit {
  match size {
    Some(size) => {
      let physical_size = size.to_physical(self.scale_factor())
      set_min_surface_size(
        self.raw_window_handle,
        physical_size.width(),
        physical_size.height(),
      )
    }
    None => set_min_surface_size(self.raw_window_handle, 0, 0)
  }
}

///|
pub fn Window::set_min_inner_size(self : Window, size : @dpi.Size?) -> Unit {
  self.set_min_surface_size(size)
}

///|
pub fn Window::set_max_surface_size(self : Window, size : @dpi.Size?) -> Unit {
  match size {
    Some(size) => {
      let physical_size = size.to_physical(self.scale_factor())
      set_max_surface_size(
        self.raw_window_handle,
        physical_size.width(),
        physical_size.height(),
      )
    }
    None => set_max_surface_size(self.raw_window_handle, 0, 0)
  }
}

///|
pub fn Window::set_max_inner_size(self : Window, size : @dpi.Size?) -> Unit {
  self.set_max_surface_size(size)
}

///|
pub fn Window::min_surface_size(self : Window) -> @dpi.PhysicalSize? {
  let width = window_min_surface_width(self.raw_window_handle)
  let height = window_min_surface_height(self.raw_window_handle)
  if width > 0 && height > 0 {
    Some(@dpi.PhysicalSize::new(width, height))
  } else {
    None
  }
}

///|
pub fn Window::min_inner_size(self : Window) -> @dpi.PhysicalSize? {
  self.min_surface_size()
}

///|
pub fn Window::max_surface_size(self : Window) -> @dpi.PhysicalSize? {
  let width = window_max_surface_width(self.raw_window_handle)
  let height = window_max_surface_height(self.raw_window_handle)
  if width > 0 && height > 0 {
    Some(@dpi.PhysicalSize::new(width, height))
  } else {
    None
  }
}

///|
pub fn Window::max_inner_size(self : Window) -> @dpi.PhysicalSize? {
  self.max_surface_size()
}

///|
pub fn Window::outer_position(
  self : Window,
) -> @dpi.PhysicalPosition raise @core.RequestError {
  let raw_id = self.raw_window_handle
  if raw_id == (0 : Int).to_uint64() {
    raise @core.RequestError::Ignored
  }
  @dpi.PhysicalPosition::new(window_x(raw_id), window_y(raw_id))
}

///|
pub fn Window::set_outer_position(
  self : Window,
  position : @dpi.Position,
) -> Unit {
  let physical_position = position.to_physical(self.scale_factor())
  set_window_position(
    self.raw_window_handle,
    physical_position.x(),
    physical_position.y(),
  )
}

///|
pub fn Window::focus_window(self : Window) -> Unit {
  let raw_id = self.raw_window_handle
  let is_minimized = window_minimized(raw_id)
  let is_visible = self.visible_state
  if is_minimized == false && is_visible {
    focus_window(raw_id)
  }
}

///|
pub fn Window::has_focus(self : Window) -> Bool {
  window_has_focus(self.raw_window_handle)
}

///|
pub fn Window::set_minimized(self : Window, minimized : Bool) -> Unit {
  set_window_minimized(self.raw_window_handle, minimized)
}

///|
pub fn Window::is_minimized(self : Window) -> Bool? {
  Some(window_minimized(self.raw_window_handle))
}

///|
pub fn Window::set_maximized(self : Window, maximized : Bool) -> Unit {
  set_window_maximized(self.raw_window_handle, maximized)
}

///|
pub fn Window::is_maximized(self : Window) -> Bool {
  window_maximized(self.raw_window_handle)
}

///|
pub fn Window::is_decorated(self : Window) -> Bool {
  self.decorated_state
}

///|
pub fn Window::enabled_buttons(self : Window) -> @core.WindowButtons {
  self.enabled_buttons_state
}

///|
pub fn Window::is_blurred(self : Window) -> Bool {
  self.blur_state
}

///|
pub fn Window::set_transparent(self : Window, transparent : Bool) -> Unit {
  self.transparent_state = transparent
  set_window_transparent(self.raw_window_handle, transparent)
}

///|
pub fn Window::is_transparent(self : Window) -> Bool {
  self.transparent_state
}

///|
pub fn Window::set_window_level(
  self : Window,
  level : @core.WindowLevel,
) -> Unit {
  self.window_level_state = level
  set_window_level(
    self.raw_window_handle,
    normalize_window_level_native(window_level_to_native(level)),
  )
}

///|
pub fn Window::window_level(self : Window) -> @core.WindowLevel {
  self.window_level_state
}

///|
pub fn Window::scale_factor(self : Window) -> Double {
  window_scale_factor(self.raw_window_handle)
}

///|
pub fn Window::request_redraw(self : Window) -> Unit {
  queue_redraw(self.id.into_raw())
}

///|
pub fn Window::pre_present_notify(_self : Window) -> Unit {
  ()
}

///|
pub fn Window::reset_dead_keys(_self : Window) -> Unit {
  ()
}

///|
pub fn Window::set_title(self : Window, title : String) -> Unit {
  set_title(self.raw_window_handle, title)
}

///|
pub fn Window::title(self : Window) -> String {
  window_title(self.raw_window_handle)
}

///|
pub fn Window::set_window_icon(
  _self : Window,
  _window_icon : @core.Icon?,
) -> Unit {
  ()
}

///|
pub fn Window::set_content_protected(
  self : Window,
  content_protected : Bool,
) -> Unit {
  self.content_protected_state = content_protected
  set_window_content_protected(self.raw_window_handle, content_protected)
}

///|
pub fn Window::set_visible(self : Window, visible : Bool) -> Unit {
  self.visible_state = visible
  native_set_visible(self.raw_window_handle, visible)
}

///|
pub fn Window::is_visible(self : Window) -> Bool? {
  Some(self.visible_state)
}

///|
pub fn Window::set_resizable(self : Window, resizable : Bool) -> Unit {
  self.resizable_state = resizable
  native_set_resizable(self.raw_window_handle, resizable)
}

///|
pub fn Window::is_resizable(self : Window) -> Bool {
  self.resizable_state
}

///|
pub fn Window::is_content_protected(self : Window) -> Bool {
  self.content_protected_state
}

///|
pub fn Window::is_document_edited(self : Window) -> Bool {
  self.document_edited_state
}

///|
pub fn Window::set_document_edited(self : Window, edited : Bool) -> Unit {
  self.document_edited_state = edited
  set_window_document_edited(self.raw_window_handle, edited)
}

///|
pub fn Window::set_option_as_alt(
  self : Window,
  option_as_alt : @core.OptionAsAlt,
) -> Unit {
  self.option_as_alt_state = option_as_alt
  set_window_option_as_alt(
    self.raw_window_handle,
    normalize_option_as_alt_native(option_as_alt_to_native(option_as_alt)),
  )
}

///|
pub fn Window::option_as_alt(self : Window) -> @core.OptionAsAlt {
  self.option_as_alt_state
}

///|
pub fn Window::request_user_attention(
  self : Window,
  request_type : @core.UserAttentionType?,
) -> Unit {
  request_user_attention(
    self.raw_window_handle,
    user_attention_type_to_native(request_type),
  )
}

///|
pub fn Window::current_monitor(self : Window) -> @core.MonitorHandle? {
  let monitor_id = window_current_monitor_id(self.raw_window_handle)
  if monitor_id == (0 : Int).to_uint64() {
    None
  } else {
    monitor_from_native_id(monitor_id)
  }
}

///|
pub fn Window::available_monitors(self : Window) -> Array[@core.MonitorHandle] {
  let _ = self
  available_monitors()
}

///|
pub fn Window::primary_monitor(self : Window) -> @core.MonitorHandle? {
  let _ = self
  Some(primary_monitor())
}

///|
pub fn Window::set_fullscreen(
  self : Window,
  fullscreen : @core.Fullscreen?,
) -> Unit {
  if self.simple_fullscreen() {
    ()
  } else {
    self.fullscreen_state = fullscreen
    let raw_id = self.raw_window_handle
    match fullscreen {
      None =>
        if self.exclusive_fullscreen_state {
          ignore(self.exit_exclusive_fullscreen())
        } else {
          set_window_fullscreen(raw_id, false)
        }
      Some(@core.Fullscreen::Borderless(target_monitor)) => {
        if self.exclusive_fullscreen_state {
          ignore(self.exit_exclusive_fullscreen())
        }
        match target_monitor {
          Some(monitor) =>
            set_window_position(
              raw_id,
              monitor.position().x(),
              monitor.position().y(),
            )
          None => ()
        }
        set_window_fullscreen(raw_id, true)
      }
      Some(@core.Fullscreen::Exclusive(target_monitor, video_mode)) => {
        if self.exclusive_fullscreen_state {
          ignore(self.exit_exclusive_fullscreen())
        }
        if window_fullscreen(raw_id) && !self.exclusive_fullscreen_state {
          set_window_fullscreen(raw_id, false)
        }
        ignore(self.enter_exclusive_fullscreen(target_monitor, video_mode))
      }
    }
  }
}

///|
pub fn Window::fullscreen(self : Window) -> @core.Fullscreen? {
  let raw_id = self.raw_window_handle
  if self.exclusive_fullscreen_state {
    match self.fullscreen_state {
      Some(fullscreen) => Some(fullscreen)
      None => None
    }
  } else if window_fullscreen(raw_id) {
    match self.fullscreen_state {
      Some(fullscreen) => Some(fullscreen)
      None => None
    }
  } else {
    self.fullscreen_state = None
    None
  }
}

///|
pub fn Window::is_fullscreen(self : Window) -> Bool {
  if self.exclusive_fullscreen_state {
    true
  } else {
    window_fullscreen(self.raw_window_handle)
  }
}

///|
pub fn Window::simple_fullscreen(self : Window) -> Bool {
  self.simple_fullscreen_state
}

///|
pub fn Window::set_simple_fullscreen(self : Window, fullscreen : Bool) -> Bool {
  let raw_id = self.raw_window_handle
  if self.is_fullscreen() {
    return false
  }
  if fullscreen == self.simple_fullscreen_state {
    return false
  }
  if fullscreen {
    let outer_position = Some(self.outer_position()) catch { _ => None }
    let current_monitor = self.current_monitor()
    match outer_position {
      Some(saved_outer_position) =>
        match current_monitor {
          Some(monitor) => {
            self.simple_fullscreen_saved_style_mask_state = Some(
              window_style_mask_bits(raw_id),
            )
            self.simple_fullscreen_saved_presentation_options_state = Some(
              application_presentation_options(),
            )
            self.simple_fullscreen_saved_outer_position_state = Some(
              saved_outer_position,
            )
            self.simple_fullscreen_saved_outer_size_state = Some(
              self.outer_size(),
            )
            self.simple_fullscreen_state = true
            set_application_presentation_options(
              simple_fullscreen_presentation_options(self.borderless_game_state),
            )
            clear_window_style_mask_bits(
              raw_id,
              fullscreen_removed_style_bits(),
            )
            set_window_position(
              raw_id,
              monitor.position().x(),
              monitor.position().y(),
            )
            set_window_outer_size(
              raw_id,
              monitor.surface_size().width(),
              monitor.surface_size().height(),
            )
            set_window_movable(raw_id, false)
            true
          }
          None => false
        }
      None => false
    }
  } else {
    let saved_style_mask = self.simple_fullscreen_saved_style_mask_state
    let saved_presentation_options = self.simple_fullscreen_saved_presentation_options_state
    let saved_outer_position = self.simple_fullscreen_saved_outer_position_state
    let saved_outer_size = self.simple_fullscreen_saved_outer_size_state
    self.simple_fullscreen_state = false
    self.simple_fullscreen_saved_style_mask_state = None
    self.simple_fullscreen_saved_presentation_options_state = None
    self.simple_fullscreen_saved_outer_position_state = None
    self.simple_fullscreen_saved_outer_size_state = None
    match saved_presentation_options {
      Some(options) => set_application_presentation_options(options)
      None => ()
    }
    match saved_outer_position {
      Some(position) => set_window_position(raw_id, position.x(), position.y())
      None => ()
    }
    match saved_outer_size {
      Some(size) => set_window_outer_size(raw_id, size.width(), size.height())
      None => ()
    }
    set_window_movable(raw_id, true)
    match saved_style_mask {
      Some(style_mask) => set_window_style_mask_bits(raw_id, style_mask)
      None => ()
    }
    true
  }
}

///|
fn Window::enter_exclusive_fullscreen(
  self : Window,
  target_monitor : @core.MonitorHandle,
  video_mode : @core.VideoMode,
) -> Bool {
  let raw_id = self.raw_window_handle
  let saved_outer_position = Some(self.outer_position()) catch { _ => None }
  let saved_style_mask = window_style_mask_bits(raw_id)
  let saved_outer_size = self.outer_size()
  match saved_outer_position {
    Some(saved_outer_position) => {
      let display_id = target_monitor.native_id()
      let mode_size = video_mode.surface_size()
      let target_mode = find_display_mode_handle(
        display_id,
        mode_size.width(),
        mode_size.height(),
        match video_mode.bit_depth() {
          Some(bit_depth) => bit_depth
          None => 0
        },
        match video_mode.refresh_rate_millihertz() {
          Some(refresh_rate) => refresh_rate
          None => 0
        },
      )
      if target_mode == (0 : Int).to_uint64() {
        return false
      }
      let saved_mode = copy_current_display_mode_handle(display_id)
      if saved_mode == (0 : Int).to_uint64() {
        release_display_mode_handle(target_mode)
        return false
      }
      if capture_display(display_id) == false {
        release_display_mode_handle(target_mode)
        release_display_mode_handle(saved_mode)
        return false
      }
      if set_display_mode_handle(display_id, target_mode) == false {
        ignore(release_display_capture(display_id))
        release_display_mode_handle(target_mode)
        release_display_mode_handle(saved_mode)
        return false
      }
      release_display_mode_handle(target_mode)
      self.exclusive_fullscreen_state = true
      self.exclusive_fullscreen_display_id_state = Some(display_id)
      self.exclusive_fullscreen_saved_mode_state = Some(saved_mode)
      self.exclusive_fullscreen_saved_style_mask_state = Some(saved_style_mask)
      self.exclusive_fullscreen_saved_outer_position_state = Some(
        saved_outer_position,
      )
      self.exclusive_fullscreen_saved_outer_size_state = Some(saved_outer_size)
      set_window_exclusive_runtime_state(raw_id, true, display_id, saved_mode)
      clear_window_style_mask_bits(raw_id, fullscreen_removed_style_bits())
      set_window_position(
        raw_id,
        target_monitor.position().x(),
        target_monitor.position().y(),
      )
      set_window_outer_size(
        raw_id,
        target_monitor.surface_size().width(),
        target_monitor.surface_size().height(),
      )
      set_window_movable(raw_id, false)
      true
    }
    None => false
  }
}

///|
fn Window::exit_exclusive_fullscreen(self : Window) -> Bool {
  if self.exclusive_fullscreen_state == false {
    return false
  }
  let raw_id = self.raw_window_handle
  let saved_display_id = self.exclusive_fullscreen_display_id_state
  let saved_mode = self.exclusive_fullscreen_saved_mode_state
  let saved_style_mask = self.exclusive_fullscreen_saved_style_mask_state
  let saved_outer_position = self.exclusive_fullscreen_saved_outer_position_state
  let saved_outer_size = self.exclusive_fullscreen_saved_outer_size_state
  self.exclusive_fullscreen_state = false
  self.exclusive_fullscreen_display_id_state = None
  self.exclusive_fullscreen_saved_mode_state = None
  self.exclusive_fullscreen_saved_style_mask_state = None
  self.exclusive_fullscreen_saved_outer_position_state = None
  self.exclusive_fullscreen_saved_outer_size_state = None
  match saved_display_id {
    Some(display_id) =>
      match saved_mode {
        Some(saved_mode) => {
          ignore(set_display_mode_handle(display_id, saved_mode))
          ignore(release_display_capture(display_id))
          release_display_mode_handle(saved_mode)
        }
        None => ignore(release_display_capture(display_id))
      }
    None =>
      match saved_mode {
        Some(saved_mode) => release_display_mode_handle(saved_mode)
        None => ()
      }
  }
  set_window_exclusive_runtime_state(
    raw_id,
    false,
    (0 : Int).to_uint64(),
    (0 : Int).to_uint64(),
  )
  match saved_style_mask {
    Some(style_mask) => set_window_style_mask_bits(raw_id, style_mask)
    None => ()
  }
  match saved_outer_position {
    Some(position) => set_window_position(raw_id, position.x(), position.y())
    None => ()
  }
  match saved_outer_size {
    Some(size) => set_window_outer_size(raw_id, size.width(), size.height())
    None => ()
  }
  set_window_movable(raw_id, true)
  true
}

///|
fn fullscreen_removed_style_bits() -> UInt64 {
  (13 : Int).to_uint64()
}

///|
fn simple_fullscreen_presentation_options(borderless_game : Bool) -> UInt64 {
  if borderless_game {
    (10 : Int).to_uint64()
  } else {
    (5 : Int).to_uint64()
  }
}

///|
pub fn Window::set_borderless_game(
  self : Window,
  borderless_game : Bool,
) -> Unit {
  self.borderless_game_state = borderless_game
  set_window_borderless_game(self.raw_window_handle, borderless_game)
}

///|
pub fn Window::is_borderless_game(self : Window) -> Bool {
  self.borderless_game_state
}

///|
pub fn Window::set_unified_titlebar(
  self : Window,
  unified_titlebar : Bool,
) -> Unit {
  self.unified_titlebar_state = unified_titlebar
  set_window_unified_titlebar(self.raw_window_handle, unified_titlebar)
}

///|
pub fn Window::unified_titlebar(self : Window) -> Bool {
  self.unified_titlebar_state
}

///|
pub fn Window::set_tabbing_identifier(
  self : Window,
  identifier : String,
) -> Unit {
  set_window_tabbing_identifier(self.raw_window_handle, identifier)
}

///|
pub fn Window::tabbing_identifier(self : Window) -> String {
  window_tabbing_identifier(self.raw_window_handle)
}

///|
pub fn Window::select_next_tab(self : Window) -> Unit {
  select_window_next_tab(self.raw_window_handle)
}

///|
pub fn Window::select_previous_tab(self : Window) -> Unit {
  select_window_previous_tab(self.raw_window_handle)
}

///|
pub fn Window::select_tab_at_index(self : Window, index : Int) -> Unit {
  if index >= 0 {
    select_window_tab_at_index(self.raw_window_handle, index)
  }
}

///|
pub fn Window::num_tabs(self : Window) -> Int {
  window_num_tabs(self.raw_window_handle)
}

///|
pub fn Window::set_decorations(self : Window, decorations : Bool) -> Unit {
  self.toggle_window_decorations(decorations)
}

///|
fn Window::toggle_window_decorations(self : Window, decorations : Bool) -> Unit {
  self.decorated_state = decorations
  set_window_decorations(self.raw_window_handle, decorations)
}

///|
pub fn Window::set_enabled_buttons(
  self : Window,
  buttons : @core.WindowButtons,
) -> Unit {
  self.enabled_buttons_state = buttons
  set_window_enabled_buttons(
    self.raw_window_handle,
    buttons.close(),
    buttons.minimize(),
    buttons.maximize(),
  )
}

///|
pub fn Window::set_blur(self : Window, blur : Bool) -> Unit {
  self.blur_state = blur
  set_window_blur(self.raw_window_handle, blur)
}

///|
pub fn Window::has_shadow(self : Window) -> Bool {
  self.has_shadow_state
}

///|
pub fn Window::set_has_shadow(self : Window, has_shadow : Bool) -> Unit {
  self.has_shadow_state = has_shadow
  set_window_has_shadow(self.raw_window_handle, has_shadow)
}

///|
pub fn Window::set_theme(self : Window, theme : @core.Theme?) -> Unit {
  set_window_theme(self.raw_window_handle, theme_to_appearance(theme))
}

///|
pub fn Window::theme(self : Window) -> @core.Theme? {
  appearance_to_theme(window_appearance(self.raw_window_handle))
}

///|
pub fn Window::is_occluded(self : Window) -> Bool {
  window_occluded(self.raw_window_handle)
}

///|
fn window_appearance(window_handle : UInt64) -> Int {
  window_theme(window_handle)
}

///|
fn theme_to_appearance(theme : @core.Theme?) -> Int {
  theme_to_native(theme)
}

///|
fn dark_appearance_name() -> String {
  "Dark"
}

///|
fn appearance_to_theme(appearance : Int) -> @core.Theme? {
  let _ = dark_appearance_name()
  theme_from_native(appearance)
}
