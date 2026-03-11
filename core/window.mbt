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
  Number
  Phone
  Url
  Email
  Pin
  Date
  Time
  DateTime
} derive(Eq, Show)

///|
pub struct ImeHint {
  priv bits : Int
} derive(Eq, Show)

///|
pub fn ImeHint::none() -> ImeHint {
  { bits: 0 }
}

///|
pub fn ImeHint::completion() -> ImeHint {
  { bits: 1 }
}

///|
pub fn ImeHint::spellcheck() -> ImeHint {
  { bits: 2 }
}

///|
pub fn ImeHint::auto_capitalization() -> ImeHint {
  { bits: 4 }
}

///|
pub fn ImeHint::lowercase() -> ImeHint {
  { bits: 8 }
}

///|
pub fn ImeHint::uppercase() -> ImeHint {
  { bits: 16 }
}

///|
pub fn ImeHint::titlecase() -> ImeHint {
  { bits: 32 }
}

///|
pub fn ImeHint::hidden_text() -> ImeHint {
  { bits: 64 }
}

///|
pub fn ImeHint::sensitive_data() -> ImeHint {
  { bits: 128 }
}

///|
pub fn ImeHint::latin() -> ImeHint {
  { bits: 256 }
}

///|
pub fn ImeHint::multiline() -> ImeHint {
  { bits: 512 }
}

///|
pub fn ImeHint::union(self : ImeHint, other : ImeHint) -> ImeHint {
  { bits: self.bits | other.bits }
}

///|
pub fn ImeHint::contains(self : ImeHint, other : ImeHint) -> Bool {
  (self.bits & other.bits) == other.bits
}

///|
pub fn ImeHint::from_bits(bits : Int) -> ImeHint {
  { bits: bits & 1023 }
}

///|
pub fn ImeHint::bits(self : ImeHint) -> Int {
  self.bits
}

///|
pub(all) suberror ImeSurroundingTextError {
  TextTooLong
  CursorBadPosition
  AnchorBadPosition
} derive(Show)

///|
pub struct ImeSurroundingText {
  priv anchor : Int
  priv cursor : Int
  priv text : String
} derive(Eq, Show)

///|
pub fn ImeSurroundingText::new(
  text : String,
  cursor : Int,
  anchor : Int,
) -> ImeSurroundingText raise ImeSurroundingTextError {
  let utf8_bytes = @utf8.encode(text[:], bom=false)
  let byte_len = utf8_bytes.length()
  if byte_len > 4000 {
    raise ImeSurroundingTextError::TextTooLong
  }
  if cursor < 0 || cursor > byte_len {
    raise ImeSurroundingTextError::CursorBadPosition
  }
  if anchor < 0 || anchor > byte_len {
    raise ImeSurroundingTextError::AnchorBadPosition
  }
  let _ = @utf8.decode(utf8_bytes[:cursor], ignore_bom=false) catch {
    _ => raise ImeSurroundingTextError::CursorBadPosition
  }
  let _ = @utf8.decode(utf8_bytes[:anchor], ignore_bom=false) catch {
    _ => raise ImeSurroundingTextError::AnchorBadPosition
  }
  { text, cursor, anchor }
}

///|
pub fn ImeSurroundingText::text(self : ImeSurroundingText) -> String {
  self.text
}

///|
pub fn ImeSurroundingText::cursor(self : ImeSurroundingText) -> Int {
  self.cursor
}

///|
pub fn ImeSurroundingText::anchor(self : ImeSurroundingText) -> Int {
  self.anchor
}

///|
pub struct ImeCapabilities {
  priv mut cursor_area : Bool
  priv mut hint_and_purpose : Bool
  priv mut surrounding_text : Bool
} derive(Eq, Show)

///|
pub fn ImeCapabilities::new(
  hint_and_purpose : Bool,
  cursor_area : Bool,
  surrounding_text : Bool,
) -> ImeCapabilities {
  { hint_and_purpose, cursor_area, surrounding_text }
}

///|
pub fn ImeCapabilities::hint_and_purpose(self : ImeCapabilities) -> Bool {
  self.hint_and_purpose
}

