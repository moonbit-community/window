///|
pub struct Window {
  priv id : @core.WindowId
  priv mut cursor_state : @core.Cursor
  priv mut fullscreen_state : @core.Fullscreen?
  priv mut ime_capabilities_state : @core.ImeCapabilities?
} derive(Eq, Show)

///|
pub struct EventLoopProxy {
  priv _unit : Unit
} derive(Eq, Show)

///|
pub fn EventLoopProxy::wake_up(_self : EventLoopProxy) -> Unit {
  native_event_loop_wake_up()
}

///|
pub fn Window::id(self : Window) -> @core.WindowId {
  self.id
}

///|
pub fn EventLoop::available_monitors(
  _self : EventLoop,
) -> Array[@core.MonitorHandle] {
  monitors_from_native()
}

///|
pub fn EventLoop::primary_monitor(_self : EventLoop) -> @core.MonitorHandle? {
  monitor_from_native_id(primary_monitor_id())
}

///|
pub fn EventLoop::rwh_06_handle(_self : EventLoop) -> UInt64 {
  display_handle()
}

///|
pub fn EventLoop::owned_display_handle(self : EventLoop) -> UInt64 {
  self.rwh_06_handle()
}

///|
pub fn EventLoop::display_handle(self : EventLoop) -> UInt64 {
  self.owned_display_handle()
}

///|
pub fn EventLoop::system_theme(_self : EventLoop) -> @core.Theme? {
  theme_from_native(system_theme())
}

///|
pub fn EventLoop::hide_application(_self : EventLoop) -> Unit {
  hide_application()
}

///|
pub fn EventLoop::hide_other_applications(_self : EventLoop) -> Unit {
  hide_other_applications()
}

///|
pub fn EventLoop::set_allows_automatic_window_tabbing(
  _self : EventLoop,
  enabled : Bool,
) -> Unit {
  set_allows_automatic_window_tabbing(enabled)
}

///|
pub fn EventLoop::allows_automatic_window_tabbing(_self : EventLoop) -> Bool {
  allows_automatic_window_tabbing()
}

///|
pub fn EventLoop::listen_device_events(
  _self : EventLoop,
  _allowed : @core.DeviceEvents,
) -> Unit {
  ()
}

///|
pub fn Window::available_monitors(self : Window) -> Array[@core.MonitorHandle] {
  let _ = self
  monitors_from_native()
}

///|
pub fn Window::primary_monitor(self : Window) -> @core.MonitorHandle? {
  let _ = self
  monitor_from_native_id(primary_monitor_id())
}

///|
pub fn Window::current_monitor(self : Window) -> @core.MonitorHandle? {
  monitor_from_native_id(window_current_monitor_id(self.id.into_raw()))
}

///|
pub fn Window::rwh_06_display_handle(self : Window) -> UInt64 {
  window_display_handle(self.id.into_raw())
}

///|
pub fn Window::rwh_06_window_handle(self : Window) -> UInt64 {
  window_handle(self.id.into_raw())
}

///|
pub fn Window::display_handle(self : Window) -> UInt64 {
  self.rwh_06_display_handle()
}

///|
pub fn Window::window_handle(self : Window) -> UInt64 {
  self.rwh_06_window_handle()
}

///|
pub fn Window::surface_size(self : Window) -> @dpi.PhysicalSize {
  @dpi.PhysicalSize::new(
    native_window_width(self.id.into_raw()),
    native_window_height(self.id.into_raw()),
  )
}

///|
pub fn Window::outer_size(self : Window) -> @dpi.PhysicalSize {
  @dpi.PhysicalSize::new(
    window_outer_width(self.id.into_raw()),
    window_outer_height(self.id.into_raw()),
  )
}

///|
pub fn Window::surface_position(self : Window) -> @dpi.PhysicalPosition {
  @dpi.PhysicalPosition::new(
    window_surface_x(self.id.into_raw()),
    window_surface_y(self.id.into_raw()),
  )
}

///|
pub fn Window::safe_area(self : Window) -> @dpi.PhysicalInsets {
  @dpi.PhysicalInsets::new(
    window_safe_area_top(self.id.into_raw()),
    window_safe_area_left(self.id.into_raw()),
    window_safe_area_bottom(self.id.into_raw()),
    window_safe_area_right(self.id.into_raw()),
  )
}

///|
pub fn Window::request_surface_size(
  self : Window,
  size : @dpi.Size,
) -> @dpi.PhysicalSize? {
  let physical_size = size.to_physical(self.scale_factor())
  set_surface_size(
    self.id.into_raw(),
    physical_size.width(),
    physical_size.height(),
  )
  None
}

///|
pub fn Window::set_surface_resize_increments(
  self : Window,
  size : @dpi.Size?,
) -> Unit {
  match size {
    Some(size) => {
      let physical_size = size.to_physical(self.scale_factor())
      set_surface_resize_increments(
        self.id.into_raw(),
        physical_size.width(),
        physical_size.height(),
      )
    }
    None => set_surface_resize_increments(self.id.into_raw(), 0, 0)
  }
}

///|
pub fn Window::surface_resize_increments(self : Window) -> @dpi.PhysicalSize? {
  let width = window_resize_increment_width(self.id.into_raw())
  let height = window_resize_increment_height(self.id.into_raw())
  if width > 0 && height > 0 {
    Some(@dpi.PhysicalSize::new(width, height))
  } else {
    None
  }
}

///|
pub fn Window::set_min_surface_size(self : Window, size : @dpi.Size?) -> Unit {
  match size {
    Some(size) => {
      let physical_size = size.to_physical(self.scale_factor())
      set_min_surface_size(
        self.id.into_raw(),
        physical_size.width(),
        physical_size.height(),
      )
    }
    None => set_min_surface_size(self.id.into_raw(), 0, 0)
  }
}

///|
pub fn Window::set_max_surface_size(self : Window, size : @dpi.Size?) -> Unit {
  match size {
    Some(size) => {
      let physical_size = size.to_physical(self.scale_factor())
      set_max_surface_size(
        self.id.into_raw(),
        physical_size.width(),
        physical_size.height(),
      )
    }
    None => set_max_surface_size(self.id.into_raw(), 0, 0)
  }
}

///|
pub fn Window::min_surface_size(self : Window) -> @dpi.PhysicalSize? {
  let width = window_min_surface_width(self.id.into_raw())
  let height = window_min_surface_height(self.id.into_raw())
  if width > 0 && height > 0 {
    Some(@dpi.PhysicalSize::new(width, height))
  } else {
    None
  }
}

///|
pub fn Window::max_surface_size(self : Window) -> @dpi.PhysicalSize? {
  let width = window_max_surface_width(self.id.into_raw())
  let height = window_max_surface_height(self.id.into_raw())
  if width > 0 && height > 0 {
    Some(@dpi.PhysicalSize::new(width, height))
  } else {
    None
  }
}

///|
pub fn Window::outer_position(self : Window) -> @dpi.PhysicalPosition {
  @dpi.PhysicalPosition::new(
    window_x(self.id.into_raw()),
    window_y(self.id.into_raw()),
  )
}

///|
pub fn Window::set_outer_position(
  self : Window,
  position : @dpi.Position,
) -> Unit {
  let physical_position = position.to_physical(self.scale_factor())
  set_window_position(
    self.id.into_raw(),
    physical_position.x(),
    physical_position.y(),
  )
}

