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
