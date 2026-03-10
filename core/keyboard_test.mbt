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
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::KeyA).into_key_code(),
    KeyCode::KeyA,
  )
  assert_eq(
    PhysicalKey::from_native_key_code(NativeKeyCode::MacOS(9)).into_key_code(),
    KeyCode::Unidentified,
  )
  assert_eq(Key::Character("x").character(), Some("x"))
  assert_eq(Key::Named(NamedKey::Enter).character(), None)
}

///|
test "key to_text follows winit semantics for text carrying keys" {
  assert_eq(Key::Character("a").to_text(), Some("a"))
  assert_eq(Key::Named(NamedKey::Enter).to_text(), Some("\r"))
  assert_eq(Key::Named(NamedKey::Backspace).to_text(), Some("\b"))
  assert_eq(Key::Named(NamedKey::Tab).to_text(), Some("\t"))
  assert_eq(Key::Named(NamedKey::Escape).to_text(), Some("\u{1b}"))
  assert_eq(Key::Named(NamedKey::F20).to_text(), None)
}

///|
test "extended function and help key variants are available" {
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::F21),
    PhysicalKey::Code(KeyCode::F21),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::F24),
    PhysicalKey::Code(KeyCode::F24),
  )
  assert_eq(Key::from_named(NamedKey::Help), Key::Named(NamedKey::Help))
}

///|
test "keyboard defaults and system media variants are available" {
  assert_eq(KeyCode::default(), KeyCode::Unidentified)
  assert_eq(NamedKey::default(), NamedKey::Unidentified)
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::LaunchMail),
    PhysicalKey::Code(KeyCode::LaunchMail),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::MediaTrackNext),
    PhysicalKey::Code(KeyCode::MediaTrackNext),
  )
  assert_eq(
    Key::from_named(NamedKey::BrowserBack),
    Key::Named(NamedKey::BrowserBack),
  )
  assert_eq(
    Key::from_named(NamedKey::MediaTrackPrevious),
    Key::Named(NamedKey::MediaTrackPrevious),
  )
  assert_eq(Key::Named(NamedKey::WakeUp).to_text(), None)
}

///|
test "extended system media key variants are available" {
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::BrightnessDown),
    PhysicalKey::Code(KeyCode::BrightnessDown),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::MediaFastForward),
    PhysicalKey::Code(KeyCode::MediaFastForward),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::MicrophoneMuteToggle),
    PhysicalKey::Code(KeyCode::MicrophoneMuteToggle),
  )
  assert_eq(
    Key::from_named(NamedKey::LaunchScreenSaver),
    Key::Named(NamedKey::LaunchScreenSaver),
  )
  assert_eq(
    Key::from_named(NamedKey::MediaPause),
    Key::Named(NamedKey::MediaPause),
  )
  assert_eq(
    Key::from_named(NamedKey::MicrophoneToggle),
    Key::Named(NamedKey::MicrophoneToggle),
  )
  assert_eq(Key::Named(NamedKey::ZoomToggle).to_text(), None)
}

///|
test "editing and application command key variants are available" {
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::Again),
    PhysicalKey::Code(KeyCode::Again),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::Paste),
    PhysicalKey::Code(KeyCode::Paste),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::Undo),
    PhysicalKey::Code(KeyCode::Undo),
  )
  assert_eq(Key::from_named(NamedKey::Accept), Key::Named(NamedKey::Accept))
  assert_eq(Key::from_named(NamedKey::Redo), Key::Named(NamedKey::Redo))
  assert_eq(Key::from_named(NamedKey::Execute), Key::Named(NamedKey::Execute))
  assert_eq(Key::Named(NamedKey::Paste).to_text(), None)
}

