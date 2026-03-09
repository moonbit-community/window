///|
test "monitor handle accessors return stored values" {
  let monitor = MonitorHandle::new(
    (42 : Int).to_uint64(),
    Some("main display"),
    @dpi.PhysicalPosition::new(-1200, 0),
    @dpi.PhysicalSize::new(2560, 1440),
    2.0,
  )
  assert_eq(monitor.native_id(), (42 : Int).to_uint64())
  assert_eq(monitor.name(), Some("main display"))
  assert_eq(monitor.position(), @dpi.PhysicalPosition::new(-1200, 0))
  assert_eq(monitor.surface_size(), @dpi.PhysicalSize::new(2560, 1440))
  assert_eq(monitor.scale_factor(), 2.0)
}

///|
test "monitor handle normalizes non-positive scale factor" {
  let monitor = MonitorHandle::new(
    (7 : Int).to_uint64(),
    None,
    @dpi.PhysicalPosition::new(0, 0),
    @dpi.PhysicalSize::new(1920, 1080),
    0.0,
  )
  assert_eq(monitor.scale_factor(), 1.0)
}
