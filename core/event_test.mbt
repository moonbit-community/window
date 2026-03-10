///|
test "device id can round-trip through raw integer" {
  let device_id = DeviceId::from_raw(42L)
  assert_eq(device_id.into_raw(), 42L)
}

///|
test "raw key event preserves physical key and state" {
  let event = RawKeyEvent::new(
    PhysicalKey::Code(KeyCode::KeyA),
    ElementState::Pressed,
  )
  assert_eq(event.physical_key(), PhysicalKey::Code(KeyCode::KeyA))
  assert_eq(event.state(), ElementState::Pressed)
}

///|
test "device event variants are constructible" {
  assert_eq(
    DeviceEvent::PointerMotion(1.5, -2.0),
    DeviceEvent::PointerMotion(1.5, -2.0),
  )
  assert_eq(
    DeviceEvent::MouseWheel(MouseScrollDelta::LineDelta(0.0, 1.0)),
    DeviceEvent::MouseWheel(MouseScrollDelta::LineDelta(0.0, 1.0)),
  )
  assert_eq(
    DeviceEvent::Button(ButtonId::from_raw(1), ElementState::Released),
    DeviceEvent::Button(ButtonId::from_raw(1), ElementState::Released),
  )
}

///|
test "ime event variants are constructible" {
  let range = ImeCursorRange::new(1, 2)
  assert_eq(Ime::Enabled, Ime::Enabled)
  assert_eq(Ime::Preedit("a", Some(range)), Ime::Preedit("a", Some(range)))
  assert_eq(Ime::Commit("text"), Ime::Commit("text"))
  assert_eq(Ime::DeleteSurrounding(2, 3), Ime::DeleteSurrounding(2, 3))
  assert_eq(Ime::Disabled, Ime::Disabled)
}

///|
test "async request serials can be created and round-tripped" {
  let serial = AsyncRequestSerial::get()
  assert_true(serial.into_raw() >= 0)
  let restored = AsyncRequestSerial::from_raw(7)
  assert_eq(restored.into_raw(), 7)
}

///|
test "mouse button conversion and button source helpers" {
  assert_eq(MouseButton::try_from_u8(0), Some(MouseButton::Left))
  assert_eq(MouseButton::try_from_u8(4), Some(MouseButton::Forward))
  assert_eq(MouseButton::try_from_u8(31), Some(MouseButton::Button32))
  assert_eq(MouseButton::try_from_u8(32), None)
  let from_touch = ButtonSource::Touch(FingerId::from_raw(3), None)
  assert_eq(from_touch.mouse_button(), Some(MouseButton::Left))
  let from_tool = ButtonSource::TabletTool(
    TabletToolKind::Pen,
    TabletToolButton::Barrel,
    TabletToolData::new(None, None, None, None, None),
  )
  assert_eq(from_tool.mouse_button(), Some(MouseButton::Right))
  let unknown = ButtonSource::Unknown(99)
  assert_eq(unknown.mouse_button(), None)
}

///|
test "tablet tool helpers and force normalization are available" {
  let angle = TabletToolAngle::new(@math.PI / 2.0, 0.0)
  let normalized = Force::Calibrated(1.0, 2.0).normalized(Some(angle))
  assert_true(Double::abs(normalized - 0.5) < 0.000001)
  let direct = Force::Normalized(0.25).normalized(None)
  assert_true(Double::abs(direct - 0.25) < 0.000001)
  let tilt = TabletToolTilt::new(0, 0)
  let angle_from_tilt = tilt.angle()
  assert_true(angle_from_tilt.altitude() >= 0.0)
  let tilt_from_angle = angle_from_tilt.tilt()
  assert_true(tilt_from_angle.x() <= 90)
}
