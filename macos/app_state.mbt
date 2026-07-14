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
  identity : UInt64
  native_handle : NativeWindow?
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
  mut deferred_callbacks : Array[DeferredCallback]
  mut dispatch_callback : ((DeferredCallback) -> Unit)?
}

///|
fn AppStateRuntime::AppStateRuntime() -> AppStateRuntime {
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
    control_flow: Wait,
    waker: EventLoopWaker(),
    start_time_ms: None,
    wait_timeout_ms: None,
    pending_redraw_window_ids: [],
    window_handles: [],
    deferred_callbacks: [],
    dispatch_callback: None,
  }
}

///|
let app_state_runtime : Ref[AppStateRuntime] = Ref(AppStateRuntime())

///|
let app_state_window_position_raw_ids : Ref[Array[Int]] = Ref([])

///|
let app_state_window_position_xs : Ref[Array[Int]] = Ref([])

///|
let app_state_window_position_ys : Ref[Array[Int]] = Ref([])

///|
fn app_state_window_position_index(raw_id : Int) -> Int? {
  app_state_window_position_raw_ids.val.search_by(id => id == raw_id)
}

///|
fn app_state_set_window_position_state(raw_id : Int, x : Int, y : Int) -> Unit {
  match app_state_window_position_index(raw_id) {
    Some(index) => {
      app_state_window_position_xs.val[index] = x
      app_state_window_position_ys.val[index] = y
    }
    None => {
      app_state_window_position_raw_ids.val.push(raw_id)
      app_state_window_position_xs.val.push(x)
      app_state_window_position_ys.val.push(y)
    }
  }
}

///|
fn app_state_clear_window_position_state(raw_id : Int) -> Unit {
  match app_state_window_position_index(raw_id) {
    Some(index) => {
      ignore(app_state_window_position_raw_ids.val.remove(index))
      ignore(app_state_window_position_xs.val.remove(index))
      ignore(app_state_window_position_ys.val.remove(index))
    }
    None => ()
  }
}

///|
fn app_state_queue_window_moved_if_changed(
  raw_id : Int,
  window_id : @core.WindowId,
  logical_x : Int,
  logical_y : Int,
) -> Unit {
  let should_queue = match app_state_window_position_index(raw_id) {
    Some(index) =>
      app_state_window_position_xs.val[index] != logical_x ||
      app_state_window_position_ys.val[index] != logical_y
    None => true
  }
  app_state_set_window_position_state(raw_id, logical_x, logical_y)
  if should_queue {
    app_state_queue_window_callback(
      window_id,
      Moved(
        app_state_logical_position_to_physical(raw_id, logical_x, logical_y),
      ),
    )
  }
}

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
        Some(PointerMotion(delta_x, delta_y))
      }
    2 =>
      if button < 0 {
        None
      } else {
        Some(Button(@core.ButtonId::from_raw(button), Pressed))
      }
    3 =>
      if button < 0 {
        None
      } else {
        Some(Button(@core.ButtonId::from_raw(button), Released))
      }
    _ => None
  }
}

///|
fn app_state_callback_requires_running(callback : DeferredCallback) -> Bool {
  match callback {
    DidFinishLaunching | WillTerminate => false
    _ => true
  }
}

///|
fn app_state_defer_callback(callback : DeferredCallback) -> Unit {
  app_state_deferred_queue_push(callback)
  native_event_loop_wake_up()
}

///|
fn app_state_take_next_dispatchable_callback() -> DeferredCallback? {
  app_state_deferred_queue_take_next_dispatchable(app_state_is_running())
}