///|
pub fn ImeCapabilities::cursor_area(self : ImeCapabilities) -> Bool {
  self.cursor_area
}

///|
pub fn ImeCapabilities::surrounding_text(self : ImeCapabilities) -> Bool {
  self.surrounding_text
}

///|
pub(all) enum ImeRequest {
  Enable(ImeEnableRequest)
  Update(ImeRequestData)
  Disable
} derive(Eq, Show)

///|
pub(all) suberror ImeRequestError {
  NotEnabled
  AlreadyEnabled
  NotSupported
} derive(Show)

///|
pub(all) suberror RequestError {
  NotSupported
  Ignored
  Os
} derive(Show)

///|
pub struct ActivationToken {
  priv token : String
} derive(Eq, Show)

///|
pub fn ActivationToken::from_raw(token : String) -> ActivationToken {
  { token, }
}

///|
pub fn ActivationToken::into_raw(self : ActivationToken) -> String {
  self.token
}

///|
pub fn ActivationToken::as_raw(self : ActivationToken) -> String {
  self.token
}

///|
pub(all) enum WindowLevel {
  Normal
  AlwaysOnTop
  AlwaysOnBottom
} derive(Eq, Show)

///|
pub(all) enum CursorGrabMode {
  None
  Locked
  Confined
} derive(Eq, Show)

///|
pub(all) enum ResizeDirection {
  East
  North
  NorthEast
  NorthWest
  South
  SouthEast
  SouthWest
  West
} derive(Eq, Show)

///|
pub(all) enum UserAttentionType {
  Critical
  Informational
} derive(Eq, Show)

///|
pub(all) enum CursorIcon {
  Default
  ContextMenu
  Help
  Progress
  Wait
  Cell
  VerticalText
  Alias
  Copy
  NoDrop
  Grab
  Grabbing
  EResize
  NResize
  NeResize
  NwResize
  SResize
  SeResize
  SwResize
  WResize
  EwResize
  NsResize
  NeswResize
  NwseResize
  ColResize
  RowResize
  AllScroll
  ZoomIn
  ZoomOut
  Pointer
  Text
  Crosshair
  Move
  NotAllowed
} derive(Eq, Show)

///|
pub struct CustomCursor {
  priv raw : UInt64
} derive(Eq, Show)

///|
pub fn CustomCursor::from_raw(raw : UInt64) -> CustomCursor {
  { raw, }
}

///|
pub fn CustomCursor::into_raw(self : CustomCursor) -> UInt64 {
  self.raw
}

///|
pub(all) enum Cursor {
  Icon(CursorIcon)
  Custom(CustomCursor)
} derive(Eq, Show)

///|
pub(all) enum CustomCursorSource {
  Rgba(Bytes, Int, Int, Int, Int)
  Url(String, Int, Int)
  Animation(Int, Array[CustomCursor])
} derive(Eq, Show)

///|
pub(all) suberror BadCustomCursorSource {
  TooLarge(Int, Int)
  ByteCountNotDivisibleBy4(Int)
  DimensionsVsPixelCount(Int, Int, Int, Int)
  HotspotOutOfBounds(Int, Int, Int, Int)
} derive(Show)

///|
pub(all) suberror BadCustomCursorAnimation {
  Empty
  NonPositiveFrameDuration(Int)
} derive(Show)

///|
pub fn CustomCursorSource::from_rgba(
  rgba : Bytes,
  width : Int,
  height : Int,
  hotspot_x : Int,
  hotspot_y : Int,
) -> CustomCursorSource raise BadCustomCursorSource {
  if width <= 0 || height <= 0 {
    raise BadCustomCursorSource::DimensionsVsPixelCount(
      width,
      height,
      width * height,
      rgba.length() / 4,
    )
  }
  if width > 2048 || height > 2048 {
    raise BadCustomCursorSource::TooLarge(width, height)
  }
  if rgba.length() % 4 != 0 {
    raise BadCustomCursorSource::ByteCountNotDivisibleBy4(rgba.length())
  }
  let pixel_count = rgba.length() / 4
  let width_x_height = width * height
  if pixel_count != width_x_height {
    raise BadCustomCursorSource::DimensionsVsPixelCount(
      width, height, width_x_height, pixel_count,
    )
  }
  if hotspot_x < 0 || hotspot_x >= width || hotspot_y < 0 || hotspot_y >= height {
    raise BadCustomCursorSource::HotspotOutOfBounds(
      width, height, hotspot_x, hotspot_y,
    )
  }
  CustomCursorSource::Rgba(rgba, width, height, hotspot_x, hotspot_y)
}

