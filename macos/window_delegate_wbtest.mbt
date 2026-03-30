///|
test "initial_window_surface_size_prefers_surface_size" {
  let surface = Some(
    @dpi.Size::from_physical(@dpi.PhysicalSize::new(1024, 768)),
  )
  assert_eq(
    initial_window_surface_size(surface, 2.0),
    @dpi.LogicalSize::new(512.0, 384.0),
  )
}

///|
test "initial_window_surface_size_falls_back_to_default" {
  assert_eq(
    initial_window_surface_size(None, 1.5),
    @dpi.LogicalSize::new(800.0, 600.0),
  )
}

///|
test "initial_window_position_is_applied_only_without_fullscreen" {
  assert_true(should_apply_initial_window_position(None))

  let monitor = @core.MonitorHandle::new(
    (1 : Int).to_uint64(),
    None,
    @dpi.PhysicalPosition::new(0, 0),
    @dpi.PhysicalSize::new(1920, 1080),
    2.0,
    None,
    [],
  )
  let video_mode = @core.VideoMode::new(
    @dpi.PhysicalSize::new(1920, 1080),
    Some(32),
    Some(60000),
  )
  assert_false(
    should_apply_initial_window_position(
      Some(@core.Fullscreen::Borderless(None)),
    ),
  )
  assert_false(
    should_apply_initial_window_position(
      Some(@core.Fullscreen::Exclusive(monitor, video_mode)),
    ),
  )
}

///|
test "initial_window_is_centered_when_explicit_position_is_missing" {
  assert_true(should_center_initial_window(None))
  assert_false(
    should_center_initial_window(
      Some(@dpi.LogicalPosition::new(12.0, 34.0).into_position()),
    ),
  )
}

///|
test "window_position_to_logical_preserves_logical_input" {
  let logical = window_position_to_logical(
    @dpi.LogicalPosition::new(40.0, 25.0).into_position(),
    2.0,
  )
  assert_eq(logical, @dpi.LogicalPosition::new(40.0, 25.0))
}

///|
test "window_position_to_logical_converts_physical_input" {
  let logical = window_position_to_logical(
    @dpi.PhysicalPosition::new(80, 50).into_position(),
    2.0,
  )
  assert_eq(logical, @dpi.LogicalPosition::new(40.0, 25.0))
}

///|
test "physical_outer_position_to_logical_converts_physical_input" {
  let logical = physical_outer_position_to_logical(
    @dpi.PhysicalPosition::new(120, 64),
    2.0,
  )
  assert_eq(logical, @dpi.LogicalPosition::new(60.0, 32.0))
}

///|
test "monitor_position_to_logical_uses_monitor_scale_factor" {
  let monitor = @core.MonitorHandle::new(
    (9 : Int).to_uint64(),
    Some("scaled"),
    @dpi.PhysicalPosition::new(3840, 0),
    @dpi.PhysicalSize::new(3840, 2160),
    2.0,
    None,
    [],
  )
  assert_eq(
    monitor_position_to_logical(monitor),
    @dpi.LogicalPosition::new(1920.0, 0.0),
  )
}

///|
test "fullscreen_target_surface_size_prefers_target_monitor" {
  let primary = @core.MonitorHandle::new(
    (1 : Int).to_uint64(),
    Some("primary"),
    @dpi.PhysicalPosition::new(0, 0),
    @dpi.PhysicalSize::new(2560, 1440),
    2.0,
    None,
    [],
  )
  let external = @core.MonitorHandle::new(
    (2 : Int).to_uint64(),
    Some("external"),
    @dpi.PhysicalPosition::new(2560, 0),
    @dpi.PhysicalSize::new(3840, 2160),
    2.0,
    None,
    [],
  )
  let mode = @core.VideoMode::new(
    @dpi.PhysicalSize::new(3840, 2160),
    Some(32),
    Some(60000),
  )

  assert_eq(
    fullscreen_target_surface_size(
      Some(@core.Fullscreen::Borderless(Some(external))),
      Some(primary),
    ),
    Some(@dpi.LogicalSize::new(1920.0, 1080.0)),
  )
  assert_eq(
    fullscreen_target_surface_size(
      Some(@core.Fullscreen::Exclusive(external, mode)),
      Some(primary),
    ),
    Some(@dpi.LogicalSize::new(1920.0, 1080.0)),
  )
}

