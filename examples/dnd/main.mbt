///|
struct Application {
  mut window : @macos.Window?
}

///|
fn Application::new() -> Application {
  { window: None }
}

///|
pub impl @macos.ApplicationHandler for Application with can_create_surfaces(
  self,
  event_loop,
) {
  let window_attributes = @core.WindowAttributes::default().with_title(
    "Drag and drop files on me",
  )
  let window = event_loop.create_window(window_attributes)
  self.window = Some(window)
}

///|
pub impl @macos.ApplicationHandler for Application with about_to_wait(
  self,
  _event_loop,
) {
  match self.window {
    Some(window) => window.request_redraw()
    None => ()
  }
}

///|
pub impl @macos.ApplicationHandler for Application with window_event(
  self,
  event_loop,
  _window_id,
  event,
) {
  for compat_event in event.into_winit_events() {
    match compat_event {
      @core.WinitWindowEvent::DroppedFile(path) =>
        println("Dropped file: \{path}")
      @core.WinitWindowEvent::HoveredFile(path) =>
        println("Hovered file: \{path}")
      @core.WinitWindowEvent::HoveredFileCancelled =>
        println("File hover cancelled")
      _ => ()
    }
  }

  match event {
    @core.WindowEvent::CloseRequested => {
      println("Close requested; exiting")
      event_loop.exit()
    }
    @core.WindowEvent::DragEntered(paths, position) =>
      println("Drag entered at \{position}: \{paths}")
    @core.WindowEvent::DragMoved(position) => println("Drag moved: \{position}")
    @core.WindowEvent::DragDropped(paths, position) =>
      println("Dropped at \{position}: \{paths}")
    @core.WindowEvent::DragLeft(position) => println("Drag left: \{position}")
    @core.WindowEvent::RedrawRequested =>
      match self.window {
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
