///|
fn physical_key_from_scancode(scancode : Int) -> @core.PhysicalKey {
  let code = match scancode {
    0x00 => Some(@core.KeyCode::KeyA)
    0x01 => Some(@core.KeyCode::KeyS)
    0x02 => Some(@core.KeyCode::KeyD)
    0x03 => Some(@core.KeyCode::KeyF)
    0x04 => Some(@core.KeyCode::KeyH)
    0x05 => Some(@core.KeyCode::KeyG)
    0x06 => Some(@core.KeyCode::KeyZ)
    0x07 => Some(@core.KeyCode::KeyX)
    0x08 => Some(@core.KeyCode::KeyC)
    0x09 => Some(@core.KeyCode::KeyV)
    0x0A => Some(@core.KeyCode::IntlBackslash)
    0x0B => Some(@core.KeyCode::KeyB)
    0x0C => Some(@core.KeyCode::KeyQ)
    0x0D => Some(@core.KeyCode::KeyW)
    0x0E => Some(@core.KeyCode::KeyE)
    0x0F => Some(@core.KeyCode::KeyR)
    0x10 => Some(@core.KeyCode::KeyY)
    0x11 => Some(@core.KeyCode::KeyT)
    0x12 => Some(@core.KeyCode::Digit1)
    0x13 => Some(@core.KeyCode::Digit2)
    0x14 => Some(@core.KeyCode::Digit3)
    0x15 => Some(@core.KeyCode::Digit4)
    0x16 => Some(@core.KeyCode::Digit6)
    0x17 => Some(@core.KeyCode::Digit5)
    0x18 => Some(@core.KeyCode::Equal)
    0x19 => Some(@core.KeyCode::Digit9)
    0x1A => Some(@core.KeyCode::Digit7)
    0x1B => Some(@core.KeyCode::Minus)
    0x1C => Some(@core.KeyCode::Digit8)
    0x1D => Some(@core.KeyCode::Digit0)
    0x1E => Some(@core.KeyCode::BracketRight)
    0x1F => Some(@core.KeyCode::KeyO)
    0x20 => Some(@core.KeyCode::KeyU)
    0x21 => Some(@core.KeyCode::BracketLeft)
    0x22 => Some(@core.KeyCode::KeyI)
    0x23 => Some(@core.KeyCode::KeyP)
    0x24 => Some(@core.KeyCode::Enter)
    0x25 => Some(@core.KeyCode::KeyL)
    0x26 => Some(@core.KeyCode::KeyJ)
    0x27 => Some(@core.KeyCode::Quote)
    0x28 => Some(@core.KeyCode::KeyK)
    0x29 => Some(@core.KeyCode::Semicolon)
    0x2A => Some(@core.KeyCode::Backslash)
    0x2B => Some(@core.KeyCode::Comma)
    0x2C => Some(@core.KeyCode::Slash)
    0x2D => Some(@core.KeyCode::KeyN)
    0x2E => Some(@core.KeyCode::KeyM)
    0x2F => Some(@core.KeyCode::Period)
    0x30 => Some(@core.KeyCode::Tab)
    0x31 => Some(@core.KeyCode::Space)
    0x32 => Some(@core.KeyCode::Backquote)
    0x33 => Some(@core.KeyCode::Backspace)
    0x35 => Some(@core.KeyCode::Escape)
    0x36 => Some(@core.KeyCode::MetaRight)
    0x37 => Some(@core.KeyCode::MetaLeft)
    0x38 => Some(@core.KeyCode::ShiftLeft)
    0x39 => Some(@core.KeyCode::CapsLock)
    0x3A => Some(@core.KeyCode::AltLeft)
    0x3B => Some(@core.KeyCode::ControlLeft)
    0x3C => Some(@core.KeyCode::ShiftRight)
    0x3D => Some(@core.KeyCode::AltRight)
    0x3E => Some(@core.KeyCode::ControlRight)
    0x3F => Some(@core.KeyCode::Fn)
    0x40 => Some(@core.KeyCode::F17)
    0x41 => Some(@core.KeyCode::NumpadDecimal)
    0x43 => Some(@core.KeyCode::NumpadMultiply)
    0x45 => Some(@core.KeyCode::NumpadAdd)
    0x47 => Some(@core.KeyCode::NumLock)
    0x48 => Some(@core.KeyCode::AudioVolumeUp)
    0x49 => Some(@core.KeyCode::AudioVolumeDown)
    0x4A => Some(@core.KeyCode::AudioVolumeMute)
    0x4B => Some(@core.KeyCode::NumpadDivide)
    0x4C => Some(@core.KeyCode::NumpadEnter)
    0x4E => Some(@core.KeyCode::NumpadSubtract)
    0x4F => Some(@core.KeyCode::F18)
    0x50 => Some(@core.KeyCode::F19)
    0x51 => Some(@core.KeyCode::NumpadEqual)
    0x52 => Some(@core.KeyCode::Numpad0)
    0x53 => Some(@core.KeyCode::Numpad1)
    0x54 => Some(@core.KeyCode::Numpad2)
    0x55 => Some(@core.KeyCode::Numpad3)
    0x56 => Some(@core.KeyCode::Numpad4)
    0x57 => Some(@core.KeyCode::Numpad5)
    0x58 => Some(@core.KeyCode::Numpad6)
    0x59 => Some(@core.KeyCode::Numpad7)
    0x5A => Some(@core.KeyCode::F20)
    0x5B => Some(@core.KeyCode::Numpad8)
    0x5C => Some(@core.KeyCode::Numpad9)
    0x5D => Some(@core.KeyCode::IntlYen)
    0x5E => Some(@core.KeyCode::IntlRo)
    0x5F => Some(@core.KeyCode::NumpadComma)
    0x60 => Some(@core.KeyCode::F5)
    0x61 => Some(@core.KeyCode::F6)
    0x62 => Some(@core.KeyCode::F7)
    0x63 => Some(@core.KeyCode::F3)
    0x64 => Some(@core.KeyCode::F8)
    0x65 => Some(@core.KeyCode::F9)
    0x66 => Some(@core.KeyCode::Lang2)
    0x67 => Some(@core.KeyCode::F11)
    0x68 => Some(@core.KeyCode::Lang1)
    0x69 => Some(@core.KeyCode::F13)
    0x6A => Some(@core.KeyCode::F16)
    0x6B => Some(@core.KeyCode::F14)
    0x6D => Some(@core.KeyCode::F10)
    0x6E => Some(@core.KeyCode::ContextMenu)
    0x6F => Some(@core.KeyCode::F12)
    0x71 => Some(@core.KeyCode::F15)
    0x72 => Some(@core.KeyCode::Insert)
    0x73 => Some(@core.KeyCode::Home)
    0x74 => Some(@core.KeyCode::PageUp)
    0x75 => Some(@core.KeyCode::Delete)
    0x76 => Some(@core.KeyCode::F4)
    0x77 => Some(@core.KeyCode::End)
    0x78 => Some(@core.KeyCode::F2)
    0x79 => Some(@core.KeyCode::PageDown)
    0x7A => Some(@core.KeyCode::F1)
    0x7B => Some(@core.KeyCode::ArrowLeft)
    0x7C => Some(@core.KeyCode::ArrowRight)
    0x7D => Some(@core.KeyCode::ArrowDown)
    0x7E => Some(@core.KeyCode::ArrowUp)
    0x7F => Some(@core.KeyCode::Power)
    _ => None
  }
  match code {
    Some(code) => @core.PhysicalKey::Code(code)
    None =>
      @core.PhysicalKey::Unidentified(@core.NativeKeyCode::MacOS(scancode))
  }
}

