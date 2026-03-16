///|
// Port target: winit-reference/winit/examples/application.rs
enum Action {
  CloseWindow
  PrintHelp
  CreateNewWindow
  ToggleResizeIncrements
  ToggleCursorVisibility
  ToggleResizable
  ToggleDecorations
  ToggleFullscreen
  ToggleSimpleFullscreen
  ToggleBorderlessGame
  ToggleMaximize
  Minimize
  NextCursor
  NextCustomCursor
  CycleCursorGrab
  DragWindow
  DragResizeWindow
  ShowWindowMenu
  RequestResize
  SetTheme(@core.Theme?)
  CreateNewTab
  CycleOptionAsAlt
  DumpMonitors
  Message
  ToggleAnimatedFillColor
  ToggleContinuousRedraw
  EmitSurfaceSize
} derive(Eq, Show)

///|
fn Action::help(self : Action) -> String {
  match self {
    Action::CloseWindow => "Close window"
    Action::PrintHelp => "Print help"
    Action::CreateNewWindow => "Create new window"
    Action::ToggleResizeIncrements =>
      "Use resize increments when resizing window"
    Action::ToggleCursorVisibility => "Hide cursor"
    Action::ToggleResizable => "Toggle window resizable state"
    Action::ToggleDecorations => "Toggle decorations"
    Action::ToggleFullscreen => "Toggle fullscreen"
    Action::ToggleSimpleFullscreen => "Toggle simple fullscreen"
    Action::ToggleBorderlessGame => "Toggle borderless game mode"
    Action::ToggleMaximize => "Maximize"
    Action::Minimize => "Minimize"
    Action::NextCursor => "Advance the cursor to the next value"
    Action::NextCustomCursor => "Advance custom cursor to the next value"
    Action::CycleCursorGrab => "Cycle through cursor grab mode"
    Action::DragWindow => "Start window drag"
    Action::DragResizeWindow => "Start window drag-resize"
    Action::ShowWindowMenu => "Show window menu"
    Action::RequestResize => "Request a resize"
    Action::SetTheme(None) => "Change to the system theme"
    Action::SetTheme(Some(@core.Theme::Light)) => "Change to a light theme"
    Action::SetTheme(Some(@core.Theme::Dark)) => "Change to a dark theme"
    Action::CreateNewTab => "Create new tab"
    Action::CycleOptionAsAlt => "Cycle option as alt mode"
    Action::DumpMonitors => "Dump monitor information"
    Action::Message => "Prints a message through a user wake up"
    Action::ToggleAnimatedFillColor => "Toggle animated fill color"
    Action::ToggleContinuousRedraw => "Toggle continuous redraw"
    Action::EmitSurfaceSize => "Periodically print the surface size"
  }
}

///|
priv struct KeyBinding {
  key : String
  control : Bool
  alt : Bool
  shift : Bool
  meta : Bool
  action : Action
}

///|
priv struct MouseBinding {
  button : @core.MouseButton
  control : Bool
  alt : Bool
  shift : Bool
  meta : Bool
  action : Action
}

///|
fn key_bindings() -> Array[KeyBinding] {
  [
    {
      key: "Q",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::CloseWindow,
    },
    {
      key: "H",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::PrintHelp,
    },
    {
      key: "F",
      control: false,
      alt: false,
      shift: true,
      meta: false,
      action: Action::ToggleAnimatedFillColor,
    },
    {
      key: "F",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::ToggleFullscreen,
    },
    {
      key: "F",
      control: false,
      alt: true,
      shift: false,
      meta: false,
      action: Action::ToggleSimpleFullscreen,
    },
    {
      key: "D",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::ToggleDecorations,
    },
    {
      key: "L",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::CycleCursorGrab,
    },
    {
      key: "P",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::ToggleResizeIncrements,
    },
    {
      key: "R",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::ToggleResizable,
    },
    {
      key: "R",
      control: false,
      alt: true,
      shift: false,
      meta: false,
      action: Action::RequestResize,
    },
    {
      key: "R",
      control: false,
      alt: false,
      shift: true,
      meta: false,
      action: Action::ToggleContinuousRedraw,
    },
    {
      key: "M",
      control: true,
      alt: true,
      shift: false,
      meta: false,
      action: Action::DumpMonitors,
    },
    {
      key: "M",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::ToggleMaximize,
    },
    {
      key: "M",
      control: false,
      alt: true,
      shift: false,
      meta: false,
      action: Action::Minimize,
    },
    {
      key: "N",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::CreateNewWindow,
    },
    {
      key: "C",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::NextCursor,
    },
    {
      key: "C",
      control: false,
      alt: true,
      shift: false,
      meta: false,
      action: Action::NextCustomCursor,
    },
    {
      key: "Z",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::ToggleCursorVisibility,
    },
    {
      key: "K",
      control: false,
      alt: false,
      shift: false,
      meta: false,
      action: Action::SetTheme(None),
    },
    {
      key: "K",
      control: false,
      alt: false,
      shift: false,
      meta: true,
      action: Action::SetTheme(Some(@core.Theme::Light)),
    },
    {
      key: "K",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::SetTheme(Some(@core.Theme::Dark)),
    },
    {
      key: "T",
      control: false,
      alt: false,
      shift: false,
      meta: true,
      action: Action::CreateNewTab,
    },
    {
      key: "O",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::CycleOptionAsAlt,
    },
    {
      key: "B",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::ToggleBorderlessGame,
    },
    {
      key: "S",
      control: false,
      alt: true,
      shift: false,
      meta: false,
      action: Action::EmitSurfaceSize,
    },
    {
      key: "S",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::Message,
    },
  ]
}

