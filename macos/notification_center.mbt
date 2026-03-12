///|
// Port target: winit-reference/winit-appkit/src/notification_center.rs

///|
struct NotificationObserver {
  name : String
} derive(Eq, Show)

///|
let pending_notifications : Ref[Array[String]] = Ref::new([])

///|
// Port target: notification_center.rs::create_observer
pub fn create_observer(name : String) -> NotificationObserver {
  { name, }
}

///|
pub fn notification_center_notify(observer : NotificationObserver) -> Unit {
  pending_notifications.val.push(observer.name)
  native_event_loop_wake_up()
}

///|
fn notification_center_take_pending() -> Bool {
  if pending_notifications.val.length() == 0 {
    false
  } else {
    pending_notifications.val = []
    true
  }
}

///|
fn notification_center_wait_events(timeout_ms : Int) -> Bool {
  if notification_center_take_pending() {
    false
  } else {
    wait_for_events(timeout_ms)
  }
}

///|
fn EventLoop::wait_next_iteration(self : EventLoop) -> @core.StartCause {
  match self.control_flow_ {
    @core.ControlFlow::Poll => {
      let _ = notification_center_wait_events(0)
      @core.StartCause::Poll
    }
    @core.ControlFlow::Wait => {
      let start_ms = runtime_now_ms()
      let _ = notification_center_wait_events(-1)
      @core.StartCause::WaitCancelled(start_ms, None)
    }
    @core.ControlFlow::WaitUntil(requested_resume_ms) => {
      let start_ms = runtime_now_ms()
      let remaining_ms = requested_resume_ms - start_ms
      if remaining_ms <= 0L {
        @core.StartCause::ResumeTimeReached(start_ms, requested_resume_ms)
      } else if notification_center_wait_events(
          if remaining_ms > 2147483647L {
            2147483647
          } else {
            remaining_ms.to_int()
          },
        ) {
        @core.StartCause::ResumeTimeReached(start_ms, requested_resume_ms)
      } else {
        @core.StartCause::WaitCancelled(start_ms, Some(requested_resume_ms))
      }
    }
  }
}

///|
fn EventLoop::wait_for_timeout(
  self : EventLoop,
  timeout_ms : Int,
) -> @core.StartCause {
  let start_ms = runtime_now_ms()
  let app_timeout_ms = match self.control_flow_ {
    @core.ControlFlow::Poll => Some(0)
    @core.ControlFlow::Wait => None
    @core.ControlFlow::WaitUntil(requested_resume_ms) => {
      let remaining_ms = requested_resume_ms - start_ms
      if remaining_ms <= 0L {
        Some(0)
      } else if remaining_ms > 2147483647L {
        Some(2147483647)
      } else {
        Some(remaining_ms.to_int())
      }
    }
  }
  let external_timeout_ms = if timeout_ms <= 0 {
    Some(0)
  } else {
    Some(timeout_ms)
  }
  let effective_timeout_ms = match (external_timeout_ms, app_timeout_ms) {
    (Some(external), Some(app_timeout)) =>
      Some(if external < app_timeout { external } else { app_timeout })
    (Some(external), None) => Some(external)
    (None, Some(app_timeout)) => Some(app_timeout)
    (None, None) => None
  }
  match effective_timeout_ms {
    Some(effective_timeout_ms) => {
      let _ = notification_center_wait_events(effective_timeout_ms)
      ()
    }
    None => {
      let _ = notification_center_wait_events(-1)
      ()
    }
  }
  match self.control_flow_ {
    @core.ControlFlow::Poll => @core.StartCause::Poll
    @core.ControlFlow::Wait => @core.StartCause::WaitCancelled(start_ms, None)
    @core.ControlFlow::WaitUntil(requested_resume_ms) =>
      if runtime_now_ms() >= requested_resume_ms {
        @core.StartCause::ResumeTimeReached(start_ms, requested_resume_ms)
      } else {
        @core.StartCause::WaitCancelled(start_ms, Some(requested_resume_ms))
      }
  }
}
