///|
struct App {
  mut window : @macos.Window?
}

///|
pub impl @macos.ApplicationHandler for App with can_create_surfaces(
  self,
  event_loop,
) {
  let window_attributes = @core.WindowAttributes::default().with_title(
    "winit/window example (MoonBit)",
  )
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
        Some(window) => {
          window.pre_present_notify()
          println("Redraw requested")
        }
        None => ()
      }
    _ => ()
  }
}

///|
fn main {
  let event_loop = @macos.EventLoop::new()
  event_loop.run_app({ window: None })
}
