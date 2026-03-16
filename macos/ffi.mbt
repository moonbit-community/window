///|
// Port target: winit-reference/winit-appkit/src/ffi.rs
// MoonBit adaptation:
// 1. Raw pointer-like values are represented as UInt64.
// 2. kTISPropertyUnicodeKeyLayoutData is modeled by creating a CFString key.

let cursor_hidden_state : Ref[Bool] = Ref::new(false)

///|
let application_launch_finished : Ref[Bool] = Ref::new(false)

///|
let maximized_standard_frame_window_handles : Ref[Array[UInt64]] = Ref::new([])

///|
let maximized_standard_frame_xs : Ref[Array[Double]] = Ref::new([])

///|
let maximized_standard_frame_ys : Ref[Array[Double]] = Ref::new([])

///|
let maximized_standard_frame_widths : Ref[Array[Double]] = Ref::new([])

///|
let maximized_standard_frame_heights : Ref[Array[Double]] = Ref::new([])

///|
fn native_window_store_standard_frame(
  handle : UInt64,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Unit {
  match
    maximized_standard_frame_window_handles.val.search_by(window_handle => {
      window_handle == handle
    }) {
    Some(index) => {
      maximized_standard_frame_xs.val[index] = x
      maximized_standard_frame_ys.val[index] = y
      maximized_standard_frame_widths.val[index] = width
      maximized_standard_frame_heights.val[index] = height
    }
    None => {
      maximized_standard_frame_window_handles.val.push(handle)
      maximized_standard_frame_xs.val.push(x)
      maximized_standard_frame_ys.val.push(y)
      maximized_standard_frame_widths.val.push(width)
      maximized_standard_frame_heights.val.push(height)
    }
  }
}

///|
fn native_window_forget_standard_frame(handle : UInt64) -> Unit {
  match
    maximized_standard_frame_window_handles.val.search_by(window_handle => {
      window_handle == handle
    }) {
    Some(index) => {
      ignore(maximized_standard_frame_window_handles.val.remove(index))
      ignore(maximized_standard_frame_xs.val.remove(index))
      ignore(maximized_standard_frame_ys.val.remove(index))
      ignore(maximized_standard_frame_widths.val.remove(index))
      ignore(maximized_standard_frame_heights.val.remove(index))
    }
    None => ()
  }
}

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
fn native_main_run_loop_remove_observer(observer_handle : UInt64) -> Unit {
  if observer_handle != (0 : Int).to_uint64() {
    appkit_main_run_loop_remove_observer(observer_handle)
  }
}

///|
fn native_notification_center_remove_observer(observer_handle : UInt64) -> Unit {
  if observer_handle != (0 : Int).to_uint64() {
    appkit_notification_center_remove_observer(observer_handle)
  }
}

///|
fn native_create_window(width : Int, height : Int) -> UInt64 {
  appkit_create_window(width, height)
}

///|
fn native_window_set_title(handle : UInt64, title : String) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let title_string = objc_nsstring_from_string(title)
  if title_string != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle("setTitle:"),
      title_string,
    )
  }
}

///|
fn native_window_set_name(handle : UInt64, name : String) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let name_string = objc_nsstring_from_string(name)
  if name_string == (0 : Int).to_uint64() {
    return ()
  }
  let set_identifier = objc_runtime_selector_handle("setIdentifier:")
  if appkit_objc_msg_send_bool_u64(
      window,
      objc_runtime_selector_handle("respondsToSelector:"),
      set_identifier,
    ) {
    appkit_objc_msg_send_void_u64(window, set_identifier, name_string)
  }
}

///|
fn native_window_set_resizable(handle : UInt64, resizable : Bool) -> Unit {
  let resizable_mask = (8 : Int).to_uint64()
  if resizable {
    native_window_set_style_mask(
      handle,
      native_window_style_mask(handle) | resizable_mask,
    )
  } else {
    native_window_clear_style_mask_bits(handle, resizable_mask)
  }
}

///|
fn native_window_set_skip_taskbar(handle : UInt64, skip_taskbar : Bool) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let set_excluded_from_windows_menu = objc_runtime_selector_handle(
    "setExcludedFromWindowsMenu:",
  )
  if appkit_objc_msg_send_bool_u64(
      window,
      objc_runtime_selector_handle("respondsToSelector:"),
      set_excluded_from_windows_menu,
    ) {
    appkit_objc_msg_send_void_bool(
      window, set_excluded_from_windows_menu, skip_taskbar,
    )
  }
  let transient_behavior = (1 << 3).to_uint64()
  let ignores_cycle_behavior = (1 << 6).to_uint64()
  let mut behavior = appkit_objc_msg_send_u64(
    window,
    objc_runtime_selector_handle("collectionBehavior"),
  )
  if skip_taskbar {
    behavior = behavior | transient_behavior
    behavior = behavior | ignores_cycle_behavior
  } else {
    if (behavior & transient_behavior) != (0 : Int).to_uint64() {
      behavior = behavior - transient_behavior
    }
    if (behavior & ignores_cycle_behavior) != (0 : Int).to_uint64() {
      behavior = behavior - ignores_cycle_behavior
    }
  }
  appkit_objc_msg_send_void_u64(
    window,
    objc_runtime_selector_handle("setCollectionBehavior:"),
    behavior,
  )
}

///|
fn native_window_set_clip_children(
  handle : UInt64,
  clip_children : Bool,
) -> Unit {
  let content_view = native_window_content_view_objc_handle(handle)
  if content_view == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_bool(
    content_view,
    objc_runtime_selector_handle("setWantsLayer:"),
    true,
  )
  let layer = appkit_objc_msg_send_u64(
    content_view,
    objc_runtime_selector_handle("layer"),
  )
  if layer != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_bool(
      layer,
      objc_runtime_selector_handle("setMasksToBounds:"),
      clip_children,
    )
  }
}

///|
fn native_window_set_content_size(
  handle : UInt64,
  width : Int,
  height : Int,
) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_size(
    window,
    objc_runtime_selector_handle("setContentSize:"),
    if width > 0 {
      width.to_double()
    } else {
      1.0
    },
    if height > 0 {
      height.to_double()
    } else {
      1.0
    },
  )
}

///|
fn native_window_set_min_content_size(
  handle : UInt64,
  width : Int,
  height : Int,
) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_size(
    window,
    objc_runtime_selector_handle("setContentMinSize:"),
    if width > 0 {
      width.to_double()
    } else {
      0.0
    },
    if height > 0 {
      height.to_double()
    } else {
      0.0
    },
  )
}

///|
fn native_window_set_max_content_size(
  handle : UInt64,
  width : Int,
  height : Int,
) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let max_value = native_cgfloat_max()
  appkit_objc_msg_send_void_size(
    window,
    objc_runtime_selector_handle("setContentMaxSize:"),
    if width > 0 {
      width.to_double()
    } else {
      max_value
    },
    if height > 0 {
      height.to_double()
    } else {
      max_value
    },
  )
}

///|
fn native_window_set_resize_increments(
  handle : UInt64,
  width : Int,
  height : Int,
) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_size(
    window,
    objc_runtime_selector_handle("setContentResizeIncrements:"),
    if width > 0 {
      width.to_double()
    } else {
      1.0
    },
    if height > 0 {
      height.to_double()
    } else {
      1.0
    },
  )
}

///|
fn native_window_set_position(handle : UInt64, x : Int, y : Int) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_point(
    window,
    objc_runtime_selector_handle("setFrameOrigin:"),
    x.to_double(),
    y.to_double(),
  )
}

///|
fn native_window_content_width(handle : UInt64) -> Int {
  let content_view = native_window_content_view_objc_handle(handle)
  if content_view == (0 : Int).to_uint64() {
    return 800
  }
  appkit_objc_msg_send_rect_width(
    content_view,
    objc_runtime_selector_handle("frame"),
  ).to_int()
}

///|
fn native_window_content_height(handle : UInt64) -> Int {
  let content_view = native_window_content_view_objc_handle(handle)
  if content_view == (0 : Int).to_uint64() {
    return 600
  }
  appkit_objc_msg_send_rect_height(
    content_view,
    objc_runtime_selector_handle("frame"),
  ).to_int()
}

///|
fn native_window_min_content_width(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  let width = appkit_objc_msg_send_size_width(
    window,
    objc_runtime_selector_handle("contentMinSize"),
  )
  if width > 0.0 {
    width.to_int()
  } else {
    0
  }
}

///|
fn native_window_min_content_height(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  let height = appkit_objc_msg_send_size_height(
    window,
    objc_runtime_selector_handle("contentMinSize"),
  )
  if height > 0.0 {
    height.to_int()
  } else {
    0
  }
}

///|
fn native_window_max_content_width(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  let width = appkit_objc_msg_send_size_width(
    window,
    objc_runtime_selector_handle("contentMaxSize"),
  )
  if width >= native_cgfloat_max() / 2.0 {
    0
  } else {
    width.to_int()
  }
}

