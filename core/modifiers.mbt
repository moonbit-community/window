///|
let modifiers_state_shift_bit : Int = 0b100

///|
let modifiers_state_control_bit : Int = 0b100 << 3

///|
let modifiers_state_alt_bit : Int = 0b100 << 6

///|
let modifiers_state_meta_bit : Int = 0b100 << 9

///|
let modifiers_state_mask : Int = modifiers_state_shift_bit |
  modifiers_state_control_bit |
  modifiers_state_alt_bit |
  modifiers_state_meta_bit

///|
let modifiers_keys_mask : Int = 0xFF

///|
pub struct ModifiersState {
  priv bits : Int
} derive(Eq, Show)

///|
pub fn ModifiersState::none() -> ModifiersState {
  { bits: 0 }
}

///|
pub fn ModifiersState::shift() -> ModifiersState {
  { bits: modifiers_state_shift_bit }
}

///|
pub fn ModifiersState::control() -> ModifiersState {
  { bits: modifiers_state_control_bit }
}

///|
pub fn ModifiersState::alt() -> ModifiersState {
  { bits: modifiers_state_alt_bit }
}

///|
pub fn ModifiersState::meta() -> ModifiersState {
  { bits: modifiers_state_meta_bit }
}

///|
pub fn ModifiersState::from_bits(bits : Int) -> ModifiersState {
  { bits: bits & modifiers_state_mask }
}

///|
pub fn ModifiersState::bits(self : ModifiersState) -> Int {
  self.bits
}

///|
pub fn ModifiersState::union(
  self : ModifiersState,
  other : ModifiersState,
) -> ModifiersState {
  ModifiersState::from_bits(self.bits | other.bits)
}

///|
pub fn ModifiersState::contains(
  self : ModifiersState,
  other : ModifiersState,
) -> Bool {
  (self.bits & other.bits) == other.bits
}

///|
pub fn ModifiersState::shift_key(self : ModifiersState) -> Bool {
  self.contains(ModifiersState::shift())
}

///|
pub fn ModifiersState::control_key(self : ModifiersState) -> Bool {
  self.contains(ModifiersState::control())
}

///|
pub fn ModifiersState::alt_key(self : ModifiersState) -> Bool {
  self.contains(ModifiersState::alt())
}

///|
pub fn ModifiersState::meta_key(self : ModifiersState) -> Bool {
  self.contains(ModifiersState::meta())
}

///|
pub fn ModifiersState::is_empty(self : ModifiersState) -> Bool {
  self.bits == 0
}

///|
pub(all) enum ModifiersKeyState {
  Pressed
  Unknown
} derive(Eq, Show)

///|
pub struct ModifiersKeys {
  priv bits : Int
} derive(Eq, Show)

///|
pub fn ModifiersKeys::none() -> ModifiersKeys {
  { bits: 0 }
}

///|
pub fn ModifiersKeys::lshift() -> ModifiersKeys {
  { bits: 0b0000_0001 }
}

///|
pub fn ModifiersKeys::rshift() -> ModifiersKeys {
  { bits: 0b0000_0010 }
}

///|
pub fn ModifiersKeys::lcontrol() -> ModifiersKeys {
  { bits: 0b0000_0100 }
}

///|
pub fn ModifiersKeys::rcontrol() -> ModifiersKeys {
  { bits: 0b0000_1000 }
}

///|
pub fn ModifiersKeys::lalt() -> ModifiersKeys {
  { bits: 0b0001_0000 }
}

///|
pub fn ModifiersKeys::ralt() -> ModifiersKeys {
  { bits: 0b0010_0000 }
}

///|
pub fn ModifiersKeys::lmeta() -> ModifiersKeys {
  { bits: 0b0100_0000 }
}

///|
pub fn ModifiersKeys::rmeta() -> ModifiersKeys {
  { bits: 0b1000_0000 }
}

///|
pub fn ModifiersKeys::from_bits(bits : Int) -> ModifiersKeys {
  { bits: bits & modifiers_keys_mask }
}

///|
pub fn ModifiersKeys::bits(self : ModifiersKeys) -> Int {
  self.bits
}

///|
pub fn ModifiersKeys::union(
  self : ModifiersKeys,
  other : ModifiersKeys,
) -> ModifiersKeys {
  ModifiersKeys::from_bits(self.bits | other.bits)
}

///|
pub fn ModifiersKeys::contains(
  self : ModifiersKeys,
  other : ModifiersKeys,
) -> Bool {
  (self.bits & other.bits) == other.bits
}

///|
pub fn ModifiersKeys::without(
  self : ModifiersKeys,
  other : ModifiersKeys,
) -> ModifiersKeys {
  ModifiersKeys::from_bits(self.bits & (modifiers_keys_mask ^ other.bits))
}

