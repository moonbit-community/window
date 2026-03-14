///|
// Port target: winit-reference/winit-appkit/src/window.rs

///|
pub struct Window {
  priv id : @core.WindowId
  priv raw_window_handle : UInt64
  priv raw_view_handle : UInt64
  priv mut cursor_state : @core.Cursor
  priv mut fullscreen_state : @core.Fullscreen?
  priv mut ime_capabilities_state : @core.ImeCapabilities?
  priv mut ime_surrounding_text_state : @core.ImeSurroundingText?
  priv mut blur_state : Bool
  priv disallow_hidpi_state : Bool
  priv mut borderless_game_state : Bool
  priv mut unified_titlebar_state : Bool
  priv mut simple_fullscreen_state : Bool
  priv mut simple_fullscreen_saved_style_mask_state : UInt64?
  priv mut simple_fullscreen_saved_presentation_options_state : UInt64?
  priv mut simple_fullscreen_saved_outer_position_state : @dpi.PhysicalPosition?
  priv mut simple_fullscreen_saved_outer_size_state : @dpi.PhysicalSize?
  priv mut exclusive_fullscreen_state : Bool
  priv mut exclusive_fullscreen_display_id_state : UInt64?
  priv mut exclusive_fullscreen_saved_mode_state : UInt64?
  priv mut exclusive_fullscreen_saved_style_mask_state : UInt64?
  priv mut exclusive_fullscreen_saved_outer_position_state : @dpi.PhysicalPosition?
  priv mut exclusive_fullscreen_saved_outer_size_state : @dpi.PhysicalSize?
} derive(Eq, Show)

///|
pub type WindowAttributesMacOS = @core.PlatformWindowAttributes

///|
// Port target: window.rs::Window::new
pub fn Window::new(
  event_loop : EventLoop,
  attributes : @core.WindowAttributes,
) -> Window raise @core.RequestError {
  new_window(event_loop, attributes)
}

///|
pub fn Window::id(self : Window) -> @core.WindowId {
  self.id
}

///|
pub fn Window::rwh_06_display_handle(self : Window) -> UInt64 {
  let _ = self
  cg_main_display_id()
}

///|
pub fn Window::rwh_06_window_handle(self : Window) -> UInt64 {
  if self.raw_view_handle != (0 : Int).to_uint64() {
    self.raw_view_handle
  } else {
    self.raw_window_handle
  }
}

///|
// Port target: window.rs::raw_display_handle_rwh_06
fn Window::raw_display_handle_rwh_06(self : Window) -> UInt64 {
  self.rwh_06_display_handle()
}

///|
// Port target: window.rs::raw_window_handle_rwh_06
fn Window::raw_window_handle_rwh_06(self : Window) -> UInt64 {
  self.rwh_06_window_handle()
}

///|
pub fn Window::display_handle(self : Window) -> UInt64 {
  self.raw_display_handle_rwh_06()
}

///|
pub fn Window::window_handle(self : Window) -> UInt64 {
  self.raw_window_handle_rwh_06()
}

///|
// Port target: window.rs::Drop::drop
pub fn Window::drop(self : Window) -> Unit {
  if self.simple_fullscreen_state {
    ignore(self.set_simple_fullscreen(false))
  }
  if self.exclusive_fullscreen_state {
    self.set_fullscreen(None)
  }
  close_window(self.raw_window_handle)
  app_state_unregister_window_handle(self.id.into_raw())
}

///|
pub fn Window::set_cursor(self : Window, cursor : @core.Cursor) -> Unit {
  match cursor {
    @core.Cursor::Icon(icon) => {
      self.cursor_state = cursor
      set_window_cursor(self.raw_window_handle, cursor_icon_to_native(icon))
    }
    @core.Cursor::Custom(custom_cursor) =>
      if set_window_custom_cursor(
          self.raw_window_handle,
          custom_cursor.into_raw(),
        ) {
        self.cursor_state = cursor
      } else {
        self.cursor_state = @core.Cursor::Icon(@core.CursorIcon::Default)
        set_window_cursor(
          self.raw_window_handle,
          cursor_icon_to_native(@core.CursorIcon::Default),
        )
      }
  }
}

///|
pub fn Window::set_cursor_icon(
  self : Window,
  cursor : @core.CursorIcon,
) -> Unit {
  self.set_cursor(@core.Cursor::Icon(cursor))
}

///|
pub fn Window::set_cursor_visible(self : Window, visible : Bool) -> Unit {
  set_window_cursor_visible(self.raw_window_handle, visible)
}

///|
pub fn Window::set_cursor_hittest(
  self : Window,
  hittest : Bool,
) -> Unit raise @core.RequestError {
  if set_window_cursor_hittest(self.raw_window_handle, hittest) == false {
    raise @core.RequestError::NotSupported
  }
}

