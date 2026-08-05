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
} derive(Eq, Debug)

///|
fn Action::help(self : Action) -> String {
  match self {
    CloseWindow => "Close window"
    PrintHelp => "Print help"
    CreateNewWindow => "Create new window"
    ToggleResizeIncrements => "Use resize increments when resizing window"
    ToggleCursorVisibility => "Hide cursor"
    ToggleResizable => "Toggle window resizable state"
    ToggleDecorations => "Toggle decorations"
    ToggleFullscreen => "Toggle fullscreen"
    ToggleSimpleFullscreen => "Toggle simple fullscreen"
    ToggleBorderlessGame => "Toggle borderless game mode"
    ToggleMaximize => "Maximize"
    Minimize => "Minimize"
    NextCursor => "Advance the cursor to the next value"
    NextCustomCursor => "Advance custom cursor to the next value"
    CycleCursorGrab => "Cycle through cursor grab mode"
    DragWindow => "Start window drag"
    DragResizeWindow => "Start window drag-resize"
    ShowWindowMenu => "Show window menu"
    RequestResize => "Request a resize"
    SetTheme(None) => "Change to the system theme"
    SetTheme(Some(Light)) => "Change to a light theme"
    SetTheme(Some(Dark)) => "Change to a dark theme"
    CreateNewTab => "Create new tab"
    CycleOptionAsAlt => "Cycle option as alt mode"
    DumpMonitors => "Dump monitor information"
    Message => "Prints a message through a user wake up"
    ToggleAnimatedFillColor => "Toggle animated fill color"
    ToggleContinuousRedraw => "Toggle continuous redraw"
    EmitSurfaceSize => "Periodically print the surface size"
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
      action: CloseWindow,
    },
    {
      key: "H",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: PrintHelp,
    },
    {
      key: "F",
      control: false,
      alt: false,
      shift: true,
      meta: false,
      action: ToggleAnimatedFillColor,
    },
    {
      key: "F",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: ToggleFullscreen,
    },
    {
      key: "F",
      control: false,
      alt: true,
      shift: false,
      meta: false,
      action: ToggleSimpleFullscreen,
    },
    {
      key: "D",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: ToggleDecorations,
    },
    {
      key: "L",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: CycleCursorGrab,
    },
    {
      key: "P",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: ToggleResizeIncrements,
    },
    {
      key: "R",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: ToggleResizable,
    },
    {
      key: "R",
      control: false,
      alt: true,
      shift: false,
      meta: false,
      action: RequestResize,
    },
    {
      key: "R",
      control: false,
      alt: false,
      shift: true,
      meta: false,
      action: ToggleContinuousRedraw,
    },
    {
      key: "M",
      control: true,
      alt: true,
      shift: false,
      meta: false,
      action: DumpMonitors,
    },
    {
      key: "M",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: ToggleMaximize,
    },
    {
      key: "M",
      control: false,
      alt: true,
      shift: false,
      meta: false,
      action: Minimize,
    },
    {
      key: "N",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: CreateNewWindow,
    },
    {
      key: "C",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: NextCursor,
    },
    {
      key: "C",
      control: false,
      alt: true,
      shift: false,
      meta: false,
      action: NextCustomCursor,
    },
    {
      key: "Z",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: ToggleCursorVisibility,
    },
    {
      key: "K",
      control: false,
      alt: false,
      shift: false,
      meta: false,
      action: SetTheme(None),
    },
    {
      key: "K",
      control: false,
      alt: false,
      shift: false,
      meta: true,
      action: SetTheme(Some(Light)),
    },
    {
      key: "K",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: SetTheme(Some(Dark)),
    },
    {
      key: "T",
      control: false,
      alt: false,
      shift: false,
      meta: true,
      action: CreateNewTab,
    },
    {
      key: "O",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: CycleOptionAsAlt,
    },
    {
      key: "B",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: ToggleBorderlessGame,
    },
    {
      key: "S",
      control: false,
      alt: true,
      shift: false,
      meta: false,
      action: EmitSurfaceSize,
    },
    {
      key: "S",
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: Message,
    },
  ]
}

