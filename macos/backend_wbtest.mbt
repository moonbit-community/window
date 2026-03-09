///|
test "macos backend is available on native" {
  assert_true(backend_available())
  let event_loop = EventLoop::new()
  assert_eq(event_loop.control_flow(), @core.ControlFlow::Wait)
}

///|
extern "C" fn runtime_now_set_for_test(ms : Int64) -> Unit = "mbw_runtime_now_ms_set_for_test"

///|
extern "C" fn runtime_now_clear_for_test() -> Unit = "mbw_runtime_now_ms_clear_for_test"

///|
extern "C" fn queue_focus_for_test(window_id : Int, focused : Bool) -> Unit = "mbw_test_window_queue_focused"

///|
extern "C" fn queue_moved_for_test(window_id : Int, x : Int, y : Int) -> Unit = "mbw_test_window_queue_moved"

///|
extern "C" fn queue_scale_factor_changed_for_test(
  window_id : Int,
  scale_factor : Double,
  width : Int,
  height : Int,
) -> Unit = "mbw_test_window_queue_scale_factor_changed"

///|
extern "C" fn queue_theme_changed_for_test(
  window_id : Int,
  theme_kind : Int,
) -> Unit = "mbw_test_window_queue_theme_changed"

///|
extern "C" fn queue_occluded_for_test(window_id : Int, occluded : Bool) -> Unit = "mbw_test_window_queue_occluded"

///|
extern "C" fn queue_pointer_moved_for_test(
  window_id : Int,
  x : Double,
  y : Double,
) -> Unit = "mbw_test_window_queue_pointer_moved"

///|
extern "C" fn queue_pointer_entered_for_test(
  window_id : Int,
  x : Double,
  y : Double,
) -> Unit = "mbw_test_window_queue_pointer_entered"

///|
extern "C" fn queue_pointer_left_for_test(
  window_id : Int,
  x : Double,
  y : Double,
) -> Unit = "mbw_test_window_queue_pointer_left"

///|
extern "C" fn queue_pointer_button_for_test(
  window_id : Int,
  state : Int,
  x : Double,
  y : Double,
  button : Int,
) -> Unit = "mbw_test_window_queue_pointer_button"

///|
extern "C" fn queue_mouse_wheel_for_test(
  window_id : Int,
  delta_kind : Int,
  delta_x : Double,
  delta_y : Double,
  phase : Int,
) -> Unit = "mbw_test_window_queue_mouse_wheel"

///|
struct StartCauseApp {
  causes : Array[@core.StartCause]
}

///|
impl ApplicationHandler for StartCauseApp with new_events(
  self,
  event_loop,
  cause,
) {
  self.causes.push(cause)
  if self.causes.length() >= 2 {
    event_loop.exit()
  }
}

///|
impl ApplicationHandler for StartCauseApp with can_create_surfaces(
  _self,
  event_loop,
) {
  runtime_now_set_for_test(100L)
  let attrs = @core.WindowAttributes::default().with_visible(false)
  let _ = event_loop.create_window(attrs)
  event_loop.set_control_flow(@core.ControlFlow::WaitUntil(5))
}

///|
struct WaitCancelledApp {
  causes : Array[@core.StartCause]
  wake_requested : Ref[Bool]
  control_flow : @core.ControlFlow
}

///|
impl ApplicationHandler for WaitCancelledApp with new_events(
  self,
  event_loop,
  cause,
) {
  self.causes.push(cause)
  if self.causes.length() >= 2 {
    event_loop.exit()
  }
}

///|
impl ApplicationHandler for WaitCancelledApp with can_create_surfaces(
  self,
  event_loop,
) {
  runtime_now_set_for_test(200L)
  let attrs = @core.WindowAttributes::default().with_visible(false)
  let _ = event_loop.create_window(attrs)
  event_loop.set_control_flow(self.control_flow)
}

///|
impl ApplicationHandler for WaitCancelledApp with about_to_wait(
  self,
  event_loop,
) {
  if self.wake_requested.val == false {
    self.wake_requested.val = true
    let proxy = event_loop.create_proxy()
    proxy.wake_up()
  }
}

///|
struct ProxyWakeApp {
  wake_seen : Ref[Bool]
}

///|
struct FocusApp {
  focused_values : Array[Bool]
}

///|
struct MovedApp {
  moved : Ref[@dpi.PhysicalPosition?]
}

///|
struct PointerMovedApp {
  moved : Ref[@dpi.PhysicalPositionF64?]
}

///|
struct PointerBoundaryApp {
  entered : Ref[@dpi.PhysicalPositionF64?]
  left : Ref[@dpi.PhysicalPositionF64?]
}

///|
struct PointerButtonApp {
  state : Ref[@core.ElementState?]
  position : Ref[@dpi.PhysicalPositionF64?]
  button : Ref[@core.ButtonSource?]
}

///|
struct MouseWheelApp {
  delta : Ref[@core.MouseScrollDelta?]
  phase : Ref[@core.TouchPhase?]
}

