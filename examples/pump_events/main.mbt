///|
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
    "pump_events example",
  )
  let window = event_loop.create_window(attrs)
  self.window = Some(window)
}

///|
pub impl @macos.ApplicationHandler for PumpDemo with about_to_wait(
  self,
  _event_loop,
) {
  match self.window {
    Some(window) => window.request_redraw()
    None => ()
  }
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
          window.pre_present_notify()
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
fn pump_loop(
  event_loop : @macos.EventLoop,
  app : PumpDemo,
  remaining_ticks : Int,
) -> Unit {
  if remaining_ticks <= 0 {
    event_loop.exit()
    let status = event_loop.pump_app_events(Some(0), app)
    println("Final pump status: \{status}")
    return
  }

  match event_loop.pump_app_events(Some(0), app) {
    @core.PumpStatus::Continue =>
      pump_loop(event_loop, app, remaining_ticks - 1)
    @core.PumpStatus::Exit(exit_code) =>
      println("Pump exited early with code \{exit_code}")
  }
}

///|
fn main {
  let event_loop = @macos.EventLoop::new()
  event_loop.set_control_flow(@core.ControlFlow::Poll)
  let app = PumpDemo::new()
  pump_loop(event_loop, app, 180)
}
