///|
// Port target: winit-reference/winit/examples/run_on_demand.rs
struct App {
  run_index : Ref[Int]
  frame_count : Ref[Int]
  mut window : @macos.Window?
}

///|
pub impl @macos.ApplicationHandler for App with can_create_surfaces(
  self,
  event_loop,
) {
  let title = "run_on_demand run #\{self.run_index.val}"
  let attrs = @core.WindowAttributes::default()
    .with_title(title)
    .with_surface_size(@dpi.LogicalSize::new(160.0, 120.0).into_size())
  let window = event_loop.create_window(attrs)
  self.window = Some(window)
}

///|
pub impl @macos.ApplicationHandler for App with about_to_wait(self, _event_loop) {
  match self.window {
    Some(window) => window.request_redraw()
    None => ()
  }
}

///|
pub impl @macos.ApplicationHandler for App with window_event(
  self,
  event_loop,
  _window_id,
  event,
) {
  match event {
    @core.WindowEvent::Destroyed => self.window = None
    @core.WindowEvent::CloseRequested => event_loop.exit()
    @core.WindowEvent::RedrawRequested =>
      match self.window {
        Some(window) => {
          @util.fill_window(window)
          self.frame_count.val += 1
          if self.frame_count.val >= 30 {
            println(
              "run #\{self.run_index.val} reached \{self.frame_count.val} frames; exiting this run",
            )
            event_loop.exit()
          }
        }
        None => ()
      }
    _ => ()
  }
}

///|
fn main {
  @util.tracing_init()
  let event_loop = @macos.EventLoop::new()
  let run_index = Ref::new(1)
  let frame_count = Ref::new(0)
  let app : App = { run_index, frame_count, window: None }

  event_loop.run_app_on_demand(app)
  println("Finished first run")
  println("Waiting before second run (upstream waits 5 seconds)")

  run_index.val = 2
  frame_count.val = 0
  event_loop.run_app_on_demand(app)
  println("Finished second run")
}
