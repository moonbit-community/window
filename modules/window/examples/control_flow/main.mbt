///|
// Port target: winit-reference/winit/examples/control_flow.rs
enum Mode {
  Wait
  WaitUntil
  Poll
} derive(Eq, Debug)

///|
struct ControlFlowDemo {
  mut mode : Mode
  mut request_redraw : Bool
  mut wait_cancelled : Bool
  mut close_requested : Bool
  mut window : @macos.Window?
}

///|
fn ControlFlowDemo::ControlFlowDemo() -> ControlFlowDemo {
  {
    mode: Wait,
    request_redraw: false,
    wait_cancelled: false,
    close_requested: false,
    window: None,
  }
}

///|
pub impl @macos.ApplicationHandler for ControlFlowDemo with fn new_events(
  self,
  _event_loop,
  cause,
) {
  println("new_events: \{cause}")
  self.wait_cancelled = match cause {
    WaitCancelled(_, _) => self.mode == WaitUntil
    _ => false
  }
}

///|
pub impl @macos.ApplicationHandler for ControlFlowDemo with fn can_create_surfaces(
  self,
  event_loop,
) {
  let window_attributes = @core.WindowAttributes::default().with_title(
    "Press 1, 2, 3 to change control flow mode. Press R to toggle redraw requests.",
  )
  let window = event_loop.create_window(window_attributes)
  self.window = Some(window)
}

///|
pub impl @macos.ApplicationHandler for ControlFlowDemo with fn window_event(
  self,
  _event_loop,
  _window_id,
  event,
) {
  println("\{event}")
  match event {
    CloseRequested => self.close_requested = true
    KeyboardInput(_device_id, key_event, _is_synthetic) =>
      if key_event.state() is Pressed {
        match key_event.logical_key() {
          Character("1") => {
            self.mode = Wait
            println("mode: \{self.mode}")
          }
          Character("2") => {
            self.mode = WaitUntil
            println("mode: \{self.mode}")
          }
          Character("3") => {
            self.mode = Poll
            println("mode: \{self.mode}")
          }
          Character("r") => {
            self.request_redraw = !self.request_redraw
            println("request_redraw: \{self.request_redraw}")
          }
          Named(Escape) => self.close_requested = true
          _ => ()
        }
      }
    RedrawRequested =>
      match self.window {
        Some(window) => {
          window.pre_present_notify()
          @util.fill_window(window)
        }
        None => ()
      }
    _ => ()
  }
}

///|
pub impl @macos.ApplicationHandler for ControlFlowDemo with fn about_to_wait(
  self,
  event_loop,
) {
  if self.request_redraw && !self.wait_cancelled && !self.close_requested {
    match self.window {
      Some(window) => window.request_redraw()
      None => ()
    }
  }

  match self.mode {
    Wait => event_loop.set_control_flow(Wait)
    WaitUntil =>
      if !self.wait_cancelled {
        event_loop.set_control_flow(
          @core.ControlFlow::wait_duration(@util.now_millis(), 100),
        )
      }
    Poll => {
      @util.sleep_millis(100)
      event_loop.set_control_flow(Poll)
    }
  }

  if self.close_requested {
    event_loop.exit()
  }
}

///|
fn main {
  @util.tracing_init()
  println("Press '1' to switch to Wait mode.")
  println("Press '2' to switch to WaitUntil mode.")
  println("Press '3' to switch to Poll mode.")
  println("Press 'R' to toggle request_redraw() calls.")
  println("Press 'Esc' to close the window.")
  let event_loop = @macos.EventLoop::EventLoop()
  event_loop.run_app(ControlFlowDemo::ControlFlowDemo())
}