///|
fn mouse_bindings() -> Array[MouseBinding] {
  [
    {
      button: @core.MouseButton::Left,
      control: false,
      alt: true,
      shift: false,
      meta: false,
      action: Action::DragResizeWindow,
    },
    {
      button: @core.MouseButton::Left,
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::DragWindow,
    },
    {
      button: @core.MouseButton::Right,
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Action::ShowWindowMenu,
    },
  ]
}

///|
struct Application {
  windows : Array[@macos.Window]
  window_input_states : Array[WindowInputState]
  mut proxy : @macos.EventLoopProxy?
  proxy_actions : Array[Action]
  custom_cursors : Array[@core.CustomCursor]
  start_time_ms : Int64
  mut next_proxy_wake_ms : Int64
}

///|
struct WindowInputState {
  window_id : @core.WindowId
  mut modifiers : @core.ModifiersState
  mut theme : @core.Theme
  mut cursor_grab_mode : @core.CursorGrabMode
  mut cursor_index : Int
  mut custom_cursor_index : Int
  mut animated_fill_color : Bool
  mut continuous_redraw : Bool
  mut emit_surface_size : Bool
  mut occluded : Bool
  mut zoom : Double
  mut rotated : Double
  mut panned_x : Double
  mut panned_y : Double
}

///|
fn system_cursors() -> Array[@core.CursorIcon] {
  [
    @core.CursorIcon::Default,
    @core.CursorIcon::Crosshair,
    @core.CursorIcon::Pointer,
    @core.CursorIcon::Move,
    @core.CursorIcon::Text,
    @core.CursorIcon::Wait,
    @core.CursorIcon::Help,
    @core.CursorIcon::Progress,
    @core.CursorIcon::NotAllowed,
    @core.CursorIcon::ContextMenu,
    @core.CursorIcon::Cell,
    @core.CursorIcon::VerticalText,
    @core.CursorIcon::Alias,
    @core.CursorIcon::Copy,
    @core.CursorIcon::NoDrop,
    @core.CursorIcon::Grab,
    @core.CursorIcon::Grabbing,
    @core.CursorIcon::AllScroll,
    @core.CursorIcon::ZoomIn,
    @core.CursorIcon::ZoomOut,
    @core.CursorIcon::EResize,
    @core.CursorIcon::NResize,
    @core.CursorIcon::NeResize,
    @core.CursorIcon::NwResize,
    @core.CursorIcon::SResize,
    @core.CursorIcon::SeResize,
    @core.CursorIcon::SwResize,
    @core.CursorIcon::WResize,
    @core.CursorIcon::EwResize,
    @core.CursorIcon::NsResize,
    @core.CursorIcon::NeswResize,
    @core.CursorIcon::NwseResize,
    @core.CursorIcon::ColResize,
    @core.CursorIcon::RowResize,
  ]
}

///|
let border_size_points : Double = 20.0

///|
fn modifiers_match(
  modifiers : @core.ModifiersState,
  control : Bool,
  alt : Bool,
  shift : Bool,
  meta : Bool,
) -> Bool {
  modifiers.control_key() == control &&
  modifiers.alt_key() == alt &&
  modifiers.shift_key() == shift &&
  modifiers.meta_key() == meta
}

///|
fn modifiers_prefix(
  control : Bool,
  alt : Bool,
  shift : Bool,
  meta : Bool,
) -> String {
  let mut prefix = ""
  if meta {
    prefix = prefix + "Cmd+"
  }
  if alt {
    prefix = prefix + "Alt+"
  }
  if control {
    prefix = prefix + "Ctrl+"
  }
  if shift {
    prefix = prefix + "Shift+"
  }
  prefix
}

///|
fn mouse_button_name(button : @core.MouseButton) -> String {
  match button {
    @core.MouseButton::Left => "Left"
    @core.MouseButton::Right => "Right"
    @core.MouseButton::Middle => "Middle"
    @core.MouseButton::Back => "Back"
    @core.MouseButton::Forward => "Forward"
    @core.MouseButton::Button6 => "Button6"
    @core.MouseButton::Button7 => "Button7"
    @core.MouseButton::Button8 => "Button8"
    @core.MouseButton::Button9 => "Button9"
    @core.MouseButton::Button10 => "Button10"
    @core.MouseButton::Button11 => "Button11"
    @core.MouseButton::Button12 => "Button12"
    @core.MouseButton::Button13 => "Button13"
    @core.MouseButton::Button14 => "Button14"
    @core.MouseButton::Button15 => "Button15"
    @core.MouseButton::Button16 => "Button16"
    @core.MouseButton::Button17 => "Button17"
    @core.MouseButton::Button18 => "Button18"
    @core.MouseButton::Button19 => "Button19"
    @core.MouseButton::Button20 => "Button20"
    @core.MouseButton::Button21 => "Button21"
    @core.MouseButton::Button22 => "Button22"
    @core.MouseButton::Button23 => "Button23"
    @core.MouseButton::Button24 => "Button24"
    @core.MouseButton::Button25 => "Button25"
    @core.MouseButton::Button26 => "Button26"
    @core.MouseButton::Button27 => "Button27"
    @core.MouseButton::Button28 => "Button28"
    @core.MouseButton::Button29 => "Button29"
    @core.MouseButton::Button30 => "Button30"
    @core.MouseButton::Button31 => "Button31"
    @core.MouseButton::Button32 => "Button32"
  }
}

