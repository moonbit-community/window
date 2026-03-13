///|
// Port target: winit-reference/winit/examples/pump_events.rs
struct PumpDemo {
  mut window : @macos.Window?
  mut redraw_count : Int
}

///|
fn PumpDemo::new() -> PumpDemo {
  { window: None, redraw_count: 0 }
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
          self.redraw_count += 1
          @util.fill_window(window)
          window.request_redraw()
          if self.redraw_count % 30 == 0 {
            println("redraw_count=\{self.redraw_count}")
          }
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
    match event_loop.pump_app_events(Some(0), app) {
      @core.PumpStatus::Continue =>
        // The upstream example sleeps briefly to simulate application work.
        println("Update()")
      @core.PumpStatus::Exit(exit_code) => {
        println("Pump exited with code \{exit_code}")
        done = true
      }
    }
  }
}

///|
fn main {
  @util.tracing_init()
  let event_loop = @macos.EventLoop::new()
  event_loop.set_control_flow(@core.ControlFlow::Poll)
  let app = PumpDemo::new()
  pump_loop(event_loop, app)
}
