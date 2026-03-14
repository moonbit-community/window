///|
// Port target: winit-reference/winit/tests/serde_objects.rs
// MoonBit adaptation: this package does not expose Rust serde traits, so we
// assert representability via value construction + Show/Eq stability.

///|
test "window_serde" {
  let icon = CursorIcon::Default
  assert_true("\{icon}" != "")
}

///|
test "events_serde" {
  let phase = TouchPhase::Moved
  let state = ElementState::Pressed
  let button = MouseButton::Left
  let delta = MouseScrollDelta::LineDelta(1.0, -1.0)
  let key = Key::Character("a")
  let named = NamedKey::Escape
  let code = KeyCode::KeyA
  let physical = PhysicalKey::Code(code)
  let location = KeyLocation::Standard
  let modifiers = ModifiersState::shift().union(ModifiersState::alt())

  let _ = "\{phase}"
  let _ = "\{state}"
  let _ = "\{button}"
  let _ = "\{delta}"
  let _ = "\{key}"
  let _ = "\{named}"
  let _ = "\{code}"
  let _ = "\{physical}"
  let _ = "\{location}"
  let _ = "\{modifiers}"

  assert_eq(key, Key::Character("a"))
  assert_eq(physical, PhysicalKey::Code(KeyCode::KeyA))
}

///|
test "dpi_serde" {
  let logical_position = @dpi.LogicalPosition::new(12.5, 9.5)
  let physical_position = @dpi.PhysicalPosition::new(125, 95)
  let physical_position_f64 = @dpi.PhysicalPositionF64::new(125.0, 95.0)
  let logical_size = @dpi.LogicalSize::new(640.0, 480.0)
  let physical_size = @dpi.PhysicalSize::new(640, 480)

  let _ = "\{logical_position}"
  let _ = "\{physical_position}"
  let _ = "\{physical_position_f64}"
  let _ = "\{logical_size}"
  let _ = "\{physical_size}"

  assert_eq(
    logical_position.to_physical(2.0),
    @dpi.PhysicalPosition::new(25, 19),
  )
  assert_eq(logical_size.to_physical(2.0), @dpi.PhysicalSize::new(1280, 960))
}
