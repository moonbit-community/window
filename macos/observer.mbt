///|
// Port target: winit-reference/winit-appkit/src/observer.rs

///|
pub struct EventLoopWaker {
  start_instant_ms : Int64
  mut next_fire_date_ms : Int64?
} derive(Eq, Show)

///|
pub fn EventLoopWaker::new() -> EventLoopWaker {
  { start_instant_ms: runtime_now_ms(), next_fire_date_ms: None }
}

///|
fn EventLoopWaker::update_next_fire_date(
  self : EventLoopWaker,
  next_fire_date_ms : Int64?,
  wake_on_change : Bool,
) -> Unit {
  if self.next_fire_date_ms != next_fire_date_ms {
    self.next_fire_date_ms = next_fire_date_ms
    if wake_on_change {
      native_event_loop_wake_up()
    }
  }
}

///|
pub fn EventLoopWaker::stop(self : EventLoopWaker) -> Unit {
  self.update_next_fire_date(None, false)
}

///|
pub fn EventLoopWaker::start(self : EventLoopWaker) -> Unit {
  self.update_next_fire_date(Some(self.start_instant_ms), true)
}

///|
pub fn EventLoopWaker::start_at(
  self : EventLoopWaker,
  instant_ms : Int64?,
) -> Unit {
  let now = runtime_now_ms()
  match instant_ms {
    Some(instant_ms) if now >= instant_ms => self.start()
    Some(instant_ms) =>
      // Current FFI exposes immediate wake only; keep target time for
      // higher-level scheduling while preserving waker state transitions.
      self.update_next_fire_date(Some(instant_ms), true)
    None => self.stop()
  }
}

///|
pub fn EventLoopWaker::next_fire_date_ms(self : EventLoopWaker) -> Int64? {
  self.next_fire_date_ms
}

///|
pub fn EventLoopWaker::is_stopped(self : EventLoopWaker) -> Bool {
  self.next_fire_date_ms is None
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_proxy_wake_up(
  self : EventLoop,
  app : A,
) -> Unit {
  let native_proxy_wake = native_event_loop_take_proxy_wake_up()
  let queued_proxy_wake = app_state_take_proxy_wake_up()
  if native_proxy_wake || queued_proxy_wake {
    app.proxy_wake_up(self.as_active())
  }
}
