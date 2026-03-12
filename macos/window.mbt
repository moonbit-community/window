///|
// Port target: winit-reference/winit-appkit/src/window.rs

///|
pub struct Window {
  priv id : @core.WindowId
  priv mut cursor_state : @core.Cursor
  priv mut fullscreen_state : @core.Fullscreen?
  priv mut ime_capabilities_state : @core.ImeCapabilities?
  priv mut ime_cursor_area_position_state : @dpi.PhysicalPosition
  priv mut ime_cursor_area_size_state : @dpi.PhysicalSize
  priv mut ime_surrounding_text_state : @core.ImeSurroundingText?
  priv mut visible_state : Bool
  priv mut resizable_state : Bool
  priv mut content_protected_state : Bool
  priv mut decorated_state : Bool
  priv mut enabled_buttons_state : @core.WindowButtons
  priv mut blur_state : Bool
  priv mut has_shadow_state : Bool
  priv mut document_edited_state : Bool
  priv mut option_as_alt_state : @core.OptionAsAlt
  priv mut borderless_game_state : Bool
  priv mut unified_titlebar_state : Bool
  priv mut cursor_visible_state : Bool
  priv mut cursor_hittest_state : Bool
  priv mut transparent_state : Bool
  priv mut window_level_state : @core.WindowLevel
  priv mut ime_allowed_state : Bool
  priv mut ime_purpose_state : @core.ImePurpose
  priv mut ime_hints_state : @core.ImeHint
} derive(Eq, Show)

///|
pub type WindowAttributesMacOS = @core.PlatformWindowAttributes

///|
pub fn Window::id(self : Window) -> @core.WindowId {
  self.id
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
pub fn Window::inner_size(self : Window) -> @dpi.PhysicalSize {
  self.surface_size()
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
pub fn Window::inner_position(self : Window) -> @dpi.PhysicalPosition {
  self.surface_position()
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
pub fn Window::set_resize_increments(self : Window, size : @dpi.Size?) -> Unit {
  self.set_surface_resize_increments(size)
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
pub fn Window::resize_increments(self : Window) -> @dpi.PhysicalSize? {
  self.surface_resize_increments()
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
pub fn Window::set_min_inner_size(self : Window, size : @dpi.Size?) -> Unit {
  self.set_min_surface_size(size)
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
pub fn Window::set_max_inner_size(self : Window, size : @dpi.Size?) -> Unit {
  self.set_max_surface_size(size)
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
pub fn Window::min_inner_size(self : Window) -> @dpi.PhysicalSize? {
  self.min_surface_size()
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
pub fn Window::max_inner_size(self : Window) -> @dpi.PhysicalSize? {
  self.max_surface_size()
}

///|
pub fn Window::outer_position(
  self : Window,
) -> @dpi.PhysicalPosition raise @core.RequestError {
  let raw_id = self.id.into_raw()
  if window_handle(raw_id) == (0 : Int).to_uint64() {
    raise @core.RequestError::Ignored
  }
  @dpi.PhysicalPosition::new(window_x(raw_id), window_y(raw_id))
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
  let is_visible = self.visible_state
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
      None =>
        if window_is_exclusive_fullscreen(raw_id) {
          ignore(
            set_window_exclusive_fullscreen(
              raw_id,
              (0 : Int).to_uint64(),
              0,
              0,
              0,
              0,
            ),
          )
        } else {
          set_window_fullscreen(raw_id, false)
        }
      Some(@core.Fullscreen::Borderless(target_monitor)) => {
        if window_is_exclusive_fullscreen(raw_id) {
          ignore(
            set_window_exclusive_fullscreen(
              raw_id,
              (0 : Int).to_uint64(),
              0,
              0,
              0,
              0,
            ),
          )
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
        if window_fullscreen(raw_id) && !window_is_exclusive_fullscreen(raw_id) {
          set_window_fullscreen(raw_id, false)
        }
        let mode_size = video_mode.surface_size()
        ignore(
          set_window_exclusive_fullscreen(
            raw_id,
            target_monitor.native_id(),
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
          ),
        )
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
  let raw_id = self.id.into_raw()
  if window_is_exclusive_fullscreen(raw_id) {
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
  window_fullscreen(self.id.into_raw())
}
