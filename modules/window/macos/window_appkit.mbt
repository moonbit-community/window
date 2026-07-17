///|
// Port target: winit-reference/winit-appkit/src/window_delegate.rs
fn registered_borrowed_native_handle(
  window_handle : NativeWindow,
) -> BorrowedObjcHandle {
  let native_handle = native_window_borrowed_objc_handle(window_handle)
  if native_handle.is_non_null() && app_state_has_window_handle(window_handle) {
    native_handle
  } else {
    BorrowedObjcHandle::null()
  }
}

///|
fn registered_native_handle(window_handle : NativeWindow) -> UInt64 {
  registered_borrowed_native_handle(window_handle).raw()
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
fn native_window_apply_cursor_obj(
  handle : NativeWindow,
  cursor_obj : UInt64,
) -> Bool {
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
fn native_window_set_cursor(
  handle : NativeWindow,
  cursor : @core.CursorIcon,
) -> Unit {
  ignore(native_window_apply_cursor_obj(handle, cursor_from_icon(cursor)))
}

///|
fn native_window_set_custom_cursor(
  handle : NativeWindow,
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
fn native_window_set_cursor_visible(
  handle : NativeWindow,
  visible : Bool,
) -> Unit {
  set_window_cursor_visible_state(native_window_identity(handle), visible)
  if !visible {
    ignore(native_window_apply_cursor_obj(handle, invisible_cursor()))
  }
}

///|
fn native_window_cursor_visible(handle : NativeWindow) -> Bool {
  window_cursor_visible_state(native_window_identity(handle))
}

///|
fn native_window_set_cursor_grab(handle : NativeWindow, mode : Int) -> Int {
  ignore(handle)
  if mode == 0 {
    native_cg_associate_mouse_and_mouse_cursor_position(true)
  } else if mode == 1 {
    native_cg_associate_mouse_and_mouse_cursor_position(false)
  } else {
    -1
  }
}

///|
fn native_window_set_cursor_position(
  handle : NativeWindow,
  x : Int,
  y : Int,
) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return -1
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
  let screen_y = cursor_screen_y_from_content_rect(content_y, content_height, y)
  let warp_status = native_cg_warp_mouse_cursor_position(
    content_x + x.to_double(),
    screen_y,
  )
  if warp_status != 0 {
    return warp_status
  }
  native_cg_associate_mouse_and_mouse_cursor_position(true)
}

///|
fn native_window_set_maximized(handle : NativeWindow, maximized : Bool) -> Unit {
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

  match native_window_saved_standard_frame(handle) {
    Some(frame) =>
      appkit_objc_msg_send_void_rect_bool(
        window,
        set_frame_display,
        frame.x,
        frame.y,
        frame.width,
        frame.height,
        false,
      )
    None =>
      appkit_objc_msg_send_void_rect_bool(
        window, set_frame_display, 100.0, 100.0, 800.0, 600.0, false,
      )
  }
}

///|
fn native_create_window(width : Int, height : Int) -> NativeWindow {
  appkit_create_window(width, height)
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
fn window_title(window_handle : NativeWindow) -> String {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    ""
  } else {
    native_window_title(window_handle)
  }
}

///|
fn window_tabbing_identifier(window_handle : NativeWindow) -> String {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    ""
  } else {
    native_window_tabbing_identifier(window_handle)
  }
}

///|
fn is_main_thread() -> Bool {
  pthread_is_main_thread()
}

///|
fn create_window(width : Int, height : Int) -> NativeWindow {
  let initial_width = clamp_size(width)
  let initial_height = clamp_size(height)
  native_create_window(initial_width, initial_height)
}

///|
fn native_window_set_title(handle : NativeWindow, title : String) -> Unit {
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
fn native_window_set_name(handle : NativeWindow, name : String) -> Unit {
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
fn native_window_set_resizable(handle : NativeWindow, resizable : Bool) -> Unit {
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
fn native_window_set_skip_taskbar(
  handle : NativeWindow,
  skip_taskbar : Bool,
) -> Unit {
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
  handle : NativeWindow,
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
  handle : NativeWindow,
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
  handle : NativeWindow,
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
  handle : NativeWindow,
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
  handle : NativeWindow,
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
fn flip_window_screen_coordinate_y(y : Double, frame_height : Double) -> Double {
  cg_main_display_bounds_height() - frame_height - y
}

///|
fn window_surface_offset_y_from_frame_and_content(
  frame_y : Double,
  frame_height : Double,
  content_y : Double,
  content_height : Double,
) -> Double {
  let frame_screen_y = flip_window_screen_coordinate_y(frame_y, frame_height)
  let content_screen_y = flip_window_screen_coordinate_y(
    content_y, content_height,
  )
  content_screen_y - frame_screen_y
}

///|
fn cursor_screen_y_from_content_rect(
  content_y : Double,
  content_height : Double,
  cursor_y : Int,
) -> Double {
  flip_window_screen_coordinate_y(content_y, content_height) +
  cursor_y.to_double()
}

///|
fn native_window_set_position(handle : NativeWindow, x : Int, y : Int) -> Unit {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let frame_selector = objc_runtime_selector_handle("frame")
  let frame_height = appkit_objc_msg_send_rect_height(window, frame_selector)
  appkit_objc_msg_send_void_point(
    window,
    objc_runtime_selector_handle("setFrameOrigin:"),
    x.to_double(),
    flip_window_screen_coordinate_y(y.to_double(), frame_height),
  )
}

///|
fn native_window_content_width(handle : NativeWindow) -> Int {
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
fn native_window_content_height(handle : NativeWindow) -> Int {
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
fn native_window_min_content_width(handle : NativeWindow) -> Int {
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
fn native_window_min_content_height(handle : NativeWindow) -> Int {
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
fn native_window_max_content_width(handle : NativeWindow) -> Int {
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
fn native_window_max_content_height(handle : NativeWindow) -> Int {
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
fn native_window_outer_width(handle : NativeWindow) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  appkit_objc_msg_send_rect_width(window, objc_runtime_selector_handle("frame")).to_int()
}

///|
fn native_window_outer_height(handle : NativeWindow) -> Int {
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
fn native_window_resize_increment_width(handle : NativeWindow) -> Int {
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
fn native_window_resize_increment_height(handle : NativeWindow) -> Int {
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
fn native_window_safe_area_top(handle : NativeWindow) -> Int {
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
fn native_window_safe_area_left(handle : NativeWindow) -> Int {
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
fn native_window_safe_area_bottom(handle : NativeWindow) -> Int {
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
fn native_window_safe_area_right(handle : NativeWindow) -> Int {
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
fn native_window_x(handle : NativeWindow) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  appkit_objc_msg_send_rect_x(window, objc_runtime_selector_handle("frame")).to_int()
}

///|
fn native_window_y(handle : NativeWindow) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  let frame_selector = objc_runtime_selector_handle("frame")
  let frame_y = appkit_objc_msg_send_rect_y(window, frame_selector)
  let frame_height = appkit_objc_msg_send_rect_height(window, frame_selector)
  flip_window_screen_coordinate_y(frame_y, frame_height).to_int()
}

///|
fn native_window_surface_x(handle : NativeWindow) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
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
  (content_x - frame_x).to_int()
}

///|
fn native_window_surface_y(handle : NativeWindow) -> Int {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return 0
  }
  let frame_selector = objc_runtime_selector_handle("frame")
  let frame_x = appkit_objc_msg_send_rect_x(window, frame_selector)
  let frame_y = appkit_objc_msg_send_rect_y(window, frame_selector)
  let frame_width = appkit_objc_msg_send_rect_width(window, frame_selector)
  let frame_height = appkit_objc_msg_send_rect_height(window, frame_selector)
  let content_rect_selector = objc_runtime_selector_handle(
    "contentRectForFrameRect:",
  )
  let content_y = appkit_objc_msg_send_rect_y_rect(
    window, content_rect_selector, frame_x, frame_y, frame_width, frame_height,
  )
  let content_height = appkit_objc_msg_send_rect_height_rect(
    window, content_rect_selector, frame_x, frame_y, frame_width, frame_height,
  )
  window_surface_offset_y_from_frame_and_content(
    frame_y, frame_height, content_y, content_height,
  ).to_int()
}

///|
fn native_window_title(handle : NativeWindow) -> String {
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
  handle : NativeWindow,
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
fn native_window_tabbing_identifier(handle : NativeWindow) -> String {
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
fn native_window_theme(handle : NativeWindow) -> Int {
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
fn native_window_set_theme(handle : NativeWindow, theme : Int) -> Unit {
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
fn native_window_set_level(handle : NativeWindow, level : Int) -> Unit {
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
fn native_window_level(handle : NativeWindow) -> Int {
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
fn native_window_is_visible(handle : NativeWindow) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_bool(window, objc_runtime_selector_handle("isVisible"))
}

///|
fn native_window_has_focus(handle : NativeWindow) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_bool(window, objc_runtime_selector_handle("isKeyWindow"))
}

///|
fn native_window_is_occluded(handle : NativeWindow) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_u64(
    window,
    objc_runtime_selector_handle("occlusionState"),
  ) ==
  (0 : Int).to_uint64()
}

///|
fn native_window_is_minimized(handle : NativeWindow) -> Bool {
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
fn native_window_is_resizable(handle : NativeWindow) -> Bool {
  (native_window_style_mask(handle) & (8 : Int).to_uint64()) !=
  (0 : Int).to_uint64()
}

///|
fn native_window_is_maximized(handle : NativeWindow) -> Bool {
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
fn native_window_is_decorated(handle : NativeWindow) -> Bool {
  (native_window_style_mask(handle) & (1 : Int).to_uint64()) !=
  (0 : Int).to_uint64()
}

///|
fn native_window_drag_resize_window(
  _handle : NativeWindow,
  _direction : Int,
) -> Bool {
  false
}

///|
fn native_window_show_window_menu(
  _handle : NativeWindow,
  _x : Int,
  _y : Int,
) -> Bool {
  false
}

///|
fn native_window_drag_window(handle : NativeWindow) -> Int {
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
fn native_window_set_has_shadow(
  handle : NativeWindow,
  has_shadow : Bool,
) -> Unit {
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
fn native_window_has_shadow(handle : NativeWindow) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_bool(window, objc_runtime_selector_handle("hasShadow"))
}

///|
fn native_window_set_document_edited(
  handle : NativeWindow,
  edited : Bool,
) -> Unit {
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
fn native_window_is_document_edited(handle : NativeWindow) -> Bool {
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
  handle : NativeWindow,
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
fn native_window_set_movable(handle : NativeWindow, movable : Bool) -> Unit {
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
  handle : NativeWindow,
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
fn native_window_is_content_protected(handle : NativeWindow) -> Bool {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_u64(window, objc_runtime_selector_handle("sharingType")) ==
  (0 : Int).to_uint64()
}

///|
fn native_window_is_fullscreen(handle : NativeWindow) -> Bool {
  (native_window_style_mask(handle) & (16384 : Int).to_uint64()) !=
  (0 : Int).to_uint64()
}

///|
fn native_window_set_unified_titlebar(
  handle : NativeWindow,
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
      appkit_objc_release_raw_object(toolbar_alloc)
      return ()
    }
    let toolbar_raw = appkit_objc_msg_send_u64_u64(
      toolbar_alloc,
      objc_runtime_selector_handle("initWithIdentifier:"),
      identifier,
    )
    if toolbar_raw == (0 : Int).to_uint64() {
      appkit_objc_release_raw_object(toolbar_alloc)
    }
    let toolbar = appkit_objc_wrap_owned_object(toolbar_raw)
    if native_objc_owned_valid(toolbar) {
      appkit_objc_msg_send_void_u64(
        window,
        objc_runtime_selector_handle("setToolbar:"),
        native_objc_owned_handle(toolbar),
      )
      appkit_objc_release_object(toolbar)
    }
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
fn native_window_style_mask(handle : NativeWindow) -> UInt64 {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(window, objc_runtime_selector_handle("styleMask"))
}

///|
fn native_window_set_style_mask(
  handle : NativeWindow,
  style_mask : UInt64,
) -> Unit {
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
  handle : NativeWindow,
  style_mask : UInt64,
) -> Unit {
  let current_style_mask = native_window_style_mask(handle)
  let clear_bits = current_style_mask & style_mask
  native_window_set_style_mask(handle, current_style_mask - clear_bits)
}

///|
fn native_window_num_tabs(handle : NativeWindow) -> Int {
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
  handle : NativeWindow,
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
  handle : NativeWindow,
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
fn native_window_enabled_buttons_mask(handle : NativeWindow) -> Int {
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
fn native_window_current_monitor_id(handle : NativeWindow) -> UInt64 {
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
fn native_window_set_tabbing_mode_preferred(handle : NativeWindow) -> Unit {
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
fn native_window_select_next_tab(handle : NativeWindow) -> Unit {
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
fn native_window_select_previous_tab(handle : NativeWindow) -> Unit {
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
fn native_window_select_tab_at_index(
  handle : NativeWindow,
  index : Int,
) -> Unit {
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
fn native_window_scale_factor(handle : NativeWindow) -> Double {
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
fn set_window_raw_id(window_handle : NativeWindow, raw_id : Int) -> Unit {
  if native_window_objc_handle(window_handle) == (0 : Int).to_uint64() {
    return ()
  }
  let set_raw_id = objc_runtime_selector_handle("setRawId:")
  let delegate = native_window_delegate_objc_handle(window_handle)
  if delegate != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_i32(delegate, set_raw_id, raw_id)
  }
  let content_view = native_window_content_view_objc_handle(window_handle)
  if content_view != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_i32(content_view, set_raw_id, raw_id)
  }
}

///|
fn show_window(window_handle : NativeWindow, active : Bool) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    let window = native_window_objc_handle(window_handle)
    if window == (0 : Int).to_uint64() {
      return ()
    }
    if active {
      appkit_objc_msg_send_void_u64(
        window,
        objc_runtime_selector_handle("makeKeyAndOrderFront:"),
        (0 : Int).to_uint64(),
      )
    } else {
      appkit_objc_msg_send_void_u64(
        window,
        objc_runtime_selector_handle("orderFront:"),
        (0 : Int).to_uint64(),
      )
    }
  }
}

///|
fn native_set_visible(window_handle : NativeWindow, visible : Bool) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    let window = native_window_objc_handle(window_handle)
    if window == (0 : Int).to_uint64() {
      return ()
    }
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle(
        if visible {
          "orderFront:"
        } else {
          "orderOut:"
        },
      ),
      (0 : Int).to_uint64(),
    )
  }
}

///|
fn focus_window(window_handle : NativeWindow) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() &&
    native_window_is_visible(window_handle) {
    let window = native_window_objc_handle(window_handle)
    if window == (0 : Int).to_uint64() {
      return ()
    }
    let app = native_application_shared_handle()
    if app != (0 : Int).to_uint64() {
      appkit_objc_msg_send_void_bool(
        app,
        objc_runtime_selector_handle("activateIgnoringOtherApps:"),
        true,
      )
    }
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle("makeKeyAndOrderFront:"),
      (0 : Int).to_uint64(),
    )
  }
}

///|
fn center_window(window_handle : NativeWindow) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    let window = native_window_objc_handle(window_handle)
    if window != (0 : Int).to_uint64() {
      appkit_objc_msg_send_void(window, objc_runtime_selector_handle("center"))
    }
  }
}

///|
fn set_window_minimized(window_handle : NativeWindow, minimized : Bool) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    let window = native_window_objc_handle(window_handle)
    if window == (0 : Int).to_uint64() {
      return ()
    }
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle(
        if minimized {
          "miniaturize:"
        } else {
          "deminiaturize:"
        },
      ),
      (0 : Int).to_uint64(),
    )
  }
}

///|
fn toggle_window_fullscreen(
  window_handle : NativeWindow,
  fullscreen : Bool,
) -> Unit {
  let window = native_window_objc_handle(window_handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let is_fullscreen = native_window_is_fullscreen(window_handle)
  let should_toggle = (fullscreen && is_fullscreen == false) ||
    (fullscreen == false && is_fullscreen)
  if should_toggle {
    set_window_fullscreen_transition_state(
      native_window_identity(window_handle),
      true,
    )
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle("toggleFullScreen:"),
      (0 : Int).to_uint64(),
    )
  }
}

///|
fn set_window_blur(window_handle : NativeWindow, blur : Bool) -> Unit {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  let window = native_handle
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let window_number = appkit_objc_msg_send_i64(
    window,
    objc_runtime_selector_handle("windowNumber"),
  ).to_int()
  ignore(
    native_cgs_set_window_background_blur_radius(
      window_number,
      if blur {
        80
      } else {
        0
      },
    ),
  )
}

///|
fn set_window_titlebar_transparent(
  window_handle : NativeWindow,
  titlebar_transparent : Bool,
) -> Unit {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  let window = native_handle
  if window == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_bool(
    window,
    objc_runtime_selector_handle("setTitlebarAppearsTransparent:"),
    titlebar_transparent,
  )
}

///|
fn set_window_title_hidden(
  window_handle : NativeWindow,
  title_hidden : Bool,
) -> Unit {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  let window = native_handle
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let visibility = if title_hidden { 1 } else { 0 }
  appkit_objc_msg_send_void_u64(
    window,
    objc_runtime_selector_handle("setTitleVisibility:"),
    visibility.to_uint64(),
  )
}

///|
fn set_parent_window(
  window_handle : NativeWindow,
  parent_window : UInt64,
) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  let parent = native_objc_window_from_raw_handle(parent_window)
  if native_handle == (0 : Int).to_uint64() || parent == (0 : Int).to_uint64() {
    false
  } else {
    let window = native_handle
    if window == (0 : Int).to_uint64() || parent == (0 : Int).to_uint64() {
      false
    } else {
      appkit_objc_msg_send_void_u64_u64(
        parent,
        objc_runtime_selector_handle("addChildWindow:ordered:"),
        window,
        (1 : Int).to_uint64(),
      )
      true
    }
  }
}

///|
fn set_window_cursor_hittest(
  window_handle : NativeWindow,
  hittest : Bool,
) -> Int {
  let window = registered_borrowed_native_handle(window_handle)
  if window.is_null() {
    return -1
  }
  appkit_objc_msg_send_void_bool(
    window.raw(),
    objc_runtime_selector_handle("setIgnoresMouseEvents:"),
    hittest == false,
  )
  0
}

///|
fn window_cursor_hittest(window_handle : NativeWindow) -> Bool {
  let window = registered_borrowed_native_handle(window_handle)
  if window.is_null() {
    true
  } else {
    appkit_objc_msg_send_bool(
      window.raw(),
      objc_runtime_selector_handle("ignoresMouseEvents"),
    ) ==
    false
  }
}

///|
fn set_window_transparent(
  window_handle : NativeWindow,
  transparent : Bool,
) -> Unit {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  let window = native_handle
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
fn set_ime_allowed(window_handle : NativeWindow, allowed : Bool) -> Unit {
  set_window_ime_allowed_state(native_window_identity(window_handle), allowed)
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  let content_view = native_window_content_view_objc_handle(window_handle)
  if content_view == (0 : Int).to_uint64() {
    return ()
  }
  if !allowed {
    match app_state_window_raw_id(window_handle) {
      Some(raw_id) => view_disable_ime(raw_id)
      None => ()
    }
    let input_context = appkit_objc_msg_send_u64(
      content_view,
      objc_runtime_selector_handle("inputContext"),
    )
    if input_context != (0 : Int).to_uint64() {
      appkit_objc_msg_send_void(
        input_context,
        objc_runtime_selector_handle("discardMarkedText"),
      )
    }
  }
}

///|
fn set_ime_cursor_area(
  window_handle : NativeWindow,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Unit {
  set_window_ime_cursor_area_state(
    native_window_identity(window_handle),
    x,
    y,
    width,
    height,
  )
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  let content_view = native_window_content_view_objc_handle(window_handle)
  if content_view == (0 : Int).to_uint64() {
    return ()
  }
  let input_context = appkit_objc_msg_send_u64(
    content_view,
    objc_runtime_selector_handle("inputContext"),
  )
  if input_context != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void(
      input_context,
      objc_runtime_selector_handle("invalidateCharacterCoordinates"),
    )
  }
}

///|
fn window_transparent(window_handle : NativeWindow) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    let window = native_handle
    if window == (0 : Int).to_uint64() {
      false
    } else {
      appkit_objc_msg_send_bool(
        window,
        objc_runtime_selector_handle("isOpaque"),
      ) ==
      false
    }
  }
}