///|
pub fn Window::focus_window(self : Window) -> Unit {
  let raw_id = self.id.into_raw()
  let is_minimized = window_minimized(raw_id)
  let is_visible = window_visible(raw_id)
  if is_minimized == false && is_visible {
    focus_window(raw_id)
  }
}

///|
pub fn Window::has_focus(self : Window) -> Bool {
  window_has_focus(self.id.into_raw())
}

///|
pub fn Window::set_minimized(self : Window, minimized : Bool) -> Unit {
  set_window_minimized(self.id.into_raw(), minimized)
}

///|
pub fn Window::is_minimized(self : Window) -> Bool? {
  Some(window_minimized(self.id.into_raw()))
}

///|
pub fn Window::set_maximized(self : Window, maximized : Bool) -> Unit {
  set_window_maximized(self.id.into_raw(), maximized)
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
    let raw_id = self.id.into_raw()
    match fullscreen {
      None => set_window_fullscreen(raw_id, false)
      Some(@core.Fullscreen::Borderless(target_monitor)) => {
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
        let position = target_monitor.position()
        let mode_size = video_mode.surface_size()
        set_window_position(raw_id, position.x(), position.y())
        set_surface_size(raw_id, mode_size.width(), mode_size.height())
        set_window_fullscreen(raw_id, true)
      }
    }
  }
}

///|
pub fn Window::is_maximized(self : Window) -> Bool {
  window_maximized(self.id.into_raw())
}

///|
pub fn Window::fullscreen(self : Window) -> @core.Fullscreen? {
  if window_fullscreen(self.id.into_raw()) {
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
  window_fullscreen(self.id.into_raw())
}

///|
pub fn Window::simple_fullscreen(self : Window) -> Bool {
  window_simple_fullscreen(self.id.into_raw())
}

///|
pub fn Window::set_simple_fullscreen(self : Window, fullscreen : Bool) -> Bool {
  set_window_simple_fullscreen(self.id.into_raw(), fullscreen)
}

///|
pub fn Window::set_borderless_game(
  self : Window,
  borderless_game : Bool,
) -> Unit {
  set_window_borderless_game(self.id.into_raw(), borderless_game)
}

///|
pub fn Window::is_borderless_game(self : Window) -> Bool {
  window_is_borderless_game(self.id.into_raw())
}

///|
pub fn Window::set_tabbing_identifier(
  self : Window,
  identifier : String,
) -> Unit {
  set_window_tabbing_identifier(self.id.into_raw(), identifier)
}

///|
pub fn Window::tabbing_identifier(self : Window) -> String {
  text_from_native(window_tabbing_identifier(self.id.into_raw()))
}

///|
pub fn Window::select_next_tab(self : Window) -> Unit {
  select_window_next_tab(self.id.into_raw())
}

///|
pub fn Window::select_previous_tab(self : Window) -> Unit {
  select_window_previous_tab(self.id.into_raw())
}

///|
pub fn Window::select_tab_at_index(self : Window, index : Int) -> Unit {
  if index >= 0 {
    select_window_tab_at_index(self.id.into_raw(), index)
  }
}

///|
pub fn Window::num_tabs(self : Window) -> Int {
  window_num_tabs(self.id.into_raw())
}

///|
pub fn Window::set_decorations(self : Window, decorations : Bool) -> Unit {
  set_window_decorations(self.id.into_raw(), decorations)
}

///|
pub fn Window::set_enabled_buttons(
  self : Window,
  buttons : @core.WindowButtons,
) -> Unit {
  set_window_enabled_buttons(
    self.id.into_raw(),
    buttons.close(),
    buttons.minimize(),
    buttons.maximize(),
  )
}

///|
pub fn Window::set_blur(self : Window, blur : Bool) -> Unit {
  set_window_blur(self.id.into_raw(), blur)
}

///|
pub fn Window::has_shadow(self : Window) -> Bool {
  window_has_shadow(self.id.into_raw())
}

///|
pub fn Window::set_has_shadow(self : Window, has_shadow : Bool) -> Unit {
  set_window_has_shadow(self.id.into_raw(), has_shadow)
}

///|
pub fn Window::set_cursor(self : Window, cursor : @core.Cursor) -> Unit {
  let raw_id = self.id.into_raw()
  match cursor {
    @core.Cursor::Icon(icon) => {
      set_window_cursor(raw_id, cursor_icon_to_native(icon))
      self.cursor_state = cursor
    }
    @core.Cursor::Custom(custom_cursor) =>
      if set_window_custom_cursor(raw_id, custom_cursor.into_raw()) {
        self.cursor_state = cursor
      } else {
        set_window_cursor(
          raw_id,
          cursor_icon_to_native(@core.CursorIcon::Default),
        )
        self.cursor_state = @core.Cursor::Icon(@core.CursorIcon::Default)
      }
  }
}

///|
pub fn Window::set_cursor_visible(self : Window, visible : Bool) -> Unit {
  set_window_cursor_visible(self.id.into_raw(), visible)
}

///|
pub fn Window::set_cursor_hittest(self : Window, hittest : Bool) -> Unit {
  set_window_cursor_hittest(self.id.into_raw(), hittest)
}

///|
pub fn Window::set_cursor_position(
  self : Window,
  position : @dpi.Position,
) -> Unit raise @core.RequestError {
  let physical_position = position.to_physical(self.scale_factor())
  if set_cursor_position(
      self.id.into_raw(),
      physical_position.x(),
      physical_position.y(),
    ) {
    ()
  } else {
    raise @core.RequestError::Ignored("set_cursor_position was ignored")
  }
}

///|
pub fn Window::set_cursor_grab(
  self : Window,
  mode : @core.CursorGrabMode,
) -> Unit raise @core.RequestError {
  if mode is @core.CursorGrabMode::Confined {
    raise @core.RequestError::NotSupported(
      "confined cursor grab is not supported on macOS",
    )
  }
  if set_cursor_grab(self.id.into_raw(), cursor_grab_mode_to_native(mode)) {
    ()
  } else {
    raise @core.RequestError::Ignored("set_cursor_grab was ignored")
  }
}

///|
pub fn Window::drag_window(self : Window) -> Unit raise @core.RequestError {
  if drag_window(self.id.into_raw()) {
    ()
  } else {
    raise @core.RequestError::Ignored("drag_window was ignored")
  }
}

///|
pub fn Window::drag_resize_window(
  self : Window,
  direction : @core.ResizeDirection,
) -> Unit raise @core.RequestError {
  if drag_resize_window(
      self.id.into_raw(),
      resize_direction_to_native(direction),
    ) {
    ()
  } else {
    raise @core.RequestError::NotSupported(
      "drag_resize_window is not supported on macOS",
    )
  }
}

///|
pub fn Window::show_window_menu(
  self : Window,
  position : @dpi.Position,
) -> Unit {
  let physical_position = position.to_physical(self.scale_factor())
  let _ = show_window_menu(
    self.id.into_raw(),
    physical_position.x(),
    physical_position.y(),
  )
}

///|
pub fn Window::is_decorated(self : Window) -> Bool {
  window_decorated(self.id.into_raw())
}

///|
pub fn Window::enabled_buttons(self : Window) -> @core.WindowButtons {
  @core.WindowButtons::all()
  .with_close(window_close_button_enabled(self.id.into_raw()))
  .with_minimize(window_minimize_button_enabled(self.id.into_raw()))
  .with_maximize(window_maximize_button_enabled(self.id.into_raw()))
}

///|
pub fn Window::is_blurred(self : Window) -> Bool {
  window_blur(self.id.into_raw())
}

///|
pub fn Window::cursor(self : Window) -> @core.Cursor {
  self.cursor_state
}

///|
pub fn Window::is_cursor_visible(self : Window) -> Bool {
  window_cursor_visible(self.id.into_raw())
}

///|
pub fn Window::is_cursor_hittest(self : Window) -> Bool {
  window_cursor_hittest(self.id.into_raw())
}

///|
pub fn Window::set_transparent(self : Window, transparent : Bool) -> Unit {
  set_window_transparent(self.id.into_raw(), transparent)
}

///|
pub fn Window::is_transparent(self : Window) -> Bool {
  window_transparent(self.id.into_raw())
}

///|
pub fn Window::set_window_level(
  self : Window,
  level : @core.WindowLevel,
) -> Unit {
  set_window_level(self.id.into_raw(), window_level_to_native(level))
}

///|
pub fn Window::window_level(self : Window) -> @core.WindowLevel {
  window_level_from_native(window_level(self.id.into_raw()))
}

///|
pub fn Window::set_ime_purpose(
  self : Window,
  purpose : @core.ImePurpose,
) -> Unit {
  set_ime_purpose(self.id.into_raw(), ime_purpose_to_native(purpose))
}

///|
pub fn Window::set_ime_hints(self : Window, hints : @core.ImeHint) -> Unit {
  set_ime_hints(self.id.into_raw(), hints.bits())
}

///|
pub fn Window::set_ime_allowed(self : Window, allowed : Bool) -> Unit {
  self.ime_capabilities_state = if allowed {
    Some(default_ime_capabilities())
  } else {
    None
  }
  set_ime_allowed(self.id.into_raw(), allowed)
}

///|
pub fn Window::ime_allowed(self : Window) -> Bool {
  window_ime_allowed(self.id.into_raw())
}

///|
pub fn Window::set_ime_cursor_area(
  self : Window,
  position : @dpi.PhysicalPosition,
  size : @dpi.PhysicalSize,
) -> Unit {
  set_ime_cursor_area(
    self.id.into_raw(),
    position.x(),
    position.y(),
    size.width(),
    size.height(),
  )
}

///|
pub fn Window::set_ime_surrounding_text(
  self : Window,
  surrounding_text : @core.ImeSurroundingText?,
) -> Unit {
  match surrounding_text {
    Some(surrounding_text) =>
      set_ime_surrounding_text(
        self.id.into_raw(),
        surrounding_text.text(),
        surrounding_text.cursor(),
        surrounding_text.anchor(),
      )
    None => clear_ime_surrounding_text(self.id.into_raw())
  }
}

///|
pub fn Window::ime_cursor_area_position(self : Window) -> @dpi.PhysicalPosition {
  @dpi.PhysicalPosition::new(
    window_ime_cursor_area_x(self.id.into_raw()),
    window_ime_cursor_area_y(self.id.into_raw()),
  )
}

///|
pub fn Window::ime_cursor_area_size(self : Window) -> @dpi.PhysicalSize {
  @dpi.PhysicalSize::new(
    window_ime_cursor_area_width(self.id.into_raw()),
    window_ime_cursor_area_height(self.id.into_raw()),
  )
}

///|
pub fn Window::ime_surrounding_text(self : Window) -> @core.ImeSurroundingText? {
  let raw_id = self.id.into_raw()
  if window_has_ime_surrounding_text(raw_id) == false {
    return None
  }
  let text = text_from_native(window_ime_surrounding_text(raw_id))
  let cursor = window_ime_surrounding_cursor(raw_id)
  let anchor = window_ime_surrounding_anchor(raw_id)
  let surrounding_text = @core.ImeSurroundingText::new(text, cursor, anchor) catch {
    _ => return None
  }
  Some(surrounding_text)
}

///|
pub fn Window::ime_purpose(self : Window) -> @core.ImePurpose {
  ime_purpose_from_native(window_ime_purpose(self.id.into_raw()))
}

///|
pub fn Window::ime_hints(self : Window) -> @core.ImeHint {
  @core.ImeHint::from_bits(window_ime_hints(self.id.into_raw()))
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
    if self.ime_supports_hint_and_purpose() == false {
      raise @core.ImeRequestError::NotSupported
    }
    match request_data.hint_and_purpose() {
      Some((hints, purpose)) => {
        self.set_ime_hints(hints)
        self.set_ime_purpose(purpose)
      }
      None => ()
    }
  }
  if request_data.has_cursor_area() {
    if self.ime_supports_cursor_area() == false {
      raise @core.ImeRequestError::NotSupported
    }
    match request_data.cursor_area() {
      Some((position, size)) => {
        let scale_factor = self.scale_factor()
        let physical_position = position.to_physical(scale_factor)
        let physical_size = size.to_physical(scale_factor)
        self.set_ime_cursor_area(physical_position, physical_size)
      }
      None => ()
    }
  }
  if request_data.has_surrounding_text() {
    if self.ime_supports_surrounding_text() == false {
      raise @core.ImeRequestError::NotSupported
    }
    match request_data.surrounding_text() {
      Some(surrounding_text) =>
        self.set_ime_surrounding_text(Some(surrounding_text))
      None => ()
    }
  }
}

