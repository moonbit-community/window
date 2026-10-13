///|
test "custom cursor rejects extreme negative dimensions without overflow" {
  let min_int = -2147483647 - 1
  let rejected_safely = try {
    ignore(
      @core.CustomCursorSource::from_rgba(
        Bytes::make(4, (0 : Int32).to_byte()),
        min_int,
        -1,
        0,
        0,
      ),
    )
    false
  } catch {
    DimensionsVsPixelCount(width, height, expected, actual) =>
      width == min_int && height == -1 && expected == 0 && actual == 1
    _ => false
  }
  assert_true(rejected_safely)
}

///|
fn is_cursor_bad_position(
  text : String,
  cursor : Int32,
  anchor : Int32,
) -> Bool {
  try {
    ignore(@core.ImeSurroundingText::ImeSurroundingText(text, cursor, anchor))
    false
  } catch {
    CursorBadPosition => true
    _ => false
  }
}

///|
test "ime_initial_request_caps_match" {
  let position : @dpi.Position = @dpi.LogicalPosition::LogicalPosition(0.0, 0.0).into_position()
  let size : @dpi.Size = @dpi.LogicalSize::LogicalSize(0.0, 0.0).into_size()

  assert_true(
    @core.ImeEnableRequest::from_capabilities(
      @core.ImeCapabilities::default().with_cursor_area(),
      @core.ImeRequestData::default(),
    ) ==
    None,
  )
  assert_true(
    @core.ImeEnableRequest::from_capabilities(
      @core.ImeCapabilities::default().with_hint_and_purpose(),
      @core.ImeRequestData::default(),
    ) ==
    None,
  )
  assert_true(
    @core.ImeEnableRequest::from_capabilities(
      @core.ImeCapabilities::default().with_cursor_area(),
      @core.ImeRequestData::default().with_hint_and_purpose(
        @core.ImeHint::none(),
        Normal,
      ),
    ) ==
    None,
  )
  assert_true(
    @core.ImeEnableRequest::from_capabilities(
      @core.ImeCapabilities::default(),
      @core.ImeRequestData::default()
      .with_hint_and_purpose(@core.ImeHint::none(), Normal)
      .with_cursor_area(position, size),
    ) ==
    None,
  )
  assert_true(
    @core.ImeEnableRequest::from_capabilities(
      @core.ImeCapabilities::default().with_cursor_area(),
      @core.ImeRequestData::default()
      .with_hint_and_purpose(@core.ImeHint::none(), Normal)
      .with_cursor_area(position, size),
    ) ==
    None,
  )
  assert_true(
    @core.ImeEnableRequest::from_capabilities(
      @core.ImeCapabilities::default().with_cursor_area(),
      @core.ImeRequestData::default().with_cursor_area(position, size),
    )
    is Some(_),
  )
  assert_true(
    @core.ImeEnableRequest::from_capabilities(
      @core.ImeCapabilities::default()
      .with_hint_and_purpose()
      .with_cursor_area(),
      @core.ImeRequestData::default()
      .with_hint_and_purpose(@core.ImeHint::none(), Normal)
      .with_cursor_area(position, size),
    )
    is Some(_),
  )

  let long_text = try! @utf8.decode(
    Bytes::make(8000, (97 : Int32).to_byte())[:],
    ignore_bom=false,
  )
  let text_too_long = try {
    ignore(@core.ImeSurroundingText::ImeSurroundingText(long_text, 0, 0))
    false
  } catch {
    TextTooLong => true
    _ => false
  }
  assert_true(text_too_long)

  assert_true(is_cursor_bad_position("short", 110, 0))
  assert_true(is_cursor_bad_position("граница", 1, 0))
}

///|
test "window_attributes_name_skip_taskbar_clip_children" {
  let attrs = @core.WindowAttributes::default()
  assert_true(attrs.name() == None)
  assert_false(attrs.skip_taskbar())
  assert_true(attrs.clip_children())

  let attrs = attrs
    .with_name("editor-main")
    .with_skip_taskbar(true)
    .with_clip_children(false)

  assert_true(attrs.name() == Some("editor-main"))
  assert_true(attrs.skip_taskbar())
  assert_false(attrs.clip_children())
}

///|
test "parent windows preserve structured raw handles" {
  let appkit = try! @windowing.AppKitWindowHandle::new(42UL)
  let raw : @windowing.RawWindowHandle = AppKit(appkit)
  let parent = @core.ParentWindow::from_raw(raw)
  assert_eq(parent.into_raw(), raw)
}

///|
struct DummyCursorHittestWindow {
  mut hittest : Bool
}

///|
impl WindowCursorHittest for DummyCursorHittestWindow with fn set_cursor_hittest(
  self,
  hittest,
) {
  self.hittest = hittest
}

///|
fn[T : WindowCursorHittest] set_cursor_hittest_generic(
  window : T,
  hittest : Bool,
) -> Unit raise @core.RequestError {
  window.set_cursor_hittest(hittest)
}

///|
test "window_cursor_hittest_trait_usage" {
  let window = { hittest: false, }
  let _ = set_cursor_hittest_generic(window, true) catch {
    _ => fail("DummyCursorHittestWindow should not raise RequestError")
  }
  assert_true(window.hittest)
}

///|
test "request_error_structured_payload" {
  let unsupported = @core.RequestError::not_supported(
    "Confined cursor grab is unavailable",
  )
  guard unsupported is NotSupported(not_supported) else {
    fail("expected RequestError::NotSupported payload")
  }
  assert_eq(not_supported.reason(), "Confined cursor grab is unavailable")
  assert_eq(
    "\{unsupported}",
    "Operation is not supported: Confined cursor grab is unavailable",
  )

  let os_error = @core.RequestError::os(
    "NSWindow cursor update failed",
    code=1001,
    domain="NSCocoaErrorDomain",
  )
  guard os_error is Os(os) else { fail("expected RequestError::Os payload") }
  assert_eq(os.message(), "NSWindow cursor update failed")
  assert_true(os.code() == Some(1001))
  assert_true(os.domain() == Some("NSCocoaErrorDomain"))
  assert_eq(
    "\{os_error}",
    "os error: NSWindow cursor update failed (domain=NSCocoaErrorDomain, code=1001)",
  )

  let os_error_without_code = @core.RequestError::os("Unknown AppKit failure")
  guard os_error_without_code is Os(os_no_code) else {
    fail("expected RequestError::Os payload")
  }
  assert_eq(os_no_code.message(), "Unknown AppKit failure")
  assert_true(os_no_code.code() == None)
  assert_true(os_no_code.domain() == None)
  assert_eq("\{os_error_without_code}", "os error: Unknown AppKit failure")
}
