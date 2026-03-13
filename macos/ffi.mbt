///|
// Port target: winit-reference/winit-appkit/src/ffi.rs
// MoonBit adaptation:
// 1. Raw pointer-like values are represented as UInt64.
// 2. kTISPropertyUnicodeKeyLayoutData is modeled by creating a CFString key.

///|
fn cg_display_create_uuid_from_display_id(display_id : UInt64) -> UInt64 {
  native_cg_display_create_uuid_from_display_id(display_id.to_uint())
}

///|
fn cg_main_display_id() -> UInt64 {
  native_cg_main_display_id().to_uint64()
}

///|
fn cg_display_model_number(display_id : UInt64) -> Int {
  native_cg_display_model_number(display_id.to_uint()).reinterpret_as_int()
}

///|
fn cg_display_pixels_wide(display_id : UInt64) -> Int {
  native_cg_display_pixels_wide(display_id.to_uint()).to_int()
}

///|
fn cg_display_pixels_high(display_id : UInt64) -> Int {
  native_cg_display_pixels_high(display_id.to_uint()).to_int()
}

///|
fn cg_display_get_display_id_from_uuid(uuid : UInt64) -> UInt64 {
  native_cg_display_get_display_id_from_uuid(uuid).to_uint64()
}

///|
fn cf_release(cf_type : UInt64) -> Unit {
  if cf_type != (0 : Int).to_uint64() {
    native_cf_release(cf_type)
  }
}

///|
fn pthread_is_main_thread() -> Bool {
  native_pthread_main_np() != 0
}

///|
fn cg_active_display_count() -> Int {
  let count = native_cg_active_display_count()
  if count < 0 {
    0
  } else {
    count
  }
}

///|
fn cg_active_display_id_at(index : Int) -> UInt64 {
  native_cg_active_display_id_at(index).to_uint64()
}

///|
fn cg_display_bounds_x(display_id : UInt64) -> Int {
  native_cg_display_bounds_x(display_id.to_uint())
}

///|
fn cg_display_bounds_y(display_id : UInt64) -> Int {
  native_cg_display_bounds_y(display_id.to_uint())
}

///|
fn cg_display_scale_factor(display_id : UInt64) -> Double {
  let factor = native_cg_display_scale_factor(display_id.to_uint())
  if factor > 0.0 {
    factor
  } else {
    1.0
  }
}

///|
fn native_install_window_event_callback(
  call_closure : FuncRef[
    ((Int, Int, Int, Int, Int, Double) -> Unit, Int, Int, Int, Int, Int, Double) -> Unit,
  ],
  callback : (Int, Int, Int, Int, Int, Double) -> Unit,
) -> Unit {
  appkit_install_window_event_callback(call_closure, callback)
}

///|
fn native_install_lifecycle_callback(
  call_closure : FuncRef[((Int) -> Unit, Int) -> Unit],
  callback : (Int) -> Unit,
) -> Unit {
  appkit_install_lifecycle_callback(call_closure, callback)
}

///|
fn native_install_input_event_callback(
  call_closure : FuncRef[
    (
      (
        Int,
        Int,
        Double,
        Double,
        Int,
        Int,
        Int,
        Int,
        Int,
        Int,
        Int,
        Int,
        Double,
        Double,
        Int,
      ) -> Unit,
      Int,
      Int,
      Double,
      Double,
      Int,
      Int,
      Int,
      Int,
      Int,
      Int,
      Int,
      Int,
      Double,
      Double,
      Int,
    ) -> Unit,
  ],
  callback : (
    Int,
    Int,
    Double,
    Double,
    Int,
    Int,
    Int,
    Int,
    Int,
    Int,
    Int,
    Int,
    Double,
    Double,
    Int,
  ) -> Unit,
) -> Unit {
  appkit_install_input_event_callback(call_closure, callback)
}

///|
fn native_install_text_input_event_callback(
  call_closure : FuncRef[
    (
      (Int, Int, Double, Double, Int, Bytes, Int, Int, Bytes) -> Unit,
      Int,
      Int,
      Double,
      Double,
      Int,
      Bytes,
      Int,
      Int,
      Bytes,
    ) -> Unit,
  ],
  callback : (Int, Int, Double, Double, Int, Bytes, Int, Int, Bytes) -> Unit,
) -> Unit {
  appkit_install_text_input_event_callback(call_closure, callback)
}

///|
fn native_install_device_event_callback(
  call_closure : FuncRef[
    ((Int, Int, Double, Double) -> Unit, Int, Int, Double, Double) -> Unit,
  ],
  callback : (Int, Int, Double, Double) -> Unit,
) -> Unit {
  appkit_install_device_event_callback(call_closure, callback)
}

///|
fn native_override_send_event() -> Unit {
  appkit_override_send_event()
}

///|
fn native_create_window(
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
  appkit_create_window(
    raw_id,
    width,
    height,
    if visible {
      1
    } else {
      0
    },
    if active {
      1
    } else {
      0
    },
    if resizable {
      1
    } else {
      0
    },
    if decorations {
      1
    } else {
      0
    },
    if panel {
      1
    } else {
      0
    },
    @utf8.encode(title[:], bom=false),
  )
}

