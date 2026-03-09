///|
pub(all) enum Theme {
  Light
  Dark
} derive(Eq, Show)

///|
pub(all) enum ImePurpose {
  Normal
  Password
  Terminal
} derive(Eq, Show)

///|
pub(all) enum WindowLevel {
  Normal
  AlwaysOnTop
  AlwaysOnBottom
} derive(Eq, Show)

///|
pub(all) enum CursorIcon {
  Default
  Pointer
  Text
  Crosshair
  Move
  NotAllowed
} derive(Eq, Show)

///|
pub(all) enum BadIcon {
  ByteCountNotDivisibleBy4(Int)
  DimensionsVsPixelCount(Int, Int, Int, Int)
} derive(Eq, Show)

///|
pub struct Icon {
  priv height : Int
  priv rgba : Bytes
  priv width : Int
} derive(Eq, Show)

///|
pub fn Icon::new(
  rgba : Bytes,
  width : Int,
  height : Int,
) -> Result[Icon, BadIcon] {
  if rgba.length() % 4 != 0 {
    return Err(BadIcon::ByteCountNotDivisibleBy4(rgba.length()))
  }
  let pixel_count = rgba.length() / 4
  let width_x_height = width * height
  if width <= 0 || height <= 0 || pixel_count != width_x_height {
    Err(
      BadIcon::DimensionsVsPixelCount(
        width, height, width_x_height, pixel_count,
      ),
    )
  } else {
    Ok({ width, height, rgba })
  }
}

///|
pub fn Icon::width(self : Icon) -> Int {
  self.width
}

///|
pub fn Icon::height(self : Icon) -> Int {
  self.height
}

///|
pub fn Icon::rgba(self : Icon) -> Bytes {
  self.rgba
}

///|
pub struct WindowButtons {
  priv mut close : Bool
  priv mut maximize : Bool
  priv mut minimize : Bool
} derive(Eq, Show)

///|
pub fn WindowButtons::all() -> WindowButtons {
  { close: true, maximize: true, minimize: true }
}

///|
pub fn WindowButtons::none() -> WindowButtons {
  { close: false, maximize: false, minimize: false }
}

///|
pub fn WindowButtons::with_close(
  self : WindowButtons,
  enabled : Bool,
) -> WindowButtons {
  self.close = enabled
  self
}

///|
pub fn WindowButtons::with_maximize(
  self : WindowButtons,
  enabled : Bool,
) -> WindowButtons {
  self.maximize = enabled
  self
}

///|
pub fn WindowButtons::with_minimize(
  self : WindowButtons,
  enabled : Bool,
) -> WindowButtons {
  self.minimize = enabled
  self
}

///|
pub fn WindowButtons::close(self : WindowButtons) -> Bool {
  self.close
}

///|
pub fn WindowButtons::maximize(self : WindowButtons) -> Bool {
  self.maximize
}

///|
pub fn WindowButtons::minimize(self : WindowButtons) -> Bool {
  self.minimize
}

///|
pub struct WindowId {
  priv raw : Int
} derive(Eq, Show)

///|
pub fn WindowId::from_raw(raw : Int) -> WindowId {
  { raw, }
}

///|
pub fn WindowId::into_raw(self : WindowId) -> Int {
  self.raw
}

///|
pub struct WindowAttributes {
  priv mut active : Bool
  priv mut blur : Bool
  priv mut content_protected : Bool
  priv mut cursor : CursorIcon
  priv mut decorations : Bool
  priv mut enabled_buttons : WindowButtons
  priv mut fullscreen : Bool
  priv mut ime_purpose : ImePurpose
  priv mut max_surface_size : @dpi.PhysicalSize?
  priv mut maximized : Bool
  priv mut min_surface_size : @dpi.PhysicalSize?
  priv mut position : @dpi.PhysicalPosition?
  priv mut surface_size : @dpi.PhysicalSize?
  priv mut surface_resize_increments : @dpi.PhysicalSize?
  priv mut theme : Theme?
  priv mut window_icon : Icon?
  priv mut transparent : Bool
  priv mut resizable : Bool
  priv mut title : String
  priv mut visible : Bool
  priv mut window_level : WindowLevel
} derive(Eq, Show)

///|
pub fn WindowAttributes::default() -> WindowAttributes {
  {
    active: true,
    blur: false,
    content_protected: false,
    cursor: CursorIcon::Default,
    decorations: true,
    enabled_buttons: WindowButtons::all(),
    fullscreen: false,
    ime_purpose: ImePurpose::Normal,
    maximized: false,
    min_surface_size: None,
    max_surface_size: None,
    position: None,
    surface_size: Some(@dpi.PhysicalSize::new(800, 600)),
    surface_resize_increments: None,
    theme: None,
    window_icon: None,
    transparent: false,
    resizable: true,
    title: "winit window",
    visible: true,
    window_level: WindowLevel::Normal,
  }
}

///|
pub fn WindowAttributes::with_surface_size(
  self : WindowAttributes,
  size : @dpi.PhysicalSize,
) -> WindowAttributes {
  self.surface_size = Some(size)
  self
}

///|
pub fn WindowAttributes::with_surface_resize_increments(
  self : WindowAttributes,
  size : @dpi.PhysicalSize?,
) -> WindowAttributes {
  self.surface_resize_increments = size
  self
}

///|
pub fn WindowAttributes::with_min_surface_size(
  self : WindowAttributes,
  size : @dpi.PhysicalSize?,
) -> WindowAttributes {
  self.min_surface_size = size
  self
}

///|
pub fn WindowAttributes::with_max_surface_size(
  self : WindowAttributes,
  size : @dpi.PhysicalSize?,
) -> WindowAttributes {
  self.max_surface_size = size
  self
}

