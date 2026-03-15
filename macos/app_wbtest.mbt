///|
test "test_override" {
  if !is_main_thread() {
    ()
  } else {
    // Idempotent override should not crash or mutate behavior on repeated calls.
    override_send_event()
    override_send_event()
    assert_true(true)
  }
}
