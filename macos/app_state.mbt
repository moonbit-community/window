///|
// Port target: winit-reference/winit-appkit/src/app_state.rs

///|
priv enum DeferredCallback {
  DidFinishLaunching
  WillTerminate
  NewEvents(@core.StartCause)
  CanCreateSurfaces
  AboutToWait
  ProxyWakeUp
  WindowEvent(@core.WindowId, @core.WindowEvent)
  ScaleFactorChanged(Int, @core.WindowId, Double, Int, Int)
  DeviceEvent(@core.DeviceEvent)
  StandardKeyBinding(@core.WindowId, String)
}

///|
priv struct WindowHandleEntry {
  raw_id : Int
  handle : UInt64
}

///|
priv struct FullscreenRequestEntry {
  raw_id : Int
  fullscreen : Bool
}

///|
priv struct AppStateRuntime {
  mut activation_policy : Int
  mut default_menu : Bool
  mut activate_ignoring_other_apps : Bool
  mut next_window_id : Int
  mut stop_on_launch : Bool
  mut stop_before_wait : Bool
  mut stop_after_wait : Bool
  mut stop_on_redraw : Bool
  mut is_launched : Bool
  mut is_running : Bool
  mut will_terminate_handled : Bool
  mut exit_requested : Bool
  mut event_handler_in_use : Bool
  mut control_flow : @core.ControlFlow
  waker : EventLoopWaker
  mut start_time_ms : Int64?
  mut wait_timeout_ms : Int64?
  mut pending_redraw_window_ids : Array[Int]
  mut window_handles : Array[WindowHandleEntry]
  mut fullscreen_requests : Array[FullscreenRequestEntry]
  mut deferred_callbacks : Array[DeferredCallback]
  mut dispatch_callback : ((DeferredCallback) -> Unit)?
}

///|
fn AppStateRuntime::new() -> AppStateRuntime {
  {
    activation_policy: -1,
    default_menu: true,
    activate_ignoring_other_apps: true,
    next_window_id: 1,
    stop_on_launch: false,
    stop_before_wait: false,
    stop_after_wait: false,
    stop_on_redraw: false,
    is_launched: false,
    is_running: false,
    will_terminate_handled: false,
    exit_requested: false,
    event_handler_in_use: false,
    control_flow: @core.ControlFlow::Wait,
    waker: EventLoopWaker::new(),
    start_time_ms: None,
    wait_timeout_ms: None,
    pending_redraw_window_ids: [],
    window_handles: [],
    fullscreen_requests: [],
    deferred_callbacks: [],
    dispatch_callback: None,
  }
}

///|
let app_state_runtime : Ref[AppStateRuntime] = Ref::new(AppStateRuntime::new())

///|
fn runtime_now_ms() -> Int64 {
  (native_cf_absolute_time_get_current() * 1000.0).to_int64()
}

///|
fn native_event_loop_wake_up() -> Unit {
  native_event_loop_wake_up_appkit()
}

///|
fn app_state_device_event_from_native(
  native_event_kind : Int,
  button : Int,
  delta_x : Double,
  delta_y : Double,
) -> @core.DeviceEvent? {
  match native_event_kind {
    1 =>
      if delta_x == 0.0 && delta_y == 0.0 {
        None
      } else {
        Some(@core.DeviceEvent::PointerMotion(delta_x, delta_y))
      }
    2 =>
      if button < 0 {
        None
      } else {
        Some(
          @core.DeviceEvent::Button(
            @core.ButtonId::from_raw(button),
            @core.ElementState::Pressed,
          ),
        )
      }
    3 =>
      if button < 0 {
        None
      } else {
        Some(
          @core.DeviceEvent::Button(
            @core.ButtonId::from_raw(button),
            @core.ElementState::Released,
          ),
        )
      }
    _ => None
  }
}

///|
fn app_state_callback_requires_running(callback : DeferredCallback) -> Bool {
  match callback {
    DeferredCallback::DidFinishLaunching | DeferredCallback::WillTerminate =>
      false
    _ => true
  }
}

