///|
test "native key code conversion helpers cover cross platform variants" {
  assert_eq(
    NativeKey::from_key_code(NativeKeyCode::Android(1)),
    NativeKey::Android(1),
  )
  assert_eq(
    NativeKey::from_key_code(NativeKeyCode::MacOS(2)),
    NativeKey::MacOS(2),
  )
  assert_eq(
    NativeKey::from_key_code(NativeKeyCode::Windows(3)),
    NativeKey::Windows(3),
  )
  assert_eq(NativeKey::from_key_code(NativeKeyCode::Xkb(4)), NativeKey::Xkb(4))
  assert_eq(
    NativeKey::from_key_code(NativeKeyCode::Ohos(5)),
    NativeKey::Ohos(5),
  )
  assert_eq(
    NativeKey::from_key_code(NativeKeyCode::Unidentified),
    NativeKey::Unidentified,
  )
}

///|
test "physical and logical key constructors are available" {
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::KeyA),
    PhysicalKey::Code(KeyCode::KeyA),
  )
  assert_eq(
    PhysicalKey::from_native_key_code(NativeKeyCode::Xkb(12)),
    PhysicalKey::Unidentified(NativeKeyCode::Xkb(12)),
  )
  assert_eq(Key::from_named(NamedKey::Tab), Key::Named(NamedKey::Tab))
  assert_eq(
    Key::from_native(NativeKey::Web("KeyA")),
    Key::Unidentified(NativeKey::Web("KeyA")),
  )
}
