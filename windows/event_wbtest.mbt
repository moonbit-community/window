///|
struct RecordingApp {
  events : Array[@core.WindowEvent]
}

///|
pub impl ApplicationHandler for RecordingApp with fn window_event(
  self,
  _event_loop,
  _window_id,
  event,
) {
  self.events.push(event)
}

///|
fn reset_event_test_state() -> Unit {
  app_state_runtime.val = AppStateRuntime::new()
  event_loop_global_created.val = false
  window_mouse_tracking.val = []
  windows_pending_high_surrogates.val = []
}

///|
fn test_active_loop() -> ActiveEventLoop {
  { inner: { msg_window: 0UL, thread_id: 0 } }
}

///|
fn begin_recording() -> RecordingApp {
  reset_event_test_state()
  let app = { events: [] }
  app_state_set_running(true)
  app_state_set_dispatch_handler(app, test_active_loop())
  app
}

///|
fn register_input_test_window(raw_id : Int) -> Unit {
  app_state_register_window_handle(raw_id, 77UL)
}

///|
fn lparam_position(x : Int, y : Int) -> Int64 {
  ((y << 16) | (x & 0xFFFF)).to_int64()
}

///|
fn lparam_key(scan_code : Int, extended : Bool) -> Int64 {
  let extended_bit = if extended { 1 << 24 } else { 0 }
  ((scan_code << 16) | extended_bit).to_int64()
}

///|
fn assert_keyboard_event(
  event : @core.WindowEvent,
  expected_key : String,
  expected_state : @core.ElementState,
  expected_synthetic : Bool,
) -> Unit raise {
  match event {
    KeyboardInput(_, key_event, synthetic) => {
      assert_eq(synthetic, expected_synthetic)
      assert_eq(key_event.state(), expected_state)
      match key_event.logical_key() {
        Character(key) => inspect(key, content=expected_key)
        _ => fail("expected character logical key")
      }
    }
    _ => fail("expected keyboard input")
  }
}

///|
test "windows dispatch maps resize scale pointer keyboard ime and redraw" {
  let app = begin_recording()
  let raw_id = 42
  register_input_test_window(raw_id)
  dispatch_native_window_event(3, raw_id, 320, 200, 0, 0.0)
  dispatch_native_window_event(40, raw_id, 400, 240, 0, 1.5)
  dispatch_native_input_event(raw_id, 10, 0UL, lparam_position(12, 34))
  dispatch_native_input_event(raw_id, 12, 0UL, lparam_position(12, 34))
  dispatch_native_input_event(raw_id, 30, 0x41UL, 0L)
  dispatch_native_input_event(raw_id, 31, 0x41UL, 0L)
  dispatch_native_input_event(raw_id, 34, 0x61UL, 0L)
  app_state_queue_redraw(raw_id)
  app_state_queue_redraw(raw_id)
  app_state_dispatch_redraws()
  assert_eq(app.events.length(), 11)
  match app.events[0] {
    SurfaceResized(size) => {
      assert_eq(size.width(), 320)
      assert_eq(size.height(), 200)
    }
    _ => fail("expected surface resize")
  }
  match app.events[1] {
    ScaleFactorChanged(scale, writer) => {
      assert_eq(scale, 1.5)
      assert_eq(writer.surface_size(), PhysicalSize(400, 240))
    }
    _ => fail("expected scale factor change")
  }
  match app.events[2] {
    PointerEntered(_, position, false, Mouse) => {
      assert_eq(position.x(), 12.0)
      assert_eq(position.y(), 34.0)
    }
    _ => fail("expected pointer entered")
  }
  match app.events[3] {
    PointerMoved(_, position, false, Mouse) => {
      assert_eq(position.x(), 12.0)
      assert_eq(position.y(), 34.0)
    }
    _ => fail("expected pointer moved")
  }
  match app.events[4] {
    PointerButton(_, Pressed, position, false, Mouse(Left)) => {
      assert_eq(position.x(), 12.0)
      assert_eq(position.y(), 34.0)
    }
    _ => fail("expected left pointer press")
  }
  assert_keyboard_event(app.events[5], "a", Pressed, false)
  assert_true(app.events[6] is ModifiersChanged(_))
  assert_keyboard_event(app.events[7], "a", Released, false)
  assert_true(app.events[8] is ModifiersChanged(_))
  match app.events[9] {
    Ime(Commit(text)) => inspect(text, content="a")
    _ => fail("expected ime commit")
  }
  assert_true(app.events[10] is RedrawRequested)
}

