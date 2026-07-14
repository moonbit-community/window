///|
fn reset_app_state_runtime_for_test() -> Unit {
  app_state_runtime.val = AppStateRuntime()
  clear_all_window_fullscreen_state()
  app_state_window_position_raw_ids.val = []
  app_state_window_position_xs.val = []
  app_state_window_position_ys.val = []
}

///|
fn app_state_set_start_time_for_test(start_time_ms : Int64?) -> Unit {
  app_state_runtime.val.start_time_ms = start_time_ms
}

///|
fn app_state_start_time_for_test() -> Int64? {
  app_state_runtime.val.start_time_ms
}

///|
fn app_state_deferred_callbacks_for_test() -> Array[DeferredCallback] {
  app_state_runtime.val.deferred_callbacks
}

///|
fn app_state_deferred_callback_for_test(index : Int) -> DeferredCallback? {
  if index < 0 || index >= app_state_deferred_callbacks_for_test().length() {
    None
  } else {
    Some(app_state_deferred_callbacks_for_test()[index])
  }
}

///|
fn app_state_deferred_callback_count_for_test() -> Int {
  app_state_deferred_callbacks_for_test().length()
}

///|
fn app_state_register_window_identity_for_test(
  raw_id : Int,
  identity : UInt64,
) -> Unit {
  app_state_runtime.val.window_handles.push({
    raw_id,
    identity,
    native_handle: None,
  })
}

///|
fn app_state_queue_deferred_callback_for_test(
  callback : DeferredCallback,
) -> Unit {
  app_state_runtime.val.deferred_callbacks.push(callback)
}

///|
fn app_state_deferred_callback_names_for_test() -> Array[String] {
  callback_names_for_test(app_state_deferred_callbacks_for_test())
}

///|
fn app_state_pending_redraw_window_ids_for_test() -> Array[Int] {
  app_state_runtime.val.pending_redraw_window_ids
}

///|
fn app_state_set_dispatch_callback_for_test(
  callback : (DeferredCallback) -> Unit,
) -> Unit {
  app_state_runtime.val.dispatch_callback = Some(callback)
}

///|
fn app_state_has_dispatch_callback_for_test() -> Bool {
  app_state_runtime.val.dispatch_callback is Some(_)
}

///|
fn app_state_set_will_terminate_handled_for_test(handled : Bool) -> Unit {
  app_state_runtime.val.will_terminate_handled = handled
}

///|
fn app_state_stop_on_launch_for_test() -> Bool {
  app_state_runtime.val.stop_on_launch
}

///|
fn callback_name_for_test(callback : DeferredCallback) -> String {
  match callback {
    DidFinishLaunching => "did_finish_launching"
    WillTerminate => "will_terminate"
    NewEvents(_) => "new_events"
    CanCreateSurfaces => "can_create_surfaces"
    AboutToWait => "about_to_wait"
    ProxyWakeUp => "proxy_wake_up"
    WindowEvent(_, _) => "window_event"
    ScaleFactorChanged(_, _, _, _, _) => "scale_factor_changed"
    DeviceEvent(_) => "device_event"
    StandardKeyBinding(_, _) => "standard_key_binding"
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
      did_finish_launching_observer_: None,
      will_terminate_observer_: None,
      before_waiting_observer_: None,
      after_waiting_observer_: None,
    },
  }
}

///|
let launch_init_callback_order_for_test : Ref[Array[String]] = Ref([])

///|
let launch_init_stop_flag_seen_for_test : Ref[Array[Bool]] = Ref([])

///|
struct LaunchInitCallbacksApp {}

///|
pub impl ApplicationHandler for LaunchInitCallbacksApp with fn new_events(
  _self,
  _event_loop,
  _cause,
) {
  launch_init_callback_order_for_test.val.push("new_events")
  launch_init_stop_flag_seen_for_test.val.push(
    app_state_stop_on_launch_for_test(),
  )
}

///|
pub impl ApplicationHandler for LaunchInitCallbacksApp with fn can_create_surfaces(
  _self,
  _event_loop,
) {
  launch_init_callback_order_for_test.val.push("can_create_surfaces")
  launch_init_stop_flag_seen_for_test.val.push(
    app_state_stop_on_launch_for_test(),
  )
}

