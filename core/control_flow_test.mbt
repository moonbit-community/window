///|
test "control flow defaults and wait duration" {
  assert_eq(ControlFlow::Wait, ControlFlow::Wait)
  assert_eq(ControlFlow::wait_duration(100L, 16), ControlFlow::WaitUntil(116L))
  assert_eq(ControlFlow::wait_until(42L), ControlFlow::WaitUntil(42L))
}

///|
test "start cause constructors are available" {
  assert_eq(StartCause::Init, StartCause::Init)
  assert_eq(StartCause::Poll, StartCause::Poll)
  assert_eq(
    StartCause::WaitCancelled(1L, Some(2L)),
    StartCause::WaitCancelled(1L, Some(2L)),
  )
  assert_eq(
    StartCause::ResumeTimeReached(3L, 4L),
    StartCause::ResumeTimeReached(3L, 4L),
  )
}

///|
test "surface size writer updates the requested size" {
  let writer = SurfaceSizeWriter::new(@dpi.PhysicalSize::new(800, 600))
  writer.request_surface_size(@dpi.PhysicalSize::new(1200, 900))
  assert_eq(writer.surface_size(), @dpi.PhysicalSize::new(1200, 900))
}
