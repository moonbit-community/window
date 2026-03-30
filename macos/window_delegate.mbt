///|
// Port target: winit-reference/winit-appkit/src/window_delegate.rs
fn registered_native_handle(window_handle : UInt64) -> UInt64 {
  if window_handle != (0 : Int).to_uint64() &&
    app_state_has_window_handle(window_handle) {
    window_handle
  } else {
    (0 : Int).to_uint64()
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
let invisible_cursor_obj_handle : Ref[UInt64] = Ref::new((0 : Int).to_uint64())

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
let fullscreen_transition_window_handles : Ref[Array[UInt64]] = Ref::new([])

///|
let fullscreen_transition_values : Ref[Array[Bool]] = Ref::new([])

///|
let window_platform_state_handles : Ref[Array[UInt64]] = Ref::new([])

///|
let window_ime_allowed_values : Ref[Array[Bool]] = Ref::new([])

///|
let window_cursor_visible_values : Ref[Array[Bool]] = Ref::new([])

///|
let window_accepts_first_mouse_values : Ref[Array[Bool]] = Ref::new([])

///|
let window_option_as_alt_values : Ref[Array[Int]] = Ref::new([])

///|
let window_ime_purpose_values : Ref[Array[Int]] = Ref::new([])

///|
let window_ime_hints_values : Ref[Array[Int]] = Ref::new([])

///|
let window_ime_cursor_x_values : Ref[Array[Int]] = Ref::new([])

///|
let window_ime_cursor_y_values : Ref[Array[Int]] = Ref::new([])

///|
let window_ime_cursor_width_values : Ref[Array[Int]] = Ref::new([])

///|
let window_ime_cursor_height_values : Ref[Array[Int]] = Ref::new([])

///|
fn window_fullscreen_transition_index(window_handle : UInt64) -> Int? {
  fullscreen_transition_window_handles.val.search_by(handle => {
    handle == window_handle
  })
}

///|
fn set_window_fullscreen_transition_state(
  window_handle : UInt64,
  in_transition : Bool,
) -> Unit {
  match window_fullscreen_transition_index(window_handle) {
    Some(index) => fullscreen_transition_values.val[index] = in_transition
    None => {
      fullscreen_transition_window_handles.val.push(window_handle)
      fullscreen_transition_values.val.push(in_transition)
    }
  }
}

///|
fn clear_window_fullscreen_transition_state(window_handle : UInt64) -> Unit {
  match window_fullscreen_transition_index(window_handle) {
    Some(index) => {
      ignore(fullscreen_transition_window_handles.val.remove(index))
      ignore(fullscreen_transition_values.val.remove(index))
    }
    None => ()
  }
}

///|
fn window_platform_state_index(window_handle : UInt64) -> Int? {
  window_platform_state_handles.val.search_by(handle => handle == window_handle)
}

///|
fn window_platform_state_ensure_index(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => index
    None => {
      window_platform_state_handles.val.push(window_handle)
      window_ime_allowed_values.val.push(false)
      window_cursor_visible_values.val.push(true)
      window_accepts_first_mouse_values.val.push(false)
      window_option_as_alt_values.val.push(0)
      window_ime_purpose_values.val.push(0)
      window_ime_hints_values.val.push(0)
      window_ime_cursor_x_values.val.push(0)
      window_ime_cursor_y_values.val.push(0)
      window_ime_cursor_width_values.val.push(1)
      window_ime_cursor_height_values.val.push(1)
      window_platform_state_handles.val.length() - 1
    }
  }
}

///|
fn clear_window_platform_state(window_handle : UInt64) -> Unit {
  match window_platform_state_index(window_handle) {
    Some(index) => {
      ignore(window_platform_state_handles.val.remove(index))
      ignore(window_ime_allowed_values.val.remove(index))
      ignore(window_cursor_visible_values.val.remove(index))
      ignore(window_accepts_first_mouse_values.val.remove(index))
      ignore(window_option_as_alt_values.val.remove(index))
      ignore(window_ime_purpose_values.val.remove(index))
      ignore(window_ime_hints_values.val.remove(index))
      ignore(window_ime_cursor_x_values.val.remove(index))
      ignore(window_ime_cursor_y_values.val.remove(index))
      ignore(window_ime_cursor_width_values.val.remove(index))
      ignore(window_ime_cursor_height_values.val.remove(index))
    }
    None => ()
  }
}

///|
fn set_window_ime_allowed_state(window_handle : UInt64, allowed : Bool) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  window_ime_allowed_values.val[index] = allowed
}

///|
fn window_ime_allowed_state(window_handle : UInt64) -> Bool {
  match window_platform_state_index(window_handle) {
    Some(index) => window_ime_allowed_values.val[index]
    None => false
  }
}

///|
fn set_window_cursor_visible_state(
  window_handle : UInt64,
  visible : Bool,
) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  window_cursor_visible_values.val[index] = visible
}

///|
fn window_cursor_visible_state(window_handle : UInt64) -> Bool {
  match window_platform_state_index(window_handle) {
    Some(index) => window_cursor_visible_values.val[index]
    None => true
  }
}

///|
fn set_window_option_as_alt_state(
  window_handle : UInt64,
  option_as_alt : Int,
) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  window_option_as_alt_values.val[index] = option_as_alt
}

///|
fn window_option_as_alt_native(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_option_as_alt_values.val[index]
    None => 0
  }
}

///|
fn set_window_accepts_first_mouse_state(
  window_handle : UInt64,
  accepts_first_mouse : Bool,
) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  window_accepts_first_mouse_values.val[index] = accepts_first_mouse
}

///|
fn window_accepts_first_mouse_state(window_handle : UInt64) -> Bool {
  match window_platform_state_index(window_handle) {
    Some(index) => window_accepts_first_mouse_values.val[index]
    None => false
  }
}

///|
fn set_window_ime_purpose_state(window_handle : UInt64, purpose : Int) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  window_ime_purpose_values.val[index] = purpose
}

///|
fn window_ime_purpose_state(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_ime_purpose_values.val[index]
    None => 0
  }
}

