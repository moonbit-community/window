///|
// Port target: winit-reference/winit-appkit/src/event.rs

///|
fn extra_function_key_from_text(text : String?) -> @core.PhysicalKey? {
  match text {
    Some("\u{f718}") => Some(Code(F21))
    Some("\u{f719}") => Some(Code(F22))
    Some("\u{f71a}") => Some(Code(F23))
    Some("\u{f71b}") => Some(Code(F24))
    Some("\u{f727}") => Some(Code(Insert))
    Some("\u{f746}") => Some(Code(Help))
    _ => None
  }
}

///|
// Port target: event.rs::extra_function_key_to_code
fn extra_function_key_to_code(text : String?) -> @core.PhysicalKey? {
  extra_function_key_from_text(text)
}

///|
fn physical_key_from_scancode(
  scancode : Int,
  text_with_all_modifiers : String?,
) -> @core.PhysicalKey {
  let code = match scancode {
    0x00 => Some(@core.KeyCode::KeyA)
    0x01 => Some(KeyS)
    0x02 => Some(KeyD)
    0x03 => Some(KeyF)
    0x04 => Some(KeyH)
    0x05 => Some(KeyG)
    0x06 => Some(KeyZ)
    0x07 => Some(KeyX)
    0x08 => Some(KeyC)
    0x09 => Some(KeyV)
    0x0A => Some(IntlBackslash)
    0x0B => Some(KeyB)
    0x0C => Some(KeyQ)
    0x0D => Some(KeyW)
    0x0E => Some(KeyE)
    0x0F => Some(KeyR)
    0x10 => Some(KeyY)
    0x11 => Some(KeyT)
    0x12 => Some(Digit1)
    0x13 => Some(Digit2)
    0x14 => Some(Digit3)
    0x15 => Some(Digit4)
    0x16 => Some(Digit6)
    0x17 => Some(Digit5)
    0x18 => Some(Equal)
    0x19 => Some(Digit9)
    0x1A => Some(Digit7)
    0x1B => Some(Minus)
    0x1C => Some(Digit8)
    0x1D => Some(Digit0)
    0x1E => Some(BracketRight)
    0x1F => Some(KeyO)
    0x20 => Some(KeyU)
    0x21 => Some(BracketLeft)
    0x22 => Some(KeyI)
    0x23 => Some(KeyP)
    0x24 => Some(Enter)
    0x25 => Some(KeyL)
    0x26 => Some(KeyJ)
    0x27 => Some(Quote)
    0x28 => Some(KeyK)
    0x29 => Some(Semicolon)
    0x2A => Some(Backslash)
    0x2B => Some(Comma)
    0x2C => Some(Slash)
    0x2D => Some(KeyN)
    0x2E => Some(KeyM)
    0x2F => Some(Period)
    0x30 => Some(Tab)
    0x31 => Some(Space)
    0x32 => Some(Backquote)
    0x33 => Some(Backspace)
    0x35 => Some(Escape)
    0x36 => Some(MetaRight)
    0x37 => Some(MetaLeft)
    0x38 => Some(ShiftLeft)
    0x39 => Some(CapsLock)
    0x3A => Some(AltLeft)
    0x3B => Some(ControlLeft)
    0x3C => Some(ShiftRight)
    0x3D => Some(AltRight)
    0x3E => Some(ControlRight)
    0x3F => Some(Fn)
    0x40 => Some(F17)
    0x41 => Some(NumpadDecimal)
    0x43 => Some(NumpadMultiply)
    0x45 => Some(NumpadAdd)
    0x47 => Some(NumLock)
    0x48 => Some(AudioVolumeUp)
    0x49 => Some(AudioVolumeDown)
    0x4A => Some(AudioVolumeMute)
    0x4B => Some(NumpadDivide)
    0x4C => Some(NumpadEnter)
    0x4E => Some(NumpadSubtract)
    0x4F => Some(F18)
    0x50 => Some(F19)
    0x51 => Some(NumpadEqual)
    0x52 => Some(Numpad0)
    0x53 => Some(Numpad1)
    0x54 => Some(Numpad2)
    0x55 => Some(Numpad3)
    0x56 => Some(Numpad4)
    0x57 => Some(Numpad5)
    0x58 => Some(Numpad6)
    0x59 => Some(Numpad7)
    0x5A => Some(F20)
    0x5B => Some(Numpad8)
    0x5C => Some(Numpad9)
    0x5D => Some(IntlYen)
    0x5E => Some(IntlRo)
    0x5F => Some(NumpadComma)
    0x60 => Some(F5)
    0x61 => Some(F6)
    0x62 => Some(F7)
    0x63 => Some(F3)
    0x64 => Some(F8)
    0x65 => Some(F9)
    0x66 => Some(Lang2)
    0x67 => Some(F11)
    0x68 => Some(Lang1)
    0x69 => Some(F13)
    0x6A => Some(F16)
    0x6B => Some(F14)
    0x6D => Some(F10)
    0x6E => Some(ContextMenu)
    0x6F => Some(F12)
    0x71 => Some(F15)
    0x72 => Some(Insert)
    0x73 => Some(Home)
    0x74 => Some(PageUp)
    0x75 => Some(Delete)
    0x76 => Some(F4)
    0x77 => Some(End)
    0x78 => Some(F2)
    0x79 => Some(PageDown)
    0x7A => Some(F1)
    0x7B => Some(ArrowLeft)
    0x7C => Some(ArrowRight)
    0x7D => Some(ArrowDown)
    0x7E => Some(ArrowUp)
    0x7F => Some(Power)
    _ => None
  }
  match extra_function_key_to_code(text_with_all_modifiers) {
    Some(key) => key
    None =>
      match code {
        Some(code) => Code(code)
        None => Unidentified(MacOS(scancode))
      }
  }
}

