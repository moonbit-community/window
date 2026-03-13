///|
// Port target: winit-reference/winit/examples/child_window.rs
struct App {
  mut parent_window : @macos.Window?
  windows : Array[@macos.Window]
  mut child_count : Int
}

///|
fn App::new() -> App {
  { parent_window: None, windows: [], child_count: 0 }
}

///|
fn App::remove_window(self : App, window_id : @core.WindowId) -> Unit {
  match self.windows.search_by(window => window.id() == window_id) {
    Some(index) => ignore(self.windows.remove(index))
    None => ()
  }
}

///|
fn App::spawn_child_window(
  self : App,
  event_loop : @macos.ActiveEventLoop,
) -> Unit {
  match self.parent_window {
    Some(parent_window) => {
      let x = (self.child_count % 5).to_double() * 128.0
      let y = (self.child_count / 5).to_double() * 96.0
      let parent_raw = @core.ParentWindow::from_raw(
        parent_window.window_handle(),
      )
      let child_attrs = @core.WindowAttributes::default()
        .with_title("child window")
        .with_surface_size(@dpi.LogicalSize::new(128.0, 96.0).into_size())
        .with_position(@dpi.LogicalPosition::new(x, y).into_position())
        .with_visible(true)
        .with_parent_window(Some(parent_raw))
      let child_window = event_loop.create_window(child_attrs)
      self.windows.push(child_window)
      self.child_count += 1
      println("Child window created: \{child_window.id()}")
    }
    None => ()
  }
}

///|
pub impl @macos.ApplicationHandler for App with can_create_surfaces(
  self,
  event_loop,
) {
  let parent_attrs = @core.WindowAttributes::default()
    .with_title("parent window")
    .with_position(@dpi.LogicalPosition::new(0.0, 0.0).into_position())
    .with_surface_size(@dpi.LogicalSize::new(640.0, 480.0).into_size())
  let parent_window = event_loop.create_window(parent_attrs)
  self.parent_window = Some(parent_window)
  self.windows.push(parent_window)
  println("Parent window id: \{parent_window.id()}")
}

///|
pub impl @macos.ApplicationHandler for App with window_event(
  self,
  event_loop,
  window_id,
  event,
) {
  match event {
    @core.WindowEvent::CloseRequested => {
      self.windows.clear()
      event_loop.exit()
    }
    @core.WindowEvent::Destroyed => {
      self.remove_window(window_id)
      if self.windows.is_empty() {
        event_loop.exit()
      }
    }
    @core.WindowEvent::PointerEntered(_device_id, _position, _primary, _kind) =>
      println("Cursor entered window \{window_id}")
    @core.WindowEvent::KeyboardInput(_device_id, key_event, _is_synthetic) =>
      if key_event.state() is @core.ElementState::Pressed {
        self.spawn_child_window(event_loop)
      }
    @core.WindowEvent::RedrawRequested =>
      match self.windows.search_by(window => window.id() == window_id) {
        Some(index) =>
          if index == 0 {
            @util.fill_window(self.windows[index])
          } else {
            let color = (0xff000000 : Int) + ((index * 0x00010101) & 0x00ffffff)
            @util.fill_window_with_color(self.windows[index], color)
          }
        None => ()
      }
    _ => ()
  }
}

///|
pub impl @macos.ApplicationHandler for App with about_to_wait(
  _self,
  _event_loop,
) {
  ()
}

///|
fn main {
  @util.tracing_init()
  let event_loop = @macos.EventLoop::new()
  event_loop.run_app(App::new())
}
