///|
pub struct Window {
  priv id : @core.WindowId
} derive(Eq, Show)

///|
pub struct EventLoopProxy {
  priv _unit : Unit
} derive(Eq, Show)

///|
pub fn EventLoopProxy::wake_up(_self : EventLoopProxy) -> Unit {
  native_event_loop_wake_up()
}

///|
pub fn Window::id(self : Window) -> @core.WindowId {
  self.id
}

///|
pub fn Window::surface_size(self : Window) -> @dpi.PhysicalSize {
  @dpi.PhysicalSize::new(
    native_window_width(self.id.into_raw()),
    native_window_height(self.id.into_raw()),
  )
}

///|
pub fn Window::request_redraw(self : Window) -> Unit {
  native_window_request_redraw(self.id.into_raw())
}

///|
pub fn Window::set_title(self : Window, title : String) -> Unit {
  set_title(self.id.into_raw(), title)
}

///|
pub fn Window::set_visible(self : Window, visible : Bool) -> Unit {
  native_set_visible(self.id.into_raw(), visible)
}

///|
pub fn Window::set_resizable(self : Window, resizable : Bool) -> Unit {
  native_set_resizable(self.id.into_raw(), resizable)
}

///|
pub fn Window::theme(_self : Window) -> @core.Theme? {
  None
}

///|
pub struct EventLoop {
  priv mut control_flow_ : @core.ControlFlow
  priv mut exit_requested : Bool
  priv mut window_ids : Array[Int]
} derive(Show)

///|
pub fn EventLoop::new() -> EventLoop {
  guard backend_available() else {
    abort("macos backend is unavailable on this target")
  }
  reset_proxy_wake_state()
  {
    control_flow_: @core.ControlFlow::Wait,
    exit_requested: false,
    window_ids: [],
  }
}

///|
pub fn EventLoop::create_window(
  self : EventLoop,
  attributes : @core.WindowAttributes,
) -> Window {
  let size = match attributes.surface_size() {
    Some(size) => size
    None => @dpi.PhysicalSize::new(800, 600)
  }
  let raw_id = create_window(
    size.width(),
    size.height(),
    attributes.visible(),
    attributes.resizable(),
    attributes.title(),
  )
  guard raw_id > 0 else { abort("failed to create macos window") }
  self.window_ids.push(raw_id)
  { id: @core.WindowId::from_raw(raw_id) }
}

///|
pub fn EventLoop::set_control_flow(
  self : EventLoop,
  control_flow : @core.ControlFlow,
) -> Unit {
  self.control_flow_ = control_flow
}

///|
pub fn EventLoop::control_flow(self : EventLoop) -> @core.ControlFlow {
  self.control_flow_
}

///|
pub fn EventLoop::create_proxy(_self : EventLoop) -> EventLoopProxy {
  { _unit: () }
}

///|
pub fn EventLoop::exit(self : EventLoop) -> Unit {
  self.exit_requested = true
}

///|
pub fn EventLoop::exiting(self : EventLoop) -> Bool {
  self.exit_requested
}

///|
pub(open) trait ApplicationHandler {
  new_events(Self, EventLoop, @core.StartCause) -> Unit = _
  can_create_surfaces(Self, EventLoop) -> Unit = _
  proxy_wake_up(Self, EventLoop) -> Unit = _
  window_event(Self, EventLoop, @core.WindowId, @core.WindowEvent) -> Unit = _
  about_to_wait(Self, EventLoop) -> Unit = _
}

///|
impl ApplicationHandler with new_events(_self, _event_loop, _cause) {
  ()
}

///|
impl ApplicationHandler with can_create_surfaces(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with proxy_wake_up(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with window_event(_self, _event_loop, _id, _event) {
  ()
}

///|
impl ApplicationHandler with about_to_wait(_self, _event_loop) {
  ()
}

///|
fn EventLoop::has_open_windows(self : EventLoop) -> Bool {
  for raw_id in self.window_ids {
    if native_window_should_close(raw_id) == false {
      return true
    }
  }
  false
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_window_events(
  self : EventLoop,
  app : A,
) -> Unit {
  let mut polled = false
  for raw_id in self.window_ids {
    if polled == false {
      native_poll_window(raw_id)
      polled = true
    }
    let window_id = @core.WindowId::from_raw(raw_id)
    if native_window_take_surface_resized(raw_id) {
      let size = @dpi.PhysicalSize::new(
        native_window_width(raw_id),
        native_window_height(raw_id),
      )
      app.window_event(self, window_id, @core.WindowEvent::SurfaceResized(size))
    }
    if native_window_take_redraw_requested(raw_id) {
      app.window_event(self, window_id, @core.WindowEvent::RedrawRequested)
    }
    if native_window_take_close_requested(raw_id) {
      app.window_event(self, window_id, @core.WindowEvent::CloseRequested)
    }
    if self.exit_requested {
      return
    }
  }
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_proxy_wake_up(
  self : EventLoop,
  app : A,
) -> Unit {
  if native_event_loop_take_proxy_wake_up() {
    app.proxy_wake_up(self)
  }
}

///|
fn EventLoop::wait_next_iteration(self : EventLoop) -> @core.StartCause {
  match self.control_flow_ {
    @core.ControlFlow::Poll => @core.StartCause::Poll
    @core.ControlFlow::Wait => {
      let start_ms = runtime_now_ms()
      let _ = wait_for_events(-1)
      @core.StartCause::WaitCancelled(start_ms, None)
    }
    @core.ControlFlow::WaitUntil(timeout_ms) => {
      let start_ms = runtime_now_ms()
      let requested_resume_ms = start_ms + timeout_ms.to_int64()
      if timeout_ms <= 0 {
        @core.StartCause::ResumeTimeReached(start_ms, start_ms)
      } else if wait_for_events(timeout_ms) {
        @core.StartCause::ResumeTimeReached(start_ms, requested_resume_ms)
      } else {
        @core.StartCause::WaitCancelled(start_ms, Some(requested_resume_ms))
      }
    }
  }
}

///|
pub fn[A : ApplicationHandler] EventLoop::run_app(
  self : EventLoop,
  app : A,
) -> Unit {
  app.new_events(self, @core.StartCause::Init)
  app.can_create_surfaces(self)
  while self.exit_requested == false {
    self.dispatch_window_events(app)
    self.dispatch_proxy_wake_up(app)
    if self.exit_requested {
      break
    }
    app.about_to_wait(self)
    if self.exit_requested || self.has_open_windows() == false {
      break
    }
    app.new_events(self, self.wait_next_iteration())
  }
}
