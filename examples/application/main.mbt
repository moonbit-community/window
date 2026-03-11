///|
struct Application {
  windows : Array[@macos.Window]
  mut proxy : @macos.EventLoopProxy?
  mut proxy_sent : Bool
  mut created_windows : Int
}

///|
fn Application::new() -> Application {
  { windows: [], proxy: None, proxy_sent: false, created_windows: 0 }
}

///|
fn Application::create_window(
  self : Application,
  event_loop : @macos.ActiveEventLoop,
  title : String,
) -> Unit {
  let window_attributes = @core.WindowAttributes::default()
    .with_title(title)
    .with_transparent(true)
  let window = event_loop.create_window(window_attributes)
  self.windows.push(window)
  self.created_windows += 1
  println("Created window #\{self.created_windows}: \{window.id()}")
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
fn Application::remove_window(
  self : Application,
  window_id : @core.WindowId,
) -> Unit {
  match self.windows.search_by(window => window.id() == window_id) {
    Some(index) => ignore(self.windows.remove(index))
    None => ()
  }
}

///|
pub impl @macos.ApplicationHandler for Application with can_create_surfaces(
  self,
  event_loop,
) {
  self.proxy = Some(event_loop.create_proxy())
  self.create_window(event_loop, "winit/application example (MoonBit)")
}

///|
pub impl @macos.ApplicationHandler for Application with proxy_wake_up(
  self,
  event_loop,
) {
  println("Received proxy wake-up")
  if self.windows.length() == 1 {
    self.create_window(event_loop, "proxy wake-up window")
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
  for window in self.windows {
    window.request_redraw()
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
    @core.WindowEvent::CloseRequested => {
      self.remove_window(window_id)
      if self.windows.is_empty() {
        event_loop.exit()
      }
    }
    @core.WindowEvent::Destroyed => {
      self.remove_window(window_id)
      if self.windows.is_empty() {
        event_loop.exit()
      }
    }
    @core.WindowEvent::KeyboardInput(_device_id, key_event, _is_synthetic) =>
      if key_event.state() is @core.ElementState::Pressed {
        match key_event.logical_key() {
          @core.Key::Character("n") | @core.Key::Character("N") =>
            self.create_window(event_loop, "extra window")
          @core.Key::Character("m") | @core.Key::Character("M") => {
            let monitor_count = event_loop.available_monitors().length()
            println("Monitor count: \{monitor_count}")
          }
          @core.Key::Named(@core.NamedKey::Escape) => event_loop.exit()
          _ => ()
        }
      }
    @core.WindowEvent::RedrawRequested =>
      match self.window_by_id(window_id) {
        Some(window) => window.pre_present_notify()
        None => ()
      }
    _ => ()
  }
}

///|
fn main {
  let event_loop = @macos.EventLoop::new()
  event_loop.run_app(Application::new())
}