///|
impl ApplicationHandler for FocusApp with can_create_surfaces(_self, event_loop) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_focus_for_test(window.id().into_raw(), true)
}

///|
impl ApplicationHandler for FocusApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::Focused(focused) => {
      self.focused_values.push(focused)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for MovedApp with can_create_surfaces(_self, event_loop) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_moved_for_test(window.id().into_raw(), 320, 180)
}

///|
impl ApplicationHandler for MovedApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::Moved(position) => {
      self.moved.val = Some(position)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for PointerMovedApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_pointer_moved_for_test(window.id().into_raw(), 24.5, 48.25)
}

///|
impl ApplicationHandler for PointerMovedApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::PointerMoved(position, true, @core.PointerSource::Mouse) => {
      self.moved.val = Some(position)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for PointerBoundaryApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_pointer_entered_for_test(window.id().into_raw(), 16.0, 32.0)
  queue_pointer_left_for_test(window.id().into_raw(), 64.0, 96.0)
}

///|
impl ApplicationHandler for PointerBoundaryApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::PointerEntered(position, true, @core.PointerKind::Mouse) =>
      self.entered.val = Some(position)
    @core.WindowEvent::PointerLeft(
      Some(position),
      true,
      @core.PointerKind::Mouse
    ) => {
      self.left.val = Some(position)
      if self.entered.val is Some(_) {
        event_loop.exit()
      }
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for PointerButtonApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_pointer_button_for_test(window.id().into_raw(), 1, 120.0, 45.5, 1)
}

///|
impl ApplicationHandler for PointerButtonApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::PointerButton(state, position, true, button) => {
      self.state.val = Some(state)
      self.position.val = Some(position)
      self.button.val = Some(button)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for MouseWheelApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_mouse_wheel_for_test(window.id().into_raw(), 2, 12.5, -24.0, 2)
}

///|
impl ApplicationHandler for MouseWheelApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::MouseWheel(delta, phase) => {
      self.delta.val = Some(delta)
      self.phase.val = Some(phase)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
struct ScaleFactorApp {
  seen_scale_factor : Ref[Double?]
  resized : Ref[@dpi.PhysicalSize?]
}

///|
impl ApplicationHandler for ScaleFactorApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_scale_factor_changed_for_test(window.id().into_raw(), 2.0, 1600, 1200)
}

///|
impl ApplicationHandler for ScaleFactorApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::ScaleFactorChanged(scale_factor, writer) => {
      self.seen_scale_factor.val = Some(scale_factor)
      writer.request_surface_size(@dpi.PhysicalSize::new(1200, 900))
    }
    @core.WindowEvent::SurfaceResized(size) => {
      self.resized.val = Some(size)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
struct ThemeApp {
  window : Ref[Window?]
  event_theme : Ref[@core.Theme?]
  current_theme : Ref[@core.Theme?]
}

///|
impl ApplicationHandler for ThemeApp with can_create_surfaces(self, event_loop) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  self.window.val = Some(window)
  queue_theme_changed_for_test(window.id().into_raw(), 2)
}

///|
impl ApplicationHandler for ThemeApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::ThemeChanged(theme) => {
      self.event_theme.val = Some(theme)
      match self.window.val {
        Some(window) => self.current_theme.val = window.theme()
        None => ()
      }
      event_loop.exit()
    }
    _ => ()
  }
}

///|
struct OccludedApp {
  occluded : Ref[Bool?]
}

///|
impl ApplicationHandler for OccludedApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_occluded_for_test(window.id().into_raw(), true)
}

///|
impl ApplicationHandler for OccludedApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::Occluded(occluded) => {
      self.occluded.val = Some(occluded)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
struct DestroyedOnExitApp {
  destroyed_seen : Ref[Bool]
}

///|
impl ApplicationHandler for DestroyedOnExitApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let _ = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  event_loop.exit()
}

///|
impl ApplicationHandler for DestroyedOnExitApp with window_event(
  self,
  _event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::Destroyed => self.destroyed_seen.val = true
    _ => ()
  }
}

///|
impl ApplicationHandler for ProxyWakeApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let proxy = event_loop.create_proxy()
  proxy.wake_up()
}

///|
impl ApplicationHandler for ProxyWakeApp with proxy_wake_up(self, event_loop) {
  self.wake_seen.val = true
  event_loop.exit()
}

///|
test "event loop proxy wake up is delivered" {
  let wake_seen = Ref::new(false)
  let event_loop = EventLoop::new()
  event_loop.run_app({ wake_seen, })
  assert_true(wake_seen.val)
}

///|
test "new events reports init then wait-until timeout" {
  let event_loop = EventLoop::new()
  let app = { causes: [] }
  event_loop.run_app(app)
  runtime_now_clear_for_test()
  assert_eq(app.causes[0], @core.StartCause::Init)
  guard app.causes[1]
    is @core.StartCause::ResumeTimeReached(start_ms, requested_resume_ms) else {
    fail("expected ResumeTimeReached")
  }
  assert_eq(start_ms, 100L)
  assert_eq(requested_resume_ms, 105L)
}