///|
pub fn ModifiersKeys::is_empty(self : ModifiersKeys) -> Bool {
  self.bits == 0
}

///|
pub struct Modifiers {
  priv pressed_mods : ModifiersKeys
  priv state : ModifiersState
} derive(Eq, Show)

///|
pub fn Modifiers::new(
  shift : Bool,
  control : Bool,
  alt : Bool,
  meta : Bool,
) -> Modifiers {
  let mut state = ModifiersState::none()
  if shift {
    state = state.union(ModifiersState::shift())
  }
  if control {
    state = state.union(ModifiersState::control())
  }
  if alt {
    state = state.union(ModifiersState::alt())
  }
  if meta {
    state = state.union(ModifiersState::meta())
  }
  Modifiers::from_state(state, ModifiersKeys::none())
}

///|
pub fn Modifiers::from_state(
  state : ModifiersState,
  pressed_mods : ModifiersKeys,
) -> Modifiers {
  { state, pressed_mods: sanitize_pressed_modifiers(state, pressed_mods) }
}

///|
pub fn Modifiers::default() -> Modifiers {
  Modifiers::from_state(ModifiersState::none(), ModifiersKeys::none())
}

///|
pub fn Modifiers::state(self : Modifiers) -> ModifiersState {
  self.state
}

///|
pub fn Modifiers::pressed_mods(self : Modifiers) -> ModifiersKeys {
  self.pressed_mods
}

///|
pub fn Modifiers::shift_key(self : Modifiers) -> Bool {
  self.state.shift_key()
}

///|
pub fn Modifiers::control_key(self : Modifiers) -> Bool {
  self.state.control_key()
}

///|
pub fn Modifiers::alt_key(self : Modifiers) -> Bool {
  self.state.alt_key()
}

///|
pub fn Modifiers::meta_key(self : Modifiers) -> Bool {
  self.state.meta_key()
}

///|
pub fn Modifiers::is_empty(self : Modifiers) -> Bool {
  self.state.is_empty()
}

///|
pub fn Modifiers::lshift_state(self : Modifiers) -> ModifiersKeyState {
  pressed_modifier_key_state(self.pressed_mods, ModifiersKeys::lshift())
}

///|
pub fn Modifiers::rshift_state(self : Modifiers) -> ModifiersKeyState {
  pressed_modifier_key_state(self.pressed_mods, ModifiersKeys::rshift())
}

///|
pub fn Modifiers::lcontrol_state(self : Modifiers) -> ModifiersKeyState {
  pressed_modifier_key_state(self.pressed_mods, ModifiersKeys::lcontrol())
}

///|
pub fn Modifiers::rcontrol_state(self : Modifiers) -> ModifiersKeyState {
  pressed_modifier_key_state(self.pressed_mods, ModifiersKeys::rcontrol())
}

///|
pub fn Modifiers::lalt_state(self : Modifiers) -> ModifiersKeyState {
  pressed_modifier_key_state(self.pressed_mods, ModifiersKeys::lalt())
}

///|
pub fn Modifiers::ralt_state(self : Modifiers) -> ModifiersKeyState {
  pressed_modifier_key_state(self.pressed_mods, ModifiersKeys::ralt())
}

///|
pub fn Modifiers::lsuper_state(self : Modifiers) -> ModifiersKeyState {
  pressed_modifier_key_state(self.pressed_mods, ModifiersKeys::lmeta())
}

///|
pub fn Modifiers::rsuper_state(self : Modifiers) -> ModifiersKeyState {
  pressed_modifier_key_state(self.pressed_mods, ModifiersKeys::rmeta())
}

///|
fn pressed_modifier_key_state(
  pressed_mods : ModifiersKeys,
  modifier : ModifiersKeys,
) -> ModifiersKeyState {
  if pressed_mods.contains(modifier) {
    ModifiersKeyState::Pressed
  } else {
    ModifiersKeyState::Unknown
  }
}

///|
fn sanitize_pressed_modifiers(
  state : ModifiersState,
  pressed_mods : ModifiersKeys,
) -> ModifiersKeys {
  let mut sanitized = pressed_mods
  let shift_keys = ModifiersKeys::lshift().union(ModifiersKeys::rshift())
  let control_keys = ModifiersKeys::lcontrol().union(ModifiersKeys::rcontrol())
  let alt_keys = ModifiersKeys::lalt().union(ModifiersKeys::ralt())
  let meta_keys = ModifiersKeys::lmeta().union(ModifiersKeys::rmeta())
  if state.shift_key() == false {
    sanitized = sanitized.without(shift_keys)
  }
  if state.control_key() == false {
    sanitized = sanitized.without(control_keys)
  }
  if state.alt_key() == false {
    sanitized = sanitized.without(alt_keys)
  }
  if state.meta_key() == false {
    sanitized = sanitized.without(meta_keys)
  }
  sanitized
}
