///|
test "macos backend is available on native" {
  assert_true(backend_available())
  let event_loop = EventLoop::new()
  assert_eq(event_loop.control_flow(), @core.ControlFlow::Wait)
}

///|
extern "C" fn runtime_now_set_for_test(ms : Int64) -> Unit = "mbw_runtime_now_ms_set_for_test"

///|
extern "C" fn runtime_now_clear_for_test() -> Unit = "mbw_runtime_now_ms_clear_for_test"

///|
extern "C" fn queue_focus_for_test(window_id : Int, focused : Bool) -> Unit = "mbw_test_window_queue_focused"

///|
extern "C" fn queue_scale_factor_changed_for_test(
  window_id : Int,
  scale_factor : Double,
  width : Int,
  height : Int,
) -> Unit = "mbw_test_window_queue_scale_factor_changed"

///|
struct StartCauseApp {
  causes : Array[@core.StartCause]
}

///|
impl ApplicationHandler for StartCauseApp with new_events(
  self,
  event_loop,
  cause,
) {
  self.causes.push(cause)
  if self.causes.length() >= 2 {
    event_loop.exit()
  }
}

///|
impl ApplicationHandler for StartCauseApp with can_create_surfaces(
  _self,
  event_loop,
) {
  runtime_now_set_for_test(100L)
  let attrs = @core.WindowAttributes::default().with_visible(false)
  let _ = event_loop.create_window(attrs)
  event_loop.set_control_flow(@core.ControlFlow::WaitUntil(5))
}

///|
struct WaitCancelledApp {
  causes : Array[@core.StartCause]
  wake_requested : Ref[Bool]
  control_flow : @core.ControlFlow
}

///|
impl ApplicationHandler for WaitCancelledApp with new_events(
  self,
  event_loop,
  cause,
) {
  self.causes.push(cause)
  if self.causes.length() >= 2 {
    event_loop.exit()
  }
}

///|
impl ApplicationHandler for WaitCancelledApp with can_create_surfaces(
  self,
  event_loop,
) {
  runtime_now_set_for_test(200L)
  let attrs = @core.WindowAttributes::default().with_visible(false)
  let _ = event_loop.create_window(attrs)
  event_loop.set_control_flow(self.control_flow)
}

///|
impl ApplicationHandler for WaitCancelledApp with about_to_wait(
  self,
  event_loop,
) {
  if self.wake_requested.val == false {
    self.wake_requested.val = true
    let proxy = event_loop.create_proxy()
    proxy.wake_up()
  }
}

///|
struct ProxyWakeApp {
  wake_seen : Ref[Bool]
}

///|
struct FocusApp {
  focused_values : Array[Bool]
}

///|
impl ApplicationHandler for FocusApp with can_create_surfaces(_self, event_loop) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_focus_for_test(window.id().into_raw(), true)
}

///|
impl ApplicationHandler for FocusApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::Focused(focused) => {
      self.focused_values.push(focused)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
struct ScaleFactorApp {
  seen_scale_factor : Ref[Double?]
  resized : Ref[@dpi.PhysicalSize?]
}

///|
impl ApplicationHandler for ScaleFactorApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_scale_factor_changed_for_test(window.id().into_raw(), 2.0, 1600, 1200)
}

///|
impl ApplicationHandler for ScaleFactorApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::ScaleFactorChanged(scale_factor, writer) => {
      self.seen_scale_factor.val = Some(scale_factor)
      writer.request_surface_size(@dpi.PhysicalSize::new(1200, 900))
    }
    @core.WindowEvent::SurfaceResized(size) => {
      self.resized.val = Some(size)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
struct DestroyedOnExitApp {
  destroyed_seen : Ref[Bool]
}

///|
impl ApplicationHandler for DestroyedOnExitApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let _ = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  event_loop.exit()
}

///|
impl ApplicationHandler for DestroyedOnExitApp with window_event(
  self,
  _event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::Destroyed => self.destroyed_seen.val = true
    _ => ()
  }
}

///|
impl ApplicationHandler for ProxyWakeApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let proxy = event_loop.create_proxy()
  proxy.wake_up()
}

///|
impl ApplicationHandler for ProxyWakeApp with proxy_wake_up(self, event_loop) {
  self.wake_seen.val = true
  event_loop.exit()
}

///|
test "event loop proxy wake up is delivered" {
  let wake_seen = Ref::new(false)
  let event_loop = EventLoop::new()
  event_loop.run_app({ wake_seen, })
  assert_true(wake_seen.val)
}

///|
test "new events reports init then wait-until timeout" {
  let event_loop = EventLoop::new()
  let app = { causes: [] }
  event_loop.run_app(app)
  runtime_now_clear_for_test()
  assert_eq(app.causes[0], @core.StartCause::Init)
  guard app.causes[1]
    is @core.StartCause::ResumeTimeReached(start_ms, requested_resume_ms) else {
    fail("expected ResumeTimeReached")
  }
  assert_eq(start_ms, 100L)
  assert_eq(requested_resume_ms, 105L)
}

///|
test "new events reports wait-until cancellation when proxy wakes" {
  let event_loop = EventLoop::new()
  let app = {
    causes: [],
    wake_requested: Ref::new(false),
    control_flow: @core.ControlFlow::WaitUntil(20),
  }
  event_loop.run_app(app)
  runtime_now_clear_for_test()
  assert_eq(app.causes[0], @core.StartCause::Init)
  guard app.causes[1]
    is @core.StartCause::WaitCancelled(start_ms, Some(requested_resume_ms)) else {
    fail("expected WaitCancelled with a requested resume time")
  }
  assert_eq(start_ms, 200L)
  assert_eq(requested_resume_ms, 220L)
}

///|
test "wait blocks on native wake source until proxy wake arrives" {
  let event_loop = EventLoop::new()
  let app = {
    causes: [],
    wake_requested: Ref::new(false),
    control_flow: @core.ControlFlow::Wait,
  }
  event_loop.run_app(app)
  runtime_now_clear_for_test()
  assert_eq(app.causes[0], @core.StartCause::Init)
  guard app.causes[1] is @core.StartCause::WaitCancelled(start_ms, None) else {
    fail("expected WaitCancelled without a timeout")
  }
  assert_eq(start_ms, 200L)
}

///|
test "focused events are delivered" {
  let event_loop = EventLoop::new()
  let app = { focused_values: [] }
  event_loop.run_app(app)
  assert_eq(app.focused_values, [true])
}

///|
test "scale factor changes can request a replacement surface size" {
  let event_loop = EventLoop::new()
  let seen_scale_factor = Ref::new(None)
  let resized = Ref::new(None)
  event_loop.run_app({ seen_scale_factor, resized })
  assert_eq(seen_scale_factor.val, Some(2.0))
  assert_eq(resized.val, Some(@dpi.PhysicalSize::new(1200, 900)))
}

///|
test "destroyed is delivered when the event loop exits" {
  let event_loop = EventLoop::new()
  let destroyed_seen = Ref::new(false)
  event_loop.run_app({ destroyed_seen, })
  assert_true(destroyed_seen.val)
}