///|
fn app_state_maybe_dispatch_callback(callback : DeferredCallback) -> Unit {
  if callback is WillTerminate {
    app_state_will_terminate()
    return ()
  }
  if app_state_callback_requires_running(callback) &&
    app_state_is_running() == false {
    return ()
  }
  if !app_state_has_dispatch_handler() {
    match callback {
      // Port target: app_state.rs::did_finish_launching / will_terminate
      // Even without an active handler, lifecycle state still advances.
      DidFinishLaunching => app_state_did_finish_launching()
      WillTerminate => app_state_will_terminate()
      _ => ()
    }
    return ()
  }
  if app_state_handler_in_use() {
    match callback {
      // Port target: app_state.rs::handle_redraw
      // Drop re-entrant redraw callbacks instead of queueing them.
      WindowEvent(_, RedrawRequested) => return ()
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
  if app_state_is_launched() {
    return ()
  }
  if app_state_deferred_queue_contains(callback => {
      callback is DidFinishLaunching
    }) {
    return ()
  }
  app_state_maybe_dispatch_callback(DidFinishLaunching)
}

///|
fn app_state_queue_will_terminate_notification() -> Unit {
  if app_state_will_terminate_handled() {
    return ()
  }
  if app_state_deferred_queue_contains(callback => callback is WillTerminate) {
    return ()
  }
  app_state_maybe_dispatch_callback(WillTerminate)
}

///|
fn app_state_queue_proxy_wake_up() -> Unit {
  app_state_maybe_dispatch_callback(ProxyWakeUp)
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
    Some(event) => app_state_maybe_dispatch_callback(DeviceEvent(event))
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
  @dpi.LogicalSize::LogicalSize(width.to_double(), height.to_double()).to_physical(
    app_state_window_scale_factor(raw_id),
  )
}

///|
fn app_state_logical_position_to_physical(
  raw_id : Int,
  x : Int,
  y : Int,
) -> @dpi.PhysicalPosition {
  @dpi.LogicalPosition::LogicalPosition(x.to_double(), y.to_double()).to_physical(
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
  ignore(_arg2)
  let window_id = @core.WindowId::from_raw(raw_id)
  let window_handle = app_state_window_handle(raw_id)
  let focused = match window_handle {
    Some(window_handle) => native_window_has_focus(window_handle)
    None => arg0 != 0
  }
  let occluded = match window_handle {
    Some(window_handle) => native_window_is_occluded(window_handle)
    None => arg0 != 0
  }
  let logical_x = match window_handle {
    Some(window_handle) => native_window_x(window_handle)
    None => arg0
  }
  let logical_y = match window_handle {
    Some(window_handle) => native_window_y(window_handle)
    None => arg1
  }
  let logical_width = match window_handle {
    Some(window_handle) => native_window_content_width(window_handle)
    None => arg0
  }
  let logical_height = match window_handle {
    Some(window_handle) => native_window_content_height(window_handle)
    None => arg1
  }
  let scale_factor = match window_handle {
    Some(window_handle) => native_window_scale_factor(window_handle)
    None => if argd > 0.0 { argd } else { 1.0 }
  }
  match kind {
    1 => app_state_queue_window_callback(window_id, CloseRequested)
    2 => {
      match window_handle {
        Some(window_handle) => {
          clear_window_fullscreen_transition_state(
            native_window_identity(window_handle),
          )
          clear_window_platform_state(native_window_identity(window_handle))
        }
        None => ()
      }
      app_state_clear_window_redraw(raw_id)
      view_clear_pressed_modifiers(raw_id)
      view_clear_ime_state(raw_id)
      app_state_clear_window_position_state(raw_id)
      app_state_unregister_window_handle(raw_id)
      app_state_queue_window_callback(window_id, Destroyed)
    }
    3 => {
      app_state_queue_window_callback(window_id, Focused(focused))
      if focused == false {
        view_clear_pressed_modifiers(raw_id)
        app_state_queue_window_callback(
          window_id,
          ModifiersChanged(@core.Modifiers::default()),
        )
      }
    }
    4 =>
      app_state_queue_window_moved_if_changed(
        raw_id, window_id, logical_x, logical_y,
      )
    5 =>
      app_state_maybe_dispatch_callback(
        ScaleFactorChanged(
          raw_id, window_id, scale_factor, logical_width, logical_height,
        ),
      )
    6 =>
      match theme_from_native(arg0) {
        Some(theme) =>
          app_state_queue_window_callback(window_id, ThemeChanged(theme))
        None => ()
      }
    7 => app_state_queue_window_callback(window_id, Occluded(occluded))
    8 =>
      app_state_queue_window_callback(
        window_id,
        SurfaceResized(
          app_state_logical_size_to_physical(
            raw_id, logical_width, logical_height,
          ),
        ),
      )
    9 =>
      match window_handle {
        Some(window_handle) =>
          set_window_fullscreen_transition_state(
            native_window_identity(window_handle),
            true,
          )
        None => ()
      }
    10 =>
      match window_handle {
        Some(window_handle) =>
          set_window_fullscreen_transition_state(
            native_window_identity(window_handle),
            true,
          )
        None => ()
      }
    11 => {
      match window_handle {
        Some(window_handle) =>
          set_window_fullscreen_transition_state(
            native_window_identity(window_handle),
            false,
          )
        None => ()
      }
      app_state_process_queued_fullscreen_request(raw_id)
      app_state_queue_window_callback(
        window_id,
        SurfaceResized(
          app_state_logical_size_to_physical(
            raw_id, logical_width, logical_height,
          ),
        ),
      )
    }
    12 => {
      match window_handle {
        Some(window_handle) =>
          set_window_fullscreen_transition_state(
            native_window_identity(window_handle),
            false,
          )
        None => ()
      }
      app_state_process_queued_fullscreen_request(raw_id)
      app_state_queue_window_callback(
        window_id,
        SurfaceResized(
          app_state_logical_size_to_physical(
            raw_id, logical_width, logical_height,
          ),
        ),
      )
    }
    13 => {
      match window_handle {
        Some(window_handle) =>
          set_window_fullscreen_transition_state(
            native_window_identity(window_handle),
            false,
          )
        None => ()
      }
      app_state_process_queued_fullscreen_request(raw_id)
    }
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
      event_type,
      x,
      y,
      state,
      button,
      modifier_flags,
      scancode,
      repeat,
      pointer_source,
      pointer_kind,
      scroll_delta_kind,
      delta_x,
      delta_y,
      phase,
      text_with_all_modifiers,
      text_ignoring_modifiers,
      text_without_modifiers,
    ) {
      callback(
        raw_id, kind, event_type, x, y, state, button, modifier_flags, scancode,
        repeat, pointer_source, pointer_kind, scroll_delta_kind, delta_x, delta_y,
        phase, text_with_all_modifiers, text_ignoring_modifiers, text_without_modifiers,
      )
    },
    native_callback_input_event,
  )
  native_install_text_input_event_callback(
    fn(
      callback,
      raw_id,
      kind,
      state,
      text_handle,
      cursor_start,
      cursor_end,
      path_handle,
    ) {
      callback(
        raw_id, kind, state, text_handle, cursor_start, cursor_end, path_handle,
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
    fn(callback, kind, button, delta_x, delta_y) {
      callback(kind, button, delta_x, delta_y)
    },
    native_callback_device_event,
  )
  native_install_drag_event_callback(
    fn(callback, raw_id, kind, x, y, has_position, path_cstr) {
      callback(raw_id, kind, x, y, has_position, path_cstr)
    },
    native_callback_drag_event,
  )
  native_install_sync_query_callback(
    fn(callback, raw_id, kind, arg0) { callback(raw_id, kind, arg0) },
    native_callback_sync_query,
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
fn native_callback_drag_event(
  raw_id : Int,
  kind : Int,
  x : Double,
  y : Double,
  has_position : Int,
  path_cstr : UInt64,
) -> Unit {
  queue_drag_event_from_payload(
    raw_id,
    kind,
    PhysicalPositionF64(x, y),
    native_copy_utf8_cstr_bytes(path_cstr),
    has_position != 0,
  )
}

///|
fn native_callback_device_event(
  kind : Int,
  button : Int,
  delta_x : Double,
  delta_y : Double,
) -> Unit {
  app_state_queue_device_event(kind, button, delta_x, delta_y)
}

///|
fn native_callback_sync_query(raw_id : Int, kind : Int, _arg0 : UInt64) -> Int {
  match kind {
    _ => view_native_query_state(raw_id, kind)
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
      WindowEvent(@core.WindowId::from_raw(raw_id), RedrawRequested),
    )
  }
  app_state_maybe_dispatch_callback(AboutToWait)
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
  app_state_maybe_dispatch_callback(NewEvents(app_state_wait_cause()))
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
  window_handle : NativeWindow,
) -> Unit {
  let next_entries : Array[WindowHandleEntry] = []
  let mut replaced = false
  let window_identity = native_window_identity(window_handle)
  for entry in app_state_runtime.val.window_handles {
    if entry.raw_id == raw_id {
      next_entries.push({
        raw_id,
        identity: window_identity,
        native_handle: Some(window_handle),
      })
      replaced = true
    } else {
      next_entries.push(entry)
    }
  }
  if replaced == false {
    next_entries.push({
      raw_id,
      identity: window_identity,
      native_handle: Some(window_handle),
    })
  }
  app_state_runtime.val.window_handles = next_entries
  app_state_set_window_position_state(
    raw_id,
    native_window_x(window_handle),
    native_window_y(window_handle),
  )
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
  app_state_clear_window_position_state(raw_id)
}

///|
fn app_state_window_handle(raw_id : Int) -> NativeWindow? {
  match
    app_state_runtime.val.window_handles.search_by(entry => {
      entry.raw_id == raw_id
    }) {
    Some(index) => app_state_runtime.val.window_handles[index].native_handle
    None => None
  }
}

///|
fn app_state_window_identity(raw_id : Int) -> UInt64? {
  match
    app_state_runtime.val.window_handles.search_by(entry => {
      entry.raw_id == raw_id
    }) {
    Some(index) => Some(app_state_runtime.val.window_handles[index].identity)
    None => None
  }
}

///|
fn app_state_window_raw_id(window_handle : NativeWindow) -> Int? {
  let window_identity = native_window_identity(window_handle)
  match
    app_state_runtime.val.window_handles.search_by(entry => {
      entry.identity == window_identity
    }) {
    Some(index) => Some(app_state_runtime.val.window_handles[index].raw_id)
    None => None
  }
}

///|
fn app_state_has_window_handle(window_handle : NativeWindow) -> Bool {
  let window_identity = native_window_identity(window_handle)
  app_state_runtime.val.window_handles.search_by(entry => {
    entry.identity == window_identity
  }) !=
  None
}

///|
fn app_state_process_queued_fullscreen_request(raw_id : Int) -> Unit {
  match app_state_window_handle(raw_id) {
    Some(window_handle) =>
      if !window_in_fullscreen_transition(window_handle) {
        match
          take_window_target_fullscreen_state(
            native_window_identity(window_handle),
          ) {
          Some(fullscreen) =>
            toggle_window_fullscreen(window_handle, fullscreen)
          None => ()
        }
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
  app_state_maybe_dispatch_callback(WindowEvent(window_id, event))
}

///|
fn app_state_queue_standard_key_binding_callback(
  window_id : @core.WindowId,
  action : String,
) -> Unit {
  app_state_maybe_dispatch_callback(StandardKeyBinding(window_id, action))
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
    Wait => None
    Poll => Some(runtime_now_ms())
    WaitUntil(requested_resume_ms) => Some(requested_resume_ms)
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
    Poll => Poll
    Wait => WaitCancelled(start_time_ms, None)
    WaitUntil(requested_resume_ms) =>
      if runtime_now_ms() >= requested_resume_ms {
        ResumeTimeReached(start_time_ms, requested_resume_ms)
      } else {
        WaitCancelled(start_time_ms, Some(requested_resume_ms))
      }
  }
}

///|
fn app_state_did_finish_launching() -> Unit {
  if !app_state_mark_launched() {
    return ()
  }
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
fn[A : ApplicationHandler] app_state_dispatch_callback(
  app : A,
  event_loop : ActiveEventLoop,
  callback : DeferredCallback,
) -> Unit {
  match callback {
    DidFinishLaunching =>
      if app_state_is_launched() == false {
        app_state_did_finish_launching_and_dispatch(app, event_loop)
      }
    WillTerminate => app_state_will_terminate()
    NewEvents(cause) => app.new_events(event_loop, cause)
    CanCreateSurfaces => app.can_create_surfaces(event_loop)
    AboutToWait => app.about_to_wait(event_loop)
    ProxyWakeUp => app.proxy_wake_up(event_loop)
    WindowEvent(window_id, event) => {
      let stop_on_redraw = app_state_stop_on_redraw() &&
        event is RedrawRequested
      app.window_event(event_loop, window_id, event)
      if stop_on_redraw {
        stop_app_immediately()
      }
    }
    ScaleFactorChanged(raw_id, window_id, scale_factor, width, height) => {
      let physical_size = @dpi.LogicalSize::LogicalSize(
        width.to_double(),
        height.to_double(),
      ).to_physical(scale_factor)
      let writer = @core.SurfaceSizeWriter::SurfaceSizeWriter(physical_size)
      app.window_event(
        event_loop,
        window_id,
        ScaleFactorChanged(scale_factor, writer),
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
    DeviceEvent(event) => app.device_event(event_loop, None, event)
    StandardKeyBinding(window_id, action) =>
      app.standard_key_binding(event_loop, window_id, action)
  }
}

///|
fn[A : ApplicationHandler] app_state_dispatch_init_events(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  app_state_with_handler(app, event_loop, NewEvents(Init))
  app_state_with_handler(app, event_loop, CanCreateSurfaces)
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
  if app_state_take_stop_on_launch() {
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