///|
fn set_window_ime_hints_state(window_handle : UInt64, hints : Int) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  window_ime_hints_values.val[index] = hints
}

///|
fn window_ime_hints_state(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_ime_hints_values.val[index]
    None => 0
  }
}

///|
fn set_window_ime_cursor_area_state(
  window_handle : UInt64,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  window_ime_cursor_x_values.val[index] = x
  window_ime_cursor_y_values.val[index] = y
  window_ime_cursor_width_values.val[index] = clamp_size(width)
  window_ime_cursor_height_values.val[index] = clamp_size(height)
}

///|
fn window_ime_cursor_x_state(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_ime_cursor_x_values.val[index]
    None => 0
  }
}

///|
fn window_ime_cursor_y_state(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_ime_cursor_y_values.val[index]
    None => 0
  }
}

///|
fn window_ime_cursor_width_state(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_ime_cursor_width_values.val[index]
    None => 1
  }
}

///|
fn window_ime_cursor_height_state(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_ime_cursor_height_values.val[index]
    None => 1
  }
}

///|
fn drag_paths_from_native_path_list(path_list_handle : UInt64) -> Array[String] {
  if path_list_handle == (0 : Int).to_uint64() {
    return []
  }
  let count = appkit_objc_msg_send_u64(
    path_list_handle,
    objc_runtime_selector_handle("count"),
  ).to_int()
  if count <= 0 {
    return []
  }
  let paths : Array[String] = []
  let mut index = 0
  while index < count {
    let path_object = appkit_objc_msg_send_u64_u64(
      path_list_handle,
      objc_runtime_selector_handle("objectAtIndex:"),
      index.to_uint64(),
    )
    if path_object != (0 : Int).to_uint64() {
      let path = text_from_native(objc_utf8_bytes_from_object(path_object))
      if path.length() > 0 {
        paths.push(path)
      }
    }
    index = index + 1
  }
  paths
}

///|
fn drag_paths_from_dragging_info(
  dragging_info_handle : UInt64,
) -> Array[String] {
  if dragging_info_handle == (0 : Int).to_uint64() {
    return []
  }
  let pasteboard = appkit_objc_msg_send_u64(
    dragging_info_handle,
    objc_runtime_selector_handle("draggingPasteboard"),
  )
  if pasteboard == (0 : Int).to_uint64() {
    return []
  }
  let path_list_handle = appkit_objc_msg_send_u64_u64(
    pasteboard,
    objc_runtime_selector_handle("propertyListForType:"),
    objc_nsstring_from_string("NSFilenamesPboardType"),
  )
  drag_paths_from_native_path_list(path_list_handle)
}

///|
fn dragging_info_has_paths(dragging_info_handle : UInt64) -> Bool {
  drag_paths_from_dragging_info(dragging_info_handle).length() > 0
}

///|
fn native_drag_should_accept(
  _raw_id : Int,
  dragging_info_handle : UInt64,
) -> Bool {
  dragging_info_has_paths(dragging_info_handle)
}

///|
fn logical_position_f64_to_physical(
  x : Double,
  y : Double,
  scale_factor : Double,
) -> @dpi.PhysicalPositionF64 {
  let normalized_scale = if scale_factor > 0.0 { scale_factor } else { 1.0 }
  @dpi.PhysicalPositionF64::new(x * normalized_scale, y * normalized_scale)
}

///|
fn dnd_position_from_dragging_info(
  raw_id : Int,
  dragging_info_handle : UInt64,
) -> @dpi.PhysicalPositionF64? {
  if dragging_info_handle == (0 : Int).to_uint64() {
    return None
  }
  let dragging_location_x = appkit_objc_msg_send_point_x(
    dragging_info_handle,
    objc_runtime_selector_handle("draggingLocation"),
  )
  let dragging_location_y = appkit_objc_msg_send_point_y(
    dragging_info_handle,
    objc_runtime_selector_handle("draggingLocation"),
  )
  let scale_factor = app_state_window_scale_factor(raw_id)
  let mut x = dragging_location_x
  let mut y = dragging_location_y
  match app_state_window_handle(raw_id) {
    Some(window_handle) => {
      let content_view = native_window_content_view_objc_handle(window_handle)
      if content_view != (0 : Int).to_uint64() {
        x = appkit_objc_msg_send_point_x_point_u64(
          content_view,
          objc_runtime_selector_handle("convertPoint:fromView:"),
          dragging_location_x,
          dragging_location_y,
          (0 : Int).to_uint64(),
        )
        y = appkit_objc_msg_send_point_y_point_u64(
          content_view,
          objc_runtime_selector_handle("convertPoint:fromView:"),
          dragging_location_x,
          dragging_location_y,
          (0 : Int).to_uint64(),
        )
      }
      Some(logical_position_f64_to_physical(x, y, scale_factor))
    }
    None => Some(logical_position_f64_to_physical(x, y, scale_factor))
  }
}

///|
fn queue_drag_event_from_payload(
  raw_id : Int,
  kind : Int,
  position : @dpi.PhysicalPositionF64,
  path : Bytes,
  has_position : Bool,
) -> Unit {
  let window_id = @core.WindowId::from_raw(raw_id)
  match kind {
    9 => {
      let paths = drag_paths_from_native(path)
      if paths.length() > 0 {
        app_state_queue_window_callback(
          window_id,
          @core.WindowEvent::DragEntered(paths, position),
        )
      }
    }
    10 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::DragMoved(position),
      )
    11 => {
      let paths = drag_paths_from_native(path)
      if paths.length() > 0 {
        app_state_queue_window_callback(
          window_id,
          @core.WindowEvent::DragDropped(paths, position),
        )
      }
    }
    12 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::DragLeft(
          if has_position {
            Some(position)
          } else {
            None
          },
        ),
      )
    _ => ()
  }
}