///|
fn key_location_from_physical_key(key : @core.PhysicalKey) -> @core.KeyLocation {
  match key {
    @core.PhysicalKey::Code(@core.KeyCode::MetaLeft) => @core.KeyLocation::Left
    @core.PhysicalKey::Code(@core.KeyCode::ShiftLeft) => @core.KeyLocation::Left
    @core.PhysicalKey::Code(@core.KeyCode::AltLeft) => @core.KeyLocation::Left
    @core.PhysicalKey::Code(@core.KeyCode::ControlLeft) =>
      @core.KeyLocation::Left
    @core.PhysicalKey::Code(@core.KeyCode::MetaRight) =>
      @core.KeyLocation::Right
    @core.PhysicalKey::Code(@core.KeyCode::ShiftRight) =>
      @core.KeyLocation::Right
    @core.PhysicalKey::Code(@core.KeyCode::AltRight) => @core.KeyLocation::Right
    @core.PhysicalKey::Code(@core.KeyCode::ControlRight) =>
      @core.KeyLocation::Right
    @core.PhysicalKey::Code(@core.KeyCode::NumLock) => @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::NumpadDecimal) =>
      @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::NumpadMultiply) =>
      @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::NumpadAdd) =>
      @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::NumpadDivide) =>
      @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::NumpadEnter) =>
      @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::NumpadSubtract) =>
      @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::NumpadEqual) =>
      @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::Numpad0) => @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::Numpad1) => @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::Numpad2) => @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::Numpad3) => @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::Numpad4) => @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::Numpad5) => @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::Numpad6) => @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::Numpad7) => @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::Numpad8) => @core.KeyLocation::Numpad
    @core.PhysicalKey::Code(@core.KeyCode::Numpad9) => @core.KeyLocation::Numpad
    _ => @core.KeyLocation::Standard
  }
}