///|
test "min_timeout_handles_none_and_picks_smaller_timeout" {
  assert_true(min_timeout_ms(None, None) == None)
  assert_true(
    min_timeout_ms(Some((10 : Int).to_int64()), None) ==
    Some((10 : Int).to_int64()),
  )
  assert_true(
    min_timeout_ms(None, Some((20 : Int).to_int64())) ==
    Some((20 : Int).to_int64()),
  )
  assert_true(
    min_timeout_ms(Some((30 : Int).to_int64()), Some((20 : Int).to_int64())) ==
    Some((20 : Int).to_int64()),
  )
  assert_true(
    min_timeout_ms(Some((5 : Int).to_int64()), Some((20 : Int).to_int64())) ==
    Some((5 : Int).to_int64()),
  )
}

///|
test "queue_unique_window_id_is_deduplicated" {
  let ids : Array[Int] = []
  app_state_queue_unique_window_id(ids, 7)
  app_state_queue_unique_window_id(ids, 7)
  app_state_queue_unique_window_id(ids, 8)
  assert_true(ids == [7, 8])

  assert_true(app_state_take_window_id(ids, 7))
  assert_false(app_state_take_window_id(ids, 7))
  assert_true(ids == [8])
}

///|
test "wait_cause_matches_control_flow" {
  reset_app_state_runtime_for_test()
  let start = runtime_now_ms() - (100 : Int).to_int64()
  app_state_set_start_time_for_test(Some(start))

  app_state_set_control_flow(Poll)
  assert_eq(app_state_wait_cause(), Poll)

  app_state_set_control_flow(Wait)
  assert_eq(app_state_wait_cause(), WaitCancelled(start, None))

  let future = runtime_now_ms() + (2000 : Int).to_int64()
  app_state_set_control_flow(WaitUntil(future))
  assert_eq(app_state_wait_cause(), WaitCancelled(start, Some(future)))

  let past = runtime_now_ms() - (2000 : Int).to_int64()
  app_state_set_control_flow(WaitUntil(past))
  assert_eq(app_state_wait_cause(), ResumeTimeReached(start, past))
}

///|
test "did_finish_launching_notification_is_deduplicated_in_queue" {
  reset_app_state_runtime_for_test()
  app_state_queue_deferred_callback_for_test(DidFinishLaunching)

  app_state_queue_did_finish_launching_notification()
  assert_true(
    app_state_deferred_callback_names_for_test() == ["did_finish_launching"],
  )
}

///|
test "will_terminate_notification_is_deduplicated_in_queue" {
  reset_app_state_runtime_for_test()
  app_state_queue_deferred_callback_for_test(WillTerminate)

  app_state_queue_will_terminate_notification()
  assert_true(
    app_state_deferred_callback_names_for_test() == ["will_terminate"],
  )
}

///|
test "will_terminate_notification_noops_after_handled" {
  reset_app_state_runtime_for_test()
  app_state_set_will_terminate_handled_for_test(true)

  app_state_queue_will_terminate_notification()
  assert_eq(app_state_deferred_callback_count_for_test(), 0)
}

///|
test "will_terminate_callback_bypasses_registered_dispatch_handler" {
  reset_app_state_runtime_for_test()
  app_state_set_will_terminate_handled_for_test(true)
  let seen : Ref[Array[String]] = Ref([])
  app_state_set_dispatch_callback_for_test(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
  })

  app_state_maybe_dispatch_callback(WillTerminate)

  assert_eq(seen.val.length(), 0)
}

///|
test "will_terminate_clears_dispatch_handler" {
  reset_app_state_runtime_for_test()
  app_state_set_dispatch_callback_for_test(fn(_callback) {  })

  app_state_will_terminate()

  assert_false(app_state_has_dispatch_callback_for_test())
}

///|
test "will_terminate_does_not_set_exit_flag" {
  reset_app_state_runtime_for_test()
  assert_false(app_state_exiting())

  app_state_will_terminate()

  assert_false(app_state_exiting())
}

///|
test "callbacks_requiring_running_are_ignored_when_not_running" {
  reset_app_state_runtime_for_test()
  app_state_queue_proxy_wake_up()
  assert_eq(app_state_deferred_callback_count_for_test(), 0)
}

///|
test "internal_exit_preserves_stop_on_launch_flag" {
  reset_app_state_runtime_for_test()
  app_state_set_stop_on_launch(true)
  app_state_set_running(true)
  set_window_fullscreen_transition_state((901 : Int).to_uint64(), true)

  app_state_internal_exit()

  assert_true(app_state_stop_on_launch_for_test())
  assert_false(app_state_is_running())
  assert_true(fullscreen_transition_entries.val.length() == 0)
}

