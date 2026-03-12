///|
// Port target: winit-reference/winit-appkit/src/app_state.rs

///|
struct AppStateRuntime {
  mut stop_on_launch : Bool
  mut stop_before_wait : Bool
  mut stop_after_wait : Bool
  mut stop_on_redraw : Bool
  mut is_launched : Bool
  mut is_running : Bool
  mut exit_requested : Bool
  mut event_handler_in_use : Bool
  mut queued_proxy_wake_up : Bool
  mut control_flow : @core.ControlFlow
  mut start_time_ms : Int64?
  mut wait_timeout_ms : Int64?
  mut next_waker_instant_ms : Int64?
  mut pending_redraw_window_ids : Array[Int]
  mut pending_close_window_ids : Array[Int]
  mut pending_destroyed_window_ids : Array[Int]
} derive(Show)

///|
fn AppStateRuntime::new() -> AppStateRuntime {
  {
    stop_on_launch: false,
    stop_before_wait: false,
    stop_after_wait: false,
    stop_on_redraw: false,
    is_launched: false,
    is_running: false,
    exit_requested: false,
    event_handler_in_use: false,
    queued_proxy_wake_up: false,
    control_flow: @core.ControlFlow::Wait,
    start_time_ms: None,
    wait_timeout_ms: None,
    next_waker_instant_ms: None,
    pending_redraw_window_ids: [],
    pending_close_window_ids: [],
    pending_destroyed_window_ids: [],
  }
}

///|
let app_state_runtime : Ref[AppStateRuntime] = Ref::new(AppStateRuntime::new())

///|
pub fn app_state_set_stop_on_launch(value : Bool) -> Unit {
  app_state_runtime.val.stop_on_launch = value
}

///|
pub fn app_state_stop_on_launch() -> Bool {
  app_state_runtime.val.stop_on_launch
}

///|
pub fn app_state_set_stop_before_wait(value : Bool) -> Unit {
  app_state_runtime.val.stop_before_wait = value
}

///|
pub fn app_state_stop_before_wait() -> Bool {
  app_state_runtime.val.stop_before_wait
}

///|
pub fn app_state_set_stop_after_wait(value : Bool) -> Unit {
  app_state_runtime.val.stop_after_wait = value
}

///|
pub fn app_state_stop_after_wait() -> Bool {
  app_state_runtime.val.stop_after_wait
}

///|
pub fn app_state_set_stop_on_redraw(value : Bool) -> Unit {
  app_state_runtime.val.stop_on_redraw = value
}

///|
pub fn app_state_stop_on_redraw() -> Bool {
  app_state_runtime.val.stop_on_redraw
}

///|
pub fn app_state_set_launched(value : Bool) -> Unit {
  app_state_runtime.val.is_launched = value
}

///|
pub fn app_state_is_launched() -> Bool {
  app_state_runtime.val.is_launched
}

///|
pub fn app_state_set_running(value : Bool) -> Unit {
  app_state_runtime.val.is_running = value
}

///|
pub fn app_state_is_running() -> Bool {
  app_state_runtime.val.is_running
}

///|
pub fn app_state_set_handler_in_use(value : Bool) -> Unit {
  app_state_runtime.val.event_handler_in_use = value
}

///|
pub fn app_state_handler_in_use() -> Bool {
  app_state_runtime.val.event_handler_in_use
}

///|
pub fn app_state_handler_ready() -> Bool {
  app_state_runtime.val.is_running &&
  app_state_runtime.val.event_handler_in_use == false
}

///|
pub fn app_state_exit() -> Unit {
  app_state_runtime.val.exit_requested = true
}

///|
pub fn app_state_clear_exit() -> Unit {
  app_state_runtime.val.exit_requested = false
}

///|
pub fn app_state_exiting() -> Bool {
  app_state_runtime.val.exit_requested
}

///|
pub fn app_state_set_control_flow(value : @core.ControlFlow) -> Unit {
  app_state_runtime.val.control_flow = value
}

///|
pub fn app_state_control_flow() -> @core.ControlFlow {
  app_state_runtime.val.control_flow
}

///|
pub fn app_state_set_start_time_ms(value : Int64?) -> Unit {
  app_state_runtime.val.start_time_ms = value
}

///|
pub fn app_state_start_time_ms() -> Int64? {
  app_state_runtime.val.start_time_ms
}

///|
pub fn app_state_set_wait_timeout_ms(value : Int64?) -> Unit {
  app_state_runtime.val.wait_timeout_ms = value
}

///|
pub fn app_state_wait_timeout_ms() -> Int64? {
  app_state_runtime.val.wait_timeout_ms
}

///|
pub fn app_state_set_next_waker_instant_ms(value : Int64?) -> Unit {
  app_state_runtime.val.next_waker_instant_ms = value
}