///|
fn queue_native_drag_event(
  raw_id : Int,
  kind : Int,
  dragging_info_handle : UInt64,
) -> Unit {
  let window_id = @core.WindowId::from_raw(raw_id)
  let position = dnd_position_from_dragging_info(raw_id, dragging_info_handle)
  match kind {
    9 => {
      let paths = drag_paths_from_dragging_info(dragging_info_handle)
      if paths.length() > 0 {
        match position {
          Some(position) =>
            app_state_queue_window_callback(
              window_id,
              @core.WindowEvent::DragEntered(paths, position),
            )
          None => ()
        }
      }
    }
    10 =>
      match position {
        Some(position) =>
          app_state_queue_window_callback(
            window_id,
            @core.WindowEvent::DragMoved(position),
          )
        None => ()
      }
    11 => {
      let paths = drag_paths_from_dragging_info(dragging_info_handle)
      if paths.length() > 0 {
        match position {
          Some(position) =>
            app_state_queue_window_callback(
              window_id,
              @core.WindowEvent::DragDropped(paths, position),
            )
          None => ()
        }
      }
    }
    12 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::DragLeft(position),
      )
    _ => ()
  }
}

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
fn native_invisible_cursor_obj() -> UInt64 {
  let cached = invisible_cursor_obj_handle.val
  if cached != (0 : Int).to_uint64() {
    return cached
  }
  let cursor = appkit_custom_cursor_create_rgba(
    Bytes::make(4, (0 : Int).to_byte()),
    4,
    1,
    1,
    0,
    0,
  )
  if cursor != (0 : Int).to_uint64() {
    invisible_cursor_obj_handle.val = cursor
  }
  cursor
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
  set_window_cursor_visible_state(handle, visible)
  if !visible {
    ignore(
      native_window_apply_cursor_obj(handle, native_invisible_cursor_obj()),
    )
  }
}

///|
fn native_window_cursor_visible(handle : UInt64) -> Bool {
  window_cursor_visible_state(handle)
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
  let screen_y = cursor_screen_y_from_content_rect(content_y, content_height, y)
  if native_cg_warp_mouse_cursor_position(content_x + x.to_double(), screen_y) ==
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
fn native_create_window(width : Int, height : Int) -> UInt64 {
  appkit_create_window(width, height)
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
fn window_title(window_handle : UInt64) -> String {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    ""
  } else {
    native_window_title(native_handle)
  }
}

///|
fn window_tabbing_identifier(window_handle : UInt64) -> String {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    ""
  } else {
    native_window_tabbing_identifier(native_handle)
  }
}

///|
fn is_main_thread() -> Bool {
  pthread_is_main_thread()
}

///|
fn create_window(width : Int, height : Int) -> UInt64 {
  let initial_width = clamp_size(width)
  let initial_height = clamp_size(height)
  let native_handle = native_create_window(initial_width, initial_height)
  if native_handle == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  native_handle
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
fn native_window_set_position(handle : UInt64, x : Int, y : Int) -> Unit {
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
  let frame_selector = objc_runtime_selector_handle("frame")
  let frame_y = appkit_objc_msg_send_rect_y(window, frame_selector)
  let frame_height = appkit_objc_msg_send_rect_height(window, frame_selector)
  flip_window_screen_coordinate_y(frame_y, frame_height).to_int()
}

///|
fn native_window_surface_x(handle : UInt64) -> Int {
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
fn native_window_surface_y(handle : UInt64) -> Int {
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
  appkit_objc_msg_send_u64(
    window,
    objc_runtime_selector_handle("occlusionState"),
  ) ==
  (0 : Int).to_uint64()
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
fn set_window_raw_id(window_handle : UInt64, raw_id : Int) -> Unit {
  if window_handle == (0 : Int).to_uint64() {
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
fn close_window(window_handle : UInt64) -> Unit {
  if window_handle == (0 : Int).to_uint64() {
    return ()
  }
  native_window_forget_standard_frame(window_handle)
  clear_window_fullscreen_transition_state(window_handle)
  let window = native_window_objc_handle(window_handle)
  if window != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void(window, objc_runtime_selector_handle("close"))
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle("setDelegate:"),
      (0 : Int).to_uint64(),
    )
  }
  let set_window = objc_runtime_selector_handle("setWindow:")
  if appkit_objc_msg_send_bool_u64(
      window_handle,
      objc_runtime_selector_handle("respondsToSelector:"),
      set_window,
    ) {
    appkit_objc_msg_send_void_u64(
      window_handle,
      set_window,
      (0 : Int).to_uint64(),
    )
  }
  appkit_objc_release_object(window_handle)
}

///|
fn show_window(window_handle : UInt64, active : Bool) -> Unit {
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
      let app = native_application_shared_handle()
      if app != (0 : Int).to_uint64() {
        appkit_objc_msg_send_void_bool(
          app,
          objc_runtime_selector_handle("activateIgnoringOtherApps:"),
          true,
        )
      }
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
fn native_set_visible(window_handle : UInt64, visible : Bool) -> Unit {
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
fn native_set_resizable(window_handle : UInt64, resizable : Bool) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_resizable(window_handle, resizable)
  }
}

///|
fn window_visible(window_handle : UInt64) -> Bool {
  native_window_is_visible(window_handle)
}

///|
fn window_resizable(window_handle : UInt64) -> Bool {
  native_window_is_resizable(window_handle)
}

///|
fn window_decorated(window_handle : UInt64) -> Bool {
  native_window_is_decorated(window_handle)
}

///|
fn set_title(window_handle : UInt64, title : String) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_title(window_handle, title)
  }
}

///|
fn set_window_name(window_handle : UInt64, name : String) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_name(window_handle, name)
  }
}

///|
fn set_window_skip_taskbar(window_handle : UInt64, skip_taskbar : Bool) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_skip_taskbar(window_handle, skip_taskbar)
  }
}

///|
fn set_window_clip_children(
  window_handle : UInt64,
  clip_children : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_clip_children(window_handle, clip_children)
  }
}

///|
fn focus_window(window_handle : UInt64) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() &&
    native_window_is_visible(window_handle) {
    show_window(window_handle, true)
  }
}

///|
fn request_user_attention(window_handle : UInt64, request_type : Int) -> Unit {
  let _ = window_handle
  native_window_request_user_attention(request_type)
}