///|
pub fn Window::request_ime_update(
  self : Window,
  request : @core.ImeRequest,
) -> Unit raise @core.ImeRequestError {
  match request {
    @core.ImeRequest::Enable(capabilities) =>
      if self.ime_allowed() {
        raise @core.ImeRequestError::AlreadyEnabled
      } else {
        self.set_ime_allowed(true)
        self.ime_capabilities_state = Some(capabilities)
        ()
      }
    @core.ImeRequest::EnableRequest(enable_request) =>
      if self.ime_allowed() {
        raise @core.ImeRequestError::AlreadyEnabled
      } else {
        let capabilities = enable_request.capabilities()
        let request_data = enable_request.request_data()
        self.set_ime_allowed(true)
        self.ime_capabilities_state = Some(capabilities)
        self.apply_ime_request_data(request_data)
      }
    @core.ImeRequest::Update(request_data) =>
      self.apply_ime_request_data(request_data)
    @core.ImeRequest::Disable => {
      self.set_ime_allowed(false)
      ()
    }
    @core.ImeRequest::SetAllowed(allowed) =>
      if allowed {
        if self.ime_allowed() {
          raise @core.ImeRequestError::AlreadyEnabled
        } else {
          self.set_ime_allowed(true)
          if self.ime_capabilities_state is None {
            self.ime_capabilities_state = Some(default_ime_capabilities())
          }
          ()
        }
      } else {
        self.set_ime_allowed(false)
        ()
      }
    @core.ImeRequest::SetHintAndPurpose(hints, purpose) =>
      if self.ime_allowed() == false {
        raise @core.ImeRequestError::NotEnabled
      } else if self.ime_supports_hint_and_purpose() == false {
        raise @core.ImeRequestError::NotSupported
      } else {
        self.set_ime_hints(hints)
        self.set_ime_purpose(purpose)
        ()
      }
    @core.ImeRequest::SetPurpose(purpose) =>
      if self.ime_allowed() == false {
        raise @core.ImeRequestError::NotEnabled
      } else if self.ime_supports_hint_and_purpose() == false {
        raise @core.ImeRequestError::NotSupported
      } else {
        self.set_ime_purpose(purpose)
        ()
      }
    @core.ImeRequest::SetCursorArea(position, size) =>
      if self.ime_allowed() == false {
        raise @core.ImeRequestError::NotEnabled
      } else if self.ime_supports_cursor_area() == false {
        raise @core.ImeRequestError::NotSupported
      } else {
        self.set_ime_cursor_area(position, size)
        ()
      }
    @core.ImeRequest::SetSurroundingText(surrounding_text) =>
      if self.ime_allowed() == false {
        raise @core.ImeRequestError::NotEnabled
      } else if self.ime_supports_surrounding_text() == false {
        raise @core.ImeRequestError::NotSupported
      } else {
        self.set_ime_surrounding_text(surrounding_text)
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
    None => true
  }
}

///|
fn Window::ime_supports_cursor_area(self : Window) -> Bool {
  match self.ime_capabilities_state {
    Some(capabilities) => capabilities.cursor_area()
    None => true
  }
}

///|
fn Window::ime_supports_surrounding_text(self : Window) -> Bool {
  match self.ime_capabilities_state {
    Some(capabilities) => capabilities.surrounding_text()
    None => true
  }
}

///|
pub fn Window::scale_factor(self : Window) -> Double {
  window_scale_factor(self.id.into_raw())
}

///|
pub fn Window::request_redraw(self : Window) -> Unit {
  native_window_request_redraw(self.id.into_raw())
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
  set_title(self.id.into_raw(), title)
}

///|
pub fn Window::title(self : Window) -> String {
  text_from_native(window_title(self.id.into_raw()))
}

///|
pub fn Window::set_theme(self : Window, theme : @core.Theme?) -> Unit {
  set_window_theme(self.id.into_raw(), theme_to_native(theme))
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
  set_window_content_protected(self.id.into_raw(), content_protected)
}

///|
pub fn Window::set_visible(self : Window, visible : Bool) -> Unit {
  native_set_visible(self.id.into_raw(), visible)
}

///|
pub fn Window::is_visible(self : Window) -> Bool? {
  Some(window_visible(self.id.into_raw()))
}

///|
pub fn Window::set_resizable(self : Window, resizable : Bool) -> Unit {
  native_set_resizable(self.id.into_raw(), resizable)
}

///|
pub fn Window::is_resizable(self : Window) -> Bool {
  window_resizable(self.id.into_raw())
}

///|
pub fn Window::is_content_protected(self : Window) -> Bool {
  window_content_protected(self.id.into_raw())
}

///|
pub fn Window::is_document_edited(self : Window) -> Bool {
  window_document_edited(self.id.into_raw())
}

///|
pub fn Window::set_document_edited(self : Window, edited : Bool) -> Unit {
  set_window_document_edited(self.id.into_raw(), edited)
}

///|
pub fn Window::set_option_as_alt(
  self : Window,
  option_as_alt : @core.OptionAsAlt,
) -> Unit {
  set_window_option_as_alt(
    self.id.into_raw(),
    option_as_alt_to_native(option_as_alt),
  )
}

///|
pub fn Window::option_as_alt(self : Window) -> @core.OptionAsAlt {
  option_as_alt_from_native(window_option_as_alt(self.id.into_raw()))
}

///|
pub fn Window::request_user_attention(
  self : Window,
  request_type : @core.UserAttentionType?,
) -> Unit {
  request_user_attention(
    self.id.into_raw(),
    user_attention_type_to_native(request_type),
  )
}

///|
fn theme_from_native(theme : Int) -> @core.Theme? {
  match theme {
    1 => Some(@core.Theme::Light)
    2 => Some(@core.Theme::Dark)
    _ => None
  }
}

///|
fn theme_to_native(theme : @core.Theme?) -> Int {
  match theme {
    Some(@core.Theme::Light) => 1
    Some(@core.Theme::Dark) => 2
    None => 0
  }
}

///|
fn element_state_from_native(state : Int) -> @core.ElementState? {
  match state {
    1 => Some(@core.ElementState::Pressed)
    2 => Some(@core.ElementState::Released)
    _ => None
  }
}

///|
fn mouse_button_from_native(button : Int) -> @core.MouseButton? {
  @core.MouseButton::try_from_u8(button)
}

///|
fn button_source_from_native(button : Int) -> @core.ButtonSource {
  match mouse_button_from_native(button) {
    Some(mouse) => @core.ButtonSource::Mouse(mouse)
    None => @core.ButtonSource::Unknown(button)
  }
}

///|
fn pointer_source_from_native(source : Int) -> @core.PointerSource {
  match source {
    1 => @core.PointerSource::Mouse
    _ => @core.PointerSource::Unknown
  }
}

///|
fn pointer_kind_from_native(kind : Int) -> @core.PointerKind {
  match kind {
    1 => @core.PointerKind::Mouse
    _ => @core.PointerKind::Unknown
  }
}

///|
fn scroll_delta_from_native(
  kind : Int,
  x : Double,
  y : Double,
) -> @core.MouseScrollDelta? {
  match kind {
    1 => Some(@core.MouseScrollDelta::LineDelta(x, y))
    2 =>
      Some(
        @core.MouseScrollDelta::PixelDelta(@dpi.PhysicalPositionF64::new(x, y)),
      )
    _ => None
  }
}

///|
fn touch_phase_from_native(phase : Int) -> @core.TouchPhase? {
  match phase {
    1 => Some(@core.TouchPhase::Started)
    2 => Some(@core.TouchPhase::Moved)
    3 => Some(@core.TouchPhase::Ended)
    4 => Some(@core.TouchPhase::Cancelled)
    _ => None
  }
}

///|
fn modifiers_state_from_native(modifiers : Int) -> @core.ModifiersState {
  let mut state = @core.ModifiersState::none()
  if (modifiers & 1) != 0 {
    state = state.union(@core.ModifiersState::shift())
  }
  if (modifiers & 2) != 0 {
    state = state.union(@core.ModifiersState::control())
  }
  if (modifiers & 4) != 0 {
    state = state.union(@core.ModifiersState::alt())
  }
  if (modifiers & 8) != 0 {
    state = state.union(@core.ModifiersState::meta())
  }
  state
}

///|
fn modifiers_from_native(
  modifiers : Int,
  pressed_mods : @core.ModifiersKeys,
) -> @core.Modifiers {
  @core.Modifiers::from_state(
    modifiers_state_from_native(modifiers),
    pressed_mods,
  )
}

///|
fn modifier_keys_from_physical_key(
  physical_key : @core.PhysicalKey,
) -> @core.ModifiersKeys? {
  match physical_key {
    @core.PhysicalKey::Code(@core.KeyCode::ShiftLeft) =>
      Some(@core.ModifiersKeys::lshift())
    @core.PhysicalKey::Code(@core.KeyCode::ShiftRight) =>
      Some(@core.ModifiersKeys::rshift())
    @core.PhysicalKey::Code(@core.KeyCode::ControlLeft) =>
      Some(@core.ModifiersKeys::lcontrol())
    @core.PhysicalKey::Code(@core.KeyCode::ControlRight) =>
      Some(@core.ModifiersKeys::rcontrol())
    @core.PhysicalKey::Code(@core.KeyCode::AltLeft) =>
      Some(@core.ModifiersKeys::lalt())
    @core.PhysicalKey::Code(@core.KeyCode::AltRight) =>
      Some(@core.ModifiersKeys::ralt())
    @core.PhysicalKey::Code(@core.KeyCode::MetaLeft) =>
      Some(@core.ModifiersKeys::lmeta())
    @core.PhysicalKey::Code(@core.KeyCode::MetaRight) =>
      Some(@core.ModifiersKeys::rmeta())
    _ => None
  }
}

///|
fn update_pressed_modifier_keys(
  state : @core.ModifiersState,
  pressed_mods : @core.ModifiersKeys,
  physical_key : @core.PhysicalKey,
  element_state : @core.ElementState,
) -> @core.ModifiersKeys {
  let updated = match modifier_keys_from_physical_key(physical_key) {
    Some(modifier_key) =>
      match element_state {
        @core.ElementState::Pressed => pressed_mods.union(modifier_key)
        @core.ElementState::Released => pressed_mods.without(modifier_key)
      }
    None => pressed_mods
  }
  normalize_pressed_modifier_keys(state, updated)
}

///|
fn normalize_pressed_modifier_keys(
  state : @core.ModifiersState,
  pressed_mods : @core.ModifiersKeys,
) -> @core.ModifiersKeys {
  @core.Modifiers::from_state(state, pressed_mods).pressed_mods()
}

///|
fn ime_purpose_to_native(purpose : @core.ImePurpose) -> Int {
  match purpose {
    @core.ImePurpose::Normal => 0
    @core.ImePurpose::Password => 1
    @core.ImePurpose::Terminal => 2
    @core.ImePurpose::Number => 3
    @core.ImePurpose::Phone => 4
    @core.ImePurpose::Url => 5
    @core.ImePurpose::Email => 6
    @core.ImePurpose::Pin => 7
    @core.ImePurpose::Date => 8
    @core.ImePurpose::Time => 9
    @core.ImePurpose::DateTime => 10
  }
}

///|
fn ime_purpose_from_native(purpose : Int) -> @core.ImePurpose {
  match purpose {
    1 => @core.ImePurpose::Password
    2 => @core.ImePurpose::Terminal
    3 => @core.ImePurpose::Number
    4 => @core.ImePurpose::Phone
    5 => @core.ImePurpose::Url
    6 => @core.ImePurpose::Email
    7 => @core.ImePurpose::Pin
    8 => @core.ImePurpose::Date
    9 => @core.ImePurpose::Time
    10 => @core.ImePurpose::DateTime
    _ => @core.ImePurpose::Normal
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
fn window_level_to_native(level : @core.WindowLevel) -> Int {
  match level {
    @core.WindowLevel::Normal => 0
    @core.WindowLevel::AlwaysOnTop => 1
    @core.WindowLevel::AlwaysOnBottom => 2
  }
}

///|
fn window_level_from_native(level : Int) -> @core.WindowLevel {
  match level {
    1 => @core.WindowLevel::AlwaysOnTop
    2 => @core.WindowLevel::AlwaysOnBottom
    _ => @core.WindowLevel::Normal
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

///|
fn resize_direction_to_native(direction : @core.ResizeDirection) -> Int {
  match direction {
    @core.ResizeDirection::East => 0
    @core.ResizeDirection::North => 1
    @core.ResizeDirection::NorthEast => 2
    @core.ResizeDirection::NorthWest => 3
    @core.ResizeDirection::South => 4
    @core.ResizeDirection::SouthEast => 5
    @core.ResizeDirection::SouthWest => 6
    @core.ResizeDirection::West => 7
  }
}

///|
fn user_attention_type_to_native(
  request_type : @core.UserAttentionType?,
) -> Int {
  match request_type {
    None => 0
    Some(@core.UserAttentionType::Critical) => 1
    Some(@core.UserAttentionType::Informational) => 2
  }
}

///|
fn option_as_alt_to_native(option_as_alt : @core.OptionAsAlt) -> Int {
  match option_as_alt {
    @core.OptionAsAlt::OnlyLeft => 1
    @core.OptionAsAlt::OnlyRight => 2
    @core.OptionAsAlt::Both => 3
    @core.OptionAsAlt::None => 0
  }
}

///|
fn option_as_alt_from_native(option_as_alt : Int) -> @core.OptionAsAlt {
  match option_as_alt {
    1 => @core.OptionAsAlt::OnlyLeft
    2 => @core.OptionAsAlt::OnlyRight
    3 => @core.OptionAsAlt::Both
    _ => @core.OptionAsAlt::None
  }
}

///|
fn optional_text_from_native(bytes : Bytes) -> String? {
  if bytes.length() == 0 {
    None
  } else {
    Some(@utf8.decode_lossy(bytes[:], ignore_bom=false))
  }
}

///|
fn text_from_native(bytes : Bytes) -> String {
  @utf8.decode_lossy(bytes[:], ignore_bom=false)
}

///|
fn monitor_from_native_id(monitor_id : UInt64) -> @core.MonitorHandle? {
  if monitor_id == (0 : Int).to_uint64() {
    None
  } else {
    let width = monitor_width(monitor_id)
    let height = monitor_height(monitor_id)
    let video_mode_count = monitor_video_mode_count(monitor_id)
    let video_modes : Array[@core.VideoMode] = []
    let mut mode_index = 0
    while mode_index < video_mode_count {
      let mode_width = monitor_video_mode_width(monitor_id, mode_index)
      let mode_height = monitor_video_mode_height(monitor_id, mode_index)
      if mode_width > 0 && mode_height > 0 {
        let bit_depth_raw = monitor_video_mode_bit_depth(monitor_id, mode_index)
        let refresh_rate_raw = monitor_video_mode_refresh_rate_millihertz(
          monitor_id, mode_index,
        )
        video_modes.push(
          @core.VideoMode::new(
            @dpi.PhysicalSize::new(mode_width, mode_height),
            if bit_depth_raw > 0 {
              Some(bit_depth_raw)
            } else {
              None
            },
            if refresh_rate_raw > 0 {
              Some(refresh_rate_raw)
            } else {
              None
            },
          ),
        )
      }
      mode_index = mode_index + 1
    }
    let current_mode_index = monitor_current_video_mode_index(monitor_id)
    let current_video_mode = if current_mode_index >= 0 &&
      current_mode_index < video_modes.length() {
      Some(video_modes[current_mode_index])
    } else {
      None
    }
    Some(
      @core.MonitorHandle::new(
        monitor_id,
        optional_text_from_native(monitor_name(monitor_id)),
        @dpi.PhysicalPosition::new(
          monitor_position_x(monitor_id),
          monitor_position_y(monitor_id),
        ),
        @dpi.PhysicalSize::new(
          if width > 0 {
            width
          } else {
            1
          },
          if height > 0 {
            height
          } else {
            1
          },
        ),
        monitor_scale_factor(monitor_id),
        current_video_mode,
        video_modes,
      ),
    )
  }
}

///|
fn monitors_from_native() -> Array[@core.MonitorHandle] {
  let monitors : Array[@core.MonitorHandle] = []
  let count = available_monitor_count()
  let mut index = 0
  while index < count {
    match monitor_from_native_id(monitor_id_at(index)) {
      Some(monitor) => monitors.push(monitor)
      None => ()
    }
    index = index + 1
  }
  monitors
}

///|
fn drag_paths_from_native(bytes : Bytes) -> Array[String] {
  let text = text_from_native(bytes)
  let paths : Array[String] = []
  for path in text.split("\n"[:]) {
    let value = path.to_string()
    if value != "" {
      paths.push(value)
    }
  }
  paths
}

///|
fn ime_from_native(window_id : Int) -> @core.Ime? {
  match input_event_ime_kind(window_id) {
    1 => Some(@core.Ime::Enabled)
    2 => {
      let cursor_start = input_event_ime_cursor_start(window_id)
      let cursor_end = input_event_ime_cursor_end(window_id)
      let cursor = if cursor_start >= 0 && cursor_end >= cursor_start {
        Some(@core.ImeCursorRange::new(cursor_start, cursor_end))
      } else {
        None
      }
      Some(
        @core.Ime::Preedit(
          text_from_native(input_event_ime_text(window_id)),
          cursor,
        ),
      )
    }
    3 =>
      Some(@core.Ime::Commit(text_from_native(input_event_ime_text(window_id))))
    4 => Some(@core.Ime::Disabled)
    _ => None
  }
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_input_events(
  self : EventLoop,
  app : A,
  raw_id : Int,
  window_id : @core.WindowId,
) -> Unit {
  while take_input_event(raw_id) {
    let pointer_device_id = Some(@core.DeviceId::from_raw(1L))
    let keyboard_device_id = Some(@core.DeviceId::from_raw(2L))
    let position = @dpi.PhysicalPositionF64::new(
      input_event_x(raw_id),
      input_event_y(raw_id),
    )
    match input_event_kind(raw_id) {
      1 => {
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::PointerMoved(
            pointer_device_id,
            position,
            true,
            pointer_source_from_native(input_event_pointer_source(raw_id)),
          ),
        )
        app.device_event(
          self,
          pointer_device_id,
          @core.DeviceEvent::PointerMotion(
            input_event_scroll_delta_x(raw_id),
            input_event_scroll_delta_y(raw_id),
          ),
        )
      }
      2 =>
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::PointerEntered(
            pointer_device_id,
            position,
            true,
            pointer_kind_from_native(input_event_pointer_kind(raw_id)),
          ),
        )
      3 =>
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::PointerLeft(
            pointer_device_id,
            Some(position),
            true,
            pointer_kind_from_native(input_event_pointer_kind(raw_id)),
          ),
        )
      4 =>
        match element_state_from_native(input_event_state(raw_id)) {
          Some(state) => {
            app.window_event(
              self,
              window_id,
              @core.WindowEvent::PointerButton(
                pointer_device_id,
                state,
                position,
                true,
                button_source_from_native(input_event_button(raw_id)),
              ),
            )
            app.device_event(
              self,
              pointer_device_id,
              @core.DeviceEvent::Button(
                @core.ButtonId::from_raw(input_event_button(raw_id)),
                state,
              ),
            )
          }
          None => ()
        }
      5 =>
        match
          (
            scroll_delta_from_native(
              input_event_scroll_delta_kind(raw_id),
              input_event_scroll_delta_x(raw_id),
              input_event_scroll_delta_y(raw_id),
            ),
            touch_phase_from_native(input_event_phase(raw_id)),
          ) {
          (Some(delta), Some(phase)) => {
            app.window_event(
              self,
              window_id,
              @core.WindowEvent::MouseWheel(pointer_device_id, delta, phase),
            )
            app.device_event(
              self,
              pointer_device_id,
              @core.DeviceEvent::MouseWheel(delta),
            )
          }
          _ => ()
        }
      6 => {
        let state = modifiers_state_from_native(input_event_modifiers(raw_id))
        self.pressed_modifiers_ = normalize_pressed_modifier_keys(
          state,
          self.pressed_modifiers_,
        )
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::ModifiersChanged(
            @core.Modifiers::from_state(state, self.pressed_modifiers_),
          ),
        )
      }
      7 =>
        match element_state_from_native(input_event_state(raw_id)) {
          Some(state) => {
            let modifiers = modifiers_from_native(
              input_event_modifiers(raw_id),
              self.pressed_modifiers_,
            )
            let key_event = create_key_event(
              input_event_scancode(raw_id),
              state,
              input_event_repeat(raw_id),
              modifiers,
              optional_text_from_native(
                input_event_text_with_all_modifiers(raw_id),
              ),
              optional_text_from_native(
                input_event_text_ignoring_modifiers(raw_id),
              ),
              optional_text_from_native(
                input_event_text_without_modifiers(raw_id),
              ),
            )
            self.pressed_modifiers_ = update_pressed_modifier_keys(
              modifiers.state(),
              self.pressed_modifiers_,
              key_event.physical_key(),
              state,
            )
            app.window_event(
              self,
              window_id,
              @core.WindowEvent::KeyboardInput(
                keyboard_device_id, key_event, false,
              ),
            )
            app.device_event(
              self,
              keyboard_device_id,
              @core.DeviceEvent::Key(
                @core.RawKeyEvent::new(key_event.physical_key(), state),
              ),
            )
          }
          None => ()
        }
      8 =>
        match ime_from_native(raw_id) {
          Some(ime) =>
            app.window_event(self, window_id, @core.WindowEvent::Ime(ime))
          None => ()
        }
      9 =>
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::DragEntered(
            drag_paths_from_native(input_event_path(raw_id)),
            position,
          ),
        )
      10 =>
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::DragMoved(position),
        )
      11 =>
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::DragDropped(
            drag_paths_from_native(input_event_path(raw_id)),
            position,
          ),
        )
      12 =>
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::DragLeft(
            if input_event_state(raw_id) != 0 {
              Some(position)
            } else {
              None
            },
          ),
        )
      13 =>
        match touch_phase_from_native(input_event_phase(raw_id)) {
          Some(phase) =>
            app.window_event(
              self,
              window_id,
              @core.WindowEvent::PinchGesture(
                pointer_device_id,
                input_event_scroll_delta_x(raw_id),
                phase,
              ),
            )
          None => ()
        }
      14 =>
        match touch_phase_from_native(input_event_phase(raw_id)) {
          Some(phase) =>
            app.window_event(
              self,
              window_id,
              @core.WindowEvent::PanGesture(
                pointer_device_id,
                @dpi.PhysicalPositionF64::new(
                  input_event_scroll_delta_x(raw_id),
                  input_event_scroll_delta_y(raw_id),
                ),
                phase,
              ),
            )
          None => ()
        }
      15 =>
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::DoubleTapGesture(pointer_device_id),
        )
      16 =>
        match touch_phase_from_native(input_event_phase(raw_id)) {
          Some(phase) =>
            app.window_event(
              self,
              window_id,
              @core.WindowEvent::RotationGesture(
                pointer_device_id,
                input_event_scroll_delta_x(raw_id),
                phase,
              ),
            )
          None => ()
        }
      17 =>
        app.window_event(
          self,
          window_id,
          @core.WindowEvent::TouchpadPressure(
            pointer_device_id,
            input_event_scroll_delta_x(raw_id),
            input_event_state(raw_id),
          ),
        )
      _ => ()
    }
  }
}