///|
fn native_window_max_content_height(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  let height = appkit_objc_msg_send_size_height(
    window,
    objc_runtime_selector_handle("contentMaxSize"),
  )
  if height >= native_cgfloat_max() / 2.0 {
    0
  } else {
    height.to_int()
  }
}

///|
fn native_window_outer_width(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  appkit_objc_msg_send_rect_width(window, objc_runtime_selector_handle("frame")).to_int()
}

///|
fn native_window_outer_height(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  appkit_objc_msg_send_rect_height(
    window,
    objc_runtime_selector_handle("frame"),
  ).to_int()
}

///|
fn native_window_resize_increment_width(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  let width = appkit_objc_msg_send_size_width(
    window,
    objc_runtime_selector_handle("contentResizeIncrements"),
  )
  if width > 1.0 {
    width.to_int()
  } else {
    0
  }
}

///|
fn native_window_resize_increment_height(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  let height = appkit_objc_msg_send_size_height(
    window,
    objc_runtime_selector_handle("contentResizeIncrements"),
  )
  if height > 1.0 {
    height.to_int()
  } else {
    0
  }
}

///|
fn native_window_safe_area_top(handle : UInt64) -> Int {
  let content_view = native_window_content_view_objc_handle(handle)
  if content_view == (0 : Int).to_uint64() {
    return 0
  }
  let safe_area_insets = objc_runtime_selector_handle("safeAreaInsets")
  if appkit_objc_msg_send_bool_u64(
      content_view,
      objc_runtime_selector_handle("respondsToSelector:"),
      safe_area_insets,
    ) ==
    false {
    return 0
  }
  appkit_objc_msg_send_edge_insets_top(content_view, safe_area_insets).to_int()
}

///|
fn native_window_safe_area_left(handle : UInt64) -> Int {
  let content_view = native_window_content_view_objc_handle(handle)
  if content_view == (0 : Int).to_uint64() {
    return 0
  }
  let safe_area_insets = objc_runtime_selector_handle("safeAreaInsets")
  if appkit_objc_msg_send_bool_u64(
      content_view,
      objc_runtime_selector_handle("respondsToSelector:"),
      safe_area_insets,
    ) ==
    false {
    return 0
  }
  appkit_objc_msg_send_edge_insets_left(content_view, safe_area_insets).to_int()
}

///|
fn native_window_safe_area_bottom(handle : UInt64) -> Int {
  let content_view = native_window_content_view_objc_handle(handle)
  if content_view == (0 : Int).to_uint64() {
    return 0
  }
  let safe_area_insets = objc_runtime_selector_handle("safeAreaInsets")
  if appkit_objc_msg_send_bool_u64(
      content_view,
      objc_runtime_selector_handle("respondsToSelector:"),
      safe_area_insets,
    ) ==
    false {
    return 0
  }
  appkit_objc_msg_send_edge_insets_bottom(content_view, safe_area_insets).to_int()
}

///|
fn native_window_safe_area_right(handle : UInt64) -> Int {
  let content_view = native_window_content_view_objc_handle(handle)
  if content_view == (0 : Int).to_uint64() {
    return 0
  }
  let safe_area_insets = objc_runtime_selector_handle("safeAreaInsets")
  if appkit_objc_msg_send_bool_u64(
      content_view,
      objc_runtime_selector_handle("respondsToSelector:"),
      safe_area_insets,
    ) ==
    false {
    return 0
  }
  appkit_objc_msg_send_edge_insets_right(content_view, safe_area_insets).to_int()
}

///|
fn native_window_x(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  appkit_objc_msg_send_rect_x(window, objc_runtime_selector_handle("frame")).to_int()
}

///|
fn native_window_y(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  appkit_objc_msg_send_rect_y(window, objc_runtime_selector_handle("frame")).to_int()
}

///|
fn native_window_title(handle : UInt64) -> String {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ""
  }
  let title = appkit_objc_msg_send_u64(
    window,
    objc_runtime_selector_handle("title"),
  )
  @utf8.decode(objc_utf8_bytes_from_object(title)[:], ignore_bom=false) catch {
    _ => ""
  }
}

///|
fn native_window_set_tabbing_identifier(
  handle : UInt64,
  identifier : String,
) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let identifier_string = objc_nsstring_from_string(identifier)
  if identifier_string != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle("setTabbingIdentifier:"),
      identifier_string,
    )
  }
}

///|
fn native_window_tabbing_identifier(handle : UInt64) -> String {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ""
  }
  let identifier = appkit_objc_msg_send_u64(
    window,
    objc_runtime_selector_handle("tabbingIdentifier"),
  )
  @utf8.decode(objc_utf8_bytes_from_object(identifier)[:], ignore_bom=false) catch {
    _ => ""
  }
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
fn native_cursor_objc_handle_from_kind(cursor : Int) -> UInt64 {
  let ns_cursor_class = objc_runtime_class_handle("NSCursor")
  if ns_cursor_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let selector_name = if cursor == 10 {
    "openHandCursor"
  } else if cursor == 11 {
    "closedHandCursor"
  } else if cursor == 12 || cursor == 19 || cursor == 20 || cursor == 24 {
    "resizeLeftRightCursor"
  } else if cursor == 13 || cursor == 16 || cursor == 21 || cursor == 25 {
    "resizeUpDownCursor"
  } else if cursor == 29 {
    "pointingHandCursor"
  } else if cursor == 30 {
    "IBeamCursor"
  } else if cursor == 31 {
    "crosshairCursor"
  } else if cursor == 33 {
    "operationNotAllowedCursor"
  } else {
    "arrowCursor"
  }
  appkit_objc_msg_send_u64(
    ns_cursor_class,
    objc_runtime_selector_handle(selector_name),
  )
}

///|
fn native_window_apply_cursor_obj(handle : UInt64, cursor_obj : UInt64) -> Bool {
  if cursor_obj == (0 : Int).to_uint64() {
    return false
  }
  let content_view = native_window_content_view_objc_handle(handle)
  if content_view == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_void(cursor_obj, objc_runtime_selector_handle("set"))
  appkit_objc_msg_send_void(
    content_view,
    objc_runtime_selector_handle("discardCursorRects"),
  )
  let bounds = objc_runtime_selector_handle("bounds")
  appkit_objc_msg_send_void_rect_u64(
    content_view,
    objc_runtime_selector_handle("addCursorRect:cursor:"),
    appkit_objc_msg_send_rect_x(content_view, bounds),
    appkit_objc_msg_send_rect_y(content_view, bounds),
    appkit_objc_msg_send_rect_width(content_view, bounds),
    appkit_objc_msg_send_rect_height(content_view, bounds),
    cursor_obj,
  )
  true
}

///|
fn native_window_set_cursor(handle : UInt64, cursor : Int) -> Unit {
  ignore(
    native_window_apply_cursor_obj(
      handle,
      native_cursor_objc_handle_from_kind(cursor),
    ),
  )
}

///|
fn native_window_set_custom_cursor(
  handle : UInt64,
  custom_cursor : UInt64,
) -> Bool {
  let ns_cursor_class = objc_runtime_class_handle("NSCursor")
  if custom_cursor == (0 : Int).to_uint64() ||
    ns_cursor_class == (0 : Int).to_uint64() {
    return false
  }
  if appkit_objc_msg_send_bool_u64(
      custom_cursor,
      objc_runtime_selector_handle("isKindOfClass:"),
      ns_cursor_class,
    ) ==
    false {
    return false
  }
  native_window_apply_cursor_obj(handle, custom_cursor)
}

///|
fn native_window_set_cursor_visible(handle : UInt64, visible : Bool) -> Unit {
  ignore(handle)
  if visible && cursor_hidden_state.val {
    let ns_cursor = objc_runtime_class_handle("NSCursor")
    if ns_cursor != (0 : Int).to_uint64() {
      appkit_objc_msg_send_void(
        ns_cursor,
        objc_runtime_selector_handle("unhide"),
      )
      cursor_hidden_state.val = false
    }
  } else if !visible && !cursor_hidden_state.val {
    let ns_cursor = objc_runtime_class_handle("NSCursor")
    if ns_cursor != (0 : Int).to_uint64() {
      appkit_objc_msg_send_void(ns_cursor, objc_runtime_selector_handle("hide"))
      cursor_hidden_state.val = true
    }
  }
}

///|
fn native_window_cursor_visible(handle : UInt64) -> Bool {
  ignore(handle)
  !cursor_hidden_state.val
}

///|
fn native_window_set_cursor_grab(handle : UInt64, mode : Int) -> Bool {
  ignore(handle)
  if mode == 0 {
    native_cg_associate_mouse_and_mouse_cursor_position(true) == 0
  } else if mode == 1 {
    native_cg_associate_mouse_and_mouse_cursor_position(false) == 0
  } else {
    false
  }
}