///|
fn native_close_window(handle : UInt64) -> Unit {
  appkit_close_window(handle)
}

///|
fn native_show_window(handle : UInt64, active : Bool) -> Unit {
  appkit_window_show(handle, if active { 1 } else { 0 })
}

///|
fn native_window_set_visible(handle : UInt64, visible : Bool) -> Unit {
  appkit_window_set_visible(handle, if visible { 1 } else { 0 })
}

///|
fn native_window_set_resizable(handle : UInt64, resizable : Bool) -> Unit {
  appkit_window_set_resizable(handle, if resizable { 1 } else { 0 })
}

///|
fn native_window_set_title(handle : UInt64, title : String) -> Unit {
  appkit_window_set_title(handle, @utf8.encode(title[:], bom=false))
}

///|
fn native_window_focus(handle : UInt64) -> Unit {
  appkit_window_focus(handle)
}

///|
fn native_window_set_content_size(
  handle : UInt64,
  width : Int,
  height : Int,
) -> Unit {
  appkit_window_set_content_size(handle, width, height)
}

///|
fn native_window_set_min_content_size(
  handle : UInt64,
  width : Int,
  height : Int,
) -> Unit {
  appkit_window_set_min_content_size(handle, width, height)
}

///|
fn native_window_set_max_content_size(
  handle : UInt64,
  width : Int,
  height : Int,
) -> Unit {
  appkit_window_set_max_content_size(handle, width, height)
}

///|
fn native_window_set_resize_increments(
  handle : UInt64,
  width : Int,
  height : Int,
) -> Unit {
  appkit_window_set_resize_increments(handle, width, height)
}

///|
fn native_window_set_position(handle : UInt64, x : Int, y : Int) -> Unit {
  appkit_window_set_position(handle, x, y)
}

///|
fn native_window_content_width(handle : UInt64) -> Int {
  appkit_window_content_width(handle)
}

///|
fn native_window_content_height(handle : UInt64) -> Int {
  appkit_window_content_height(handle)
}

///|
fn native_window_min_content_width(handle : UInt64) -> Int {
  appkit_window_min_content_width(handle)
}

///|
fn native_window_min_content_height(handle : UInt64) -> Int {
  appkit_window_min_content_height(handle)
}

///|
fn native_window_max_content_width(handle : UInt64) -> Int {
  appkit_window_max_content_width(handle)
}

///|
fn native_window_max_content_height(handle : UInt64) -> Int {
  appkit_window_max_content_height(handle)
}

///|
fn native_window_outer_width(handle : UInt64) -> Int {
  appkit_window_outer_width(handle)
}

///|
fn native_window_outer_height(handle : UInt64) -> Int {
  appkit_window_outer_height(handle)
}

///|
fn native_window_resize_increment_width(handle : UInt64) -> Int {
  appkit_window_resize_increment_width(handle)
}

///|
fn native_window_resize_increment_height(handle : UInt64) -> Int {
  appkit_window_resize_increment_height(handle)
}

///|
fn native_window_safe_area_top(handle : UInt64) -> Int {
  appkit_window_safe_area_top(handle)
}

///|
fn native_window_safe_area_left(handle : UInt64) -> Int {
  appkit_window_safe_area_left(handle)
}

///|
fn native_window_safe_area_bottom(handle : UInt64) -> Int {
  appkit_window_safe_area_bottom(handle)
}

///|
fn native_window_safe_area_right(handle : UInt64) -> Int {
  appkit_window_safe_area_right(handle)
}

///|
fn native_window_x(handle : UInt64) -> Int {
  appkit_window_x(handle)
}

///|
fn native_window_y(handle : UInt64) -> Int {
  appkit_window_y(handle)
}

///|
fn native_window_has_focus(handle : UInt64) -> Bool {
  appkit_window_has_focus(handle) != 0
}

///|
fn native_window_is_occluded(handle : UInt64) -> Bool {
  appkit_window_is_occluded(handle) != 0
}

///|
fn native_window_scale_factor(handle : UInt64) -> Double {
  appkit_window_scale_factor(handle)
}

///|
fn native_window_set_minimized(handle : UInt64, minimized : Bool) -> Unit {
  appkit_window_set_minimized(handle, if minimized { 1 } else { 0 })
}

///|
fn native_window_is_minimized(handle : UInt64) -> Bool {
  appkit_window_is_minimized(handle) != 0
}

///|
fn native_window_set_maximized(handle : UInt64, maximized : Bool) -> Unit {
  appkit_window_set_maximized(handle, if maximized { 1 } else { 0 })
}

///|
fn native_window_is_maximized(handle : UInt64) -> Bool {
  appkit_window_is_maximized(handle) != 0
}

///|
fn native_window_set_fullscreen(handle : UInt64, fullscreen : Bool) -> Unit {
  appkit_window_set_fullscreen(handle, if fullscreen { 1 } else { 0 })
}

///|
fn native_window_is_fullscreen(handle : UInt64) -> Bool {
  appkit_window_is_fullscreen(handle) != 0
}

///|
fn native_window_style_mask(handle : UInt64) -> UInt64 {
  appkit_window_style_mask(handle)
}