///|
fn make_custom_cursor_source(value : Int) -> @core.CustomCursorSource? {
  let rgba = Bytes::make(4, value.to_byte())
  Some(@core.CustomCursorSource::from_rgba(rgba, 1, 1, 0, 0)) catch {
    _ => None
  }
}

///|
fn fill_color_for_theme(theme : @core.Theme) -> Int {
  match theme {
    @core.Theme::Light => 0xffe8e8e8
    @core.Theme::Dark => 0xff525252
  }
}

///|
fn video_mode_bits_suffix(mode : @core.VideoMode) -> String {
  match mode.bit_depth() {
    Some(bits) => "x\{bits}"
    None => ""
  }
}

///|
fn video_mode_refresh_suffix(mode : @core.VideoMode) -> String {
  match mode.refresh_rate_millihertz() {
    Some(m_hz) => " @ \{m_hz / 1000}.\{m_hz % 1000} Hz"
    None => ""
  }
}

///|
fn print_video_mode(prefix : String, mode : @core.VideoMode) -> Unit {
  let surface_size = mode.surface_size()
  let bits = video_mode_bits_suffix(mode)
  let refresh = video_mode_refresh_suffix(mode)
  println(
    "\{prefix}\{surface_size.width()}x\{surface_size.height()}\{bits}\{refresh}",
  )
}

///|
fn Application::new() -> Application {
  let start_time_ms = @util.now_millis()
  {
    windows: [],
    window_input_states: [],
    proxy: None,
    proxy_actions: [],
    custom_cursors: [],
    start_time_ms,
    next_proxy_wake_ms: start_time_ms + (1000 : Int).to_int64(),
  }
}

///|
fn Application::print_help(_self : Application) -> Unit {
  println("Keyboard bindings:")
  for binding in key_bindings() {
    let prefix = modifiers_prefix(
      binding.control,
      binding.alt,
      binding.shift,
      binding.meta,
    )
    println("  \{prefix}\{binding.key} \{binding.action.help()}")
  }
  println("Mouse bindings:")
  for binding in mouse_bindings() {
    let prefix = modifiers_prefix(
      binding.control,
      binding.alt,
      binding.shift,
      binding.meta,
    )
    println(
      "  \{prefix}\{mouse_button_name(binding.button)} \{binding.action.help()}",
    )
  }
  println("  Esc Close window")
}

///|
fn Application::window_by_id(
  self : Application,
  window_id : @core.WindowId,
) -> @macos.Window? {
  match self.windows.search_by(window => window.id() == window_id) {
    Some(index) => Some(self.windows[index])
    None => None
  }
}

///|
fn Application::create_window(
  self : Application,
  event_loop : @macos.ActiveEventLoop,
  title : String,
  tabbing_identifier : String?,
) -> @core.WindowId? {
  let mut window_attributes = @core.WindowAttributes::default()
    .with_title(title)
    .with_transparent(true)
  match tabbing_identifier {
    Some(tab_id) => {
      let platform_attributes = @core.PlatformWindowAttributes::default().with_tabbing_identifier(
        tab_id,
      )
      window_attributes = window_attributes.with_platform_attributes(
        platform_attributes,
      )
    }
    None => ()
  }
  let window : @macos.Window = event_loop.try_create_window(window_attributes) catch {
    err => {
      println("Error creating new window: \{err}")
      return None
    }
  }
  let window_id = window.id()
  let initial_theme = match window.theme() {
    Some(theme) => theme
    None => @core.Theme::Dark
  }
  println("Theme: \{initial_theme}")
  self.windows.push(window)
  let initial_custom_cursor_index = if self.custom_cursors.is_empty() {
    0
  } else {
    self.custom_cursors.length() - 1
  }
  self.window_input_states.push({
    window_id,
    modifiers: @core.ModifiersState::none(),
    theme: initial_theme,
    cursor_grab_mode: @core.CursorGrabMode::None,
    cursor_index: 0,
    custom_cursor_index: initial_custom_cursor_index,
    animated_fill_color: false,
    continuous_redraw: false,
    emit_surface_size: false,
    occluded: false,
    zoom: 0.0,
    rotated: 0.0,
    panned_x: 0.0,
    panned_y: 0.0,
  })
  println("Created new window with id=\{window_id}")
  match self.window_by_id(window_id) {
    Some(created_window) => created_window.request_redraw()
    None => ()
  }
  Some(window_id)
}