///|
fn native_window_set_cursor_position(handle : UInt64, x : Int, y : Int) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  let frame_selector = objc_runtime_selector_handle("frame")
  let frame_x = appkit_objc_msg_send_rect_x(window, frame_selector)
  let frame_y = appkit_objc_msg_send_rect_y(window, frame_selector)
  let frame_width = appkit_objc_msg_send_rect_width(window, frame_selector)
  let frame_height = appkit_objc_msg_send_rect_height(window, frame_selector)
  let content_rect_selector = objc_runtime_selector_handle(
    "contentRectForFrameRect:",
  )
  let content_x = appkit_objc_msg_send_rect_x_rect(
    window, content_rect_selector, frame_x, frame_y, frame_width, frame_height,
  )
  let content_y = appkit_objc_msg_send_rect_y_rect(
    window, content_rect_selector, frame_x, frame_y, frame_width, frame_height,
  )
  let content_height = appkit_objc_msg_send_rect_height_rect(
    window, content_rect_selector, frame_x, frame_y, frame_width, frame_height,
  )
  if native_cg_warp_mouse_cursor_position(
      content_x + x.to_double(),
      content_y + content_height - y.to_double(),
    ) ==
    false {
    return false
  }
  native_cg_associate_mouse_and_mouse_cursor_position(true) == 0
}

///|
fn native_window_set_maximized(handle : UInt64, maximized : Bool) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let is_zoomed = native_window_is_maximized(handle)
  if is_zoomed == maximized {
    return ()
  }

  let style_mask = native_window_style_mask(handle)
  if (style_mask & (8 : Int).to_uint64()) != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle("zoom:"),
      (0 : Int).to_uint64(),
    )
    return ()
  }

  let set_frame_display = objc_runtime_selector_handle("setFrame:display:")
  if maximized {
    if !is_zoomed {
      let frame_selector = objc_runtime_selector_handle("frame")
      native_window_store_standard_frame(
        handle,
        appkit_objc_msg_send_rect_x(window, frame_selector),
        appkit_objc_msg_send_rect_y(window, frame_selector),
        appkit_objc_msg_send_rect_width(window, frame_selector),
        appkit_objc_msg_send_rect_height(window, frame_selector),
      )
    }
    let mut screen = appkit_objc_msg_send_u64(
      window,
      objc_runtime_selector_handle("screen"),
    )
    if screen == (0 : Int).to_uint64() {
      let ns_screen_class = objc_runtime_class_handle("NSScreen")
      if ns_screen_class != (0 : Int).to_uint64() {
        screen = appkit_objc_msg_send_u64(
          ns_screen_class,
          objc_runtime_selector_handle("mainScreen"),
        )
      }
    }
    if screen != (0 : Int).to_uint64() {
      let visible_frame = objc_runtime_selector_handle("visibleFrame")
      appkit_objc_msg_send_void_rect_bool(
        window,
        set_frame_display,
        appkit_objc_msg_send_rect_x(screen, visible_frame),
        appkit_objc_msg_send_rect_y(screen, visible_frame),
        appkit_objc_msg_send_rect_width(screen, visible_frame),
        appkit_objc_msg_send_rect_height(screen, visible_frame),
        false,
      )
    }
    return ()
  }

  match
    maximized_standard_frame_window_handles.val.search_by(window_handle => {
      window_handle == handle
    }) {
    Some(index) =>
      appkit_objc_msg_send_void_rect_bool(
        window,
        set_frame_display,
        maximized_standard_frame_xs.val[index],
        maximized_standard_frame_ys.val[index],
        maximized_standard_frame_widths.val[index],
        maximized_standard_frame_heights.val[index],
        false,
      )
    None =>
      appkit_objc_msg_send_void_rect_bool(
        window, set_frame_display, 100.0, 100.0, 800.0, 600.0, false,
      )
  }
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
fn native_copy_display_mode_count(monitor_id : UInt64) -> Int {
  let count = native_monitor_copy_display_mode_count(monitor_id.to_uint())
  if count > 0 {
    count
  } else {
    0
  }
}

///|
fn native_copy_display_mode_handle_at(
  monitor_id : UInt64,
  index : Int,
) -> UInt64 {
  native_monitor_copy_display_mode_handle_at(monitor_id.to_uint(), index)
}

///|
fn native_display_mode_width(mode_handle : UInt64) -> Int {
  let width = native_monitor_display_mode_width(mode_handle)
  if width > 0 {
    width
  } else {
    0
  }
}

///|
fn native_display_mode_height(mode_handle : UInt64) -> Int {
  let height = native_monitor_display_mode_height(mode_handle)
  if height > 0 {
    height
  } else {
    0
  }
}

///|
fn native_display_mode_bit_depth(mode_handle : UInt64) -> Int {
  let bit_depth = native_monitor_display_mode_bit_depth(mode_handle)
  if bit_depth > 0 {
    bit_depth
  } else {
    0
  }
}

///|
fn native_display_mode_refresh_rate_millihertz(mode_handle : UInt64) -> Int {
  let refresh_rate_millihertz = native_monitor_display_mode_refresh_rate_millihertz(
    mode_handle,
  )
  if refresh_rate_millihertz > 0 {
    refresh_rate_millihertz
  } else {
    0
  }
}

///|
fn ffi_normalize_display_id(display_id : UInt64) -> UInt64 {
  if display_id == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let uuid = cg_display_create_uuid_from_display_id(display_id)
  if uuid == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let normalized = cg_display_get_display_id_from_uuid(uuid)
  cf_release(uuid)
  normalized
}

///|
fn native_monitor_ns_screen(monitor_id : UInt64) -> UInt64 {
  if monitor_id == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let normalized_monitor_id = ffi_normalize_display_id(monitor_id)
  if normalized_monitor_id == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let ns_screen_class = objc_runtime_class_handle("NSScreen")
  if ns_screen_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let screens = appkit_objc_msg_send_u64(
    ns_screen_class,
    objc_runtime_selector_handle("screens"),
  )
  if screens == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let count = appkit_objc_msg_send_i64(
    screens,
    objc_runtime_selector_handle("count"),
  ).to_int()
  if count <= 0 {
    return (0 : Int).to_uint64()
  }
  let key = objc_nsstring_from_string("NSScreenNumber")
  if key == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let object_at_index = objc_runtime_selector_handle("objectAtIndex:")
  let device_description = objc_runtime_selector_handle("deviceDescription")
  let object_for_key = objc_runtime_selector_handle("objectForKey:")
  let unsigned_int_value = objc_runtime_selector_handle("unsignedIntValue")
  let mut index = 0
  while index < count {
    let screen = appkit_objc_msg_send_u64_u64(
      screens,
      object_at_index,
      index.to_uint64(),
    )
    if screen != (0 : Int).to_uint64() {
      let description = appkit_objc_msg_send_u64(screen, device_description)
      if description != (0 : Int).to_uint64() {
        let number = appkit_objc_msg_send_u64_u64(
          description, object_for_key, key,
        )
        if number != (0 : Int).to_uint64() {
          let screen_display_id = appkit_objc_msg_send_u64(
            number, unsigned_int_value,
          )
          let normalized_screen_id = ffi_normalize_display_id(screen_display_id)
          if normalized_screen_id == normalized_monitor_id {
            return screen
          }
        }
      }
    }
    index = index + 1
  }
  (0 : Int).to_uint64()
}