///|
fn native_window_set_style_mask(handle : UInt64, style_mask : UInt64) -> Unit {
  appkit_window_set_style_mask(handle, style_mask)
}

///|
fn native_window_clear_style_mask_bits(
  handle : UInt64,
  style_mask : UInt64,
) -> Unit {
  appkit_window_clear_style_mask_bits(handle, style_mask)
}

///|
fn native_window_num_tabs(handle : UInt64) -> Int {
  appkit_window_num_tabs(handle)
}

///|
fn native_window_set_theme(handle : UInt64, theme : Int) -> Unit {
  appkit_window_set_theme(handle, theme)
}

///|
fn native_window_set_has_shadow(handle : UInt64, has_shadow : Bool) -> Unit {
  appkit_window_set_has_shadow(handle, if has_shadow { 1 } else { 0 })
}

///|
fn native_window_set_document_edited(handle : UInt64, edited : Bool) -> Unit {
  appkit_window_set_document_edited(handle, if edited { 1 } else { 0 })
}

///|
fn native_window_set_level(handle : UInt64, level : Int) -> Unit {
  appkit_window_set_level(handle, level)
}

///|
fn native_window_set_movable_by_background(
  handle : UInt64,
  movable : Bool,
) -> Unit {
  appkit_window_set_movable_by_window_background(
    handle,
    if movable {
      1
    } else {
      0
    },
  )
}

///|
fn native_window_set_accepts_first_mouse(
  handle : UInt64,
  accepts_first_mouse : Bool,
) -> Unit {
  appkit_window_set_accepts_first_mouse(
    handle,
    if accepts_first_mouse {
      1
    } else {
      0
    },
  )
}

///|
fn native_window_set_option_as_alt(
  handle : UInt64,
  option_as_alt : Int,
) -> Unit {
  appkit_window_set_option_as_alt(handle, option_as_alt)
}

///|
fn native_window_set_ime_purpose(handle : UInt64, purpose : Int) -> Unit {
  appkit_window_set_ime_purpose(handle, purpose)
}

///|
fn native_window_set_ime_hints(handle : UInt64, hints : Int) -> Unit {
  appkit_window_set_ime_hints(handle, hints)
}

///|
fn native_window_set_ime_allowed(handle : UInt64, allowed : Bool) -> Unit {
  appkit_window_set_ime_allowed(handle, if allowed { 1 } else { 0 })
}

