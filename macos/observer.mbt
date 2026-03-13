///|
// Port target: winit-reference/winit-appkit/src/observer.rs

///|
priv struct EventLoopWaker {
  mut next_fire_date_ms : Int64?
}

///|
fn EventLoopWaker::new() -> EventLoopWaker {
  { next_fire_date_ms: None }
}

///|
fn EventLoopWaker::update_next_fire_date(
  self : EventLoopWaker,
  next_fire_date_ms : Int64?,
  wake_on_change : Bool,
) -> Unit {
  if self.next_fire_date_ms != next_fire_date_ms {
    self.next_fire_date_ms = next_fire_date_ms
    if wake_on_change || next_fire_date_ms is Some(_) {
      wakeup_main_loop()
    }
  }
}

///|
fn EventLoopWaker::stop(self : EventLoopWaker) -> Unit {
  self.update_next_fire_date(None, false)
}

///|
// Port target: observer.rs::wakeup_main_loop
fn wakeup_main_loop() -> Unit {
  native_event_loop_wake_up()
}

///|
fn EventLoopWaker::start(self : EventLoopWaker) -> Unit {
  let now = runtime_now_ms()
  if self.next_fire_date_ms != Some(now) {
    self.next_fire_date_ms = Some(now)
    wakeup_main_loop()
  }
}

///|
fn EventLoopWaker::start_at(self : EventLoopWaker, instant_ms : Int64?) -> Unit {
  let now = runtime_now_ms()
  match instant_ms {
    Some(instant_ms) if now >= instant_ms => self.start()
    Some(instant_ms) => self.update_next_fire_date(Some(instant_ms), false)
    None => self.stop()
  }
}

///|
fn EventLoopWaker::next_fire_date(self : EventLoopWaker) -> Int64? {
  self.next_fire_date_ms
}