///|
fn mouse_bindings() -> Array[MouseBinding] {
  [
    {
      button: Left,
      control: false,
      alt: true,
      shift: false,
      meta: false,
      action: DragResizeWindow,
    },
    {
      button: Left,
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: DragWindow,
    },
    {
      button: Right,
      control: true,
      alt: false,
      shift: false,
      meta: false,
      action: ShowWindowMenu,
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
    Default,
    Crosshair,
    Pointer,
    Move,
    Text,
    Wait,
    Help,
    Progress,
    NotAllowed,
    ContextMenu,
    Cell,
    VerticalText,
    Alias,
    Copy,
    NoDrop,
    Grab,
    Grabbing,
    AllScroll,
    ZoomIn,
    ZoomOut,
    EResize,
    NResize,
    NeResize,
    NwResize,
    SResize,
    SeResize,
    SwResize,
    WResize,
    EwResize,
    NsResize,
    NeswResize,
    NwseResize,
    ColResize,
    RowResize,
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
    Left => "Left"
    Right => "Right"
    Middle => "Middle"
    Back => "Back"
    Forward => "Forward"
    Button6 => "Button6"
    Button7 => "Button7"
    Button8 => "Button8"
    Button9 => "Button9"
    Button10 => "Button10"
    Button11 => "Button11"
    Button12 => "Button12"
    Button13 => "Button13"
    Button14 => "Button14"
    Button15 => "Button15"
    Button16 => "Button16"
    Button17 => "Button17"
    Button18 => "Button18"
    Button19 => "Button19"
    Button20 => "Button20"
    Button21 => "Button21"
    Button22 => "Button22"
    Button23 => "Button23"
    Button24 => "Button24"
    Button25 => "Button25"
    Button26 => "Button26"
    Button27 => "Button27"
    Button28 => "Button28"
    Button29 => "Button29"
    Button30 => "Button30"
    Button31 => "Button31"
    Button32 => "Button32"
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
fn safe_area_inner_color_for_theme(theme : @core.Theme) -> Int {
  match theme {
    Light => 0xffe8e8e8
    Dark => 0xff525252
  }
}

///|
fn safe_area_outer_color_for_theme(theme : @core.Theme) -> Int {
  match theme {
    Light => 0xffffffff
    Dark => 0xff181818
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
fn Application::Application() -> Application {
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
    println(
      "  \{prefix}\{binding.key} - \{binding.action} (\{binding.action.help()})",
    )
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
      "  \{prefix}\{mouse_button_name(binding.button)} - \{binding.action} (\{binding.action.help()})",
    )
  }
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
    None => Dark
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
    cursor_grab_mode: None,
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
            None => Dark
          }
        None => Dark
      }
      self.window_input_states.push({
        window_id,
        modifiers: @core.ModifiersState::none(),
        theme: initial_theme,
        cursor_grab_mode: None,
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
    Named(Escape) => Some(CloseWindow)
    Character("q") | Character("Q") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(CloseWindow)
      } else {
        None
      }
    Character("h") | Character("H") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(PrintHelp)
      } else {
        None
      }
    Character("n") | Character("N") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(CreateNewWindow)
      } else {
        None
      }
    Character("f") | Character("F") =>
      if modifiers_match(modifiers, false, false, true, false) {
        Some(ToggleAnimatedFillColor)
      } else if modifiers_match(modifiers, true, false, false, false) {
        Some(ToggleFullscreen)
      } else if modifiers_match(modifiers, false, true, false, false) {
        Some(ToggleSimpleFullscreen)
      } else {
        None
      }
    Character("d") | Character("D") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(ToggleDecorations)
      } else {
        None
      }
    Character("l") | Character("L") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(CycleCursorGrab)
      } else {
        None
      }
    Character("p") | Character("P") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(ToggleResizeIncrements)
      } else {
        None
      }
    Character("r") | Character("R") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(ToggleResizable)
      } else if modifiers_match(modifiers, false, true, false, false) {
        Some(RequestResize)
      } else if modifiers_match(modifiers, false, false, true, false) {
        Some(ToggleContinuousRedraw)
      } else {
        None
      }
    Character("m") | Character("M") =>
      if modifiers_match(modifiers, true, true, false, false) {
        Some(DumpMonitors)
      } else if modifiers_match(modifiers, true, false, false, false) {
        Some(ToggleMaximize)
      } else if modifiers_match(modifiers, false, true, false, false) {
        Some(Minimize)
      } else {
        None
      }
    Character("c") | Character("C") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(NextCursor)
      } else if modifiers_match(modifiers, false, true, false, false) {
        Some(NextCustomCursor)
      } else {
        None
      }
    Character("z") | Character("Z") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(ToggleCursorVisibility)
      } else {
        None
      }
    Character("k") | Character("K") =>
      if modifiers_match(modifiers, false, false, false, false) {
        Some(SetTheme(None))
      } else if modifiers_match(modifiers, false, false, false, true) {
        Some(SetTheme(Some(Light)))
      } else if modifiers_match(modifiers, true, false, false, false) {
        Some(SetTheme(Some(Dark)))
      } else {
        None
      }
    Character("t") | Character("T") =>
      if modifiers_match(modifiers, false, false, false, true) {
        Some(CreateNewTab)
      } else {
        None
      }
    Character("o") | Character("O") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(CycleOptionAsAlt)
      } else {
        None
      }
    Character("b") | Character("B") =>
      if modifiers_match(modifiers, true, false, false, false) {
        Some(ToggleBorderlessGame)
      } else {
        None
      }
    Character("s") | Character("S") =>
      if modifiers_match(modifiers, false, true, false, false) {
        Some(EmitSurfaceSize)
      } else if modifiers_match(modifiers, true, false, false, false) {
        Some(Message)
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
    CloseWindow => self.remove_window(window_id)
    ToggleCursorVisibility =>
      window.set_cursor_visible(!window.is_cursor_visible())
    ToggleResizeIncrements =>
      if window.resize_increments() is None {
        println("Had increments: false")
        window.set_resize_increments(
          Some(@dpi.LogicalSize::LogicalSize(25.0, 25.0).into_size()),
        )
      } else {
        println("Had increments: true")
        window.set_resize_increments(None)
      }
    ToggleResizable => window.set_resizable(!window.is_resizable())
    ToggleDecorations => window.set_decorations(!window.is_decorated())
    ToggleFullscreen =>
      match window.fullscreen() {
        Some(_) => window.set_fullscreen(None)
        None => window.set_fullscreen(Some(Borderless(None)))
      }
    ToggleSimpleFullscreen => {
      let _ = window.set_simple_fullscreen(!window.simple_fullscreen())
    }
    ToggleBorderlessGame => {
      let next = !window.is_borderless_game()
      window.set_borderless_game(next)
      println("Borderless game: \{next}")
    }
    ToggleMaximize => window.set_maximized(!window.is_maximized())
    Minimize => window.set_minimized(true)
    NextCursor => {
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
    NextCustomCursor =>
      if self.custom_cursors.is_empty() {
        println("No custom cursor available on this platform/runtime")
      } else {
        let state_index = self.ensure_window_input_state(window_id)
        let next_custom_cursor_index = (
            self.window_input_states[state_index].custom_cursor_index + 1
          ) %
          self.custom_cursors.length()
        self.window_input_states[state_index].custom_cursor_index = next_custom_cursor_index
        window.set_cursor(Custom(self.custom_cursors[next_custom_cursor_index]))
      }
    CycleCursorGrab => {
      let state_index = self.ensure_window_input_state(window_id)
      let next_mode = match
        self.window_input_states[state_index].cursor_grab_mode {
        None => @core.CursorGrabMode::Confined
        Confined => Locked
        Locked => None
      }
      println("Changing cursor grab mode to \{next_mode}")
      try {
        window.set_cursor_grab(next_mode)
        self.window_input_states[state_index].cursor_grab_mode = next_mode
      } catch {
        err => println("Cursor grab update failed: \{err}")
      }
    }
    RequestResize => {
      let old_surface_size = window.surface_size()
      let requested_surface_size = @dpi.PhysicalSize::PhysicalSize(
        old_surface_size.height(),
        old_surface_size.width(),
      )
      println(
        "Requesting resize from \{old_surface_size} to \{requested_surface_size}",
      )
      match window.request_surface_size(requested_surface_size.into_size()) {
        Some(new_surface_size) =>
          if old_surface_size == new_surface_size {
            println("Inner size change got ignored")
          } else {
            println("Surface resized to \{new_surface_size}")
          }
        None => println("Requesting surface size is asynchronous")
      }
    }
    SetTheme(theme) => {
      window.set_theme(theme)
      let state_index = self.ensure_window_input_state(window_id)
      let actual_theme = match theme {
        Some(theme) => theme
        None =>
          match window.theme() {
            Some(theme) => theme
            None => Dark
          }
      }
      self.window_input_states[state_index].theme = actual_theme
    }
    CreateNewTab => {
      let current_id = window.tabbing_identifier()
      let tab_id = if current_id.is_empty() {
        "moonbit-window-example-tabs"
      } else {
        current_id
      }
      self.create_window(event_loop, "Winit tab", Some(tab_id)) |> ignore
    }
    CycleOptionAsAlt => {
      let next = match window.option_as_alt() {
        OnlyLeft => @core.OptionAsAlt::OnlyRight
        OnlyRight => Both
        Both => None
        None => OnlyLeft
      }
      window.set_option_as_alt(next)
      println("Setting option as alt \{next}")
    }
    ToggleAnimatedFillColor => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].animated_fill_color = !self.window_input_states[state_index].animated_fill_color
      let enabled = self.window_input_states[state_index].animated_fill_color
      println("Animated fill on \{window_id}: \{enabled}")
    }
    ToggleContinuousRedraw => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].continuous_redraw = !self.window_input_states[state_index].continuous_redraw
      let enabled = self.window_input_states[state_index].continuous_redraw
      println("Continuous redraw on \{window_id}: \{enabled}")
      if enabled {
        window.request_redraw()
      }
    }
    EmitSurfaceSize => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].emit_surface_size = !self.window_input_states[state_index].emit_surface_size
      let enabled = self.window_input_states[state_index].emit_surface_size
      println("Emit surface size on \{window_id}: \{enabled}")
    }
    CreateNewWindow
    | PrintHelp
    | DumpMonitors
    | Message
    | DragWindow
    | DragResizeWindow
    | ShowWindowMenu => ()
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
    CreateNewWindow =>
      self.create_window(event_loop, "Winit window", None) |> ignore
    PrintHelp => self.print_help()
    DumpMonitors => self.dump_monitors(event_loop)
    Message =>
      match self.proxy {
        Some(proxy) => {
          self.proxy_actions.push(Message)
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
    Message => {
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
    DumpMonitors => self.dump_monitors(event_loop)
    _ => ()
  }
}

///|
fn drag_resize_direction(
  window : @macos.Window,
  position : @dpi.PhysicalPositionF64,
) -> @core.ResizeDirection {
  let size = window.surface_size()
  let border_size = border_size_points * window.scale_factor()

  let x_direction = if position.x() < border_size {
    @core.ResizeDirection::West
  } else if position.x() > size.width().to_double() - border_size {
    East
  } else {
    SouthEast
  }

  let y_direction = if position.y() < border_size {
    @core.ResizeDirection::North
  } else if position.y() > size.height().to_double() - border_size {
    South
  } else {
    SouthEast
  }

  match (x_direction, y_direction) {
    (West, North) => NorthWest
    (West, South) => SouthWest
    (West, _) => West
    (East, North) => NorthEast
    (East, South) => SouthEast
    (East, _) => East
    (_, South) => South
    (_, North) => North
    _ => SouthEast
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
  if state != Pressed {
    return
  }
  let modifiers = self.modifiers_for_window(window_id)
  let button = match source {
    Mouse(mouse_button) => Some(mouse_button)
    _ => None
  }
  match (button, self.window_by_id(window_id)) {
    (Some(Left), Some(window)) =>
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
        let direction = drag_resize_direction(window, position)
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
    (Some(Right), Some(window)) =>
      if modifiers_match(modifiers, true, false, false, false) {
        let menu_position = @dpi.PhysicalPosition::PhysicalPosition(
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
pub impl @macos.ApplicationHandler for Application with fn can_create_surfaces(
  self,
  event_loop,
) {
  println("Ready to create surfaces")
  self.dump_monitors(event_loop)
  self.create_window(event_loop, "Winit window", None) |> ignore
  self.print_help()
}

///|
pub impl @macos.ApplicationHandler for Application with fn proxy_wake_up(
  self,
  event_loop,
) {
  while self.proxy_actions.is_empty() == false {
    let action = self.proxy_actions.remove(0)
    self.handle_proxy_action(event_loop, action)
  }
}

///|
pub impl @macos.ApplicationHandler for Application with fn about_to_wait(
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
        self.proxy_actions.push(Message)
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
pub impl @macos.ApplicationHandler for Application with fn device_event(
  _self,
  _event_loop,
  device_id,
  event,
) {
  let device_id_debug = Repr(device_id).to_string()
  let event_debug = Repr(event).to_string()
  println("Device \{device_id_debug} event: \{event_debug}")
}

///|
pub impl @macos.ApplicationHandler for Application with fn window_event(
  self,
  event_loop,
  window_id,
  event,
) {
  match event {
    CloseRequested => {
      println("Closing Window=\{window_id}")
      self.execute_action(event_loop, window_id, CloseWindow)
    }
    Destroyed => {
      self.remove_window(window_id)
      if self.windows.is_empty() {
        event_loop.exit()
      }
    }
    Focused(focused) =>
      if focused {
        println("Window=\{window_id} focused")
      } else {
        println("Window=\{window_id} unfocused")
      }
    ScaleFactorChanged(scale_factor, _writer) =>
      println("Window=\{window_id} changed scale to \{scale_factor}")
    Occluded(occluded) => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].occluded = occluded
      if !occluded {
        match self.window_by_id(window_id) {
          Some(window) => window.request_redraw()
          None => ()
        }
      }
    }
    ThemeChanged(theme) => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].theme = theme
      println("Theme changed to \{theme}")
    }
    ModifiersChanged(modifiers) => {
      self.set_window_modifiers(window_id, modifiers.state())
      println("Modifiers changed to \{modifiers.state()}")
    }
    MouseWheel(_device_id, delta, _phase) =>
      match delta {
        LineDelta(x, y) => println("Mouse wheel Line Delta: (\{x},\{y})")
        PixelDelta(px) =>
          println("Mouse wheel Pixel Delta: (\{px.x()},\{px.y()})")
      }
    PointerMoved(_device_id, position, _is_primary, _kind) =>
      println("Moved pointer to \{position}")
    PointerLeft(_device_id, _position, _is_primary, _kind) =>
      println("Pointer left Window=\{window_id}")
    PointerButton(_device_id, state, position, _is_primary, source) => {
      match source {
        Mouse(button) => println("Pointer button \{button} \{state}")
        _ => println("Pointer button \{source} \{state}")
      }
      self.handle_pointer_binding(window_id, state, position, source)
    }
    PinchGesture(_device_id, delta, _phase) => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].zoom += delta
      let zoom = self.window_input_states[state_index].zoom
      if delta > 0.0 {
        println("Zoomed in \{delta} (now: \{zoom})")
      } else {
        println("Zoomed out \{delta} (now: \{zoom})")
      }
    }
    RotationGesture(_device_id, delta, _phase) => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].rotated += delta
      let rotated = self.window_input_states[state_index].rotated
      if delta > 0.0 {
        println("Rotated counterclockwise \{delta} (now: \{rotated})")
      } else {
        println("Rotated clockwise \{delta} (now: \{rotated})")
      }
    }
    PanGesture(_device_id, delta, phase) => {
      let state_index = self.ensure_window_input_state(window_id)
      self.window_input_states[state_index].panned_x += delta.x()
      self.window_input_states[state_index].panned_y += delta.y()
      let panned_x = self.window_input_states[state_index].panned_x
      let panned_y = self.window_input_states[state_index].panned_y
      println("Panned (\{delta}) (now: (\{panned_x},\{panned_y})), \{phase}")
    }
    DoubleTapGesture(_device_id) => println("Smart zoom")
    KeyboardInput(_device_id, key_event, is_synthetic) =>
      if !is_synthetic && key_event.state() is Pressed {
        match self.action_from_key(window_id, key_event) {
          Some(action) => self.execute_action(event_loop, window_id, action)
          None => ()
        }
      }
    SurfaceResized(size) =>
      match self.window_by_id(window_id) {
        Some(window) => {
          println("Surface resized to \{size}")
          window.request_redraw()
        }
        None => ()
      }
    RedrawRequested =>
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
                  @util.fill_window_with_safe_area_colors(
                    window,
                    safe_area_inner_color_for_theme(state.theme),
                    safe_area_outer_color_for_theme(state.theme),
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
pub impl @macos.ApplicationHandler for Application with fn standard_key_binding(
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
  let event_loop = @macos.EventLoop::EventLoop()
  let app = Application::Application()
  let window_target = event_loop.window_target()
  app.proxy = Some(window_target.create_proxy())
  println("Starting to send user event every second")
  app.load_custom_cursors(window_target)
  event_loop.run_app(app)
  println("Application exited")
}