///|
fn native_display_refresh_rate_millihertz(monitor_id : UInt64) -> Int {
  let maximum_frames_per_second = objc_runtime_selector_handle(
    "maximumFramesPerSecond",
  )
  let mut screen = native_monitor_ns_screen(monitor_id)
  if screen == (0 : Int).to_uint64() {
    let ns_screen_class = objc_runtime_class_handle("NSScreen")
    if ns_screen_class == (0 : Int).to_uint64() {
      return 0
    }
    screen = appkit_objc_msg_send_u64(
      ns_screen_class,
      objc_runtime_selector_handle("mainScreen"),
    )
  }
  if screen == (0 : Int).to_uint64() ||
    appkit_objc_msg_send_bool_u64(
      screen,
      objc_runtime_selector_handle("respondsToSelector:"),
      maximum_frames_per_second,
    ) ==
    false {
    return 0
  }
  let frames_per_second = appkit_objc_msg_send_i64(
    screen, maximum_frames_per_second,
  ).to_int()
  if frames_per_second <= 0 {
    return 0
  }
  if frames_per_second > 2_147_483 {
    2_147_483_647
  } else {
    frames_per_second * 1000
  }
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
fn objc_runtime_class_handle(name : String) -> UInt64 {
  appkit_objc_get_class(@utf8.encode(name[:], bom=false))
}

///|
fn objc_runtime_selector_handle(name : String) -> UInt64 {
  appkit_objc_sel_register_name(@utf8.encode(name[:], bom=false))
}

///|
fn native_application_shared_handle() -> UInt64 {
  let app_class = objc_runtime_class_handle("NSApplication")
  if app_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(
    app_class,
    objc_runtime_selector_handle("sharedApplication"),
  )
}

///|
fn native_window_objc_handle(handle : UInt64) -> UInt64 {
  if handle == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let window_or_self = appkit_objc_msg_send_u64(
    handle,
    objc_runtime_selector_handle("window"),
  )
  if window_or_self == (0 : Int).to_uint64() {
    handle
  } else {
    window_or_self
  }
}

///|
fn native_window_content_view_objc_handle(handle : UInt64) -> UInt64 {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(window, objc_runtime_selector_handle("contentView"))
}

///|
fn native_window_delegate_objc_handle(handle : UInt64) -> UInt64 {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(window, objc_runtime_selector_handle("delegate"))
}

///|
fn objc_utf8_bytes_from_object(handle : UInt64) -> Bytes {
  if handle == (0 : Int).to_uint64() {
    return b""
  }
  native_objc_copy_utf8_bytes(handle)
}

///|
fn objc_nsstring_from_string(value : String) -> UInt64 {
  let ns_string = objc_runtime_class_handle("NSString")
  if ns_string == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64_bytes(
    ns_string,
    objc_runtime_selector_handle("stringWithUTF8String:"),
    @utf8.encode(value[:], bom=false),
  )
}

///|
fn objc_theme_from_appearance_handle(appearance : UInt64) -> Int {
  if appearance == (0 : Int).to_uint64() {
    return 0
  }
  let name_handle = appkit_objc_msg_send_u64(
    appearance,
    objc_runtime_selector_handle("name"),
  )
  if name_handle == (0 : Int).to_uint64() {
    return 0
  }
  let name = @utf8.decode_lossy(
    objc_utf8_bytes_from_object(name_handle)[:],
    ignore_bom=false,
  )
  if name == "NSAppearanceNameDarkAqua" ||
    name == "NSAppearanceNameVibrantDark" ||
    name == "NSAppearanceNameAccessibilityHighContrastDarkAqua" {
    2
  } else if name == "NSAppearanceNameAqua" ||
    name == "NSAppearanceNameVibrantLight" ||
    name == "NSAppearanceNameAccessibilityHighContrastAqua" {
    1
  } else {
    0
  }
}

///|
fn native_application_presentation_options() -> UInt64 {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(
    app,
    objc_runtime_selector_handle("presentationOptions"),
  )
}

///|
fn native_set_application_presentation_options(options : UInt64) -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("setPresentationOptions:"),
    options,
  )
}

///|
fn native_application_hide() -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("hide:"),
    (0 : Int).to_uint64(),
  )
}

///|
fn native_application_hide_other_applications() -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("hideOtherApplications:"),
    (0 : Int).to_uint64(),
  )
}

///|
fn native_application_set_allows_automatic_window_tabbing(
  enabled : Bool,
) -> Unit {
  let window_class = objc_runtime_class_handle("NSWindow")
  if window_class == (0 : Int).to_uint64() {
    return ()
  }
  let responds_to_selector = objc_runtime_selector_handle("respondsToSelector:")
  let setter = objc_runtime_selector_handle("setAllowsAutomaticWindowTabbing:")
  if appkit_objc_msg_send_bool_u64(window_class, responds_to_selector, setter) {
    appkit_objc_msg_send_void_bool(window_class, setter, enabled)
  }
}

///|
fn native_application_allows_automatic_window_tabbing() -> Bool {
  let window_class = objc_runtime_class_handle("NSWindow")
  if window_class == (0 : Int).to_uint64() {
    return false
  }
  let responds_to_selector = objc_runtime_selector_handle("respondsToSelector:")
  let getter = objc_runtime_selector_handle("allowsAutomaticWindowTabbing")
  if appkit_objc_msg_send_bool_u64(window_class, responds_to_selector, getter) ==
    false {
    return false
  }
  appkit_objc_msg_send_bool(window_class, getter)
}

///|
fn native_application_is_bundled() -> Bool {
  let running_application_class = objc_runtime_class_handle(
    "NSRunningApplication",
  )
  if running_application_class == (0 : Int).to_uint64() {
    return false
  }
  let app = appkit_objc_msg_send_u64(
    running_application_class,
    objc_runtime_selector_handle("currentApplication"),
  )
  if app == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_u64(
    app,
    objc_runtime_selector_handle("bundleIdentifier"),
  ) !=
  (0 : Int).to_uint64()
}

///|
fn native_application_set_activation_policy(activation_policy : Int) -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  let policy = if activation_policy < 0 { 0 } else { activation_policy }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("setActivationPolicy:"),
    policy.to_uint64(),
  )
}

///|
fn native_application_set_activate_ignoring_other_apps(
  activate_ignoring_other_apps : Bool,
) -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_bool(
    app,
    objc_runtime_selector_handle("activateIgnoringOtherApps:"),
    activate_ignoring_other_apps,
  )
}

///|
fn native_application_theme() -> Int {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return 0
  }
  let appearance = appkit_objc_msg_send_u64(
    app,
    objc_runtime_selector_handle("effectiveAppearance"),
  )
  objc_theme_from_appearance_handle(appearance)
}

///|
fn native_application_close_all_windows() -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  let windows = appkit_objc_msg_send_u64(
    app,
    objc_runtime_selector_handle("windows"),
  )
  if windows == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    windows,
    objc_runtime_selector_handle("makeObjectsPerformSelector:"),
    objc_runtime_selector_handle("close"),
  )
}

///|
fn native_appkit_new_menu(title : String) -> UInt64 {
  let ns_menu_class = objc_runtime_class_handle("NSMenu")
  if ns_menu_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let menu_alloc = appkit_objc_msg_send_u64(
    ns_menu_class,
    objc_runtime_selector_handle("alloc"),
  )
  if menu_alloc == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let title_handle = objc_nsstring_from_string(title)
  if title_handle == (0 : Int).to_uint64() {
    appkit_objc_release_object(menu_alloc)
    return (0 : Int).to_uint64()
  }
  let menu = appkit_objc_msg_send_u64_u64(
    menu_alloc,
    objc_runtime_selector_handle("initWithTitle:"),
    title_handle,
  )
  if menu == (0 : Int).to_uint64() {
    appkit_objc_release_object(menu_alloc)
  }
  menu
}

///|
fn native_appkit_new_menu_item(
  title : String,
  action_selector_name : String,
  key_equivalent : String,
  target : UInt64,
  key_modifier_mask : Int,
) -> UInt64 {
  let ns_menu_item_class = objc_runtime_class_handle("NSMenuItem")
  if ns_menu_item_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let item_alloc = appkit_objc_msg_send_u64(
    ns_menu_item_class,
    objc_runtime_selector_handle("alloc"),
  )
  if item_alloc == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let item = appkit_objc_msg_send_u64(
    item_alloc,
    objc_runtime_selector_handle("init"),
  )
  if item == (0 : Int).to_uint64() {
    appkit_objc_release_object(item_alloc)
    return (0 : Int).to_uint64()
  }
  let title_handle = objc_nsstring_from_string(title)
  if title_handle != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_u64(
      item,
      objc_runtime_selector_handle("setTitle:"),
      title_handle,
    )
  }
  if action_selector_name != "" {
    appkit_objc_msg_send_void_u64(
      item,
      objc_runtime_selector_handle("setAction:"),
      objc_runtime_selector_handle(action_selector_name),
    )
  }
  let key_handle = objc_nsstring_from_string(key_equivalent)
  if key_handle != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_u64(
      item,
      objc_runtime_selector_handle("setKeyEquivalent:"),
      key_handle,
    )
  }
  if target != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_u64(
      item,
      objc_runtime_selector_handle("setTarget:"),
      target,
    )
  }
  if key_modifier_mask >= 0 {
    appkit_objc_msg_send_void_u64(
      item,
      objc_runtime_selector_handle("setKeyEquivalentModifierMask:"),
      key_modifier_mask.to_uint64(),
    )
  }
  item
}

///|
fn native_appkit_add_menu_item(menu : UInt64, item : UInt64) -> Unit {
  if menu == (0 : Int).to_uint64() || item == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    menu,
    objc_runtime_selector_handle("addItem:"),
    item,
  )
}

///|
fn native_appkit_add_separator_item(menu : UInt64) -> Unit {
  if menu == (0 : Int).to_uint64() {
    return ()
  }
  let ns_menu_item_class = objc_runtime_class_handle("NSMenuItem")
  if ns_menu_item_class == (0 : Int).to_uint64() {
    return ()
  }
  let separator = appkit_objc_msg_send_u64(
    ns_menu_item_class,
    objc_runtime_selector_handle("separatorItem"),
  )
  native_appkit_add_menu_item(menu, separator)
}

