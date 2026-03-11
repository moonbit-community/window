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
struct RunGuardApp {
  _unit : Unit
}

///|
impl ApplicationHandler for RunGuardApp with can_create_surfaces(
  _self,
  event_loop,
) {
  event_loop.exit()
}

///|
test "try run app raises recreation attempt when backend is already running" {
  set_event_loop_running(true)
  let event_loop = EventLoop::new()
  let app : RunGuardApp = { _unit: () }
  let recreation_attempt = try {
    event_loop.try_run_app(app)
    false
  } catch {
    @core.EventLoopError::RecreationAttempt => true
    _ => false
  }
  set_event_loop_running(false)
  assert_true(recreation_attempt)
}

///|
test "try run app on demand raises recreation attempt when backend is already running" {
  set_event_loop_running(true)
  let event_loop = EventLoop::new()
  let app : RunGuardApp = { _unit: () }
  let recreation_attempt = try {
    event_loop.try_run_app_on_demand(app)
    false
  } catch {
    @core.EventLoopError::RecreationAttempt => true
    _ => false
  }
  set_event_loop_running(false)
  assert_true(recreation_attempt)
}

///|
test "try pump app events raises recreation attempt when backend is already running" {
  set_event_loop_running(true)
  let event_loop = EventLoop::new()
  let app : RunGuardApp = { _unit: () }
  let recreation_attempt = try {
    let _ = event_loop.try_pump_app_events(Some(0), app)
    false
  } catch {
    @core.EventLoopError::RecreationAttempt => true
    _ => false
  }
  set_event_loop_running(false)
  assert_true(recreation_attempt)
}

///|
extern "C" fn queue_close_requested_for_test(window_id : Int) -> Unit = "mbw_test_window_queue_close_requested"

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
#borrow(path)
extern "C" fn queue_drag_entered_for_test(
  window_id : Int,
  path : Bytes,
  path_len : Int,
  x : Double,
  y : Double,
) -> Unit = "mbw_test_window_queue_drag_entered"

///|
extern "C" fn queue_drag_moved_for_test(
  window_id : Int,
  x : Double,
  y : Double,
) -> Unit = "mbw_test_window_queue_drag_moved"

///|
#borrow(path)
extern "C" fn queue_drag_dropped_for_test(
  window_id : Int,
  path : Bytes,
  path_len : Int,
  x : Double,
  y : Double,
) -> Unit = "mbw_test_window_queue_drag_dropped"

///|
extern "C" fn queue_drag_left_for_test(
  window_id : Int,
  has_position : Bool,
  x : Double,
  y : Double,
) -> Unit = "mbw_test_window_queue_drag_left"

///|
extern "C" fn queue_pinch_gesture_for_test(
  window_id : Int,
  delta : Double,
  phase : Int,
) -> Unit = "mbw_test_window_queue_pinch_gesture"

///|
extern "C" fn queue_pan_gesture_for_test(
  window_id : Int,
  delta_x : Double,
  delta_y : Double,
  phase : Int,
) -> Unit = "mbw_test_window_queue_pan_gesture"

///|
extern "C" fn queue_double_tap_gesture_for_test(window_id : Int) -> Unit = "mbw_test_window_queue_double_tap_gesture"

///|
extern "C" fn queue_rotation_gesture_for_test(
  window_id : Int,
  delta : Double,
  phase : Int,
) -> Unit = "mbw_test_window_queue_rotation_gesture"

///|
extern "C" fn queue_touchpad_pressure_for_test(
  window_id : Int,
  pressure : Double,
  stage : Int,
) -> Unit = "mbw_test_window_queue_touchpad_pressure"

///|
extern "C" fn queue_modifiers_changed_for_test(
  window_id : Int,
  modifiers : Int,
) -> Unit = "mbw_test_window_queue_modifiers_changed"

///|
extern "C" fn queue_keyboard_input_for_test(
  window_id : Int,
  scancode : Int,
  state : Int,
  repeat : Bool,
  modifiers : Int,
) -> Unit = "mbw_test_window_queue_keyboard_input"

///|
#borrow(text_with_all_modifiers, text_ignoring_modifiers)
extern "C" fn queue_keyboard_input_with_text_for_test(
  window_id : Int,
  scancode : Int,
  state : Int,
  repeat : Bool,
  modifiers : Int,
  text_with_all_modifiers : Bytes,
  text_with_all_modifiers_len : Int,
  text_ignoring_modifiers : Bytes,
  text_ignoring_modifiers_len : Int,
) -> Unit = "mbw_test_window_queue_keyboard_input_with_text"

///|
extern "C" fn queue_ime_disabled_for_test(window_id : Int) -> Unit = "mbw_test_window_queue_ime_disabled"

///|
#borrow(text)
extern "C" fn queue_ime_preedit_for_test(
  window_id : Int,
  text : Bytes,
  text_len : Int,
  cursor_start : Int,
  cursor_end : Int,
) -> Unit = "mbw_test_window_queue_ime_preedit"

///|
#borrow(text)
extern "C" fn queue_ime_commit_for_test(
  window_id : Int,
  text : Bytes,
  text_len : Int,
) -> Unit = "mbw_test_window_queue_ime_commit"

///|
extern "C" fn queue_ime_delete_surrounding_for_test(
  window_id : Int,
  before_bytes : Int,
  after_bytes : Int,
) -> Unit = "mbw_test_window_queue_ime_delete_surrounding"

///|
extern "C" fn icon_present_for_test(window_id : Int) -> Bool = "mbw_test_window_has_icon"

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
  event_loop.set_control_flow(@core.ControlFlow::WaitUntil(105L))
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
struct ProxyWakeWithoutWindowApp {
  about_to_wait_count : Ref[Int]
  wake_requested : Ref[Bool]
  wake_seen : Ref[Bool]
}

///|
struct FocusApp {
  focused_values : Array[Bool]
}

///|
struct FocusWindowApp {
  has_focus : Ref[Bool?]
  window : Ref[Window?]
}

///|
struct HiddenFocusWindowApp {
  focused_event : Ref[Bool?]
  has_focus : Ref[Bool?]
  window : Ref[Window?]
}

///|
struct MinimizedFocusWindowApp {
  focused_event : Ref[Bool?]
  has_focus : Ref[Bool?]
  window : Ref[Window?]
}

///|
struct InactiveWindowApp {
  has_focus : Ref[Bool?]
  window : Ref[Window?]
}

///|
struct WindowMinMaxStateApp {
  maximized_after_disable : Ref[Bool]
  maximized_after_enable : Ref[Bool]
  minimized_after_disable : Ref[Bool?]
  minimized_after_enable : Ref[Bool?]
}

///|
struct WindowFullscreenStateApp {
  fullscreen_after_disable : Ref[@core.Fullscreen?]
  fullscreen_after_enable : Ref[@core.Fullscreen?]
  fullscreen_initial : Ref[@core.Fullscreen?]
}

///|
struct WindowFullscreenRoundtripApp {
  borderless_targeted : Ref[@core.Fullscreen?]
  exclusive : Ref[@core.Fullscreen?]
  has_monitor : Ref[Bool]
}

///|
struct WindowDecorationsApp {
  decorated_after_disable : Ref[Bool]
  decorated_after_enable : Ref[Bool]
  decorated_initial : Ref[Bool]
}

///|
struct WindowLevelApp {
  level_after_update : Ref[@core.WindowLevel?]
  level_initial : Ref[@core.WindowLevel?]
}

///|
struct AttributesMaximizedApp {
  maximized : Ref[Bool]
}

///|
struct WindowTransparentApp {
  transparent_after_disable : Ref[Bool]
  transparent_after_enable : Ref[Bool]
  transparent_initial : Ref[Bool]
}

///|
struct WindowBlurApp {
  blur_after_disable : Ref[Bool]
  blur_after_enable : Ref[Bool]
  blur_initial : Ref[Bool]
}

///|
struct WindowCursorApp {
  cursor_after_first_update : Ref[@core.Cursor?]
  cursor_after_second_update : Ref[@core.Cursor?]
  cursor_initial : Ref[@core.Cursor?]
  hittest_after_disable : Ref[Bool]
  hittest_after_enable : Ref[Bool]
  hittest_initial : Ref[Bool]
  visible_after_disable : Ref[Bool]
  visible_after_enable : Ref[Bool]
  visible_initial : Ref[Bool]
}

///|
struct WindowIconApp {
  icon_after_clear : Ref[Bool]
  icon_after_restore : Ref[Bool]
  icon_initial : Ref[Bool]
}

///|
struct WindowVisibilityResizableApp {
  resizable_after_disable : Ref[Bool]
  resizable_after_enable : Ref[Bool]
  resizable_initial : Ref[Bool]
  visible_after_disable : Ref[Bool?]
  visible_after_enable : Ref[Bool?]
  visible_initial : Ref[Bool?]
}

///|
struct WindowContentProtectedApp {
  protected_after_disable : Ref[Bool]
  protected_after_enable : Ref[Bool]
  protected_initial : Ref[Bool]
}

///|
struct WindowEnabledButtonsApp {
  close_after_enable : Ref[Bool]
  close_initial : Ref[Bool]
  maximize_after_enable : Ref[Bool]
  maximize_initial : Ref[Bool]
  minimize_after_enable : Ref[Bool]
  minimize_initial : Ref[Bool]
}

///|
struct SurfaceResizeIncrementsApp {
  increments_after_disable : Ref[@dpi.PhysicalSize?]
  increments_after_enable : Ref[@dpi.PhysicalSize?]
  increments_initial : Ref[@dpi.PhysicalSize?]
}

///|
struct MovedApp {
  moved : Ref[@dpi.PhysicalPosition?]
}

///|
struct RedrawRequestApp {
  redraw_requested : Ref[Bool]
}

///|
struct OuterPositionApp {
  moved : Ref[@dpi.PhysicalPosition?]
  outer_position : Ref[@dpi.PhysicalPosition?]
  window : Ref[Window?]
}