///|
fn native_window_set_ime_cursor_area(
  handle : UInt64,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Unit {
  appkit_window_set_ime_cursor_area(handle, x, y, width, height)
}

///|
fn native_window_set_titlebar_transparent(
  handle : UInt64,
  transparent : Bool,
) -> Unit {
  appkit_window_set_titlebar_transparent(
    handle,
    if transparent {
      1
    } else {
      0
    },
  )
}

///|
fn native_window_set_title_hidden(handle : UInt64, hidden : Bool) -> Unit {
  appkit_window_set_title_hidden(handle, if hidden { 1 } else { 0 })
}

///|
fn native_window_set_titlebar_hidden(handle : UInt64, hidden : Bool) -> Unit {
  appkit_window_set_titlebar_hidden(handle, if hidden { 1 } else { 0 })
}

///|
fn native_window_set_titlebar_buttons_hidden(
  handle : UInt64,
  hidden : Bool,
) -> Unit {
  appkit_window_set_titlebar_buttons_hidden(handle, if hidden { 1 } else { 0 })
}

///|
fn native_window_set_fullsize_content_view(
  handle : UInt64,
  enabled : Bool,
) -> Unit {
  appkit_window_set_fullsize_content_view(handle, if enabled { 1 } else { 0 })
}

///|
fn native_window_set_unified_titlebar(
  handle : UInt64,
  unified_titlebar : Bool,
) -> Unit {
  appkit_window_set_unified_titlebar(
    handle,
    if unified_titlebar {
      1
    } else {
      0
    },
  )
}

///|
fn native_window_set_enabled_buttons(
  handle : UInt64,
  close : Bool,
  minimize : Bool,
  maximize : Bool,
) -> Unit {
  appkit_window_set_enabled_buttons(
    handle,
    if close {
      1
    } else {
      0
    },
    if minimize {
      1
    } else {
      0
    },
    if maximize {
      1
    } else {
      0
    },
  )
}

///|
fn native_window_set_blur(handle : UInt64, blur : Bool) -> Unit {
  appkit_window_set_blur(handle, if blur { 1 } else { 0 })
}

///|
fn native_window_request_user_attention(request_type : Int) -> Unit {
  appkit_window_request_user_attention(request_type)
}

///|
fn native_window_set_movable(handle : UInt64, movable : Bool) -> Unit {
  appkit_window_set_movable(handle, if movable { 1 } else { 0 })
}

///|
fn native_window_set_transparent(handle : UInt64, transparent : Bool) -> Unit {
  appkit_window_set_transparent(handle, if transparent { 1 } else { 0 })
}

///|
fn native_window_set_parent(handle : UInt64, parent_handle : UInt64) -> Unit {
  appkit_window_set_parent(handle, parent_handle)
}

///|
fn native_window_set_content_protected(
  handle : UInt64,
  content_protected : Bool,
) -> Unit {
  appkit_window_set_content_protected(
    handle,
    if content_protected {
      1
    } else {
      0
    },
  )
}

///|
fn native_window_set_tabbing_identifier(
  handle : UInt64,
  identifier : String,
) -> Unit {
  appkit_window_set_tabbing_identifier(
    handle,
    @utf8.encode(identifier[:], bom=false),
  )
}

///|
fn native_window_set_tabbing_mode_preferred(handle : UInt64) -> Unit {
  appkit_window_set_tabbing_mode_preferred(handle)
}

///|
fn native_window_select_next_tab(handle : UInt64) -> Unit {
  appkit_window_select_next_tab(handle)
}

///|
fn native_window_select_previous_tab(handle : UInt64) -> Unit {
  appkit_window_select_previous_tab(handle)
}

///|
fn native_window_select_tab_at_index(handle : UInt64, index : Int) -> Unit {
  appkit_window_select_tab_at_index(handle, index)
}

///|
fn native_window_set_cursor(handle : UInt64, cursor : Int) -> Unit {
  appkit_window_set_cursor(handle, cursor)
}

///|
fn native_custom_cursor_create_rgba(
  rgba : Bytes,
  width : Int,
  height : Int,
  hotspot_x : Int,
  hotspot_y : Int,
) -> UInt64 {
  appkit_custom_cursor_create_rgba(
    rgba,
    rgba.length(),
    width,
    height,
    hotspot_x,
    hotspot_y,
  )
}

///|
fn native_custom_cursor_create_url(
  url : String,
  hotspot_x : Int,
  hotspot_y : Int,
) -> UInt64 {
  appkit_custom_cursor_create_url(
    @utf8.encode(url[:], bom=false),
    hotspot_x,
    hotspot_y,
  )
}

///|
fn native_window_set_custom_cursor(
  handle : UInt64,
  custom_cursor : UInt64,
) -> Bool {
  appkit_window_set_custom_cursor(handle, custom_cursor) != 0
}

///|
fn native_window_set_cursor_visible(handle : UInt64, visible : Bool) -> Unit {
  appkit_window_set_cursor_visible(handle, if visible { 1 } else { 0 })
}

///|
fn native_window_set_cursor_hittest(handle : UInt64, hittest : Bool) -> Bool {
  appkit_window_set_cursor_hittest(handle, if hittest { 1 } else { 0 }) != 0
}

///|
fn native_window_set_cursor_position(handle : UInt64, x : Int, y : Int) -> Bool {
  appkit_window_set_cursor_position(handle, x, y) != 0
}

///|
fn native_window_set_cursor_grab(handle : UInt64, mode : Int) -> Bool {
  appkit_window_set_cursor_grab(handle, mode) != 0
}

///|
fn native_window_drag_window(handle : UInt64) -> Bool {
  appkit_window_drag_window(handle) != 0
}

///|
fn native_window_drag_resize_window(handle : UInt64, direction : Int) -> Bool {
  appkit_window_drag_resize_window(handle, direction) != 0
}

///|
fn native_window_show_window_menu(handle : UInt64, x : Int, y : Int) -> Bool {
  appkit_window_show_window_menu(handle, x, y) != 0
}

///|
fn native_window_current_monitor_id(handle : UInt64) -> UInt64 {
  appkit_window_current_monitor_id(handle)
}

///|
fn native_window_theme(handle : UInt64) -> Int {
  appkit_window_theme(handle)
}

///|
fn native_event_loop_wake_up_appkit() -> Unit {
  appkit_event_loop_wake_up()
}

///|
fn native_event_loop_wait_millis(timeout_ms : Int) -> Bool {
  appkit_event_loop_wait_millis(timeout_ms) != 0
}

///|
fn native_application_presentation_options() -> UInt64 {
  appkit_application_presentation_options()
}

///|
fn native_set_application_presentation_options(options : UInt64) -> Unit {
  appkit_set_application_presentation_options(options)
}

///|
fn native_application_hide() -> Unit {
  appkit_application_hide()
}

///|
fn native_application_hide_other_applications() -> Unit {
  appkit_application_hide_other_applications()
}

///|
fn native_application_set_allows_automatic_window_tabbing(
  enabled : Bool,
) -> Unit {
  appkit_application_set_allows_automatic_window_tabbing(
    if enabled {
      1
    } else {
      0
    },
  )
}

///|
fn native_application_allows_automatic_window_tabbing() -> Bool {
  appkit_application_allows_automatic_window_tabbing() != 0
}

///|
fn native_application_set_activation_policy(activation_policy : Int) -> Unit {
  appkit_application_set_activation_policy(activation_policy)
}

///|
fn native_application_set_activate_ignoring_other_apps(
  activate_ignoring_other_apps : Bool,
) -> Unit {
  appkit_application_set_activate_ignoring_other_apps(
    if activate_ignoring_other_apps {
      1
    } else {
      0
    },
  )
}

///|
fn native_application_initialize_default_menu(enabled : Bool) -> Unit {
  appkit_application_initialize_default_menu(if enabled { 1 } else { 0 })
}

///|
fn native_find_display_mode_handle(
  monitor_id : UInt64,
  width : Int,
  height : Int,
  bit_depth : Int,
  refresh_rate_millihertz : Int,
) -> UInt64 {
  native_monitor_find_display_mode_handle(
    monitor_id.to_uint(),
    width,
    height,
    bit_depth,
    refresh_rate_millihertz,
  )
}

///|
fn native_copy_current_display_mode_handle(monitor_id : UInt64) -> UInt64 {
  native_monitor_copy_current_display_mode_handle(monitor_id.to_uint())
}

///|
fn native_release_display_mode_handle(mode_handle : UInt64) -> Unit {
  native_monitor_release_display_mode_handle(mode_handle)
}

///|
fn native_capture_display(monitor_id : UInt64) -> Bool {
  native_monitor_capture_display(monitor_id.to_uint()) != 0
}

///|
fn native_set_display_mode_handle(
  monitor_id : UInt64,
  mode_handle : UInt64,
) -> Bool {
  native_monitor_set_display_mode_handle(monitor_id.to_uint(), mode_handle) != 0
}

///|
fn native_release_display_capture(monitor_id : UInt64) -> Bool {
  native_monitor_release_display_capture(monitor_id.to_uint()) != 0
}

///|
extern "C" fn native_cg_display_create_uuid_from_display_id(
  display : UInt,
) -> UInt64 = "CGDisplayCreateUUIDFromDisplayID"

///|
extern "C" fn native_cf_absolute_time_get_current() -> Double = "CFAbsoluteTimeGetCurrent"

///|
extern "C" fn native_cg_main_display_id() -> UInt = "CGMainDisplayID"

///|
extern "C" fn native_cg_display_model_number(display : UInt) -> UInt = "CGDisplayModelNumber"

///|
extern "C" fn native_cg_display_pixels_wide(display : UInt) -> UInt64 = "CGDisplayPixelsWide"

///|
extern "C" fn native_cg_display_pixels_high(display : UInt) -> UInt64 = "CGDisplayPixelsHigh"

///|
extern "C" fn native_cg_display_get_display_id_from_uuid(uuid : UInt64) -> UInt = "CGDisplayGetDisplayIDFromUUID"

///|
extern "C" fn native_cf_release(cf_type : UInt64) -> Unit = "CFRelease"

///|
extern "C" fn native_pthread_main_np() -> Int = "pthread_main_np"

///|
extern "C" fn native_cg_active_display_count() -> Int = "mbw_cg_active_display_count"

///|
extern "C" fn native_cg_active_display_id_at(index : Int) -> UInt = "mbw_cg_active_display_id_at"

///|
extern "C" fn native_cg_display_bounds_x(display : UInt) -> Int = "mbw_cg_display_bounds_x"

///|
extern "C" fn native_cg_display_bounds_y(display : UInt) -> Int = "mbw_cg_display_bounds_y"

///|
extern "C" fn native_cg_display_scale_factor(display : UInt) -> Double = "mbw_cg_display_scale_factor"

///|
extern "C" fn appkit_install_window_event_callback(
  call_closure : FuncRef[
    ((Int, Int, Int, Int, Int, Double) -> Unit, Int, Int, Int, Int, Int, Double) -> Unit,
  ],
  callback : (Int, Int, Int, Int, Int, Double) -> Unit,
) -> Unit = "mbw_install_window_event_callback"

///|
extern "C" fn appkit_install_lifecycle_callback(
  call_closure : FuncRef[((Int) -> Unit, Int) -> Unit],
  callback : (Int) -> Unit,
) -> Unit = "mbw_install_lifecycle_callback"

///|
extern "C" fn appkit_install_input_event_callback(
  call_closure : FuncRef[
    (
      (
        Int,
        Int,
        Double,
        Double,
        Int,
        Int,
        Int,
        Int,
        Int,
        Int,
        Int,
        Int,
        Double,
        Double,
        Int,
      ) -> Unit,
      Int,
      Int,
      Double,
      Double,
      Int,
      Int,
      Int,
      Int,
      Int,
      Int,
      Int,
      Int,
      Double,
      Double,
      Int,
    ) -> Unit,
  ],
  callback : (
    Int,
    Int,
    Double,
    Double,
    Int,
    Int,
    Int,
    Int,
    Int,
    Int,
    Int,
    Int,
    Double,
    Double,
    Int,
  ) -> Unit,
) -> Unit = "mbw_install_input_event_callback"

///|
extern "C" fn appkit_install_text_input_event_callback(
  call_closure : FuncRef[
    (
      (Int, Int, Double, Double, Int, Bytes, Int, Int, Bytes) -> Unit,
      Int,
      Int,
      Double,
      Double,
      Int,
      Bytes,
      Int,
      Int,
      Bytes,
    ) -> Unit,
  ],
  callback : (Int, Int, Double, Double, Int, Bytes, Int, Int, Bytes) -> Unit,
) -> Unit = "mbw_install_text_input_event_callback"

///|
extern "C" fn appkit_install_device_event_callback(
  call_closure : FuncRef[
    ((Int, Int, Double, Double) -> Unit, Int, Int, Double, Double) -> Unit,
  ],
  callback : (Int, Int, Double, Double) -> Unit,
) -> Unit = "mbw_install_device_event_callback"

///|
extern "C" fn appkit_override_send_event() -> Unit = "mbw_override_send_event"

///|
#borrow(title)
extern "C" fn appkit_create_window(
  raw_id : Int,
  width : Int,
  height : Int,
  visible : Int,
  active : Int,
  resizable : Int,
  decorations : Int,
  panel : Int,
  title : Bytes,
) -> UInt64 = "mbw_create_window"

///|
extern "C" fn appkit_close_window(handle : UInt64) -> Unit = "mbw_close_window"

///|
extern "C" fn appkit_window_show(handle : UInt64, active : Int) -> Unit = "mbw_window_show"

///|
extern "C" fn appkit_window_set_visible(handle : UInt64, visible : Int) -> Unit = "mbw_window_set_visible"

///|
extern "C" fn appkit_window_set_resizable(
  handle : UInt64,
  resizable : Int,
) -> Unit = "mbw_window_set_resizable"

///|
#borrow(title)
extern "C" fn appkit_window_set_title(handle : UInt64, title : Bytes) -> Unit = "mbw_window_set_title"

///|
extern "C" fn appkit_window_focus(handle : UInt64) -> Unit = "mbw_window_focus"

///|
extern "C" fn appkit_window_set_content_size(
  handle : UInt64,
  width : Int,
  height : Int,
) -> Unit = "mbw_window_set_content_size"

///|
extern "C" fn appkit_window_set_min_content_size(
  handle : UInt64,
  width : Int,
  height : Int,
) -> Unit = "mbw_window_set_min_content_size"

///|
extern "C" fn appkit_window_set_max_content_size(
  handle : UInt64,
  width : Int,
  height : Int,
) -> Unit = "mbw_window_set_max_content_size"

///|
extern "C" fn appkit_window_set_resize_increments(
  handle : UInt64,
  width : Int,
  height : Int,
) -> Unit = "mbw_window_set_resize_increments"

///|
extern "C" fn appkit_window_set_position(
  handle : UInt64,
  x : Int,
  y : Int,
) -> Unit = "mbw_window_set_position"

///|
extern "C" fn appkit_window_content_width(handle : UInt64) -> Int = "mbw_window_content_width"

///|
extern "C" fn appkit_window_content_height(handle : UInt64) -> Int = "mbw_window_content_height"

///|
extern "C" fn appkit_window_min_content_width(handle : UInt64) -> Int = "mbw_window_min_content_width"

///|
extern "C" fn appkit_window_min_content_height(handle : UInt64) -> Int = "mbw_window_min_content_height"

///|
extern "C" fn appkit_window_max_content_width(handle : UInt64) -> Int = "mbw_window_max_content_width"

///|
extern "C" fn appkit_window_max_content_height(handle : UInt64) -> Int = "mbw_window_max_content_height"

///|
extern "C" fn appkit_window_outer_width(handle : UInt64) -> Int = "mbw_window_outer_width"

///|
extern "C" fn appkit_window_outer_height(handle : UInt64) -> Int = "mbw_window_outer_height"

///|
extern "C" fn appkit_window_resize_increment_width(handle : UInt64) -> Int = "mbw_window_resize_increment_width"

///|
extern "C" fn appkit_window_resize_increment_height(handle : UInt64) -> Int = "mbw_window_resize_increment_height"

///|
extern "C" fn appkit_window_safe_area_top(handle : UInt64) -> Int = "mbw_window_safe_area_top"

///|
extern "C" fn appkit_window_safe_area_left(handle : UInt64) -> Int = "mbw_window_safe_area_left"

///|
extern "C" fn appkit_window_safe_area_bottom(handle : UInt64) -> Int = "mbw_window_safe_area_bottom"

///|
extern "C" fn appkit_window_safe_area_right(handle : UInt64) -> Int = "mbw_window_safe_area_right"

///|
extern "C" fn appkit_window_x(handle : UInt64) -> Int = "mbw_window_x"

///|
extern "C" fn appkit_window_y(handle : UInt64) -> Int = "mbw_window_y"

///|
extern "C" fn appkit_window_has_focus(handle : UInt64) -> Int = "mbw_window_has_focus"

///|
extern "C" fn appkit_window_is_occluded(handle : UInt64) -> Int = "mbw_window_is_occluded"

///|
extern "C" fn appkit_window_scale_factor(handle : UInt64) -> Double = "mbw_window_scale_factor"

///|
extern "C" fn appkit_window_set_minimized(
  handle : UInt64,
  minimized : Int,
) -> Unit = "mbw_window_set_minimized"

///|
extern "C" fn appkit_window_is_minimized(handle : UInt64) -> Int = "mbw_window_is_minimized"

///|
extern "C" fn appkit_window_set_maximized(
  handle : UInt64,
  maximized : Int,
) -> Unit = "mbw_window_set_maximized"

///|
extern "C" fn appkit_window_is_maximized(handle : UInt64) -> Int = "mbw_window_is_maximized"

///|
extern "C" fn appkit_window_set_fullscreen(
  handle : UInt64,
  fullscreen : Int,
) -> Unit = "mbw_window_set_fullscreen"

///|
extern "C" fn appkit_window_is_fullscreen(handle : UInt64) -> Int = "mbw_window_is_fullscreen"

///|
extern "C" fn appkit_window_style_mask(handle : UInt64) -> UInt64 = "mbw_window_style_mask"

///|
extern "C" fn appkit_window_set_style_mask(
  handle : UInt64,
  style_mask : UInt64,
) -> Unit = "mbw_window_set_style_mask"

///|
extern "C" fn appkit_window_clear_style_mask_bits(
  handle : UInt64,
  style_mask : UInt64,
) -> Unit = "mbw_window_clear_style_mask_bits"

///|
extern "C" fn appkit_window_num_tabs(handle : UInt64) -> Int = "mbw_window_num_tabs"

///|
extern "C" fn appkit_window_set_theme(handle : UInt64, theme : Int) -> Unit = "mbw_window_set_theme"

///|
extern "C" fn appkit_window_set_has_shadow(
  handle : UInt64,
  has_shadow : Int,
) -> Unit = "mbw_window_set_has_shadow"

///|
extern "C" fn appkit_window_set_document_edited(
  handle : UInt64,
  edited : Int,
) -> Unit = "mbw_window_set_document_edited"

///|
extern "C" fn appkit_window_set_level(handle : UInt64, level : Int) -> Unit = "mbw_window_set_level"

///|
extern "C" fn appkit_window_set_movable_by_window_background(
  handle : UInt64,
  movable : Int,
) -> Unit = "mbw_window_set_movable_by_window_background"

///|
extern "C" fn appkit_window_set_accepts_first_mouse(
  handle : UInt64,
  accepts_first_mouse : Int,
) -> Unit = "mbw_window_set_accepts_first_mouse"

///|
extern "C" fn appkit_window_set_option_as_alt(
  handle : UInt64,
  option_as_alt : Int,
) -> Unit = "mbw_window_set_option_as_alt"

///|
extern "C" fn appkit_window_set_ime_purpose(
  handle : UInt64,
  purpose : Int,
) -> Unit = "mbw_window_set_ime_purpose"

///|
extern "C" fn appkit_window_set_ime_hints(handle : UInt64, hints : Int) -> Unit = "mbw_window_set_ime_hints"

///|
extern "C" fn appkit_window_set_ime_allowed(
  handle : UInt64,
  allowed : Int,
) -> Unit = "mbw_window_set_ime_allowed"

///|
extern "C" fn appkit_window_set_ime_cursor_area(
  handle : UInt64,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Unit = "mbw_window_set_ime_cursor_area"

///|
extern "C" fn appkit_window_set_titlebar_transparent(
  handle : UInt64,
  transparent : Int,
) -> Unit = "mbw_window_set_titlebar_transparent"

///|
extern "C" fn appkit_window_set_title_hidden(
  handle : UInt64,
  hidden : Int,
) -> Unit = "mbw_window_set_title_hidden"

///|
extern "C" fn appkit_window_set_titlebar_hidden(
  handle : UInt64,
  hidden : Int,
) -> Unit = "mbw_window_set_titlebar_hidden"

///|
extern "C" fn appkit_window_set_titlebar_buttons_hidden(
  handle : UInt64,
  hidden : Int,
) -> Unit = "mbw_window_set_titlebar_buttons_hidden"

///|
extern "C" fn appkit_window_set_fullsize_content_view(
  handle : UInt64,
  enabled : Int,
) -> Unit = "mbw_window_set_fullsize_content_view"

///|
extern "C" fn appkit_window_set_unified_titlebar(
  handle : UInt64,
  unified_titlebar : Int,
) -> Unit = "mbw_window_set_unified_titlebar"

///|
extern "C" fn appkit_window_set_enabled_buttons(
  handle : UInt64,
  close : Int,
  minimize : Int,
  maximize : Int,
) -> Unit = "mbw_window_set_enabled_buttons"

///|
extern "C" fn appkit_window_set_blur(handle : UInt64, blur : Int) -> Unit = "mbw_window_set_blur"

///|
extern "C" fn appkit_window_request_user_attention(request_type : Int) -> Unit = "mbw_window_request_user_attention"

///|
extern "C" fn appkit_window_set_movable(handle : UInt64, movable : Int) -> Unit = "mbw_window_set_movable"

///|
extern "C" fn appkit_window_set_transparent(
  handle : UInt64,
  transparent : Int,
) -> Unit = "mbw_window_set_transparent"

///|
extern "C" fn appkit_window_set_parent(
  handle : UInt64,
  parent_handle : UInt64,
) -> Unit = "mbw_window_set_parent"

///|
extern "C" fn appkit_window_set_content_protected(
  handle : UInt64,
  content_protected : Int,
) -> Unit = "mbw_window_set_content_protected"

///|
#borrow(identifier)
extern "C" fn appkit_window_set_tabbing_identifier(
  handle : UInt64,
  identifier : Bytes,
) -> Unit = "mbw_window_set_tabbing_identifier"

///|
extern "C" fn appkit_window_set_tabbing_mode_preferred(handle : UInt64) -> Unit = "mbw_window_set_tabbing_mode_preferred"

///|
extern "C" fn appkit_window_select_next_tab(handle : UInt64) -> Unit = "mbw_window_select_next_tab"

///|
extern "C" fn appkit_window_select_previous_tab(handle : UInt64) -> Unit = "mbw_window_select_previous_tab"

///|
extern "C" fn appkit_window_select_tab_at_index(
  handle : UInt64,
  index : Int,
) -> Unit = "mbw_window_select_tab_at_index"

///|
extern "C" fn appkit_window_set_cursor(handle : UInt64, cursor : Int) -> Unit = "mbw_window_set_cursor"

///|
#borrow(rgba)
extern "C" fn appkit_custom_cursor_create_rgba(
  rgba : Bytes,
  rgba_len : Int,
  width : Int,
  height : Int,
  hotspot_x : Int,
  hotspot_y : Int,
) -> UInt64 = "mbw_custom_cursor_create_rgba"

///|
#borrow(url)
extern "C" fn appkit_custom_cursor_create_url(
  url : Bytes,
  hotspot_x : Int,
  hotspot_y : Int,
) -> UInt64 = "mbw_custom_cursor_create_url"

///|
extern "C" fn appkit_window_set_custom_cursor(
  handle : UInt64,
  custom_cursor : UInt64,
) -> Int = "mbw_window_set_custom_cursor"

///|
extern "C" fn appkit_window_set_cursor_visible(
  handle : UInt64,
  visible : Int,
) -> Unit = "mbw_window_set_cursor_visible"

///|
extern "C" fn appkit_window_set_cursor_hittest(
  handle : UInt64,
  hittest : Int,
) -> Int = "mbw_window_set_cursor_hittest"

///|
extern "C" fn appkit_window_set_cursor_position(
  handle : UInt64,
  x : Int,
  y : Int,
) -> Int = "mbw_window_set_cursor_position"

///|
extern "C" fn appkit_window_set_cursor_grab(handle : UInt64, mode : Int) -> Int = "mbw_window_set_cursor_grab"

///|
extern "C" fn appkit_window_drag_window(handle : UInt64) -> Int = "mbw_window_drag_window"

///|
extern "C" fn appkit_window_drag_resize_window(
  handle : UInt64,
  direction : Int,
) -> Int = "mbw_window_drag_resize_window"

///|
extern "C" fn appkit_window_show_window_menu(
  handle : UInt64,
  x : Int,
  y : Int,
) -> Int = "mbw_window_show_window_menu"

///|
extern "C" fn appkit_window_current_monitor_id(handle : UInt64) -> UInt64 = "mbw_window_current_monitor_id"

///|
extern "C" fn appkit_window_theme(handle : UInt64) -> Int = "mbw_window_theme"

///|
extern "C" fn appkit_event_loop_wake_up() -> Unit = "mbw_event_loop_wake_up"

///|
extern "C" fn appkit_event_loop_wait_millis(timeout_ms : Int) -> Int = "mbw_event_loop_wait_millis"

///|
extern "C" fn appkit_application_presentation_options() -> UInt64 = "mbw_application_presentation_options"

///|
extern "C" fn appkit_set_application_presentation_options(
  options : UInt64,
) -> Unit = "mbw_set_application_presentation_options"

///|
extern "C" fn appkit_application_hide() -> Unit = "mbw_application_hide"

///|
extern "C" fn appkit_application_hide_other_applications() -> Unit = "mbw_application_hide_other_applications"

///|
extern "C" fn appkit_application_set_allows_automatic_window_tabbing(
  enabled : Int,
) -> Unit = "mbw_application_set_allows_automatic_window_tabbing"

///|
extern "C" fn appkit_application_allows_automatic_window_tabbing() -> Int = "mbw_application_allows_automatic_window_tabbing"

///|
extern "C" fn appkit_application_set_activation_policy(
  activation_policy : Int,
) -> Unit = "mbw_application_set_activation_policy"

///|
extern "C" fn appkit_application_set_activate_ignoring_other_apps(
  activate_ignoring_other_apps : Int,
) -> Unit = "mbw_application_set_activate_ignoring_other_apps"

///|
extern "C" fn appkit_application_initialize_default_menu(enabled : Int) -> Unit = "mbw_application_initialize_default_menu"

///|
extern "C" fn native_monitor_find_display_mode_handle(
  monitor_id : UInt,
  width : Int,
  height : Int,
  bit_depth : Int,
  refresh_rate_millihertz : Int,
) -> UInt64 = "mbw_find_display_mode_handle"

///|
extern "C" fn native_monitor_copy_current_display_mode_handle(
  monitor_id : UInt,
) -> UInt64 = "mbw_copy_current_display_mode_handle"

///|
extern "C" fn native_monitor_release_display_mode_handle(
  mode_handle : UInt64,
) -> Unit = "mbw_release_display_mode_handle"

///|
extern "C" fn native_monitor_capture_display(monitor_id : UInt) -> Int = "mbw_capture_display"

///|
extern "C" fn native_monitor_set_display_mode_handle(
  monitor_id : UInt,
  mode_handle : UInt64,
) -> Int = "mbw_set_display_mode_handle"

///|
extern "C" fn native_monitor_release_display_capture(monitor_id : UInt) -> Int = "mbw_release_display_capture"