///|
pub fn Window::theme(self : Window) -> @core.Theme? {
  theme_from_native(window_theme(self.id.into_raw()))
}

///|
pub fn Window::is_occluded(self : Window) -> Bool {
  window_occluded(self.id.into_raw())
}

///|
pub struct EventLoop {
  priv mut control_flow_ : @core.ControlFlow
  priv mut exit_requested : Bool
  priv mut pressed_modifiers_ : @core.ModifiersKeys
  priv mut window_ids : Array[Int]
} derive(Show)

///|
pub type ActiveEventLoop = EventLoop

///|
pub fn EventLoop::new() -> EventLoop {
  guard backend_available() else {
    abort("macos backend is unavailable on this target")
  }
  reset_proxy_wake_state()
  {
    control_flow_: @core.ControlFlow::Wait,
    exit_requested: false,
    pressed_modifiers_: @core.ModifiersKeys::none(),
    window_ids: [],
  }
}

///|
pub fn EventLoop::create_window(
  self : EventLoop,
  attributes : @core.WindowAttributes,
) -> Window {
  let scale_factor = match self.primary_monitor() {
    Some(monitor) => monitor.scale_factor()
    None => 1.0
  }
  let size = match attributes.surface_size() {
    Some(size) => size.to_physical(scale_factor)
    None => @dpi.PhysicalSize::new(800, 600)
  }
  let raw_id = create_window(
    size.width(),
    size.height(),
    attributes.visible(),
    attributes.active(),
    attributes.resizable(),
    attributes.decorations(),
    attributes.title(),
  )
  guard raw_id > 0 else { abort("failed to create macos window") }
  match attributes.parent_window() {
    Some(parent_window) => {
      let _ = set_parent_window(raw_id, parent_window.into_raw())
      ()
    }
    None => ()
  }
  set_window_borderless_game(
    raw_id,
    attributes.platform_attributes().borderless_game(),
  )
  set_window_has_shadow(raw_id, attributes.platform_attributes().has_shadow())
  set_window_option_as_alt(
    raw_id,
    option_as_alt_to_native(attributes.platform_attributes().option_as_alt()),
  )
  match attributes.platform_attributes().tabbing_identifier() {
    Some(identifier) => set_window_tabbing_identifier(raw_id, identifier)
    None => ()
  }
  set_window_theme(raw_id, theme_to_native(attributes.theme()))
  set_window_content_protected(raw_id, attributes.content_protected())
  set_window_blur(raw_id, attributes.blur())
  let mut cursor_state = attributes.cursor()
  match attributes.cursor() {
    @core.Cursor::Icon(icon) =>
      set_window_cursor(raw_id, cursor_icon_to_native(icon))
    @core.Cursor::Custom(custom_cursor) =>
      if set_window_custom_cursor(raw_id, custom_cursor.into_raw()) == false {
        set_window_cursor(
          raw_id,
          cursor_icon_to_native(@core.CursorIcon::Default),
        )
        cursor_state = @core.Cursor::Icon(@core.CursorIcon::Default)
      }
  }
  set_window_cursor_visible(raw_id, attributes.cursor_visible())
  set_window_cursor_hittest(raw_id, attributes.cursor_hittest())
  let enabled_buttons = attributes.enabled_buttons()
  set_window_enabled_buttons(
    raw_id,
    enabled_buttons.close(),
    enabled_buttons.minimize(),
    enabled_buttons.maximize(),
  )
  match attributes.surface_resize_increments() {
    Some(increments) => {
      let physical_increments = increments.to_physical(scale_factor)
      set_surface_resize_increments(
        raw_id,
        physical_increments.width(),
        physical_increments.height(),
      )
    }
    None => ()
  }
  set_ime_purpose(raw_id, ime_purpose_to_native(attributes.ime_purpose()))
  set_ime_hints(raw_id, attributes.ime_hints().bits())
  set_window_level(raw_id, window_level_to_native(attributes.window_level()))
  set_window_transparent(raw_id, attributes.transparent())
  if attributes.maximized() {
    set_window_maximized(raw_id, true)
  }
  match attributes.fullscreen() {
    Some(@core.Fullscreen::Borderless(target_monitor)) => {
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
      let monitor_position = target_monitor.position()
      let mode_size = video_mode.surface_size()
      set_window_position(raw_id, monitor_position.x(), monitor_position.y())
      set_surface_size(raw_id, mode_size.width(), mode_size.height())
      set_window_fullscreen(raw_id, true)
    }
    None => ()
  }
  match attributes.min_surface_size() {
    Some(min_size) => {
      let physical_min = min_size.to_physical(scale_factor)
      set_min_surface_size(raw_id, physical_min.width(), physical_min.height())
    }
    None => ()
  }
  match attributes.max_surface_size() {
    Some(max_size) => {
      let physical_max = max_size.to_physical(scale_factor)
      set_max_surface_size(raw_id, physical_max.width(), physical_max.height())
    }
    None => ()
  }
  match attributes.position() {
    Some(position) => {
      let physical_position = position.to_physical(scale_factor)
      set_window_position(raw_id, physical_position.x(), physical_position.y())
    }
    None => ()
  }
  if attributes.fullscreen() is None &&
    attributes.platform_attributes().simple_fullscreen() == Some(true) {
    ignore(set_window_simple_fullscreen(raw_id, true))
  }
  self.window_ids.push(raw_id)
  {
    id: @core.WindowId::from_raw(raw_id),
    cursor_state,
    fullscreen_state: initial_fullscreen_state(attributes),
    ime_capabilities_state: Some(default_ime_capabilities()),
  }
}