///|
test "dispatch_registered_deferred_callbacks_keeps_order_when_running" {
  reset_app_state_runtime_for_test()
  let seen : Ref[Array[String]] = Ref([])
  app_state_set_dispatch_callback_for_test(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
  })
  app_state_set_running(true)

  app_state_queue_deferred_callback_for_test(ProxyWakeUp)
  app_state_queue_deferred_callback_for_test(AboutToWait)
  app_state_dispatch_registered_deferred_callbacks()

  assert_true(seen.val == ["proxy_wake_up", "about_to_wait"])
  assert_eq(app_state_deferred_callback_count_for_test(), 0)
}

///|
test "dispatch_registered_deferred_callbacks_dispatches_lifecycle_while_not_running" {
  reset_app_state_runtime_for_test()
  let seen : Ref[Array[String]] = Ref([])
  app_state_set_dispatch_callback_for_test(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
  })
  app_state_set_running(false)

  app_state_queue_deferred_callback_for_test(ProxyWakeUp)
  app_state_queue_deferred_callback_for_test(WillTerminate)
  app_state_queue_deferred_callback_for_test(DidFinishLaunching)
  app_state_dispatch_registered_deferred_callbacks()

  assert_true(seen.val == ["will_terminate", "did_finish_launching"])
  assert_true(app_state_deferred_callback_names_for_test() == ["proxy_wake_up"])
}

///|
test "did_finish_launching_keeps_stop_on_launch_until_init_dispatch" {
  reset_app_state_runtime_for_test()
  app_state_set_stop_on_launch(true)

  app_state_did_finish_launching()

  assert_true(app_state_is_launched())
  assert_true(app_state_stop_on_launch_for_test())
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

  assert_true(
    launch_init_callback_order_for_test.val ==
    ["new_events", "can_create_surfaces"],
  )
  assert_true(launch_init_stop_flag_seen_for_test.val == [true, true])
  assert_false(app_state_stop_on_launch_for_test())
}

///|
test "reentrant_redraw_requested_is_dropped" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  app_state_set_handler_in_use(true)
  let seen : Ref[Array[String]] = Ref([])
  app_state_set_dispatch_callback_for_test(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
  })

  app_state_queue_window_callback(@core.WindowId::from_raw(1), RedrawRequested)

  assert_eq(seen.val.length(), 0)
  assert_eq(app_state_deferred_callback_count_for_test(), 0)
}

///|
test "reentrant_non_redraw_window_event_is_queued" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  app_state_set_handler_in_use(true)
  let seen : Ref[Array[String]] = Ref([])
  app_state_set_dispatch_callback_for_test(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
  })

  app_state_queue_window_callback(@core.WindowId::from_raw(1), Focused(true))

  assert_eq(seen.val.length(), 0)
  assert_true(app_state_deferred_callback_names_for_test() == ["window_event"])
}

///|
test "before_waiting_dispatches_redraws_then_about_to_wait" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  let seen : Ref[Array[String]] = Ref([])
  app_state_set_dispatch_callback_for_test(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
  })
  app_state_queue_redraw(7)
  app_state_queue_redraw(7)
  app_state_queue_redraw(8)

  app_state_on_before_waiting()

  assert_true(seen.val == ["window_event", "window_event", "about_to_wait"])
  assert_eq(app_state_pending_redraw_window_ids_for_test().length(), 0)
  assert_true(app_state_start_time_for_test() is Some(_))
}

///|
test "after_waiting_dispatches_new_events_with_wait_cause" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  let captured_causes : Ref[Array[@core.StartCause]] = Ref([])
  app_state_set_dispatch_callback_for_test(fn(callback) {
    match callback {
      NewEvents(cause) => captured_causes.val.push(cause)
      _ => ()
    }
  })
  let start = runtime_now_ms() - (20 : Int).to_int64()
  let requested_resume = runtime_now_ms() + (2000 : Int).to_int64()
  app_state_set_start_time_for_test(Some(start))
  app_state_set_control_flow(WaitUntil(requested_resume))

  app_state_on_after_waiting()

  assert_true(
    captured_causes.val == [WaitCancelled(start, Some(requested_resume))],
  )
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
  assert_true(
    launch_init_callback_order_for_test.val ==
    ["new_events", "can_create_surfaces"],
  )
  app_state_clear_dispatch_handler()
}

///|
test "handler_ready_requires_registered_dispatch_handler" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  app_state_set_handler_in_use(false)
  assert_false(app_state_handler_ready())

  app_state_set_dispatch_callback_for_test(fn(_callback) {  })
  assert_true(app_state_handler_ready())
}

///|
test "before_waiting_noops_without_dispatch_handler" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  app_state_set_handler_in_use(false)
  app_state_set_control_flow(Wait)
  app_state_queue_redraw(1)

  app_state_on_before_waiting()

  assert_true(app_state_pending_redraw_window_ids_for_test() == [1])
  assert_true(app_state_start_time_for_test() is None)
}