///|
fn key_location_from_physical_key(key : @core.PhysicalKey) -> @core.KeyLocation {
  match key {
    Code(MetaLeft) => Left
    Code(ShiftLeft) => Left
    Code(AltLeft) => Left
    Code(ControlLeft) => Left
    Code(MetaRight) => Right
    Code(ShiftRight) => Right
    Code(AltRight) => Right
    Code(ControlRight) => Right
    Code(NumLock) => Numpad
    Code(NumpadDecimal) => Numpad
    Code(NumpadMultiply) => Numpad
    Code(NumpadAdd) => Numpad
    Code(NumpadDivide) => Numpad
    Code(NumpadEnter) => Numpad
    Code(NumpadSubtract) => Numpad
    Code(NumpadEqual) => Numpad
    Code(Numpad0) => Numpad
    Code(Numpad1) => Numpad
    Code(Numpad2) => Numpad
    Code(Numpad3) => Numpad
    Code(Numpad4) => Numpad
    Code(Numpad5) => Numpad
    Code(Numpad6) => Numpad
    Code(Numpad7) => Numpad
    Code(Numpad8) => Numpad
    Code(Numpad9) => Numpad
    _ => Standard
  }
}

///|
// Port target: event.rs::code_to_location
fn code_to_location(key : @core.PhysicalKey) -> @core.KeyLocation {
  key_location_from_physical_key(key)
}

///|
fn named_key_from_code(code : @core.KeyCode) -> @core.NamedKey? {
  match code {
    Enter => Some(Enter)
    Tab => Some(Tab)
    Backspace => Some(Backspace)
    Escape => Some(Escape)
    MetaRight => Some(Meta)
    MetaLeft => Some(Meta)
    ShiftLeft => Some(Shift)
    AltLeft => Some(Alt)
    ControlLeft => Some(Control)
    ShiftRight => Some(Shift)
    AltRight => Some(Alt)
    ControlRight => Some(Control)
    CapsLock => Some(CapsLock)
    NumLock => Some(NumLock)
    AudioVolumeUp => Some(AudioVolumeUp)
    AudioVolumeDown => Some(AudioVolumeDown)
    AudioVolumeMute => Some(AudioVolumeMute)
    NumpadEnter => Some(Enter)
    Fn => Some(Fn)
    F1 => Some(F1)
    F2 => Some(F2)
    F3 => Some(F3)
    F4 => Some(F4)
    F5 => Some(F5)
    F6 => Some(F6)
    F7 => Some(F7)
    F8 => Some(F8)
    F9 => Some(F9)
    F10 => Some(F10)
    F11 => Some(F11)
    F12 => Some(F12)
    F13 => Some(F13)
    F14 => Some(F14)
    F15 => Some(F15)
    F16 => Some(F16)
    F17 => Some(F17)
    F18 => Some(F18)
    F19 => Some(F19)
    F20 => Some(F20)
    F21 => Some(F21)
    F22 => Some(F22)
    F23 => Some(F23)
    F24 => Some(F24)
    Insert => Some(Insert)
    Home => Some(Home)
    PageUp => Some(PageUp)
    Delete => Some(Delete)
    Help => Some(Help)
    End => Some(End)
    PageDown => Some(PageDown)
    ArrowLeft => Some(ArrowLeft)
    ArrowRight => Some(ArrowRight)
    ArrowDown => Some(ArrowDown)
    ArrowUp => Some(ArrowUp)
    ContextMenu => Some(ContextMenu)
    Lang2 => Some(Eisu)
    Lang1 => Some(KanjiMode)
    _ => None
  }
}