///|
fn named_key_from_code(code : @core.KeyCode) -> @core.NamedKey? {
  match code {
    @core.KeyCode::Enter => Some(@core.NamedKey::Enter)
    @core.KeyCode::Tab => Some(@core.NamedKey::Tab)
    @core.KeyCode::Backspace => Some(@core.NamedKey::Backspace)
    @core.KeyCode::Escape => Some(@core.NamedKey::Escape)
    @core.KeyCode::MetaRight => Some(@core.NamedKey::Meta)
    @core.KeyCode::MetaLeft => Some(@core.NamedKey::Meta)
    @core.KeyCode::ShiftLeft => Some(@core.NamedKey::Shift)
    @core.KeyCode::AltLeft => Some(@core.NamedKey::Alt)
    @core.KeyCode::ControlLeft => Some(@core.NamedKey::Control)
    @core.KeyCode::ShiftRight => Some(@core.NamedKey::Shift)
    @core.KeyCode::AltRight => Some(@core.NamedKey::Alt)
    @core.KeyCode::ControlRight => Some(@core.NamedKey::Control)
    @core.KeyCode::CapsLock => Some(@core.NamedKey::CapsLock)
    @core.KeyCode::NumLock => Some(@core.NamedKey::NumLock)
    @core.KeyCode::AudioVolumeUp => Some(@core.NamedKey::AudioVolumeUp)
    @core.KeyCode::AudioVolumeDown => Some(@core.NamedKey::AudioVolumeDown)
    @core.KeyCode::AudioVolumeMute => Some(@core.NamedKey::AudioVolumeMute)
    @core.KeyCode::NumpadEnter => Some(@core.NamedKey::Enter)
    @core.KeyCode::Fn => Some(@core.NamedKey::Fn)
    @core.KeyCode::F1 => Some(@core.NamedKey::F1)
    @core.KeyCode::F2 => Some(@core.NamedKey::F2)
    @core.KeyCode::F3 => Some(@core.NamedKey::F3)
    @core.KeyCode::F4 => Some(@core.NamedKey::F4)
    @core.KeyCode::F5 => Some(@core.NamedKey::F5)
    @core.KeyCode::F6 => Some(@core.NamedKey::F6)
    @core.KeyCode::F7 => Some(@core.NamedKey::F7)
    @core.KeyCode::F8 => Some(@core.NamedKey::F8)
    @core.KeyCode::F9 => Some(@core.NamedKey::F9)
    @core.KeyCode::F10 => Some(@core.NamedKey::F10)
    @core.KeyCode::F11 => Some(@core.NamedKey::F11)
    @core.KeyCode::F12 => Some(@core.NamedKey::F12)
    @core.KeyCode::F13 => Some(@core.NamedKey::F13)
    @core.KeyCode::F14 => Some(@core.NamedKey::F14)
    @core.KeyCode::F15 => Some(@core.NamedKey::F15)
    @core.KeyCode::F16 => Some(@core.NamedKey::F16)
    @core.KeyCode::F17 => Some(@core.NamedKey::F17)
    @core.KeyCode::F18 => Some(@core.NamedKey::F18)
    @core.KeyCode::F19 => Some(@core.NamedKey::F19)
    @core.KeyCode::F20 => Some(@core.NamedKey::F20)
    @core.KeyCode::Insert => Some(@core.NamedKey::Insert)
    @core.KeyCode::Home => Some(@core.NamedKey::Home)
    @core.KeyCode::PageUp => Some(@core.NamedKey::PageUp)
    @core.KeyCode::Delete => Some(@core.NamedKey::Delete)
    @core.KeyCode::End => Some(@core.NamedKey::End)
    @core.KeyCode::PageDown => Some(@core.NamedKey::PageDown)
    @core.KeyCode::ArrowLeft => Some(@core.NamedKey::ArrowLeft)
    @core.KeyCode::ArrowRight => Some(@core.NamedKey::ArrowRight)
    @core.KeyCode::ArrowDown => Some(@core.NamedKey::ArrowDown)
    @core.KeyCode::ArrowUp => Some(@core.NamedKey::ArrowUp)
    @core.KeyCode::ContextMenu => Some(@core.NamedKey::ContextMenu)
    @core.KeyCode::Lang2 => Some(@core.NamedKey::Eisu)
    @core.KeyCode::Lang1 => Some(@core.NamedKey::KanjiMode)
    _ => None
  }
}