///|
fn native_application_initialize_default_menu(enabled : Bool) -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  if !enabled {
    appkit_objc_msg_send_void_u64(
      app,
      objc_runtime_selector_handle("setMainMenu:"),
      (0 : Int).to_uint64(),
    )
    return ()
  }
  let process_info_class = objc_runtime_class_handle("NSProcessInfo")
  let process_info = if process_info_class == (0 : Int).to_uint64() {
    (0 : Int).to_uint64()
  } else {
    appkit_objc_msg_send_u64(
      process_info_class,
      objc_runtime_selector_handle("processInfo"),
    )
  }
  let process_name_handle = if process_info == (0 : Int).to_uint64() {
    (0 : Int).to_uint64()
  } else {
    appkit_objc_msg_send_u64(
      process_info,
      objc_runtime_selector_handle("processName"),
    )
  }
  let process_name = @utf8.decode(
    objc_utf8_bytes_from_object(process_name_handle)[:],
    ignore_bom=false,
  ) catch {
    _ => ""
  }
  let app_name = if process_name == "" { "Application" } else { process_name }
  let main_menu = native_appkit_new_menu("")
  if main_menu == (0 : Int).to_uint64() {
    return ()
  }
  let app_menu_item = native_appkit_new_menu_item(
    "",
    "",
    "",
    (0 : Int).to_uint64(),
    -1,
  )
  let app_menu = native_appkit_new_menu("")
  if app_menu_item != (0 : Int).to_uint64() {
    native_appkit_add_menu_item(main_menu, app_menu_item)
    if app_menu != (0 : Int).to_uint64() {
      appkit_objc_msg_send_void_u64(
        app_menu_item,
        objc_runtime_selector_handle("setSubmenu:"),
        app_menu,
      )
    }
  }
  if app_menu != (0 : Int).to_uint64() {
    let about_item = native_appkit_new_menu_item(
      "About " + app_name,
      "orderFrontStandardAboutPanel:",
      "",
      app,
      -1,
    )
    if about_item != (0 : Int).to_uint64() {
      native_appkit_add_menu_item(app_menu, about_item)
      appkit_objc_release_object(about_item)
    }
    native_appkit_add_separator_item(app_menu)
    let services_item = native_appkit_new_menu_item(
      "Services",
      "",
      "",
      (0 : Int).to_uint64(),
      -1,
    )
    let services_menu = native_appkit_new_menu("Services")
    if services_menu != (0 : Int).to_uint64() {
      appkit_objc_msg_send_void_u64(
        app,
        objc_runtime_selector_handle("setServicesMenu:"),
        services_menu,
      )
      if services_item != (0 : Int).to_uint64() {
        appkit_objc_msg_send_void_u64(
          services_item,
          objc_runtime_selector_handle("setSubmenu:"),
          services_menu,
        )
      }
      appkit_objc_release_object(services_menu)
    }
    if services_item != (0 : Int).to_uint64() {
      native_appkit_add_menu_item(app_menu, services_item)
      appkit_objc_release_object(services_item)
    }
    let hide_item = native_appkit_new_menu_item(
      "Hide " + app_name,
      "hide:",
      "h",
      app,
      -1,
    )
    if hide_item != (0 : Int).to_uint64() {
      native_appkit_add_menu_item(app_menu, hide_item)
      appkit_objc_release_object(hide_item)
    }
    let option_command_modifier_mask = 524288 + 1_048_576
    let hide_others_item = native_appkit_new_menu_item(
      "Hide Others", "hideOtherApplications:", "h", app, option_command_modifier_mask,
    )
    if hide_others_item != (0 : Int).to_uint64() {
      native_appkit_add_menu_item(app_menu, hide_others_item)
      appkit_objc_release_object(hide_others_item)
    }
    let show_all_item = native_appkit_new_menu_item(
      "Show All", "unhideAllApplications:", "", app, -1,
    )
    if show_all_item != (0 : Int).to_uint64() {
      native_appkit_add_menu_item(app_menu, show_all_item)
      appkit_objc_release_object(show_all_item)
    }
    native_appkit_add_separator_item(app_menu)
    let quit_item = native_appkit_new_menu_item(
      "Quit " + app_name,
      "terminate:",
      "q",
      app,
      -1,
    )
    if quit_item != (0 : Int).to_uint64() {
      native_appkit_add_menu_item(app_menu, quit_item)
      appkit_objc_release_object(quit_item)
    }
  }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("setMainMenu:"),
    main_menu,
  )
  if app_menu != (0 : Int).to_uint64() {
    appkit_objc_release_object(app_menu)
  }
  if app_menu_item != (0 : Int).to_uint64() {
    appkit_objc_release_object(app_menu_item)
  }
  appkit_objc_release_object(main_menu)
}

///|
fn native_post_application_defined_event(at_start : Bool) -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  let ns_event_class = objc_runtime_class_handle("NSEvent")
  if ns_event_class == (0 : Int).to_uint64() {
    return ()
  }
  // NSEventTypeApplicationDefined = 15.
  let event = appkit_objc_msg_send_u64_i32_double_double_i32_u64_i32_i32_u64(
    ns_event_class,
    objc_runtime_selector_handle(
      "otherEventWithType:location:modifierFlags:timestamp:windowNumber:context:subtype:data1:data2:",
    ),
    15,
    0.0,
    0.0,
    0,
    (0 : Int).to_uint64(),
    0,
    0,
    (0 : Int).to_uint64(),
  )
  if event == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64_u64(
    app,
    objc_runtime_selector_handle("postEvent:atStart:"),
    event,
    if at_start {
      (1 : Int).to_uint64()
    } else {
      (0 : Int).to_uint64()
    },
  )
}

///|
fn native_application_run() -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  if !application_launch_finished.val {
    appkit_objc_msg_send_void(
      app,
      objc_runtime_selector_handle("finishLaunching"),
    )
    application_launch_finished.val = true
  }
  appkit_objc_msg_send_void(app, objc_runtime_selector_handle("run"))
}

///|
fn native_application_stop_immediately() -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  if !application_launch_finished.val {
    appkit_objc_msg_send_void(
      app,
      objc_runtime_selector_handle("finishLaunching"),
    )
    application_launch_finished.val = true
  }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("stop:"),
    (0 : Int).to_uint64(),
  )
  native_post_application_defined_event(true)
}

///|
fn native_window_request_user_attention(request_type : Int) -> Unit {
  if request_type == 0 {
    return ()
  }
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  // AppKit constants (NSRequestUserAttentionType):
  // NSCriticalRequest = 0, NSInformationalRequest = 10.
  let native_request_type = if request_type == 1 { 0 } else { 10 }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("requestUserAttention:"),
    native_request_type.to_uint64(),
  )
}

///|
fn native_window_theme(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  let appearance = appkit_objc_msg_send_u64(
    window,
    objc_runtime_selector_handle("effectiveAppearance"),
  )
  objc_theme_from_appearance_handle(appearance)
}

///|
fn native_window_set_theme(handle : UInt64, theme : Int) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  if theme != 1 && theme != 2 {
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle("setAppearance:"),
      (0 : Int).to_uint64(),
    )
    return ()
  }
  let appearance_name = if theme == 1 {
    "NSAppearanceNameAqua"
  } else {
    "NSAppearanceNameDarkAqua"
  }
  let appearance_name_string = objc_nsstring_from_string(appearance_name)
  if appearance_name_string == (0 : Int).to_uint64() {
    return ()
  }
  let appearance_class = objc_runtime_class_handle("NSAppearance")
  if appearance_class == (0 : Int).to_uint64() {
    return ()
  }
  let appearance = appkit_objc_msg_send_u64_u64(
    appearance_class,
    objc_runtime_selector_handle("appearanceNamed:"),
    appearance_name_string,
  )
  appkit_objc_msg_send_void_u64(
    window,
    objc_runtime_selector_handle("setAppearance:"),
    appearance,
  )
}

///|
fn native_window_set_level(handle : UInt64, level : Int) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let native_level = native_appkit_window_level(level)
  appkit_objc_msg_send_void_u64(
    window,
    objc_runtime_selector_handle("setLevel:"),
    native_level,
  )
}

///|
fn native_window_level(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  let level = appkit_objc_msg_send_i64(
    window,
    objc_runtime_selector_handle("level"),
  )
  if level >= native_appkit_window_level(1).reinterpret_as_int64() {
    return 1
  }
  if level < 0L {
    return 2
  }
  0
}

///|
fn native_window_is_visible(handle : UInt64) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_bool(window, objc_runtime_selector_handle("isVisible"))
}

///|
fn native_window_has_focus(handle : UInt64) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_bool(window, objc_runtime_selector_handle("isKeyWindow"))
}