///|
// Port target: event.rs::code_to_key
fn code_to_key(code : @core.KeyCode) -> @core.NamedKey? {
  named_key_from_code(code)
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
    Some(text) => Some(Character(text))
    None => None
  }
}

///|
fn fallback_character_from_key_code(code : @core.KeyCode) -> String? {
  match code {
    KeyA => Some("a")
    KeyB => Some("b")
    KeyC => Some("c")
    KeyD => Some("d")
    KeyE => Some("e")
    KeyF => Some("f")
    KeyG => Some("g")
    KeyH => Some("h")
    KeyI => Some("i")
    KeyJ => Some("j")
    KeyK => Some("k")
    KeyL => Some("l")
    KeyM => Some("m")
    KeyN => Some("n")
    KeyO => Some("o")
    KeyP => Some("p")
    KeyQ => Some("q")
    KeyR => Some("r")
    KeyS => Some("s")
    KeyT => Some("t")
    KeyU => Some("u")
    KeyV => Some("v")
    KeyW => Some("w")
    KeyX => Some("x")
    KeyY => Some("y")
    KeyZ => Some("z")
    Digit0 => Some("0")
    Digit1 => Some("1")
    Digit2 => Some("2")
    Digit3 => Some("3")
    Digit4 => Some("4")
    Digit5 => Some("5")
    Digit6 => Some("6")
    Digit7 => Some("7")
    Digit8 => Some("8")
    Digit9 => Some("9")
    Space => Some(" ")
    Minus => Some("-")
    Equal => Some("=")
    BracketLeft => Some("[")
    BracketRight => Some("]")
    Backslash => Some("\\")
    Semicolon => Some(";")
    Quote => Some("'")
    Backquote => Some("`")
    Comma => Some(",")
    Period => Some(".")
    Slash => Some("/")
    NumpadDecimal => Some(".")
    NumpadAdd => Some("+")
    NumpadSubtract => Some("-")
    NumpadMultiply => Some("*")
    NumpadDivide => Some("/")
    Numpad0 => Some("0")
    Numpad1 => Some("1")
    Numpad2 => Some("2")
    Numpad3 => Some("3")
    Numpad4 => Some("4")
    Numpad5 => Some("5")
    Numpad6 => Some("6")
    Numpad7 => Some("7")
    Numpad8 => Some("8")
    Numpad9 => Some("9")
    NumpadComma => Some(",")
    _ => None
  }
}

///|
fn dead_or_character_from_native_text(
  text : String?,
  state : @core.ElementState,
) -> @core.Key? {
  match normalized_native_text(text) {
    Some(text) =>
      match state {
        Pressed => Some(Dead(Some(text)))
        Released => Some(Character(text))
      }
    None => None
  }
}

///|
fn key_without_modifiers_from_scancode(
  scancode : Int,
  physical_key : @core.PhysicalKey,
  text_without_modifiers : String?,
) -> @core.Key {
  match physical_key {
    Code(Space) => Character(" ")
    Code(code) =>
      match code_to_key(code) {
        Some(named) => Named(named)
        None =>
          match key_from_native_text(text_without_modifiers) {
            Some(key) => key
            None =>
              match fallback_character_from_key_code(code) {
                Some(text) => Character(text)
                None => Unidentified(MacOS(scancode))
              }
          }
      }
    Unidentified(MacOS(code)) =>
      match key_from_native_text(text_without_modifiers) {
        Some(key) => key
        None => Unidentified(MacOS(code))
      }
    Unidentified(_) =>
      match key_from_native_text(text_without_modifiers) {
        Some(key) => key
        None => Unidentified(Unidentified)
      }
  }
}

