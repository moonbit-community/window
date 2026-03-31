///|
// Port target: winit-reference/winit/examples/pump_events.rs
struct PumpDemo {
  mut window : @macos.Window?
}

///|
fn PumpDemo::new() -> PumpDemo {
  { window: None }
}

///|
pub impl @macos.ApplicationHandler for PumpDemo with can_create_surfaces(
  self,
  event_loop,
) {
  let attrs = @core.WindowAttributes::default().with_title(
    "A fantastic window!",
  )
  let window = event_loop.create_window(attrs)
  self.window = Some(window)
}

///|
pub impl @macos.ApplicationHandler for PumpDemo with window_event(
  self,
  event_loop,
  _window_id,
  event,
) {
  match event {
    @core.WindowEvent::CloseRequested => event_loop.exit()
    @core.WindowEvent::RedrawRequested =>
      match self.window {
        Some(window) => {
          @util.fill_window(window)
          window.request_redraw()
        }
        None => ()
      }
    _ => ()
  }
}

///|
fn pump_loop(event_loop : @macos.EventLoop, app : PumpDemo) -> Unit {
  let mut done = false
  while done == false {
    let timeout_ms = Some(0)
    match event_loop.pump_app_events(timeout_ms, app) {
      @core.PumpStatus::Continue => @util.sleep_millis(16)
      @core.PumpStatus::Exit(_exit_code) => done = true
    }
  }
}

///|
fn main {
  @util.tracing_init()
  let event_loop = @macos.EventLoop::new()
  let app = PumpDemo::new()
  pump_loop(event_loop, app)
}
