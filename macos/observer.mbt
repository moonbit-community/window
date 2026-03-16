///|
// Port target: winit-reference/winit-appkit/src/observer.rs

///|
const MAIN_RUN_LOOP_ACTIVITY_BEFORE_WAITING : Int = 1

///|
const MAIN_RUN_LOOP_ACTIVITY_AFTER_WAITING : Int = 2

///|
const MAIN_RUN_LOOP_CALLBACK_BEFORE_WAITING : Int = 3

///|
const MAIN_RUN_LOOP_CALLBACK_AFTER_WAITING : Int = 4

///|
const MAIN_RUN_LOOP_ORDER_LOWEST : Int = 2147483647

///|
const MAIN_RUN_LOOP_ORDER_HIGHEST : Int = -2147483647 - 1

///|
fn create_main_run_loop_observer(
  activity_kind : Int,
  callback_kind : Int,
  order : Int,
) -> UInt64 {
  native_main_run_loop_add_observer(
    fn(callback, kind) { callback(kind) },
    native_callback_lifecycle,
    activity_kind,
    callback_kind,
    order,
  )
}

///|
fn create_before_waiting_observer() -> UInt64 {
  create_main_run_loop_observer(
    MAIN_RUN_LOOP_ACTIVITY_BEFORE_WAITING,
    MAIN_RUN_LOOP_CALLBACK_BEFORE_WAITING,
    MAIN_RUN_LOOP_ORDER_LOWEST,
  )
}

///|
fn create_after_waiting_observer() -> UInt64 {
  create_main_run_loop_observer(
    MAIN_RUN_LOOP_ACTIVITY_AFTER_WAITING,
    MAIN_RUN_LOOP_CALLBACK_AFTER_WAITING,
    MAIN_RUN_LOOP_ORDER_HIGHEST,
  )
}

///|
fn native_main_run_loop_remove_observer(observer_handle : UInt64) -> Unit {
  if observer_handle != (0 : Int).to_uint64() {
    appkit_main_run_loop_remove_observer(observer_handle)
  }
}

///|
fn release_main_run_loop_observer(observer_handle : UInt64) -> Unit {
  native_main_run_loop_remove_observer(observer_handle)
}

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
