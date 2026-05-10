///|
priv enum DeferredCallback {
  NewEvents(@core.StartCause)
  CanCreateSurfaces
  AboutToWait
  ProxyWakeUp
  WindowEvent(@core.WindowId, @core.WindowEvent)
  ScaleFactorChanged(@core.WindowId, Double, Int, Int)
  DeviceEvent(@core.DeviceEvent)
  StandardKeyBinding(@core.WindowId, String)
}

///|
priv struct WindowHandleEntry {
  raw_id : Int
  hwnd : UInt64
}

///|
priv struct AppStateRuntime {
  mut next_window_id : Int
  mut is_running : Bool
  mut exit_requested : Bool
  mut exit_code : Int
  mut event_handler_in_use : Bool
  mut control_flow : @core.ControlFlow
  mut msg_window : UInt64
  mut thread_id : UInt
  mut pending_redraw_window_ids : Array[Int]
  mut window_handles : Array[WindowHandleEntry]
  mut deferred_callbacks : Array[DeferredCallback]
  mut dispatch_callback : ((DeferredCallback) -> Unit)?
}

///|
fn AppStateRuntime::new() -> AppStateRuntime {
  {
    next_window_id: 1,
    is_running: false,
    exit_requested: false,
    exit_code: 0,
    event_handler_in_use: false,
    control_flow: @core.ControlFlow::Wait,
    msg_window: (0 : Int).to_uint64(),
    thread_id: (0 : UInt),
    pending_redraw_window_ids: [],
    window_handles: [],
    deferred_callbacks: [],
    dispatch_callback: None,
  }
}

///|
let app_state_runtime : Ref[AppStateRuntime] = Ref::new(AppStateRuntime::new())

///|
let event_loop_global_created : Ref[Bool] = Ref::new(false)

///|
fn app_state_next_window_id() -> Int {
  let id = app_state_runtime.val.next_window_id
  app_state_runtime.val.next_window_id = id + 1
  id
}

///|
fn app_state_register_window_handle(raw_id : Int, hwnd : UInt64) -> Unit {
  let next_entries : Array[WindowHandleEntry] = []
  let mut replaced = false
  for entry in app_state_runtime.val.window_handles {
    if entry.raw_id == raw_id {
      next_entries.push({ raw_id, hwnd })
      replaced = true
    } else {
      next_entries.push(entry)
    }
  }
  if replaced == false {
    next_entries.push({ raw_id, hwnd })
  }
  app_state_runtime.val.window_handles = next_entries
}

///|
fn app_state_unregister_window_handle(raw_id : Int) -> Unit {
  let next_entries : Array[WindowHandleEntry] = []
  for entry in app_state_runtime.val.window_handles {
    if entry.raw_id != raw_id {
      next_entries.push(entry)
    }
  }
  app_state_runtime.val.window_handles = next_entries
}

///|
fn app_state_window_handle(raw_id : Int) -> UInt64? {
  for entry in app_state_runtime.val.window_handles {
    if entry.raw_id == raw_id {
      return Some(entry.hwnd)
    }
  }
  None
}

///|
fn app_state_set_msg_window(hwnd : UInt64) -> Unit {
  app_state_runtime.val.msg_window = hwnd
}

///|
fn app_state_set_thread_id(tid : UInt) -> Unit {
  app_state_runtime.val.thread_id = tid
}

///|
fn app_state_msg_window() -> UInt64 {
  app_state_runtime.val.msg_window
}

///|
fn app_state_thread_id() -> UInt {
  app_state_runtime.val.thread_id
}

///|
fn app_state_is_running() -> Bool {
  app_state_runtime.val.is_running
}

///|
fn app_state_set_running(running : Bool) -> Unit {
  app_state_runtime.val.is_running = running
}

///|
fn app_state_exit_requested() -> Bool {
  app_state_runtime.val.exit_requested
}

///|
fn app_state_exit_code() -> Int {
  app_state_runtime.val.exit_code
}

///|
fn app_state_set_exit(code : Int) -> Unit {
  app_state_runtime.val.exit_requested = true
  app_state_runtime.val.exit_code = code
}

///|
fn app_state_clear_exit() -> Unit {
  app_state_runtime.val.exit_requested = false
  app_state_runtime.val.exit_code = 0
}

///|
fn app_state_set_control_flow(cf : @core.ControlFlow) -> Unit {
  app_state_runtime.val.control_flow = cf
}

///|
fn app_state_control_flow() -> @core.ControlFlow {
  app_state_runtime.val.control_flow
}

///|
fn app_state_set_handler_in_use(in_use : Bool) -> Unit {
  app_state_runtime.val.event_handler_in_use = in_use
}

///|
fn app_state_handler_in_use() -> Bool {
  app_state_runtime.val.event_handler_in_use
}

///|
fn app_state_handler_ready() -> Bool {
  app_state_runtime.val.is_running &&
  !app_state_runtime.val.event_handler_in_use &&
  app_state_runtime.val.dispatch_callback is Some(_)
}

///|
fn[A : ApplicationHandler] app_state_set_dispatch_handler(
  app : A,
  active_loop : ActiveEventLoop,
) -> Unit {
  app_state_runtime.val.dispatch_callback = Some(fn(
    cb : DeferredCallback,
  ) -> Unit {
    app_state_dispatch_callback(app, active_loop, cb)
  })
}

///|
fn app_state_clear_dispatch_handler() -> Unit {
  app_state_runtime.val.dispatch_callback = None
}