///|
pub fn EventLoop::create_custom_cursor(
  _self : EventLoop,
  source : @core.CustomCursorSource,
) -> @core.CustomCursor raise @core.RequestError {
  match source {
    @core.CustomCursorSource::Rgba(rgba, width, height, hotspot_x, hotspot_y) => {
      let raw = create_custom_cursor_rgba(
        rgba, width, height, hotspot_x, hotspot_y,
      )
      if raw == (0 : Int).to_uint64() {
        raise @core.RequestError::NotSupported(
          "custom cursor is not supported on this platform",
        )
      } else {
        @core.CustomCursor::from_raw(raw)
      }
    }
    @core.CustomCursorSource::Url(url, hotspot_x, hotspot_y) => {
      let raw = create_custom_cursor_url(url, hotspot_x, hotspot_y)
      if raw == (0 : Int).to_uint64() {
        raise @core.RequestError::NotSupported(
          "failed to create url-backed custom cursor on macOS backend",
        )
      } else {
        @core.CustomCursor::from_raw(raw)
      }
    }
    @core.CustomCursorSource::Animation(_, _) =>
      raise @core.RequestError::NotSupported(
        "animated custom cursors are not supported on macOS backend",
      )
  }
}

///|
fn initial_fullscreen_state(
  attributes : @core.WindowAttributes,
) -> @core.Fullscreen? {
  attributes.fullscreen()
}