///|
test "windows dispatch suppresses minimized and invalid resize events" {
  let app = begin_recording()
  let raw_id = 7
  register_input_test_window(raw_id)
  dispatch_native_window_event(3, raw_id, 0, 200, 0, 0.0)
  dispatch_native_window_event(3, raw_id, 320, 200, size_minimized, 0.0)
  dispatch_native_window_event(40, raw_id, 0, 240, 0, 1.5)
  assert_eq(app.events.length(), 0)
}

///|
test "windows dispatch ignores invalid raw ids" {
  let app = begin_recording()
  dispatch_native_window_event(3, 0, 320, 200, 0, 0.0)
  dispatch_native_window_event(5, 0, 0, 0, 0, 0.0)
  dispatch_native_window_event(40, 0, 400, 240, 0, 1.5)
  dispatch_native_input_event(0, 10, 0UL, lparam_position(12, 34))
  dispatch_native_input_event(0, 34, 0xD83DUL, 0L)
  app_state_dispatch_redraws()
  assert_eq(app.events.length(), 0)
  assert_false(is_mouse_tracking(0))
  assert_true(pending_windows_high_surrogate(0) == None)
  assert_eq(dispatch_native_sync_query(0, 10, 0), 0)
}

///|
test "windows input dispatch ignores unregistered windows" {
  let app = begin_recording()
  let raw_id = 17
  dispatch_native_input_event(raw_id, 10, 0UL, lparam_position(12, 34))
  dispatch_native_input_event(raw_id, 34, 0xD83DUL, 0L)
  assert_eq(app.events.length(), 0)
  assert_false(is_mouse_tracking(raw_id))
  assert_true(pending_windows_high_surrogate(raw_id) == None)
}

///|
test "windows window dispatch ignores unregistered windows" {
  let app = begin_recording()
  let raw_id = 18
  dispatch_native_window_event(3, raw_id, 320, 200, 0, 0.0)
  dispatch_native_window_event(4, raw_id, 12, 34, 0, 0.0)
  dispatch_native_window_event(6, raw_id, 0, 0, 0, 0.0)
  dispatch_native_window_event(40, raw_id, 400, 240, 0, 1.5)
  dispatch_native_window_event(2, raw_id, 0, 0, 0, 0.0)
  assert_eq(app.events.length(), 0)
}

///|
test "windows focus loss emits empty modifiers" {
  let app = begin_recording()
  let raw_id = 8
  register_input_test_window(raw_id)
  dispatch_native_window_event(6, raw_id, 0, 0, 0, 0.0)
  assert_eq(app.events.length(), 2)
  assert_true(app.events[0] is Focused(false))
  match app.events[1] {
    ModifiersChanged(modifiers) => assert_true(modifiers.is_empty())
    _ => fail("expected empty modifiers after focus loss")
  }
}

///|
test "windows dispatch normalizes invalid scale change factors" {
  let app = begin_recording()
  let raw_id = 8
  register_input_test_window(raw_id)
  dispatch_native_window_event(40, raw_id, 400, 240, 0, 0.0)
  dispatch_native_window_event(40, raw_id, 400, 240, 0, 0.0 / 0.0)
  dispatch_native_window_event(40, raw_id, 400, 240, 0, 1.0 / 0.0)
  assert_eq(app.events.length(), 3)
  for event in app.events {
    match event {
      ScaleFactorChanged(scale, writer) => {
        assert_eq(scale, 1.0)
        assert_eq(writer.surface_size(), PhysicalSize(400, 240))
      }
      _ => fail("expected normalized scale factor change")
    }
  }
}

///|
test "windows dispatch maps signed pointer leave coordinates" {
  let app = begin_recording()
  let raw_id = 9
  register_input_test_window(raw_id)
  dispatch_native_input_event(raw_id, 11, 0UL, lparam_position(65531, 65526))
  assert_eq(app.events.length(), 1)
  match app.events[0] {
    PointerLeft(_, Some(position), false, Mouse) => {
      assert_eq(position.x(), -5.0)
      assert_eq(position.y(), -10.0)
    }
    _ => fail("expected pointer left with signed coordinates")
  }
}

