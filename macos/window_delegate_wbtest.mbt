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
