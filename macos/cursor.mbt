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
  raw : UInt64,
) -> @core.CustomCursor raise @core.RequestError {
  if raw == (0 : Int).to_uint64() {
    raise @core.RequestError::not_supported(
      "Failed to create a native custom cursor from RGBA data",
    )
  } else {
    let custom = @core.CustomCursor::from_raw(raw)
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
    native_custom_cursor_create_rgba(rgba, width, height, hotspot_x, hotspot_y),
  )
}

///|
// Port target: cursor.rs::default_cursor
fn default_cursor() -> Int {
  ignore(invisible_cursor())
  0
}

///|
// Port target: cursor.rs::try_cursor_from_selector
fn try_cursor_from_selector(selector : String) -> Int? {
  match selector {
    "_helpCursor" => Some(2)
    "_zoomInCursor" => Some(27)
    "_zoomOutCursor" => Some(28)
    "_windowResizeNorthEastCursor" => Some(14)
    "_windowResizeNorthWestCursor" => Some(15)
    "_windowResizeSouthEastCursor" => Some(17)
    "_windowResizeSouthWestCursor" => Some(18)
    "_windowResizeNorthEastSouthWestCursor" => Some(22)
    "_windowResizeNorthWestSouthEastCursor" => Some(23)
    "_moveCursor" => Some(32)
    "_waitCursor" => Some(4)
    "busyButClickableCursor" => Some(3)
    _ => None
  }
}

///|
fn _helpCursor() -> Int {
  match try_cursor_from_selector("_helpCursor") {
    Some(cursor) => cursor
    None => default_cursor()
  }
}

///|
fn _zoomInCursor() -> Int {
  match try_cursor_from_selector("_zoomInCursor") {
    Some(cursor) => cursor
    None => default_cursor()
  }
}

///|
fn _zoomOutCursor() -> Int {
  match try_cursor_from_selector("_zoomOutCursor") {
    Some(cursor) => cursor
    None => default_cursor()
  }
}

///|
fn _windowResizeNorthEastCursor() -> Int {
  match try_cursor_from_selector("_windowResizeNorthEastCursor") {
    Some(cursor) => cursor
    None => default_cursor()
  }
}

///|
fn _windowResizeNorthWestCursor() -> Int {
  match try_cursor_from_selector("_windowResizeNorthWestCursor") {
    Some(cursor) => cursor
    None => default_cursor()
  }
}

///|
fn _windowResizeSouthEastCursor() -> Int {
  match try_cursor_from_selector("_windowResizeSouthEastCursor") {
    Some(cursor) => cursor
    None => default_cursor()
  }
}

///|
fn _windowResizeSouthWestCursor() -> Int {
  match try_cursor_from_selector("_windowResizeSouthWestCursor") {
    Some(cursor) => cursor
    None => default_cursor()
  }
}

///|
fn _windowResizeNorthEastSouthWestCursor() -> Int {
  match try_cursor_from_selector("_windowResizeNorthEastSouthWestCursor") {
    Some(cursor) => cursor
    None => default_cursor()
  }
}

///|
fn _windowResizeNorthWestSouthEastCursor() -> Int {
  match try_cursor_from_selector("_windowResizeNorthWestSouthEastCursor") {
    Some(cursor) => cursor
    None => default_cursor()
  }
}

///|
fn _moveCursor() -> Int {
  match try_cursor_from_selector("_moveCursor") {
    Some(cursor) => cursor
    None => default_cursor()
  }
}

///|
fn _waitCursor() -> Int {
  match try_cursor_from_selector("_waitCursor") {
    Some(cursor) => cursor
    None => default_cursor()
  }
}

///|
fn busyButClickableCursor() -> Int {
  match try_cursor_from_selector("busyButClickableCursor") {
    Some(cursor) => cursor
    None => default_cursor()
  }
}

///|
fn load_webkit_cursor(name : String) -> Int {
  match name {
    "move" => 32
    "cell" => 5
    _ => default_cursor()
  }
}

///|
fn webkit_move() -> Int {
  load_webkit_cursor("move")
}

///|
fn webkit_cell() -> Int {
  load_webkit_cursor("cell")
}

///|
fn new_invisible() -> Int {
  0
}

///|
fn invisible_cursor() -> Int {
  new_invisible()
}

///|
fn cursor_from_icon(cursor : @core.CursorIcon) -> Int {
  match cursor {
    Default => default_cursor()
    ContextMenu => 1
    Help => _helpCursor()
    Progress => busyButClickableCursor()
    Wait => busyButClickableCursor()
    Cell => webkit_cell()
    VerticalText => 6
    Alias => 7
    Copy => 8
    NoDrop => 9
    Grab => 10
    Grabbing => 11
    EResize => 12
    NResize => 13
    NeResize => _windowResizeNorthEastCursor()
    NwResize => _windowResizeNorthWestCursor()
    SResize => 16
    SeResize => _windowResizeSouthEastCursor()
    SwResize => _windowResizeSouthWestCursor()
    WResize => 19
    EwResize => 20
    NsResize => 21
    NeswResize => _windowResizeNorthEastSouthWestCursor()
    NwseResize => _windowResizeNorthWestSouthEastCursor()
    ColResize => 24
    RowResize => 25
    AllScroll => _moveCursor()
    ZoomIn => _zoomInCursor()
    ZoomOut => _zoomOutCursor()
    Pointer => 29
    Text => 30
    Crosshair => 31
    Move => webkit_move()
    NotAllowed => 33
  }
}

///|
fn cursor_icon_to_native(cursor : @core.CursorIcon) -> Int {
  cursor_from_icon(cursor)
}

///|
fn cursor_grab_mode_to_native(mode : @core.CursorGrabMode) -> Int {
  match mode {
    None => 0
    Locked => 1
    Confined => 2
  }
}