///|
test "windows dispatch maps signed pointer move and button coordinates" {
  let app = begin_recording()
  let raw_id = 10
  register_input_test_window(raw_id)
  dispatch_native_input_event(raw_id, 10, 0UL, lparam_position(65531, 65526))
  dispatch_native_input_event(raw_id, 12, 0UL, lparam_position(65531, 65526))
  assert_eq(app.events.length(), 3)
  match app.events[0] {
    PointerEntered(_, position, false, Mouse) => {
      assert_eq(position.x(), -5.0)
      assert_eq(position.y(), -10.0)
    }
    _ => fail("expected pointer entered with signed coordinates")
  }
  match app.events[1] {
    PointerMoved(_, position, false, Mouse) => {
      assert_eq(position.x(), -5.0)
      assert_eq(position.y(), -10.0)
    }
    _ => fail("expected pointer moved with signed coordinates")
  }
  match app.events[2] {
    PointerButton(_, Pressed, position, false, Mouse(Left)) => {
      assert_eq(position.x(), -5.0)
      assert_eq(position.y(), -10.0)
    }
    _ => fail("expected pointer button with signed coordinates")
  }
}

///|
test "windows dispatch ignores invalid wm char code units" {
  let app = begin_recording()
  let raw_id = 11
  register_input_test_window(raw_id)
  dispatch_native_input_event(raw_id, 34, 0x1FUL, 0L)
  dispatch_native_input_event(raw_id, 34, 0x7FUL, 0L)
  dispatch_native_input_event(raw_id, 34, 0xD800UL, 0L)
  dispatch_native_input_event(raw_id, 34, 0x110000UL, 0L)
  dispatch_native_input_event(raw_id, 34, 0x61UL, 0L)
  assert_eq(app.events.length(), 1)
  match app.events[0] {
    Ime(Commit(text)) => inspect(text, content="a")
    _ => fail("expected valid ime commit")
  }
}

///|
test "windows dispatch combines wm char surrogate pairs" {
  let app = begin_recording()
  let raw_id = 12
  register_input_test_window(raw_id)
  dispatch_native_input_event(raw_id, 34, 0xD83DUL, 0L)
  assert_eq(app.events.length(), 0)
  dispatch_native_input_event(raw_id, 34, 0xDE00UL, 0L)
  assert_eq(app.events.length(), 1)
  match app.events[0] {
    Ime(Commit(text)) => inspect(text, content="\u{1f600}")
    _ => fail("expected surrogate pair ime commit")
  }
}

///|
test "windows dispatch keeps wm char high surrogates per window" {
  let app = begin_recording()
  register_input_test_window(12)
  register_input_test_window(13)
  dispatch_native_input_event(12, 34, 0xD83DUL, 0L)
  dispatch_native_input_event(13, 34, 0xDE00UL, 0L)
  dispatch_native_input_event(12, 34, 0xDE00UL, 0L)
  assert_eq(app.events.length(), 1)
  match app.events[0] {
    Ime(Commit(text)) => inspect(text, content="\u{1f600}")
    _ => fail("expected same-window surrogate pair ime commit")
  }
}

///|
test "windows destroyed clears pending input state" {
  let app = begin_recording()
  let raw_id = 14
  register_input_test_window(raw_id)
  dispatch_native_input_event(raw_id, 10, 0UL, lparam_position(12, 34))
  dispatch_native_input_event(raw_id, 34, 0xD83DUL, 0L)
  app_state_queue_redraw(raw_id)
  assert_true(is_mouse_tracking(raw_id))
  assert_true(pending_windows_high_surrogate(raw_id) is Some(_))
  assert_true(app_state_window_handle(raw_id) is Some(_))
  assert_eq(app_state_runtime.val.pending_redraw_window_ids.length(), 1)
  dispatch_native_window_event(2, raw_id, 0, 0, 0, 0.0)
  assert_false(is_mouse_tracking(raw_id))
  assert_true(pending_windows_high_surrogate(raw_id) == None)
  assert_true(app_state_window_handle(raw_id) == None)
  assert_eq(app_state_runtime.val.pending_redraw_window_ids.length(), 0)
  dispatch_native_input_event(raw_id, 34, 0xDE00UL, 0L)
  dispatch_native_input_event(raw_id, 10, 0UL, lparam_position(15, 35))
  dispatch_native_window_event(3, raw_id, 400, 240, 0, 0.0)
  dispatch_native_window_event(6, raw_id, 0, 0, 0, 0.0)
  assert_eq(app.events.length(), 3)
  assert_true(app.events[0] is PointerEntered(_, _, _, _))
  assert_true(app.events[1] is PointerMoved(_, _, _, _))
  assert_true(app.events[2] is Destroyed)
  app_state_dispatch_redraws()
  assert_eq(app.events.length(), 3)
}

