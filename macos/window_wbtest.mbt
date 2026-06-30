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

///|
test "drag_window_invalid_handle_status_maps_to_ignored" {
  let raised = try {
    raise_request_error_from_drag_window_status(
      invalid_native_window_handle_status,
    )
    false
  } catch {
    Ignored => true
    _ => {
      fail("expected RequestError::Ignored")
      false
    }
  }
  assert_true(raised)
}

///|
test "drag_window_zero_status_maps_to_not_supported" {
  let raised = try {
    raise_request_error_from_drag_window_status(0)
    false
  } catch {
    NotSupported(error) => {
      assert_eq(
        error.reason(),
        "Window dragging is not supported in the current state",
      )
      true
    }
    _ => {
      fail("expected RequestError::NotSupported")
      false
    }
  }
  assert_true(raised)
}

///|
test "drag_resize_false_result_maps_to_not_supported" {
  let raised = try {
    raise_request_error_from_drag_resize_result(false)
    false
  } catch {
    NotSupported(error) => {
      assert_eq(
        error.reason(),
        "Window edge dragging is not supported in the current state",
      )
      true
    }
    _ => {
      fail("expected RequestError::NotSupported")
      false
    }
  }
  assert_true(raised)
}

///|
test "content_view_handle_from_raw_returns_view_handle" {
  let handle = (42 : Int).to_uint64()
  let actual = content_view_handle_from_raw(handle) catch {
    _ => fail("expected content view handle")
  }
  assert_eq(actual, handle)
}

///|
test "content_view_handle_from_raw_rejects_null_handle" {
  let raised = try {
    ignore(content_view_handle_from_raw((0 : Int).to_uint64()))
    false
  } catch {
    Os(os) => {
      assert_eq(os.message(), "Window content view handle is unavailable")
      assert_true(os.code() == None)
      assert_true(os.domain() == Some("AppKit.NSWindow"))
      true
    }
    _ => {
      fail("expected RequestError::Os")
      false
    }
  }
  assert_true(raised)
}
