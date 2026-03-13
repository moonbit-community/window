///|
// Port target: winit-reference/winit-appkit/src/app_state.rs

///|
priv enum DeferredCallback {
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
priv struct AppStateRuntime {
  mut activation_policy : Int
  mut default_menu : Bool
  mut activate_ignoring_other_apps : Bool
  mut stop_on_launch : Bool
  mut stop_before_wait : Bool
  mut stop_after_wait : Bool
  mut stop_on_redraw : Bool
  mut is_launched : Bool
  mut is_running : Bool
  mut pending_proxy_wake : Bool
  mut exit_requested : Bool
  mut event_handler_in_use : Bool
  mut control_flow : @core.ControlFlow
  waker : EventLoopWaker
  mut start_time_ms : Int64?
  mut wait_timeout_ms : Int64?
  mut pending_did_finish_launching : Bool
  mut pending_will_terminate : Bool
  mut pending_destroyed_window_ids : Array[Int]
  mut pending_redraw_window_ids : Array[Int]
  mut window_handles : Array[WindowHandleEntry]
  mut deferred_callbacks : Array[DeferredCallback]
}

///|
fn AppStateRuntime::new() -> AppStateRuntime {
  {
    activation_policy: -1,
    default_menu: true,
    activate_ignoring_other_apps: true,
    stop_on_launch: false,
    stop_before_wait: false,
    stop_after_wait: false,
    stop_on_redraw: false,
    is_launched: false,
    is_running: false,
    pending_proxy_wake: false,
    exit_requested: false,
    event_handler_in_use: false,
    control_flow: @core.ControlFlow::Wait,
    waker: EventLoopWaker::new(),
    start_time_ms: None,
    wait_timeout_ms: None,
    pending_did_finish_launching: false,
    pending_will_terminate: false,
    pending_destroyed_window_ids: [],
    pending_redraw_window_ids: [],
    window_handles: [],
    deferred_callbacks: [],
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
fn wait_for_events(timeout_ms : Int) -> Bool {
  native_event_loop_wait_millis(timeout_ms)
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
fn app_state_queue_did_finish_launching_notification() -> Unit {
  app_state_runtime.val.pending_did_finish_launching = true
}

///|
fn app_state_queue_will_terminate_notification() -> Unit {
  app_state_runtime.val.pending_will_terminate = true
}

///|
fn app_state_queue_proxy_wake_up() -> Unit {
  if app_state_is_running() {
    app_state_runtime.val.pending_proxy_wake = true
    app_state_runtime.val.deferred_callbacks.push(DeferredCallback::ProxyWakeUp)
    native_event_loop_wake_up()
  }
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
      if app_state_is_running() {
        app_state_runtime.val.deferred_callbacks.push(
          DeferredCallback::DeviceEvent(event),
        )
        native_event_loop_wake_up()
      }
    None => ()
  }
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
      app_state_unregister_window_handle(raw_id)
      if app_state_is_running() {
        app_state_runtime.val.pending_destroyed_window_ids.push(raw_id)
      }
      app_state_queue_window_callback(window_id, @core.WindowEvent::Destroyed)
    }
    3 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::Focused(arg0 != 0),
      )
    4 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::Moved(@dpi.PhysicalPosition::new(arg0, arg1)),
      )
    5 =>
      if app_state_is_running() {
        app_state_runtime.val.deferred_callbacks.push(
          DeferredCallback::ScaleFactorChanged(
            raw_id, window_id, argd, arg0, arg1,
          ),
        )
        native_event_loop_wake_up()
      }
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
        @core.WindowEvent::SurfaceResized(@dpi.PhysicalSize::new(arg0, arg1)),
      )
    _ => ()
  }
}