///|
test "windows window runtime cleanup clears input handle and redraws" {
  let app = begin_recording()
  let raw_id = 15
  register_input_test_window(raw_id)
  dispatch_native_input_event(raw_id, 10, 0UL, lparam_position(12, 34))
  dispatch_native_input_event(raw_id, 34, 0xD83DUL, 0L)
  app_state_queue_redraw(raw_id)
  assert_true(is_mouse_tracking(raw_id))
  assert_true(pending_windows_high_surrogate(raw_id) is Some(_))
  assert_true(app_state_window_handle(raw_id) is Some(_))
  assert_eq(app_state_runtime.val.pending_redraw_window_ids.length(), 1)
  app_state_clear_window_runtime_state(raw_id)
  assert_false(is_mouse_tracking(raw_id))
  assert_true(pending_windows_high_surrogate(raw_id) == None)
  assert_true(app_state_window_handle(raw_id) == None)
  assert_eq(app_state_runtime.val.pending_redraw_window_ids.length(), 0)
  app_state_dispatch_redraws()
  assert_eq(app.events.length(), 2)
}

///|
test "windows redraw queue ignores unregistered windows" {
  let app = begin_recording()
  let raw_id = 16
  app_state_queue_redraw(raw_id)
  assert_eq(app_state_runtime.val.pending_redraw_window_ids.length(), 0)
  register_input_test_window(raw_id)
  app_state_queue_redraw(raw_id)
  assert_eq(app_state_runtime.val.pending_redraw_window_ids.length(), 1)
  app_state_clear_window_runtime_state(raw_id)
  app_state_queue_redraw(raw_id)
  assert_eq(app_state_runtime.val.pending_redraw_window_ids.length(), 0)
  app_state_dispatch_redraws()
  assert_eq(app.events.length(), 0)
}

///|
test "windows event loop drop cleanup clears app state windows input and redraws" {
  let app = begin_recording()
  let first_id = 17
  let second_id = 18
  register_input_test_window(first_id)
  register_input_test_window(second_id)
  dispatch_native_input_event(first_id, 10, 0UL, lparam_position(12, 34))
  dispatch_native_input_event(first_id, 34, 0xD83DUL, 0L)
  dispatch_native_input_event(second_id, 10, 0UL, lparam_position(15, 35))
  dispatch_native_input_event(second_id, 34, 0xD83DUL, 0L)
  app_state_queue_redraw(first_id)
  app_state_queue_redraw(second_id)
  assert_true(is_mouse_tracking(first_id))
  assert_true(is_mouse_tracking(second_id))
  assert_true(pending_windows_high_surrogate(first_id) is Some(_))
  assert_true(pending_windows_high_surrogate(second_id) is Some(_))
  assert_true(app_state_window_handle(first_id) is Some(_))
  assert_true(app_state_window_handle(second_id) is Some(_))
  assert_eq(app_state_runtime.val.pending_redraw_window_ids.length(), 2)
  app_state_clear_all_window_runtime_state()
  assert_false(is_mouse_tracking(first_id))
  assert_false(is_mouse_tracking(second_id))
  assert_true(pending_windows_high_surrogate(first_id) == None)
  assert_true(pending_windows_high_surrogate(second_id) == None)
  assert_true(app_state_window_handle(first_id) == None)
  assert_true(app_state_window_handle(second_id) == None)
  assert_eq(app_state_runtime.val.pending_redraw_window_ids.length(), 0)
  dispatch_native_input_event(first_id, 10, 0UL, lparam_position(20, 30))
  dispatch_native_window_event(5, second_id, 0, 0, 0, 0.0)
  app_state_dispatch_redraws()
  assert_eq(app.events.length(), 4)
}

///|
test "windows modifiers preserve right-side keys and meta state" {
  let states : WindowsModifierKeyStates = {
    shift: false,
    lshift: false,
    rshift: true,
    control: false,
    lcontrol: false,
    rcontrol: true,
    alt: false,
    lalt: false,
    ralt: true,
    lmeta: true,
    rmeta: false,
  }
  let modifiers = windows_modifiers_from_key_states(states)
  assert_true(modifiers.shift_key())
  assert_true(modifiers.control_key())
  assert_true(modifiers.alt_key())
  assert_true(modifiers.meta_key())
  assert_true(modifiers.lshift_state() is Unknown)
  assert_true(modifiers.rshift_state() is Pressed)
  assert_true(modifiers.lcontrol_state() is Unknown)
  assert_true(modifiers.rcontrol_state() is Pressed)
  assert_true(modifiers.lalt_state() is Unknown)
  assert_true(modifiers.ralt_state() is Pressed)
  assert_true(modifiers.lsuper_state() is Pressed)
  assert_true(modifiers.rsuper_state() is Unknown)
}