///|
fn native_window_is_occluded(handle : UInt64) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_bool(window, objc_runtime_selector_handle("isOccluded"))
}

///|
fn native_window_is_minimized(handle : UInt64) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_bool(
    window,
    objc_runtime_selector_handle("isMiniaturized"),
  )
}

///|
fn native_window_is_resizable(handle : UInt64) -> Bool {
  (native_window_style_mask(handle) & (8 : Int).to_uint64()) !=
  (0 : Int).to_uint64()
}

///|
fn native_window_is_maximized(handle : UInt64) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }

  let current_mask = native_window_style_mask(handle)
  let required_mask = (1 : Int).to_uint64() | (8 : Int).to_uint64()
  let needs_temporary_mask = (current_mask & required_mask) != required_mask
  if needs_temporary_mask {
    native_window_set_style_mask(handle, required_mask)
  }
  let is_zoomed = appkit_objc_msg_send_bool(
    window,
    objc_runtime_selector_handle("isZoomed"),
  )
  if needs_temporary_mask {
    native_window_set_style_mask(handle, current_mask)
  }
  is_zoomed
}

///|
fn native_window_is_decorated(handle : UInt64) -> Bool {
  (native_window_style_mask(handle) & (1 : Int).to_uint64()) !=
  (0 : Int).to_uint64()
}

///|
fn native_window_drag_resize_window(_handle : UInt64, _direction : Int) -> Bool {
  false
}

///|
fn native_window_show_window_menu(_handle : UInt64, _x : Int, _y : Int) -> Bool {
  false
}

///|
fn native_window_drag_window(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return -1
  }
  let event = appkit_objc_msg_send_u64(
    app,
    objc_runtime_selector_handle("currentEvent"),
  )
  if event == (0 : Int).to_uint64() {
    return -1
  }
  let perform_drag = objc_runtime_selector_handle("performWindowDragWithEvent:")
  if appkit_objc_msg_send_bool_u64(
      window,
      objc_runtime_selector_handle("respondsToSelector:"),
      perform_drag,
    ) {
    appkit_objc_msg_send_void_u64(window, perform_drag, event)
    1
  } else {
    0
  }
}

///|
fn native_window_set_has_shadow(handle : UInt64, has_shadow : Bool) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_bool(
    window,
    objc_runtime_selector_handle("setHasShadow:"),
    has_shadow,
  )
}

///|
fn native_window_has_shadow(handle : UInt64) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_bool(window, objc_runtime_selector_handle("hasShadow"))
}

///|
fn native_window_set_document_edited(handle : UInt64, edited : Bool) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_bool(
    window,
    objc_runtime_selector_handle("setDocumentEdited:"),
    edited,
  )
}

///|
fn native_window_is_document_edited(handle : UInt64) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_bool(
    window,
    objc_runtime_selector_handle("isDocumentEdited"),
  )
}

///|
fn native_window_set_movable_by_background(
  handle : UInt64,
  movable : Bool,
) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_bool(
    window,
    objc_runtime_selector_handle("setMovableByWindowBackground:"),
    movable,
  )
}

///|
fn native_window_set_movable(handle : UInt64, movable : Bool) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_bool(
    window,
    objc_runtime_selector_handle("setMovable:"),
    movable,
  )
}

///|
fn native_window_set_content_protected(
  handle : UInt64,
  content_protected : Bool,
) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let sharing_type = if content_protected { 0 } else { 1 }
  appkit_objc_msg_send_void_u64(
    window,
    objc_runtime_selector_handle("setSharingType:"),
    sharing_type.to_uint64(),
  )
}

///|
fn native_window_is_content_protected(handle : UInt64) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_u64(window, objc_runtime_selector_handle("sharingType")) ==
  (0 : Int).to_uint64()
}

///|
fn native_window_is_fullscreen(handle : UInt64) -> Bool {
  (native_window_style_mask(handle) & (16384 : Int).to_uint64()) !=
  (0 : Int).to_uint64()
}

///|
fn native_window_set_accepts_first_mouse(
  handle : UInt64,
  accepts_first_mouse : Bool,
) -> Unit {
  let content_view = native_window_content_view_objc_handle(handle)
  if content_view == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_bool(
    content_view,
    objc_runtime_selector_handle("setAcceptsFirstMouseEnabled:"),
    accepts_first_mouse,
  )
}

///|
fn native_window_set_option_as_alt(
  handle : UInt64,
  option_as_alt : Int,
) -> Unit {
  let content_view = native_window_content_view_objc_handle(handle)
  if content_view == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    content_view,
    objc_runtime_selector_handle("setOptionAsAlt:"),
    option_as_alt.to_uint64(),
  )
}

///|
fn native_window_option_as_alt(handle : UInt64) -> Int {
  let content_view = native_window_content_view_objc_handle(handle)
  if content_view == (0 : Int).to_uint64() {
    return 0
  }
  appkit_objc_msg_send_u64(
    content_view,
    objc_runtime_selector_handle("optionAsAlt"),
  ).to_int()
}

///|
fn native_window_set_unified_titlebar(
  handle : UInt64,
  unified_titlebar : Bool,
) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  if unified_titlebar {
    let toolbar_class = objc_runtime_class_handle("NSToolbar")
    if toolbar_class == (0 : Int).to_uint64() {
      return ()
    }
    let toolbar_alloc = appkit_objc_msg_send_u64(
      toolbar_class,
      objc_runtime_selector_handle("alloc"),
    )
    if toolbar_alloc == (0 : Int).to_uint64() {
      return ()
    }
    let identifier = objc_nsstring_from_string("window-unified-titlebar")
    if identifier == (0 : Int).to_uint64() {
      return ()
    }
    let toolbar = appkit_objc_msg_send_u64_u64(
      toolbar_alloc,
      objc_runtime_selector_handle("initWithIdentifier:"),
      identifier,
    )
    let toolbar_handle = if toolbar == (0 : Int).to_uint64() {
      (0 : Int).to_uint64()
    } else {
      appkit_objc_msg_send_u64(
        toolbar,
        objc_runtime_selector_handle("autorelease"),
      )
    }
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle("setToolbar:"),
      toolbar_handle,
    )
    let set_toolbar_style = objc_runtime_selector_handle("setToolbarStyle:")
    if appkit_objc_msg_send_bool_u64(
        window,
        objc_runtime_selector_handle("respondsToSelector:"),
        set_toolbar_style,
      ) {
      // NSWindowToolbarStyleUnified = 3.
      appkit_objc_msg_send_void_u64(
        window,
        set_toolbar_style,
        (3 : Int).to_uint64(),
      )
    }
  } else {
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle("setToolbar:"),
      (0 : Int).to_uint64(),
    )
    let set_toolbar_style = objc_runtime_selector_handle("setToolbarStyle:")
    if appkit_objc_msg_send_bool_u64(
        window,
        objc_runtime_selector_handle("respondsToSelector:"),
        set_toolbar_style,
      ) {
      // NSWindowToolbarStyleAutomatic = 0.
      appkit_objc_msg_send_void_u64(
        window,
        set_toolbar_style,
        (0 : Int).to_uint64(),
      )
    }
  }
}

///|
fn native_window_style_mask(handle : UInt64) -> UInt64 {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(window, objc_runtime_selector_handle("styleMask"))
}

///|
fn native_window_set_style_mask(handle : UInt64, style_mask : UInt64) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    window,
    objc_runtime_selector_handle("setStyleMask:"),
    style_mask,
  )
  let content_view = appkit_objc_msg_send_u64(
    window,
    objc_runtime_selector_handle("contentView"),
  )
  if content_view != (0 : Int).to_uint64() &&
    appkit_objc_msg_send_bool(
      content_view,
      objc_runtime_selector_handle("acceptsFirstResponder"),
    ) {
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle("makeFirstResponder:"),
      content_view,
    )
  }
}

///|
fn native_window_clear_style_mask_bits(
  handle : UInt64,
  style_mask : UInt64,
) -> Unit {
  let current_style_mask = native_window_style_mask(handle)
  let clear_bits = current_style_mask & style_mask
  native_window_set_style_mask(handle, current_style_mask - clear_bits)
}

///|
fn native_window_num_tabs(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 1
  }
  let tabbed_windows = objc_runtime_selector_handle("tabbedWindows")
  if appkit_objc_msg_send_bool_u64(
      window,
      objc_runtime_selector_handle("respondsToSelector:"),
      tabbed_windows,
    ) ==
    false {
    return 1
  }
  let tabbed = appkit_objc_msg_send_u64(window, tabbed_windows)
  if tabbed == (0 : Int).to_uint64() {
    return 1
  }
  let count = appkit_objc_msg_send_u64(
    tabbed,
    objc_runtime_selector_handle("count"),
  ).to_int()
  if count > 0 {
    count
  } else {
    1
  }
}

