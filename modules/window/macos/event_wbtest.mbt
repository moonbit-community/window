///|
test "drag payload converts entered paths and position" {
  let position = @dpi.PhysicalPositionF64::PhysicalPositionF64(12.0, 34.0)
  match drag_event_from_native_payload(9, position, b"first\nsecond\n", true) {
    Some(DragEntered(paths, event_position)) => {
      assert_true(paths == ["first", "second"])
      assert_eq(event_position, position)
    }
    _ => fail("expected DragEntered")
  }
}

///|
test "drag payload ignores entered and dropped events without paths" {
  let position = @dpi.PhysicalPositionF64::PhysicalPositionF64(12.0, 34.0)
  assert_true(drag_event_from_native_payload(9, position, b"", true) is None)
  assert_true(drag_event_from_native_payload(11, position, b"", true) is None)
}

///|
test "drag payload preserves optional leave position" {
  let position = @dpi.PhysicalPositionF64::PhysicalPositionF64(12.0, 34.0)
  assert_true(
    drag_event_from_native_payload(12, position, b"", true)
    is Some(DragLeft(Some(event_position))) &&
    event_position == position,
  )
  assert_true(
    drag_event_from_native_payload(12, position, b"", false)
    is Some(DragLeft(None)),
  )
}

///|
test "drag payload rejects unknown native kinds" {
  let position = @dpi.PhysicalPositionF64::PhysicalPositionF64(12.0, 34.0)
  assert_true(drag_event_from_native_payload(99, position, b"", true) is None)
}