///|
pub fn Window::set_cursor_position(
  self : Window,
  position : @dpi.Position,
) -> Unit raise @core.RequestError {
  let physical_position = position.to_physical(self.scale_factor())
  if set_cursor_position(
      self.raw_window_handle,
      physical_position.x(),
      physical_position.y(),
    ) ==
    false {
    raise @core.RequestError::NotSupported
  }
}

///|
pub fn Window::set_cursor_grab(
  self : Window,
  mode : @core.CursorGrabMode,
) -> Unit raise @core.RequestError {
  if mode is @core.CursorGrabMode::Confined {
    raise @core.RequestError::NotSupported
  }
  if set_cursor_grab(self.raw_window_handle, cursor_grab_mode_to_native(mode)) ==
    false {
    raise @core.RequestError::NotSupported
  }
}

///|
pub fn Window::drag_window(self : Window) -> Unit raise @core.RequestError {
  let status = drag_window(self.raw_window_handle)
  if status == -1 {
    raise @core.RequestError::Ignored
  }
  if status == 0 {
    raise @core.RequestError::NotSupported
  }
}

///|
pub fn Window::drag_resize_window(
  self : Window,
  direction : @core.ResizeDirection,
) -> Unit raise @core.RequestError {
  if drag_resize_window(
      self.raw_window_handle,
      resize_direction_to_native(direction),
    ) ==
    false {
    raise @core.RequestError::NotSupported
  }
}

///|
pub fn Window::show_window_menu(
  self : Window,
  position : @dpi.Position,
) -> Unit {
  let physical_position = position.to_physical(self.scale_factor())
  let _ = show_window_menu(
    self.raw_window_handle,
    physical_position.x(),
    physical_position.y(),
  )
}

///|
pub fn Window::cursor(self : Window) -> @core.Cursor {
  self.cursor_state
}

///|
pub fn Window::is_cursor_visible(self : Window) -> Bool {
  window_cursor_visible(self.raw_window_handle)
}

///|
pub fn Window::is_cursor_hittest(self : Window) -> Bool {
  window_cursor_hittest(self.raw_window_handle)
}

///|
pub fn Window::set_ime_purpose(
  self : Window,
  purpose : @core.ImePurpose,
) -> Unit {
  match self.ime_capabilities() {
    Some(capabilities) =>
      if capabilities.hint_and_purpose() {
        let _ = self.request_ime_update(
          @core.ImeRequestData::default()
          .with_hint_and_purpose(@core.ImeHint::none(), purpose)
          .into_request(),
        ) catch {
          _ => ()
        }
      }
    None => ()
  }
}

///|
fn Window::set_ime_purpose_raw(
  self : Window,
  purpose : @core.ImePurpose,
) -> Unit {
  set_ime_purpose(
    self.raw_window_handle,
    normalize_ime_purpose_native(ime_purpose_to_native(purpose)),
  )
}

///|
pub fn Window::set_ime_hints(self : Window, hints : @core.ImeHint) -> Unit {
  set_ime_hints(self.raw_window_handle, normalize_ime_hints_bits(hints.bits()))
}

///|
pub fn Window::set_ime_allowed(self : Window, allowed : Bool) -> Unit {
  let request : @core.ImeRequest? = if allowed {
    let capabilities = @core.ImeCapabilities::default().with_cursor_area()
    let request_data = @core.ImeRequestData::default().with_cursor_area(
      @dpi.LogicalPosition::new(0.0, 0.0).into_position(),
      @dpi.LogicalSize::new(0.0, 0.0).into_size(),
    )
    match @core.ImeEnableRequest::new(capabilities, request_data) {
      Some(enable_request) => Some(@core.ImeRequest::Enable(enable_request))
      None => None
    }
  } else {
    Some(@core.ImeRequest::Disable)
  }
  match request {
    Some(request) => {
      let _ = self.request_ime_update(request) catch { _ => () }
      ()
    }
    None => ()
  }
}

///|
fn Window::set_ime_allowed_raw(self : Window, allowed : Bool) -> Unit {
  if allowed == false {
    self.ime_capabilities_state = None
    self.ime_surrounding_text_state = None
  }
  set_ime_allowed(self.raw_window_handle, allowed)
}

///|
pub fn Window::ime_allowed(self : Window) -> Bool {
  window_ime_allowed(self.raw_window_handle)
}

///|
pub fn Window::set_ime_cursor_area(
  self : Window,
  position : @dpi.Position,
  size : @dpi.Size,
) -> Unit {
  match self.ime_capabilities() {
    Some(capabilities) =>
      if capabilities.cursor_area() {
        let _ = self.request_ime_update(
          @core.ImeRequestData::default()
          .with_cursor_area(position, size)
          .into_request(),
        ) catch {
          _ => ()
        }
      }
    None => ()
  }
}

