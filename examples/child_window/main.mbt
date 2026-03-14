///|
// Port target: winit-reference/winit/examples/child_window.rs
struct App {
  mut parent_window_id : @core.WindowId?
  windows : Array[WindowData]
}

///|
struct WindowData {
  window : @macos.Window
  color : Int
}

///|
fn App::new() -> App {
  { parent_window_id: None, windows: [] }
}

///|
fn int_pow(base : Int, exp : Int) -> Int {
  let mut value = 1
  let mut i = 0
  while i < exp {
    value = value * base
    i += 1
  }
  value
}

///|
fn child_color(child_index : Int) -> Int {
  (0xff000000 : Int) + int_pow(3, (child_index + 2) % 16)
}

///|
fn App::window_data_index(self : App, window_id : @core.WindowId) -> Int? {
  self.windows.search_by(entry => entry.window.id() == window_id)
}

///|
fn App::parent_window(self : App) -> @macos.Window? {
  match self.parent_window_id {
    Some(parent_window_id) =>
      match self.window_data_index(parent_window_id) {
        Some(index) => Some(self.windows[index].window)
        None => None
      }
    None => None
  }
}

///|
fn App::spawn_child_window(
  self : App,
  event_loop : @macos.ActiveEventLoop,
) -> Unit {
  match self.parent_window() {
    Some(parent_window) => {
      let child_index = self.windows.length() - 1
      let x = (child_index % 5).to_double() * 128.0
      let y = (child_index / 5).to_double() * 96.0
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
      let child_window_id = child_window.id()
      self.windows.push({
        window: child_window,
        color: child_color(child_index),
      })
      println("Child window created with id: \{child_window_id}")
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
  let parent_window_id = parent_window.id()
  self.parent_window_id = Some(parent_window_id)
  self.windows.push({ window: parent_window, color: 0xffbbbbbb })
  println("Parent window id: \{parent_window_id}")
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
    @core.WindowEvent::PointerEntered(_device_id, _position, _primary, _kind) =>
      println("cursor entered in the window \{window_id}")
    @core.WindowEvent::KeyboardInput(_device_id, key_event, _is_synthetic) =>
      if key_event.state() is @core.ElementState::Pressed {
        self.spawn_child_window(event_loop)
      }
    @core.WindowEvent::RedrawRequested =>
      match self.window_data_index(window_id) {
        Some(index) =>
          match self.parent_window_id {
            Some(parent_window_id) =>
              if parent_window_id == window_id {
                @util.fill_window(self.windows[index].window)
              } else {
                @util.fill_window_with_color(
                  self.windows[index].window,
                  self.windows[index].color,
                )
              }
            None =>
              @util.fill_window_with_color(
                self.windows[index].window,
                self.windows[index].color,
              )
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