///|
fn app_state_defer_callback(callback : DeferredCallback) -> Unit {
  app_state_runtime.val.deferred_callbacks.push(callback)
  native_event_loop_wake_up()
}

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
fn app_state_take_next_dispatchable_callback() -> DeferredCallback? {
  if app_state_runtime.val.deferred_callbacks.is_empty() {
    return None
  }
  if app_state_is_running() {
    return Some(app_state_runtime.val.deferred_callbacks.remove(0))
  }
  match
    app_state_runtime.val.deferred_callbacks.search_by(callback => {
      app_state_callback_requires_running(callback) == false
    }) {
    Some(index) => Some(app_state_runtime.val.deferred_callbacks.remove(index))
    None => None
  }
}

///|
fn app_state_dispatch_registered_deferred_callbacks() -> Unit {
  if app_state_runtime.val.dispatch_callback is None {
    return ()
  }
  while app_state_runtime.val.event_handler_in_use == false {
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
fn app_state_maybe_dispatch_callback(callback : DeferredCallback) -> Unit {
  if callback is DeferredCallback::WillTerminate {
    app_state_will_terminate()
    return ()
  }
  if app_state_callback_requires_running(callback) &&
    app_state_is_running() == false {
    return ()
  }
  if app_state_runtime.val.dispatch_callback is None {
    match callback {
      // Port target: app_state.rs::did_finish_launching / will_terminate
      // Even without an active handler, lifecycle state still advances.
      DeferredCallback::DidFinishLaunching => app_state_did_finish_launching()
      DeferredCallback::WillTerminate => app_state_will_terminate()
      _ => ()
    }
    return ()
  }
  if app_state_runtime.val.event_handler_in_use {
    match callback {
      // Port target: app_state.rs::handle_redraw
      // Drop re-entrant redraw callbacks instead of queueing them.
      DeferredCallback::WindowEvent(_, @core.WindowEvent::RedrawRequested) =>
        return ()
      _ => ()
    }
    app_state_defer_callback(callback)
    return ()
  }
  if app_state_dispatch_with_registered_callback(callback) == false {
    app_state_defer_callback(callback)
  }
}

///|
fn app_state_queue_did_finish_launching_notification() -> Unit {
  if app_state_runtime.val.is_launched {
    return ()
  }
  for callback in app_state_runtime.val.deferred_callbacks {
    if callback is DeferredCallback::DidFinishLaunching {
      return ()
    }
  }
  app_state_maybe_dispatch_callback(DeferredCallback::DidFinishLaunching)
}

///|
fn app_state_queue_will_terminate_notification() -> Unit {
  if app_state_runtime.val.will_terminate_handled {
    return ()
  }
  for callback in app_state_runtime.val.deferred_callbacks {
    if callback is DeferredCallback::WillTerminate {
      return ()
    }
  }
  app_state_maybe_dispatch_callback(DeferredCallback::WillTerminate)
}

///|
fn app_state_queue_proxy_wake_up() -> Unit {
  app_state_maybe_dispatch_callback(DeferredCallback::ProxyWakeUp)
}

///|
fn app_state_queue_device_event(
  native_event_kind : Int,
  button : Int,
  delta_x : Double,
  delta_y : Double,
) -> Unit {
  match
    app_state_device_event_from_native(
      native_event_kind, button, delta_x, delta_y,
    ) {
    Some(event) =>
      app_state_maybe_dispatch_callback(DeferredCallback::DeviceEvent(event))
    None => ()
  }
}

///|
fn app_state_window_scale_factor(raw_id : Int) -> Double {
  match app_state_window_handle(raw_id) {
    Some(window_handle) => native_window_scale_factor(window_handle)
    None => 1.0
  }
}

///|
fn app_state_logical_size_to_physical(
  raw_id : Int,
  width : Int,
  height : Int,
) -> @dpi.PhysicalSize {
  @dpi.LogicalSize::new(width.to_double(), height.to_double()).to_physical(
    app_state_window_scale_factor(raw_id),
  )
}

///|
fn app_state_logical_position_to_physical(
  raw_id : Int,
  x : Int,
  y : Int,
) -> @dpi.PhysicalPosition {
  @dpi.LogicalPosition::new(x.to_double(), y.to_double()).to_physical(
    app_state_window_scale_factor(raw_id),
  )
}

///|
fn app_state_queue_native_window_event(
  kind : Int,
  raw_id : Int,
  arg0 : Int,
  arg1 : Int,
  _arg2 : Int,
  argd : Double,
) -> Unit {
  let window_id = @core.WindowId::from_raw(raw_id)
  match kind {
    1 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::CloseRequested,
      )
    2 => {
      app_state_clear_window_redraw(raw_id)
      view_clear_pressed_modifiers(raw_id)
      app_state_clear_fullscreen_request(raw_id)
      app_state_unregister_window_handle(raw_id)
      app_state_queue_window_callback(window_id, @core.WindowEvent::Destroyed)
    }
    3 => {
      let focused = arg0 != 0
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::Focused(focused),
      )
      if focused == false {
        view_clear_pressed_modifiers(raw_id)
        app_state_queue_window_callback(
          window_id,
          @core.WindowEvent::ModifiersChanged(@core.Modifiers::default()),
        )
      }
    }
    4 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::Moved(
          app_state_logical_position_to_physical(raw_id, arg0, arg1),
        ),
      )
    5 =>
      app_state_maybe_dispatch_callback(
        DeferredCallback::ScaleFactorChanged(
          raw_id, window_id, argd, arg0, arg1,
        ),
      )
    6 =>
      match theme_from_native(arg0) {
        Some(theme) =>
          app_state_queue_window_callback(
            window_id,
            @core.WindowEvent::ThemeChanged(theme),
          )
        None => ()
      }
    7 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::Occluded(arg0 != 0),
      )
    8 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::SurfaceResized(
          app_state_logical_size_to_physical(raw_id, arg0, arg1),
        ),
      )
    9 => ()
    10 => ()
    11 => {
      app_state_process_queued_fullscreen_request(raw_id)
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::SurfaceResized(
          app_state_logical_size_to_physical(raw_id, arg0, arg1),
        ),
      )
    }
    12 => {
      app_state_process_queued_fullscreen_request(raw_id)
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::SurfaceResized(
          app_state_logical_size_to_physical(raw_id, arg0, arg1),
        ),
      )
    }
    13 => app_state_process_queued_fullscreen_request(raw_id)
    _ => ()
  }
}

