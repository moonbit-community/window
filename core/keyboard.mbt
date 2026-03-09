///|
pub(all) enum NativeKeyCode {
  Unidentified
  MacOS(Int)
} derive(Eq, Show)

///|
pub(all) enum NativeKey {
  Unidentified
  MacOS(Int)
} derive(Eq, Show)

///|
pub(all) enum KeyCode {
  KeyA
  KeyS
  KeyD
  KeyF
  KeyH
  KeyG
  KeyZ
  KeyX
  KeyC
  KeyV
  IntlBackslash
  KeyB
  KeyQ
  KeyW
  KeyE
  KeyR
  KeyY
  KeyT
  Digit1
  Digit2
  Digit3
  Digit4
  Digit6
  Digit5
  Equal
  Digit9
  Digit7
  Minus
  Digit8
  Digit0
  BracketRight
  KeyO
  KeyU
  BracketLeft
  KeyI
  KeyP
  Enter
  KeyL
  KeyJ
  Quote
  KeyK
  Semicolon
  Backslash
  Comma
  Slash
  KeyN
  KeyM
  Period
  Tab
  Space
  Backquote
  Backspace
  Escape
  MetaRight
  MetaLeft
  ShiftLeft
  CapsLock
  AltLeft
  ControlLeft
  ShiftRight
  AltRight
  ControlRight
  Fn
  F17
  NumpadDecimal
  NumpadMultiply
  NumpadAdd
  NumLock
  AudioVolumeUp
  AudioVolumeDown
  AudioVolumeMute
  NumpadDivide
  NumpadEnter
  NumpadSubtract
  F18
  F19
  NumpadEqual
  Numpad0
  Numpad1
  Numpad2
  Numpad3
  Numpad4
  Numpad5
  Numpad6
  Numpad7
  F20
  Numpad8
  Numpad9
  IntlYen
  IntlRo
  NumpadComma
  F5
  F6
  F7
  F3
  F8
  F9
  Lang2
  F11
  Lang1
  F13
  F16
  F14
  F10
  ContextMenu
  F12
  F15
  Insert
  Home
  PageUp
  Delete
  F4
  End
  F2
  PageDown
  F1
  ArrowLeft
  ArrowRight
  ArrowDown
  ArrowUp
  Power
} derive(Eq, Show)

///|
pub(all) enum PhysicalKey {
  Code(KeyCode)
  Unidentified(NativeKeyCode)
} derive(Eq, Show)

///|
pub(all) enum KeyLocation {
  Standard
  Left
  Right
  Numpad
} derive(Eq, Show)

///|
pub(all) enum NamedKey {
  Enter
  Tab
  Backspace
  Escape
  Meta
  Shift
  Alt
  Control
  CapsLock
  NumLock
  AudioVolumeUp
  AudioVolumeDown
  AudioVolumeMute
  Fn
  F1
  F2
  F3
  F4
  F5
  F6
  F7
  F8
  F9
  F10
  F11
  F12
  F13
  F14
  F15
  F16
  F17
  F18
  F19
  F20
  Insert
  Home
  PageUp
  Delete
  End
  PageDown
  ArrowLeft
  ArrowRight
  ArrowDown
  ArrowUp
  ContextMenu
  Eisu
  KanjiMode
  Help
} derive(Eq, Show)

///|
pub(all) enum Key {
  Named(NamedKey)
  Character(String)
  Dead(String?)
  Unidentified(NativeKey)
} derive(Eq, Show)

///|
pub struct KeyEvent {
  key_without_modifiers : Key
  location : KeyLocation
  logical_key : Key
  physical_key : PhysicalKey
  repeat : Bool
  state : ElementState
  text : String?
  text_with_all_modifiers : String?
} derive(Eq, Show)

///|
pub fn KeyEvent::new(
  physical_key : PhysicalKey,
  logical_key : Key,
  key_without_modifiers : Key,
  location : KeyLocation,
  state : ElementState,
  repeat : Bool,
  text : String?,
  text_with_all_modifiers : String?,
) -> KeyEvent {
  {
    physical_key,
    logical_key,
    key_without_modifiers,
    location,
    state,
    repeat,
    text,
    text_with_all_modifiers,
  }
}

///|
pub fn KeyEvent::key_without_modifiers(self : KeyEvent) -> Key {
  self.key_without_modifiers
}

///|
pub fn KeyEvent::location(self : KeyEvent) -> KeyLocation {
  self.location
}

///|
pub fn KeyEvent::logical_key(self : KeyEvent) -> Key {
  self.logical_key
}

///|
pub fn KeyEvent::physical_key(self : KeyEvent) -> PhysicalKey {
  self.physical_key
}

///|
pub fn KeyEvent::repeat(self : KeyEvent) -> Bool {
  self.repeat
}

///|
pub fn KeyEvent::state(self : KeyEvent) -> ElementState {
  self.state
}

///|
pub fn KeyEvent::text(self : KeyEvent) -> String? {
  self.text
}

///|
pub fn KeyEvent::text_with_all_modifiers(self : KeyEvent) -> String? {
  self.text_with_all_modifiers
}
