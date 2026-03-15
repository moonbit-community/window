///|
fn reset_app_state_runtime_for_test() -> Unit {
  app_state_runtime.val = AppStateRuntime::new()
}

///|
fn callback_name_for_test(callback : DeferredCallback) -> String {
  match callback {
    DeferredCallback::DidFinishLaunching => "did_finish_launching"
    DeferredCallback::WillTerminate => "will_terminate"
    DeferredCallback::NewEvents(_) => "new_events"
    DeferredCallback::CanCreateSurfaces => "can_create_surfaces"
    DeferredCallback::AboutToWait => "about_to_wait"
    DeferredCallback::ProxyWakeUp => "proxy_wake_up"
    DeferredCallback::WindowEvent(_, _) => "window_event"
    DeferredCallback::ScaleFactorChanged(_, _, _, _, _) =>
      "scale_factor_changed"
    DeferredCallback::DeviceEvent(_) => "device_event"
    DeferredCallback::StandardKeyBinding(_, _) => "standard_key_binding"
  }
}

///|
fn callback_names_for_test(
  callbacks : Array[DeferredCallback],
) -> Array[String] {
  let names : Array[String] = []
  for callback in callbacks {
    names.push(callback_name_for_test(callback))
  }
  names
}

///|
fn active_event_loop_for_test() -> ActiveEventLoop {
  {
    inner: {
      did_finish_launching_observer_: (0 : Int).to_uint64(),
      will_terminate_observer_: (0 : Int).to_uint64(),
      before_waiting_observer_: (0 : Int).to_uint64(),
      after_waiting_observer_: (0 : Int).to_uint64(),
    },
  }
}

///|
let launch_init_callback_order_for_test : Ref[Array[String]] = Ref::new([])

///|
let launch_init_stop_flag_seen_for_test : Ref[Array[Bool]] = Ref::new([])

///|
struct LaunchInitCallbacksApp {}

///|
pub impl ApplicationHandler for LaunchInitCallbacksApp with new_events(
  _self,
  _event_loop,
  _cause,
) {
  launch_init_callback_order_for_test.val.push("new_events")
  launch_init_stop_flag_seen_for_test.val.push(
    app_state_runtime.val.stop_on_launch,
  )
}

///|
pub impl ApplicationHandler for LaunchInitCallbacksApp with can_create_surfaces(
  _self,
  _event_loop,
) {
  launch_init_callback_order_for_test.val.push("can_create_surfaces")
  launch_init_stop_flag_seen_for_test.val.push(
    app_state_runtime.val.stop_on_launch,
  )
}

///|
test "min_timeout_handles_none_and_picks_smaller_timeout" {
  assert_eq(min_timeout_ms(None, None), None)
  assert_eq(
    min_timeout_ms(Some((10 : Int).to_int64()), None),
    Some((10 : Int).to_int64()),
  )
  assert_eq(
    min_timeout_ms(None, Some((20 : Int).to_int64())),
    Some((20 : Int).to_int64()),
  )
  assert_eq(
    min_timeout_ms(Some((30 : Int).to_int64()), Some((20 : Int).to_int64())),
    Some((20 : Int).to_int64()),
  )
  assert_eq(
    min_timeout_ms(Some((5 : Int).to_int64()), Some((20 : Int).to_int64())),
    Some((5 : Int).to_int64()),
  )
}

///|
test "queue_unique_window_id_is_deduplicated" {
  let ids : Array[Int] = []
  app_state_queue_unique_window_id(ids, 7)
  app_state_queue_unique_window_id(ids, 7)
  app_state_queue_unique_window_id(ids, 8)
  assert_eq(ids, [7, 8])

  assert_true(app_state_take_window_id(ids, 7))
  assert_false(app_state_take_window_id(ids, 7))
  assert_eq(ids, [8])
}

