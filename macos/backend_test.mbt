///|
test "macos backend is available on native" {
  assert_true(backend_available())
  let event_loop = EventLoop::new()
  assert_eq(event_loop.control_flow(), @core.ControlFlow::Wait)
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
