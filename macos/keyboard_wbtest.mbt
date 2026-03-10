///|
test "create_key_event recognizes extra macos function keys from text" {
  let event = create_key_event(
    200,
    @core.ElementState::Pressed,
    false,
    @core.Modifiers::default(),
    Some("\u{f718}"),
    Some("\u{f718}"),
    Some("\u{f718}"),
  )
  assert_eq(event.physical_key(), @core.PhysicalKey::Code(@core.KeyCode::F21))
  assert_eq(event.logical_key(), @core.Key::Named(@core.NamedKey::F21))
  assert_eq(
    event.key_without_modifiers(),
    @core.Key::Named(@core.NamedKey::F21),
  )
  assert_eq(event.text(), None)
}

///|
test "create_key_event recognizes highest extra macos function key from text" {
  let event = create_key_event(
    201,
    @core.ElementState::Pressed,
    false,
    @core.Modifiers::default(),
    Some("\u{f71b}"),
    Some("\u{f71b}"),
    Some("\u{f71b}"),
  )
  assert_eq(event.physical_key(), @core.PhysicalKey::Code(@core.KeyCode::F24))
  assert_eq(event.logical_key(), @core.Key::Named(@core.NamedKey::F24))
  assert_eq(
    event.key_without_modifiers(),
    @core.Key::Named(@core.NamedKey::F24),
  )
  assert_eq(event.text(), None)
}
