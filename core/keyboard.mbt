///|
pub(all) enum NativeKeyCode {
  Unidentified
  Android(Int)
  MacOS(Int)
  Windows(Int)
  Xkb(Int)
  Ohos(Int)
} derive(Eq, Debug)

///|
pub(all) enum NativeKey {
  Unidentified
  Android(Int)
  MacOS(Int)
  Windows(Int)
  Xkb(Int)
  Web(String)
  Ohos(Int)
} derive(Eq, Debug)

///|
pub fn NativeKey::from_key_code(code : NativeKeyCode) -> NativeKey {
  match code {
    Unidentified => NativeKey::Unidentified
    Android(code) => NativeKey::Android(code)
    MacOS(code) => NativeKey::MacOS(code)
    Windows(code) => NativeKey::Windows(code)
    Xkb(code) => NativeKey::Xkb(code)
    Ohos(code) => NativeKey::Ohos(code)
  }
}

///|
pub(all) enum KeyCode {
  Unidentified
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
  Convert
  KanaMode
  Lang3
  Lang4
  Lang5
  NonConvert
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
  FnLock
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
  NumpadBackspace
  NumpadClear
  NumpadClearEntry
  NumpadHash
  NumpadMemoryAdd
  NumpadMemoryClear
  NumpadMemoryRecall
  NumpadMemoryStore
  NumpadMemorySubtract
  NumpadParenLeft
  NumpadParenRight
  NumpadStar
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
  F21
  F22
  F23
  F24
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
  Help
  PrintScreen
  ScrollLock
  Pause
  F4
  End
  F2
  PageDown
  F1
  ArrowLeft
  ArrowRight
  ArrowDown
  ArrowUp
  BrowserBack
  BrowserFavorites
  BrowserForward
  BrowserHome
  BrowserRefresh
  BrowserSearch
  BrowserStop
  Close
  Eject
  LaunchApp1
  LaunchApp2
  LaunchMail
  MediaPlayPause
  MediaSelect
  MediaStop
  MediaTrackNext
  MediaTrackPrevious
  Sleep
  WakeUp
  BrightnessDown
  BrightnessUp
  Again
  Copy
  Cut
  Find
  Open
  Paste
  Props
  Select
  Undo
  LaunchScreenSaver
  MailForward
  MailReply
  MailSend
  MediaFastForward
  MediaPause
  MediaPlay
  MediaRecord
  MediaRewind
  MicrophoneMuteToggle
  Abort
  Resume
  Suspend
  Hiragana
  Katakana
  F25
  F26
  F27
  F28
  F29
  F30
  F31
  F32
  F33
  F34
  F35
  DisplayToggleIntExt
  KeyboardLayoutSelect
  LaunchAssistant
  LaunchControlPanel
  PrivacyScreenToggle
  KeyboardBacklightToggle
  SelectTask
  ShowAllWindows
  ZoomToggle
  Hyper
  Super
  Turbo
  Power
} derive(Eq, Debug)

///|
pub fn KeyCode::default() -> KeyCode {
  KeyCode::Unidentified
}

///|
pub(all) enum PhysicalKey {
  Code(KeyCode)
  Unidentified(NativeKeyCode)
} derive(Eq, Debug)

///|
pub fn PhysicalKey::from_key_code(code : KeyCode) -> PhysicalKey {
  PhysicalKey::Code(code)
}

///|
pub fn PhysicalKey::from_native_key_code(code : NativeKeyCode) -> PhysicalKey {
  PhysicalKey::Unidentified(code)
}

///|
pub fn PhysicalKey::into_key_code(self : PhysicalKey) -> KeyCode {
  match self {
    Code(code) => code
    Unidentified(_) => KeyCode::Unidentified
  }
}

///|
pub(all) enum KeyLocation {
  Standard
  Left
  Right
  Numpad
} derive(Eq, Debug)