///|
test "windows modifiers keep generic family state without fabricating side" {
  let states : WindowsModifierKeyStates = {
    shift: true,
    lshift: false,
    rshift: false,
    control: true,
    lcontrol: false,
    rcontrol: false,
    alt: true,
    lalt: false,
    ralt: false,
    lmeta: false,
    rmeta: false,
  }
  let modifiers = windows_modifiers_from_key_states(states)
  assert_true(modifiers.shift_key())
  assert_true(modifiers.control_key())
  assert_true(modifiers.alt_key())
  assert_false(modifiers.meta_key())
  assert_true(modifiers.lshift_state() is Unknown)
  assert_true(modifiers.rshift_state() is Unknown)
  assert_true(modifiers.lcontrol_state() is Unknown)
  assert_true(modifiers.rcontrol_state() is Unknown)
  assert_true(modifiers.lalt_state() is Unknown)
  assert_true(modifiers.ralt_state() is Unknown)
}

///|
test "windows key mapping uses lparam side information" {
  let right_shift_lparam = lparam_key(0x36, false)
  let left_shift_lparam = lparam_key(0x2A, false)
  let right_control_lparam = lparam_key(0x1D, true)
  let left_control_lparam = lparam_key(0x1D, false)
  let right_alt_lparam = lparam_key(0x38, true)
  let numpad_enter_lparam = lparam_key(0x1C, true)
  assert_eq(
    vk_to_physical_key(0x10, right_shift_lparam),
    @core.PhysicalKey::from_key_code(ShiftRight),
  )
  assert_eq(vk_to_key_location(0x10, right_shift_lparam), Right)
  assert_eq(
    vk_to_physical_key(0x10, left_shift_lparam),
    @core.PhysicalKey::from_key_code(ShiftLeft),
  )
  assert_eq(vk_to_key_location(0x10, left_shift_lparam), Left)
  assert_eq(
    vk_to_physical_key(0x11, right_control_lparam),
    @core.PhysicalKey::from_key_code(ControlRight),
  )
  assert_eq(vk_to_key_location(0x11, right_control_lparam), Right)
  assert_eq(
    vk_to_physical_key(0x11, left_control_lparam),
    @core.PhysicalKey::from_key_code(ControlLeft),
  )
  assert_eq(vk_to_key_location(0x11, left_control_lparam), Left)
  assert_eq(
    vk_to_physical_key(0x12, right_alt_lparam),
    @core.PhysicalKey::from_key_code(AltRight),
  )
  assert_eq(vk_to_key_location(0x12, right_alt_lparam), Right)
  assert_eq(
    vk_to_physical_key(0x5C, 0L),
    @core.PhysicalKey::from_key_code(MetaRight),
  )
  assert_eq(vk_to_logical_key(0x5B, @core.Modifiers::default()), Named(Meta))
  assert_eq(
    vk_to_physical_key(0x0D, numpad_enter_lparam),
    @core.PhysicalKey::from_key_code(NumpadEnter),
  )
  assert_eq(vk_to_key_location(0x0D, numpad_enter_lparam), Numpad)
}

///|
test "windows logical keys use shifted printable fallback" {
  let shifted : WindowsModifierKeyStates = {
    shift: true,
    lshift: false,
    rshift: false,
    control: false,
    lcontrol: false,
    rcontrol: false,
    alt: false,
    lalt: false,
    ralt: false,
    lmeta: false,
    rmeta: false,
  }
  let modifiers = windows_modifiers_from_key_states(shifted)
  assert_eq(vk_to_logical_key(0x41, modifiers), Character("A"))
  assert_eq(vk_to_key_without_modifiers(0x41), Character("a"))
  assert_eq(vk_to_logical_key(0x31, modifiers), Character("!"))
  assert_eq(vk_to_key_without_modifiers(0x31), Character("1"))
  assert_eq(vk_to_logical_key(0xBF, modifiers), Character("?"))
  assert_eq(vk_to_key_without_modifiers(0xBF), Character("/"))
}

///|
test "windows sync query requires a registered window handle" {
  reset_event_test_state()
  assert_eq(dispatch_native_sync_query(3, 10, 0), 0)
  app_state_register_window_handle(3, 99UL)
  assert_eq(dispatch_native_sync_query(3, 10, 0), 1)
}
