///|
test "control flow defaults and wait duration" {
  assert_eq(ControlFlow::Wait, ControlFlow::Wait)
  assert_eq(ControlFlow::wait_duration(16), ControlFlow::WaitUntil(16))
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
