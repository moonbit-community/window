///|
fn is_cursor_bad_position(text : String, cursor : Int, anchor : Int) -> Bool {
  try {
    ignore(ImeSurroundingText::new(text, cursor, anchor))
    false
  } catch {
    ImeSurroundingTextError::CursorBadPosition => true
    _ => false
  }
}

///|
test "ime_initial_request_caps_match" {
  let position : @dpi.Position = @dpi.LogicalPosition::new(0.0, 0.0).into_position()
  let size : @dpi.Size = @dpi.LogicalSize::new(0.0, 0.0).into_size()

  assert_eq(
    ImeEnableRequest::new(
      ImeCapabilities::default().with_cursor_area(),
      ImeRequestData::default(),
    ),
    None,
  )
  assert_eq(
    ImeEnableRequest::new(
      ImeCapabilities::default().with_hint_and_purpose(),
      ImeRequestData::default(),
    ),
    None,
  )
  assert_eq(
    ImeEnableRequest::new(
      ImeCapabilities::default().with_cursor_area(),
      ImeRequestData::default().with_hint_and_purpose(
        ImeHint::none(),
        ImePurpose::Normal,
      ),
    ),
    None,
  )
  assert_eq(
    ImeEnableRequest::new(
      ImeCapabilities::default(),
      ImeRequestData::default()
      .with_hint_and_purpose(ImeHint::none(), ImePurpose::Normal)
      .with_cursor_area(position, size),
    ),
    None,
  )
  assert_eq(
    ImeEnableRequest::new(
      ImeCapabilities::default().with_cursor_area(),
      ImeRequestData::default()
      .with_hint_and_purpose(ImeHint::none(), ImePurpose::Normal)
      .with_cursor_area(position, size),
    ),
    None,
  )
  assert_true(
    ImeEnableRequest::new(
      ImeCapabilities::default().with_cursor_area(),
      ImeRequestData::default().with_cursor_area(position, size),
    )
    is Some(_),
  )
  assert_true(
    ImeEnableRequest::new(
      ImeCapabilities::default().with_hint_and_purpose().with_cursor_area(),
      ImeRequestData::default()
      .with_hint_and_purpose(ImeHint::none(), ImePurpose::Normal)
      .with_cursor_area(position, size),
    )
    is Some(_),
  )

  let long_text = try! @utf8.decode(
    Bytes::make(8000, (97 : Int).to_byte())[:],
    ignore_bom=false,
  )
  let text_too_long = try {
    ignore(ImeSurroundingText::new(long_text, 0, 0))
    false
  } catch {
    ImeSurroundingTextError::TextTooLong => true
    _ => false
  }
  assert_true(text_too_long)

  assert_true(is_cursor_bad_position("short", 110, 0))
  assert_true(is_cursor_bad_position("граница", 1, 0))
}

///|
test "window_attributes_name_skip_taskbar_clip_children" {
  let attrs = WindowAttributes::default()
  assert_eq(attrs.name(), None)
  assert_false(attrs.skip_taskbar())
  assert_true(attrs.clip_children())

  let attrs = attrs
    .with_name("editor-main")
    .with_skip_taskbar(true)
    .with_clip_children(false)

  assert_eq(attrs.name(), Some("editor-main"))
  assert_true(attrs.skip_taskbar())
  assert_false(attrs.clip_children())
}
