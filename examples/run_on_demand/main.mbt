///|
// Port target: winit-reference/winit/examples/run_on_demand.rs
struct App {
  mut run_index : Int
  mut window_id : @core.WindowId?
  mut window : @macos.Window?
}

///|
pub impl @macos.ApplicationHandler for App with can_create_surfaces(
  self,
  event_loop,
) {
  let title = "Fantastic window number one!"
  let attrs = @core.WindowAttributes::default()
    .with_title(title)
    .with_surface_size(@dpi.LogicalSize::new(128.0, 128.0).into_size())
  let window = event_loop.create_window(attrs)
  self.window_id = Some(window.id())
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
  window_id,
  event,
) {
  match event {
    @core.WindowEvent::Destroyed =>
      match self.window_id {
        Some(current_window_id) =>
          if current_window_id == window_id {
            println(
              "--------------------------------------------------------- Window \{self.run_index} Destroyed",
            )
            self.window_id = None
            self.window = None
            event_loop.exit()
          }
        None => ()
      }
    @core.WindowEvent::CloseRequested =>
      match self.window {
        Some(window) => {
          println(
            "--------------------------------------------------------- Window \{self.run_index} CloseRequested",
          )
          @util.cleanup_window(window)
          self.window = None
        }
        None => ()
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
  let app : App = { run_index: 1, window_id: None, window: None }

  event_loop.run_app_on_demand(app)
  println(
    "--------------------------------------------------------- Finished first loop",
  )
  println(
    "--------------------------------------------------------- Waiting 5 seconds",
  )
  @util.sleep_millis(5000)

  app.run_index += 1
  event_loop.run_app_on_demand(app)
  println(
    "--------------------------------------------------------- Finished second loop",
  )
}