///|
test "wait_cause_matches_control_flow" {
  reset_app_state_runtime_for_test()
  let start = runtime_now_ms() - (100 : Int).to_int64()
  app_state_runtime.val.start_time_ms = Some(start)

  app_state_set_control_flow(@core.ControlFlow::Poll)
  assert_eq(app_state_wait_cause(), @core.StartCause::Poll)

  app_state_set_control_flow(@core.ControlFlow::Wait)
  assert_eq(
    app_state_wait_cause(),
    @core.StartCause::WaitCancelled(start, None),
  )

  let future = runtime_now_ms() + (2000 : Int).to_int64()
  app_state_set_control_flow(@core.ControlFlow::WaitUntil(future))
  assert_eq(
    app_state_wait_cause(),
    @core.StartCause::WaitCancelled(start, Some(future)),
  )

  let past = runtime_now_ms() - (2000 : Int).to_int64()
  app_state_set_control_flow(@core.ControlFlow::WaitUntil(past))
  assert_eq(
    app_state_wait_cause(),
    @core.StartCause::ResumeTimeReached(start, past),
  )
}

///|
test "did_finish_launching_notification_is_deduplicated_in_queue" {
  reset_app_state_runtime_for_test()
  app_state_runtime.val.deferred_callbacks.push(
    DeferredCallback::DidFinishLaunching,
  )

  app_state_queue_did_finish_launching_notification()
  assert_eq(callback_names_for_test(app_state_runtime.val.deferred_callbacks), [
    "did_finish_launching",
  ])
}

///|
test "will_terminate_notification_is_deduplicated_in_queue" {
  reset_app_state_runtime_for_test()
  app_state_runtime.val.deferred_callbacks.push(DeferredCallback::WillTerminate)

  app_state_queue_will_terminate_notification()
  assert_eq(callback_names_for_test(app_state_runtime.val.deferred_callbacks), [
    "will_terminate",
  ])
}

///|
test "callbacks_requiring_running_are_ignored_when_not_running" {
  reset_app_state_runtime_for_test()
  app_state_queue_proxy_wake_up()
  assert_eq(app_state_runtime.val.deferred_callbacks.length(), 0)
}

///|
test "dispatch_registered_deferred_callbacks_keeps_order_when_running" {
  reset_app_state_runtime_for_test()
  let seen : Ref[Array[String]] = Ref::new([])
  app_state_runtime.val.dispatch_callback = Some(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
  })
  app_state_set_running(true)

  app_state_runtime.val.deferred_callbacks.push(DeferredCallback::ProxyWakeUp)
  app_state_runtime.val.deferred_callbacks.push(DeferredCallback::AboutToWait)
  app_state_dispatch_registered_deferred_callbacks()

  assert_eq(seen.val, ["proxy_wake_up", "about_to_wait"])
  assert_eq(app_state_runtime.val.deferred_callbacks.length(), 0)
}

///|
test "dispatch_registered_deferred_callbacks_dispatches_lifecycle_while_not_running" {
  reset_app_state_runtime_for_test()
  let seen : Ref[Array[String]] = Ref::new([])
  app_state_runtime.val.dispatch_callback = Some(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
  })
  app_state_set_running(false)

  app_state_runtime.val.deferred_callbacks.push(DeferredCallback::ProxyWakeUp)
  app_state_runtime.val.deferred_callbacks.push(DeferredCallback::WillTerminate)
  app_state_runtime.val.deferred_callbacks.push(
    DeferredCallback::DidFinishLaunching,
  )
  app_state_dispatch_registered_deferred_callbacks()

  assert_eq(seen.val, ["will_terminate", "did_finish_launching"])
  assert_eq(callback_names_for_test(app_state_runtime.val.deferred_callbacks), [
    "proxy_wake_up",
  ])
}

///|
test "did_finish_launching_keeps_stop_on_launch_until_init_dispatch" {
  reset_app_state_runtime_for_test()
  app_state_set_stop_on_launch(true)

  app_state_did_finish_launching()

  assert_true(app_state_is_launched())
  assert_true(app_state_runtime.val.stop_on_launch)
}

///|
test "did_finish_launching_and_dispatch_runs_init_before_stop_on_launch" {
  reset_app_state_runtime_for_test()
  launch_init_callback_order_for_test.val = []
  launch_init_stop_flag_seen_for_test.val = []
  app_state_set_stop_on_launch(true)

  app_state_did_finish_launching_and_dispatch(
    LaunchInitCallbacksApp::{  },
    active_event_loop_for_test(),
  )

  assert_eq(launch_init_callback_order_for_test.val, [
    "new_events", "can_create_surfaces",
  ])
  assert_eq(launch_init_stop_flag_seen_for_test.val, [true, true])
  assert_false(app_state_runtime.val.stop_on_launch)
}

