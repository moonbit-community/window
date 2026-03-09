///|
test "window attributes follow winit defaults" {
  let attrs = WindowAttributes::default()
  assert_eq(attrs.title(), "winit window")
  assert_true(attrs.visible())
  assert_true(attrs.resizable())
  assert_true(attrs.active())
  assert_true(attrs.decorations())
  assert_eq(attrs.surface_size(), Some(@dpi.PhysicalSize::new(800, 600)))
  assert_eq(attrs.min_surface_size(), None)
  assert_eq(attrs.max_surface_size(), None)
  assert_eq(attrs.position(), None)
  assert_eq(attrs.ime_purpose(), ImePurpose::Normal)
}

///|
test "window attributes builders update fields" {
  let attrs = WindowAttributes::default()
    .with_title("hello")
    .with_visible(false)
    .with_resizable(false)
    .with_surface_size(@dpi.PhysicalSize::new(1024, 768))
    .with_min_surface_size(Some(@dpi.PhysicalSize::new(640, 480)))
    .with_max_surface_size(Some(@dpi.PhysicalSize::new(1920, 1080)))
    .with_position(Some(@dpi.PhysicalPosition::new(320, 180)))
    .with_ime_purpose(ImePurpose::Password)
    .with_active(false)
    .with_decorations(false)
  assert_eq(attrs.title(), "hello")
  assert_false(attrs.visible())
  assert_false(attrs.resizable())
  assert_false(attrs.active())
  assert_false(attrs.decorations())
  assert_eq(attrs.surface_size(), Some(@dpi.PhysicalSize::new(1024, 768)))
  assert_eq(attrs.min_surface_size(), Some(@dpi.PhysicalSize::new(640, 480)))
  assert_eq(attrs.max_surface_size(), Some(@dpi.PhysicalSize::new(1920, 1080)))
  assert_eq(attrs.position(), Some(@dpi.PhysicalPosition::new(320, 180)))
  assert_eq(attrs.ime_purpose(), ImePurpose::Password)
}
