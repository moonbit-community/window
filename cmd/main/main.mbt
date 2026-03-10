///|
struct App {
  mut window : @macos.Window?
}

///|
pub impl @macos.ApplicationHandler for App with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(@core.WindowAttributes::default())
  self.window = Some(window)
  window.request_redraw()
}

///|
pub impl @macos.ApplicationHandler for App with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  for compat_event in event.into_winit_events() {
    match compat_event {
      @core.WinitWindowEvent::CloseRequested => event_loop.exit()
      @core.WinitWindowEvent::Resized(_) =>
        match self.window {
          Some(window) => window.request_redraw()
          None => ()
        }
      @core.WinitWindowEvent::RedrawRequested => println("redraw requested")
      _ => ()
    }
  }
}

///|
fn main {
  let event_loop = @macos.EventLoop::new()
  event_loop.run_app({ window: None })
}