///|
fn key_without_modifiers_char(scancode : Int) -> String? {
  match scancode {
    0x00 => Some("a")
    0x01 => Some("s")
    0x02 => Some("d")
    0x03 => Some("f")
    0x04 => Some("h")
    0x05 => Some("g")
    0x06 => Some("z")
    0x07 => Some("x")
    0x08 => Some("c")
    0x09 => Some("v")
    0x0B => Some("b")
    0x0C => Some("q")
    0x0D => Some("w")
    0x0E => Some("e")
    0x0F => Some("r")
    0x10 => Some("y")
    0x11 => Some("t")
    0x12 => Some("1")
    0x13 => Some("2")
    0x14 => Some("3")
    0x15 => Some("4")
    0x16 => Some("6")
    0x17 => Some("5")
    0x18 => Some("=")
    0x19 => Some("9")
    0x1A => Some("7")
    0x1B => Some("-")
    0x1C => Some("8")
    0x1D => Some("0")
    0x1E => Some("]")
    0x1F => Some("o")
    0x20 => Some("u")
    0x21 => Some("[")
    0x22 => Some("i")
    0x23 => Some("p")
    0x25 => Some("l")
    0x26 => Some("j")
    0x27 => Some("'")
    0x28 => Some("k")
    0x29 => Some(";")
    0x2A => Some("\\")
    0x2B => Some(",")
    0x2C => Some("/")
    0x2D => Some("n")
    0x2E => Some("m")
    0x2F => Some(".")
    0x31 => Some(" ")
    0x32 => Some("`")
    0x41 => Some(".")
    0x43 => Some("*")
    0x45 => Some("+")
    0x4B => Some("/")
    0x4E => Some("-")
    0x51 => Some("=")
    0x52 => Some("0")
    0x53 => Some("1")
    0x54 => Some("2")
    0x55 => Some("3")
    0x56 => Some("4")
    0x57 => Some("5")
    0x58 => Some("6")
    0x59 => Some("7")
    0x5B => Some("8")
    0x5C => Some("9")
    0x5F => Some(",")
    _ => None
  }
}