///|
fn app_state_install_native_callbacks() -> Unit {
  native_install_input_event_callback(
    fn(callback, raw_id, kind, event_handle) {
      callback(raw_id, kind, event_handle)
    },
    native_callback_input_event,
  )
  native_install_text_input_event_callback(
    fn(
      callback,
      raw_id,
      kind,
      event_handle,
      state,
      text_handle,
      cursor_start,
      cursor_end,
      path_handle,
    ) {
      callback(
        raw_id, kind, event_handle, state, text_handle, cursor_start, cursor_end,
        path_handle,
      )
    },
    native_callback_text_input_event,
  )
  native_install_window_event_callback(
    fn(callback, kind, raw_id, arg0, arg1, arg2, argd) {
      callback(kind, raw_id, arg0, arg1, arg2, argd)
    },
    native_callback_window_event,
  )
  native_install_device_event_callback(
    fn(callback, event_handle) { callback(event_handle) },
    native_callback_device_event,
  )
}

///|
fn native_callback_did_finish_launching() -> Unit {
  app_state_queue_did_finish_launching_notification()
}

///|
fn native_callback_will_terminate() -> Unit {
  app_state_queue_will_terminate_notification()
}

///|
fn native_callback_input_event(
  raw_id : Int,
  kind : Int,
  event_handle : UInt64,
) -> Unit {
  queue_native_input_event(raw_id, kind, event_handle)
}

///|
fn native_callback_text_input_event(
  raw_id : Int,
  kind : Int,
  event_handle : UInt64,
  state : Int,
  text_handle : UInt64,
  cursor_start : Int,
  cursor_end : Int,
  path_handle : UInt64,
) -> Unit {
  queue_native_text_input_event(
    raw_id, kind, event_handle, state, text_handle, cursor_start, cursor_end, path_handle,
  )
}

