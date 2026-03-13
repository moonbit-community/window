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
  mut proxy : @macos.EventLoopProxy?
  mut proxy_sent : Bool
  mut created_windows : Int
  mut modifiers : @core.ModifiersState
  mut cursor_grab_mode : @core.CursorGrabMode
  mut cursor_index : Int
  mut custom_cursor_index : Int
  custom_cursors : Array[@core.CustomCursor]
  animated_fill_window_ids : Array[@core.WindowId]
  continuous_redraw_window_ids : Array[@core.WindowId]
  emit_surface_size_window_ids : Array[@core.WindowId]
  occluded_window_ids : Array[@core.WindowId]
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
    @core.CursorIcon::Grab,
    @core.CursorIcon::Grabbing,
    @core.CursorIcon::ZoomIn,
    @core.CursorIcon::ZoomOut,
    @core.CursorIcon::EwResize,
    @core.CursorIcon::NsResize,
  ]
}

///|
fn contains_window_id(
  window_ids : Array[@core.WindowId],
  window_id : @core.WindowId,
) -> Bool {
  match window_ids.search_by(id => id == window_id) {
    Some(_) => true
    None => false
  }
}

///|
fn remove_window_id(
  window_ids : Array[@core.WindowId],
  window_id : @core.WindowId,
) -> Unit {
  match window_ids.search_by(id => id == window_id) {
    Some(index) => ignore(window_ids.remove(index))
    None => ()
  }
}