///|
test "new events reports wait-until cancellation when proxy wakes" {
  let event_loop = EventLoop::new()
  let app = {
    causes: [],
    wake_requested: Ref::new(false),
    control_flow: @core.ControlFlow::WaitUntil(20),
  }
  event_loop.run_app(app)
  runtime_now_clear_for_test()
  assert_eq(app.causes[0], @core.StartCause::Init)
  guard app.causes[1]
    is @core.StartCause::WaitCancelled(start_ms, Some(requested_resume_ms)) else {
    fail("expected WaitCancelled with a requested resume time")
  }
  assert_eq(start_ms, 200L)
  assert_eq(requested_resume_ms, 220L)
}

///|
test "wait blocks on native wake source until proxy wake arrives" {
  let event_loop = EventLoop::new()
  let app = {
    causes: [],
    wake_requested: Ref::new(false),
    control_flow: @core.ControlFlow::Wait,
  }
  event_loop.run_app(app)
  runtime_now_clear_for_test()
  assert_eq(app.causes[0], @core.StartCause::Init)
  guard app.causes[1] is @core.StartCause::WaitCancelled(start_ms, None) else {
    fail("expected WaitCancelled without a timeout")
  }
  assert_eq(start_ms, 200L)
}

///|
test "focused events are delivered" {
  let event_loop = EventLoop::new()
  let app = { focused_values: [] }
  event_loop.run_app(app)
  assert_eq(app.focused_values, [true])
}

///|
test "moved events are delivered" {
  let event_loop = EventLoop::new()
  let moved = Ref::new(None)
  let app : MovedApp = { moved, }
  event_loop.run_app(app)
  assert_eq(moved.val, Some(@dpi.PhysicalPosition::new(320, 180)))
}

///|
test "pointer moved events are delivered" {
  let event_loop = EventLoop::new()
  let moved = Ref::new(None)
  let app : PointerMovedApp = { moved, }
  event_loop.run_app(app)
  assert_eq(moved.val, Some(@dpi.PhysicalPositionF64::new(24.5, 48.25)))
}

///|
test "pointer entered and left events are delivered" {
  let event_loop = EventLoop::new()
  let entered = Ref::new(None)
  let left = Ref::new(None)
  event_loop.run_app({ entered, left })
  assert_eq(entered.val, Some(@dpi.PhysicalPositionF64::new(16.0, 32.0)))
  assert_eq(left.val, Some(@dpi.PhysicalPositionF64::new(64.0, 96.0)))
}

///|
test "pointer button events report state position and button" {
  let event_loop = EventLoop::new()
  let state = Ref::new(None)
  let position = Ref::new(None)
  let button = Ref::new(None)
  event_loop.run_app({ state, position, button })
  assert_eq(state.val, Some(@core.ElementState::Pressed))
  assert_eq(position.val, Some(@dpi.PhysicalPositionF64::new(120.0, 45.5)))
  assert_eq(
    button.val,
    Some(@core.ButtonSource::Mouse(@core.MouseButton::Right)),
  )
}

///|
test "mouse wheel events deliver pixel deltas and phase" {
  let event_loop = EventLoop::new()
  let delta = Ref::new(None)
  let phase = Ref::new(None)
  event_loop.run_app({ delta, phase })
  assert_eq(
    delta.val,
    Some(
      @core.MouseScrollDelta::PixelDelta(
        @dpi.PhysicalPositionF64::new(12.5, -24.0),
      ),
    ),
  )
  assert_eq(phase.val, Some(@core.TouchPhase::Moved))
}

///|
test "scale factor changes can request a replacement surface size" {
  let event_loop = EventLoop::new()
  let seen_scale_factor = Ref::new(None)
  let resized = Ref::new(None)
  event_loop.run_app({ seen_scale_factor, resized })
  assert_eq(seen_scale_factor.val, Some(2.0))
  assert_eq(resized.val, Some(@dpi.PhysicalSize::new(1200, 900)))
}

///|
test "theme changed events update the readable window theme" {
  let event_loop = EventLoop::new()
  let window = Ref::new(None)
  let event_theme = Ref::new(None)
  let current_theme = Ref::new(None)
  event_loop.run_app({ window, event_theme, current_theme })
  assert_eq(event_theme.val, Some(@core.Theme::Dark))
  assert_eq(current_theme.val, Some(@core.Theme::Dark))
}

///|
test "occluded events are delivered" {
  let event_loop = EventLoop::new()
  let occluded = Ref::new(None)
  event_loop.run_app({ occluded, })
  assert_eq(occluded.val, Some(true))
}

///|
test "destroyed is delivered when the event loop exits" {
  let event_loop = EventLoop::new()
  let destroyed_seen = Ref::new(false)
  event_loop.run_app({ destroyed_seen, })
  assert_true(destroyed_seen.val)
}