///|
struct OuterSizeApp {
  outer_size : Ref[@dpi.PhysicalSize?]
  surface_position : Ref[@dpi.PhysicalPosition?]
  surface_size : Ref[@dpi.PhysicalSize?]
}

///|
struct AttributesPositionApp {
  moved : Ref[@dpi.PhysicalPosition?]
  outer_position : Ref[@dpi.PhysicalPosition?]
  window : Ref[Window?]
}

///|
struct RequestSurfaceSizeApp {
  request_result : Ref[@dpi.PhysicalSize?]
  resized : Ref[@dpi.PhysicalSize?]
  surface_size : Ref[@dpi.PhysicalSize?]
  window : Ref[Window?]
}

///|
struct MinSurfaceSizeApp {
  min_surface_size : Ref[@dpi.PhysicalSize?]
  resized : Ref[@dpi.PhysicalSize?]
  surface_size : Ref[@dpi.PhysicalSize?]
  window : Ref[Window?]
}

///|
struct MaxSurfaceSizeApp {
  max_surface_size : Ref[@dpi.PhysicalSize?]
  resized : Ref[@dpi.PhysicalSize?]
  surface_size : Ref[@dpi.PhysicalSize?]
  window : Ref[Window?]
}

///|
struct AttributesSurfaceConstraintsApp {
  resized : Ref[@dpi.PhysicalSize?]
  surface_size : Ref[@dpi.PhysicalSize?]
  window : Ref[Window?]
}

///|
struct PointerMovedApp {
  moved : Ref[@dpi.PhysicalPositionF64?]
}

///|
struct DragEventsApp {
  dropped_paths : Ref[Array[String]?]
  dropped_position : Ref[@dpi.PhysicalPositionF64?]
  entered_paths : Ref[Array[String]?]
  entered_position : Ref[@dpi.PhysicalPositionF64?]
  left_position : Ref[@dpi.PhysicalPositionF64?]
  moved_position : Ref[@dpi.PhysicalPositionF64?]
}

///|
struct DragLeftWithoutPositionApp {
  left_position : Ref[@dpi.PhysicalPositionF64?]
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
struct GestureEventsApp {
  double_tap_seen : Ref[Bool]
  pan_delta : Ref[@dpi.PhysicalPositionF64?]
  pan_phase : Ref[@core.TouchPhase?]
  pinch_delta : Ref[Double?]
  pinch_phase : Ref[@core.TouchPhase?]
  pressure : Ref[Double?]
  pressure_stage : Ref[Int?]
  rotation_delta : Ref[Double?]
  rotation_phase : Ref[@core.TouchPhase?]
}

///|
struct ModifiersApp {
  modifiers : Ref[@core.Modifiers?]
}

///|
struct ResetModifiersApp {
  modifiers_events : Array[@core.Modifiers]
}

///|
struct KeyboardInputApp {
  captured : Ref[@core.KeyEvent?]
  modifiers : Int
  repeat : Bool
  scancode : Int
  state : Int
  text_with_all_modifiers : String?
  text_ignoring_modifiers : String?
}

///|
struct ImeApp {
  events : Array[@core.Ime]
  scenario : Int
}

///|
struct ImeConfigurationApp {
  cursor_when_disabled_error : Ref[@core.ImeRequestError?]
  enable_when_enabled_error : Ref[@core.ImeRequestError?]
  cursor_position : Ref[@dpi.PhysicalPosition?]
  cursor_size : Ref[@dpi.PhysicalSize?]
  ime_capabilities : Ref[@core.ImeCapabilities?]
  ime_allowed : Ref[Bool]
  initial_hints : Ref[@core.ImeHint]
  initial_purpose : Ref[@core.ImePurpose]
  request_allowed_ok : Ref[Bool]
  request_cursor_ok : Ref[Bool]
  request_hint_and_purpose_ok : Ref[Bool]
  request_purpose_ok : Ref[Bool]
  request_surrounding_ok : Ref[Bool]
  surrounding_text_after_clear : Ref[@core.ImeSurroundingText?]
  surrounding_text_after_request : Ref[@core.ImeSurroundingText?]
  updated_hints : Ref[@core.ImeHint]
  updated_purpose : Ref[@core.ImePurpose]
}

///|
struct ImeCapabilityRestrictionApp {
  cursor_not_supported : Ref[Bool]
  hint_and_purpose_not_supported : Ref[Bool]
  purpose_not_supported : Ref[Bool]
  surrounding_not_supported : Ref[Bool]
}

///|
struct WindowAuxiliaryApiApp {
  cursor_grab_confined : Ref[Bool]
  drag_resize_started : Ref[Bool]
  drag_window_started : Ref[Bool]
  safe_area : Ref[@dpi.PhysicalInsets?]
  title_after_update : Ref[String?]
  title_initial : Ref[String?]
}

///|
struct MonitorApiApp {
  available_monitor_count : Ref[Int]
  current_monitor : Ref[@core.MonitorHandle?]
  primary_monitor_from_event_loop : Ref[@core.MonitorHandle?]
  primary_monitor_from_window : Ref[@core.MonitorHandle?]
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
impl ApplicationHandler for FocusWindowApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(@core.WindowAttributes::default())
  self.window.val = Some(window)
  window.focus_window()
}

///|
impl ApplicationHandler for FocusWindowApp with window_event(
  _self,
  _event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::Focused(_focused) => ()
    _ => ()
  }
}

///|
impl ApplicationHandler for FocusWindowApp with about_to_wait(self, event_loop) {
  match self.window.val {
    Some(window) => self.has_focus.val = Some(window.has_focus())
    None => ()
  }
  event_loop.exit()
}

///|
impl ApplicationHandler for HiddenFocusWindowApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_active(false).with_visible(false),
  )
  self.window.val = Some(window)
  window.focus_window()
}

///|
impl ApplicationHandler for HiddenFocusWindowApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::Focused(focused) => {
      self.focused_event.val = Some(focused)
      match self.window.val {
        Some(window) => self.has_focus.val = Some(window.has_focus())
        None => ()
      }
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for HiddenFocusWindowApp with about_to_wait(
  self,
  event_loop,
) {
  match self.window.val {
    Some(window) => self.has_focus.val = Some(window.has_focus())
    None => ()
  }
  event_loop.exit()
}

///|
impl ApplicationHandler for MinimizedFocusWindowApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_active(false),
  )
  window.set_minimized(true)
  self.window.val = Some(window)
  window.focus_window()
}

///|
impl ApplicationHandler for MinimizedFocusWindowApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::Focused(focused) => {
      self.focused_event.val = Some(focused)
      match self.window.val {
        Some(window) => self.has_focus.val = Some(window.has_focus())
        None => ()
      }
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for MinimizedFocusWindowApp with about_to_wait(
  self,
  event_loop,
) {
  match self.window.val {
    Some(window) => self.has_focus.val = Some(window.has_focus())
    None => ()
  }
  event_loop.exit()
}

///|
impl ApplicationHandler for InactiveWindowApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_active(false),
  )
  self.window.val = Some(window)
}

///|
impl ApplicationHandler for InactiveWindowApp with about_to_wait(
  self,
  event_loop,
) {
  match self.window.val {
    Some(window) => self.has_focus.val = Some(window.has_focus())
    None => ()
  }
  event_loop.exit()
}

///|
impl ApplicationHandler for WindowMinMaxStateApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  window.set_minimized(true)
  self.minimized_after_enable.val = window.is_minimized()
  window.set_minimized(false)
  self.minimized_after_disable.val = window.is_minimized()
  window.set_maximized(true)
  self.maximized_after_enable.val = window.is_maximized()
  window.set_maximized(false)
  self.maximized_after_disable.val = window.is_maximized()
  event_loop.exit()
}

///|
impl ApplicationHandler for WindowFullscreenStateApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_fullscreen(Some(@core.Fullscreen::Borderless(None))),
  )
  self.fullscreen_initial.val = window.fullscreen()
  window.set_fullscreen(None)
  self.fullscreen_after_disable.val = window.fullscreen()
  window.set_fullscreen(Some(@core.Fullscreen::Borderless(None)))
  self.fullscreen_after_enable.val = window.fullscreen()
  event_loop.exit()
}

///|
impl ApplicationHandler for WindowFullscreenRoundtripApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  match window.current_monitor() {
    Some(monitor) => {
      self.has_monitor.val = true
      let mode = match monitor.current_video_mode() {
        Some(mode) => mode
        None => @core.VideoMode::new(monitor.surface_size(), None, None)
      }
      window.set_fullscreen(Some(@core.Fullscreen::Exclusive(monitor, mode)))
      self.exclusive.val = window.fullscreen()
      window.set_fullscreen(Some(@core.Fullscreen::Borderless(Some(monitor))))
      self.borderless_targeted.val = window.fullscreen()
      window.set_fullscreen(None)
    }
    None => {
      self.has_monitor.val = false
      self.exclusive.val = None
      self.borderless_targeted.val = None
    }
  }
  event_loop.exit()
}

///|
impl ApplicationHandler for WindowDecorationsApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_decorations(false),
  )
  self.decorated_initial.val = window.is_decorated()
  window.set_decorations(true)
  self.decorated_after_enable.val = window.is_decorated()
  window.set_decorations(false)
  self.decorated_after_disable.val = window.is_decorated()
  event_loop.exit()
}

///|
impl ApplicationHandler for WindowLevelApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_window_level(@core.WindowLevel::AlwaysOnTop),
  )
  self.level_initial.val = Some(window.window_level())
  window.set_window_level(@core.WindowLevel::AlwaysOnBottom)
  self.level_after_update.val = Some(window.window_level())
  event_loop.exit()
}

///|
impl ApplicationHandler for AttributesMaximizedApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false).with_maximized(true),
  )
  self.maximized.val = window.is_maximized()
  event_loop.exit()
}