///|
pub(all) enum NamedKey {
  Unidentified
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
  ScrollLock
  AudioVolumeUp
  AudioVolumeDown
  AudioVolumeMute
  Fn
  FnLock
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
  F21
  F22
  F23
  F24
  Insert
  Home
  PageUp
  Delete
  Clear
  Copy
  Cut
  Find
  Open
  Paste
  Redo
  Undo
  Accept
  Again
  Cancel
  Execute
  Props
  Select
  End
  PageDown
  ArrowLeft
  ArrowRight
  ArrowDown
  ArrowUp
  ContextMenu
  BrowserBack
  BrowserFavorites
  BrowserForward
  BrowserHome
  BrowserRefresh
  BrowserSearch
  BrowserStop
  Close
  Eject
  Eisu
  KanjiMode
  Help
  Pause
  Play
  Power
  PrintScreen
  Standby
  WakeUp
  Alphanumeric
  CodeInput
  Convert
  NonConvert
  Hankaku
  Hiragana
  HiraganaKatakana
  KanaMode
  LaunchApplication1
  LaunchApplication2
  LaunchCalendar
  LaunchContacts
  LaunchMail
  LaunchMediaPlayer
  LaunchMusicPlayer
  LaunchPhone
  MediaClose
  MediaPlayPause
  MediaStop
  MediaTrackNext
  MediaTrackPrevious
  New
  Print
  Save
  SpellCheck
  Key11
  Key12
  Katakana
  BrightnessDown
  BrightnessUp
  LaunchScreenSaver
  MailForward
  MailReply
  MailSend
  MediaFastForward
  MediaPause
  MediaPlay
  MediaRecord
  MediaRewind
  MicrophoneToggle
  MicrophoneVolumeDown
  MicrophoneVolumeUp
  MicrophoneVolumeMute
  LaunchSpreadsheet
  LaunchWebBrowser
  LaunchWebCam
  LaunchWordProcessor
  Romaji
  Zenkaku
  ZenkakuHankaku
  F25
  F26
  F27
  F28
  F29
  F30
  F31
  F32
  F33
  F34
  F35
  ZoomToggle
  AltGraph
  Symbol
  SymbolLock
  Hyper
  Super
  CrSel
  EraseEof
  ExSel
  Attn
  ZoomIn
  ZoomOut
  LogOff
  PowerOff
  Hibernate
  AllCandidates
  Compose
  Dead
  FinalMode
  GroupFirst
  GroupLast
  GroupNext
  GroupPrevious
  ModeChange
  NextCandidate
  PreviousCandidate
  Process
  SingleCandidate
  HangulMode
  HanjaMode
  JunjaMode
  Soft1
  Soft2
  Soft3
  Soft4
  ChannelDown
  ChannelUp
  AudioBalanceLeft
  AudioBalanceRight
  AudioBassBoostDown
  AudioBassBoostToggle
  AudioBassBoostUp
  AudioFaderFront
  AudioFaderRear
  AudioSurroundModeNext
  AudioTrebleDown
  AudioTrebleUp
  SpeechCorrectionList
  SpeechInputToggle
  AppSwitch
  Call
  Camera
  CameraFocus
  EndCall
  GoBack
  GoHome
  HeadsetHook
  LastNumberRedial
  Notification
  MannerMode
  VoiceDial
  TV
  TV3DMode
  TVAntennaCable
  TVAudioDescription
  TVAudioDescriptionMixDown
  TVAudioDescriptionMixUp
  TVContentsMenu
  TVDataService
  TVInput
  TVInputComponent1
  TVInputComponent2
  TVInputComposite1
  TVInputComposite2
  TVInputHDMI1
  TVInputHDMI2
  TVInputHDMI3
  TVInputHDMI4
  TVInputVGA1
  TVMediaContext
  TVNetwork
  TVNumberEntry
  TVPower
  TVRadioService
  TVSatellite
  TVSatelliteBS
  TVSatelliteCS
  TVSatelliteToggle
  TVTerrestrialAnalog
  TVTerrestrialDigital
  TVTimer
  AVRInput
  AVRPower
  ColorF0Red
  ColorF1Green
  ColorF2Yellow
  ColorF3Blue
  ColorF4Grey
  ColorF5Brown
  ClosedCaptionToggle
  Dimmer
  DisplaySwap
  DVR
  Exit
  FavoriteClear0
  FavoriteClear1
  FavoriteClear2
  FavoriteClear3
  FavoriteRecall0
  FavoriteRecall1
  FavoriteRecall2
  FavoriteRecall3
  FavoriteStore0
  FavoriteStore1
  FavoriteStore2
  FavoriteStore3
  Guide
  GuideNextDay
  GuidePreviousDay
  Info
  InstantReplay
  Link
  ListProgram
  LiveContent
  Lock
  MediaApps
  MediaAudioTrack
  MediaLast
  MediaSkipBackward
  MediaSkipForward
  MediaStepBackward
  MediaStepForward
  MediaTopMenu
  NavigateIn
  NavigateNext
  NavigateOut
  NavigatePrevious
  NextFavoriteChannel
  NextUserProfile
  OnDemand
  Pairing
  PinPDown
  PinPMove
  PinPToggle
  PinPUp
  PlaySpeedDown
  PlaySpeedReset
  PlaySpeedUp
  RandomToggle
  RcLowBattery
  RecordSpeedNext
  RfBypass
  ScanChannelsToggle
  ScreenModeNext
  Settings
  SplitScreenToggle
  STBInput
  STBPower
  Subtitle
  Teletext
  VideoModeNext
  Wink
} derive(Eq, Debug)

///|
pub fn NamedKey::default() -> NamedKey {
  NamedKey::Unidentified
}

///|
pub(all) enum Key {
  Named(NamedKey)
  Character(String)
  Dead(String?)
  Unidentified(NativeKey)
} derive(Eq, Debug)

///|
pub fn Key::from_named(named : NamedKey) -> Key {
  Key::Named(named)
}

///|
pub fn Key::from_native(native : NativeKey) -> Key {
  Key::Unidentified(native)
}

///|
pub fn Key::character(self : Key) -> String? {
  match self {
    Character(character) => Some(character)
    _ => None
  }
}

///|
pub fn Key::to_text(self : Key) -> String? {
  match self {
    Named(NamedKey::Enter) => Some("\r")
    Named(NamedKey::Backspace) => Some("\b")
    Named(NamedKey::Tab) => Some("\t")
    Named(NamedKey::Escape) => Some("\u{1b}")
    Character(character) => Some(character)
    _ => None
  }
}

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
} derive(Eq, Debug)

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
