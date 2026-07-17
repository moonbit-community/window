///|
// Port target: winit-reference/winit-appkit/src/window.rs

///|
pub struct Window {
  priv id : @core.WindowId
  priv raw_window_handle : NativeWindow
  priv mut cursor_state : @core.Cursor
  priv mut fullscreen_state : @core.Fullscreen?
  priv mut ime_capabilities_state : @core.ImeCapabilities?
  priv mut ime_surrounding_text_state : @core.ImeSurroundingText?
  priv mut prefers_home_indicator_hidden_state : Bool
  priv mut prefers_status_bar_hidden_state : Bool
  priv mut preferred_screen_edges_deferring_system_gestures_state : @core.ScreenEdge
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
  priv mut exclusive_fullscreen_saved_mode_state : NativeDisplayMode?
  priv mut exclusive_fullscreen_saved_style_mask_state : UInt64?
  priv mut exclusive_fullscreen_saved_outer_position_state : @dpi.PhysicalPosition?
  priv mut exclusive_fullscreen_saved_outer_size_state : @dpi.PhysicalSize?
} derive(Eq, Debug)

///|
pub type WindowAttributesMacOS = @core.PlatformWindowAttributes

///|
// Port target: window.rs::Window::Window
pub fn Window::Window(
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
fn Window::raw_display_handle(self : Window) -> @windowing.RawDisplayHandle {
  let _ = self
  AppKit(@windowing.AppKitDisplayHandle::new())
}

///|
fn Window::raw_window_handle(
  self : Window,
) -> @windowing.RawWindowHandle raise @windowing.HandleError {
  let raw_view = self.maybe_wait_on_main(fn(window) {
    native_window_content_view_objc_handle(window.raw_window_handle)
  })
  AppKit(@windowing.AppKitWindowHandle::new(raw_view))
}

///|
pub impl @windowing.DisplayHandleProvider for Window with fn raw_display_handle(
  self,
) {
  self.raw_display_handle()
}

///|
pub impl @windowing.WindowHandleProvider for Window with fn raw_window_handle(
  self,
) {
  self.raw_window_handle()
}

///|
pub fn Window::display_handle(self : Window) -> @windowing.DisplayHandle {
  @windowing.DisplayHandle::from_provider(
    self as &@windowing.DisplayHandleProvider,
  )
}

///|
pub impl @windowing.HasDisplayHandle for Window with fn display_handle(self) {
  self.display_handle()
}

///|
pub fn Window::window_handle(self : Window) -> @windowing.WindowHandle {
  @windowing.WindowHandle::from_provider(
    self as &@windowing.WindowHandleProvider,
  )
}

///|
pub impl @windowing.HasWindowHandle for Window with fn window_handle(self) {
  self.window_handle()
}

///|
fn content_view_handle_from_raw(
  raw_view_handle : UInt64,
) -> UInt64 raise @core.RequestError {
  guard raw_view_handle != (0 : Int).to_uint64() else {
    raise @core.RequestError::os(
      "Window content view handle is unavailable",
      domain=appkit_window_error_domain,
    )
  }
  raw_view_handle
}

///|
/// Return the borrowed AppKit content view handle for this window.
///
/// The handle is not retained for the caller. Use it only while the `Window` is
/// alive, and do not release it.
pub fn Window::content_view_handle(
  self : Window,
) -> UInt64 raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(window) -> UInt64 raise @core.RequestError {
    content_view_handle_from_raw(
      native_window_content_view_objc_handle(window.raw_window_handle),
    )
  })
}

///|
// Port target: window.rs::Drop::drop
pub fn Window::drop(self : Window) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    if window.simple_fullscreen_state {
      ignore(window.set_simple_fullscreen(false))
    }
    if window.exclusive_fullscreen_state {
      window.set_fullscreen(None)
    }
    close_window(window.raw_window_handle)
    app_state_unregister_window_handle(window.id.into_raw())
  })
}

///|
pub fn Window::set_cursor(self : Window, cursor : @core.Cursor) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    let cursor_visible = window.is_cursor_visible()
    match cursor {
      Icon(icon) => {
        window.cursor_state = cursor
        if cursor_visible {
          set_window_cursor(window.raw_window_handle, icon)
        }
      }
      Custom(custom_cursor) =>
        if cursor_visible {
          if native_window_set_custom_cursor(
              window.raw_window_handle,
              custom_cursor.into_raw(),
            ) {
            window.cursor_state = cursor
          } else {
            window.cursor_state = Icon(Default)
            set_window_cursor(window.raw_window_handle, Default)
          }
        } else {
          window.cursor_state = cursor
        }
    }
  })
}

///|
pub fn Window::set_cursor_icon(
  self : Window,
  cursor : @core.CursorIcon,
) -> Unit {
  self.maybe_wait_on_main(fn(window) { window.set_cursor(Icon(cursor)) })
}