///|
pub fn CustomCursorSource::from_animation(
  frame_duration_millis : Int,
  cursors : Array[CustomCursor],
) -> CustomCursorSource raise BadCustomCursorAnimation {
  if frame_duration_millis <= 0 {
    raise BadCustomCursorAnimation::NonPositiveFrameDuration(
      frame_duration_millis,
    )
  }
  if cursors.length() == 0 {
    raise BadCustomCursorAnimation::Empty
  }
  CustomCursorSource::Animation(frame_duration_millis, cursors)
}

///|
pub(all) enum Fullscreen {
  Borderless(MonitorHandle?)
  Exclusive(MonitorHandle, VideoMode)
} derive(Eq, Show)

///|
pub(all) enum OptionAsAlt {
  OnlyLeft
  OnlyRight
  Both
  None
} derive(Eq, Show)

///|
pub fn OptionAsAlt::default() -> OptionAsAlt {
  OptionAsAlt::None
}

///|
pub struct PlatformWindowAttributes {
  priv mut accepts_first_mouse : Bool
  priv mut disallow_hidpi : Bool
  priv mut fullsize_content_view : Bool
  priv mut has_shadow : Bool
  priv mut movable_by_window_background : Bool
  priv mut borderless_game : Bool
  priv mut option_as_alt : OptionAsAlt
  priv mut tabbing_identifier : String?
  priv mut title_hidden : Bool
  priv mut titlebar_hidden : Bool
  priv mut titlebar_buttons_hidden : Bool
  priv mut titlebar_transparent : Bool
  priv mut unified_titlebar : Bool
  priv mut panel : Bool
} derive(Eq, Show)

///|
pub fn PlatformWindowAttributes::default() -> PlatformWindowAttributes {
  {
    accepts_first_mouse: true,
    disallow_hidpi: false,
    fullsize_content_view: false,
    has_shadow: true,
    movable_by_window_background: false,
    borderless_game: false,
    option_as_alt: OptionAsAlt::None,
    tabbing_identifier: None,
    title_hidden: false,
    titlebar_hidden: false,
    titlebar_buttons_hidden: false,
    titlebar_transparent: false,
    unified_titlebar: false,
    panel: false,
  }
}

///|
pub fn PlatformWindowAttributes::with_accepts_first_mouse(
  self : PlatformWindowAttributes,
  accepts_first_mouse : Bool,
) -> PlatformWindowAttributes {
  self.accepts_first_mouse = accepts_first_mouse
  self
}

///|
pub fn PlatformWindowAttributes::accepts_first_mouse(
  self : PlatformWindowAttributes,
) -> Bool {
  self.accepts_first_mouse
}

///|
pub fn PlatformWindowAttributes::with_disallow_hidpi(
  self : PlatformWindowAttributes,
  disallow_hidpi : Bool,
) -> PlatformWindowAttributes {
  self.disallow_hidpi = disallow_hidpi
  self
}

///|
pub fn PlatformWindowAttributes::disallow_hidpi(
  self : PlatformWindowAttributes,
) -> Bool {
  self.disallow_hidpi
}

///|
pub fn PlatformWindowAttributes::with_fullsize_content_view(
  self : PlatformWindowAttributes,
  fullsize_content_view : Bool,
) -> PlatformWindowAttributes {
  self.fullsize_content_view = fullsize_content_view
  self
}

///|
pub fn PlatformWindowAttributes::fullsize_content_view(
  self : PlatformWindowAttributes,
) -> Bool {
  self.fullsize_content_view
}

///|
pub fn PlatformWindowAttributes::with_has_shadow(
  self : PlatformWindowAttributes,
  has_shadow : Bool,
) -> PlatformWindowAttributes {
  self.has_shadow = has_shadow
  self
}