///|
fn app_state_install_native_callbacks() -> Unit {
  native_install_input_event_callback(
    fn(
      callback,
      raw_id,
      kind,
      x,
      y,
      state,
      button,
      modifiers,
      scancode,
      repeat,
      pointer_source,
      pointer_kind,
      scroll_delta_kind,
      delta_x,
      delta_y,
      phase,
    ) {
      callback(
        raw_id, kind, x, y, state, button, modifiers, scancode, repeat, pointer_source,
        pointer_kind, scroll_delta_kind, delta_x, delta_y, phase,
      )
    },
    native_callback_input_event,
  )
  native_install_text_input_event_callback(
    fn(
      callback,
      raw_id,
      kind,
      x,
      y,
      state,
      text,
      cursor_start,
      cursor_end,
      path,
    ) {
      callback(raw_id, kind, x, y, state, text, cursor_start, cursor_end, path)
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
    fn(callback, kind, button, delta_x, delta_y) {
      callback(kind, button, delta_x, delta_y)
    },
    native_callback_device_event,
  )
  native_install_lifecycle_callback(
    fn(callback, kind) { callback(kind) },
    native_callback_lifecycle,
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
  x : Double,
  y : Double,
  state : Int,
  button : Int,
  modifiers : Int,
  scancode : Int,
  repeat : Int,
  pointer_source : Int,
  pointer_kind : Int,
  scroll_delta_kind : Int,
  delta_x : Double,
  delta_y : Double,
  phase : Int,
) -> Unit {
  queue_native_input_event(
    raw_id, kind, x, y, state, button, modifiers, scancode, repeat, pointer_source,
    pointer_kind, scroll_delta_kind, delta_x, delta_y, phase,
  )
}

///|
fn native_callback_text_input_event(
  raw_id : Int,
  kind : Int,
  x : Double,
  y : Double,
  state : Int,
  text : Bytes,
  cursor_start : Int,
  cursor_end : Int,
  path : Bytes,
) -> Unit {
  queue_native_text_input_event(
    raw_id, kind, x, y, state, text, cursor_start, cursor_end, path,
  )
}

///|
fn native_callback_device_event(
  native_event_kind : Int,
  button : Int,
  delta_x : Double,
  delta_y : Double,
) -> Unit {
  app_state_queue_device_event(native_event_kind, button, delta_x, delta_y)
}

///|
fn native_callback_lifecycle(kind : Int) -> Unit {
  match kind {
    1 => native_callback_did_finish_launching()
    2 => native_callback_will_terminate()
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
fn app_state_take_did_finish_launching_notification() -> Bool {
  let pending = app_state_runtime.val.pending_did_finish_launching
  app_state_runtime.val.pending_did_finish_launching = false
  pending
}

///|
fn app_state_take_will_terminate_notification() -> Bool {
  let pending = app_state_runtime.val.pending_will_terminate
  app_state_runtime.val.pending_will_terminate = false
  pending
}

///|
fn app_state_take_destroyed_window_ids() -> Array[Int] {
  let pending = app_state_runtime.val.pending_destroyed_window_ids
  app_state_runtime.val.pending_destroyed_window_ids = []
  pending
}

///|
fn app_state_mark_window_destroyed(raw_id : Int) -> Unit {
  app_state_queue_unique_window_id(
    app_state_runtime.val.pending_destroyed_window_ids,
    raw_id,
  )
  native_event_loop_wake_up()
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
fn app_state_queue_window_callback(
  window_id : @core.WindowId,
  event : @core.WindowEvent,
) -> Unit {
  if app_state_is_running() {
    app_state_runtime.val.deferred_callbacks.push(
      DeferredCallback::WindowEvent(window_id, event),
    )
    native_event_loop_wake_up()
  }
}

///|
fn app_state_queue_standard_key_binding_callback(
  window_id : @core.WindowId,
  action : String,
) -> Unit {
  if app_state_is_running() {
    app_state_runtime.val.deferred_callbacks.push(
      DeferredCallback::StandardKeyBinding(window_id, action),
    )
    native_event_loop_wake_up()
  }
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
  app_state_runtime.val.event_handler_in_use == false
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
  min_timeout(
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
      if app_state_runtime.val.pending_proxy_wake {
        @core.StartCause::WaitCancelled(
          start_time_ms,
          Some(requested_resume_ms),
        )
      } else if runtime_now_ms() >= requested_resume_ms {
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
fn clamp_wait_timeout_to_int(timeout_ms : Int64) -> Int {
  if timeout_ms <= 0 {
    0
  } else if timeout_ms > 2147483647L {
    2147483647
  } else {
    timeout_ms.to_int()
  }
}

///|
fn app_state_wait_timeout_ms() -> Int {
  if app_state_stop_before_wait() {
    0
  } else {
    match app_state_runtime.val.waker.next_fire_date() {
      Some(deadline_ms) => {
        let now = runtime_now_ms()
        clamp_wait_timeout_to_int(deadline_ms - now)
      }
      None => -1
    }
  }
}

///|
fn app_state_wait() -> @core.StartCause {
  let _ = wait_for_events(app_state_wait_timeout_ms())
  app_state_wait_cause()
}

///|
fn app_state_did_finish_launching() -> Unit {
  if app_state_runtime.val.is_launched {
    return ()
  }
  app_state_runtime.val.is_launched = true
  app_state_apply_launch_policy()
  app_state_runtime.val.waker.start()
  if app_state_runtime.val.stop_on_launch {
    app_state_runtime.val.stop_on_launch = false
    app_state_set_stop_before_wait(true)
    app_state_set_stop_after_wait(false)
  }
}

///|
fn app_state_apply_launch_policy() -> Unit {
  if app_state_runtime.val.activation_policy >= 0 {
    native_application_set_activation_policy(
      app_state_runtime.val.activation_policy,
    )
  }
  native_application_set_activate_ignoring_other_apps(
    app_state_runtime.val.activate_ignoring_other_apps,
  )
  initialize(app_state_runtime.val.default_menu)
}

///|
fn app_state_will_terminate() -> Unit {
  app_state_exit()
  app_state_internal_exit()
}

///|
fn app_state_internal_exit() -> Unit {
  app_state_runtime.val.is_running = false
  app_state_runtime.val.event_handler_in_use = false
  app_state_runtime.val.pending_proxy_wake = false
  app_state_runtime.val.stop_on_redraw = false
  app_state_runtime.val.stop_on_launch = false
  app_state_runtime.val.stop_before_wait = false
  app_state_runtime.val.stop_after_wait = false
  app_state_runtime.val.waker.stop()
  app_state_runtime.val.wait_timeout_ms = None
  app_state_runtime.val.start_time_ms = None
  app_state_runtime.val.pending_did_finish_launching = false
  app_state_runtime.val.pending_will_terminate = false
  app_state_runtime.val.pending_destroyed_window_ids = []
  app_state_runtime.val.pending_redraw_window_ids = []
  app_state_runtime.val.window_handles = []
  app_state_runtime.val.deferred_callbacks = []
}

///|
fn[A : ApplicationHandler] app_state_dispatch_callback(
  app : A,
  event_loop : ActiveEventLoop,
  callback : DeferredCallback,
) -> Unit {
  match callback {
    DeferredCallback::NewEvents(cause) => app.new_events(event_loop, cause)
    DeferredCallback::CanCreateSurfaces => app.can_create_surfaces(event_loop)
    DeferredCallback::AboutToWait => app.about_to_wait(event_loop)
    DeferredCallback::ProxyWakeUp => {
      app_state_runtime.val.pending_proxy_wake = false
      app.proxy_wake_up(event_loop)
    }
    DeferredCallback::WindowEvent(window_id, event) =>
      app.window_event(event_loop, window_id, event)
    DeferredCallback::ScaleFactorChanged(
      raw_id,
      window_id,
      scale_factor,
      width,
      height
    ) => {
      let writer = @core.SurfaceSizeWriter::new(
        @dpi.PhysicalSize::new(width, height),
      )
      app.window_event(
        event_loop,
        window_id,
        @core.WindowEvent::ScaleFactorChanged(scale_factor, writer),
      )
      let requested_size = writer.surface_size()
      match app_state_window_handle(raw_id) {
        Some(window_handle) =>
          set_surface_size(
            window_handle,
            requested_size.width(),
            requested_size.height(),
          )
        None => ()
      }
    }
    DeferredCallback::DeviceEvent(event) =>
      app.device_event(event_loop, None, event)
    DeferredCallback::StandardKeyBinding(window_id, action) =>
      if app.macos_handler() {
        app.standard_key_binding(event_loop, window_id, action)
      }
  }
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
  while app_state_is_running() &&
        app_state_runtime.val.event_handler_in_use == false &&
        app_state_runtime.val.deferred_callbacks.is_empty() == false {
    let callback = app_state_runtime.val.deferred_callbacks.remove(0)
    with_handler(app, event_loop, callback)
  }
}

///|
fn[A : ApplicationHandler] app_state_maybe_queue_with_handler(
  app : A,
  event_loop : ActiveEventLoop,
  callback : DeferredCallback,
) -> Unit {
  if app_state_is_running() == false {
    return ()
  }
  if app_state_runtime.val.event_handler_in_use {
    app_state_runtime.val.deferred_callbacks.push(callback)
    native_event_loop_wake_up()
    return ()
  }
  with_handler(app, event_loop, callback)
  app_state_dispatch_deferred_callbacks(app, event_loop)
}

///|
fn[A : ApplicationHandler] app_state_dispatch_new_events(
  app : A,
  event_loop : ActiveEventLoop,
  cause : @core.StartCause,
) -> Unit {
  maybe_queue_with_handler(app, event_loop, DeferredCallback::NewEvents(cause))
}

///|
fn[A : ApplicationHandler] app_state_dispatch_can_create_surfaces(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  maybe_queue_with_handler(app, event_loop, DeferredCallback::CanCreateSurfaces)
}

///|
fn[A : ApplicationHandler] app_state_dispatch_about_to_wait(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  if app_state_is_running() == false {
    return ()
  }
  if app_state_runtime.val.event_handler_in_use {
    app_state_runtime.val.deferred_callbacks.push(DeferredCallback::AboutToWait)
    native_event_loop_wake_up()
    return ()
  }
  with_handler(app, event_loop, DeferredCallback::AboutToWait)
}

///|
fn[A : ApplicationHandler] app_state_dispatch_window_event(
  app : A,
  event_loop : ActiveEventLoop,
  window_id : @core.WindowId,
  event : @core.WindowEvent,
) -> Unit {
  maybe_queue_with_handler(
    app,
    event_loop,
    DeferredCallback::WindowEvent(window_id, event),
  )
}

///|
fn[A : ApplicationHandler] app_state_dispatch_init_events(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  app_state_dispatch_new_events(app, event_loop, @core.StartCause::Init)
  app_state_dispatch_can_create_surfaces(app, event_loop)
}

///|
fn[A : ApplicationHandler] app_state_did_finish_launching_and_dispatch(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  if app_state_is_running() == false {
    set_is_running(true)
  }
  did_finish_launching()
  dispatch_init_events(app, event_loop)
}

///|
fn[A : ApplicationHandler] app_state_cleared(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  if app_state_handler_ready() == false || app_state_is_running() == false {
    return ()
  }
  app_state_dispatch_deferred_callbacks(app, event_loop)
  if app_state_handler_ready() == false || app_state_is_running() == false {
    return ()
  }
  let mut stop_before_wait = false
  for raw_id in app_state_take_all_redraws() {
    let window_id = @core.WindowId::from_raw(raw_id)
    if handle_redraw(app, event_loop, window_id) {
      stop_before_wait = true
    }
  }
  app_state_dispatch_about_to_wait(app, event_loop)
  if app_state_runtime.val.pending_proxy_wake {
    stop_before_wait = true
  }
  if app_state_runtime.val.deferred_callbacks.is_empty() == false {
    stop_before_wait = true
  }
  if app_state_exiting() {
    event_loop.inner.notify_windows_of_exit()
    stop_before_wait = true
  }
  let start_time_ms = runtime_now_ms()
  app_state_prepare_wait_cycle(start_time_ms)
  if stop_before_wait || app_state_stop_before_wait() {
    stop_app_immediately()
    app_state_runtime.val.waker.start_at(Some(start_time_ms))
  } else {
    app_state_runtime.val.waker.start_at(app_state_effective_wait_timeout_ms())
  }
  ()
}

///|
fn[A : ApplicationHandler] app_state_wakeup(
  app : A,
  event_loop : ActiveEventLoop,
  cause : @core.StartCause,
) -> Unit {
  if app_state_handler_ready() == false || app_state_is_running() == false {
    return ()
  }
  app_state_dispatch_deferred_callbacks(app, event_loop)
  if app_state_handler_ready() == false || app_state_is_running() == false {
    return ()
  }
  if app_state_stop_after_wait() {
    stop_app_immediately()
  }
  app_state_dispatch_new_events(app, event_loop, cause)
  ()
}

///|
fn[A : ApplicationHandler] app_state_handle_redraw(
  app : A,
  event_loop : ActiveEventLoop,
  window_id : @core.WindowId,
) -> Bool {
  app_state_dispatch_window_event(
    app,
    event_loop,
    window_id,
    @core.WindowEvent::RedrawRequested,
  )
  app_state_stop_on_redraw()
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
fn app_state_clear_redraws() -> Unit {
  app_state_runtime.val.pending_redraw_window_ids = []
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

///|
// Port target: app_state.rs::setup_global
fn setup_global(
  activation_policy : Int,
  default_menu : Bool,
  activate_ignoring_other_apps : Bool,
) -> Unit {
  get()
  app_state_configure_launch_policy(
    activation_policy, default_menu, activate_ignoring_other_apps,
  )
  app_state_install_native_callbacks()
}

///|
// Port target: app_state.rs::get
fn get() -> Unit {
  ()
}

///|
// Port target: app_state.rs::did_finish_launching
fn did_finish_launching() -> Unit {
  app_state_did_finish_launching()
}

///|
// Port target: app_state.rs::will_terminate
fn will_terminate() -> Unit {
  app_state_will_terminate()
}

///|
// Port target: app_state.rs::event_loop_proxy
fn event_loop_proxy() -> EventLoopProxy {
  { _unit: () }
}

///|
// Port target: app_state.rs::set_stop_on_launch
fn set_stop_on_launch() -> Unit {
  app_state_set_stop_on_launch(true)
}

///|
// Port target: app_state.rs::set_stop_before_wait
fn set_stop_before_wait(value : Bool) -> Unit {
  app_state_set_stop_before_wait(value)
}

///|
// Port target: app_state.rs::set_stop_after_wait
fn set_stop_after_wait(value : Bool) -> Unit {
  app_state_set_stop_after_wait(value)
}

///|
// Port target: app_state.rs::set_stop_on_redraw
fn set_stop_on_redraw(value : Bool) -> Unit {
  app_state_set_stop_on_redraw(value)
}

///|
// Port target: app_state.rs::set_wait_timeout
fn set_wait_timeout(value : Int64?) -> Unit {
  app_state_set_wait_timeout_ms(value)
}

///|
// Port target: app_state.rs::internal_exit
fn internal_exit() -> Unit {
  app_state_internal_exit()
}

///|
// Port target: app_state.rs::is_launched
fn is_launched() -> Bool {
  app_state_is_launched()
}

///|
// Port target: app_state.rs::set_is_running
fn set_is_running(value : Bool) -> Unit {
  app_state_set_running(value)
}

///|
// Port target: app_state.rs::is_running
fn is_running() -> Bool {
  app_state_is_running()
}

///|
// Port target: app_state.rs::clear_exit
fn clear_exit() -> Unit {
  app_state_clear_exit()
}

///|
fn queue_proxy_wake_up() -> Unit {
  app_state_queue_proxy_wake_up()
}

///|
fn take_destroyed_window_ids() -> Array[Int] {
  app_state_take_destroyed_window_ids()
}

///|
fn mark_window_destroyed(raw_id : Int) -> Unit {
  app_state_mark_window_destroyed(raw_id)
}

///|
// Port target: app_state.rs::handle_redraw
fn[A : ApplicationHandler] handle_redraw(
  app : A,
  event_loop : ActiveEventLoop,
  window_id : @core.WindowId,
) -> Bool {
  app_state_handle_redraw(app, event_loop, window_id)
}

///|
// Port target: app_state.rs::queue_redraw
fn queue_redraw(window_id : Int) -> Unit {
  app_state_queue_redraw(window_id)
}

///|
fn register_window_handle(raw_id : Int, window_handle : UInt64) -> Unit {
  app_state_register_window_handle(raw_id, window_handle)
}

///|
fn window_handle_for_id(raw_id : Int) -> UInt64? {
  app_state_window_handle(raw_id)
}

///|
fn unregister_window_handle(raw_id : Int) -> Unit {
  app_state_unregister_window_handle(raw_id)
}

///|
// Port target: app_state.rs::with_handler
fn[A : ApplicationHandler] with_handler(
  app : A,
  event_loop : ActiveEventLoop,
  callback : DeferredCallback,
) -> Unit {
  app_state_with_handler(app, event_loop, callback)
}

///|
// Port target: app_state.rs::maybe_queue_with_handler
fn[A : ApplicationHandler] maybe_queue_with_handler(
  app : A,
  event_loop : ActiveEventLoop,
  callback : DeferredCallback,
) -> Unit {
  app_state_maybe_queue_with_handler(app, event_loop, callback)
}

///|
fn[A : ApplicationHandler] dispatch_deferred_callbacks(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  app_state_dispatch_deferred_callbacks(app, event_loop)
}

///|
fn queue_window_callback(
  window_id : @core.WindowId,
  event : @core.WindowEvent,
) -> Unit {
  app_state_queue_window_callback(window_id, event)
}

///|
fn queue_standard_key_binding_callback(
  window_id : @core.WindowId,
  action : String,
) -> Unit {
  app_state_queue_standard_key_binding_callback(window_id, action)
}

///|
// Port target: app_state.rs::dispatch_init_events
fn[A : ApplicationHandler] dispatch_init_events(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  app_state_dispatch_init_events(app, event_loop)
}

///|
// Port target: app_state.rs::wakeup
fn[A : ApplicationHandler] wakeup(
  app : A,
  event_loop : ActiveEventLoop,
  cause : @core.StartCause,
) -> Unit {
  app_state_wakeup(app, event_loop, cause)
}

///|
// Port target: app_state.rs::cleared
fn[A : ApplicationHandler] cleared(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  app_state_cleared(app, event_loop)
}

///|
// Port target: app_state.rs::min_timeout
fn min_timeout(a : Int64?, b : Int64?) -> Int64? {
  min_timeout_ms(a, b)
}