///|
test "after_waiting_noops_without_dispatch_handler" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  app_state_set_handler_in_use(false)
  app_state_set_start_time_for_test(Some((42 : Int).to_int64()))
  app_state_set_control_flow(Poll)

  app_state_on_after_waiting()

  assert_eq(app_state_deferred_callback_count_for_test(), 0)
}

///|
test "running_callbacks_are_dropped_when_dispatch_handler_absent" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  app_state_set_handler_in_use(false)

  app_state_queue_proxy_wake_up()
  app_state_queue_window_callback(@core.WindowId::from_raw(1), Focused(true))

  assert_eq(app_state_deferred_callback_count_for_test(), 0)
}

///|
test "did_finish_launching_updates_state_without_dispatch_handler" {
  reset_app_state_runtime_for_test()
  assert_false(app_state_is_launched())
  assert_false(app_state_is_running())

  app_state_queue_did_finish_launching_notification()

  assert_true(app_state_is_launched())
  assert_false(app_state_is_running())
  assert_eq(app_state_deferred_callback_count_for_test(), 0)
}

///|
test "nested_proxy_wake_is_deferred_until_explicit_drain" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  let seen : Ref[Array[String]] = Ref([])
  app_state_set_dispatch_callback_for_test(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
    match callback {
      AboutToWait => app_state_queue_proxy_wake_up()
      _ => ()
    }
  })

  app_state_maybe_dispatch_callback(AboutToWait)

  assert_true(seen.val == ["about_to_wait"])
  assert_true(app_state_deferred_callback_names_for_test() == ["proxy_wake_up"])

  app_state_dispatch_registered_deferred_callbacks()

  assert_true(seen.val == ["about_to_wait", "proxy_wake_up"])
  assert_eq(app_state_deferred_callback_count_for_test(), 0)
}

///|
test "nested_redraw_is_dropped_while_handler_is_in_use" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  let seen : Ref[Array[String]] = Ref([])
  app_state_set_dispatch_callback_for_test(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
    match callback {
      AboutToWait =>
        app_state_queue_window_callback(
          @core.WindowId::from_raw(1),
          RedrawRequested,
        )
      _ => ()
    }
  })

  app_state_maybe_dispatch_callback(AboutToWait)

  assert_true(seen.val == ["about_to_wait"])
  assert_eq(app_state_deferred_callback_count_for_test(), 0)
}

///|
test "before_waiting_drains_deferred_callbacks_before_about_to_wait" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  let seen : Ref[Array[String]] = Ref([])
  app_state_set_dispatch_callback_for_test(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
  })
  app_state_queue_deferred_callback_for_test(ProxyWakeUp)

  app_state_on_before_waiting()

  assert_true(seen.val == ["proxy_wake_up", "about_to_wait"])
  assert_eq(app_state_deferred_callback_count_for_test(), 0)
}

///|
test "dispatch_registered_deferred_callbacks_keeps_queue_when_handler_is_cleared" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  let seen : Ref[Array[String]] = Ref([])
  app_state_set_dispatch_callback_for_test(fn(callback) {
    seen.val.push(callback_name_for_test(callback))
    app_state_clear_dispatch_handler()
  })
  app_state_queue_deferred_callback_for_test(ProxyWakeUp)
  app_state_queue_deferred_callback_for_test(AboutToWait)

  app_state_dispatch_registered_deferred_callbacks()

  assert_true(seen.val == ["proxy_wake_up"])
  assert_true(app_state_deferred_callback_names_for_test() == ["about_to_wait"])
}

///|
test "moved_event_is_deduplicated_when_position_is_unchanged" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  app_state_set_handler_in_use(true)
  app_state_set_dispatch_callback_for_test(fn(_callback) {  })

  app_state_queue_native_window_event(4, 7, 10, 20, 0, 0.0)
  app_state_queue_native_window_event(4, 7, 10, 20, 0, 0.0)

  assert_true(app_state_deferred_callback_names_for_test() == ["window_event"])
}

///|
test "moved_event_is_queued_again_when_position_changes" {
  reset_app_state_runtime_for_test()
  app_state_set_running(true)
  app_state_set_handler_in_use(true)
  app_state_set_dispatch_callback_for_test(fn(_callback) {  })

  app_state_queue_native_window_event(4, 7, 10, 20, 0, 0.0)
  app_state_queue_native_window_event(4, 7, 11, 20, 0, 0.0)

  assert_true(
    app_state_deferred_callback_names_for_test() ==
    ["window_event", "window_event"],
  )
}