///|
test "international input and extended function key variants are available" {
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::Convert),
    PhysicalKey::Code(KeyCode::Convert),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::KanaMode),
    PhysicalKey::Code(KeyCode::KanaMode),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::NumpadClear),
    PhysicalKey::Code(KeyCode::NumpadClear),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::NumpadMemoryRecall),
    PhysicalKey::Code(KeyCode::NumpadMemoryRecall),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::F35),
    PhysicalKey::Code(KeyCode::F35),
  )
  assert_eq(
    Key::from_named(NamedKey::Alphanumeric),
    Key::Named(NamedKey::Alphanumeric),
  )
  assert_eq(Key::from_named(NamedKey::KanaMode), Key::Named(NamedKey::KanaMode))
  assert_eq(
    Key::from_named(NamedKey::ZenkakuHankaku),
    Key::Named(NamedKey::ZenkakuHankaku),
  )
  assert_eq(Key::from_named(NamedKey::F35), Key::Named(NamedKey::F35))
  assert_eq(Key::Named(NamedKey::Convert).to_text(), None)
}

///|
test "extended system control code variants are available" {
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::Abort),
    PhysicalKey::Code(KeyCode::Abort),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::PrivacyScreenToggle),
    PhysicalKey::Code(KeyCode::PrivacyScreenToggle),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::ShowAllWindows),
    PhysicalKey::Code(KeyCode::ShowAllWindows),
  )
  assert_eq(Key::from_named(NamedKey::Hiragana), Key::Named(NamedKey::Hiragana))
  assert_eq(Key::from_named(NamedKey::Katakana), Key::Named(NamedKey::Katakana))
  assert_eq(Key::from_named(NamedKey::Romaji), Key::Named(NamedKey::Romaji))
  assert_eq(Key::Named(NamedKey::HiraganaKatakana).to_text(), None)
}

///|
test "legacy modifier and accelerator key variants are available" {
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::Hyper),
    PhysicalKey::Code(KeyCode::Hyper),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::Super),
    PhysicalKey::Code(KeyCode::Super),
  )
  assert_eq(
    PhysicalKey::from_key_code(KeyCode::Turbo),
    PhysicalKey::Code(KeyCode::Turbo),
  )
  assert_eq(Key::from_named(NamedKey::AltGraph), Key::Named(NamedKey::AltGraph))
  assert_eq(Key::from_named(NamedKey::Symbol), Key::Named(NamedKey::Symbol))
  assert_eq(
    Key::from_named(NamedKey::SymbolLock),
    Key::Named(NamedKey::SymbolLock),
  )
  assert_eq(Key::from_named(NamedKey::Hyper), Key::Named(NamedKey::Hyper))
  assert_eq(Key::from_named(NamedKey::Super), Key::Named(NamedKey::Super))
  assert_eq(Key::Named(NamedKey::ZoomIn).to_text(), None)
}

///|
test "application launcher and document named keys are available" {
  assert_eq(Key::from_named(NamedKey::Close), Key::Named(NamedKey::Close))
  assert_eq(Key::from_named(NamedKey::New), Key::Named(NamedKey::New))
  assert_eq(Key::from_named(NamedKey::Print), Key::Named(NamedKey::Print))
  assert_eq(Key::from_named(NamedKey::Save), Key::Named(NamedKey::Save))
  assert_eq(
    Key::from_named(NamedKey::LaunchCalendar),
    Key::Named(NamedKey::LaunchCalendar),
  )
  assert_eq(
    Key::from_named(NamedKey::LaunchMediaPlayer),
    Key::Named(NamedKey::LaunchMediaPlayer),
  )
  assert_eq(
    Key::from_named(NamedKey::LaunchWordProcessor),
    Key::Named(NamedKey::LaunchWordProcessor),
  )
  assert_eq(Key::Named(NamedKey::SpellCheck).to_text(), None)
}

