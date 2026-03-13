///|
// Port target: winit-reference/winit/examples/window.rs
struct App {
  mut window : @macos.Window?
}

///|
pub impl @macos.ApplicationHandler for App with can_create_surfaces(
  self,
  event_loop,
) {
  let window_attributes = @core.WindowAttributes::default()
  let window = event_loop.create_window(window_attributes)
  self.window = Some(window)
}

///|
pub impl @macos.ApplicationHandler for App with window_event(
  self,
  event_loop,
  _window_id,
  event,
) {
  println("\{event}")
  match event {
    @core.WindowEvent::CloseRequested => {
      println("Close requested; exiting")
      event_loop.exit()
    }
    @core.WindowEvent::SurfaceResized(size) => {
      println("Resized to \{size.width()}x\{size.height()}")
      match self.window {
        Some(window) => window.request_redraw()
        None => ()
      }
    }
    @core.WindowEvent::RedrawRequested =>
      match self.window {
        Some(window) => @util.fill_window(window)
        None => ()
      }
    _ => ()
  }
}

///|
fn main {
  @util.tracing_init()
  let event_loop = @macos.EventLoop::new()
  event_loop.run_app({ window: None })
}
