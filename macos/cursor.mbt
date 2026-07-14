///|
// Port target: winit-reference/winit-appkit/src/cursor.rs

///|
pub fn EventLoop::create_custom_cursor(
  self : EventLoop,
  source : @core.CustomCursorSource,
) -> @core.CustomCursor raise @core.RequestError {
  match source {
    Rgba(rgba, width, height, hotspot_x, hotspot_y) =>
      self.create_custom_cursor_from_rgba_source(
        rgba, width, height, hotspot_x, hotspot_y,
      )
    Url(_, _, _) =>
      raise @core.RequestError::not_supported(
        "URL custom cursors are not supported on macOS",
      )
    Animation(_, _) =>
      raise @core.RequestError::not_supported(
        "Animated custom cursors are not supported on macOS",
      )
  }
}

///|
// Port target: cursor.rs::CustomCursorProvider::is_animated
fn is_animated(_cursor : @core.CustomCursor) -> Bool {
  false
}

///|
fn EventLoop::create_custom_cursor_from_rgba_source(
  self : EventLoop,
  rgba : Bytes,
  width : Int,
  height : Int,
  hotspot_x : Int,
  hotspot_y : Int,
) -> @core.CustomCursor raise @core.RequestError {
  ignore(self)
  cursor_from_image(rgba, width, height, hotspot_x, hotspot_y)
}

