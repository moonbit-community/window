///|
test "control flow defaults and wait duration" {
  assert_eq(ControlFlow::Wait, ControlFlow::Wait)
  assert_eq(ControlFlow::wait_duration(16), ControlFlow::WaitUntil(16))
}
