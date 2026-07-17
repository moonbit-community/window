///|
test "initial_window_surface_size_prefers_surface_size" {
  let surface = Some(@dpi.Size::from_physical(PhysicalSize(1024, 768)))
  assert_eq(
    initial_window_surface_size(surface, 2.0),
    LogicalSize(512.0, 384.0),
  )
}

///|
test "initial_window_surface_size_falls_back_to_default" {
  assert_eq(initial_window_surface_size(None, 1.5), LogicalSize(800.0, 600.0))
}

///|
test "initial_window_position_is_applied_only_without_fullscreen" {
  assert_true(should_apply_initial_window_position(None))

  let monitor = @core.MonitorHandle::MonitorHandle(
    (1 : Int).to_uint64(),
    None,
    PhysicalPosition(0, 0),
    PhysicalSize(1920, 1080),
    2.0,
    None,
    [],
  )
  let video_mode = @core.VideoMode::VideoMode(
    PhysicalSize(1920, 1080),
    Some(32),
    Some(60000),
  )
  assert_false(should_apply_initial_window_position(Some(Borderless(None))))
  assert_false(
    should_apply_initial_window_position(Some(Exclusive(monitor, video_mode))),
  )
}

///|
test "initial_window_is_centered_when_explicit_position_is_missing" {
  assert_true(should_center_initial_window(None))
  assert_false(
    should_center_initial_window(
      Some(@dpi.LogicalPosition::LogicalPosition(12.0, 34.0).into_position()),
    ),
  )
}

///|
test "window_position_to_logical_preserves_logical_input" {
  let logical = window_position_to_logical(
    @dpi.LogicalPosition::LogicalPosition(40.0, 25.0).into_position(),
    2.0,
  )
  assert_eq(logical, LogicalPosition(40.0, 25.0))
}

///|
test "window_position_to_logical_converts_physical_input" {
  let logical = window_position_to_logical(
    @dpi.PhysicalPosition::PhysicalPosition(80, 50).into_position(),
    2.0,
  )
  assert_eq(logical, LogicalPosition(40.0, 25.0))
}

///|
test "physical_outer_position_to_logical_converts_physical_input" {
  let logical = physical_outer_position_to_logical(
    PhysicalPosition(120, 64),
    2.0,
  )
  assert_eq(logical, LogicalPosition(60.0, 32.0))
}

///|
test "monitor_position_to_logical_uses_monitor_scale_factor" {
  let monitor = @core.MonitorHandle::MonitorHandle(
    (9 : Int).to_uint64(),
    Some("scaled"),
    PhysicalPosition(3840, 0),
    PhysicalSize(3840, 2160),
    2.0,
    None,
    [],
  )
  assert_eq(monitor_position_to_logical(monitor), LogicalPosition(1920.0, 0.0))
}

///|
test "fullscreen_target_surface_size_prefers_target_monitor" {
  let primary = @core.MonitorHandle::MonitorHandle(
    (1 : Int).to_uint64(),
    Some("primary"),
    PhysicalPosition(0, 0),
    PhysicalSize(2560, 1440),
    2.0,
    None,
    [],
  )
  let external = @core.MonitorHandle::MonitorHandle(
    (2 : Int).to_uint64(),
    Some("external"),
    PhysicalPosition(2560, 0),
    PhysicalSize(3840, 2160),
    2.0,
    None,
    [],
  )
  let mode = @core.VideoMode::VideoMode(
    PhysicalSize(3840, 2160),
    Some(32),
    Some(60000),
  )

  assert_true(
    fullscreen_target_surface_size(
      Some(Borderless(Some(external))),
      Some(primary),
    ) ==
    Some(LogicalSize(1920.0, 1080.0)),
  )
  assert_true(
    fullscreen_target_surface_size(
      Some(Exclusive(external, mode)),
      Some(primary),
    ) ==
    Some(LogicalSize(1920.0, 1080.0)),
  )
}

///|
test "fullscreen_target_surface_size_falls_back_to_primary_monitor" {
  let primary = @core.MonitorHandle::MonitorHandle(
    (1 : Int).to_uint64(),
    Some("primary"),
    PhysicalPosition(0, 0),
    PhysicalSize(3000, 2000),
    2.0,
    None,
    [],
  )

  assert_true(
    fullscreen_target_surface_size(Some(Borderless(None)), Some(primary)) ==
    Some(LogicalSize(1500.0, 1000.0)),
  )
  assert_true(fullscreen_target_surface_size(None, Some(primary)) == None)
  assert_true(
    fullscreen_target_surface_size(Some(Borderless(None)), None) == None,
  )
}