///|
pub fn app_state_next_waker_instant_ms() -> Int64? {
  app_state_runtime.val.next_waker_instant_ms
}

///|
pub fn app_state_queue_proxy_wake_up() -> Unit {
  app_state_runtime.val.queued_proxy_wake_up = true
}

///|
pub fn app_state_take_proxy_wake_up() -> Bool {
  let queued = app_state_runtime.val.queued_proxy_wake_up
  app_state_runtime.val.queued_proxy_wake_up = false
  queued
}

///|
pub fn min_timeout_ms(a : Int64?, b : Int64?) -> Int64? {
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
pub fn app_state_control_flow_timeout_ms() -> Int64? {
  match app_state_runtime.val.control_flow {
    @core.ControlFlow::Wait => None
    @core.ControlFlow::Poll => Some(runtime_now_ms())
    @core.ControlFlow::WaitUntil(requested_resume_ms) =>
      Some(requested_resume_ms)
  }
}

///|
pub fn app_state_effective_wait_timeout_ms() -> Int64? {
  min_timeout_ms(
    app_state_runtime.val.wait_timeout_ms,
    app_state_control_flow_timeout_ms(),
  )
}

///|
pub fn app_state_prepare_wait_cycle(start_time_ms : Int64) -> Unit {
  app_state_runtime.val.start_time_ms = Some(start_time_ms)
  app_state_runtime.val.next_waker_instant_ms = app_state_effective_wait_timeout_ms()
}

///|
pub fn app_state_internal_exit() -> Unit {
  app_state_runtime.val.is_running = false
  app_state_runtime.val.event_handler_in_use = false
  app_state_runtime.val.queued_proxy_wake_up = false
  app_state_runtime.val.stop_on_redraw = false
  app_state_runtime.val.stop_before_wait = false
  app_state_runtime.val.stop_after_wait = false
  app_state_runtime.val.wait_timeout_ms = None
  app_state_runtime.val.start_time_ms = None
  app_state_runtime.val.next_waker_instant_ms = None
  app_state_runtime.val.pending_redraw_window_ids = []
  app_state_runtime.val.pending_close_window_ids = []
  app_state_runtime.val.pending_destroyed_window_ids = []
}

///|
pub fn[A : ApplicationHandler] app_state_dispatch_init_events(
  app : A,
  event_loop : ActiveEventLoop,
) -> Unit {
  app.new_events(event_loop, @core.StartCause::Init)
  app.can_create_surfaces(event_loop)
}

///|
pub fn[A : ApplicationHandler] app_state_dispatch_about_to_wait(
  app : A,
  event_loop : ActiveEventLoop,
) -> Bool {
  app.about_to_wait(event_loop)
  app_state_exiting()
}

///|
pub fn[A : ApplicationHandler] app_state_handle_redraw(
  app : A,
  event_loop : ActiveEventLoop,
  window_id : @core.WindowId,
) -> Bool {
  app.window_event(event_loop, window_id, @core.WindowEvent::RedrawRequested)
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
}

///|
pub fn app_state_has_pending_redraws() -> Bool {
  app_state_runtime.val.pending_redraw_window_ids.is_empty() == false
}

///|
pub fn app_state_take_all_redraws() -> Array[Int] {
  let redraws = app_state_runtime.val.pending_redraw_window_ids
  app_state_runtime.val.pending_redraw_window_ids = []
  redraws
}

///|
fn app_state_take_redraw(window_id : Int) -> Bool {
  app_state_take_window_id(
    app_state_runtime.val.pending_redraw_window_ids,
    window_id,
  )
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
pub fn app_state_queue_close_window(window_id : Int) -> Unit {
  app_state_queue_unique_window_id(
    app_state_runtime.val.pending_close_window_ids,
    window_id,
  )
}

///|
pub fn app_state_take_close_window(window_id : Int) -> Bool {
  app_state_take_window_id(
    app_state_runtime.val.pending_close_window_ids,
    window_id,
  )
}

///|
pub fn app_state_take_all_close_windows() -> Array[Int] {
  let close_ids = app_state_runtime.val.pending_close_window_ids
  app_state_runtime.val.pending_close_window_ids = []
  close_ids
}

///|
pub fn app_state_queue_destroyed_window(window_id : Int) -> Unit {
  app_state_queue_unique_window_id(
    app_state_runtime.val.pending_destroyed_window_ids,
    window_id,
  )
}

///|
pub fn app_state_take_destroyed_window(window_id : Int) -> Bool {
  app_state_take_window_id(
    app_state_runtime.val.pending_destroyed_window_ids,
    window_id,
  )
}

///|
pub fn app_state_take_all_destroyed_windows() -> Array[Int] {
  let destroyed_ids = app_state_runtime.val.pending_destroyed_window_ids
  app_state_runtime.val.pending_destroyed_window_ids = []
  destroyed_ids
}