///|
fn window_native_scale_factor(window_handle : UInt64) -> Double {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    1.0
  } else {
    native_window_scale_factor(native_handle)
  }
}

///|
fn set_surface_size(window_handle : UInt64, width : Int, height : Int) -> Unit {
  let content_width = clamp_size(width)
  let content_height = clamp_size(height)
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_content_size(window_handle, content_width, content_height)
  }
}

///|
fn set_surface_resize_increments(
  window_handle : UInt64,
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
  window_handle : UInt64,
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
  window_handle : UInt64,
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
fn set_window_position(window_handle : UInt64, x : Int, y : Int) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    let logical_position = @dpi.PhysicalPosition::new(x, y).to_logical(
      window_native_scale_factor(window_handle),
    )
    native_window_set_position(
      window_handle,
      logical_position.x().to_int(),
      logical_position.y().to_int(),
    )
  }
}

///|
fn center_window(window_handle : UInt64) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    let window = native_window_objc_handle(window_handle)
    if window != (0 : Int).to_uint64() {
      appkit_objc_msg_send_void(window, objc_runtime_selector_handle("center"))
    }
  }
}

///|
fn set_window_outer_size(
  window_handle : UInt64,
  width : Int,
  height : Int,
) -> Unit {
  let logical_size = @dpi.PhysicalSize::new(width, height).to_logical(
    window_native_scale_factor(window_handle),
  )
  set_surface_size(
    window_handle,
    logical_size.width().to_int(),
    logical_size.height().to_int(),
  )
}

///|
fn set_window_minimized(window_handle : UInt64, minimized : Bool) -> Unit {
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
fn set_window_maximized(window_handle : UInt64, maximized : Bool) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_maximized(window_handle, maximized)
  }
}

///|
fn window_in_fullscreen_transition(window_handle : UInt64) -> Bool {
  match window_fullscreen_transition_index(window_handle) {
    Some(index) => fullscreen_transition_values.val[index]
    None => false
  }
}

///|
fn toggle_window_fullscreen(window_handle : UInt64, fullscreen : Bool) -> Unit {
  let window = native_window_objc_handle(window_handle)
  if window == (0 : Int).to_uint64() {
    return ()
  }
  let is_fullscreen = native_window_is_fullscreen(window_handle)
  let should_toggle = (fullscreen && is_fullscreen == false) ||
    (fullscreen == false && is_fullscreen)
  if should_toggle {
    set_window_fullscreen_transition_state(window_handle, true)
    appkit_objc_msg_send_void_u64(
      window,
      objc_runtime_selector_handle("toggleFullScreen:"),
      (0 : Int).to_uint64(),
    )
  }
}

///|
fn set_window_fullscreen(window_handle : UInt64, fullscreen : Bool) -> Unit {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  match app_state_window_raw_id(native_handle) {
    Some(raw_id) =>
      if window_in_fullscreen_transition(native_handle) {
        app_state_set_fullscreen_request(raw_id, fullscreen)
      } else {
        app_state_clear_fullscreen_request(raw_id)
        toggle_window_fullscreen(native_handle, fullscreen)
      }
    None => toggle_window_fullscreen(native_handle, fullscreen)
  }
}

///|
fn set_window_decorations(window_handle : UInt64, decorated : Bool) -> Unit {
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
  if window_resizable(window_handle) {
    // Resizable
    style_mask = style_mask | (8 : Int).to_uint64()
  }
  style_mask = style_mask | utility_window_bits
  native_window_set_style_mask(window_handle, style_mask)
}

///|
fn set_window_panel(window_handle : UInt64, panel : Bool) -> Unit {
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
  window_handle : UInt64,
  close : Bool,
  minimize : Bool,
  maximize : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_enabled_buttons(window_handle, close, minimize, maximize)
  }
}

///|
fn set_window_blur(window_handle : UInt64, blur : Bool) -> Unit {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  let window = native_window_objc_handle(native_handle)
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
fn set_window_accepts_first_mouse(
  window_handle : UInt64,
  accepts_first_mouse : Bool,
) -> Unit {
  set_window_accepts_first_mouse_state(window_handle, accepts_first_mouse)
}

///|
fn set_window_movable_by_window_background(
  window_handle : UInt64,
  movable_by_window_background : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_movable_by_background(
      window_handle, movable_by_window_background,
    )
  }
}

///|
fn set_window_titlebar_transparent(
  window_handle : UInt64,
  titlebar_transparent : Bool,
) -> Unit {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  let window = native_window_objc_handle(native_handle)
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
fn set_window_title_hidden(window_handle : UInt64, title_hidden : Bool) -> Unit {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  let window = native_window_objc_handle(native_handle)
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
fn set_window_titlebar_hidden(
  window_handle : UInt64,
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
  window_handle : UInt64,
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
  window_handle : UInt64,
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
fn set_window_has_shadow(window_handle : UInt64, has_shadow : Bool) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_has_shadow(window_handle, has_shadow)
  }
}

///|
fn set_window_document_edited(window_handle : UInt64, edited : Bool) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_document_edited(window_handle, edited)
  }
}

///|
fn set_window_borderless_game(
  window_handle : UInt64,
  borderless_game : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() &&
    native_window_is_fullscreen(window_handle) {
    set_application_presentation_options(
      simple_fullscreen_presentation_options(borderless_game),
    )
  }
}

///|
fn set_window_unified_titlebar(
  window_handle : UInt64,
  unified_titlebar : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_unified_titlebar(window_handle, unified_titlebar)
  }
}

///|
fn set_window_tabbing_identifier(
  window_handle : UInt64,
  identifier : String,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_tabbing_identifier(window_handle, identifier)
  }
}

///|
fn set_window_tabbing_mode_preferred(window_handle : UInt64) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_tabbing_mode_preferred(window_handle)
  }
}

///|
fn select_window_next_tab(window_handle : UInt64) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_select_next_tab(window_handle)
  }
}

///|
fn select_window_previous_tab(window_handle : UInt64) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_select_previous_tab(window_handle)
  }
}