///|
test "reentrant_redraw_requested_is_dropped" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  app_state_set_handler_in_use(true)
  let seen : Ref[Array[String]] = Ref::new([])
  app_state_runtime.val.dispatch_callback = Some(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
  })

  app_state_queue_window_callback(
    @core.WindowId::from_raw(1),
    @core.WindowEvent::RedrawRequested,
  )

  assert_eq(seen.val.length(), 0)
  assert_eq(app_state_runtime.val.deferred_callbacks.length(), 0)
}

///|
test "reentrant_non_redraw_window_event_is_queued" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  app_state_set_handler_in_use(true)
  let seen : Ref[Array[String]] = Ref::new([])
  app_state_runtime.val.dispatch_callback = Some(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
  })

  app_state_queue_window_callback(
    @core.WindowId::from_raw(1),
    @core.WindowEvent::Focused(true),
  )

  assert_eq(seen.val.length(), 0)
  assert_eq(callback_names_for_test(app_state_runtime.val.deferred_callbacks), [
    "window_event",
  ])
}

///|
test "before_waiting_dispatches_redraws_then_about_to_wait" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  let seen : Ref[Array[String]] = Ref::new([])
  app_state_runtime.val.dispatch_callback = Some(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
  })
  app_state_queue_redraw(7)
  app_state_queue_redraw(7)
  app_state_queue_redraw(8)

  app_state_on_before_waiting()

  assert_eq(seen.val, ["window_event", "window_event", "about_to_wait"])
  assert_eq(app_state_runtime.val.pending_redraw_window_ids.length(), 0)
  assert_true(app_state_runtime.val.start_time_ms is Some(_))
}

///|
test "after_waiting_dispatches_new_events_with_wait_cause" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  let captured_causes : Ref[Array[@core.StartCause]] = Ref::new([])
  app_state_runtime.val.dispatch_callback = Some(fn(callback) {
    match callback {
      DeferredCallback::NewEvents(cause) => captured_causes.val.push(cause)
      _ => ()
    }
  })
  let start = runtime_now_ms() - (20 : Int).to_int64()
  let requested_resume = runtime_now_ms() + (2000 : Int).to_int64()
  app_state_runtime.val.start_time_ms = Some(start)
  app_state_set_control_flow(@core.ControlFlow::WaitUntil(requested_resume))

  app_state_on_after_waiting()

  assert_eq(captured_causes.val, [
    @core.StartCause::WaitCancelled(start, Some(requested_resume)),
  ])
}

///|
test "queue_did_finish_launching_dispatches_init_when_handler_registered" {
  reset_app_state_runtime_for_test()
  launch_init_callback_order_for_test.val = []
  launch_init_stop_flag_seen_for_test.val = []
  app_state_set_dispatch_handler(
    LaunchInitCallbacksApp::{  },
    active_event_loop_for_test(),
  )

  app_state_queue_did_finish_launching_notification()

  assert_true(app_state_is_launched())
  assert_true(app_state_is_running())
  assert_eq(launch_init_callback_order_for_test.val, [
    "new_events", "can_create_surfaces",
  ])
  app_state_clear_dispatch_handler()
}

///|
test "handler_ready_requires_registered_dispatch_handler" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  app_state_set_handler_in_use(false)
  assert_false(app_state_handler_ready())

  app_state_runtime.val.dispatch_callback = Some(fn(_callback) {  })
  assert_true(app_state_handler_ready())
}

///|
test "before_waiting_noops_without_dispatch_handler" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  app_state_set_handler_in_use(false)
  app_state_set_control_flow(@core.ControlFlow::Wait)
  app_state_queue_redraw(1)

  app_state_on_before_waiting()

  assert_eq(app_state_runtime.val.pending_redraw_window_ids, [1])
  assert_true(app_state_runtime.val.start_time_ms is None)
}

///|
test "after_waiting_noops_without_dispatch_handler" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  app_state_set_handler_in_use(false)
  app_state_runtime.val.start_time_ms = Some((42 : Int).to_int64())
  app_state_set_control_flow(@core.ControlFlow::Poll)

  app_state_on_after_waiting()

  assert_eq(app_state_runtime.val.deferred_callbacks.length(), 0)
}
