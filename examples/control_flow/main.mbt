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
fn ControlFlowDemo::new() -> ControlFlowDemo {
  {
    mode: Mode::Wait,
    request_redraw: false,
    wait_cancelled: false,
    close_requested: false,
    window: None,
  }
}

///|
pub impl @macos.ApplicationHandler for ControlFlowDemo with new_events(
  self,
  _event_loop,
  cause,
) {
  println("new_events: \{cause}")
  self.wait_cancelled = match cause {
    @core.StartCause::WaitCancelled(_, _) => self.mode == Mode::WaitUntil
    _ => false
  }
}

///|
pub impl @macos.ApplicationHandler for ControlFlowDemo with can_create_surfaces(
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
pub impl @macos.ApplicationHandler for ControlFlowDemo with window_event(
  self,
  _event_loop,
  _window_id,
  event,
) {
  println("\{event}")
  match event {
    @core.WindowEvent::CloseRequested => self.close_requested = true
    @core.WindowEvent::KeyboardInput(_device_id, key_event, _is_synthetic) =>
      if key_event.state() is @core.ElementState::Pressed {
        match key_event.logical_key() {
          @core.Key::Character("1") => {
            self.mode = Mode::Wait
            println("mode: \{self.mode}")
          }
          @core.Key::Character("2") => {
            self.mode = Mode::WaitUntil
            println("mode: \{self.mode}")
          }
          @core.Key::Character("3") => {
            self.mode = Mode::Poll
            println("mode: \{self.mode}")
          }
          @core.Key::Character("r") => {
            self.request_redraw = !self.request_redraw
            println("request_redraw: \{self.request_redraw}")
          }
          @core.Key::Named(@core.NamedKey::Escape) =>
            self.close_requested = true
          _ => ()
        }
      }
    @core.WindowEvent::RedrawRequested =>
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
pub impl @macos.ApplicationHandler for ControlFlowDemo with about_to_wait(
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
    Mode::Wait => event_loop.set_control_flow(@core.ControlFlow::Wait)
    Mode::WaitUntil =>
      if !self.wait_cancelled {
        event_loop.set_control_flow(
          @core.ControlFlow::wait_duration(@util.now_millis(), 100),
        )
      }
    Mode::Poll => {
      @util.sleep_millis(100)
      event_loop.set_control_flow(@core.ControlFlow::Poll)
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
  let event_loop = @macos.EventLoop::new()
  event_loop.run_app(ControlFlowDemo::new())
}