///|
fn shifted_char(scancode : Int) -> String? {
  match scancode {
    0x00 => Some("A")
    0x01 => Some("S")
    0x02 => Some("D")
    0x03 => Some("F")
    0x04 => Some("H")
    0x05 => Some("G")
    0x06 => Some("Z")
    0x07 => Some("X")
    0x08 => Some("C")
    0x09 => Some("V")
    0x0B => Some("B")
    0x0C => Some("Q")
    0x0D => Some("W")
    0x0E => Some("E")
    0x0F => Some("R")
    0x10 => Some("Y")
    0x11 => Some("T")
    0x12 => Some("!")
    0x13 => Some("@")
    0x14 => Some("#")
    0x15 => Some("$")
    0x16 => Some("^")
    0x17 => Some("%")
    0x18 => Some("+")
    0x19 => Some("(")
    0x1A => Some("&")
    0x1B => Some("_")
    0x1C => Some("*")
    0x1D => Some(")")
    0x1E => Some("}")
    0x1F => Some("O")
    0x20 => Some("U")
    0x21 => Some("{")
    0x22 => Some("I")
    0x23 => Some("P")
    0x25 => Some("L")
    0x26 => Some("J")
    0x27 => Some("\"")
    0x28 => Some("K")
    0x29 => Some(":")
    0x2A => Some("|")
    0x2B => Some("<")
    0x2C => Some("?")
    0x2D => Some("N")
    0x2E => Some("M")
    0x2F => Some(">")
    0x31 => Some(" ")
    0x32 => Some("~")
    0x41 => Some(".")
    0x43 => Some("*")
    0x45 => Some("+")
    0x4B => Some("/")
    0x4E => Some("-")
    0x51 => Some("=")
    0x52 => Some("0")
    0x53 => Some("1")
    0x54 => Some("2")
    0x55 => Some("3")
    0x56 => Some("4")
    0x57 => Some("5")
    0x58 => Some("6")
    0x59 => Some("7")
    0x5B => Some("8")
    0x5C => Some("9")
    0x5F => Some(",")
    _ => None
  }
}

///|
fn normalized_native_text(text : String?) -> String? {
  match text {
    Some(text) => if text.length() == 0 { None } else { Some(text) }
    None => None
  }
}

///|
fn key_from_native_text(text : String?) -> @core.Key? {
  match normalized_native_text(text) {
    Some(text) => Some(@core.Key::Character(text))
    None => None
  }
}

///|
fn key_without_modifiers_from_scancode(
  scancode : Int,
  physical_key : @core.PhysicalKey,
  text_ignoring_modifiers : String?,
) -> @core.Key {
  match physical_key {
    @core.PhysicalKey::Code(@core.KeyCode::Space) => @core.Key::Character(" ")
    @core.PhysicalKey::Code(code) =>
      match named_key_from_code(code) {
        Some(named) => @core.Key::Named(named)
        None =>
          match key_from_native_text(text_ignoring_modifiers) {
            Some(key) => key
            None =>
              match key_without_modifiers_char(scancode) {
                Some(character) => @core.Key::Character(character)
                None =>
                  @core.Key::Unidentified(@core.NativeKey::MacOS(scancode))
              }
          }
      }
    @core.PhysicalKey::Unidentified(@core.NativeKeyCode::MacOS(code)) =>
      match key_from_native_text(text_ignoring_modifiers) {
        Some(key) => key
        None => @core.Key::Unidentified(@core.NativeKey::MacOS(code))
      }
    @core.PhysicalKey::Unidentified(_) =>
      match key_from_native_text(text_ignoring_modifiers) {
        Some(key) => key
        None => @core.Key::Unidentified(@core.NativeKey::Unidentified)
      }
  }
}