///|
impl ApplicationHandler for WindowTransparentApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false).with_transparent(true),
  )
  self.transparent_initial.val = window.is_transparent()
  window.set_transparent(false)
  self.transparent_after_disable.val = window.is_transparent()
  window.set_transparent(true)
  self.transparent_after_enable.val = window.is_transparent()
  event_loop.exit()
}

///|
impl ApplicationHandler for WindowBlurApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false).with_blur(true),
  )
  self.blur_initial.val = window.is_blurred()
  window.set_blur(false)
  self.blur_after_disable.val = window.is_blurred()
  window.set_blur(true)
  self.blur_after_enable.val = window.is_blurred()
  event_loop.exit()
}

///|
impl ApplicationHandler for WindowCursorApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_cursor(@core.Cursor::Icon(@core.CursorIcon::NeResize)),
  )
  self.cursor_initial.val = Some(window.cursor())
  self.visible_initial.val = window.is_cursor_visible()
  self.hittest_initial.val = window.is_cursor_hittest()
  window.set_cursor(@core.Cursor::Icon(@core.CursorIcon::ContextMenu))
  self.cursor_after_first_update.val = Some(window.cursor())
  window.set_cursor(@core.Cursor::Icon(@core.CursorIcon::RowResize))
  self.cursor_after_second_update.val = Some(window.cursor())
  window.set_cursor_visible(false)
  self.visible_after_disable.val = window.is_cursor_visible()
  window.set_cursor_visible(true)
  self.visible_after_enable.val = window.is_cursor_visible()
  window.set_cursor_hittest(false) catch {
    _ => ()
  }
  self.hittest_after_disable.val = window.is_cursor_hittest()
  window.set_cursor_hittest(true) catch {
    _ => ()
  }
  self.hittest_after_enable.val = window.is_cursor_hittest()
  event_loop.exit()
}

///|
impl ApplicationHandler for WindowIconApp with can_create_surfaces(
  self,
  event_loop,
) {
  let icon = try! @core.Icon::new(Bytes::make(4, (255 : Int).to_byte()), 1, 1)
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_window_icon(Some(icon)),
  )
  let raw_id = window.id().into_raw()
  self.icon_initial.val = icon_present_for_test(raw_id)
  window.set_window_icon(None)
  self.icon_after_clear.val = icon_present_for_test(raw_id)
  window.set_window_icon(Some(icon))
  self.icon_after_restore.val = icon_present_for_test(raw_id)
  event_loop.exit()
}

///|
impl ApplicationHandler for WindowVisibilityResizableApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  self.visible_initial.val = window.is_visible()
  self.resizable_initial.val = window.is_resizable()
  window.set_visible(true)
  self.visible_after_enable.val = window.is_visible()
  window.set_visible(false)
  self.visible_after_disable.val = window.is_visible()
  window.set_resizable(false)
  self.resizable_after_disable.val = window.is_resizable()
  window.set_resizable(true)
  self.resizable_after_enable.val = window.is_resizable()
  event_loop.exit()
}

///|
impl ApplicationHandler for WindowContentProtectedApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_content_protected(true),
  )
  self.protected_initial.val = window.is_content_protected()
  window.set_content_protected(false)
  self.protected_after_disable.val = window.is_content_protected()
  window.set_content_protected(true)
  self.protected_after_enable.val = window.is_content_protected()
  event_loop.exit()
}

///|
impl ApplicationHandler for WindowEnabledButtonsApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_enabled_buttons(@core.WindowButtons::none().with_minimize(true)),
  )
  let initial = window.enabled_buttons()
  self.close_initial.val = initial.close()
  self.minimize_initial.val = initial.minimize()
  self.maximize_initial.val = initial.maximize()
  window.set_enabled_buttons(@core.WindowButtons::all())
  let updated = window.enabled_buttons()
  self.close_after_enable.val = updated.close()
  self.minimize_after_enable.val = updated.minimize()
  self.maximize_after_enable.val = updated.maximize()
  event_loop.exit()
}

///|
impl ApplicationHandler for SurfaceResizeIncrementsApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_surface_resize_increments(@dpi.PhysicalSize::new(64, 48).into_size()),
  )
  self.increments_initial.val = window.surface_resize_increments()
  window.set_surface_resize_increments(None)
  self.increments_after_disable.val = window.surface_resize_increments()
  window.set_surface_resize_increments(
    Some(@dpi.PhysicalSize::new(32, 24).into_size()),
  )
  self.increments_after_enable.val = window.surface_resize_increments()
  event_loop.exit()
}

///|
impl ApplicationHandler for MovedApp with can_create_surfaces(_self, event_loop) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_moved_for_test(window.id().into_raw(), 320, 180)
}

///|
impl ApplicationHandler for RedrawRequestApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  window.request_redraw()
}

///|
impl ApplicationHandler for RedrawRequestApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::RedrawRequested => {
      self.redraw_requested.val = true
      event_loop.exit()
    }
    _ => ()
  }
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
impl ApplicationHandler for OuterPositionApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  self.window.val = Some(window)
  window.set_outer_position(
    @dpi.PhysicalPosition::new(320, 180).into_position(),
  )
}

///|
impl ApplicationHandler for OuterPositionApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::Moved(position) => {
      self.moved.val = Some(position)
      match self.window.val {
        Some(window) =>
          self.outer_position.val = Some(window.outer_position()) catch {
            _ => None
          }
        None => ()
      }
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for OuterSizeApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_surface_size(@dpi.PhysicalSize::new(640, 480).into_size()),
  )
  self.surface_size.val = Some(window.surface_size())
  self.outer_size.val = Some(window.outer_size())
  self.surface_position.val = Some(window.surface_position())
  event_loop.exit()
}

///|
impl ApplicationHandler for AttributesPositionApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_position(@dpi.PhysicalPosition::new(480, 260).into_position()),
  )
  self.window.val = Some(window)
}

///|
impl ApplicationHandler for AttributesPositionApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::Moved(position) => {
      self.moved.val = Some(position)
      match self.window.val {
        Some(window) =>
          self.outer_position.val = Some(window.outer_position()) catch {
            _ => None
          }
        None => ()
      }
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for RequestSurfaceSizeApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  self.window.val = Some(window)
  self.request_result.val = window.request_surface_size(
    @dpi.PhysicalSize::new(1200, 900).into_size(),
  )
}

///|
impl ApplicationHandler for RequestSurfaceSizeApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::SurfaceResized(size) => {
      self.resized.val = Some(size)
      match self.window.val {
        Some(window) => self.surface_size.val = Some(window.surface_size())
        None => ()
      }
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for MinSurfaceSizeApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  self.window.val = Some(window)
  window.set_min_surface_size(
    Some(@dpi.PhysicalSize::new(960, 720).into_size()),
  )
  self.min_surface_size.val = window.min_surface_size()
  let _ = window.request_surface_size(
    @dpi.PhysicalSize::new(640, 480).into_size(),
  )
}

///|
impl ApplicationHandler for MinSurfaceSizeApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::SurfaceResized(size) => {
      self.resized.val = Some(size)
      match self.window.val {
        Some(window) => self.surface_size.val = Some(window.surface_size())
        None => ()
      }
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for MaxSurfaceSizeApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  self.window.val = Some(window)
  window.set_max_surface_size(
    Some(@dpi.PhysicalSize::new(1024, 768).into_size()),
  )
  self.max_surface_size.val = window.max_surface_size()
  let _ = window.request_surface_size(
    @dpi.PhysicalSize::new(1400, 1050).into_size(),
  )
}

///|
impl ApplicationHandler for MaxSurfaceSizeApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::SurfaceResized(size) => {
      self.resized.val = Some(size)
      match self.window.val {
        Some(window) => self.surface_size.val = Some(window.surface_size())
        None => ()
      }
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for AttributesSurfaceConstraintsApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_surface_size(@dpi.PhysicalSize::new(1600, 1200).into_size())
    .with_max_surface_size(@dpi.PhysicalSize::new(1280, 720).into_size()),
  )
  self.window.val = Some(window)
}

