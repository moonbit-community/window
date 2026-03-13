///|
// Port target: winit-reference/winit-appkit/src/window.rs

///|
pub struct Window {
  priv id : @core.WindowId
  priv raw_window_handle : UInt64
  priv mut visible_state : Bool
  priv mut resizable_state : Bool
  priv mut decorated_state : Bool
  priv mut enabled_buttons_state : @core.WindowButtons
  priv mut window_level_state : @core.WindowLevel
  priv mut cursor_state : @core.Cursor
  priv mut fullscreen_state : @core.Fullscreen?
  priv mut ime_capabilities_state : @core.ImeCapabilities?
  priv mut ime_cursor_area_position_state : @dpi.PhysicalPosition
  priv mut ime_cursor_area_size_state : @dpi.PhysicalSize
  priv mut ime_surrounding_text_state : @core.ImeSurroundingText?
  priv mut content_protected_state : Bool
  priv mut blur_state : Bool
  priv mut has_shadow_state : Bool
  priv mut document_edited_state : Bool
  priv mut option_as_alt_state : @core.OptionAsAlt
  priv mut borderless_game_state : Bool
  priv mut unified_titlebar_state : Bool
  priv mut cursor_visible_state : Bool
  priv mut cursor_hittest_state : Bool
  priv mut transparent_state : Bool
  priv mut ime_allowed_state : Bool
  priv mut ime_purpose_state : @core.ImePurpose
  priv mut ime_hints_state : @core.ImeHint
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
  self.raw_window_handle
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
  unregister_window_handle(self.id.into_raw())
  mark_window_destroyed(self.id.into_raw())
}