///|
fn select_window_tab_at_index(window_handle : UInt64, index : Int) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_select_tab_at_index(window_handle, index)
  }
}

///|
fn set_window_option_as_alt(
  window_handle : UInt64,
  option_as_alt : Int,
) -> Unit {
  set_window_option_as_alt_state(window_handle, option_as_alt)
}

///|
fn set_window_cursor(window_handle : UInt64, cursor : Int) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_cursor(window_handle, cursor)
  }
}

///|
fn set_window_custom_cursor(
  window_handle : UInt64,
  custom_cursor : UInt64,
) -> Bool {
  native_window_set_custom_cursor(window_handle, custom_cursor)
}

///|
fn set_parent_window(window_handle : UInt64, parent_window : UInt64) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  let parent_handle = registered_native_handle(parent_window)
  if native_handle == (0 : Int).to_uint64() ||
    parent_handle == (0 : Int).to_uint64() {
    false
  } else {
    let window = native_window_objc_handle(native_handle)
    let parent = native_window_objc_handle(parent_handle)
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
fn set_window_cursor_visible(window_handle : UInt64, visible : Bool) -> Unit {
  let native_handle = registered_native_handle(window_handle)
  if native_handle != (0 : Int).to_uint64() {
    native_window_set_cursor_visible(native_handle, visible)
  }
}

///|
fn window_cursor_visible(window_handle : UInt64) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    true
  } else {
    native_window_cursor_visible(native_handle)
  }
}

///|
fn set_window_cursor_hittest(window_handle : UInt64, hittest : Bool) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return false
  }
  let window = native_window_objc_handle(native_handle)
  if window == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_void_bool(
    window,
    objc_runtime_selector_handle("setIgnoresMouseEvents:"),
    hittest == false,
  )
  true
}

///|
fn window_cursor_hittest(window_handle : UInt64) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    true
  } else {
    let window = native_window_objc_handle(native_handle)
    if window == (0 : Int).to_uint64() {
      true
    } else {
      appkit_objc_msg_send_bool(
        window,
        objc_runtime_selector_handle("ignoresMouseEvents"),
      ) ==
      false
    }
  }
}

///|
fn set_cursor_position(window_handle : UInt64, x : Int, y : Int) -> Bool {
  native_window_set_cursor_position(window_handle, x, y)
}

///|
fn set_cursor_grab(window_handle : UInt64, mode : Int) -> Bool {
  native_window_set_cursor_grab(window_handle, mode)
}

///|
fn drag_window(window_handle : UInt64) -> Int {
  native_window_drag_window(window_handle)
}

///|
fn drag_resize_window(window_handle : UInt64, direction : Int) -> Bool {
  native_window_drag_resize_window(window_handle, direction)
}

///|
fn show_window_menu(window_handle : UInt64, x : Int, y : Int) -> Bool {
  native_window_show_window_menu(window_handle, x, y)
}

///|
fn set_window_transparent(window_handle : UInt64, transparent : Bool) -> Unit {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  let window = native_window_objc_handle(native_handle)
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
fn set_window_level(window_handle : UInt64, level : Int) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_level(window_handle, level)
  }
}

///|
fn set_window_theme(window_handle : UInt64, theme : Int) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_theme(window_handle, theme)
  }
}

///|
fn set_window_content_protected(
  window_handle : UInt64,
  content_protected : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_content_protected(window_handle, content_protected)
  }
}

///|
fn set_ime_purpose(window_handle : UInt64, purpose : Int) -> Unit {
  set_window_ime_purpose_state(window_handle, purpose)
}

///|
fn window_ime_purpose(window_handle : UInt64) -> Int {
  window_ime_purpose_state(window_handle)
}

///|
fn set_ime_hints(window_handle : UInt64, hints : Int) -> Unit {
  set_window_ime_hints_state(window_handle, hints)
}

///|
fn window_ime_hints(window_handle : UInt64) -> Int {
  window_ime_hints_state(window_handle)
}

///|
fn set_ime_allowed(window_handle : UInt64, allowed : Bool) -> Unit {
  set_window_ime_allowed_state(window_handle, allowed)
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  let content_view = native_window_content_view_objc_handle(native_handle)
  if content_view == (0 : Int).to_uint64() {
    return ()
  }
  if !allowed {
    match app_state_window_raw_id(native_handle) {
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
fn window_ime_allowed(window_handle : UInt64) -> Bool {
  window_ime_allowed_state(window_handle)
}

///|
fn set_ime_cursor_area(
  window_handle : UInt64,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Unit {
  set_window_ime_cursor_area_state(window_handle, x, y, width, height)
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  let content_view = native_window_content_view_objc_handle(native_handle)
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
fn window_ime_cursor_x(window_handle : UInt64) -> Int {
  window_ime_cursor_x_state(window_handle)
}

///|
fn window_ime_cursor_y(window_handle : UInt64) -> Int {
  window_ime_cursor_y_state(window_handle)
}

///|
fn window_ime_cursor_width(window_handle : UInt64) -> Int {
  window_ime_cursor_width_state(window_handle)
}

///|
fn window_ime_cursor_height(window_handle : UInt64) -> Int {
  window_ime_cursor_height_state(window_handle)
}

///|
fn native_window_width(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    800
  } else {
    native_window_content_width(native_handle)
  }
}

///|
fn native_window_height(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    600
  } else {
    native_window_content_height(native_handle)
  }
}

///|
fn window_min_surface_width(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_min_content_width(native_handle)
  }
}

///|
fn window_min_surface_height(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_min_content_height(native_handle)
  }
}

///|
fn window_max_surface_width(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_max_content_width(native_handle)
  }
}

///|
fn window_max_surface_height(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_max_content_height(native_handle)
  }
}

///|
fn window_outer_width(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    native_window_width(window_handle)
  } else {
    native_window_outer_width(native_handle)
  }
}

///|
fn window_outer_height(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    native_window_height(window_handle)
  } else {
    native_window_outer_height(native_handle)
  }
}

///|
fn window_surface_x(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_surface_x(native_handle)
  }
}

///|
fn window_surface_y(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_surface_y(native_handle)
  }
}