///|
fn native_custom_cursor_create_rgba_handle(
  rgba : Bytes,
  width : Int,
  height : Int,
  hotspot_x : Int,
  hotspot_y : Int,
) -> @core.CustomCursorHandle {
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
fn validate_rgba_cursor_source(
  rgba : Bytes,
  width : Int,
  height : Int,
  hotspot_x : Int,
  hotspot_y : Int,
) -> Unit raise @core.RequestError {
  if width <= 0 || height <= 0 {
    raise Ignored
  }
  // Keep runtime-side checks even though `from_rgba` already validates.
  if width > 2048 || height > 2048 {
    raise @core.RequestError::not_supported(
      "Custom cursor dimensions above 2048x2048 are not supported",
    )
  }
  if rgba.length() % 4 != 0 {
    raise Ignored
  }
  let pixel_count = rgba.length() / 4
  if pixel_count != width * height {
    raise Ignored
  }
  if hotspot_x < 0 || hotspot_x >= width || hotspot_y < 0 || hotspot_y >= height {
    raise Ignored
  }
}

///|
fn custom_cursor_from_native(
  handle : @core.CustomCursorHandle,
) -> @core.CustomCursor raise @core.RequestError {
  let raw = appkit_custom_cursor_objc_handle(handle)
  if raw == (0 : Int).to_uint64() {
    raise @core.RequestError::not_supported(
      "Failed to create a native custom cursor from RGBA data",
    )
  } else {
    let custom = @core.CustomCursor::from_native(raw, handle)
    ignore(is_animated(custom))
    custom
  }
}

///|
// Port target: cursor.rs::cursor_from_image
fn cursor_from_image(
  rgba : Bytes,
  width : Int,
  height : Int,
  hotspot_x : Int,
  hotspot_y : Int,
) -> @core.CustomCursor raise @core.RequestError {
  validate_rgba_cursor_source(rgba, width, height, hotspot_x, hotspot_y)
  custom_cursor_from_native(
    native_custom_cursor_create_rgba_handle(
      rgba, width, height, hotspot_x, hotspot_y,
    ),
  )
}

///|
fn native_cursor_class_cursor(
  cursor_class : UInt64,
  selector_name : String,
) -> UInt64 {
  if cursor_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let selector = objc_runtime_selector_handle(selector_name)
  if appkit_objc_msg_send_bool_u64(
      cursor_class,
      objc_runtime_selector_handle("respondsToSelector:"),
      selector,
    ) {
    appkit_objc_msg_send_u64(cursor_class, selector)
  } else {
    (0 : Int).to_uint64()
  }
}

///|
fn native_cursor_frame_resize(
  cursor_class : UInt64,
  position : UInt64,
  directions : UInt64,
) -> UInt64 {
  if cursor_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let selector = objc_runtime_selector_handle(
    "frameResizeCursorFromPosition:inDirections:",
  )
  if appkit_objc_msg_send_bool_u64(
      cursor_class,
      objc_runtime_selector_handle("respondsToSelector:"),
      selector,
    ) {
    appkit_objc_msg_send_u64_u64_u64(
      cursor_class, selector, position, directions,
    )
  } else {
    (0 : Int).to_uint64()
  }
}

///|
fn native_cursor_fallback(cursor : UInt64, cursor_class : UInt64) -> UInt64 {
  if cursor != (0 : Int).to_uint64() {
    cursor
  } else {
    native_cursor_class_cursor(cursor_class, "arrowCursor")
  }
}

///|
fn cursor_from_icon(cursor : @core.CursorIcon) -> UInt64 {
  let ns_cursor_class = objc_runtime_class_handle("NSCursor")
  if ns_cursor_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let mut resolved = (0 : Int).to_uint64()
  let direction_outward = (2 : Int).to_uint64()
  let direction_all = (3 : Int).to_uint64()
  match cursor {
    ContextMenu =>
      resolved = native_cursor_class_cursor(
        ns_cursor_class, "contextualMenuCursor",
      )
    Help =>
      resolved = native_cursor_class_cursor(ns_cursor_class, "_helpCursor")
    Progress =>
      resolved = native_cursor_class_cursor(
        ns_cursor_class, "busyButClickableCursor",
      )
    Wait =>
      resolved = native_cursor_class_cursor(
        ns_cursor_class, "busyButClickableCursor",
      )
    Cell =>
      resolved = native_cursor_class_cursor(ns_cursor_class, "crosshairCursor")
    VerticalText => {
      resolved = native_cursor_class_cursor(
        ns_cursor_class, "IBeamCursorForVerticalLayout",
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(ns_cursor_class, "IBeamCursor")
      }
    }
    Alias =>
      resolved = native_cursor_class_cursor(ns_cursor_class, "dragLinkCursor")
    Copy =>
      resolved = native_cursor_class_cursor(ns_cursor_class, "dragCopyCursor")
    NoDrop =>
      resolved = native_cursor_class_cursor(
        ns_cursor_class, "operationNotAllowedCursor",
      )
    Grab =>
      resolved = native_cursor_class_cursor(ns_cursor_class, "openHandCursor")
    Grabbing =>
      resolved = native_cursor_class_cursor(ns_cursor_class, "closedHandCursor")
    EResize => {
      resolved = native_cursor_frame_resize(
        ns_cursor_class,
        (8 : Int).to_uint64(),
        direction_outward,
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(
          ns_cursor_class, "resizeRightCursor",
        )
      }
    }
    NResize => {
      resolved = native_cursor_frame_resize(
        ns_cursor_class,
        (1 : Int).to_uint64(),
        direction_outward,
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(ns_cursor_class, "resizeUpCursor")
      }
    }
    NeResize => {
      resolved = native_cursor_frame_resize(
        ns_cursor_class,
        (9 : Int).to_uint64(),
        direction_outward,
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(
          ns_cursor_class, "_windowResizeNorthEastCursor",
        )
      }
    }
    NwResize => {
      resolved = native_cursor_frame_resize(
        ns_cursor_class,
        (3 : Int).to_uint64(),
        direction_outward,
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(
          ns_cursor_class, "_windowResizeNorthWestCursor",
        )
      }
    }
    SResize => {
      resolved = native_cursor_frame_resize(
        ns_cursor_class,
        (4 : Int).to_uint64(),
        direction_outward,
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(
          ns_cursor_class, "resizeDownCursor",
        )
      }
    }
    SeResize => {
      resolved = native_cursor_frame_resize(
        ns_cursor_class,
        (12 : Int).to_uint64(),
        direction_outward,
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(
          ns_cursor_class, "_windowResizeSouthEastCursor",
        )
      }
    }
    SwResize => {
      resolved = native_cursor_frame_resize(
        ns_cursor_class,
        (6 : Int).to_uint64(),
        direction_outward,
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(
          ns_cursor_class, "_windowResizeSouthWestCursor",
        )
      }
    }
    WResize => {
      resolved = native_cursor_frame_resize(
        ns_cursor_class,
        (2 : Int).to_uint64(),
        direction_outward,
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(
          ns_cursor_class, "resizeLeftCursor",
        )
      }
    }
    EwResize => {
      resolved = native_cursor_frame_resize(
        ns_cursor_class,
        (8 : Int).to_uint64(),
        direction_all,
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(
          ns_cursor_class, "resizeLeftRightCursor",
        )
      }
    }
    NsResize => {
      resolved = native_cursor_frame_resize(
        ns_cursor_class,
        (1 : Int).to_uint64(),
        direction_all,
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(
          ns_cursor_class, "resizeUpDownCursor",
        )
      }
    }
    NeswResize => {
      resolved = native_cursor_frame_resize(
        ns_cursor_class,
        (9 : Int).to_uint64(),
        direction_all,
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(
          ns_cursor_class, "_windowResizeNorthEastSouthWestCursor",
        )
      }
    }
    NwseResize => {
      resolved = native_cursor_frame_resize(
        ns_cursor_class,
        (3 : Int).to_uint64(),
        direction_all,
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(
          ns_cursor_class, "_windowResizeNorthWestSouthEastCursor",
        )
      }
    }
    ColResize => {
      resolved = native_cursor_class_cursor(
        ns_cursor_class, "columnResizeCursor",
      )
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(
          ns_cursor_class, "resizeLeftRightCursor",
        )
      }
    }
    RowResize => {
      resolved = native_cursor_class_cursor(ns_cursor_class, "rowResizeCursor")
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(
          ns_cursor_class, "resizeUpDownCursor",
        )
      }
    }
    ZoomIn => {
      resolved = native_cursor_class_cursor(ns_cursor_class, "zoomInCursor")
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(ns_cursor_class, "_zoomInCursor")
      }
    }
    ZoomOut => {
      resolved = native_cursor_class_cursor(ns_cursor_class, "zoomOutCursor")
      if resolved == (0 : Int).to_uint64() {
        resolved = native_cursor_class_cursor(ns_cursor_class, "_zoomOutCursor")
      }
    }
    Pointer =>
      resolved = native_cursor_class_cursor(
        ns_cursor_class, "pointingHandCursor",
      )
    Text =>
      resolved = native_cursor_class_cursor(ns_cursor_class, "IBeamCursor")
    Crosshair =>
      resolved = native_cursor_class_cursor(ns_cursor_class, "crosshairCursor")
    AllScroll | Move =>
      resolved = native_cursor_class_cursor(ns_cursor_class, "openHandCursor")
    NotAllowed =>
      resolved = native_cursor_class_cursor(
        ns_cursor_class, "operationNotAllowedCursor",
      )
    Default =>
      resolved = native_cursor_class_cursor(ns_cursor_class, "arrowCursor")
  }
  native_cursor_fallback(resolved, ns_cursor_class)
}

///|
let invisible_cursor_handle : Ref[@core.CustomCursorHandle?] = Ref(None)

///|
// Port target: cursor.rs::invisible_cursor
fn invisible_cursor() -> UInt64 {
  match invisible_cursor_handle.val {
    Some(cached) => {
      let cached_obj = appkit_custom_cursor_objc_handle(cached)
      if cached_obj != (0 : Int).to_uint64() {
        return cached_obj
      }
    }
    None => ()
  }
  let cursor_handle = appkit_custom_cursor_create_rgba(
    Bytes::make(4, (0 : Int).to_byte()),
    4,
    1,
    1,
    0,
    0,
  )
  let cursor = appkit_custom_cursor_objc_handle(cursor_handle)
  if cursor != (0 : Int).to_uint64() {
    invisible_cursor_handle.val = Some(cursor_handle)
  }
  cursor
}

///|
fn cursor_grab_mode_to_native(mode : @core.CursorGrabMode) -> Int {
  match mode {
    None => 0
    Locked => 1
    Confined => 2
  }
}