///|
fn Window::set_ime_cursor_area_raw(
  self : Window,
  position : @dpi.Position,
  size : @dpi.Size,
) -> Unit {
  let scale_factor = self.scale_factor()
  let physical_position = position.to_physical(scale_factor)
  let physical_size = size.to_physical(scale_factor)
  let width = if physical_size.width() > 0 { physical_size.width() } else { 1 }
  let height = if physical_size.height() > 0 {
    physical_size.height()
  } else {
    1
  }
  set_ime_cursor_area(
    self.raw_window_handle,
    physical_position.x(),
    physical_position.y(),
    width,
    height,
  )
}

///|
pub fn Window::set_ime_surrounding_text(
  self : Window,
  surrounding_text : @core.ImeSurroundingText?,
) -> Unit {
  match surrounding_text {
    Some(surrounding_text) =>
      self.ime_surrounding_text_state = Some(surrounding_text)
    None => self.ime_surrounding_text_state = None
  }
}

///|
pub fn Window::ime_cursor_area_position(self : Window) -> @dpi.PhysicalPosition {
  @dpi.PhysicalPosition::new(
    window_ime_cursor_x(self.raw_window_handle),
    window_ime_cursor_y(self.raw_window_handle),
  )
}

///|
pub fn Window::ime_cursor_area_size(self : Window) -> @dpi.PhysicalSize {
  @dpi.PhysicalSize::new(
    window_ime_cursor_width(self.raw_window_handle),
    window_ime_cursor_height(self.raw_window_handle),
  )
}

///|
pub fn Window::ime_surrounding_text(self : Window) -> @core.ImeSurroundingText? {
  self.ime_surrounding_text_state
}

///|
pub fn Window::ime_purpose(self : Window) -> @core.ImePurpose {
  ime_purpose_from_native(window_ime_purpose(self.raw_window_handle))
}

///|
pub fn Window::ime_hints(self : Window) -> @core.ImeHint {
  @core.ImeHint::from_bits(
    normalize_ime_hints_bits(window_ime_hints(self.raw_window_handle)),
  )
}

///|
fn Window::apply_ime_request_data(
  self : Window,
  request_data : @core.ImeRequestData,
) -> Unit raise @core.ImeRequestError {
  if self.ime_allowed() == false {
    raise @core.ImeRequestError::NotEnabled
  }
  if request_data.has_hint_and_purpose() {
    if self.ime_supports_hint_and_purpose() {
      match request_data.hint_and_purpose() {
        Some((hints, purpose)) => {
          self.set_ime_hints(hints)
          self.set_ime_purpose_raw(purpose)
        }
        None => ()
      }
    }
  }
  if request_data.has_cursor_area() {
    if self.ime_supports_cursor_area() {
      match request_data.cursor_area() {
        Some((position, size)) => self.set_ime_cursor_area_raw(position, size)
        None => ()
      }
    }
  }
  if request_data.has_surrounding_text() {
    if self.ime_supports_surrounding_text() {
      match request_data.surrounding_text() {
        Some(surrounding_text) =>
          self.set_ime_surrounding_text(Some(surrounding_text))
        None => ()
      }
    }
  }
}

///|
pub fn Window::request_ime_update(
  self : Window,
  request : @core.ImeRequest,
) -> Unit raise @core.ImeRequestError {
  match request {
    @core.ImeRequest::Enable(enable_request) =>
      if self.ime_allowed() {
        raise @core.ImeRequestError::AlreadyEnabled
      } else {
        let requested_capabilities = enable_request.capabilities()
        let capabilities = @core.ImeCapabilities::new(
          false,
          requested_capabilities.cursor_area(),
          false,
        )
        let request_data = enable_request.request_data()
        self.set_ime_allowed_raw(true)
        self.ime_capabilities_state = Some(capabilities)
        self.apply_ime_request_data(request_data)
      }
    @core.ImeRequest::Update(request_data) =>
      self.apply_ime_request_data(request_data)
    @core.ImeRequest::Disable => {
      self.set_ime_allowed_raw(false)
      ()
    }
  }
}

///|
pub fn Window::ime_capabilities(self : Window) -> @core.ImeCapabilities? {
  self.ime_capabilities_state
}

///|
fn Window::ime_supports_hint_and_purpose(self : Window) -> Bool {
  match self.ime_capabilities_state {
    Some(capabilities) => capabilities.hint_and_purpose()
    None => false
  }
}

///|
fn Window::ime_supports_cursor_area(self : Window) -> Bool {
  match self.ime_capabilities_state {
    Some(capabilities) => capabilities.cursor_area()
    None => false
  }
}

///|
fn Window::ime_supports_surrounding_text(self : Window) -> Bool {
  match self.ime_capabilities_state {
    Some(capabilities) => capabilities.surrounding_text()
    None => false
  }
}
