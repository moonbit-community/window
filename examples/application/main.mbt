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
struct Application {
  windows : Array[@macos.Window]
  window_input_states : Array[WindowInputState]
  mut proxy : @macos.EventLoopProxy?
  proxy_actions : Array[Action]
  mut created_windows : Int
  custom_cursors : Array[@core.CustomCursor]
  start_time_ms : Int64
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
fn Application::new() -> Application {
  {
    windows: [],
    window_input_states: [],
    proxy: None,
    proxy_actions: [],
    created_windows: 0,
    custom_cursors: [],
    start_time_ms: @util.now_millis(),
  }
}

///|
fn Application::print_help(_self : Application) -> Unit {
  println("Keyboard shortcuts (matching upstream application example intent):")
  println("  Ctrl+Q close current window")
  println("  Ctrl+H print this help")
  println("  Ctrl+N create a new window")
  println("  Ctrl+F toggle fullscreen; Alt+F toggle simple fullscreen")
  println("  Ctrl+D toggle decorations; Ctrl+R toggle resizable")
  println("  Ctrl+P toggle resize increments; Alt+R request resize")
  println("  Ctrl+M maximize; Alt+M minimize; Ctrl+Alt+M dump monitors")
  println("  Ctrl+C next system cursor; Alt+C next custom cursor")
  println("  Ctrl+L cycle cursor grab; Ctrl+Z toggle cursor visibility")
  println("  K system theme; Cmd+K light; Ctrl+K dark")
  println(
    "  Cmd+T create tab; Ctrl+O cycle OptionAsAlt; Ctrl+B toggle borderless game",
  )
  println("  Shift+F toggle animated fill; Shift+R toggle continuous redraw")
  println("  Alt+S toggle periodic surface-size logs; Ctrl+S proxy message")
  println("Mouse shortcuts:")
  println("  Ctrl+Left drag window")
  println("  Alt+Left drag-resize (direction depends on pointer edge/corner)")
  println("  Ctrl+Right show window menu")
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
  })
  self.created_windows += 1
  println("Created window #\{self.created_windows}: \{window_id}")
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
  let primary_monitor = event_loop.primary_monitor()
  println("Primary monitor: \{primary_monitor}")
  let monitors = event_loop.available_monitors()
  println("Available monitors (\{monitors.length()}):")
  for monitor in monitors {
    println(
      "  name=\{monitor.name()} pos=\{monitor.position()} size=\{monitor.surface_size()} scale=\{monitor.scale_factor()} current_video=\{monitor.current_video_mode()}",
    )
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
    Action::CloseWindow => {
      self.remove_window(window_id)
      if self.windows.is_empty() {
        event_loop.exit()
      }
    }
    Action::ToggleCursorVisibility =>
      window.set_cursor_visible(!window.is_cursor_visible())
    Action::ToggleResizeIncrements =>
      if window.resize_increments() is None {
        window.set_resize_increments(
          Some(@dpi.LogicalSize::new(25.0, 25.0).into_size()),
        )
      } else {
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
    Action::ToggleBorderlessGame =>
      window.set_borderless_game(!window.is_borderless_game())
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
      ignore(window.request_surface_size(next_size.into_size()))
    }
    Action::SetTheme(theme) => window.set_theme(theme)
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
      println("OptionAsAlt=\{next}")
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
    | Action::Message => ()
  }
}

///|
fn Application::execute_action(
  self : Application,
  event_loop : @macos.ActiveEventLoop,
  window_id : @core.WindowId,
  action : Action,
) -> Unit {
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
      println("Received proxy wake-up")
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
        window.drag_window() catch {
          err => println("Drag window failed: \{err}")
        }
      } else if modifiers_match(modifiers, false, true, false, false) {
        match drag_resize_direction(window, position) {
          Some(direction) =>
            window.drag_resize_window(direction) catch {
              err => println("Drag resize failed: \{err}")
            }
          None => println("Drag resize requires pointer near a window edge")
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
  self.proxy = Some(event_loop.create_proxy())
  self.load_custom_cursors(event_loop)
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
    event_loop.exit()
  }
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
  for compat_event in event.into_winit_events() {
    match compat_event {
      @core.WinitWindowEvent::DroppedFile(path) =>
        println("Dropped file in \{window_id}: \{path}")
      @core.WinitWindowEvent::HoveredFile(path) =>
        println("Hovering file in \{window_id}: \{path}")
      @core.WinitWindowEvent::HoveredFileCancelled =>
        println("File hover cancelled in \{window_id}")
      _ => ()
    }
  }

  match event {
    @core.WindowEvent::CloseRequested =>
      self.execute_action(event_loop, window_id, Action::CloseWindow)
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
      println("Window \{window_id} theme=\{theme}")
    }
    @core.WindowEvent::ModifiersChanged(modifiers) =>
      self.set_window_modifiers(window_id, modifiers.state())
    @core.WindowEvent::MouseWheel(_device_id, delta, _phase) =>
      match delta {
        @core.MouseScrollDelta::LineDelta(x, y) =>
          println("Mouse wheel Line Delta: (\{x},\{y})")
        @core.MouseScrollDelta::PixelDelta(px) =>
          println("Mouse wheel Pixel Delta: (\{px.x()},\{px.y()})")
      }
    @core.WindowEvent::PointerButton(
      _device_id,
      state,
      position,
      _is_primary,
      source
    ) => self.handle_pointer_binding(window_id, state, position, source)
    @core.WindowEvent::KeyboardInput(_device_id, key_event, is_synthetic) =>
      if !is_synthetic && key_event.state() is @core.ElementState::Pressed {
        match self.action_from_key(window_id, key_event) {
          Some(action) => self.execute_action(event_loop, window_id, action)
          None => ()
        }
      }
    @core.WindowEvent::SurfaceResized(_) =>
      match self.window_by_id(window_id) {
        Some(window) => window.request_redraw()
        None => ()
      }
    @core.WindowEvent::RedrawRequested =>
      match self.window_state(window_id) {
        Some(state) =>
          if state.occluded {
            ()
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
  event_loop.run_app(Application::new())
}