///|
fn logical_key_from_scancode(
  physical_key : @core.PhysicalKey,
  state : @core.ElementState,
  modifiers : @core.Modifiers,
  key_without_modifiers : @core.Key,
  text_with_all_modifiers : String?,
  text_ignoring_modifiers : String?,
  text_without_modifiers : String?,
) -> @core.Key {
  match physical_key {
    Code(Space) => Character(" ")
    Code(code) =>
      match code_to_key(code) {
        Some(named) => Named(named)
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
                match
                  dead_or_character_from_native_text(
                    text_without_modifiers, state,
                  ) {
                  Some(key) => key
                  None => key_without_modifiers
                }
            }
          }
      }
    Unidentified(MacOS(code)) =>
      if modifiers.control_key() || modifiers.meta_key() {
        match key_from_native_text(text_ignoring_modifiers) {
          Some(key) => key
          None => Unidentified(MacOS(code))
        }
      } else {
        match key_from_native_text(text_with_all_modifiers) {
          Some(key) => key
          None =>
            match
              dead_or_character_from_native_text(text_without_modifiers, state) {
              Some(key) => key
              None => Unidentified(MacOS(code))
            }
        }
      }
    Unidentified(_) =>
      if modifiers.control_key() || modifiers.meta_key() {
        match key_from_native_text(text_ignoring_modifiers) {
          Some(key) => key
          None => key_without_modifiers
        }
      } else {
        match key_from_native_text(text_with_all_modifiers) {
          Some(key) => key
          None =>
            match
              dead_or_character_from_native_text(text_without_modifiers, state) {
              Some(key) => key
              None => key_without_modifiers
            }
        }
      }
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
  text_without_modifiers : String?,
) -> @core.KeyEvent {
  let normalized_text_with_all_modifiers = normalized_native_text(
    text_with_all_modifiers,
  )
  let normalized_text_ignoring_modifiers = normalized_native_text(
    text_ignoring_modifiers,
  )
  let normalized_text_without_modifiers = normalized_native_text(
    text_without_modifiers,
  )
  let physical_key = physical_key_from_scancode(
    scancode, normalized_text_with_all_modifiers,
  )
  let key_without_modifiers = key_without_modifiers_from_scancode(
    scancode, physical_key, normalized_text_without_modifiers,
  )
  let logical_key = logical_key_from_scancode(
    physical_key, state, modifiers, key_without_modifiers, normalized_text_with_all_modifiers,
    normalized_text_ignoring_modifiers, normalized_text_without_modifiers,
  )
  let text = match state {
    Pressed => logical_key.to_text()
    Released => None
  }
  let text_with_all_modifiers = match state {
    Pressed =>
      match normalized_text_with_all_modifiers {
        Some(text) => Some(text)
        None => text
      }
    Released => None
  }
  KeyEvent(
    physical_key,
    logical_key,
    key_without_modifiers,
    code_to_location(physical_key),
    state,
    repeat,
    text,
    text_with_all_modifiers,
  )
}

///|
fn element_state_from_native(state : Int) -> @core.ElementState? {
  match state {
    1 => Some(Pressed)
    2 => Some(Released)
    _ => None
  }
}

///|
fn mouse_button_from_native(button : Int) -> @core.MouseButton? {
  @core.MouseButton::try_from_u8(button)
}

///|
fn button_source_from_native(button : Int) -> @core.ButtonSource {
  match mouse_button_from_native(button) {
    Some(mouse) => Mouse(mouse)
    None => Unknown(button)
  }
}

///|
fn pointer_source_from_native(source : Int) -> @core.PointerSource {
  match source {
    1 => Mouse
    _ => Unknown
  }
}

///|
fn pointer_kind_from_native(kind : Int) -> @core.PointerKind {
  match kind {
    1 => Mouse
    _ => Unknown
  }
}

///|
fn scroll_delta_from_native(
  kind : Int,
  x : Double,
  y : Double,
) -> @core.MouseScrollDelta? {
  match kind {
    1 => Some(LineDelta(x, y))
    2 => Some(PixelDelta(PhysicalPositionF64(x, y)))
    _ => None
  }
}

///|
fn touch_phase_from_native(phase : Int) -> @core.TouchPhase? {
  match phase {
    1 => Some(Started)
    2 => Some(Moved)
    3 => Some(Ended)
    4 => Some(Cancelled)
    _ => None
  }
}

///|
fn drag_event_from_native_payload(
  kind : Int,
  position : @dpi.PhysicalPositionF64,
  path : Bytes,
  has_position : Bool,
) -> @core.WindowEvent? {
  match kind {
    9 => {
      let paths = drag_paths_from_native(path)
      if paths.length() > 0 {
        Some(DragEntered(paths, position))
      } else {
        None
      }
    }
    10 => Some(DragMoved(position))
    11 => {
      let paths = drag_paths_from_native(path)
      if paths.length() > 0 {
        Some(DragDropped(paths, position))
      } else {
        None
      }
    }
    12 => Some(DragLeft(if has_position { Some(position) } else { None }))
    _ => None
  }
}

///|
fn queue_drag_event_from_payload(
  raw_id : Int,
  kind : Int,
  position : @dpi.PhysicalPositionF64,
  path : Bytes,
  has_position : Bool,
) -> Unit {
  match drag_event_from_native_payload(kind, position, path, has_position) {
    Some(event) =>
      app_state_queue_window_callback(@core.WindowId::from_raw(raw_id), event)
    None => ()
  }
}