///|
test "microphone and media utility named keys are available" {
  assert_eq(
    Key::from_named(NamedKey::MediaClose),
    Key::Named(NamedKey::MediaClose),
  )
  assert_eq(
    Key::from_named(NamedKey::MicrophoneVolumeDown),
    Key::Named(NamedKey::MicrophoneVolumeDown),
  )
  assert_eq(
    Key::from_named(NamedKey::MicrophoneVolumeUp),
    Key::Named(NamedKey::MicrophoneVolumeUp),
  )
  assert_eq(
    Key::from_named(NamedKey::MicrophoneVolumeMute),
    Key::Named(NamedKey::MicrophoneVolumeMute),
  )
  assert_eq(Key::from_named(NamedKey::Key11), Key::Named(NamedKey::Key11))
  assert_eq(Key::from_named(NamedKey::Key12), Key::Named(NamedKey::Key12))
  assert_eq(Key::Named(NamedKey::MediaClose).to_text(), None)
}

///|
test "composition and audio utility named keys are available" {
  assert_eq(Key::from_named(NamedKey::CrSel), Key::Named(NamedKey::CrSel))
  assert_eq(Key::from_named(NamedKey::EraseEof), Key::Named(NamedKey::EraseEof))
  assert_eq(Key::from_named(NamedKey::Compose), Key::Named(NamedKey::Compose))
  assert_eq(Key::from_named(NamedKey::Dead), Key::Named(NamedKey::Dead))
  assert_eq(
    Key::from_named(NamedKey::FinalMode),
    Key::Named(NamedKey::FinalMode),
  )
  assert_eq(
    Key::from_named(NamedKey::PreviousCandidate),
    Key::Named(NamedKey::PreviousCandidate),
  )
  assert_eq(
    Key::from_named(NamedKey::HangulMode),
    Key::Named(NamedKey::HangulMode),
  )
  assert_eq(Key::from_named(NamedKey::Soft4), Key::Named(NamedKey::Soft4))
  assert_eq(
    Key::from_named(NamedKey::AudioBalanceLeft),
    Key::Named(NamedKey::AudioBalanceLeft),
  )
  assert_eq(
    Key::from_named(NamedKey::AudioBassBoostToggle),
    Key::Named(NamedKey::AudioBassBoostToggle),
  )
  assert_eq(
    Key::from_named(NamedKey::SpeechInputToggle),
    Key::Named(NamedKey::SpeechInputToggle),
  )
  assert_eq(Key::Named(NamedKey::Process).to_text(), None)
}

///|
test "mobile and tv remote named keys are available" {
  assert_eq(
    Key::from_named(NamedKey::AppSwitch),
    Key::Named(NamedKey::AppSwitch),
  )
  assert_eq(Key::from_named(NamedKey::Camera), Key::Named(NamedKey::Camera))
  assert_eq(Key::from_named(NamedKey::GoHome), Key::Named(NamedKey::GoHome))
  assert_eq(
    Key::from_named(NamedKey::VoiceDial),
    Key::Named(NamedKey::VoiceDial),
  )
  assert_eq(Key::from_named(NamedKey::TVPower), Key::Named(NamedKey::TVPower))
  assert_eq(Key::from_named(NamedKey::AVRInput), Key::Named(NamedKey::AVRInput))
  assert_eq(
    Key::from_named(NamedKey::ColorF3Blue),
    Key::Named(NamedKey::ColorF3Blue),
  )
  assert_eq(
    Key::from_named(NamedKey::FavoriteRecall2),
    Key::Named(NamedKey::FavoriteRecall2),
  )
  assert_eq(
    Key::from_named(NamedKey::GuideNextDay),
    Key::Named(NamedKey::GuideNextDay),
  )
  assert_eq(
    Key::from_named(NamedKey::MediaSkipBackward),
    Key::Named(NamedKey::MediaSkipBackward),
  )
  assert_eq(
    Key::from_named(NamedKey::NavigateNext),
    Key::Named(NamedKey::NavigateNext),
  )
  assert_eq(
    Key::from_named(NamedKey::PlaySpeedReset),
    Key::Named(NamedKey::PlaySpeedReset),
  )
  assert_eq(Key::from_named(NamedKey::Settings), Key::Named(NamedKey::Settings))
  assert_eq(Key::from_named(NamedKey::Wink), Key::Named(NamedKey::Wink))
  assert_eq(Key::Named(NamedKey::TV).to_text(), None)
}