///|
fn default_ime_capabilities() -> @core.ImeCapabilities {
  @core.ImeCapabilities::new(true, true, true)
}

///|
pub fn EventLoop::set_control_flow(
  self : EventLoop,
  control_flow : @core.ControlFlow,
) -> Unit {
  self.control_flow_ = control_flow
}

///|
pub fn EventLoop::control_flow(self : EventLoop) -> @core.ControlFlow {
  self.control_flow_
}

///|
pub fn EventLoop::create_proxy(_self : EventLoop) -> EventLoopProxy {
  { _unit: () }
}

///|
pub fn EventLoop::exit(self : EventLoop) -> Unit {
  self.exit_requested = true
}

///|
pub fn EventLoop::exiting(self : EventLoop) -> Bool {
  self.exit_requested
}

///|
pub(open) trait ApplicationHandler {
  new_events(Self, ActiveEventLoop, @core.StartCause) -> Unit = _
  resumed(Self, ActiveEventLoop) -> Unit = _
  can_create_surfaces(Self, ActiveEventLoop) -> Unit = _
  proxy_wake_up(Self, ActiveEventLoop) -> Unit = _
  window_event(Self, EventLoop, @core.WindowId, @core.WindowEvent) -> Unit = _
  device_event(Self, ActiveEventLoop, @core.DeviceId?, @core.DeviceEvent) -> Unit = _
  about_to_wait(Self, ActiveEventLoop) -> Unit = _
  suspended(Self, ActiveEventLoop) -> Unit = _
  destroy_surfaces(Self, ActiveEventLoop) -> Unit = _
  memory_warning(Self, ActiveEventLoop) -> Unit = _
  macos_handler(Self) -> Bool = _
}