///|
fn Application::load_custom_cursors(
  self : Application,
  event_loop : @macos.ActiveEventLoop,
) -> Unit {
  println("Loading cursor assets")
  self.custom_cursors.clear()
  for value in [255, 192, 128] {
    match make_custom_cursor_source(value) {
      Some(source) =>
        try {
          let cursor = event_loop.create_custom_cursor(source)
          self.custom_cursors.push(cursor)
        } catch {
          err => println("Custom cursor creation failed: \{err}")
        }
      None => ()
    }
  }
}

///|
fn Application::remove_window(
  self : Application,
  window_id : @core.WindowId,
) -> Unit {
  match self.windows.search_by(window => window.id() == window_id) {
    Some(index) => {
      let window = self.windows.remove(index)
      @util.cleanup_window(window)
    }
    None => ()
  }
  match
    self.window_input_states.search_by(entry => entry.window_id == window_id) {
    Some(index) => ignore(self.window_input_states.remove(index))
    None => ()
  }
}

///|
fn Application::ensure_window_input_state(
  self : Application,
  window_id : @core.WindowId,
) -> Int {
  match
    self.window_input_states.search_by(entry => entry.window_id == window_id) {
    Some(index) => index
    None => {
      let initial_custom_cursor_index = if self.custom_cursors.is_empty() {
        0
      } else {
        self.custom_cursors.length() - 1
      }
      let initial_theme = match self.window_by_id(window_id) {
        Some(window) =>
          match window.theme() {
            Some(theme) => theme
            None => @core.Theme::Dark
          }
        None => @core.Theme::Dark
      }
      self.window_input_states.push({
        window_id,
        modifiers: @core.ModifiersState::none(),
        theme: initial_theme,
        cursor_grab_mode: @core.CursorGrabMode::None,
        cursor_index: 0,
        custom_cursor_index: initial_custom_cursor_index,
        animated_fill_color: false,
        continuous_redraw: false,
        emit_surface_size: false,
        occluded: false,
        zoom: 0.0,
        rotated: 0.0,
        panned_x: 0.0,
        panned_y: 0.0,
      })
      self.window_input_states.length() - 1
    }
  }
}

///|
fn Application::modifiers_for_window(
  self : Application,
  window_id : @core.WindowId,
) -> @core.ModifiersState {
  match
    self.window_input_states.search_by(entry => entry.window_id == window_id) {
    Some(index) => self.window_input_states[index].modifiers
    None => @core.ModifiersState::none()
  }
}

///|
fn Application::set_window_modifiers(
  self : Application,
  window_id : @core.WindowId,
  modifiers : @core.ModifiersState,
) -> Unit {
  let index = self.ensure_window_input_state(window_id)
  self.window_input_states[index].modifiers = modifiers
}

///|
fn Application::action_from_key(
  self : Application,
  window_id : @core.WindowId,
  key_event : @core.KeyEvent,
) -> Action? {
  let modifiers = self.modifiers_for_window(window_id)
  let key = key_event.key_without_modifiers()
  match key {
    @core.Key::Named(@core.NamedKey::Escape) => Some(Action::CloseWindow)
    @core.Key::Character("q") | @core.Key::Character("Q") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::CloseWindow)
      } else {
        None
      }
    @core.Key::Character("h") | @core.Key::Character("H") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::PrintHelp)
      } else {
        None
      }
    @core.Key::Character("n") | @core.Key::Character("N") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::CreateNewWindow)
      } else {
        None
      }
    @core.Key::Character("f") | @core.Key::Character("F") =>
      if modifiers_match(modifiers, false, false, true, false) {
        Some(Action::ToggleAnimatedFillColor)
      } else if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::ToggleFullscreen)
      } else if modifiers_match(modifiers, false, true, false, false) {
        Some(Action::ToggleSimpleFullscreen)
      } else {
        None
      }
    @core.Key::Character("d") | @core.Key::Character("D") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::ToggleDecorations)
      } else {
        None
      }
    @core.Key::Character("l") | @core.Key::Character("L") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::CycleCursorGrab)
      } else {
        None
      }
    @core.Key::Character("p") | @core.Key::Character("P") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::ToggleResizeIncrements)
      } else {
        None
      }
    @core.Key::Character("r") | @core.Key::Character("R") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::ToggleResizable)
      } else if modifiers_match(modifiers, false, true, false, false) {
        Some(Action::RequestResize)
      } else if modifiers_match(modifiers, false, false, true, false) {
        Some(Action::ToggleContinuousRedraw)
      } else {
        None
      }
    @core.Key::Character("m") | @core.Key::Character("M") =>
      if modifiers_match(modifiers, true, true, false, false) {
        Some(Action::DumpMonitors)
      } else if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::ToggleMaximize)
      } else if modifiers_match(modifiers, false, true, false, false) {
        Some(Action::Minimize)
      } else {
        None
      }
    @core.Key::Character("c") | @core.Key::Character("C") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::NextCursor)
      } else if modifiers_match(modifiers, false, true, false, false) {
        Some(Action::NextCustomCursor)
      } else {
        None
      }
    @core.Key::Character("z") | @core.Key::Character("Z") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::ToggleCursorVisibility)
      } else {
        None
      }
    @core.Key::Character("k") | @core.Key::Character("K") =>
      if modifiers_match(modifiers, false, false, false, false) {
        Some(Action::SetTheme(None))
      } else if modifiers_match(modifiers, false, false, false, true) {
        Some(Action::SetTheme(Some(@core.Theme::Light)))
      } else if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::SetTheme(Some(@core.Theme::Dark)))
      } else {
        None
      }
    @core.Key::Character("t") | @core.Key::Character("T") =>
      if modifiers_match(modifiers, false, false, false, true) {
        Some(Action::CreateNewTab)
      } else {
        None
      }
    @core.Key::Character("o") | @core.Key::Character("O") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::CycleOptionAsAlt)
      } else {
        None
      }
    @core.Key::Character("b") | @core.Key::Character("B") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::ToggleBorderlessGame)
      } else {
        None
      }
    @core.Key::Character("s") | @core.Key::Character("S") =>
      if modifiers_match(modifiers, false, true, false, false) {
        Some(Action::EmitSurfaceSize)
      } else if modifiers_match(modifiers, true, false, false, false) {
        Some(Action::Message)
      } else {
        None
      }
    _ => None
  }
}