///|
fn native_callback_device_event(event_handle : UInt64) -> Unit {
  if event_handle == (0 : Int).to_uint64() {
    return ()
  }
  let event_type = appkit_objc_msg_send_i64(
    event_handle,
    objc_runtime_selector_handle("type"),
  ).to_int()
  match event_type {
    // NSEventTypeMouseMoved | LeftMouseDragged | RightMouseDragged | OtherMouseDragged.
    5 | 6 | 7 | 27 => {
      let delta_x = appkit_objc_msg_send_double(
        event_handle,
        objc_runtime_selector_handle("deltaX"),
      )
      let delta_y = appkit_objc_msg_send_double(
        event_handle,
        objc_runtime_selector_handle("deltaY"),
      )
      if delta_x != 0.0 || delta_y != 0.0 {
        app_state_queue_device_event(1, 0, delta_x, delta_y)
      }
    }
    // NSEventTypeLeftMouseDown | RightMouseDown | OtherMouseDown.
    1 | 3 | 25 =>
      app_state_queue_device_event(
        2,
        appkit_objc_msg_send_i64(
          event_handle,
          objc_runtime_selector_handle("buttonNumber"),
        ).to_int(),
        0.0,
        0.0,
      )
    // NSEventTypeLeftMouseUp | RightMouseUp | OtherMouseUp.
    2 | 4 | 26 =>
      app_state_queue_device_event(
        3,
        appkit_objc_msg_send_i64(
          event_handle,
          objc_runtime_selector_handle("buttonNumber"),
        ).to_int(),
        0.0,
        0.0,
      )
    _ => ()
  }
}

///|
fn app_state_on_before_waiting() -> Unit {
  if app_state_handler_ready() == false {
    return ()
  }
  app_state_dispatch_registered_deferred_callbacks()
  if app_state_handler_ready() == false {
    return ()
  }
  for raw_id in app_state_take_all_redraws() {
    app_state_maybe_dispatch_callback(
      DeferredCallback::WindowEvent(
        @core.WindowId::from_raw(raw_id),
        @core.WindowEvent::RedrawRequested,
      ),
    )
  }
  app_state_maybe_dispatch_callback(DeferredCallback::AboutToWait)
  if app_state_exiting() {
    stop_app_immediately()
    notify_windows_of_exit()
  }
  if app_state_stop_before_wait() {
    stop_app_immediately()
  }
  let start_time_ms = runtime_now_ms()
  app_state_prepare_wait_cycle(start_time_ms)
  app_state_runtime.val.waker.start_at(app_state_effective_wait_timeout_ms())
}

///|
fn app_state_on_after_waiting() -> Unit {
  if app_state_handler_ready() == false {
    return ()
  }
  app_state_dispatch_registered_deferred_callbacks()
  if app_state_handler_ready() == false {
    return ()
  }
  if app_state_stop_after_wait() {
    stop_app_immediately()
  }
  app_state_maybe_dispatch_callback(
    DeferredCallback::NewEvents(app_state_wait_cause()),
  )
}

///|
fn native_callback_lifecycle(kind : Int) -> Unit {
  match kind {
    1 => native_callback_did_finish_launching()
    2 => native_callback_will_terminate()
    3 => app_state_on_before_waiting()
    4 => app_state_on_after_waiting()
    _ => ()
  }
}

///|
fn native_callback_window_event(
  kind : Int,
  raw_id : Int,
  arg0 : Int,
  arg1 : Int,
  arg2 : Int,
  argd : Double,
) -> Unit {
  app_state_queue_native_window_event(kind, raw_id, arg0, arg1, arg2, argd)
}

///|
fn app_state_register_window_handle(
  raw_id : Int,
  window_handle : UInt64,
) -> Unit {
  let next_entries : Array[WindowHandleEntry] = []
  let mut replaced = false
  for entry in app_state_runtime.val.window_handles {
    if entry.raw_id == raw_id {
      next_entries.push({ raw_id, handle: window_handle })
      replaced = true
    } else {
      next_entries.push(entry)
    }
  }
  if replaced == false {
    next_entries.push({ raw_id, handle: window_handle })
  }
  app_state_runtime.val.window_handles = next_entries
}

///|
fn app_state_unregister_window_handle(raw_id : Int) -> Unit {
  let remaining_entries : Array[WindowHandleEntry] = []
  for entry in app_state_runtime.val.window_handles {
    if entry.raw_id != raw_id {
      remaining_entries.push(entry)
    }
  }
  app_state_runtime.val.window_handles = remaining_entries
  app_state_clear_fullscreen_request(raw_id)
}

///|
fn app_state_window_handle(raw_id : Int) -> UInt64? {
  match
    app_state_runtime.val.window_handles.search_by(entry => {
      entry.raw_id == raw_id
    }) {
    Some(index) => Some(app_state_runtime.val.window_handles[index].handle)
    None => None
  }
}

///|
fn app_state_window_raw_id(window_handle : UInt64) -> Int? {
  match
    app_state_runtime.val.window_handles.search_by(entry => {
      entry.handle == window_handle
    }) {
    Some(index) => Some(app_state_runtime.val.window_handles[index].raw_id)
    None => None
  }
}