///|
test "fullscreen_target_surface_size_falls_back_to_primary_monitor" {
  let primary = @core.MonitorHandle::new(
    (1 : Int).to_uint64(),
    Some("primary"),
    @dpi.PhysicalPosition::new(0, 0),
    @dpi.PhysicalSize::new(3000, 2000),
    2.0,
    None,
    [],
  )

  assert_eq(
    fullscreen_target_surface_size(
      Some(@core.Fullscreen::Borderless(None)),
      Some(primary),
    ),
    Some(@dpi.LogicalSize::new(1500.0, 1000.0)),
  )
  assert_eq(fullscreen_target_surface_size(None, Some(primary)), None)
  assert_eq(
    fullscreen_target_surface_size(
      Some(@core.Fullscreen::Borderless(None)),
      None,
    ),
    None,
  )
}

///|
test "ime_cursor_area_state_tracks_position_and_clamps_size" {
  let handle = (91 : Int).to_uint64()
  set_window_ime_cursor_area_state(handle, 12, 34, 0, -5)

  assert_eq(window_ime_cursor_x_state(handle), 12)
  assert_eq(window_ime_cursor_y_state(handle), 34)
  assert_eq(window_ime_cursor_width_state(handle), 1)
  assert_eq(window_ime_cursor_height_state(handle), 1)
}

///|
test "ime_cursor_area_state_preserves_positive_size" {
  let handle = (92 : Int).to_uint64()
  set_window_ime_cursor_area_state(handle, 7, 8, 21, 22)

  assert_eq(window_ime_cursor_x_state(handle), 7)
  assert_eq(window_ime_cursor_y_state(handle), 8)
  assert_eq(window_ime_cursor_width_state(handle), 21)
  assert_eq(window_ime_cursor_height_state(handle), 22)
}

///|
test "dragging_info_has_paths_rejects_null_handle" {
  assert_false(dragging_info_has_paths((0 : Int).to_uint64()))
}

///|
test "native_drag_should_accept_rejects_null_handle" {
  assert_false(native_drag_should_accept(1, (0 : Int).to_uint64()))
}

///|
test "logical_position_f64_to_physical_applies_scale_factor" {
  assert_eq(
    logical_position_f64_to_physical(10.5, 20.25, 2.0),
    @dpi.PhysicalPositionF64::new(21.0, 40.5),
  )
}

///|
test "logical_position_f64_to_physical_falls_back_to_identity_scale" {
  assert_eq(
    logical_position_f64_to_physical(3.25, 4.5, 0.0),
    @dpi.PhysicalPositionF64::new(3.25, 4.5),
  )
  assert_eq(
    logical_position_f64_to_physical(3.25, 4.5, -2.0),
    @dpi.PhysicalPositionF64::new(3.25, 4.5),
  )
}

///|
test "flip_window_screen_coordinate_y_is_symmetric" {
  let logical_y = 128.0
  let frame_height = 320.0
  let appkit_y = flip_window_screen_coordinate_y(logical_y, frame_height)
  assert_eq(flip_window_screen_coordinate_y(appkit_y, frame_height), logical_y)
}

///|
test "window_surface_offset_y_from_frame_and_content_matches_expected" {
  assert_eq(
    window_surface_offset_y_from_frame_and_content(100.0, 600.0, 120.0, 560.0),
    20.0,
  )
}

///|
test "cursor_screen_y_from_content_rect_matches_top_edge_at_zero_offset" {
  let content_y = 120.0
  let content_height = 560.0
  assert_eq(
    cursor_screen_y_from_content_rect(content_y, content_height, 0),
    flip_window_screen_coordinate_y(content_y, content_height),
  )
}

///|
test "cursor_screen_y_from_content_rect_increases_with_cursor_offset" {
  let content_y = 120.0
  let content_height = 560.0
  let base = cursor_screen_y_from_content_rect(content_y, content_height, 0)
  let moved = cursor_screen_y_from_content_rect(content_y, content_height, 37)
  assert_eq(moved - base, 37.0)
}

///|
test "accepts_first_mouse_state_defaults_to_false_and_tracks_updates" {
  let handle = (94 : Int).to_uint64()

  assert_false(window_accepts_first_mouse_state(handle))

  set_window_accepts_first_mouse_state(handle, true)
  assert_true(window_accepts_first_mouse_state(handle))
}

///|
test "cursor_visible_state_defaults_to_true_and_tracks_updates" {
  let handle = (95 : Int).to_uint64()

  assert_true(window_cursor_visible_state(handle))

  set_window_cursor_visible_state(handle, false)
  assert_false(window_cursor_visible_state(handle))

  set_window_cursor_visible_state(handle, true)
  assert_true(window_cursor_visible_state(handle))
}

///|
test "clear_window_platform_state_resets_cursor_visible_state" {
  let handle = (96 : Int).to_uint64()

  set_window_cursor_visible_state(handle, false)
  assert_false(window_cursor_visible_state(handle))

  clear_window_platform_state(handle)
  assert_true(window_cursor_visible_state(handle))
}