///|
fn Application::dump_monitors(
  _self : Application,
  event_loop : @macos.ActiveEventLoop,
) -> Unit {
  println("Monitors information")
  let monitors = event_loop.available_monitors()
  let primary_native_id = match event_loop.primary_monitor() {
    Some(primary_monitor) => Some(primary_monitor.native_id())
    None => None
  }
  for monitor in monitors {
    let intro = match primary_native_id {
      Some(primary_id) =>
        if primary_id == monitor.native_id() {
          "Primary monitor"
        } else {
          "Monitor"
        }
      None => "Monitor"
    }
    match monitor.name() {
      Some(name) => println("\{intro}: \{name}")
      None => println("\{intro}: [no name]")
    }
    match monitor.current_video_mode() {
      Some(current_mode) => print_video_mode("  ", current_mode)
      None => ()
    }
    let position = monitor.position()
    println("  Position: \{position.x()},\{position.y()}")
    println("  Scale factor: \{monitor.scale_factor()}")
    println("  Available modes (width x height x bit-depth):")
    for mode in monitor.video_modes() {
      print_video_mode("    ", mode)
    }
  }
}

///|
fn Application::perform_window_action(
  self : Application,
  event_loop : @macos.ActiveEventLoop,
  window_id : @core.WindowId,
  action : Action,
  window : @macos.Window,
) -> Unit {
  match action {
    Action::CloseWindow => self.remove_window(window_id)
    Action::ToggleCursorVisibility =>
      window.set_cursor_visible(!window.is_cursor_visible())
    Action::ToggleResizeIncrements =>
      if window.resize_increments() is None {
        println("Had increments: false")
        window.set_resize_increments(
          Some(@dpi.LogicalSize::new(25.0, 25.0).into_size()),
        )
      } else {
        println("Had increments: true")
        window.set_resize_increments(None)
      }
    Action::ToggleResizable => window.set_resizable(!window.is_resizable())
    Action::ToggleDecorations => window.set_decorations(!window.is_decorated())
    Action::ToggleFullscreen =>
      match window.fullscreen() {
        Some(_) => window.set_fullscreen(None)
        None => window.set_fullscreen(Some(@core.Fullscreen::Borderless(None)))
      }
    Action::ToggleSimpleFullscreen => {
      let _ = window.set_simple_fullscreen(!window.simple_fullscreen())
    }
    Action::ToggleBorderlessGame => {
      let next = !window.is_borderless_game()
      window.set_borderless_game(next)
      println("Borderless game: \{next}")
    }
    Action::ToggleMaximize => window.set_maximized(!window.is_maximized())
    Action::Minimize => window.set_minimized(true)
    Action::NextCursor => {
      let cursors = system_cursors()
      let state_index = self.ensure_window_input_state(window_id)
      let next_cursor_index = (
          self.window_input_states[state_index].cursor_index + 1
        ) %
        cursors.length()
      self.window_input_states[state_index].cursor_index = next_cursor_index
      println("Setting cursor to \{cursors[next_cursor_index]}")
      window.set_cursor_icon(cursors[next_cursor_index])
    }
    Action::NextCustomCursor =>
      if self.custom_cursors.is_empty() {
        println("No custom cursor available on this platform/runtime")
      } else {
        let state_index = self.ensure_window_input_state(window_id)
        let next_custom_cursor_index = (
            self.window_input_states[state_index].custom_cursor_index + 1
          ) %
          self.custom_cursors.length()
        self.window_input_states[state_index].custom_cursor_index = next_custom_cursor_index
        window.set_cursor(
          @core.Cursor::Custom(self.custom_cursors[next_custom_cursor_index]),
        )
      }
    Action::CycleCursorGrab => {
      let state_index = self.ensure_window_input_state(window_id)
      let next_mode = match
        self.window_input_states[state_index].cursor_grab_mode {
        @core.CursorGrabMode::None => @core.CursorGrabMode::Confined
        @core.CursorGrabMode::Confined => @core.CursorGrabMode::Locked
        @core.CursorGrabMode::Locked => @core.CursorGrabMode::None
      }
      println("Changing cursor grab mode to \{next_mode}")
      try {
        window.set_cursor_grab(next_mode)
        self.window_input_states[state_index].cursor_grab_mode = next_mode
      } catch {
        err => println("Cursor grab update failed: \{err}")
      }
    }
    Action::RequestResize => {
      let current = window.surface_size()
      let next_size = if current.width() < 700 {
        @dpi.LogicalSize::new(800.0, 600.0)
      } else {
        @dpi.LogicalSize::new(640.0, 480.0)
      }
      println("Requesting resize from \{current} to \{next_size}")
      ignore(window.request_surface_size(next_size.into_size()))
      println("Requesting surface size is asynchronous")
    }
    Action::SetTheme(theme) => {
      window.set_theme(theme)
      let state_index = self.ensure_window_input_state(window_id)
      let actual_theme = match theme {
        Some(theme) => theme
        None =>
          match window.theme() {
            Some(theme) => theme
            None => @core.Theme::Dark
          }
      }
      self.window_input_states[state_index].theme = actual_theme
    }
    Action::CreateNewTab => {
      let current_id = window.tabbing_identifier()
      let tab_id = if current_id.is_empty() {
        "moonbit-window-example-tabs"
      } else {
        current_id
      }
      self.create_window(event_loop, "Winit tab", Some(tab_id)) |> ignore
    }
    Action::CycleOptionAsAlt => {
      let next = match window.option_as_alt() {
        @core.OptionAsAlt::OnlyLeft => @core.OptionAsAlt::OnlyRight
        @core.OptionAsAlt::OnlyRight => @core.OptionAsAlt::Both
        @core.OptionAsAlt::Both => @core.OptionAsAlt::None
        @core.OptionAsAlt::None => @core.OptionAsAlt::OnlyLeft
      }
      window.set_option_as_alt(next)
      println("Setting option as alt \{next}")
    }
    Action::ToggleAnimatedFillColor => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].animated_fill_color = !self.window_input_states[state_index].animated_fill_color
      let enabled = self.window_input_states[state_index].animated_fill_color
      println("Animated fill on \{window_id}: \{enabled}")
    }
    Action::ToggleContinuousRedraw => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].continuous_redraw = !self.window_input_states[state_index].continuous_redraw
      let enabled = self.window_input_states[state_index].continuous_redraw
      println("Continuous redraw on \{window_id}: \{enabled}")
      if enabled {
        window.request_redraw()
      }
    }
    Action::EmitSurfaceSize => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].emit_surface_size = !self.window_input_states[state_index].emit_surface_size
      let enabled = self.window_input_states[state_index].emit_surface_size
      println("Emit surface size on \{window_id}: \{enabled}")
    }
    Action::CreateNewWindow
    | Action::PrintHelp
    | Action::DumpMonitors
    | Action::Message
    | Action::DragWindow
    | Action::DragResizeWindow
    | Action::ShowWindowMenu => ()
  }
}

