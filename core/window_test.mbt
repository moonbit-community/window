///|
test "window attributes follow winit defaults" {
  let attrs = WindowAttributes::default()
  assert_eq(attrs.title(), "winit window")
  assert_true(attrs.visible())
  assert_true(attrs.resizable())
  assert_eq(attrs.surface_size(), Some(@dpi.PhysicalSize::new(800, 600)))
}

///|
test "window attributes builders update fields" {
  let attrs = WindowAttributes::default()
    .with_title("hello")
    .with_visible(false)
    .with_resizable(false)
    .with_surface_size(@dpi.PhysicalSize::new(1024, 768))
  assert_eq(attrs.title(), "hello")
  assert_false(attrs.visible())
  assert_false(attrs.resizable())
  assert_eq(attrs.surface_size(), Some(@dpi.PhysicalSize::new(1024, 768)))
}
