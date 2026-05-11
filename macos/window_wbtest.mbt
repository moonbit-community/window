///|
test "cursor_position_to_logical_preserves_logical_input" {
  let logical = cursor_position_to_logical(
    @dpi.LogicalPosition::LogicalPosition(120.0, 45.0).into_position(),
    2.0,
  )
  assert_eq(logical, LogicalPosition(120.0, 45.0))
}

///|
test "cursor_position_to_logical_converts_physical_input" {
  let logical = cursor_position_to_logical(
    @dpi.PhysicalPosition::PhysicalPosition(240, 90).into_position(),
    2.0,
  )
  assert_eq(logical, LogicalPosition(120.0, 45.0))
}

///|
test "native_core_graphics_status_maps_to_os_error" {
  let error = request_error_from_native_status(
    1001, "Failed to set cursor grab mode",
  )
  guard error is Os(os) else { fail("expected RequestError::Os") }
  assert_eq(os.message(), "Failed to set cursor grab mode")
  assert_true(os.code() == Some(1001))
  assert_true(os.domain() == Some("CoreGraphics.CGError"))
}

///|
test "invalid_native_window_handle_maps_to_os_error" {
  let error = request_error_from_native_status(
    invalid_native_window_handle_status, "Failed to set cursor hittest",
  )
  guard error is Os(os) else { fail("expected RequestError::Os") }
  assert_eq(
    os.message(),
    "Failed to set cursor hittest: invalid native window handle",
  )
  assert_true(os.code() == Some(invalid_native_window_handle_status))
  assert_true(os.domain() == Some("AppKit.NSWindow"))
}