///|
fn Application::execute_action(
  self : Application,
  event_loop : @macos.ActiveEventLoop,
  window_id : @core.WindowId,
  action : Action,
) -> Unit {
  println("Executing action: \{action}")
  match action {
    Action::CreateNewWindow =>
      self.create_window(event_loop, "Winit window", None) |> ignore
    Action::PrintHelp => self.print_help()
    Action::DumpMonitors => self.dump_monitors(event_loop)
    Action::Message =>
      match self.proxy {
        Some(proxy) => {
          self.proxy_actions.push(Action::Message)
          proxy.wake_up()
        }
        None => ()
      }
    _ =>
      match self.window_by_id(window_id) {
        Some(window) =>
          self.perform_window_action(event_loop, window_id, action, window)
        None => ()
      }
  }
}

///|
fn Application::handle_proxy_action(
  self : Application,
  event_loop : @macos.ActiveEventLoop,
  action : Action,
) -> Unit {
  match action {
    Action::Message => {
      println("User wake up")
      for state in self.window_input_states {
        if state.emit_surface_size {
          let window_id = state.window_id
          match self.window_by_id(window_id) {
            Some(window) => {
              let size = window.surface_size()
              println(
                "Window \{window_id} surface size: \{size.width()}x\{size.height()}",
              )
            }
            None => ()
          }
        }
      }
    }
    Action::DumpMonitors => self.dump_monitors(event_loop)
    _ => ()
  }
}