///|
fn logical_key_from_scancode(
  scancode : Int,
  physical_key : @core.PhysicalKey,
  modifiers : @core.Modifiers,
  key_without_modifiers : @core.Key,
  text_with_all_modifiers : String?,
  text_ignoring_modifiers : String?,
) -> @core.Key {
  match physical_key {
    @core.PhysicalKey::Code(@core.KeyCode::Space) => @core.Key::Character(" ")
    @core.PhysicalKey::Code(code) =>
      match named_key_from_code(code) {
        Some(named) => @core.Key::Named(named)
        None =>
          if modifiers.control_key() || modifiers.meta_key() {
            match key_from_native_text(text_ignoring_modifiers) {
              Some(key) => key
              None => key_without_modifiers
            }
          } else {
            match key_from_native_text(text_with_all_modifiers) {
              Some(key) => key
              None =>
                match key_from_native_text(text_ignoring_modifiers) {
                  Some(key) => key
                  None => {
                    let fallback_character = if modifiers.shift_key() {
                      shifted_char(scancode)
                    } else {
                      key_without_modifiers_char(scancode)
                    }
                    match fallback_character {
                      Some(character) => @core.Key::Character(character)
                      None => key_without_modifiers
                    }
                  }
                }
            }
          }
      }
    @core.PhysicalKey::Unidentified(@core.NativeKeyCode::MacOS(code)) =>
      if modifiers.control_key() || modifiers.meta_key() {
        match key_from_native_text(text_ignoring_modifiers) {
          Some(key) => key
          None => @core.Key::Unidentified(@core.NativeKey::MacOS(code))
        }
      } else {
        match key_from_native_text(text_with_all_modifiers) {
          Some(key) => key
          None =>
            match key_from_native_text(text_ignoring_modifiers) {
              Some(key) => key
              None => @core.Key::Unidentified(@core.NativeKey::MacOS(code))
            }
        }
      }
    @core.PhysicalKey::Unidentified(_) =>
      if modifiers.control_key() || modifiers.meta_key() {
        match key_from_native_text(text_ignoring_modifiers) {
          Some(key) => key
          None => key_without_modifiers
        }
      } else {
        match key_from_native_text(text_with_all_modifiers) {
          Some(key) => key
          None =>
            match key_from_native_text(text_ignoring_modifiers) {
              Some(key) => key
              None => key_without_modifiers
            }
        }
      }
  }
}

///|
fn key_text(key : @core.Key) -> String? {
  match key {
    @core.Key::Character(character) => Some(character)
    @core.Key::Named(@core.NamedKey::Enter) => Some("\r")
    @core.Key::Named(@core.NamedKey::Tab) => Some("\t")
    _ => None
  }
}

///|
fn create_key_event(
  scancode : Int,
  state : @core.ElementState,
  repeat : Bool,
  modifiers : @core.Modifiers,
  text_with_all_modifiers : String?,
  text_ignoring_modifiers : String?,
) -> @core.KeyEvent {
  let normalized_text_with_all_modifiers = normalized_native_text(
    text_with_all_modifiers,
  )
  let normalized_text_ignoring_modifiers = normalized_native_text(
    text_ignoring_modifiers,
  )
  let physical_key = physical_key_from_scancode(scancode)
  let key_without_modifiers = key_without_modifiers_from_scancode(
    scancode, physical_key, normalized_text_ignoring_modifiers,
  )
  let logical_key = logical_key_from_scancode(
    scancode, physical_key, modifiers, key_without_modifiers, normalized_text_with_all_modifiers,
    normalized_text_ignoring_modifiers,
  )
  let text = match state {
    @core.ElementState::Pressed => key_text(logical_key)
    @core.ElementState::Released => None
  }
  let text_with_all_modifiers = match state {
    @core.ElementState::Pressed =>
      match normalized_text_with_all_modifiers {
        Some(text) => Some(text)
        None => text
      }
    @core.ElementState::Released => None
  }
  @core.KeyEvent::new(
    physical_key,
    logical_key,
    key_without_modifiers,
    key_location_from_physical_key(physical_key),
    state,
    repeat,
    text,
    text_with_all_modifiers,
  )
}
