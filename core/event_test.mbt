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
    DeviceEvent::Button(1, ElementState::Released),
    DeviceEvent::Button(1, ElementState::Released),
  )
}
