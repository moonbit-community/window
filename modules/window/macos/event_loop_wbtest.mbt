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

///|
test "macOS event loop run rejects a worker thread" {
  guard event_loop_run_thread_error(false) is Some(Os(error)) else {
    fail("expected an OS error for a background-thread event loop run")
  }
  assert_eq(
    error.message(),
    "On macOS, EventLoop must be run on the main thread",
  )
}

///|
test "macOS event loop run accepts the main thread" {
  assert_true(event_loop_run_thread_error(true) is None)
}

///|
test "AppKit event loops expose an AppKit display handle" {
  assert_true(appkit_raw_display_handle() is AppKit(_))
}
