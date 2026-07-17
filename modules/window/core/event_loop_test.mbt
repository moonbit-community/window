///|
test "platform_event_loop_attributes_any_thread_defaults_false" {
  let attributes = PlatformEventLoopAttributes::default()
  assert_false(attributes.any_thread())
}

///|
test "platform_event_loop_attributes_with_any_thread_updates_value" {
  let attributes = PlatformEventLoopAttributes::default().with_any_thread(true)
  assert_true(attributes.any_thread())
}

///|
test "event_loop_error_structured_payload" {
  let not_supported = EventLoopError::not_supported(
    "Multiple event loops are not supported",
  )
  guard not_supported is NotSupported(err) else {
    fail("expected EventLoopError::NotSupported payload")
  }
  assert_eq(err.reason(), "Multiple event loops are not supported")

  let os_error = EventLoopError::os(
    "Failed to initialize NSApplication",
    code=4096,
    domain="NSCocoaErrorDomain",
  )
  guard os_error is Os(err) else { fail("expected EventLoopError::Os payload") }
  assert_eq(err.message(), "Failed to initialize NSApplication")
  assert_true(err.code() == Some(4096))
  assert_true(err.domain() == Some("NSCocoaErrorDomain"))
}