///|
fn native_window_set_titlebar_buttons_hidden(
  handle : UInt64,
  hidden : Bool,
) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let standard_button = objc_runtime_selector_handle("standardWindowButton:")
  let close_button = appkit_objc_msg_send_u64_u64(
    window,
    standard_button,
    (0 : Int).to_uint64(),
  )
  let miniaturize_button = appkit_objc_msg_send_u64_u64(
    window,
    standard_button,
    (1 : Int).to_uint64(),
  )
  let zoom_button = appkit_objc_msg_send_u64_u64(
    window,
    standard_button,
    (2 : Int).to_uint64(),
  )
  let set_hidden = objc_runtime_selector_handle("setHidden:")
  if close_button != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_bool(close_button, set_hidden, hidden)
  }
  if miniaturize_button != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_bool(miniaturize_button, set_hidden, hidden)
  }
  if zoom_button != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_bool(zoom_button, set_hidden, hidden)
  }
}

///|
fn native_window_set_enabled_buttons(
  handle : UInt64,
  close : Bool,
  minimize : Bool,
  maximize : Bool,
) -> Unit {
  let closable_style_mask = (2 : Int).to_uint64()
  let minimizable_style_mask = (4 : Int).to_uint64()
  if close {
    native_window_set_style_mask(
      handle,
      native_window_style_mask(handle) | closable_style_mask,
    )
  } else {
    native_window_clear_style_mask_bits(handle, closable_style_mask)
  }
  if minimize {
    native_window_set_style_mask(
      handle,
      native_window_style_mask(handle) | minimizable_style_mask,
    )
  } else {
    native_window_clear_style_mask_bits(handle, minimizable_style_mask)
  }
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let zoom_button = appkit_objc_msg_send_u64_u64(
    window,
    objc_runtime_selector_handle("standardWindowButton:"),
    (2 : Int).to_uint64(),
  )
  if zoom_button != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_bool(
      zoom_button,
      objc_runtime_selector_handle("setEnabled:"),
      maximize,
    )
  }
}

///|
fn native_window_enabled_buttons_mask(handle : UInt64) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  let style = native_window_style_mask(handle)
  let mut bits = 0
  if (style & (2 : Int).to_uint64()) != (0 : Int).to_uint64() {
    bits = bits | 1
  }
  if (style & (4 : Int).to_uint64()) != (0 : Int).to_uint64() {
    bits = bits | 2
  }
  let zoom_button = appkit_objc_msg_send_u64_u64(
    window,
    objc_runtime_selector_handle("standardWindowButton:"),
    (2 : Int).to_uint64(),
  )
  if zoom_button != (0 : Int).to_uint64() &&
    appkit_objc_msg_send_bool(
      zoom_button,
      objc_runtime_selector_handle("isEnabled"),
    ) {
    bits = bits | 4
  }
  bits
}

///|
fn native_window_set_transparent(handle : UInt64, transparent : Bool) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_bool(
    window,
    objc_runtime_selector_handle("setOpaque:"),
    transparent == false,
  )
  let ns_color = objc_runtime_class_handle("NSColor")
  if ns_color == (0 : Int).to_uint64() {
    return ()
  }
  let color_selector = if transparent {
    "clearColor"
  } else {
    "windowBackgroundColor"
  }
  let color = appkit_objc_msg_send_u64(
    ns_color,
    objc_runtime_selector_handle(color_selector),
  )
  if color != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle("setBackgroundColor:"),
      color,
    )
  }
}

///|
fn native_window_set_parent(handle : UInt64, parent_handle : UInt64) -> Bool {
  let window = native_window_objc_handle(handle)
  let parent_window = native_window_objc_handle(parent_handle)
  if window == (0 : Int).to_uint64() || parent_window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_void_u64_u64(
    parent_window,
    objc_runtime_selector_handle("addChildWindow:ordered:"),
    window,
    (1 : Int).to_uint64(),
  )
  true
}

///|
fn native_window_current_monitor_id(handle : UInt64) -> UInt64 {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let mut screen = appkit_objc_msg_send_u64(
    window,
    objc_runtime_selector_handle("screen"),
  )
  if screen == (0 : Int).to_uint64() {
    let screen_class = objc_runtime_class_handle("NSScreen")
    if screen_class == (0 : Int).to_uint64() {
      return (0 : Int).to_uint64()
    }
    screen = appkit_objc_msg_send_u64(
      screen_class,
      objc_runtime_selector_handle("mainScreen"),
    )
  }
  if screen == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let description = appkit_objc_msg_send_u64(
    screen,
    objc_runtime_selector_handle("deviceDescription"),
  )
  if description == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let key = objc_nsstring_from_string("NSScreenNumber")
  if key == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let number = appkit_objc_msg_send_u64_u64(
    description,
    objc_runtime_selector_handle("objectForKey:"),
    key,
  )
  if number == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(
    number,
    objc_runtime_selector_handle("unsignedIntValue"),
  )
}

///|
fn native_window_set_tabbing_mode_preferred(handle : UInt64) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let set_tabbing_mode = objc_runtime_selector_handle("setTabbingMode:")
  if appkit_objc_msg_send_bool_u64(
      window,
      objc_runtime_selector_handle("respondsToSelector:"),
      set_tabbing_mode,
    ) {
    // NSWindowTabbingModePreferred = 1.
    appkit_objc_msg_send_void_u64(
      window,
      set_tabbing_mode,
      (1 : Int).to_uint64(),
    )
  }
}

///|
fn native_window_select_next_tab(handle : UInt64) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    window,
    objc_runtime_selector_handle("selectNextTab:"),
    (0 : Int).to_uint64(),
  )
}

///|
fn native_window_select_previous_tab(handle : UInt64) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    window,
    objc_runtime_selector_handle("selectPreviousTab:"),
    (0 : Int).to_uint64(),
  )
}

///|
fn native_window_select_tab_at_index(handle : UInt64, index : Int) -> Unit {
  if index < 0 {
    return ()
  }
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let tabbed_windows = objc_runtime_selector_handle("tabbedWindows")
  if appkit_objc_msg_send_bool_u64(
      window,
      objc_runtime_selector_handle("respondsToSelector:"),
      tabbed_windows,
    ) ==
    false {
    return ()
  }
  let tabbed = appkit_objc_msg_send_u64(window, tabbed_windows)
  if tabbed == (0 : Int).to_uint64() {
    return ()
  }
  let count = appkit_objc_msg_send_u64(
    tabbed,
    objc_runtime_selector_handle("count"),
  ).to_int()
  if count <= 0 || index >= count {
    return ()
  }
  let selected_window = appkit_objc_msg_send_u64_u64(
    tabbed,
    objc_runtime_selector_handle("objectAtIndex:"),
    index.to_uint64(),
  )
  if selected_window != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_u64(
      selected_window,
      objc_runtime_selector_handle("makeKeyAndOrderFront:"),
      (0 : Int).to_uint64(),
    )
  }
}

///|
extern "C" fn native_cg_display_create_uuid_from_display_id(
  display : UInt,
) -> UInt64 = "CGDisplayCreateUUIDFromDisplayID"

///|
extern "C" fn native_cf_absolute_time_get_current() -> Double = "CFAbsoluteTimeGetCurrent"

///|
extern "C" fn native_cgfloat_max() -> Double = "mbw_cgfloat_max"

///|
extern "C" fn native_cg_associate_mouse_and_mouse_cursor_position(
  connected : Bool,
) -> Int = "CGAssociateMouseAndMouseCursorPosition"

///|
extern "C" fn native_cg_warp_mouse_cursor_position(
  x : Double,
  y : Double,
) -> Bool = "mbw_cg_warp_mouse_cursor_position"

///|
extern "C" fn native_cgs_set_window_background_blur_radius(
  window_number : Int,
  radius : Int,
) -> Bool = "mbw_cgs_set_window_background_blur_radius"

///|
extern "C" fn native_appkit_window_level(kind : Int) -> UInt64 = "mbw_appkit_window_level"

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
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_window_event_callback(
  call_closure : FuncRef[
    ((Int, Int, Int, Int, Int, Double) -> Unit, Int, Int, Int, Int, Int, Double) -> Unit,
  ],
  callback : (Int, Int, Int, Int, Int, Double) -> Unit,
) -> Unit = "mbw_install_window_event_callback"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_notification_center_add_observer(
  call_closure : FuncRef[((Int) -> Unit, Int) -> Unit],
  callback : (Int) -> Unit,
  notification_kind : Int,
  callback_kind : Int,
) -> UInt64 = "mbw_notification_center_add_observer"

///|
extern "C" fn appkit_notification_center_remove_observer(
  observer_handle : UInt64,
) -> Unit = "mbw_notification_center_remove_observer"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_main_run_loop_add_observer(
  call_closure : FuncRef[((Int) -> Unit, Int) -> Unit],
  callback : (Int) -> Unit,
  activity_kind : Int,
  callback_kind : Int,
  order : Int,
) -> UInt64 = "mbw_main_run_loop_add_observer"