///|
impl ApplicationHandler with new_events(_self, _event_loop, _cause) {
  ()
}

///|
impl ApplicationHandler with resumed(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with can_create_surfaces(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with proxy_wake_up(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with window_event(_self, _event_loop, _id, _event) {
  ()
}

///|
impl ApplicationHandler with device_event(
  _self,
  _event_loop,
  _device_id,
  _event,
) {
  ()
}

///|
impl ApplicationHandler with about_to_wait(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with suspended(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with destroy_surfaces(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with memory_warning(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with macos_handler(_self) {
  false
}

///|
fn EventLoop::close_windows(self : EventLoop) -> Unit {
  for raw_id in self.window_ids {
    close_window(raw_id)
  }
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_window_events(
  self : EventLoop,
  app : A,
) -> Unit {
  let mut polled = false
  let remaining_window_ids : Array[Int] = []
  for raw_id in self.window_ids {
    if polled == false {
      native_poll_window(raw_id)
      polled = true
    }
    let window_id = @core.WindowId::from_raw(raw_id)
    if take_moved(raw_id) {
      app.window_event(
        self,
        window_id,
        @core.WindowEvent::Moved(
          @dpi.PhysicalPosition::new(
            pending_move_x(raw_id),
            pending_move_y(raw_id),
          ),
        ),
      )
    }
    if take_focused_changed(raw_id) {
      app.window_event(
        self,
        window_id,
        @core.WindowEvent::Focused(pending_focused(raw_id)),
      )
    }
    self.dispatch_input_events(app, raw_id, window_id)
    if take_theme_changed(raw_id) {
      match theme_from_native(pending_theme(raw_id)) {
        Some(theme) =>
          app.window_event(
            self,
            window_id,
            @core.WindowEvent::ThemeChanged(theme),
          )
        None => ()
      }
    }
    if take_occluded_changed(raw_id) {
      app.window_event(
        self,
        window_id,
        @core.WindowEvent::Occluded(pending_occluded(raw_id)),
      )
    }
    if take_scale_factor_changed(raw_id) {
      let scale_factor = pending_scale_factor(raw_id)
      let suggested_size = @dpi.PhysicalSize::new(
        pending_scale_width(raw_id),
        pending_scale_height(raw_id),
      )
      let writer = @core.SurfaceSizeWriter::new(suggested_size)
      app.window_event(
        self,
        window_id,
        @core.WindowEvent::ScaleFactorChanged(scale_factor, writer),
      )
      let requested_size = writer.surface_size()
      set_surface_size(raw_id, requested_size.width(), requested_size.height())
    }
    if native_window_take_surface_resized(raw_id) {
      let size = @dpi.PhysicalSize::new(
        native_window_width(raw_id),
        native_window_height(raw_id),
      )
      app.window_event(self, window_id, @core.WindowEvent::SurfaceResized(size))
    }
    if native_window_take_redraw_requested(raw_id) {
      app.window_event(self, window_id, @core.WindowEvent::RedrawRequested)
    }
    if native_window_take_close_requested(raw_id) {
      app.window_event(self, window_id, @core.WindowEvent::CloseRequested)
    }
    let destroyed = take_destroyed(raw_id)
    if destroyed {
      app.window_event(self, window_id, @core.WindowEvent::Destroyed)
    }
    if destroyed == false {
      remaining_window_ids.push(raw_id)
    }
  }
  self.window_ids = remaining_window_ids
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_proxy_wake_up(
  self : EventLoop,
  app : A,
) -> Unit {
  if native_event_loop_take_proxy_wake_up() {
    app.proxy_wake_up(self)
  }
}

///|
fn EventLoop::wait_next_iteration(self : EventLoop) -> @core.StartCause {
  match self.control_flow_ {
    @core.ControlFlow::Poll => @core.StartCause::Poll
    @core.ControlFlow::Wait => {
      let start_ms = runtime_now_ms()
      let _ = wait_for_events(-1)
      @core.StartCause::WaitCancelled(start_ms, None)
    }
    @core.ControlFlow::WaitUntil(requested_resume_ms) => {
      let start_ms = runtime_now_ms()
      let remaining_ms = requested_resume_ms - start_ms
      if remaining_ms <= 0L {
        @core.StartCause::ResumeTimeReached(start_ms, requested_resume_ms)
      } else if wait_for_events(
          if remaining_ms > 2147483647L {
            2147483647
          } else {
            remaining_ms.to_int()
          },
        ) {
        @core.StartCause::ResumeTimeReached(start_ms, requested_resume_ms)
      } else {
        @core.StartCause::WaitCancelled(start_ms, Some(requested_resume_ms))
      }
    }
  }
}

///|
pub fn[A : ApplicationHandler] EventLoop::run_app(
  self : EventLoop,
  app : A,
) -> Unit {
  app.new_events(self, @core.StartCause::Init)
  app.resumed(self)
  app.can_create_surfaces(self)
  while self.exit_requested == false {
    self.dispatch_window_events(app)
    self.dispatch_proxy_wake_up(app)
    if self.exit_requested {
      break
    }
    app.about_to_wait(self)
    if self.exit_requested {
      break
    }
    app.new_events(self, self.wait_next_iteration())
  }
  if self.exit_requested {
    app.destroy_surfaces(self)
    self.close_windows()
    self.dispatch_window_events(app)
    app.suspended(self)
  }
}
