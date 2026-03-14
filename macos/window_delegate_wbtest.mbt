///|
test "initial_window_surface_size_prefers_surface_size" {
  let surface = Some(
    @dpi.Size::from_physical(@dpi.PhysicalSize::new(1024, 768)),
  )
  let inner = Some(@dpi.Size::from_logical(@dpi.LogicalSize::new(320.0, 200.0)))
  assert_eq(
    initial_window_surface_size(surface, inner, 2.0),
    @dpi.LogicalSize::new(512.0, 384.0),
  )
}

///|
test "initial_window_surface_size_uses_inner_size_when_surface_size_missing" {
  let inner = Some(@dpi.Size::from_logical(@dpi.LogicalSize::new(512.0, 384.0)))
  assert_eq(
    initial_window_surface_size(None, inner, 2.0),
    @dpi.LogicalSize::new(512.0, 384.0),
  )
}

///|
test "initial_window_surface_size_falls_back_to_default" {
  assert_eq(
    initial_window_surface_size(None, None, 1.5),
    @dpi.LogicalSize::new(800.0, 600.0),
  )
}