///|
fn app_state_has_window_handle(window_handle : UInt64) -> Bool {
  app_state_runtime.val.window_handles.search_by(entry => {
    entry.handle == window_handle
  }) !=
  None
}

///|
fn app_state_set_fullscreen_request(raw_id : Int, fullscreen : Bool) -> Unit {
  let next_requests : Array[FullscreenRequestEntry] = []
  let mut replaced = false
  for request in app_state_runtime.val.fullscreen_requests {
    if request.raw_id == raw_id {
      next_requests.push({ raw_id, fullscreen })
      replaced = true
    } else {
      next_requests.push(request)
    }
  }
  if replaced == false {
    next_requests.push({ raw_id, fullscreen })
  }
  app_state_runtime.val.fullscreen_requests = next_requests
}

///|
fn app_state_fullscreen_request(raw_id : Int) -> Bool? {
  match
    app_state_runtime.val.fullscreen_requests.search_by(request => {
      request.raw_id == raw_id
    }) {
    Some(index) =>
      Some(app_state_runtime.val.fullscreen_requests[index].fullscreen)
    None => None
  }
}

///|
fn app_state_clear_fullscreen_request(raw_id : Int) -> Unit {
  let next_requests : Array[FullscreenRequestEntry] = []
  for request in app_state_runtime.val.fullscreen_requests {
    if request.raw_id != raw_id {
      next_requests.push(request)
    }
  }
  app_state_runtime.val.fullscreen_requests = next_requests
}

///|
fn app_state_process_queued_fullscreen_request(raw_id : Int) -> Unit {
  match app_state_fullscreen_request(raw_id) {
    Some(fullscreen) =>
      match app_state_window_handle(raw_id) {
        Some(window_handle) =>
          if window_in_fullscreen_transition(window_handle) == false {
            app_state_clear_fullscreen_request(raw_id)
            toggle_window_fullscreen(window_handle, fullscreen)
          }
        None => app_state_clear_fullscreen_request(raw_id)
      }
    None => ()
  }
}

///|
fn app_state_next_window_id() -> Int {
  let raw_id = app_state_runtime.val.next_window_id
  app_state_runtime.val.next_window_id = raw_id + 1
  raw_id
}

///|
fn app_state_queue_window_callback(
  window_id : @core.WindowId,
  event : @core.WindowEvent,
) -> Unit {
  app_state_maybe_dispatch_callback(
    DeferredCallback::WindowEvent(window_id, event),
  )
}

///|
fn app_state_queue_standard_key_binding_callback(
  window_id : @core.WindowId,
  action : String,
) -> Unit {
  app_state_maybe_dispatch_callback(
    DeferredCallback::StandardKeyBinding(window_id, action),
  )
}

///|
fn app_state_configure_launch_policy(
  activation_policy : Int,
  default_menu : Bool,
  activate_ignoring_other_apps : Bool,
) -> Unit {
  app_state_runtime.val.activation_policy = activation_policy
  app_state_runtime.val.default_menu = default_menu
  app_state_runtime.val.activate_ignoring_other_apps = activate_ignoring_other_apps
}

