///|
let invalid_native_window_handle_status = -1

///|
let core_graphics_error_domain = "CoreGraphics.CGError"

///|
let appkit_window_error_domain = "AppKit.NSWindow"

///|
fn request_error_from_native_status(
  status : Int,
  operation : String,
) -> @core.RequestError {
  if status == invalid_native_window_handle_status {
    @core.RequestError::os(
      "\{operation}: invalid native window handle",
      code=status,
      domain=appkit_window_error_domain,
    )
  } else {
    @core.RequestError::os(
      operation,
      code=status,
      domain=core_graphics_error_domain,
    )
  }
}

///|
fn raise_request_error_from_native_status(
  status : Int,
  operation : String,
) -> Unit raise @core.RequestError {
  if status != 0 {
    raise request_error_from_native_status(status, operation)
  }
}

///|
fn raise_request_not_supported(
  reason : String,
) -> Unit raise @core.RequestError {
  raise @core.RequestError::not_supported(reason)
}

///|
fn raise_request_error_from_drag_window_status(
  status : Int,
) -> Unit raise @core.RequestError {
  if status == invalid_native_window_handle_status {
    raise Ignored
  }
  if status == 0 {
    raise_request_not_supported(
      "Window dragging is not supported in the current state",
    )
  }
}

///|
fn raise_request_error_from_drag_resize_result(
  succeeded : Bool,
) -> Unit raise @core.RequestError {
  if !succeeded {
    raise_request_not_supported(
      "Window edge dragging is not supported in the current state",
    )
  }
}