///|
fn drag_resize_direction(
  window : @macos.Window,
  position : @dpi.PhysicalPositionF64,
) -> @core.ResizeDirection? {
  let size = window.surface_size()
  let border_size = border_size_points * window.scale_factor()

  let x_direction = if position.x() < border_size {
    Some(@core.ResizeDirection::West)
  } else if position.x() > size.width().to_double() - border_size {
    Some(@core.ResizeDirection::East)
  } else {
    None
  }

  let y_direction = if position.y() < border_size {
    Some(@core.ResizeDirection::North)
  } else if position.y() > size.height().to_double() - border_size {
    Some(@core.ResizeDirection::South)
  } else {
    None
  }

  match (x_direction, y_direction) {
    (Some(@core.ResizeDirection::West), Some(@core.ResizeDirection::North)) =>
      Some(@core.ResizeDirection::NorthWest)
    (Some(@core.ResizeDirection::West), Some(@core.ResizeDirection::South)) =>
      Some(@core.ResizeDirection::SouthWest)
    (Some(@core.ResizeDirection::East), Some(@core.ResizeDirection::North)) =>
      Some(@core.ResizeDirection::NorthEast)
    (Some(@core.ResizeDirection::East), Some(@core.ResizeDirection::South)) =>
      Some(@core.ResizeDirection::SouthEast)
    (Some(@core.ResizeDirection::West), _) => Some(@core.ResizeDirection::West)
    (Some(@core.ResizeDirection::East), _) => Some(@core.ResizeDirection::East)
    (_, Some(@core.ResizeDirection::North)) =>
      Some(@core.ResizeDirection::North)
    (_, Some(@core.ResizeDirection::South)) =>
      Some(@core.ResizeDirection::South)
    _ => None
  }
}

///|
fn Application::handle_pointer_binding(
  self : Application,
  window_id : @core.WindowId,
  state : @core.ElementState,
  position : @dpi.PhysicalPositionF64,
  source : @core.ButtonSource,
) -> Unit {
  if state != @core.ElementState::Pressed {
    return
  }
  let modifiers = self.modifiers_for_window(window_id)
  let button = match source {
    @core.ButtonSource::Mouse(mouse_button) => Some(mouse_button)
    _ => None
  }
  match (button, self.window_by_id(window_id)) {
    (Some(@core.MouseButton::Left), Some(window)) =>
      if modifiers_match(modifiers, true, false, false, false) {
        let started = try {
          window.drag_window()
          true
        } catch {
          err => {
            println("Error starting window drag: \{err}")
            false
          }
        }
        if started {
          println("Dragging window Window=\{window.id()}")
        }
      } else if modifiers_match(modifiers, false, true, false, false) {
        match drag_resize_direction(window, position) {
          Some(direction) => {
            let started = try {
              window.drag_resize_window(direction)
              true
            } catch {
              err => {
                println("Error starting window drag-resize: \{err}")
                false
              }
            }
            if started {
              println("Drag-resizing window Window=\{window.id()}")
            }
          }
          None => println("Drag-resize requires cursor to be inside the window")
        }
      }
    (Some(@core.MouseButton::Right), Some(window)) =>
      if modifiers_match(modifiers, true, false, false, false) {
        let menu_position = @dpi.PhysicalPosition::new(
          position.x().to_int(),
          position.y().to_int(),
        )
        window.show_window_menu(menu_position.into_position())
      }
    _ => ()
  }
}

///|
fn Application::window_state(
  self : Application,
  window_id : @core.WindowId,
) -> WindowInputState? {
  match
    self.window_input_states.search_by(entry => entry.window_id == window_id) {
    Some(index) => Some(self.window_input_states[index])
    None => None
  }
}

///|
pub impl @macos.ApplicationHandler for Application with can_create_surfaces(
  self,
  event_loop,
) {
  println("Ready to create surfaces")
  self.dump_monitors(event_loop)
  self.create_window(event_loop, "Winit window", None) |> ignore
  self.print_help()
}

///|
pub impl @macos.ApplicationHandler for Application with proxy_wake_up(
  self,
  event_loop,
) {
  while self.proxy_actions.is_empty() == false {
    let action = self.proxy_actions.remove(0)
    self.handle_proxy_action(event_loop, action)
  }
}

///|
pub impl @macos.ApplicationHandler for Application with about_to_wait(
  self,
  event_loop,
) {
  if self.windows.is_empty() {
    println("No windows left, exiting...")
    event_loop.exit()
    return
  }
  let now = @util.now_millis()
  if now >= self.next_proxy_wake_ms {
    match self.proxy {
      Some(proxy) => {
        self.proxy_actions.push(Action::Message)
        proxy.wake_up()
      }
      None => ()
    }
    self.next_proxy_wake_ms = now + (1000 : Int).to_int64()
  }
  let remaining_ms = self.next_proxy_wake_ms - now
  let wait_ms = if remaining_ms <= 0 { 1 } else { remaining_ms.to_int() }
  event_loop.set_control_flow(@core.ControlFlow::wait_duration(now, wait_ms))
}

///|
pub impl @macos.ApplicationHandler for Application with device_event(
  _self,
  _event_loop,
  device_id,
  event,
) {
  println("Device \{device_id} event: \{event}")
}

