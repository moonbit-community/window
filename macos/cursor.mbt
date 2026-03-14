///|
// Port target: winit-reference/winit-appkit/src/cursor.rs

///|
pub fn EventLoop::create_custom_cursor(
  self : EventLoop,
  source : @core.CustomCursorSource,
) -> @core.CustomCursor raise @core.RequestError {
  match source {
    @core.CustomCursorSource::Rgba(rgba, width, height, hotspot_x, hotspot_y) =>
      self.create_custom_cursor_from_rgba_source(
        rgba, width, height, hotspot_x, hotspot_y,
      )
    @core.CustomCursorSource::Url(_, _, _) =>
      raise @core.RequestError::NotSupported
    @core.CustomCursorSource::Animation(_, _) =>
      raise @core.RequestError::NotSupported
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
fn validate_rgba_cursor_source(
  rgba : Bytes,
  width : Int,
  height : Int,
  hotspot_x : Int,
  hotspot_y : Int,
) -> Unit raise @core.RequestError {
  if width <= 0 || height <= 0 {
    raise @core.RequestError::Ignored
  }
  // Keep runtime-side checks even though `from_rgba` already validates.
  if width > 2048 || height > 2048 {
    raise @core.RequestError::NotSupported
  }
  if rgba.length() % 4 != 0 {
    raise @core.RequestError::Ignored
  }
  let pixel_count = rgba.length() / 4
  if pixel_count != width * height {
    raise @core.RequestError::Ignored
  }
  if hotspot_x < 0 || hotspot_x >= width || hotspot_y < 0 || hotspot_y >= height {
    raise @core.RequestError::Ignored
  }
}

///|
fn custom_cursor_from_native(
  raw : UInt64,
) -> @core.CustomCursor raise @core.RequestError {
  if raw == (0 : Int).to_uint64() {
    raise @core.RequestError::NotSupported
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
    @core.CursorIcon::Default => default_cursor()
    @core.CursorIcon::ContextMenu => 1
    @core.CursorIcon::Help => _helpCursor()
    @core.CursorIcon::Progress => busyButClickableCursor()
    @core.CursorIcon::Wait => _waitCursor()
    @core.CursorIcon::Cell => webkit_cell()
    @core.CursorIcon::VerticalText => 6
    @core.CursorIcon::Alias => 7
    @core.CursorIcon::Copy => 8
    @core.CursorIcon::NoDrop => 9
    @core.CursorIcon::Grab => 10
    @core.CursorIcon::Grabbing => 11
    @core.CursorIcon::EResize => 12
    @core.CursorIcon::NResize => 13
    @core.CursorIcon::NeResize => _windowResizeNorthEastCursor()
    @core.CursorIcon::NwResize => _windowResizeNorthWestCursor()
    @core.CursorIcon::SResize => 16
    @core.CursorIcon::SeResize => _windowResizeSouthEastCursor()
    @core.CursorIcon::SwResize => _windowResizeSouthWestCursor()
    @core.CursorIcon::WResize => 19
    @core.CursorIcon::EwResize => 20
    @core.CursorIcon::NsResize => 21
    @core.CursorIcon::NeswResize => _windowResizeNorthEastSouthWestCursor()
    @core.CursorIcon::NwseResize => _windowResizeNorthWestSouthEastCursor()
    @core.CursorIcon::ColResize => 24
    @core.CursorIcon::RowResize => 25
    @core.CursorIcon::AllScroll => _moveCursor()
    @core.CursorIcon::ZoomIn => _zoomInCursor()
    @core.CursorIcon::ZoomOut => _zoomOutCursor()
    @core.CursorIcon::Pointer => 29
    @core.CursorIcon::Text => 30
    @core.CursorIcon::Crosshair => 31
    @core.CursorIcon::Move => webkit_move()
    @core.CursorIcon::NotAllowed => 33
  }
}

///|
fn cursor_icon_to_native(cursor : @core.CursorIcon) -> Int {
  cursor_from_icon(cursor)
}

///|
fn cursor_grab_mode_to_native(mode : @core.CursorGrabMode) -> Int {
  match mode {
    @core.CursorGrabMode::None => 0
    @core.CursorGrabMode::Locked => 1
    @core.CursorGrabMode::Confined => 2
  }
}
