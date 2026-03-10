///|
test "modifiers state bit helpers work" {
  let state = ModifiersState::shift().union(ModifiersState::meta())
  assert_true(state.shift_key())
  assert_false(state.control_key())
  assert_false(state.alt_key())
  assert_true(state.meta_key())
  assert_true(state.contains(ModifiersState::shift()))
  assert_eq(
    ModifiersState::from_bits(
      ModifiersState::shift().bits() | ModifiersState::meta().bits(),
    ),
    state,
  )
}

///|
test "modifiers keys bit helpers work" {
  let keys = ModifiersKeys::lshift()
    .union(ModifiersKeys::rcontrol())
    .union(ModifiersKeys::lmeta())
  assert_true(keys.contains(ModifiersKeys::lshift()))
  assert_true(keys.contains(ModifiersKeys::rcontrol()))
  assert_true(keys.contains(ModifiersKeys::lmeta()))
  assert_false(keys.contains(ModifiersKeys::rshift()))
  assert_eq(
    keys.without(ModifiersKeys::lshift().union(ModifiersKeys::rcontrol())),
    ModifiersKeys::lmeta(),
  )
}

///|
test "modifiers preserve aggregate and side specific states" {
  let modifiers = Modifiers::from_state(
    ModifiersState::shift()
    .union(ModifiersState::control())
    .union(ModifiersState::meta()),
    ModifiersKeys::lshift()
    .union(ModifiersKeys::rcontrol())
    .union(ModifiersKeys::lmeta()),
  )
  assert_true(modifiers.shift_key())
  assert_true(modifiers.control_key())
  assert_false(modifiers.alt_key())
  assert_true(modifiers.meta_key())
  assert_eq(modifiers.lshift_state(), ModifiersKeyState::Pressed)
  assert_eq(modifiers.rshift_state(), ModifiersKeyState::Unknown)
  assert_eq(modifiers.lcontrol_state(), ModifiersKeyState::Unknown)
  assert_eq(modifiers.rcontrol_state(), ModifiersKeyState::Pressed)
  assert_eq(modifiers.lsuper_state(), ModifiersKeyState::Pressed)
  assert_eq(modifiers.rsuper_state(), ModifiersKeyState::Unknown)
}

///|
test "modifiers sanitize impossible pressed states" {
  let modifiers = Modifiers::from_state(
    ModifiersState::shift(),
    ModifiersKeys::lshift().union(ModifiersKeys::ralt()),
  )
  assert_eq(modifiers.lshift_state(), ModifiersKeyState::Pressed)
  assert_eq(modifiers.ralt_state(), ModifiersKeyState::Unknown)
  assert_eq(modifiers.pressed_mods(), ModifiersKeys::lshift())
}

///|
test "modifiers legacy constructor still works" {
  let modifiers = Modifiers::new(true, false, true, false)
  assert_true(modifiers.shift_key())
  assert_false(modifiers.control_key())
  assert_true(modifiers.alt_key())
  assert_false(modifiers.meta_key())
  assert_eq(modifiers.state().bits(), ModifiersState::from_bits(260).bits())
  assert_true(modifiers.pressed_mods().is_empty())
}
