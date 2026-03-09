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
  priv mut decorations : Bool
  priv mut ime_purpose : ImePurpose
  priv mut max_surface_size : @dpi.PhysicalSize?
  priv mut maximized : Bool
  priv mut min_surface_size : @dpi.PhysicalSize?
  priv mut position : @dpi.PhysicalPosition?
  priv mut surface_size : @dpi.PhysicalSize?
  priv mut resizable : Bool
  priv mut title : String
  priv mut visible : Bool
  priv mut window_level : WindowLevel
} derive(Eq, Show)

///|
pub fn WindowAttributes::default() -> WindowAttributes {
  {
    active: true,
    decorations: true,
    ime_purpose: ImePurpose::Normal,
    maximized: false,
    min_surface_size: None,
    max_surface_size: None,
    position: None,
    surface_size: Some(@dpi.PhysicalSize::new(800, 600)),
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
pub fn WindowAttributes::with_decorations(
  self : WindowAttributes,
  decorations : Bool,
) -> WindowAttributes {
  self.decorations = decorations
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
pub fn WindowAttributes::with_maximized(
  self : WindowAttributes,
  maximized : Bool,
) -> WindowAttributes {
  self.maximized = maximized
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
pub fn WindowAttributes::decorations(self : WindowAttributes) -> Bool {
  self.decorations
}

///|
pub fn WindowAttributes::window_level(self : WindowAttributes) -> WindowLevel {
  self.window_level
}

///|
pub fn WindowAttributes::maximized(self : WindowAttributes) -> Bool {
  self.maximized
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