///|
pub fn WindowAttributes::with_position(
  self : WindowAttributes,
  position : @dpi.PhysicalPosition?,
) -> WindowAttributes {
  self.position = position
  self
}

///|
pub fn WindowAttributes::with_ime_purpose(
  self : WindowAttributes,
  purpose : ImePurpose,
) -> WindowAttributes {
  self.ime_purpose = purpose
  self
}

///|
pub fn WindowAttributes::with_active(
  self : WindowAttributes,
  active : Bool,
) -> WindowAttributes {
  self.active = active
  self
}

///|
pub fn WindowAttributes::with_blur(
  self : WindowAttributes,
  blur : Bool,
) -> WindowAttributes {
  self.blur = blur
  self
}

///|
pub fn WindowAttributes::with_cursor(
  self : WindowAttributes,
  cursor : CursorIcon,
) -> WindowAttributes {
  self.cursor = cursor
  self
}

///|
pub fn WindowAttributes::with_decorations(
  self : WindowAttributes,
  decorations : Bool,
) -> WindowAttributes {
  self.decorations = decorations
  self
}

///|
pub fn WindowAttributes::with_content_protected(
  self : WindowAttributes,
  content_protected : Bool,
) -> WindowAttributes {
  self.content_protected = content_protected
  self
}

///|
pub fn WindowAttributes::with_enabled_buttons(
  self : WindowAttributes,
  buttons : WindowButtons,
) -> WindowAttributes {
  self.enabled_buttons = buttons
  self
}

///|
pub fn WindowAttributes::with_fullscreen(
  self : WindowAttributes,
  fullscreen : Bool,
) -> WindowAttributes {
  self.fullscreen = fullscreen
  self
}

///|
pub fn WindowAttributes::with_window_level(
  self : WindowAttributes,
  level : WindowLevel,
) -> WindowAttributes {
  self.window_level = level
  self
}

///|
pub fn WindowAttributes::with_theme(
  self : WindowAttributes,
  theme : Theme?,
) -> WindowAttributes {
  self.theme = theme
  self
}

///|
pub fn WindowAttributes::with_window_icon(
  self : WindowAttributes,
  window_icon : Icon?,
) -> WindowAttributes {
  self.window_icon = window_icon
  self
}

///|
pub fn WindowAttributes::with_maximized(
  self : WindowAttributes,
  maximized : Bool,
) -> WindowAttributes {
  self.maximized = maximized
  self
}

///|
pub fn WindowAttributes::with_transparent(
  self : WindowAttributes,
  transparent : Bool,
) -> WindowAttributes {
  self.transparent = transparent
  self
}

///|
pub fn WindowAttributes::with_title(
  self : WindowAttributes,
  title : String,
) -> WindowAttributes {
  self.title = title
  self
}

///|
pub fn WindowAttributes::with_visible(
  self : WindowAttributes,
  visible : Bool,
) -> WindowAttributes {
  self.visible = visible
  self
}

///|
pub fn WindowAttributes::with_resizable(
  self : WindowAttributes,
  resizable : Bool,
) -> WindowAttributes {
  self.resizable = resizable
  self
}

///|
pub fn WindowAttributes::surface_size(
  self : WindowAttributes,
) -> @dpi.PhysicalSize? {
  self.surface_size
}

///|
pub fn WindowAttributes::surface_resize_increments(
  self : WindowAttributes,
) -> @dpi.PhysicalSize? {
  self.surface_resize_increments
}

///|
pub fn WindowAttributes::min_surface_size(
  self : WindowAttributes,
) -> @dpi.PhysicalSize? {
  self.min_surface_size
}

///|
pub fn WindowAttributes::max_surface_size(
  self : WindowAttributes,
) -> @dpi.PhysicalSize? {
  self.max_surface_size
}

///|
pub fn WindowAttributes::position(
  self : WindowAttributes,
) -> @dpi.PhysicalPosition? {
  self.position
}

///|
pub fn WindowAttributes::ime_purpose(self : WindowAttributes) -> ImePurpose {
  self.ime_purpose
}

///|
pub fn WindowAttributes::active(self : WindowAttributes) -> Bool {
  self.active
}

///|
pub fn WindowAttributes::blur(self : WindowAttributes) -> Bool {
  self.blur
}

///|
pub fn WindowAttributes::cursor(self : WindowAttributes) -> CursorIcon {
  self.cursor
}

///|
pub fn WindowAttributes::decorations(self : WindowAttributes) -> Bool {
  self.decorations
}

///|
pub fn WindowAttributes::content_protected(self : WindowAttributes) -> Bool {
  self.content_protected
}

///|
pub fn WindowAttributes::enabled_buttons(
  self : WindowAttributes,
) -> WindowButtons {
  self.enabled_buttons
}

///|
pub fn WindowAttributes::fullscreen(self : WindowAttributes) -> Bool {
  self.fullscreen
}

///|
pub fn WindowAttributes::window_level(self : WindowAttributes) -> WindowLevel {
  self.window_level
}

///|
pub fn WindowAttributes::theme(self : WindowAttributes) -> Theme? {
  self.theme
}

///|
pub fn WindowAttributes::window_icon(self : WindowAttributes) -> Icon? {
  self.window_icon
}

///|
pub fn WindowAttributes::maximized(self : WindowAttributes) -> Bool {
  self.maximized
}

///|
pub fn WindowAttributes::transparent(self : WindowAttributes) -> Bool {
  self.transparent
}

///|
pub fn WindowAttributes::title(self : WindowAttributes) -> String {
  self.title
}

///|
pub fn WindowAttributes::visible(self : WindowAttributes) -> Bool {
  self.visible
}

///|
pub fn WindowAttributes::resizable(self : WindowAttributes) -> Bool {
  self.resizable
}
