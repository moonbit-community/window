///|
// Port target: winit-reference/winit/examples/dnd.rs
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
    "Drag and drop files on me!",
  )
  let window = event_loop.create_window(window_attributes)
  self.window = Some(window)
}

///|
pub impl @macos.ApplicationHandler for Application with window_event(
  self,
  event_loop,
  _window_id,
  event,
) {
  match event {
    @core.WindowEvent::DragEntered(_, _)
    | @core.WindowEvent::DragMoved(_)
    | @core.WindowEvent::DragDropped(_, _)
    | @core.WindowEvent::DragLeft(_) => println("\{event}")
    @core.WindowEvent::RedrawRequested =>
      match self.window {
        Some(window) => {
          window.pre_present_notify()
          @util.fill_window(window)
        }
        None => ()
      }
    @core.WindowEvent::CloseRequested => event_loop.exit()
    _ => ()
  }
}

///|
fn main {
  @util.tracing_init()
  let event_loop = @macos.EventLoop::new()
  event_loop.run_app(Application::new())
}
