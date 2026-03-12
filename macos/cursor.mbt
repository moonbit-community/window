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
    @core.CustomCursorSource::Url(url, hotspot_x, hotspot_y) =>
      self.create_custom_cursor_from_url_source(url, hotspot_x, hotspot_y)
    @core.CustomCursorSource::Animation(_, _) =>
      raise @core.RequestError::NotSupported
  }
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
  validate_rgba_cursor_source(rgba, width, height, hotspot_x, hotspot_y)
  custom_cursor_from_native(
    create_custom_cursor_rgba(rgba, width, height, hotspot_x, hotspot_y),
  )
}

///|
fn EventLoop::create_custom_cursor_from_url_source(
  self : EventLoop,
  url : String,
  hotspot_x : Int,
  hotspot_y : Int,
) -> @core.CustomCursor raise @core.RequestError {
  ignore(self)
  validate_url_cursor_source(url, hotspot_x, hotspot_y)
  custom_cursor_from_native(create_custom_cursor_url(url, hotspot_x, hotspot_y))
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
fn validate_url_cursor_source(
  url : String,
  hotspot_x : Int,
  hotspot_y : Int,
) -> Unit raise @core.RequestError {
  if url.length() == 0 {
    raise @core.RequestError::Ignored
  }
  if hotspot_x < 0 || hotspot_y < 0 {
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
    @core.CustomCursor::from_raw(raw)
  }
}

///|
fn cursor_icon_to_native(cursor : @core.CursorIcon) -> Int {
  match cursor {
    @core.CursorIcon::Default => 0
    @core.CursorIcon::ContextMenu => 1
    @core.CursorIcon::Help => 2
    @core.CursorIcon::Progress => 3
    @core.CursorIcon::Wait => 4
    @core.CursorIcon::Cell => 5
    @core.CursorIcon::VerticalText => 6
    @core.CursorIcon::Alias => 7
    @core.CursorIcon::Copy => 8
    @core.CursorIcon::NoDrop => 9
    @core.CursorIcon::Grab => 10
    @core.CursorIcon::Grabbing => 11
    @core.CursorIcon::EResize => 12
    @core.CursorIcon::NResize => 13
    @core.CursorIcon::NeResize => 14
    @core.CursorIcon::NwResize => 15
    @core.CursorIcon::SResize => 16
    @core.CursorIcon::SeResize => 17
    @core.CursorIcon::SwResize => 18
    @core.CursorIcon::WResize => 19
    @core.CursorIcon::EwResize => 20
    @core.CursorIcon::NsResize => 21
    @core.CursorIcon::NeswResize => 22
    @core.CursorIcon::NwseResize => 23
    @core.CursorIcon::ColResize => 24
    @core.CursorIcon::RowResize => 25
    @core.CursorIcon::AllScroll => 26
    @core.CursorIcon::ZoomIn => 27
    @core.CursorIcon::ZoomOut => 28
    @core.CursorIcon::Pointer => 29
    @core.CursorIcon::Text => 30
    @core.CursorIcon::Crosshair => 31
    @core.CursorIcon::Move => 32
    @core.CursorIcon::NotAllowed => 33
  }
}

///|
fn cursor_grab_mode_to_native(mode : @core.CursorGrabMode) -> Int {
  match mode {
    @core.CursorGrabMode::None => 0
    @core.CursorGrabMode::Locked => 1
    @core.CursorGrabMode::Confined => 2
  }
}