///|
impl ApplicationHandler for AttributesSurfaceConstraintsApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::SurfaceResized(size) => {
      self.resized.val = Some(size)
      match self.window.val {
        Some(window) => self.surface_size.val = Some(window.surface_size())
        None => ()
      }
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
    @core.WindowEvent::PointerMoved(
      Some(_),
      position,
      true,
      @core.PointerSource::Mouse
    ) => {
      self.moved.val = Some(position)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for DragEventsApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let entered_path = @utf8.encode(
    "/tmp/drag-entered-a.txt\n/tmp/drag-entered-b.txt"[:],
    bom=false,
  )
  let dropped_path = @utf8.encode(
    "/tmp/drag-dropped-a.txt\n/tmp/drag-dropped-b.txt"[:],
    bom=false,
  )
  let raw_id = window.id().into_raw()
  queue_drag_entered_for_test(
    raw_id,
    entered_path,
    entered_path.length(),
    12.5,
    24.0,
  )
  queue_drag_moved_for_test(raw_id, 32.0, 48.0)
  queue_drag_dropped_for_test(
    raw_id,
    dropped_path,
    dropped_path.length(),
    64.0,
    96.0,
  )
  queue_drag_left_for_test(raw_id, true, 80.0, 120.0)
}

///|
impl ApplicationHandler for DragEventsApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::DragEntered(paths, position) => {
      self.entered_paths.val = Some(paths)
      self.entered_position.val = Some(position)
    }
    @core.WindowEvent::DragMoved(position) =>
      self.moved_position.val = Some(position)
    @core.WindowEvent::DragDropped(paths, position) => {
      self.dropped_paths.val = Some(paths)
      self.dropped_position.val = Some(position)
    }
    @core.WindowEvent::DragLeft(Some(position)) => {
      self.left_position.val = Some(position)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for DragLeftWithoutPositionApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_drag_left_for_test(window.id().into_raw(), false, 0.0, 0.0)
}

///|
impl ApplicationHandler for DragLeftWithoutPositionApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::DragLeft(position) => {
      self.left_position.val = position
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
    @core.WindowEvent::PointerEntered(
      Some(_),
      position,
      true,
      @core.PointerKind::Mouse
    ) => self.entered.val = Some(position)
    @core.WindowEvent::PointerLeft(
      Some(_),
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
    @core.WindowEvent::PointerButton(Some(_), state, position, true, button) => {
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
    @core.WindowEvent::MouseWheel(Some(_), delta, phase) => {
      self.delta.val = Some(delta)
      self.phase.val = Some(phase)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for GestureEventsApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let raw_id = window.id().into_raw()
  queue_pinch_gesture_for_test(raw_id, 0.75, 1)
  queue_pan_gesture_for_test(raw_id, -18.0, 6.5, 2)
  queue_double_tap_gesture_for_test(raw_id)
  queue_rotation_gesture_for_test(raw_id, 22.5, 3)
  queue_touchpad_pressure_for_test(raw_id, 0.42, 2)
}

///|
impl ApplicationHandler for GestureEventsApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::PinchGesture(Some(_), delta, phase) => {
      self.pinch_delta.val = Some(delta)
      self.pinch_phase.val = Some(phase)
    }
    @core.WindowEvent::PanGesture(Some(_), delta, phase) => {
      self.pan_delta.val = Some(delta)
      self.pan_phase.val = Some(phase)
    }
    @core.WindowEvent::DoubleTapGesture(Some(_)) =>
      self.double_tap_seen.val = true
    @core.WindowEvent::RotationGesture(Some(_), delta, phase) => {
      self.rotation_delta.val = Some(delta)
      self.rotation_phase.val = Some(phase)
    }
    @core.WindowEvent::TouchpadPressure(Some(_), pressure, stage) => {
      self.pressure.val = Some(pressure)
      self.pressure_stage.val = Some(stage)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for ModifiersApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_modifiers_changed_for_test(window.id().into_raw(), 13)
}

///|
impl ApplicationHandler for ModifiersApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::ModifiersChanged(modifiers) => {
      self.modifiers.val = Some(modifiers)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for ResetModifiersApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_modifiers_changed_for_test(window.id().into_raw(), 3)
  queue_focus_for_test(window.id().into_raw(), false)
}

///|
impl ApplicationHandler for ResetModifiersApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::ModifiersChanged(modifiers) => {
      self.modifiers_events.push(modifiers)
      if modifiers.is_empty() {
        event_loop.exit()
      }
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for KeyboardInputApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let text_with_all_modifiers = match self.text_with_all_modifiers {
    Some(text) => @utf8.encode(text[:], bom=false)
    None => Bytes::make(0, (0 : Int).to_byte())
  }
  let text_ignoring_modifiers = match self.text_ignoring_modifiers {
    Some(text) => @utf8.encode(text[:], bom=false)
    None => Bytes::make(0, (0 : Int).to_byte())
  }
  if self.text_with_all_modifiers is Some(_) ||
    self.text_ignoring_modifiers is Some(_) {
    queue_keyboard_input_with_text_for_test(
      window.id().into_raw(),
      self.scancode,
      self.state,
      self.repeat,
      self.modifiers,
      text_with_all_modifiers,
      text_with_all_modifiers.length(),
      text_ignoring_modifiers,
      text_ignoring_modifiers.length(),
    )
  } else {
    queue_keyboard_input_for_test(
      window.id().into_raw(),
      self.scancode,
      self.state,
      self.repeat,
      self.modifiers,
    )
  }
}

///|
impl ApplicationHandler for KeyboardInputApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::KeyboardInput(Some(_), key_event, false) => {
      self.captured.val = Some(key_event)
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for ImeApp with can_create_surfaces(self, event_loop) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let raw_id = window.id().into_raw()
  match self.scenario {
    1 => {
      let preedit = @utf8.encode("nihao"[:], bom=false)
      queue_ime_preedit_for_test(raw_id, preedit, preedit.length(), 2, 5)
      let commit = @utf8.encode("你好"[:], bom=false)
      queue_ime_commit_for_test(raw_id, commit, commit.length())
      queue_ime_disabled_for_test(raw_id)
    }
    2 => {
      let preedit = @utf8.encode("a"[:], bom=false)
      queue_ime_preedit_for_test(raw_id, preedit, preedit.length(), 0, 1)
    }
    3 => queue_ime_delete_surrounding_for_test(raw_id, 3, 2)
    _ => ()
  }
}

///|
impl ApplicationHandler for ImeApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::Ime(ime) => {
      self.events.push(ime)
      if self.scenario == 1 && self.events.length() >= 4 {
        event_loop.exit()
      }
      if self.scenario == 2 && self.events.length() >= 2 {
        event_loop.exit()
      }
      if self.scenario == 3 && self.events.length() >= 1 {
        event_loop.exit()
      }
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for ImeConfigurationApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_ime_hints(
      @core.ImeHint::completion().union(@core.ImeHint::spellcheck()),
    )
    .with_ime_purpose(@core.ImePurpose::Password),
  )
  self.ime_capabilities.val = window.ime_capabilities()
  self.initial_hints.val = window.ime_hints()
  self.initial_purpose.val = window.ime_purpose()
  let surrounding_text = try! @core.ImeSurroundingText::new("hello world", 5, 0)
  let enable_request = match
    @core.ImeEnableRequest::new(
      @core.ImeCapabilities::all(),
      @core.ImeRequestData::default()
      .with_hint_and_purpose(
        @core.ImeHint::completion(),
        @core.ImePurpose::Normal,
      )
      .with_cursor_area(
        @dpi.PhysicalPosition::new(8, 16).into_position(),
        @dpi.PhysicalSize::new(10, 12).into_size(),
      )
      .with_surrounding_text(surrounding_text),
    ) {
    Some(enable_request) => enable_request
    None => abort("expected valid IME enable request")
  }
  self.enable_when_enabled_error.val = try {
    window.request_ime_update(@core.ImeRequest::Enable(enable_request))
    None
  } catch {
    error => Some(error)
  }
  self.request_purpose_ok.val = try {
    window.request_ime_update(
      @core.ImeRequest::SetPurpose(@core.ImePurpose::DateTime),
    )
    true
  } catch {
    _ => false
  }
  self.request_hint_and_purpose_ok.val = try {
    window.request_ime_update(
      @core.ImeRequestData::default()
      .with_hint_and_purpose(
        @core.ImeHint::multiline().union(@core.ImeHint::sensitive_data()),
        @core.ImePurpose::Email,
      )
      .into_request(),
    )
    true
  } catch {
    _ => false
  }
  self.request_surrounding_ok.val = try {
    window.request_ime_update(
      @core.ImeRequestData::default()
      .with_surrounding_text(surrounding_text)
      .into_request(),
    )
    true
  } catch {
    _ => false
  }
  self.surrounding_text_after_request.val = window.ime_surrounding_text()
  let clear_surrounding_ok = try {
    window.request_ime_update(@core.ImeRequest::SetSurroundingText(None))
    true
  } catch {
    _ => false
  }
  self.request_surrounding_ok.val = self.request_surrounding_ok.val &&
    clear_surrounding_ok
  self.surrounding_text_after_clear.val = window.ime_surrounding_text()
  self.request_cursor_ok.val = try {
    window.request_ime_update(
      @core.ImeRequestData::default()
      .with_cursor_area(
        @dpi.PhysicalPosition::new(48, 96).into_position(),
        @dpi.PhysicalSize::new(20, 32).into_size(),
      )
      .into_request(),
    )
    true
  } catch {
    _ => false
  }
  self.request_allowed_ok.val = try {
    window.request_ime_update(@core.ImeRequest::Disable)
    true
  } catch {
    _ => false
  }
  self.cursor_when_disabled_error.val = try {
    window.request_ime_update(
      @core.ImeRequestData::default()
      .with_cursor_area(
        @dpi.PhysicalPosition::new(48, 96).into_position(),
        @dpi.PhysicalSize::new(20, 32).into_size(),
      )
      .into_request(),
    )
    None
  } catch {
    error => Some(error)
  }
  window.set_ime_cursor_area(
    @dpi.PhysicalPosition::new(48, 96).into_position(),
    @dpi.PhysicalSize::new(20, 32).into_size(),
  )
  self.updated_hints.val = window.ime_hints()
  self.updated_purpose.val = window.ime_purpose()
  self.ime_allowed.val = window.ime_allowed()
  self.cursor_position.val = Some(window.ime_cursor_area_position())
  self.cursor_size.val = Some(window.ime_cursor_area_size())
  event_loop.exit()
}

///|
impl ApplicationHandler for ImeCapabilityRestrictionApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let surrounding_text = try! @core.ImeSurroundingText::new("abc", 1, 1)
  try! window.request_ime_update(@core.ImeRequest::Disable)
  let enable_request = match
    @core.ImeEnableRequest::new(
      @core.ImeCapabilities::default(),
      @core.ImeRequestData::default(),
    ) {
    Some(enable_request) => enable_request
    None => abort("expected valid IME enable request")
  }
  try! window.request_ime_update(@core.ImeRequest::Enable(enable_request))
  self.hint_and_purpose_not_supported.val = try {
    window.request_ime_update(
      @core.ImeRequestData::default()
      .with_hint_and_purpose(
        @core.ImeHint::multiline(),
        @core.ImePurpose::Email,
      )
      .into_request(),
    )
    false
  } catch {
    @core.ImeRequestError::NotSupported => true
    _ => false
  }
  self.purpose_not_supported.val = try {
    window.request_ime_update(
      @core.ImeRequest::SetPurpose(@core.ImePurpose::Date),
    )
    false
  } catch {
    @core.ImeRequestError::NotSupported => true
    _ => false
  }
  self.cursor_not_supported.val = try {
    window.request_ime_update(
      @core.ImeRequestData::default()
      .with_cursor_area(
        @dpi.PhysicalPosition::new(2, 4).into_position(),
        @dpi.PhysicalSize::new(8, 12).into_size(),
      )
      .into_request(),
    )
    false
  } catch {
    @core.ImeRequestError::NotSupported => true
    _ => false
  }
  self.surrounding_not_supported.val = try {
    window.request_ime_update(
      @core.ImeRequestData::default()
      .with_surrounding_text(surrounding_text)
      .into_request(),
    )
    false
  } catch {
    @core.ImeRequestError::NotSupported => true
    _ => false
  }
  event_loop.exit()
}

///|
impl ApplicationHandler for WindowAuxiliaryApiApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  self.title_initial.val = Some(window.title())
  window.set_title("window advanced api")
  self.title_after_update.val = Some(window.title())
  self.safe_area.val = Some(window.safe_area())

