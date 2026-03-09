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
  _self,
  event_loop,
) {
  runtime_now_set_for_test(200L)
  let attrs = @core.WindowAttributes::default().with_visible(false)
  let _ = event_loop.create_window(attrs)
  event_loop.set_control_flow(@core.ControlFlow::WaitUntil(20))
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
  let app = { causes: [], wake_requested: Ref::new(false) }
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