///|
fn toggle_window_id(
  window_ids : Array[@core.WindowId],
  window_id : @core.WindowId,
) -> Bool {
  match window_ids.search_by(id => id == window_id) {
    Some(index) => {
      ignore(window_ids.remove(index))
      false
    }
    None => {
      window_ids.push(window_id)
      true
    }
  }
}

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
fn Application::new() -> Application {
  {
    windows: [],
    proxy: None,
    proxy_sent: false,
    created_windows: 0,
    modifiers: @core.ModifiersState::none(),
    cursor_grab_mode: @core.CursorGrabMode::None,
    cursor_index: 0,
    custom_cursor_index: 0,
    custom_cursors: [],
    animated_fill_window_ids: [],
    continuous_redraw_window_ids: [],
    emit_surface_size_window_ids: [],
    occluded_window_ids: [],
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
  println("  Alt+Left drag-resize (south-east)")
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
) -> @core.WindowId {
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
  let window = event_loop.create_window(window_attributes)
  let window_id = window.id()
  self.windows.push(window)
  self.created_windows += 1
  println("Created window #\{self.created_windows}: \{window_id}")
  match self.window_by_id(window_id) {
    Some(created_window) => created_window.request_redraw()
    None => ()
  }
  window_id
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
  remove_window_id(self.animated_fill_window_ids, window_id)
  remove_window_id(self.continuous_redraw_window_ids, window_id)
  remove_window_id(self.emit_surface_size_window_ids, window_id)
  remove_window_id(self.occluded_window_ids, window_id)
}

///|
fn Application::action_from_key(
  self : Application,
  key_event : @core.KeyEvent,
) -> Action? {
  let key = key_event.key_without_modifiers()
  match key {
    @core.Key::Named(@core.NamedKey::Escape) => Some(Action::CloseWindow)
    @core.Key::Character("q") | @core.Key::Character("Q") =>
      if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::CloseWindow)
      } else {
        None
      }
    @core.Key::Character("h") | @core.Key::Character("H") =>
      if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::PrintHelp)
      } else {
        None
      }
    @core.Key::Character("n") | @core.Key::Character("N") =>
      if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::CreateNewWindow)
      } else {
        None
      }
    @core.Key::Character("f") | @core.Key::Character("F") =>
      if modifiers_match(self.modifiers, false, false, true, false) {
        Some(Action::ToggleAnimatedFillColor)
      } else if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::ToggleFullscreen)
      } else if modifiers_match(self.modifiers, false, true, false, false) {
        Some(Action::ToggleSimpleFullscreen)
      } else {
        None
      }
    @core.Key::Character("d") | @core.Key::Character("D") =>
      if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::ToggleDecorations)
      } else {
        None
      }
    @core.Key::Character("l") | @core.Key::Character("L") =>
      if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::CycleCursorGrab)
      } else {
        None
      }
    @core.Key::Character("p") | @core.Key::Character("P") =>
      if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::ToggleResizeIncrements)
      } else {
        None
      }
    @core.Key::Character("r") | @core.Key::Character("R") =>
      if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::ToggleResizable)
      } else if modifiers_match(self.modifiers, false, true, false, false) {
        Some(Action::RequestResize)
      } else if modifiers_match(self.modifiers, false, false, true, false) {
        Some(Action::ToggleContinuousRedraw)
      } else {
        None
      }
    @core.Key::Character("m") | @core.Key::Character("M") =>
      if modifiers_match(self.modifiers, true, true, false, false) {
        Some(Action::DumpMonitors)
      } else if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::ToggleMaximize)
      } else if modifiers_match(self.modifiers, false, true, false, false) {
        Some(Action::Minimize)
      } else {
        None
      }
    @core.Key::Character("c") | @core.Key::Character("C") =>
      if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::NextCursor)
      } else if modifiers_match(self.modifiers, false, true, false, false) {
        Some(Action::NextCustomCursor)
      } else {
        None
      }
    @core.Key::Character("z") | @core.Key::Character("Z") =>
      if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::ToggleCursorVisibility)
      } else {
        None
      }
    @core.Key::Character("k") | @core.Key::Character("K") =>
      if modifiers_match(self.modifiers, false, false, false, false) {
        Some(Action::SetTheme(None))
      } else if modifiers_match(self.modifiers, false, false, false, true) {
        Some(Action::SetTheme(Some(@core.Theme::Light)))
      } else if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::SetTheme(Some(@core.Theme::Dark)))
      } else {
        None
      }
    @core.Key::Character("t") | @core.Key::Character("T") =>
      if modifiers_match(self.modifiers, false, false, false, true) {
        Some(Action::CreateNewTab)
      } else {
        None
      }
    @core.Key::Character("o") | @core.Key::Character("O") =>
      if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::CycleOptionAsAlt)
      } else {
        None
      }
    @core.Key::Character("b") | @core.Key::Character("B") =>
      if modifiers_match(self.modifiers, true, false, false, false) {
        Some(Action::ToggleBorderlessGame)
      } else {
        None
      }
    @core.Key::Character("s") | @core.Key::Character("S") =>
      if modifiers_match(self.modifiers, false, true, false, false) {
        Some(Action::EmitSurfaceSize)
      } else if modifiers_match(self.modifiers, true, false, false, false) {
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
      self.cursor_index = (self.cursor_index + 1) % cursors.length()
      window.set_cursor_icon(cursors[self.cursor_index])
    }
    Action::NextCustomCursor =>
      if self.custom_cursors.is_empty() {
        println("No custom cursor available on this platform/runtime")
      } else {
        self.custom_cursor_index = (self.custom_cursor_index + 1) %
          self.custom_cursors.length()
        window.set_cursor(
          @core.Cursor::Custom(self.custom_cursors[self.custom_cursor_index]),
        )
      }
    Action::CycleCursorGrab => {
      let next_mode = match self.cursor_grab_mode {
        @core.CursorGrabMode::None => @core.CursorGrabMode::Locked
        @core.CursorGrabMode::Locked => @core.CursorGrabMode::Confined
        @core.CursorGrabMode::Confined => @core.CursorGrabMode::None
      }
      try {
        window.set_cursor_grab(next_mode)
        self.cursor_grab_mode = next_mode
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
      let enabled = toggle_window_id(self.animated_fill_window_ids, window_id)
      println("Animated fill on \{window_id}: \{enabled}")
    }
    Action::ToggleContinuousRedraw => {
      let enabled = toggle_window_id(
        self.continuous_redraw_window_ids,
        window_id,
      )
      println("Continuous redraw on \{window_id}: \{enabled}")
    }
    Action::EmitSurfaceSize => {
      let enabled = toggle_window_id(
        self.emit_surface_size_window_ids,
        window_id,
      )
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
        Some(proxy) => proxy.wake_up()
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
  let button = match source {
    @core.ButtonSource::Mouse(mouse_button) => Some(mouse_button)
    _ => None
  }
  match (button, self.window_by_id(window_id)) {
    (Some(@core.MouseButton::Left), Some(window)) =>
      if modifiers_match(self.modifiers, true, false, false, false) {
        window.drag_window() catch {
          err => println("Drag window failed: \{err}")
        }
      } else if modifiers_match(self.modifiers, false, true, false, false) {
        window.drag_resize_window(@core.ResizeDirection::SouthEast) catch {
          err => println("Drag resize failed: \{err}")
        }
      }
    (Some(@core.MouseButton::Right), Some(window)) =>
      if modifiers_match(self.modifiers, true, false, false, false) {
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
pub impl @macos.ApplicationHandler for Application with can_create_surfaces(
  self,
  event_loop,
) {
  self.proxy = Some(event_loop.create_proxy())
  self.load_custom_cursors(event_loop)
  self.create_window(event_loop, "Winit window", None) |> ignore
  self.print_help()
}

///|
pub impl @macos.ApplicationHandler for Application with proxy_wake_up(
  self,
  event_loop,
) {
  println("Received proxy wake-up")
  if self.windows.length() == 1 {
    self.create_window(event_loop, "proxy wake-up window", None) |> ignore
  }
  for window_id in self.emit_surface_size_window_ids {
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

///|
pub impl @macos.ApplicationHandler for Application with about_to_wait(
  self,
  event_loop,
) {
  if !self.proxy_sent {
    match self.proxy {
      Some(proxy) => {
        proxy.wake_up()
        self.proxy_sent = true
      }
      None => ()
    }
  }

  for window_id in self.continuous_redraw_window_ids {
    match self.window_by_id(window_id) {
      Some(window) => window.request_redraw()
      None => ()
    }
  }

  if self.continuous_redraw_window_ids.is_empty() {
    event_loop.set_control_flow(@core.ControlFlow::Wait)
  } else {
    event_loop.set_control_flow(@core.ControlFlow::Poll)
  }

  if self.windows.is_empty() {
    event_loop.exit()
  }
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
      println("Window \{window_id} focus=\{focused}")
    @core.WindowEvent::Occluded(occluded) =>
      if occluded {
        if !contains_window_id(self.occluded_window_ids, window_id) {
          self.occluded_window_ids.push(window_id)
        }
      } else {
        remove_window_id(self.occluded_window_ids, window_id)
        match self.window_by_id(window_id) {
          Some(window) => window.request_redraw()
          None => ()
        }
      }
    @core.WindowEvent::ThemeChanged(theme) =>
      println("Window \{window_id} theme=\{theme}")
    @core.WindowEvent::ModifiersChanged(modifiers) =>
      self.modifiers = modifiers.state()
    @core.WindowEvent::PointerButton(
      _device_id,
      state,
      position,
      _is_primary,
      source
    ) => self.handle_pointer_binding(window_id, state, position, source)
    @core.WindowEvent::KeyboardInput(_device_id, key_event, is_synthetic) =>
      if !is_synthetic && key_event.state() is @core.ElementState::Pressed {
        match self.action_from_key(key_event) {
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
      if contains_window_id(self.occluded_window_ids, window_id) {
        ()
      } else {
        match self.window_by_id(window_id) {
          Some(window) =>
            if contains_window_id(self.animated_fill_window_ids, window_id) {
              @util.fill_window_with_animated_color(window, 0)
            } else {
              @util.fill_window(window)
            }
          None => ()
        }
      }
    _ => ()
  }
}

///|
fn main {
  @util.tracing_init()
  let event_loop = @macos.EventLoop::new()
  event_loop.run_app(Application::new())
}