///|
pub impl @macos.ApplicationHandler for Application with window_event(
  self,
  event_loop,
  window_id,
  event,
) {
  match event {
    @core.WindowEvent::CloseRequested => {
      println("Closing Window=\{window_id}")
      self.execute_action(event_loop, window_id, Action::CloseWindow)
    }
    @core.WindowEvent::Destroyed => {
      self.remove_window(window_id)
      if self.windows.is_empty() {
        event_loop.exit()
      }
    }
    @core.WindowEvent::Focused(focused) =>
      if focused {
        println("Window=\{window_id} focused")
      } else {
        println("Window=\{window_id} unfocused")
      }
    @core.WindowEvent::ScaleFactorChanged(scale_factor, _writer) =>
      println("Window=\{window_id} changed scale to \{scale_factor}")
    @core.WindowEvent::Occluded(occluded) => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].occluded = occluded
      if !occluded {
        match self.window_by_id(window_id) {
          Some(window) => window.request_redraw()
          None => ()
        }
      }
    }
    @core.WindowEvent::ThemeChanged(theme) => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].theme = theme
      println("Theme changed to \{theme}")
    }
    @core.WindowEvent::ModifiersChanged(modifiers) => {
      self.set_window_modifiers(window_id, modifiers.state())
      println("Modifiers changed to \{modifiers.state()}")
    }
    @core.WindowEvent::MouseWheel(_device_id, delta, _phase) =>
      match delta {
        @core.MouseScrollDelta::LineDelta(x, y) =>
          println("Mouse wheel Line Delta: (\{x},\{y})")
        @core.MouseScrollDelta::PixelDelta(px) =>
          println("Mouse wheel Pixel Delta: (\{px.x()},\{px.y()})")
      }
    @core.WindowEvent::PointerMoved(_device_id, position, _is_primary, _kind) =>
      println("Moved pointer to \{position}")
    @core.WindowEvent::PointerLeft(_device_id, _position, _is_primary, _kind) =>
      println("Pointer left Window=\{window_id}")
    @core.WindowEvent::PointerButton(
      _device_id,
      state,
      position,
      _is_primary,
      source
    ) => {
      match source {
        @core.ButtonSource::Mouse(button) =>
          println("Pointer button \{button} \{state}")
        _ => println("Pointer button \{source} \{state}")
      }
      self.handle_pointer_binding(window_id, state, position, source)
    }
    @core.WindowEvent::PinchGesture(_device_id, delta, _phase) => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].zoom += delta
      let zoom = self.window_input_states[state_index].zoom
      if delta > 0.0 {
        println("Zoomed in \{delta} (now: \{zoom})")
      } else {
        println("Zoomed out \{delta} (now: \{zoom})")
      }
    }
    @core.WindowEvent::RotationGesture(_device_id, delta, _phase) => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].rotated += delta
      let rotated = self.window_input_states[state_index].rotated
      if delta > 0.0 {
        println("Rotated counterclockwise \{delta} (now: \{rotated})")
      } else {
        println("Rotated clockwise \{delta} (now: \{rotated})")
      }
    }
    @core.WindowEvent::PanGesture(_device_id, delta, phase) => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].panned_x += delta.x()
      self.window_input_states[state_index].panned_y += delta.y()
      let panned_x = self.window_input_states[state_index].panned_x
      let panned_y = self.window_input_states[state_index].panned_y
      println("Panned (\{delta}) (now: (\{panned_x},\{panned_y})), \{phase}")
    }
    @core.WindowEvent::DoubleTapGesture(_device_id) => println("Smart zoom")
    @core.WindowEvent::KeyboardInput(_device_id, key_event, is_synthetic) =>
      if !is_synthetic && key_event.state() is @core.ElementState::Pressed {
        match self.action_from_key(window_id, key_event) {
          Some(action) => self.execute_action(event_loop, window_id, action)
          None => ()
        }
      }
    @core.WindowEvent::SurfaceResized(size) =>
      match self.window_by_id(window_id) {
        Some(window) => {
          println("Surface resized to \{size}")
          window.request_redraw()
        }
        None => ()
      }
    @core.WindowEvent::RedrawRequested =>
      match self.window_state(window_id) {
        Some(state) =>
          if state.occluded {
            println("Skipping drawing occluded window=\{window_id}")
          } else {
            match self.window_by_id(window_id) {
              Some(window) => {
                window.pre_present_notify()
                if state.animated_fill_color {
                  @util.fill_window_with_animated_color(
                    window,
                    self.start_time_ms,
                  )
                } else {
                  @util.fill_window_with_color(
                    window,
                    fill_color_for_theme(state.theme),
                  )
                }
                if state.continuous_redraw {
                  window.request_redraw()
                }
              }
              None => ()
            }
          }
        None => ()
      }
    _ => ()
  }
}

///|
pub impl @macos.ApplicationHandler for Application with standard_key_binding(
  _self,
  _event_loop,
  window_id,
  action,
) {
  println("macOS standard key binding: window=\{window_id} action=\{action}")
}

///|
fn main {
  @util.tracing_init()
  let event_loop = @macos.EventLoop::new()
  let app = Application::new()
  let window_target = event_loop.window_target()
  app.proxy = Some(window_target.create_proxy())
  println("Starting to send user event every second")
  app.load_custom_cursors(window_target)
  event_loop.run_app(app)
  println("Application exited")
}