///|
fn app_state_setup_global(
  activation_policy : Int,
  default_menu : Bool,
  activate_ignoring_other_apps : Bool,
) -> Unit {
  app_state_configure_launch_policy(
    activation_policy, default_menu, activate_ignoring_other_apps,
  )
  app_state_install_native_callbacks()
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
fn app_state_is_launched() -> Bool {
  app_state_runtime.val.is_launched
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
  app_state_runtime.val.is_running &&
  app_state_runtime.val.event_handler_in_use == false &&
  app_state_runtime.val.dispatch_callback is Some(_)
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
fn app_state_set_control_flow(value : @core.ControlFlow) -> Unit {
  app_state_runtime.val.control_flow = value
}

///|
fn app_state_control_flow() -> @core.ControlFlow {
  app_state_runtime.val.control_flow
}

///|
fn app_state_set_wait_timeout_ms(value : Int64?) -> Unit {
  app_state_runtime.val.wait_timeout_ms = value
}

///|
fn min_timeout_ms(a : Int64?, b : Int64?) -> Int64? {
  match a {
    Some(a_timeout) =>
      match b {
        Some(b_timeout) =>
          Some(if a_timeout < b_timeout { a_timeout } else { b_timeout })
        None => Some(a_timeout)
      }
    None => b
  }
}

///|
fn app_state_control_flow_timeout_ms() -> Int64? {
  match app_state_runtime.val.control_flow {
    @core.ControlFlow::Wait => None
    @core.ControlFlow::Poll => Some(runtime_now_ms())
    @core.ControlFlow::WaitUntil(requested_resume_ms) =>
      Some(requested_resume_ms)
  }
}

///|
fn app_state_effective_wait_timeout_ms() -> Int64? {
  min_timeout_ms(
    app_state_runtime.val.wait_timeout_ms,
    app_state_control_flow_timeout_ms(),
  )
}

///|
fn app_state_prepare_wait_cycle(start_time_ms : Int64) -> Unit {
  app_state_runtime.val.start_time_ms = Some(start_time_ms)
}

///|
fn app_state_wait_cause() -> @core.StartCause {
  let start_time_ms = match app_state_runtime.val.start_time_ms {
    Some(start_time_ms) => start_time_ms
    None => runtime_now_ms()
  }
  match app_state_runtime.val.control_flow {
    @core.ControlFlow::Poll => @core.StartCause::Poll
    @core.ControlFlow::Wait =>
      @core.StartCause::WaitCancelled(start_time_ms, None)
    @core.ControlFlow::WaitUntil(requested_resume_ms) =>
      if runtime_now_ms() >= requested_resume_ms {
        @core.StartCause::ResumeTimeReached(start_time_ms, requested_resume_ms)
      } else {
        @core.StartCause::WaitCancelled(
          start_time_ms,
          Some(requested_resume_ms),
        )
      }
  }
}

///|
fn app_state_did_finish_launching() -> Unit {
  if app_state_runtime.val.is_launched {
    return ()
  }
  app_state_runtime.val.is_launched = true
  app_state_apply_launch_policy()
  app_state_runtime.val.waker.start()
}

///|
fn native_application_is_bundled() -> Bool {
  let running_application_class = objc_runtime_class_handle(
    "NSRunningApplication",
  )
  if running_application_class == (0 : Int).to_uint64() {
    return false
  }
  let app = appkit_objc_msg_send_u64(
    running_application_class,
    objc_runtime_selector_handle("currentApplication"),
  )
  if app == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_u64(
    app,
    objc_runtime_selector_handle("bundleIdentifier"),
  ) !=
  (0 : Int).to_uint64()
}

///|
fn native_application_set_activation_policy(activation_policy : Int) -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  let policy = if activation_policy < 0 { 0 } else { activation_policy }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("setActivationPolicy:"),
    policy.to_uint64(),
  )
}

///|
fn native_application_set_activate_ignoring_other_apps(
  activate_ignoring_other_apps : Bool,
) -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_bool(
    app,
    objc_runtime_selector_handle("activateIgnoringOtherApps:"),
    activate_ignoring_other_apps,
  )
}

///|
fn app_state_apply_launch_policy() -> Unit {
  let activation_policy = if app_state_runtime.val.activation_policy >= 0 {
    Some(app_state_runtime.val.activation_policy)
  } else if native_application_is_bundled() {
    None
  } else {
    Some(0)
  }
  match activation_policy {
    Some(activation_policy) =>
      native_application_set_activation_policy(activation_policy)
    None => ()
  }
  native_application_set_activate_ignoring_other_apps(
    app_state_runtime.val.activate_ignoring_other_apps,
  )
  initialize(app_state_runtime.val.default_menu)
}

///|
fn app_state_will_terminate() -> Unit {
  if app_state_runtime.val.will_terminate_handled {
    return ()
  }
  app_state_runtime.val.will_terminate_handled = true
  notify_windows_of_exit()
  app_state_runtime.val.dispatch_callback = None
  app_state_runtime.val.deferred_callbacks = []
  app_state_internal_exit()
}

///|
fn app_state_internal_exit() -> Unit {
  app_state_runtime.val.is_running = false
  app_state_runtime.val.event_handler_in_use = false
  app_state_runtime.val.stop_on_redraw = false
  app_state_runtime.val.stop_on_launch = false
  app_state_runtime.val.stop_before_wait = false
  app_state_runtime.val.stop_after_wait = false
  app_state_runtime.val.waker.stop()
  app_state_runtime.val.wait_timeout_ms = None
  app_state_runtime.val.start_time_ms = None
  app_state_runtime.val.pending_redraw_window_ids = []
  app_state_runtime.val.fullscreen_requests = []
}