///|
pub fn Window::set_cursor_visible(self : Window, visible : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_window_cursor_visible(window.raw_window_handle, visible)
    if visible {
      window.set_cursor(window.cursor_state)
    }
  })
}

///|
pub fn Window::set_cursor_hittest(
  self : Window,
  hittest : Bool,
) -> Unit raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(window) -> Unit raise @core.RequestError {
    window_set_cursor_hittest(window, hittest)
  })
}

///|
fn window_set_cursor_hittest(
  window : Window,
  hittest : Bool,
) -> Unit raise @core.RequestError {
  raise_request_error_from_native_status(
    set_window_cursor_hittest(window.raw_window_handle, hittest),
    "Failed to set cursor hittest",
  )
}

///|
pub impl @core.WindowCursorHittest for Window with fn set_cursor_hittest(
  self,
  hittest,
) {
  self.set_cursor_hittest(hittest)
}

///|
fn cursor_position_to_logical(
  position : @dpi.Position,
  scale_factor : Double,
) -> @dpi.LogicalPosition {
  position.to_logical(scale_factor)
}

///|
pub fn Window::set_cursor_position(
  self : Window,
  position : @dpi.Position,
) -> Unit raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(window) -> Unit raise @core.RequestError {
    let logical_position = cursor_position_to_logical(
      position,
      window.scale_factor(),
    )
    raise_request_error_from_native_status(
      native_window_set_cursor_position(
        window.raw_window_handle,
        logical_position.x().to_int(),
        logical_position.y().to_int(),
      ),
      "Failed to set cursor position",
    )
  })
}

///|
pub fn Window::set_cursor_grab(
  self : Window,
  mode : @core.CursorGrabMode,
) -> Unit raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(window) -> Unit raise @core.RequestError {
    if mode is Confined {
      raise_request_not_supported(
        "Confined cursor grab is not supported on macOS",
      )
    }
    raise_request_error_from_native_status(
      native_window_set_cursor_grab(
        window.raw_window_handle,
        cursor_grab_mode_to_native(mode),
      ),
      "Failed to set cursor grab mode",
    )
  })
}

///|
pub fn Window::drag_window(self : Window) -> Unit raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(window) -> Unit raise @core.RequestError {
    raise_request_error_from_drag_window_status(
      native_window_drag_window(window.raw_window_handle),
    )
  })
}

///|
pub fn Window::drag_resize_window(
  self : Window,
  direction : @core.ResizeDirection,
) -> Unit raise @core.RequestError {
  self.maybe_wait_on_main_result(fn(window) -> Unit raise @core.RequestError {
    raise_request_error_from_drag_resize_result(
      native_window_drag_resize_window(
        window.raw_window_handle,
        resize_direction_to_native(direction),
      ),
    )
  })
}

///|
pub fn Window::show_window_menu(
  self : Window,
  position : @dpi.Position,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    let physical_position = position.to_physical(window.scale_factor())
    let _ = native_window_show_window_menu(
      window.raw_window_handle,
      physical_position.x(),
      physical_position.y(),
    )
  })
}

///|
pub fn Window::cursor(self : Window) -> @core.Cursor {
  self.maybe_wait_on_main(fn(window) { window.cursor_state })
}

///|
pub fn Window::is_cursor_visible(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    window_cursor_visible(window.raw_window_handle)
  })
}

///|
pub fn Window::is_cursor_hittest(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    window_cursor_hittest(window.raw_window_handle)
  })
}

///|
pub fn Window::set_ime_purpose(
  self : Window,
  purpose : @core.ImePurpose,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    match window.ime_capabilities() {
      Some(capabilities) =>
        if capabilities.hint_and_purpose() {
          let _ = window.request_ime_update(
            @core.ImeRequestData::default()
            .with_hint_and_purpose(@core.ImeHint::none(), purpose)
            .into_request(),
          ) catch {
            _ => ()
          }
        }
      None => ()
    }
  })
}

///|
pub fn Window::set_ime_hints(self : Window, hints : @core.ImeHint) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    set_ime_hints(
      window.raw_window_handle,
      normalize_ime_hints_bits(hints.bits()),
    )
  })
}

///|
pub fn Window::set_ime_allowed(self : Window, allowed : Bool) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    let request : @core.ImeRequest? = if allowed {
      let capabilities = @core.ImeCapabilities::default()
        .with_hint_and_purpose()
        .with_cursor_area()
      let request_data = @core.ImeRequestData::default()
        .with_hint_and_purpose(@core.ImeHint::none(), Normal)
        .with_cursor_area(
          @dpi.LogicalPosition::LogicalPosition(0.0, 0.0).into_position(),
          @dpi.LogicalSize::LogicalSize(0.0, 0.0).into_size(),
        )
      match
        @core.ImeEnableRequest::from_capabilities(capabilities, request_data) {
        Some(enable_request) => Some(Enable(enable_request))
        None => None
      }
    } else {
      Some(Disable)
    }
    match request {
      Some(request) => {
        let _ = window.request_ime_update(request) catch { _ => () }
        ()
      }
      None => ()
    }
  })
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
  self.maybe_wait_on_main(fn(window) {
    window_ime_allowed(window.raw_window_handle)
  })
}