///|
fn window_safe_area_top(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_safe_area_top(native_handle)
  }
}

///|
fn window_safe_area_left(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_safe_area_left(native_handle)
  }
}

///|
fn window_safe_area_bottom(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_safe_area_bottom(native_handle)
  }
}

///|
fn window_safe_area_right(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_safe_area_right(native_handle)
  }
}

///|
fn window_resize_increment_width(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_resize_increment_width(native_handle)
  }
}

///|
fn window_resize_increment_height(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_resize_increment_height(native_handle)
  }
}

///|
fn window_x(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_x(native_handle)
  }
}

///|
fn window_y(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_y(native_handle)
  }
}

///|
fn window_theme(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_theme(native_handle)
  }
}

///|
fn window_has_shadow(window_handle : UInt64) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_has_shadow(native_handle)
  }
}

///|
fn window_document_edited(window_handle : UInt64) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_document_edited(native_handle)
  }
}

///|
fn window_level_value(window_handle : UInt64) -> @core.WindowLevel {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    @core.WindowLevel::Normal
  } else {
    window_level_from_native(native_window_level(native_handle))
  }
}

///|
fn window_option_as_alt(window_handle : UInt64) -> @core.OptionAsAlt {
  option_as_alt_from_native(window_option_as_alt_native(window_handle))
}

///|
fn window_enabled_buttons(window_handle : UInt64) -> @core.WindowButtons {
  let native_handle = registered_native_handle(window_handle)
  let bits = if native_handle == (0 : Int).to_uint64() {
    0
  } else {
    native_window_enabled_buttons_mask(native_handle)
  }
  @core.WindowButtons::none()
  .with_close((bits & 1) != 0)
  .with_minimize((bits & 2) != 0)
  .with_maximize((bits & 4) != 0)
}

///|
fn window_transparent(window_handle : UInt64) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    let window = native_window_objc_handle(native_handle)
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

///|
fn window_content_protected(window_handle : UInt64) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_content_protected(native_handle)
  }
}

///|
fn window_has_focus(window_handle : UInt64) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_has_focus(native_handle)
  }
}

///|
fn window_occluded(window_handle : UInt64) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_occluded(native_handle)
  }
}

///|
fn window_minimized(window_handle : UInt64) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_minimized(native_handle)
  }
}

///|
fn window_maximized(window_handle : UInt64) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_maximized(native_handle)
  }
}

///|
fn window_fullscreen(window_handle : UInt64) -> Bool {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    false
  } else {
    native_window_is_fullscreen(native_handle)
  }
}

///|
fn window_num_tabs(window_handle : UInt64) -> Int {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    1
  } else {
    native_window_num_tabs(native_handle)
  }
}

///|
fn window_style_mask_bits(window_handle : UInt64) -> UInt64 {
  let native_handle = registered_native_handle(window_handle)
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
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_style_mask(window_handle, style_mask)
  }
}

///|
fn clear_window_style_mask_bits(
  window_handle : UInt64,
  style_mask : UInt64,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_clear_style_mask_bits(window_handle, style_mask)
  }
}

///|
fn set_window_movable(window_handle : UInt64, movable : Bool) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_movable(window_handle, movable)
  }
}

///|
fn application_presentation_options() -> UInt64 {
  native_application_presentation_options()
}

///|
fn set_application_presentation_options(options : UInt64) -> Unit {
  native_set_application_presentation_options(options)
}

///|
fn find_display_mode_handle(
  monitor_id : UInt64,
  width : Int,
  height : Int,
  bit_depth : Int,
  refresh_rate_millihertz : Int,
) -> UInt64 {
  native_find_display_mode_handle(
    monitor_id, width, height, bit_depth, refresh_rate_millihertz,
  )
}

///|
fn copy_current_display_mode_handle(monitor_id : UInt64) -> UInt64 {
  native_copy_current_display_mode_handle(monitor_id)
}

///|
fn release_display_mode_handle(mode_handle : UInt64) -> Unit {
  native_release_display_mode_handle(mode_handle)
}

///|
fn capture_display(monitor_id : UInt64) -> Bool {
  native_capture_display(monitor_id)
}

///|
fn set_display_mode_handle(monitor_id : UInt64, mode_handle : UInt64) -> Bool {
  native_set_display_mode_handle(monitor_id, mode_handle)
}

///|
fn release_display_capture(monitor_id : UInt64) -> Bool {
  native_release_display_capture(monitor_id)
}

///|
fn set_window_exclusive_runtime_state(
  window_handle : UInt64,
  exclusive_fullscreen : Bool,
  display_id : UInt64,
  saved_mode_handle : UInt64,
) -> Unit {
  let _ = display_id
  let _ = saved_mode_handle
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_movable(window_handle, exclusive_fullscreen == false)
  }
}

///|
fn window_current_monitor_id(window_handle : UInt64) -> UInt64 {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    (0 : Int).to_uint64()
  } else {
    native_window_current_monitor_id(native_handle)
  }
}

///|
fn initial_window_surface_size(
  surface_size : @dpi.Size?,
  scale_factor : Double,
) -> @dpi.LogicalSize {
  match surface_size {
    Some(size) => size.to_logical(scale_factor)
    None => @dpi.LogicalSize::new(800.0, 600.0)
  }
}

///|
fn fullscreen_target_surface_size(
  fullscreen : @core.Fullscreen?,
  primary_monitor : @core.MonitorHandle?,
) -> @dpi.LogicalSize? {
  match fullscreen {
    Some(@core.Fullscreen::Borderless(Some(monitor))) =>
      Some(monitor.surface_size().to_logical(monitor.scale_factor()))
    Some(@core.Fullscreen::Exclusive(monitor, _video_mode)) =>
      Some(monitor.surface_size().to_logical(monitor.scale_factor()))
    Some(@core.Fullscreen::Borderless(None)) =>
      match primary_monitor {
        Some(monitor) =>
          Some(monitor.surface_size().to_logical(monitor.scale_factor()))
        None => None
      }
    None => None
  }
}

