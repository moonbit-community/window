///|
test "any_thread does not permit macOS event loop creation off main thread" {
  let attributes = @core.PlatformEventLoopAttributes::default().with_any_thread(
    true,
  )
  guard event_loop_creation_thread_error(attributes, false) is Some(Os(error)) else {
    fail("expected an OS error for background-thread event loop creation")
  }
  assert_eq(
    error.message(),
    "On macOS, EventLoop creation must happen on the main thread",
  )
}

///|
test "macOS event loop creation accepts the main thread" {
  let attributes = @core.PlatformEventLoopAttributes::default().with_any_thread(
    true,
  )
  assert_true(event_loop_creation_thread_error(attributes, true) is None)
}
