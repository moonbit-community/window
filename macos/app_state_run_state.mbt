///|
fn app_state_dispatch_with_registered_callback(
  callback : DeferredCallback,
) -> Bool {
  match app_state_runtime.val.dispatch_callback {
    Some(dispatch) => {
      app_state_runtime.val.event_handler_in_use = true
      dispatch(callback)
      app_state_runtime.val.event_handler_in_use = false
      true
    }
    None => false
  }
}

///|
fn app_state_has_dispatch_handler() -> Bool {
  app_state_runtime.val.dispatch_callback is Some(_)
}

///|
fn app_state_handler_in_use() -> Bool {
  app_state_runtime.val.event_handler_in_use
}

///|
fn app_state_dispatch_registered_deferred_callbacks() -> Unit {
  while app_state_handler_in_use() == false && app_state_has_dispatch_handler() {
    match app_state_take_next_dispatchable_callback() {
      Some(callback) =>
        if app_state_dispatch_with_registered_callback(callback) == false {
          return ()
        }
      None => return ()
    }
  }
}

///|
fn app_state_set_stop_before_wait(value : Bool) -> Unit {
  app_state_runtime.val.stop_before_wait = value
}

///|
fn app_state_set_stop_on_launch(value : Bool) -> Unit {
  app_state_runtime.val.stop_on_launch = value
}

///|
fn app_state_stop_before_wait() -> Bool {
  app_state_runtime.val.stop_before_wait
}

///|
fn app_state_set_stop_after_wait(value : Bool) -> Unit {
  app_state_runtime.val.stop_after_wait = value
}

///|
fn app_state_stop_after_wait() -> Bool {
  app_state_runtime.val.stop_after_wait
}

///|
fn app_state_set_stop_on_redraw(value : Bool) -> Unit {
  app_state_runtime.val.stop_on_redraw = value
}

///|
fn app_state_stop_on_redraw() -> Bool {
  app_state_runtime.val.stop_on_redraw
}

///|
fn app_state_take_stop_on_launch() -> Bool {
  if app_state_runtime.val.stop_on_launch {
    app_state_runtime.val.stop_on_launch = false
    true
  } else {
    false
  }
}

///|
fn app_state_is_launched() -> Bool {
  app_state_runtime.val.is_launched
}

///|
fn app_state_mark_launched() -> Bool {
  if app_state_runtime.val.is_launched {
    false
  } else {
    app_state_runtime.val.is_launched = true
    true
  }
}

///|
fn app_state_set_running(value : Bool) -> Unit {
  app_state_runtime.val.is_running = value
}

///|
fn app_state_is_running() -> Bool {
  app_state_runtime.val.is_running
}

///|
fn app_state_set_handler_in_use(value : Bool) -> Unit {
  app_state_runtime.val.event_handler_in_use = value
}

///|
fn app_state_handler_ready() -> Bool {
  app_state_is_running() &&
  !app_state_handler_in_use() &&
  app_state_has_dispatch_handler()
}

///|
fn app_state_exit() -> Unit {
  app_state_runtime.val.exit_requested = true
}

///|
fn app_state_clear_exit() -> Unit {
  app_state_runtime.val.exit_requested = false
}

///|
fn app_state_exiting() -> Bool {
  app_state_runtime.val.exit_requested
}

///|
fn app_state_will_terminate_handled() -> Bool {
  app_state_runtime.val.will_terminate_handled
}

///|
fn app_state_mark_will_terminate_handled() -> Unit {
  app_state_runtime.val.will_terminate_handled = true
}

///|
fn app_state_will_terminate() -> Unit {
  if app_state_will_terminate_handled() {
    return ()
  }
  app_state_mark_will_terminate_handled()
  notify_windows_of_exit()
  app_state_clear_dispatch_handler()
  app_state_deferred_queue_clear()
  app_state_internal_exit()
}

///|
fn app_state_internal_exit() -> Unit {
  app_state_set_running(false)
  app_state_set_handler_in_use(false)
  app_state_set_stop_on_redraw(false)
  app_state_set_stop_before_wait(false)
  app_state_set_stop_after_wait(false)
  app_state_runtime.val.waker.stop()
  app_state_runtime.val.wait_timeout_ms = None
  app_state_runtime.val.start_time_ms = None
  app_state_runtime.val.pending_redraw_window_ids = []
  clear_all_window_fullscreen_state()
}

///|
fn[A : ApplicationHandler] app_state_set_dispatch_handler(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  app_state_runtime.val.dispatch_callback = Some(fn(callback) {
    app_state_dispatch_callback(app, event_loop, callback)
  })
}

///|
fn app_state_clear_dispatch_handler() -> Unit {
  app_state_runtime.val.dispatch_callback = None
}

///|
fn[A : ApplicationHandler] app_state_with_handler(
  app : A,
  event_loop : ActiveEventLoop,
  callback : DeferredCallback,
) -> Unit {
  app_state_set_handler_in_use(true)
  app_state_dispatch_callback(app, event_loop, callback)
  app_state_set_handler_in_use(false)
}

///|
fn[A : ApplicationHandler] app_state_dispatch_deferred_callbacks(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  while !app_state_handler_in_use() {
    match app_state_take_next_dispatchable_callback() {
      Some(callback) => app_state_with_handler(app, event_loop, callback)
      None => return ()
    }
  }
}