///|
fn should_apply_initial_window_position(fullscreen : @core.Fullscreen?) -> Bool {
  match fullscreen {
    Some(_) => false
    None => true
  }
}

///|
fn should_center_initial_window(position : @dpi.Position?) -> Bool {
  match position {
    Some(_) => false
    None => true
  }
}

///|
fn window_position_to_logical(
  position : @dpi.Position,
  scale_factor : Double,
) -> @dpi.LogicalPosition {
  position.to_logical(scale_factor)
}

///|
// Port target: window_delegate.rs::new
fn new_window(
  event_loop : EventLoop,
  attributes : @core.WindowAttributes,
) -> Window raise @core.RequestError {
  guard is_main_thread() else { raise @core.RequestError::Os }
  let raw_id = app_state_next_window_id()
  let scale_factor = match event_loop.primary_monitor() {
    Some(monitor) => monitor.scale_factor()
    None => 1.0
  }
  let fullscreen = attributes.fullscreen()
  let size = match
    fullscreen_target_surface_size(fullscreen, event_loop.primary_monitor()) {
    Some(size) => size
    None => initial_window_surface_size(attributes.surface_size(), scale_factor)
  }
  let raw_window_handle = create_window(
    clamp_size(size.width().to_int()),
    clamp_size(size.height().to_int()),
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
  set_window_raw_id(raw_window_handle, raw_id)
  app_state_register_window_handle(raw_id, raw_window_handle)
  set_title(raw_window_handle, attributes.title())
  native_set_resizable(raw_window_handle, attributes.resizable())
  set_window_panel(raw_window_handle, attributes.platform_attributes().panel())
  set_window_decorations(raw_window_handle, attributes.decorations())
  match attributes.name() {
    Some(name) => set_window_name(raw_window_handle, name)
    None => ()
  }
  set_window_skip_taskbar(raw_window_handle, attributes.skip_taskbar())
  set_window_clip_children(raw_window_handle, attributes.clip_children())
  set_window_borderless_game(
    raw_window_handle,
    attributes.platform_attributes().borderless_game(),
  )
  set_window_accepts_first_mouse(
    raw_window_handle,
    attributes.platform_attributes().accepts_first_mouse(),
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
      let logical_increments = increments.to_logical(scale_factor)
      set_surface_resize_increments(
        raw_window_handle,
        logical_increments.width().to_int(),
        logical_increments.height().to_int(),
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
  match fullscreen {
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
      let logical_min = min_size.to_logical(scale_factor)
      set_min_surface_size(
        raw_window_handle,
        logical_min.width().to_int(),
        logical_min.height().to_int(),
      )
    }
    None => ()
  }
  match attributes.max_surface_size() {
    Some(max_size) => {
      let logical_max = max_size.to_logical(scale_factor)
      set_max_surface_size(
        raw_window_handle,
        logical_max.width().to_int(),
        logical_max.height().to_int(),
      )
    }
    None => ()
  }
  let position = attributes.position()
  if should_center_initial_window(position) {
    center_window(raw_window_handle)
  } else if should_apply_initial_window_position(fullscreen) {
    match position {
      Some(position) => {
        let logical_position = window_position_to_logical(
          position, scale_factor,
        )
        set_window_position(
          raw_window_handle,
          logical_position.x().to_int(),
          logical_position.y().to_int(),
        )
      }
      None => ()
    }
  }
  if attributes.visible() {
    show_window(raw_window_handle, attributes.active())
  }
  if attributes.maximized() {
    set_window_maximized(raw_window_handle, true)
  }
  let raw_view_handle = native_window_content_view_objc_handle(
    raw_window_handle,
  )
  let window : Window = {
    id: @core.WindowId::from_raw(raw_id),
    raw_window_handle,
    raw_view_handle,
    cursor_state,
    fullscreen_state: initial_fullscreen_state(attributes),
    ime_capabilities_state: None,
    ime_surrounding_text_state: None,
    prefers_home_indicator_hidden_state: false,
    prefers_status_bar_hidden_state: false,
    preferred_screen_edges_deferring_system_gestures_state: @core.ScreenEdge::none(),
    blur_state: attributes.blur(),
    disallow_hidpi_state: attributes.platform_attributes().disallow_hidpi(),
    borderless_game_state: attributes.platform_attributes().borderless_game(),
    unified_titlebar_state: attributes.platform_attributes().unified_titlebar(),
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
  @dpi.LogicalSize::new(
    native_window_width(self.raw_window_handle).to_double(),
    native_window_height(self.raw_window_handle).to_double(),
  ).to_physical(self.scale_factor())
}

///|
pub fn Window::inner_size(self : Window) -> @dpi.PhysicalSize {
  self.surface_size()
}

///|
pub fn Window::outer_size(self : Window) -> @dpi.PhysicalSize {
  @dpi.LogicalSize::new(
    window_outer_width(self.raw_window_handle).to_double(),
    window_outer_height(self.raw_window_handle).to_double(),
  ).to_physical(self.scale_factor())
}

///|
pub fn Window::surface_position(self : Window) -> @dpi.PhysicalPosition {
  @dpi.LogicalPosition::new(
    window_surface_x(self.raw_window_handle).to_double(),
    window_surface_y(self.raw_window_handle).to_double(),
  ).to_physical(self.scale_factor())
}

///|
pub fn Window::inner_position(self : Window) -> @dpi.PhysicalPosition {
  self.surface_position()
}

///|
pub fn Window::safe_area(self : Window) -> @dpi.PhysicalInsets {
  let scale_factor = self.scale_factor()
  @dpi.PhysicalInsets::new(
    (window_safe_area_top(self.raw_window_handle).to_double() * scale_factor).to_int(),
    (window_safe_area_left(self.raw_window_handle).to_double() * scale_factor).to_int(),
    (window_safe_area_bottom(self.raw_window_handle).to_double() * scale_factor).to_int(),
    (window_safe_area_right(self.raw_window_handle).to_double() * scale_factor).to_int(),
  )
}

///|
pub fn Window::request_surface_size(
  self : Window,
  size : @dpi.Size,
) -> @dpi.PhysicalSize? {
  let logical_size = size.to_logical(self.scale_factor())
  set_surface_size(
    self.raw_window_handle,
    logical_size.width().to_int(),
    logical_size.height().to_int(),
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
      let logical_size = size.to_logical(self.scale_factor())
      set_surface_resize_increments(
        self.raw_window_handle,
        logical_size.width().to_int(),
        logical_size.height().to_int(),
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
    Some(
      @dpi.LogicalSize::new(width.to_double(), height.to_double()).to_physical(
        self.scale_factor(),
      ),
    )
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
      let logical_size = size.to_logical(self.scale_factor())
      set_min_surface_size(
        self.raw_window_handle,
        logical_size.width().to_int(),
        logical_size.height().to_int(),
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
      let logical_size = size.to_logical(self.scale_factor())
      set_max_surface_size(
        self.raw_window_handle,
        logical_size.width().to_int(),
        logical_size.height().to_int(),
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
    Some(
      @dpi.LogicalSize::new(width.to_double(), height.to_double()).to_physical(
        self.scale_factor(),
      ),
    )
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
    Some(
      @dpi.LogicalSize::new(width.to_double(), height.to_double()).to_physical(
        self.scale_factor(),
      ),
    )
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
  @dpi.LogicalPosition::new(
    window_x(raw_id).to_double(),
    window_y(raw_id).to_double(),
  ).to_physical(self.scale_factor())
}

///|
pub fn Window::set_outer_position(
  self : Window,
  position : @dpi.Position,
) -> Unit {
  let logical_position = window_position_to_logical(
    position,
    self.scale_factor(),
  )
  set_window_position(
    self.raw_window_handle,
    logical_position.x().to_int(),
    logical_position.y().to_int(),
  )
}

///|
pub fn Window::focus_window(self : Window) -> Unit {
  let raw_id = self.raw_window_handle
  let is_minimized = window_minimized(raw_id)
  let is_visible = window_visible(raw_id)
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
  window_decorated(self.raw_window_handle)
}

///|
pub fn Window::enabled_buttons(self : Window) -> @core.WindowButtons {
  window_enabled_buttons(self.raw_window_handle)
}

///|
pub fn Window::is_blurred(self : Window) -> Bool {
  self.blur_state
}

///|
pub fn Window::set_transparent(self : Window, transparent : Bool) -> Unit {
  set_window_transparent(self.raw_window_handle, transparent)
}

///|
pub fn Window::is_transparent(self : Window) -> Bool {
  window_transparent(self.raw_window_handle)
}

///|
pub fn Window::set_window_level(
  self : Window,
  level : @core.WindowLevel,
) -> Unit {
  set_window_level(
    self.raw_window_handle,
    normalize_window_level_native(window_level_to_native(level)),
  )
}

///|
pub fn Window::window_level(self : Window) -> @core.WindowLevel {
  window_level_value(self.raw_window_handle)
}

///|
pub fn Window::scale_factor(self : Window) -> Double {
  if self.disallow_hidpi_state {
    1.0
  } else {
    native_window_scale_factor(self.raw_window_handle)
  }
}

///|
pub fn Window::request_redraw(self : Window) -> Unit {
  app_state_queue_redraw(self.id.into_raw())
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
  set_window_content_protected(self.raw_window_handle, content_protected)
}

///|
pub fn Window::set_visible(self : Window, visible : Bool) -> Unit {
  native_set_visible(self.raw_window_handle, visible)
}

///|
pub fn Window::is_visible(self : Window) -> Bool? {
  Some(window_visible(self.raw_window_handle))
}

///|
pub fn Window::set_resizable(self : Window, resizable : Bool) -> Unit {
  native_set_resizable(self.raw_window_handle, resizable)
}

///|
pub fn Window::is_resizable(self : Window) -> Bool {
  window_resizable(self.raw_window_handle)
}

///|
pub fn Window::is_content_protected(self : Window) -> Bool {
  window_content_protected(self.raw_window_handle)
}

///|
pub fn Window::is_document_edited(self : Window) -> Bool {
  window_document_edited(self.raw_window_handle)
}

///|
pub fn Window::set_document_edited(self : Window, edited : Bool) -> Unit {
  set_window_document_edited(self.raw_window_handle, edited)
}

///|
pub fn Window::set_option_as_alt(
  self : Window,
  option_as_alt : @core.OptionAsAlt,
) -> Unit {
  set_window_option_as_alt(
    self.raw_window_handle,
    normalize_option_as_alt_native(option_as_alt_to_native(option_as_alt)),
  )
}

///|
pub fn Window::option_as_alt(self : Window) -> @core.OptionAsAlt {
  window_option_as_alt(self.raw_window_handle)
}

///|
pub fn Window::set_prefers_home_indicator_hidden(
  self : Window,
  hidden : Bool,
) -> Unit {
  // AppKit has no home-indicator API; keep state for cross-platform parity.
  self.prefers_home_indicator_hidden_state = hidden
}

///|
pub fn Window::set_prefers_status_bar_hidden(
  self : Window,
  hidden : Bool,
) -> Unit {
  // AppKit has no status-bar API; keep state for cross-platform parity.
  self.prefers_status_bar_hidden_state = hidden
}

///|
pub fn Window::set_preferred_screen_edges_deferring_system_gestures(
  self : Window,
  edges : @core.ScreenEdge,
) -> Unit {
  // AppKit has no system-gesture deferral API; keep state for parity.
  self.preferred_screen_edges_deferring_system_gestures_state = edges
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
      None => Some(@core.Fullscreen::Borderless(self.current_monitor()))
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
  if self.simple_fullscreen_state {
    set_application_presentation_options(
      simple_fullscreen_presentation_options(borderless_game),
    )
  }
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
  set_window_decorations(self.raw_window_handle, decorations)
}

///|
pub fn Window::set_enabled_buttons(
  self : Window,
  buttons : @core.WindowButtons,
) -> Unit {
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
  window_has_shadow(self.raw_window_handle)
}

///|
pub fn Window::set_has_shadow(self : Window, has_shadow : Bool) -> Unit {
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