///|
fn[A : ApplicationHandler] app_state_dispatch_callback(
  app : A,
  active_loop : ActiveEventLoop,
  callback : DeferredCallback,
) -> Unit {
  app_state_runtime.val.event_handler_in_use = true
  match callback {
    NewEvents(cause) => app.new_events(active_loop, cause)
    CanCreateSurfaces => app.can_create_surfaces(active_loop)
    AboutToWait => app.about_to_wait(active_loop)
    ProxyWakeUp => app.proxy_wake_up(active_loop)
    WindowEvent(window_id, event) =>
      app.window_event(active_loop, window_id, event)
    ScaleFactorChanged(window_id, scale_factor, dpi_x, dpi_y) => {
      let size_writer = @core.SurfaceSizeWriter::new(
        @dpi.PhysicalSize::new(
          dpi_x *
          app_state_scale_factor_for_window(window_id.into_raw()).to_int(),
          dpi_y *
          app_state_scale_factor_for_window(window_id.into_raw()).to_int(),
        ),
      )
      app.window_event(
        active_loop,
        window_id,
        @core.WindowEvent::ScaleFactorChanged(scale_factor, size_writer),
      )
    }
    DeviceEvent(event) => app.device_event(active_loop, None, event)
    StandardKeyBinding(window_id, action) =>
      app.standard_key_binding(active_loop, window_id, action)
  }
  app_state_runtime.val.event_handler_in_use = false
}

///|
fn app_state_queue_callback(callback : DeferredCallback) -> Unit {
  if app_state_handler_ready() &&
    !(app_state_runtime.val.event_handler_in_use &&
    callback is WindowEvent(_, @core.WindowEvent::RedrawRequested)) {
    match app_state_runtime.val.dispatch_callback {
      Some(dispatch) => dispatch(callback)
      None => app_state_runtime.val.deferred_callbacks.push(callback)
    }
  } else {
    app_state_runtime.val.deferred_callbacks.push(callback)
  }
}

///|
fn app_state_queue_window_event(
  raw_id : Int,
  event : @core.WindowEvent,
) -> Unit {
  let window_id = @core.WindowId::from_raw(raw_id)
  app_state_queue_callback(WindowEvent(window_id, event))
}

///|
fn app_state_queue_redraw(raw_id : Int) -> Unit {
  let found = app_state_runtime.val.pending_redraw_window_ids.search_by(id => {
    id == raw_id
  })
  if found is None {
    app_state_runtime.val.pending_redraw_window_ids.push(raw_id)
  }
}

///|
fn[A : ApplicationHandler] app_state_dispatch_deferred_callbacks(
  app : A,
  active_loop : ActiveEventLoop,
) -> Unit {
  let callbacks = app_state_runtime.val.deferred_callbacks
  app_state_runtime.val.deferred_callbacks = []
  for callback in callbacks {
    match app_state_runtime.val.dispatch_callback {
      Some(dispatch) => dispatch(callback)
      None => ()
    }
  }
}

///|
fn[A : ApplicationHandler] app_state_dispatch_init_events(
  app : A,
  active_loop : ActiveEventLoop,
) -> Unit {
  app_state_set_dispatch_handler(app, active_loop)
  app_state_queue_callback(NewEvents(@core.StartCause::Init))
  app_state_queue_callback(CanCreateSurfaces)
  app_state_dispatch_deferred_callbacks(app, active_loop)
}

///|
fn[A : ApplicationHandler] app_state_dispatch_redraws(
  app : A,
  active_loop : ActiveEventLoop,
) -> Unit {
  let redraw_ids = app_state_runtime.val.pending_redraw_window_ids
  app_state_runtime.val.pending_redraw_window_ids = []
  for raw_id in redraw_ids {
    app_state_queue_window_event(raw_id, @core.WindowEvent::RedrawRequested)
  }
  app_state_dispatch_deferred_callbacks(app, active_loop)
}

///|
fn app_state_scale_factor_for_window(raw_id : Int) -> Double {
  match app_state_window_handle(raw_id) {
    Some(hwnd) => native_get_dpi_for_window(hwnd).to_double() / 96.0
    None => 1.0
  }
}

///|
fn app_state_internal_exit() -> Unit {
  app_state_runtime.val.is_running = false
  app_state_runtime.val.deferred_callbacks = []
  app_state_runtime.val.pending_redraw_window_ids = []
}

///|
fn app_state_install_native_callbacks() -> Unit {
  native_install_window_event_callback(
    fn(callback, kind, raw_id, arg0, arg1, arg2, argd) {
      callback(kind, raw_id, arg0, arg1, arg2, argd)
    },
    native_callback_window_event,
  )
  native_install_input_event_callback(
    fn(callback, raw_id, kind, wparam, lparam) {
      callback(raw_id, kind, wparam, lparam)
    },
    native_callback_input_event,
  )
  native_install_sync_query_callback(
    fn(callback, raw_id, kind, arg0) { callback(raw_id, kind, arg0) },
    native_callback_sync_query,
  )
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
  dispatch_native_window_event(kind, raw_id, arg0, arg1, arg2, argd)
}

///|
fn native_callback_input_event(
  raw_id : Int,
  kind : Int,
  wparam : UInt64,
  lparam : Int64,
) -> Unit {
  dispatch_native_input_event(raw_id, kind, wparam, lparam)
}

///|
fn native_callback_sync_query(raw_id : Int, kind : Int, arg0 : Int) -> Int {
  dispatch_native_sync_query(raw_id, kind, arg0)
}