///|
pub fn PlatformWindowAttributes::has_shadow(
  self : PlatformWindowAttributes,
) -> Bool {
  self.has_shadow
}

///|
pub fn PlatformWindowAttributes::with_movable_by_window_background(
  self : PlatformWindowAttributes,
  movable_by_window_background : Bool,
) -> PlatformWindowAttributes {
  self.movable_by_window_background = movable_by_window_background
  self
}

///|
pub fn PlatformWindowAttributes::movable_by_window_background(
  self : PlatformWindowAttributes,
) -> Bool {
  self.movable_by_window_background
}

///|
pub fn PlatformWindowAttributes::with_borderless_game(
  self : PlatformWindowAttributes,
  borderless_game : Bool,
) -> PlatformWindowAttributes {
  self.borderless_game = borderless_game
  self
}

///|
pub fn PlatformWindowAttributes::borderless_game(
  self : PlatformWindowAttributes,
) -> Bool {
  self.borderless_game
}

///|
pub fn PlatformWindowAttributes::with_option_as_alt(
  self : PlatformWindowAttributes,
  option_as_alt : OptionAsAlt,
) -> PlatformWindowAttributes {
  self.option_as_alt = option_as_alt
  self
}

///|
pub fn PlatformWindowAttributes::option_as_alt(
  self : PlatformWindowAttributes,
) -> OptionAsAlt {
  self.option_as_alt
}

///|
pub fn PlatformWindowAttributes::with_tabbing_identifier(
  self : PlatformWindowAttributes,
  tabbing_identifier : String,
) -> PlatformWindowAttributes {
  self.tabbing_identifier = Some(tabbing_identifier)
  self
}

///|
pub fn PlatformWindowAttributes::tabbing_identifier(
  self : PlatformWindowAttributes,
) -> String? {
  self.tabbing_identifier
}

///|
pub fn PlatformWindowAttributes::with_title_hidden(
  self : PlatformWindowAttributes,
  title_hidden : Bool,
) -> PlatformWindowAttributes {
  self.title_hidden = title_hidden
  self
}

///|
pub fn PlatformWindowAttributes::title_hidden(
  self : PlatformWindowAttributes,
) -> Bool {
  self.title_hidden
}

///|
pub fn PlatformWindowAttributes::with_titlebar_hidden(
  self : PlatformWindowAttributes,
  titlebar_hidden : Bool,
) -> PlatformWindowAttributes {
  self.titlebar_hidden = titlebar_hidden
  self
}

///|
pub fn PlatformWindowAttributes::titlebar_hidden(
  self : PlatformWindowAttributes,
) -> Bool {
  self.titlebar_hidden
}

///|
pub fn PlatformWindowAttributes::with_titlebar_buttons_hidden(
  self : PlatformWindowAttributes,
  titlebar_buttons_hidden : Bool,
) -> PlatformWindowAttributes {
  self.titlebar_buttons_hidden = titlebar_buttons_hidden
  self
}

///|
pub fn PlatformWindowAttributes::titlebar_buttons_hidden(
  self : PlatformWindowAttributes,
) -> Bool {
  self.titlebar_buttons_hidden
}

///|
pub fn PlatformWindowAttributes::with_titlebar_transparent(
  self : PlatformWindowAttributes,
  titlebar_transparent : Bool,
) -> PlatformWindowAttributes {
  self.titlebar_transparent = titlebar_transparent
  self
}

///|
pub fn PlatformWindowAttributes::titlebar_transparent(
  self : PlatformWindowAttributes,
) -> Bool {
  self.titlebar_transparent
}

///|
pub fn PlatformWindowAttributes::with_unified_titlebar(
  self : PlatformWindowAttributes,
  unified_titlebar : Bool,
) -> PlatformWindowAttributes {
  self.unified_titlebar = unified_titlebar
  self
}

///|
pub fn PlatformWindowAttributes::unified_titlebar(
  self : PlatformWindowAttributes,
) -> Bool {
  self.unified_titlebar
}

