///|
fn test_window_for_monitor(hwnd : UInt64) -> Window {
  {
    id: @core.WindowId::from_raw(1),
    hwnd,
    cursor_state: Icon(Default),
    fullscreen_state: None,
    ime_capabilities_state: None,
    ime_hints_state: @core.ImeHint::none(),
    ime_purpose_state: Normal,
    ime_surrounding_text_state: None,
    ime_cursor_area_position_state: PhysicalPosition(0, 0),
    ime_cursor_area_size_state: PhysicalSize(1, 1),
    is_decorated_state: true,
    is_maximized_state: false,
    is_visible_state: true,
    is_resizable_state: true,
    is_cursor_visible_state: true,
    is_cursor_hittest_state: true,
    is_transparent_state: false,
    is_blurred_state: false,
    saved_window_rect_left: 0,
    saved_window_rect_top: 0,
    saved_window_rect_right: 0,
    saved_window_rect_bottom: 0,
    saved_window_style: 0,
    saved_window_ex_style: 0,
  }
}

///|
fn reset_monitor_test_state() -> Unit {
  app_state_runtime.val = AppStateRuntime::new()
  event_loop_global_created.val = false
}

///|
test "windows monitor helpers do not fabricate missing monitors" {
  assert_true(monitor_from_native_id((0 : Int).to_uint64()) == None)
  assert_true(current_monitor_for_window((0 : Int).to_uint64()) == None)
}

///|
test "windows monitor helpers normalize invalid size and scale" {
  assert_true(windows_monitor_surface_size(0, -8) == PhysicalSize(1, 1))
  assert_true(windows_monitor_surface_size(1920, 0) == PhysicalSize(1920, 1))
  assert_eq(windows_monitor_scale_factor(1.25), 1.25)
  assert_eq(windows_monitor_scale_factor(0.0), 1.0)
  assert_eq(windows_monitor_scale_factor(-2.0), 1.0)
  assert_eq(windows_monitor_scale_factor(0.0 / 0.0), 1.0)
  assert_eq(windows_monitor_scale_factor(1.0 / 0.0), 1.0)
}

///|
test "windows dpi scale helper falls back for zero dpi" {
  assert_eq(windows_scale_factor_from_dpi(0), 1.0)
  assert_eq(windows_scale_factor_from_dpi(96), 1.0)
  assert_eq(windows_scale_factor_from_dpi(144), 1.5)
}

///|
test "windows window current monitor preserves none when native lookup is unavailable" {
  let window = test_window_for_monitor(1UL)
  reset_monitor_test_state()
  assert_true(window.current_monitor() == None)
  app_state_register_window_handle(1, 1UL)
  if native_enum_monitors() == 0 {
    assert_true(window.current_monitor() == None)
  }
}

///|
test "windows current monitor rejects invalid hwnd handles" {
  assert_true(current_monitor_for_window(1UL) == None)
}

///|
test "windows raw handle accessors preserve hwnd and do not fabricate display handle" {
  let window = test_window_for_monitor(7UL)
  let display = native_hinstance_handle()
  assert_eq(window.window_handle(), 7UL)
  assert_eq(window.rwh_06_window_handle(), 7UL)
  assert_eq(window.display_handle(), display)
  assert_eq(window.rwh_06_display_handle(), display)
}