  window.pre_present_notify()
  window.reset_dead_keys()
  window.set_cursor_position(@dpi.PhysicalPosition::new(24, 24).into_position()) catch {
    _ => ()
  }
  window.set_cursor_grab(@core.CursorGrabMode::Locked) catch {
    _ => ()
  }
  window.set_cursor_grab(@core.CursorGrabMode::None) catch {
    _ => ()
  }
  self.cursor_grab_confined.val = try {
    window.set_cursor_grab(@core.CursorGrabMode::Confined)
    false
  } catch {
    @core.RequestError::NotSupported => true
    _ => false
  }
  self.drag_window_started.val = try {
    window.drag_window()
    true
  } catch {
    _ => false
  }
  self.drag_resize_started.val = try {
    window.drag_resize_window(@core.ResizeDirection::SouthEast)
    true
  } catch {
    _ => false
  }
  window.show_window_menu(@dpi.PhysicalPosition::new(8, 8).into_position())
  window.request_user_attention(Some(@core.UserAttentionType::Informational))
  window.request_user_attention(Some(@core.UserAttentionType::Critical))
  window.request_user_attention(None)
  event_loop.exit()
}

///|
impl ApplicationHandler for MonitorApiApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let available_monitors = event_loop.available_monitors()
  self.available_monitor_count.val = available_monitors.length()
  self.primary_monitor_from_event_loop.val = event_loop.primary_monitor()
  self.primary_monitor_from_window.val = window.primary_monitor()
  self.current_monitor.val = window.current_monitor()
  event_loop.exit()
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
    @core.WindowEvent::ScaleFactorChanged(scale_factor, writer) =>
      if scale_factor == 2.0 {
        self.seen_scale_factor.val = Some(scale_factor)
        writer.request_surface_size(@dpi.PhysicalSize::new(1200, 900))
      }
    @core.WindowEvent::SurfaceResized(size) =>
      if self.seen_scale_factor.val == Some(2.0) &&
        size == @dpi.PhysicalSize::new(1200, 900) {
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
struct WindowThemePreferenceApp {
  initial_theme : Ref[@core.Theme?]
  changed_theme : Ref[@core.Theme?]
}

///|
impl ApplicationHandler for WindowThemePreferenceApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_theme(Some(@core.Theme::Dark)),
  )
  self.initial_theme.val = window.theme()
  window.set_theme(Some(@core.Theme::Light))
  self.changed_theme.val = window.theme()
  event_loop.exit()
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
  current_occluded : Ref[Bool?]
  occluded : Ref[Bool?]
  window : Ref[Window?]
}

///|
impl ApplicationHandler for OccludedApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  self.window.val = Some(window)
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
      match self.window.val {
        Some(window) => self.current_occluded.val = Some(window.is_occluded())
        None => ()
      }
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
struct CloseRequestedApp {
  close_requested_seen : Ref[Bool]
}

///|
impl ApplicationHandler for CloseRequestedApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_close_requested_for_test(window.id().into_raw())
}

///|
impl ApplicationHandler for CloseRequestedApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::CloseRequested => {
      self.close_requested_seen.val = true
      event_loop.exit()
    }
    _ => ()
  }
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
impl ApplicationHandler for ProxyWakeWithoutWindowApp with can_create_surfaces(
  _self,
  _event_loop,
) {
  ()
}

///|
impl ApplicationHandler for ProxyWakeWithoutWindowApp with about_to_wait(
  self,
  event_loop,
) {
  self.about_to_wait_count.val = self.about_to_wait_count.val + 1
  if self.wake_requested.val == false {
    self.wake_requested.val = true
    let proxy = event_loop.create_proxy()
    proxy.wake_up()
  }
}