///|
fn[A : ApplicationHandler] app_state_dispatch_callback(
  app : A,
  event_loop : ActiveEventLoop,
  callback : DeferredCallback,
) -> Unit {
  match callback {
    DeferredCallback::DidFinishLaunching =>
      if app_state_is_launched() == false {
        app_state_did_finish_launching_and_dispatch(app, event_loop)
      }
    DeferredCallback::WillTerminate => app_state_will_terminate()
    DeferredCallback::NewEvents(cause) => app.new_events(event_loop, cause)
    DeferredCallback::CanCreateSurfaces => app.can_create_surfaces(event_loop)
    DeferredCallback::AboutToWait => app.about_to_wait(event_loop)
    DeferredCallback::ProxyWakeUp => app.proxy_wake_up(event_loop)
    DeferredCallback::WindowEvent(window_id, event) => {
      let stop_on_redraw = app_state_stop_on_redraw() &&
        event is @core.WindowEvent::RedrawRequested
      app.window_event(event_loop, window_id, event)
      if stop_on_redraw {
        stop_app_immediately()
      }
    }
    DeferredCallback::ScaleFactorChanged(
      raw_id,
      window_id,
      scale_factor,
      width,
      height
    ) => {
      let physical_size = @dpi.LogicalSize::new(
        width.to_double(),
        height.to_double(),
      ).to_physical(scale_factor)
      let writer = @core.SurfaceSizeWriter::new(physical_size)
      app.window_event(
        event_loop,
        window_id,
        @core.WindowEvent::ScaleFactorChanged(scale_factor, writer),
      )
      let requested_size = writer.surface_size()
      match app_state_window_handle(raw_id) {
        Some(window_handle) => {
          let logical_size = requested_size.to_logical(
            native_window_scale_factor(window_handle),
          )
          set_surface_size(
            window_handle,
            logical_size.width().to_int(),
            logical_size.height().to_int(),
          )
        }
        None => ()
      }
    }
    DeferredCallback::DeviceEvent(event) =>
      app.device_event(event_loop, None, event)
    DeferredCallback::StandardKeyBinding(window_id, action) =>
      app.standard_key_binding(event_loop, window_id, action)
  }
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
  while app_state_runtime.val.event_handler_in_use == false {
    match app_state_take_next_dispatchable_callback() {
      Some(callback) => app_state_with_handler(app, event_loop, callback)
      None => return ()
    }
  }
}

///|
fn[A : ApplicationHandler] app_state_dispatch_init_events(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  app_state_with_handler(
    app,
    event_loop,
    DeferredCallback::NewEvents(@core.StartCause::Init),
  )
  app_state_with_handler(app, event_loop, DeferredCallback::CanCreateSurfaces)
}

///|
fn[A : ApplicationHandler] app_state_did_finish_launching_and_dispatch(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  if app_state_is_running() == false {
    app_state_set_running(true)
  }
  app_state_did_finish_launching()
  app_state_dispatch_init_events(app, event_loop)
  if app_state_runtime.val.stop_on_launch {
    app_state_runtime.val.stop_on_launch = false
    stop_app_immediately()
  }
}

///|
fn app_state_queue_unique_window_id(ids : Array[Int], window_id : Int) -> Unit {
  match ids.search_by(id => id == window_id) {
    Some(_) => ()
    None => ids.push(window_id)
  }
}

///|
fn app_state_take_window_id(ids : Array[Int], window_id : Int) -> Bool {
  match ids.search_by(id => id == window_id) {
    Some(index) => {
      ignore(ids.remove(index))
      true
    }
    None => false
  }
}

///|
fn app_state_queue_redraw(window_id : Int) -> Unit {
  app_state_queue_unique_window_id(
    app_state_runtime.val.pending_redraw_window_ids,
    window_id,
  )
  native_event_loop_wake_up()
}

///|
fn app_state_take_all_redraws() -> Array[Int] {
  let redraws = app_state_runtime.val.pending_redraw_window_ids
  app_state_runtime.val.pending_redraw_window_ids = []
  redraws
}

///|
fn app_state_clear_window_redraw(window_id : Int) -> Unit {
  ignore(
    app_state_take_window_id(
      app_state_runtime.val.pending_redraw_window_ids,
      window_id,
    ),
  )
}