///|
pub fn PlatformWindowAttributes::with_panel(
  self : PlatformWindowAttributes,
  panel : Bool,
) -> PlatformWindowAttributes {
  self.panel = panel
  self
}

///|
pub fn PlatformWindowAttributes::panel(self : PlatformWindowAttributes) -> Bool {
  self.panel
}

///|
pub(all) suberror BadIcon {
  ByteCountNotDivisibleBy4(Int)
  DimensionsVsPixelCount(Int, Int, Int, Int)
} derive(Show)

///|
pub struct Icon {
  priv height : Int
  priv rgba : Bytes
  priv width : Int
} derive(Eq, Show)

///|
pub fn Icon::new(rgba : Bytes, width : Int, height : Int) -> Icon raise BadIcon {
  if rgba.length() % 4 != 0 {
    raise BadIcon::ByteCountNotDivisibleBy4(rgba.length())
  }
  let pixel_count = rgba.length() / 4
  let width_x_height = width * height
  if width <= 0 || height <= 0 || pixel_count != width_x_height {
    raise BadIcon::DimensionsVsPixelCount(
      width, height, width_x_height, pixel_count,
    )
  } else {
    { width, height, rgba }
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
pub struct ParentWindow {
  priv raw : UInt64
} derive(Eq, Show)

///|
pub fn ParentWindow::from_raw(raw : UInt64) -> ParentWindow {
  { raw, }
}

///|
pub fn ParentWindow::into_raw(self : ParentWindow) -> UInt64 {
  self.raw
}

///|
pub struct WindowAttributes {
  priv mut active : Bool
  priv mut blur : Bool
  priv mut content_protected : Bool
  priv mut cursor : Cursor
  priv mut cursor_hittest : Bool
  priv mut cursor_visible : Bool
  priv mut decorations : Bool
  priv mut enabled_buttons : WindowButtons
  priv mut fullscreen : Fullscreen?
  priv mut ime_hints : ImeHint
  priv mut ime_purpose : ImePurpose
  priv mut max_surface_size : @dpi.Size?
  priv mut maximized : Bool
  priv mut min_surface_size : @dpi.Size?
  priv mut parent_window : ParentWindow?
  priv mut platform_attributes : PlatformWindowAttributes
  priv mut position : @dpi.Position?
  priv mut surface_size : @dpi.Size?
  priv mut surface_resize_increments : @dpi.Size?
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
    cursor: Cursor::Icon(CursorIcon::Default),
    cursor_hittest: true,
    cursor_visible: true,
    decorations: true,
    enabled_buttons: WindowButtons::all(),
    fullscreen: None,
    ime_hints: ImeHint::none(),
    ime_purpose: ImePurpose::Normal,
    maximized: false,
    min_surface_size: None,
    max_surface_size: None,
    parent_window: None,
    platform_attributes: PlatformWindowAttributes::default(),
    position: None,
    surface_size: None,
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
  size : @dpi.Size,
) -> WindowAttributes {
  self.surface_size = Some(size)
  self
}

///|
pub fn WindowAttributes::with_inner_size(
  self : WindowAttributes,
  size : @dpi.Size,
) -> WindowAttributes {
  self.with_surface_size(size)
}

///|
pub fn WindowAttributes::with_surface_resize_increments(
  self : WindowAttributes,
  size : @dpi.Size,
) -> WindowAttributes {
  self.surface_resize_increments = Some(size)
  self
}

///|
pub fn WindowAttributes::with_resize_increments(
  self : WindowAttributes,
  size : @dpi.Size,
) -> WindowAttributes {
  self.with_surface_resize_increments(size)
}

///|
pub fn WindowAttributes::with_min_surface_size(
  self : WindowAttributes,
  size : @dpi.Size,
) -> WindowAttributes {
  self.min_surface_size = Some(size)
  self
}

///|
pub fn WindowAttributes::with_min_inner_size(
  self : WindowAttributes,
  size : @dpi.Size,
) -> WindowAttributes {
  self.with_min_surface_size(size)
}

///|
pub fn WindowAttributes::with_max_surface_size(
  self : WindowAttributes,
  size : @dpi.Size,
) -> WindowAttributes {
  self.max_surface_size = Some(size)
  self
}

///|
pub fn WindowAttributes::with_max_inner_size(
  self : WindowAttributes,
  size : @dpi.Size,
) -> WindowAttributes {
  self.with_max_surface_size(size)
}

///|
pub fn WindowAttributes::with_position(
  self : WindowAttributes,
  position : @dpi.Position,
) -> WindowAttributes {
  self.position = Some(position)
  self
}

///|
pub fn WindowAttributes::with_parent_window(
  self : WindowAttributes,
  parent_window : ParentWindow?,
) -> WindowAttributes {
  self.parent_window = parent_window
  self
}

///|
pub fn WindowAttributes::with_platform_attributes(
  self : WindowAttributes,
  platform_attributes : PlatformWindowAttributes,
) -> WindowAttributes {
  self.platform_attributes = platform_attributes
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
pub fn WindowAttributes::with_ime_hints(
  self : WindowAttributes,
  hints : ImeHint,
) -> WindowAttributes {
  self.ime_hints = hints
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
  cursor : Cursor,
) -> WindowAttributes {
  self.cursor = cursor
  self
}

///|
pub fn WindowAttributes::with_cursor_icon(
  self : WindowAttributes,
  cursor : CursorIcon,
) -> WindowAttributes {
  self.with_cursor(Cursor::Icon(cursor))
}

///|
pub fn WindowAttributes::with_cursor_visible(
  self : WindowAttributes,
  cursor_visible : Bool,
) -> WindowAttributes {
  self.cursor_visible = cursor_visible
  self
}

///|
pub fn WindowAttributes::with_cursor_hittest(
  self : WindowAttributes,
  cursor_hittest : Bool,
) -> WindowAttributes {
  self.cursor_hittest = cursor_hittest
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
  fullscreen : Fullscreen?,
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
pub fn WindowAttributes::surface_size(self : WindowAttributes) -> @dpi.Size? {
  self.surface_size
}

///|
pub fn WindowAttributes::inner_size(self : WindowAttributes) -> @dpi.Size? {
  self.surface_size()
}

///|
pub fn WindowAttributes::surface_resize_increments(
  self : WindowAttributes,
) -> @dpi.Size? {
  self.surface_resize_increments
}

///|
pub fn WindowAttributes::resize_increments(
  self : WindowAttributes,
) -> @dpi.Size? {
  self.surface_resize_increments()
}

///|
pub fn WindowAttributes::min_surface_size(
  self : WindowAttributes,
) -> @dpi.Size? {
  self.min_surface_size
}

///|
pub fn WindowAttributes::min_inner_size(self : WindowAttributes) -> @dpi.Size? {
  self.min_surface_size()
}

///|
pub fn WindowAttributes::max_surface_size(
  self : WindowAttributes,
) -> @dpi.Size? {
  self.max_surface_size
}

///|
pub fn WindowAttributes::max_inner_size(self : WindowAttributes) -> @dpi.Size? {
  self.max_surface_size()
}

///|
pub fn WindowAttributes::position(self : WindowAttributes) -> @dpi.Position? {
  self.position
}

///|
pub fn WindowAttributes::parent_window(
  self : WindowAttributes,
) -> ParentWindow? {
  self.parent_window
}

///|
pub fn WindowAttributes::platform_attributes(
  self : WindowAttributes,
) -> PlatformWindowAttributes {
  self.platform_attributes
}

///|
pub fn WindowAttributes::ime_purpose(self : WindowAttributes) -> ImePurpose {
  self.ime_purpose
}

///|
pub fn WindowAttributes::ime_hints(self : WindowAttributes) -> ImeHint {
  self.ime_hints
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
pub fn WindowAttributes::cursor(self : WindowAttributes) -> Cursor {
  self.cursor
}

///|
pub fn WindowAttributes::cursor_visible(self : WindowAttributes) -> Bool {
  self.cursor_visible
}

///|
pub fn WindowAttributes::cursor_hittest(self : WindowAttributes) -> Bool {
  self.cursor_hittest
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
pub fn WindowAttributes::fullscreen(self : WindowAttributes) -> Fullscreen? {
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
