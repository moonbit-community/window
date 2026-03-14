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
