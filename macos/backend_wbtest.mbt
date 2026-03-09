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
extern "C" fn ime_allowed_for_test(window_id : Int) -> Bool = "mbw_test_window_ime_allowed"

///|
extern "C" fn ime_cursor_area_x_for_test(window_id : Int) -> Int = "mbw_test_window_ime_cursor_area_x"

///|
extern "C" fn ime_cursor_area_y_for_test(window_id : Int) -> Int = "mbw_test_window_ime_cursor_area_y"

///|
extern "C" fn ime_cursor_area_width_for_test(window_id : Int) -> Int = "mbw_test_window_ime_cursor_area_width"

///|
extern "C" fn ime_cursor_area_height_for_test(window_id : Int) -> Int = "mbw_test_window_ime_cursor_area_height"

///|
extern "C" fn ime_purpose_for_test(window_id : Int) -> Int = "mbw_test_window_ime_purpose"

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
struct FocusApp {
  focused_values : Array[Bool]
}

///|
struct FocusWindowApp {
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
  minimized_after_disable : Ref[Bool]
  minimized_after_enable : Ref[Bool]
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
struct WindowVisibilityResizableApp {
  resizable_after_disable : Ref[Bool]
  resizable_after_enable : Ref[Bool]
  resizable_initial : Ref[Bool]
  visible_after_disable : Ref[Bool]
  visible_after_enable : Ref[Bool]
  visible_initial : Ref[Bool]
}

///|
struct MovedApp {
  moved : Ref[@dpi.PhysicalPosition?]
}

///|
struct OuterPositionApp {
  moved : Ref[@dpi.PhysicalPosition?]
  outer_position : Ref[@dpi.PhysicalPosition?]
  window : Ref[Window?]
}

///|
struct AttributesPositionApp {
  moved : Ref[@dpi.PhysicalPosition?]
  outer_position : Ref[@dpi.PhysicalPosition?]
  window : Ref[Window?]
}

///|
struct RequestSurfaceSizeApp {
  resized : Ref[@dpi.PhysicalSize?]
  surface_size : Ref[@dpi.PhysicalSize?]
  window : Ref[Window?]
}

///|
struct MinSurfaceSizeApp {
  resized : Ref[@dpi.PhysicalSize?]
  surface_size : Ref[@dpi.PhysicalSize?]
  window : Ref[Window?]
}

///|
struct MaxSurfaceSizeApp {
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
  initial_purpose : Ref[Int]
  window_id : Ref[Int]
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
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  self.window.val = Some(window)
  window.focus_window()
}

///|
impl ApplicationHandler for FocusWindowApp with window_event(
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
impl ApplicationHandler for OuterPositionApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  self.window.val = Some(window)
  window.set_outer_position(@dpi.PhysicalPosition::new(320, 180))
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
        Some(window) => self.outer_position.val = Some(window.outer_position())
        None => ()
      }
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for AttributesPositionApp with can_create_surfaces(
  self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_position(Some(@dpi.PhysicalPosition::new(480, 260))),
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
        Some(window) => self.outer_position.val = Some(window.outer_position())
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
  window.request_surface_size(@dpi.PhysicalSize::new(1200, 900))
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
  window.set_min_surface_size(Some(@dpi.PhysicalSize::new(960, 720)))
  window.request_surface_size(@dpi.PhysicalSize::new(640, 480))
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
  window.set_max_surface_size(Some(@dpi.PhysicalSize::new(1024, 768)))
  window.request_surface_size(@dpi.PhysicalSize::new(1400, 1050))
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
    .with_surface_size(@dpi.PhysicalSize::new(1600, 1200))
    .with_max_surface_size(Some(@dpi.PhysicalSize::new(1280, 720))),
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
    @core.WindowEvent::KeyboardInput(key_event, false) => {
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
    .with_ime_purpose(@core.ImePurpose::Password),
  )
  self.window_id.val = window.id().into_raw()
  self.initial_purpose.val = ime_purpose_for_test(window.id().into_raw())
  window.set_ime_purpose(@core.ImePurpose::Terminal)
  window.set_ime_allowed(false)
  window.set_ime_cursor_area(
    @dpi.PhysicalPosition::new(48, 96),
    @dpi.PhysicalSize::new(20, 32),
  )
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
  let focused_event = Ref::new(None)
  let has_focus = Ref::new(None)
  let window = Ref::new(None)
  let app : FocusWindowApp = { focused_event, has_focus, window }
  event_loop.run_app(app)
  assert_eq(focused_event.val, Some(true))
  assert_eq(has_focus.val, Some(true))
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
  let minimized_after_enable = Ref::new(false)
  let minimized_after_disable = Ref::new(true)
  let maximized_after_enable = Ref::new(false)
  let maximized_after_disable = Ref::new(true)
  let app : WindowMinMaxStateApp = {
    maximized_after_disable,
    maximized_after_enable,
    minimized_after_disable,
    minimized_after_enable,
  }
  event_loop.run_app(app)
  assert_true(minimized_after_enable.val)
  assert_false(minimized_after_disable.val)
  assert_true(maximized_after_enable.val)
  assert_false(maximized_after_disable.val)
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
test "window visibility and resizable getters reflect runtime updates" {
  let event_loop = EventLoop::new()
  let visible_initial = Ref::new(true)
  let visible_after_enable = Ref::new(false)
  let visible_after_disable = Ref::new(true)
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
  assert_false(visible_initial.val)
  assert_true(visible_after_enable.val)
  assert_false(visible_after_disable.val)
  assert_true(resizable_initial.val)
  assert_false(resizable_after_disable.val)
  assert_true(resizable_after_enable.val)
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
  let resized = Ref::new(None)
  let surface_size = Ref::new(None)
  let window = Ref::new(None)
  let app : RequestSurfaceSizeApp = { resized, surface_size, window }
  event_loop.run_app(app)
  assert_eq(resized.val, Some(@dpi.PhysicalSize::new(1200, 900)))
  assert_eq(surface_size.val, Some(@dpi.PhysicalSize::new(1200, 900)))
}

///|
test "window min surface size clamps resize requests" {
  let event_loop = EventLoop::new()
  let resized = Ref::new(None)
  let surface_size = Ref::new(None)
  let window = Ref::new(None)
  let app : MinSurfaceSizeApp = { resized, surface_size, window }
  event_loop.run_app(app)
  assert_eq(resized.val, Some(@dpi.PhysicalSize::new(960, 720)))
  assert_eq(surface_size.val, Some(@dpi.PhysicalSize::new(960, 720)))
}

///|
test "window max surface size clamps resize requests" {
  let event_loop = EventLoop::new()
  let resized = Ref::new(None)
  let surface_size = Ref::new(None)
  let window = Ref::new(None)
  let app : MaxSurfaceSizeApp = { resized, surface_size, window }
  event_loop.run_app(app)
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
    text_with_all_modifiers: None,
    text_ignoring_modifiers: None,
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
    text_with_all_modifiers: None,
    text_ignoring_modifiers: None,
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
test "window ime configuration updates native state" {
  let event_loop = EventLoop::new()
  let initial_purpose = Ref::new(0)
  let window_id = Ref::new(0)
  let app : ImeConfigurationApp = { initial_purpose, window_id }
  event_loop.run_app(app)
  let raw_id = window_id.val
  assert_eq(initial_purpose.val, 1)
  assert_eq(ime_purpose_for_test(raw_id), 2)
  assert_false(ime_allowed_for_test(raw_id))
  assert_eq(ime_cursor_area_x_for_test(raw_id), 48)
  assert_eq(ime_cursor_area_y_for_test(raw_id), 96)
  assert_eq(ime_cursor_area_width_for_test(raw_id), 20)
  assert_eq(ime_cursor_area_height_for_test(raw_id), 32)
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
  let window = Ref::new(None)
  let current_occluded = Ref::new(None)
  let occluded = Ref::new(None)
  event_loop.run_app({ window, current_occluded, occluded })
  assert_eq(occluded.val, Some(true))
  assert_eq(current_occluded.val, Some(true))
}

///|
test "destroyed is delivered when the event loop exits" {
  let event_loop = EventLoop::new()
  let destroyed_seen = Ref::new(false)
  event_loop.run_app({ destroyed_seen, })
  assert_true(destroyed_seen.val)
}