///|
pub fn Window::set_ime_cursor_area(
  self : Window,
  position : @dpi.Position,
  size : @dpi.Size,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    match window.ime_capabilities() {
      Some(capabilities) =>
        if capabilities.cursor_area() {
          let _ = window.request_ime_update(
            @core.ImeRequestData::default()
            .with_cursor_area(position, size)
            .into_request(),
          ) catch {
            _ => ()
          }
        }
      None => ()
    }
  })
}

///|
fn Window::set_ime_cursor_area_raw(
  self : Window,
  position : @dpi.Position,
  size : @dpi.Size,
) -> Unit {
  let scale_factor = self.scale_factor()
  let logical_position = position.to_logical(scale_factor)
  let logical_size = size.to_logical(scale_factor)
  let width = if logical_size.width().to_int() > 0 {
    logical_size.width().to_int()
  } else {
    1
  }
  let height = if logical_size.height().to_int() > 0 {
    logical_size.height().to_int()
  } else {
    1
  }
  set_ime_cursor_area(
    self.raw_window_handle,
    logical_position.x().to_int(),
    logical_position.y().to_int(),
    width,
    height,
  )
}

///|
pub fn Window::set_ime_surrounding_text(
  self : Window,
  surrounding_text : @core.ImeSurroundingText?,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    match surrounding_text {
      Some(surrounding_text) =>
        window.ime_surrounding_text_state = Some(surrounding_text)
      None => window.ime_surrounding_text_state = None
    }
  })
}

///|
pub fn Window::ime_cursor_area_position(self : Window) -> @dpi.PhysicalPosition {
  self.maybe_wait_on_main(fn(window) {
    @dpi.LogicalPosition::LogicalPosition(
      window_ime_cursor_x(window.raw_window_handle).to_double(),
      window_ime_cursor_y(window.raw_window_handle).to_double(),
    ).to_physical(window.scale_factor())
  })
}

///|
pub fn Window::ime_cursor_area_size(self : Window) -> @dpi.PhysicalSize {
  self.maybe_wait_on_main(fn(window) {
    @dpi.LogicalSize::LogicalSize(
      window_ime_cursor_width(window.raw_window_handle).to_double(),
      window_ime_cursor_height(window.raw_window_handle).to_double(),
    ).to_physical(window.scale_factor())
  })
}

///|
pub fn Window::ime_surrounding_text(self : Window) -> @core.ImeSurroundingText? {
  self.maybe_wait_on_main(fn(window) { window.ime_surrounding_text_state })
}

///|
pub fn Window::ime_purpose(self : Window) -> @core.ImePurpose {
  self.maybe_wait_on_main(fn(window) {
    ime_purpose_from_native(window_ime_purpose(window.raw_window_handle))
  })
}

///|
pub fn Window::ime_hints(self : Window) -> @core.ImeHint {
  self.maybe_wait_on_main(fn(window) {
    @core.ImeHint::from_bits(
      normalize_ime_hints_bits(window_ime_hints(window.raw_window_handle)),
    )
  })
}

///|
fn Window::apply_ime_request_data(
  self : Window,
  request_data : @core.ImeRequestData,
) -> Unit raise @core.ImeRequestError {
  if self.ime_capabilities_state is None {
    raise NotEnabled
  }
  if request_data.has_cursor_area() {
    if self.ime_supports_cursor_area() {
      match request_data.cursor_area() {
        Some((position, size)) => self.set_ime_cursor_area_raw(position, size)
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
  self.maybe_wait_on_main_result(fn(
    window,
  ) -> Unit raise @core.ImeRequestError {
    let current_caps = window.ime_capabilities_state
    let request_data = match request {
      Enable(enable_request) =>
        match current_caps {
          Some(_) => raise AlreadyEnabled
          None => {
            window.set_ime_allowed_raw(true)
            window.ime_capabilities_state = Some(enable_request.capabilities())
            enable_request.request_data()
          }
        }
      Update(request_data) =>
        match current_caps {
          Some(_) => request_data
          None => raise NotEnabled
        }
      Disable => {
        window.set_ime_allowed_raw(false)
        return ()
      }
    }
    window.apply_ime_request_data(request_data)
  })
}

///|
pub fn Window::ime_capabilities(self : Window) -> @core.ImeCapabilities? {
  self.maybe_wait_on_main(fn(window) { window.ime_capabilities_state })
}

///|
fn Window::ime_supports_cursor_area(self : Window) -> Bool {
  match self.ime_capabilities_state {
    Some(capabilities) => capabilities.cursor_area()
    None => false
  }
}
