///|
// Port target: winit-reference/winit/examples/dnd.rs
struct Application {
  mut window : @macos.Window?
}

///|
fn Application::Application() -> Application {
  { window: None }
}

///|
pub impl @macos.ApplicationHandler for Application with fn can_create_surfaces(
  self,
  event_loop,
) {
  let window_attributes = @core.WindowAttributes::default().with_title(
    "Drag and drop files on me!",
  )
  let window = event_loop.create_window(window_attributes)
  self.window = Some(window)
}

///|
pub impl @macos.ApplicationHandler for Application with fn window_event(
  self,
  event_loop,
  _window_id,
  event,
) {
  match event {
    DragEntered(_, _) | DragMoved(_) | DragDropped(_, _) | DragLeft(_) =>
      println("\{event}")
    RedrawRequested =>
      match self.window {
        Some(window) => {
          window.pre_present_notify()
          @util.fill_window(window)
        }
        None => ()
      }
    CloseRequested => event_loop.exit()
    _ => ()
  }
}

///|
fn main {
  @util.tracing_init()
  let event_loop = @macos.EventLoop::EventLoop()
  event_loop.run_app(Application::Application())
}