///|
impl ApplicationHandler for ProxyWakeWithoutWindowApp with proxy_wake_up(
  self,
  event_loop,
) {
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
test "event loop keeps running without windows and can be woken by proxy" {
  let event_loop = EventLoop::new()
  let about_to_wait_count = Ref::new(0)
  let wake_requested = Ref::new(false)
  let wake_seen = Ref::new(false)
  let app : ProxyWakeWithoutWindowApp = {
    about_to_wait_count,
    wake_requested,
    wake_seen,
  }
  event_loop.run_app(app)
  assert_true(about_to_wait_count.val > 0)
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
    control_flow: @core.ControlFlow::WaitUntil(220L),
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
test "focus_window updates focus state and has_focus" {
  let event_loop = EventLoop::new()
  let has_focus = Ref::new(None)
  let window = Ref::new(None)
  let app : FocusWindowApp = { has_focus, window }
  event_loop.run_app(app)
  assert_eq(has_focus.val, Some(true))
}

///|
test "focus_window is ignored for hidden windows" {
  let event_loop = EventLoop::new()
  let focused_event = Ref::new(None)
  let has_focus = Ref::new(None)
  let window = Ref::new(None)
  let app : HiddenFocusWindowApp = { focused_event, has_focus, window }
  event_loop.run_app(app)
  assert_eq(focused_event.val, None)
  assert_eq(has_focus.val, Some(false))
}

///|
test "focus_window is ignored for minimized windows" {
  let event_loop = EventLoop::new()
  let focused_event = Ref::new(None)
  let has_focus = Ref::new(None)
  let window = Ref::new(None)
  let app : MinimizedFocusWindowApp = { focused_event, has_focus, window }
  event_loop.run_app(app)
  assert_false(focused_event.val == Some(true))
  assert_eq(has_focus.val, Some(false))
}

///|
test "window attributes active=false keeps window unfocused" {
  let event_loop = EventLoop::new()
  let has_focus = Ref::new(None)
  let window = Ref::new(None)
  let app : InactiveWindowApp = { has_focus, window }
  event_loop.run_app(app)
  assert_eq(has_focus.val, Some(false))
}

///|
test "window minimize and maximize state can be controlled" {
  let event_loop = EventLoop::new()
  let minimized_after_enable = Ref::new(None)
  let minimized_after_disable = Ref::new(None)
  let maximized_after_enable = Ref::new(false)
  let maximized_after_disable = Ref::new(true)
  let app : WindowMinMaxStateApp = {
    maximized_after_disable,
    maximized_after_enable,
    minimized_after_disable,
    minimized_after_enable,
  }
  event_loop.run_app(app)
  assert_eq(minimized_after_enable.val, Some(true))
  assert_eq(minimized_after_disable.val, Some(false))
  assert_true(maximized_after_enable.val)
  assert_false(maximized_after_disable.val)
}

///|
test "window fullscreen state can be controlled" {
  let event_loop = EventLoop::new()
  let fullscreen_initial = Ref::new(None)
  let fullscreen_after_disable = Ref::new(
    Some(@core.Fullscreen::Borderless(None)),
  )
  let fullscreen_after_enable = Ref::new(None)
  let app : WindowFullscreenStateApp = {
    fullscreen_after_disable,
    fullscreen_after_enable,
    fullscreen_initial,
  }
  event_loop.run_app(app)
  assert_eq(fullscreen_initial.val, Some(@core.Fullscreen::Borderless(None)))
  assert_eq(fullscreen_after_disable.val, None)
  assert_eq(
    fullscreen_after_enable.val,
    Some(@core.Fullscreen::Borderless(None)),
  )
}

///|
test "window fullscreen roundtrip keeps exclusive and targeted borderless modes" {
  let event_loop = EventLoop::new()
  let has_monitor = Ref::new(false)
  let exclusive = Ref::new(None)
  let borderless_targeted = Ref::new(None)
  let app : WindowFullscreenRoundtripApp = {
    borderless_targeted,
    exclusive,
    has_monitor,
  }
  event_loop.run_app(app)
  if has_monitor.val {
    assert_true(exclusive.val is Some(@core.Fullscreen::Exclusive(_, _)))
    assert_true(
      borderless_targeted.val is Some(@core.Fullscreen::Borderless(Some(_))),
    )
  } else {
    assert_eq(exclusive.val, None)
    assert_eq(borderless_targeted.val, None)
  }
}

///|
test "window decorations can be configured at create and runtime" {
  let event_loop = EventLoop::new()
  let decorated_initial = Ref::new(true)
  let decorated_after_enable = Ref::new(false)
  let decorated_after_disable = Ref::new(true)
  let app : WindowDecorationsApp = {
    decorated_after_disable,
    decorated_after_enable,
    decorated_initial,
  }
  event_loop.run_app(app)
  assert_false(decorated_initial.val)
  assert_true(decorated_after_enable.val)
  assert_false(decorated_after_disable.val)
}

///|
test "window level can be configured at create and runtime" {
  let event_loop = EventLoop::new()
  let level_initial = Ref::new(None)
  let level_after_update = Ref::new(None)
  let app : WindowLevelApp = { level_after_update, level_initial }
  event_loop.run_app(app)
  assert_eq(level_initial.val, Some(@core.WindowLevel::AlwaysOnTop))
  assert_eq(level_after_update.val, Some(@core.WindowLevel::AlwaysOnBottom))
}

///|
test "window attributes maximized applies at creation time" {
  let event_loop = EventLoop::new()
  let maximized = Ref::new(false)
  let app : AttributesMaximizedApp = { maximized, }
  event_loop.run_app(app)
  assert_true(maximized.val)
}

///|
test "window transparency can be configured at create and runtime" {
  let event_loop = EventLoop::new()
  let transparent_initial = Ref::new(false)
  let transparent_after_disable = Ref::new(true)
  let transparent_after_enable = Ref::new(false)
  let app : WindowTransparentApp = {
    transparent_after_disable,
    transparent_after_enable,
    transparent_initial,
  }
  event_loop.run_app(app)
  assert_true(transparent_initial.val)
  assert_false(transparent_after_disable.val)
  assert_true(transparent_after_enable.val)
}

///|
test "window blur can be configured at create and runtime" {
  let event_loop = EventLoop::new()
  let blur_initial = Ref::new(false)
  let blur_after_disable = Ref::new(true)
  let blur_after_enable = Ref::new(false)
  let app : WindowBlurApp = {
    blur_after_disable,
    blur_after_enable,
    blur_initial,
  }
  event_loop.run_app(app)
  assert_true(blur_initial.val)
  assert_false(blur_after_disable.val)
  assert_true(blur_after_enable.val)
}

///|
test "window cursor can be configured at create and runtime" {
  let event_loop = EventLoop::new()
  let cursor_initial = Ref::new(None)
  let cursor_after_first_update = Ref::new(None)
  let cursor_after_second_update = Ref::new(None)
  let hittest_initial = Ref::new(false)
  let hittest_after_disable = Ref::new(true)
  let hittest_after_enable = Ref::new(false)
  let visible_initial = Ref::new(false)
  let visible_after_disable = Ref::new(true)
  let visible_after_enable = Ref::new(false)
  let app : WindowCursorApp = {
    cursor_after_first_update,
    cursor_after_second_update,
    cursor_initial,
    hittest_after_disable,
    hittest_after_enable,
    hittest_initial,
    visible_after_disable,
    visible_after_enable,
    visible_initial,
  }
  event_loop.run_app(app)
  assert_eq(
    cursor_initial.val,
    Some(@core.Cursor::Icon(@core.CursorIcon::NeResize)),
  )
  assert_eq(
    cursor_after_first_update.val,
    Some(@core.Cursor::Icon(@core.CursorIcon::ContextMenu)),
  )
  assert_eq(
    cursor_after_second_update.val,
    Some(@core.Cursor::Icon(@core.CursorIcon::RowResize)),
  )
  assert_true(visible_initial.val)
  assert_false(visible_after_disable.val)
  assert_true(visible_after_enable.val)
  assert_true(hittest_initial.val)
  assert_false(hittest_after_disable.val)
  assert_true(hittest_after_enable.val)
}

///|
test "window icon can be configured at create and runtime" {
  let event_loop = EventLoop::new()
  let icon_initial = Ref::new(false)
  let icon_after_clear = Ref::new(false)
  let icon_after_restore = Ref::new(false)
  let app : WindowIconApp = {
    icon_after_clear,
    icon_after_restore,
    icon_initial,
  }
  event_loop.run_app(app)
  assert_false(icon_initial.val)
  assert_false(icon_after_clear.val)
  assert_false(icon_after_restore.val)
}

///|
test "window visibility and resizable getters reflect runtime updates" {
  let event_loop = EventLoop::new()
  let visible_initial = Ref::new(None)
  let visible_after_enable = Ref::new(None)
  let visible_after_disable = Ref::new(None)
  let resizable_initial = Ref::new(false)
  let resizable_after_disable = Ref::new(true)
  let resizable_after_enable = Ref::new(false)
  let app : WindowVisibilityResizableApp = {
    resizable_after_disable,
    resizable_after_enable,
    resizable_initial,
    visible_after_disable,
    visible_after_enable,
    visible_initial,
  }
  event_loop.run_app(app)
  assert_eq(visible_initial.val, Some(false))
  assert_eq(visible_after_enable.val, Some(true))
  assert_eq(visible_after_disable.val, Some(false))
  assert_true(resizable_initial.val)
  assert_false(resizable_after_disable.val)
  assert_true(resizable_after_enable.val)
}

///|
test "window content protection can be configured at create and runtime" {
  let event_loop = EventLoop::new()
  let protected_initial = Ref::new(false)
  let protected_after_disable = Ref::new(true)
  let protected_after_enable = Ref::new(false)
  let app : WindowContentProtectedApp = {
    protected_after_disable,
    protected_after_enable,
    protected_initial,
  }
  event_loop.run_app(app)
  assert_true(protected_initial.val)
  assert_false(protected_after_disable.val)
  assert_true(protected_after_enable.val)
}

///|
test "window enabled buttons can be configured at create and runtime" {
  let event_loop = EventLoop::new()
  let close_initial = Ref::new(true)
  let minimize_initial = Ref::new(false)
  let maximize_initial = Ref::new(true)
  let close_after_enable = Ref::new(false)
  let minimize_after_enable = Ref::new(false)
  let maximize_after_enable = Ref::new(false)
  let app : WindowEnabledButtonsApp = {
    close_after_enable,
    close_initial,
    maximize_after_enable,
    maximize_initial,
    minimize_after_enable,
    minimize_initial,
  }
  event_loop.run_app(app)
  assert_false(close_initial.val)
  assert_true(minimize_initial.val)
  assert_false(maximize_initial.val)
  assert_true(close_after_enable.val)
  assert_true(minimize_after_enable.val)
  assert_true(maximize_after_enable.val)
}

///|
test "window surface resize increments can be configured at create and runtime" {
  let event_loop = EventLoop::new()
  let increments_initial = Ref::new(None)
  let increments_after_disable = Ref::new(Some(@dpi.PhysicalSize::new(1, 1)))
  let increments_after_enable = Ref::new(None)
  let app : SurfaceResizeIncrementsApp = {
    increments_after_disable,
    increments_after_enable,
    increments_initial,
  }
  event_loop.run_app(app)
  assert_eq(increments_initial.val, Some(@dpi.PhysicalSize::new(64, 48)))
  assert_eq(increments_after_disable.val, None)
  assert_eq(increments_after_enable.val, Some(@dpi.PhysicalSize::new(32, 24)))
}

///|
test "window redraw requests are delivered" {
  let event_loop = EventLoop::new()
  let redraw_requested = Ref::new(false)
  event_loop.run_app({ redraw_requested, })
  assert_true(redraw_requested.val)
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
test "window outer position can be set and read" {
  let event_loop = EventLoop::new()
  let moved = Ref::new(None)
  let outer_position = Ref::new(None)
  let window = Ref::new(None)
  let app : OuterPositionApp = { moved, outer_position, window }
  event_loop.run_app(app)
  assert_eq(moved.val, Some(@dpi.PhysicalPosition::new(320, 180)))
  assert_eq(outer_position.val, Some(@dpi.PhysicalPosition::new(320, 180)))
}

///|
test "window outer size reports frame dimensions" {
  let event_loop = EventLoop::new()
  let outer_size = Ref::new(None)
  let surface_position = Ref::new(None)
  let surface_size = Ref::new(None)
  let app : OuterSizeApp = { outer_size, surface_position, surface_size }
  event_loop.run_app(app)
  match (surface_size.val, outer_size.val, surface_position.val) {
    (Some(surface), Some(outer), Some(position)) => {
      assert_true(position.x() >= 0)
      assert_true(position.y() >= 0)
      assert_true(outer.width() >= surface.width())
      assert_true(outer.height() >= surface.height())
      assert_true(outer.width() >= surface.width() + position.x())
      assert_true(outer.height() >= surface.height() + position.y())
    }
    _ => abort("expected outer/surface sizes and surface position")
  }
}

///|
test "window attributes position applies at creation time" {
  let event_loop = EventLoop::new()
  let moved = Ref::new(None)
  let outer_position = Ref::new(None)
  let window = Ref::new(None)
  let app : AttributesPositionApp = { moved, outer_position, window }
  event_loop.run_app(app)
  assert_eq(moved.val, Some(@dpi.PhysicalPosition::new(480, 260)))
  assert_eq(outer_position.val, Some(@dpi.PhysicalPosition::new(480, 260)))
}

///|
test "window request surface size delivers resized event" {
  let event_loop = EventLoop::new()
  let request_result = Ref::new(None)
  let resized = Ref::new(None)
  let surface_size = Ref::new(None)
  let window = Ref::new(None)
  let app : RequestSurfaceSizeApp = {
    request_result,
    resized,
    surface_size,
    window,
  }
  event_loop.run_app(app)
  assert_eq(request_result.val, None)
  assert_eq(resized.val, Some(@dpi.PhysicalSize::new(1200, 900)))
  assert_eq(surface_size.val, Some(@dpi.PhysicalSize::new(1200, 900)))
}

///|
test "window min surface size clamps resize requests" {
  let event_loop = EventLoop::new()
  let min_surface_size = Ref::new(None)
  let resized = Ref::new(None)
  let surface_size = Ref::new(None)
  let window = Ref::new(None)
  let app : MinSurfaceSizeApp = {
    min_surface_size,
    resized,
    surface_size,
    window,
  }
  event_loop.run_app(app)
  assert_eq(min_surface_size.val, Some(@dpi.PhysicalSize::new(960, 720)))
  assert_eq(resized.val, Some(@dpi.PhysicalSize::new(960, 720)))
  assert_eq(surface_size.val, Some(@dpi.PhysicalSize::new(960, 720)))
}

///|
test "window max surface size clamps resize requests" {
  let event_loop = EventLoop::new()
  let max_surface_size = Ref::new(None)
  let resized = Ref::new(None)
  let surface_size = Ref::new(None)
  let window = Ref::new(None)
  let app : MaxSurfaceSizeApp = {
    max_surface_size,
    resized,
    surface_size,
    window,
  }
  event_loop.run_app(app)
  assert_eq(max_surface_size.val, Some(@dpi.PhysicalSize::new(1024, 768)))
  assert_eq(resized.val, Some(@dpi.PhysicalSize::new(1024, 768)))
  assert_eq(surface_size.val, Some(@dpi.PhysicalSize::new(1024, 768)))
}

///|
test "window attributes max surface size applies at creation time" {
  let event_loop = EventLoop::new()
  let resized = Ref::new(None)
  let surface_size = Ref::new(None)
  let window = Ref::new(None)
  let app : AttributesSurfaceConstraintsApp = { resized, surface_size, window }
  event_loop.run_app(app)
  assert_eq(resized.val, Some(@dpi.PhysicalSize::new(1280, 720)))
  assert_eq(surface_size.val, Some(@dpi.PhysicalSize::new(1280, 720)))
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
test "drag events are delivered with paths and positions" {
  let event_loop = EventLoop::new()
  let entered_paths = Ref::new(None)
  let entered_position = Ref::new(None)
  let moved_position = Ref::new(None)
  let dropped_paths = Ref::new(None)
  let dropped_position = Ref::new(None)
  let left_position = Ref::new(None)
  let app : DragEventsApp = {
    dropped_paths,
    dropped_position,
    entered_paths,
    entered_position,
    left_position,
    moved_position,
  }
  event_loop.run_app(app)
  assert_eq(
    entered_paths.val,
    Some(["/tmp/drag-entered-a.txt", "/tmp/drag-entered-b.txt"]),
  )
  assert_eq(
    entered_position.val,
    Some(@dpi.PhysicalPositionF64::new(12.5, 24.0)),
  )
  assert_eq(moved_position.val, Some(@dpi.PhysicalPositionF64::new(32.0, 48.0)))
  assert_eq(
    dropped_paths.val,
    Some(["/tmp/drag-dropped-a.txt", "/tmp/drag-dropped-b.txt"]),
  )
  assert_eq(
    dropped_position.val,
    Some(@dpi.PhysicalPositionF64::new(64.0, 96.0)),
  )
  assert_eq(left_position.val, Some(@dpi.PhysicalPositionF64::new(80.0, 120.0)))
}

///|
test "drag left can omit pointer position" {
  let event_loop = EventLoop::new()
  let left_position = Ref::new(Some(@dpi.PhysicalPositionF64::new(1.0, 1.0)))
  let app : DragLeftWithoutPositionApp = { left_position, }
  event_loop.run_app(app)
  assert_eq(left_position.val, None)
}

///|
test "gesture events are delivered" {
  let event_loop = EventLoop::new()
  let double_tap_seen = Ref::new(false)
  let pan_delta = Ref::new(None)
  let pan_phase = Ref::new(None)
  let pinch_delta = Ref::new(None)
  let pinch_phase = Ref::new(None)
  let pressure = Ref::new(None)
  let pressure_stage = Ref::new(None)
  let rotation_delta = Ref::new(None)
  let rotation_phase = Ref::new(None)
  let app : GestureEventsApp = {
    double_tap_seen,
    pan_delta,
    pan_phase,
    pinch_delta,
    pinch_phase,
    pressure,
    pressure_stage,
    rotation_delta,
    rotation_phase,
  }
  event_loop.run_app(app)
  assert_eq(pinch_delta.val, Some(0.75))
  assert_eq(pinch_phase.val, Some(@core.TouchPhase::Started))
  assert_eq(pan_delta.val, Some(@dpi.PhysicalPositionF64::new(-18.0, 6.5)))
  assert_eq(pan_phase.val, Some(@core.TouchPhase::Moved))
  assert_true(double_tap_seen.val)
  assert_eq(rotation_delta.val, Some(22.5))
  assert_eq(rotation_phase.val, Some(@core.TouchPhase::Ended))
  assert_eq(pressure.val, Some(0.42))
  assert_eq(pressure_stage.val, Some(2))
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
test "modifiers changed events are delivered" {
  let event_loop = EventLoop::new()
  let modifiers = Ref::new(None)
  event_loop.run_app({ modifiers, })
  assert_eq(modifiers.val, Some(@core.Modifiers::new(true, false, true, true)))
}

///|
test "focus loss resets modifiers" {
  let event_loop = EventLoop::new()
  let modifiers_events = []
  event_loop.run_app({ modifiers_events, })
  assert_eq(modifiers_events, [
    @core.Modifiers::new(true, true, false, false),
    @core.Modifiers::default(),
  ])
}

///|
test "keyboard input reports character keys" {
  let event_loop = EventLoop::new()
  let captured = Ref::new(None)
  let app : KeyboardInputApp = {
    captured,
    modifiers: 0,
    repeat: false,
    scancode: 0x00,
    state: 1,
    text_with_all_modifiers: Some("a"),
    text_ignoring_modifiers: Some("a"),
  }
  event_loop.run_app(app)
  assert_eq(
    captured.val,
    Some(
      @core.KeyEvent::new(
        @core.PhysicalKey::Code(@core.KeyCode::KeyA),
        @core.Key::Character("a"),
        @core.Key::Character("a"),
        @core.KeyLocation::Standard,
        @core.ElementState::Pressed,
        false,
        Some("a"),
        Some("a"),
      ),
    ),
  )
}

///|
test "keyboard input applies shift and repeat" {
  let event_loop = EventLoop::new()
  let captured = Ref::new(None)
  let app : KeyboardInputApp = {
    captured,
    modifiers: 1,
    repeat: true,
    scancode: 0x00,
    state: 1,
    text_with_all_modifiers: Some("A"),
    text_ignoring_modifiers: Some("a"),
  }
  event_loop.run_app(app)
  assert_eq(
    captured.val,
    Some(
      @core.KeyEvent::new(
        @core.PhysicalKey::Code(@core.KeyCode::KeyA),
        @core.Key::Character("A"),
        @core.Key::Character("a"),
        @core.KeyLocation::Standard,
        @core.ElementState::Pressed,
        true,
        Some("A"),
        Some("A"),
      ),
    ),
  )
}

///|
test "keyboard input reports modifier keys with side information" {
  let event_loop = EventLoop::new()
  let captured = Ref::new(None)
  let app : KeyboardInputApp = {
    captured,
    modifiers: 1,
    repeat: false,
    scancode: 0x38,
    state: 1,
    text_with_all_modifiers: None,
    text_ignoring_modifiers: None,
  }
  event_loop.run_app(app)
  assert_eq(
    captured.val,
    Some(
      @core.KeyEvent::new(
        @core.PhysicalKey::Code(@core.KeyCode::ShiftLeft),
        @core.Key::Named(@core.NamedKey::Shift),
        @core.Key::Named(@core.NamedKey::Shift),
        @core.KeyLocation::Left,
        @core.ElementState::Pressed,
        false,
        None,
        None,
      ),
    ),
  )
}

///|
test "keyboard input reports key release without text" {
  let event_loop = EventLoop::new()
  let captured = Ref::new(None)
  let app : KeyboardInputApp = {
    captured,
    modifiers: 0,
    repeat: false,
    scancode: 0x24,
    state: 2,
    text_with_all_modifiers: None,
    text_ignoring_modifiers: None,
  }
  event_loop.run_app(app)
  assert_eq(
    captured.val,
    Some(
      @core.KeyEvent::new(
        @core.PhysicalKey::Code(@core.KeyCode::Enter),
        @core.Key::Named(@core.NamedKey::Enter),
        @core.Key::Named(@core.NamedKey::Enter),
        @core.KeyLocation::Standard,
        @core.ElementState::Released,
        false,
        None,
        None,
      ),
    ),
  )
}

///|
test "keyboard input prefers native event text when provided" {
  let event_loop = EventLoop::new()
  let captured = Ref::new(None)
  let app : KeyboardInputApp = {
    captured,
    modifiers: 0,
    repeat: false,
    scancode: 0x00,
    state: 1,
    text_with_all_modifiers: Some("q"),
    text_ignoring_modifiers: Some("q"),
  }
  event_loop.run_app(app)
  assert_eq(
    captured.val,
    Some(
      @core.KeyEvent::new(
        @core.PhysicalKey::Code(@core.KeyCode::KeyA),
        @core.Key::Character("q"),
        @core.Key::Character("q"),
        @core.KeyLocation::Standard,
        @core.ElementState::Pressed,
        false,
        Some("q"),
        Some("q"),
      ),
    ),
  )
}

///|
test "keyboard input emits dead key when only ignoring-modifier text is present" {
  let event_loop = EventLoop::new()
  let captured = Ref::new(None)
  let app : KeyboardInputApp = {
    captured,
    modifiers: 0,
    repeat: false,
    scancode: 0x32,
    state: 1,
    text_with_all_modifiers: None,
    text_ignoring_modifiers: Some("`"),
  }
  event_loop.run_app(app)
  assert_eq(
    captured.val,
    Some(
      @core.KeyEvent::new(
        @core.PhysicalKey::Code(@core.KeyCode::Backquote),
        @core.Key::Dead(Some("`")),
        @core.Key::Character("`"),
        @core.KeyLocation::Standard,
        @core.ElementState::Pressed,
        false,
        None,
        None,
      ),
    ),
  )
}

///|
test "keyboard input with control prefers ignoring-modifier logical text" {
  let event_loop = EventLoop::new()
  let captured = Ref::new(None)
  let app : KeyboardInputApp = {
    captured,
    modifiers: 2,
    repeat: false,
    scancode: 0x1C,
    state: 1,
    text_with_all_modifiers: Some("{"),
    text_ignoring_modifiers: Some("8"),
  }
  event_loop.run_app(app)
  assert_eq(
    captured.val,
    Some(
      @core.KeyEvent::new(
        @core.PhysicalKey::Code(@core.KeyCode::Digit8),
        @core.Key::Character("8"),
        @core.Key::Character("8"),
        @core.KeyLocation::Standard,
        @core.ElementState::Pressed,
        false,
        Some("8"),
        Some("{"),
      ),
    ),
  )
}

///|
test "ime preedit commit and disabled events are delivered" {
  let event_loop = EventLoop::new()
  let events = []
  let app : ImeApp = { events, scenario: 1 }
  event_loop.run_app(app)
  assert_eq(events, [
    @core.Ime::Enabled,
    @core.Ime::Preedit("nihao", Some(@core.ImeCursorRange::new(2, 5))),
    @core.Ime::Commit("你好"),
    @core.Ime::Disabled,
  ])
}

///|
test "ime preedit always includes enabled first" {
  let event_loop = EventLoop::new()
  let events = []
  let app : ImeApp = { events, scenario: 2 }
  event_loop.run_app(app)
  assert_eq(events, [
    @core.Ime::Enabled,
    @core.Ime::Preedit("a", Some(@core.ImeCursorRange::new(0, 1))),
  ])
}

///|
test "ime delete-surrounding event is delivered" {
  let event_loop = EventLoop::new()
  let events = []
  let app : ImeApp = { events, scenario: 3 }
  event_loop.run_app(app)
  assert_eq(events, [@core.Ime::DeleteSurrounding(3, 2)])
}

///|
test "window ime configuration updates native state" {
  let event_loop = EventLoop::new()
  let cursor_when_disabled_error = Ref::new(None)
  let enable_when_enabled_error = Ref::new(None)
  let ime_capabilities = Ref::new(None)
  let initial_hints = Ref::new(@core.ImeHint::none())
  let initial_purpose = Ref::new(@core.ImePurpose::Normal)
  let updated_purpose = Ref::new(@core.ImePurpose::Normal)
  let updated_hints = Ref::new(@core.ImeHint::none())
  let ime_allowed = Ref::new(true)
  let request_allowed_ok = Ref::new(false)
  let request_purpose_ok = Ref::new(false)
  let request_cursor_ok = Ref::new(false)
  let request_hint_and_purpose_ok = Ref::new(false)
  let request_surrounding_ok = Ref::new(false)
  let surrounding_text_after_request = Ref::new(None)
  let surrounding_text_after_clear = Ref::new(None)
  let cursor_position = Ref::new(None)
  let cursor_size = Ref::new(None)
  let app : ImeConfigurationApp = {
    cursor_when_disabled_error,
    enable_when_enabled_error,
    cursor_position,
    cursor_size,
    ime_capabilities,
    ime_allowed,
    initial_hints,
    initial_purpose,
    request_allowed_ok,
    request_cursor_ok,
    request_hint_and_purpose_ok,
    request_purpose_ok,
    request_surrounding_ok,
    surrounding_text_after_clear,
    surrounding_text_after_request,
    updated_hints,
    updated_purpose,
  }
  event_loop.run_app(app)
  assert_eq(
    ime_capabilities.val,
    Some(@core.ImeCapabilities::new(true, true, true)),
  )
  assert_eq(
    initial_hints.val,
    @core.ImeHint::completion().union(@core.ImeHint::spellcheck()),
  )
  assert_eq(initial_purpose.val, @core.ImePurpose::Password)
  assert_true(request_allowed_ok.val)
  assert_true(request_hint_and_purpose_ok.val)
  assert_true(request_purpose_ok.val)
  assert_true(request_cursor_ok.val)
  assert_true(
    match enable_when_enabled_error.val {
      Some(@core.ImeRequestError::AlreadyEnabled) => true
      _ => false
    },
  )
  assert_true(
    match cursor_when_disabled_error.val {
      Some(@core.ImeRequestError::NotEnabled) => true
      _ => false
    },
  )
  assert_true(request_surrounding_ok.val)
  assert_eq(
    surrounding_text_after_request.val,
    Some(try! @core.ImeSurroundingText::new("hello world", 5, 0)),
  )
  assert_eq(surrounding_text_after_clear.val, None)
  assert_eq(
    updated_hints.val,
    @core.ImeHint::multiline().union(@core.ImeHint::sensitive_data()),
  )
  assert_eq(updated_purpose.val, @core.ImePurpose::Email)
  assert_false(ime_allowed.val)
  assert_eq(cursor_position.val, Some(@dpi.PhysicalPosition::new(48, 96)))
  assert_eq(cursor_size.val, Some(@dpi.PhysicalSize::new(20, 32)))
}

///|
test "ime request updates respect negotiated capabilities" {
  let event_loop = EventLoop::new()
  let hint_and_purpose_not_supported = Ref::new(false)
  let purpose_not_supported = Ref::new(false)
  let cursor_not_supported = Ref::new(false)
  let surrounding_not_supported = Ref::new(false)
  let app : ImeCapabilityRestrictionApp = {
    cursor_not_supported,
    hint_and_purpose_not_supported,
    purpose_not_supported,
    surrounding_not_supported,
  }
  event_loop.run_app(app)
  assert_true(hint_and_purpose_not_supported.val)
  assert_true(purpose_not_supported.val)
  assert_true(cursor_not_supported.val)
  assert_true(surrounding_not_supported.val)
}

///|
test "window auxiliary api methods are available on macos" {
  let event_loop = EventLoop::new()
  let title_initial = Ref::new(None)
  let title_after_update = Ref::new(None)
  let safe_area = Ref::new(None)
  let cursor_grab_confined = Ref::new(true)
  let drag_window_started = Ref::new(true)
  let drag_resize_started = Ref::new(true)
  let app : WindowAuxiliaryApiApp = {
    cursor_grab_confined,
    drag_resize_started,
    drag_window_started,
    safe_area,
    title_after_update,
    title_initial,
  }
  event_loop.run_app(app)
  assert_eq(title_initial.val, Some("winit window"))
  assert_eq(title_after_update.val, Some("window advanced api"))
  match safe_area.val {
    Some(insets) => {
      assert_true(insets.top() >= 0)
      assert_true(insets.left() >= 0)
      assert_true(insets.bottom() >= 0)
      assert_true(insets.right() >= 0)
    }
    None => abort("expected safe area to be captured")
  }
  assert_true(cursor_grab_confined.val)
  let _ = drag_window_started.val
  assert_false(drag_resize_started.val)
}

///|
test "monitor api returns available primary and current monitor handles" {
  let event_loop = EventLoop::new()
  let available_monitor_count = Ref::new(0)
  let primary_monitor_from_event_loop = Ref::new(None)
  let primary_monitor_from_window = Ref::new(None)
  let current_monitor = Ref::new(None)
  let app : MonitorApiApp = {
    available_monitor_count,
    current_monitor,
    primary_monitor_from_event_loop,
    primary_monitor_from_window,
  }
  event_loop.run_app(app)
  assert_true(available_monitor_count.val >= 0)
  if available_monitor_count.val > 0 {
    assert_true(primary_monitor_from_event_loop.val is Some(_))
  }
  match primary_monitor_from_event_loop.val {
    Some(primary_from_loop) => {
      assert_true(primary_from_loop.native_id() > (0 : Int).to_uint64())
      assert_true(primary_from_loop.surface_size().width() > 0)
      assert_true(primary_from_loop.surface_size().height() > 0)
      assert_true(primary_from_loop.scale_factor() > 0.0)
      for mode in primary_from_loop.video_modes() {
        assert_true(mode.surface_size().width() > 0)
        assert_true(mode.surface_size().height() > 0)
        match mode.bit_depth() {
          Some(bit_depth) => assert_true(bit_depth > 0)
          None => ()
        }
        match mode.refresh_rate_millihertz() {
          Some(refresh_rate_millihertz) =>
            assert_true(refresh_rate_millihertz > 0)
          None => ()
        }
      }
      match primary_from_loop.current_video_mode() {
        Some(current_mode) => {
          let mut found = false
          for mode in primary_from_loop.video_modes() {
            if mode == current_mode {
              found = true
            }
          }
          assert_true(found)
        }
        None => ()
      }
      match primary_monitor_from_window.val {
        Some(primary_from_window) =>
          assert_eq(
            primary_from_window.native_id(),
            primary_from_loop.native_id(),
          )
        None => ()
      }
    }
    None => ()
  }
  match current_monitor.val {
    Some(monitor) => {
      assert_true(monitor.native_id() > (0 : Int).to_uint64())
      assert_true(monitor.surface_size().width() > 0)
      assert_true(monitor.surface_size().height() > 0)
      assert_true(monitor.scale_factor() > 0.0)
    }
    None => ()
  }
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
test "window theme can be configured at create and runtime" {
  let event_loop = EventLoop::new()
  let initial_theme = Ref::new(None)
  let changed_theme = Ref::new(None)
  event_loop.run_app({ initial_theme, changed_theme })
  assert_eq(initial_theme.val, Some(@core.Theme::Dark))
  assert_eq(changed_theme.val, Some(@core.Theme::Light))
}

///|
test "occluded events are delivered" {
  let event_loop = EventLoop::new()
  let window = Ref::new(None)
  let current_occluded = Ref::new(None)
  let occluded = Ref::new(None)
  event_loop.run_app({ window, current_occluded, occluded })
  assert_eq(occluded.val, Some(true))
  assert_eq(current_occluded.val, Some(true))
}

///|
test "close requested is delivered when the backend queues it" {
  let event_loop = EventLoop::new()
  let close_requested_seen = Ref::new(false)
  event_loop.run_app({ close_requested_seen, })
  assert_true(close_requested_seen.val)
}

///|
test "destroyed is delivered when the event loop exits" {
  let event_loop = EventLoop::new()
  let destroyed_seen = Ref::new(false)
  event_loop.run_app({ destroyed_seen, })
  assert_true(destroyed_seen.val)
}