///|
extern "C" fn appkit_main_run_loop_remove_observer(
  observer_handle : UInt64,
) -> Unit = "mbw_main_run_loop_remove_observer"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_input_event_callback(
  call_closure : FuncRef[((Int, Int, UInt64) -> Unit, Int, Int, UInt64) -> Unit],
  callback : (Int, Int, UInt64) -> Unit,
) -> Unit = "mbw_install_input_event_callback"

///|
extern "C" fn native_objc_copy_utf8_bytes(object_handle : UInt64) -> Bytes = "mbw_objc_copy_utf8_bytes"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_text_input_event_callback(
  call_closure : FuncRef[
    (
      (Int, Int, UInt64, Int, UInt64, Int, Int, UInt64) -> Unit,
      Int,
      Int,
      UInt64,
      Int,
      UInt64,
      Int,
      Int,
      UInt64,
    ) -> Unit,
  ],
  callback : (Int, Int, UInt64, Int, UInt64, Int, Int, UInt64) -> Unit,
) -> Unit = "mbw_install_text_input_event_callback"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_device_event_callback(
  call_closure : FuncRef[((UInt64) -> Unit, UInt64) -> Unit],
  callback : (UInt64) -> Unit,
) -> Unit = "mbw_install_device_event_callback"

///|
extern "C" fn native_override_send_event() -> Unit = "mbw_override_send_event"

///|
extern "C" fn appkit_create_window(width : Int, height : Int) -> UInt64 = "mbw_create_window"

///|
fn native_window_scale_factor(handle : UInt64) -> Double {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 1.0
  }
  let scale = appkit_objc_msg_send_double(
    window,
    objc_runtime_selector_handle("backingScaleFactor"),
  )
  if scale > 0.0 {
    scale
  } else {
    1.0
  }
}

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
fn native_event_loop_wake_up_appkit() -> Unit {
  native_post_application_defined_event(false)
}

///|
extern "C" fn appkit_objc_msg_send_u64(
  target : UInt64,
  selector : UInt64,
) -> UInt64 = "mbw_objc_msg_send_u64"

///|
#borrow(arg0)
extern "C" fn appkit_objc_msg_send_u64_bytes(
  target : UInt64,
  selector : UInt64,
  arg0 : Bytes,
) -> UInt64 = "mbw_objc_msg_send_u64_bytes"

///|
extern "C" fn appkit_objc_msg_send_u64_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : UInt64,
) -> UInt64 = "mbw_objc_msg_send_u64_u64"

///|
extern "C" fn appkit_objc_msg_send_void(
  target : UInt64,
  selector : UInt64,
) -> Unit = "mbw_objc_msg_send_void"

///|
extern "C" fn appkit_objc_msg_send_void_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : UInt64,
) -> Unit = "mbw_objc_msg_send_void_u64"

///|
extern "C" fn appkit_objc_msg_send_void_i32(
  target : UInt64,
  selector : UInt64,
  arg0 : Int,
) -> Unit = "mbw_objc_msg_send_void_i32"

///|
extern "C" fn appkit_objc_msg_send_void_rect_u64(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  arg1 : UInt64,
) -> Unit = "mbw_objc_msg_send_void_rect_u64"

///|
extern "C" fn appkit_objc_msg_send_void_rect_bool(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  arg1 : Bool,
) -> Unit = "mbw_objc_msg_send_void_rect_bool"

///|
extern "C" fn appkit_objc_msg_send_void_i32_u64_i32_u64_i32_i32_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : Int,
  arg1 : UInt64,
  arg2 : Int,
  arg3 : UInt64,
  arg4 : Int,
  arg5 : Int,
  arg6 : UInt64,
) -> Unit = "mbw_objc_msg_send_void_i32_u64_i32_u64_i32_i32_u64"

///|
extern "C" fn appkit_objc_msg_send_u64_i32_double_double_i32_u64_i32_i32_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : Int,
  arg1 : Double,
  arg2 : Double,
  arg3 : Int,
  arg4 : UInt64,
  arg5 : Int,
  arg6 : Int,
  arg7 : UInt64,
) -> UInt64 = "mbw_objc_msg_send_u64_i32_double_double_i32_u64_i32_i32_u64"

///|
extern "C" fn appkit_objc_msg_send_void_size(
  target : UInt64,
  selector : UInt64,
  width : Double,
  height : Double,
) -> Unit = "mbw_objc_msg_send_void_size"

///|
extern "C" fn appkit_objc_msg_send_void_point(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
) -> Unit = "mbw_objc_msg_send_void_point"

///|
extern "C" fn appkit_objc_msg_send_void_u64_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : UInt64,
  arg1 : UInt64,
) -> Unit = "mbw_objc_msg_send_void_u64_u64"

///|
extern "C" fn appkit_objc_msg_send_void_bool(
  target : UInt64,
  selector : UInt64,
  arg0 : Bool,
) -> Unit = "mbw_objc_msg_send_void_bool"

///|
extern "C" fn appkit_objc_msg_send_bool(
  target : UInt64,
  selector : UInt64,
) -> Bool = "mbw_objc_msg_send_bool"

///|
extern "C" fn appkit_objc_msg_send_bool_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : UInt64,
) -> Bool = "mbw_objc_msg_send_bool_u64"

///|
extern "C" fn appkit_objc_msg_send_i64(
  target : UInt64,
  selector : UInt64,
) -> Int64 = "mbw_objc_msg_send_i64"

///|
extern "C" fn appkit_objc_msg_send_double(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_double"

///|
extern "C" fn appkit_objc_msg_send_rect_x(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_rect_x"

///|
extern "C" fn appkit_objc_msg_send_rect_y(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_rect_y"

///|
extern "C" fn appkit_objc_msg_send_rect_width(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_rect_width"

///|
extern "C" fn appkit_objc_msg_send_rect_height(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_rect_height"

///|
extern "C" fn appkit_objc_msg_send_rect_x_rect(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Double = "mbw_objc_msg_send_rect_x_rect"

///|
extern "C" fn appkit_objc_msg_send_rect_y_rect(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Double = "mbw_objc_msg_send_rect_y_rect"

///|
extern "C" fn appkit_objc_msg_send_rect_height_rect(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Double = "mbw_objc_msg_send_rect_height_rect"

///|
extern "C" fn appkit_objc_msg_send_size_width(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_size_width"

///|
extern "C" fn appkit_objc_msg_send_size_height(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_size_height"

///|
extern "C" fn appkit_objc_msg_send_point_x(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_point_x"

///|
extern "C" fn appkit_objc_msg_send_point_y(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_point_y"

///|
extern "C" fn appkit_objc_msg_send_point_x_point_u64(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  arg1 : UInt64,
) -> Double = "mbw_objc_msg_send_point_x_point_u64"

///|
extern "C" fn appkit_objc_msg_send_point_y_point_u64(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  arg1 : UInt64,
) -> Double = "mbw_objc_msg_send_point_y_point_u64"

///|
extern "C" fn appkit_objc_msg_send_edge_insets_top(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_edge_insets_top"

///|
extern "C" fn appkit_objc_msg_send_edge_insets_left(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_edge_insets_left"

///|
extern "C" fn appkit_objc_msg_send_edge_insets_bottom(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_edge_insets_bottom"

///|
extern "C" fn appkit_objc_msg_send_edge_insets_right(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_edge_insets_right"

///|
#borrow(name)
extern "C" fn appkit_objc_get_class(name : Bytes) -> UInt64 = "mbw_objc_get_class"

///|
extern "C" fn appkit_objc_release_object(handle : UInt64) -> Unit = "mbw_objc_release"

///|
#borrow(name)
extern "C" fn appkit_objc_sel_register_name(name : Bytes) -> UInt64 = "mbw_objc_sel_register_name"

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
extern "C" fn native_monitor_copy_display_mode_count(monitor_id : UInt) -> Int = "mbw_copy_display_mode_count"

///|
extern "C" fn native_monitor_copy_display_mode_handle_at(
  monitor_id : UInt,
  index : Int,
) -> UInt64 = "mbw_copy_display_mode_handle_at"

///|
extern "C" fn native_monitor_display_mode_width(mode_handle : UInt64) -> Int = "mbw_display_mode_width"

///|
extern "C" fn native_monitor_display_mode_height(mode_handle : UInt64) -> Int = "mbw_display_mode_height"

///|
extern "C" fn native_monitor_display_mode_bit_depth(
  mode_handle : UInt64,
) -> Int = "mbw_display_mode_bit_depth"

///|
extern "C" fn native_monitor_display_mode_refresh_rate_millihertz(
  mode_handle : UInt64,
) -> Int = "mbw_display_mode_refresh_rate_millihertz"

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
