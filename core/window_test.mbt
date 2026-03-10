///|
test "window attributes follow winit defaults" {
  let attrs = WindowAttributes::default()
  assert_eq(attrs.title(), "winit window")
  assert_true(attrs.visible())
  assert_true(attrs.resizable())
  assert_true(attrs.active())
  assert_false(attrs.blur())
  assert_eq(attrs.cursor(), Cursor::Icon(CursorIcon::Default))
  assert_true(attrs.cursor_visible())
  assert_true(attrs.cursor_hittest())
  assert_true(attrs.decorations())
  assert_false(attrs.content_protected())
  let default_buttons = attrs.enabled_buttons()
  assert_true(default_buttons.close())
  assert_true(default_buttons.minimize())
  assert_true(default_buttons.maximize())
  assert_eq(attrs.fullscreen(), None)
  assert_eq(attrs.surface_size(), Some(@dpi.PhysicalSize::new(800, 600)))
  assert_eq(attrs.surface_resize_increments(), None)
  assert_eq(attrs.min_surface_size(), None)
  assert_eq(attrs.max_surface_size(), None)
  assert_eq(attrs.position(), None)
  assert_eq(attrs.parent_window(), None)
  assert_eq(attrs.platform_attributes().simple_fullscreen(), None)
  assert_eq(attrs.ime_hints(), ImeHint::none())
  assert_eq(attrs.ime_purpose(), ImePurpose::Normal)
  assert_eq(attrs.window_level(), WindowLevel::Normal)
  assert_eq(attrs.theme(), None)
  assert_eq(attrs.window_icon(), None)
  assert_false(attrs.maximized())
  assert_false(attrs.transparent())
}

///|
test "window attributes builders update fields" {
  let icon = try! Icon::new(Bytes::make(4, (255 : Int).to_byte()), 1, 1)
  let parent_window = ParentWindow::from_raw((99 : Int).to_uint64())
  let attrs = WindowAttributes::default()
    .with_title("hello")
    .with_visible(false)
    .with_resizable(false)
    .with_surface_size(@dpi.PhysicalSize::new(1024, 768))
    .with_surface_resize_increments(Some(@dpi.PhysicalSize::new(32, 24)))
    .with_min_surface_size(Some(@dpi.PhysicalSize::new(640, 480)))
    .with_max_surface_size(Some(@dpi.PhysicalSize::new(1920, 1080)))
    .with_position(Some(@dpi.PhysicalPosition::new(320, 180)))
    .with_parent_window(Some(parent_window))
    .with_platform_attributes(
      PlatformWindowAttributes::default().with_simple_fullscreen(Some(true)),
    )
    .with_ime_hints(
      ImeHint::completion()
      .union(ImeHint::spellcheck())
      .union(ImeHint::multiline()),
    )
    .with_ime_purpose(ImePurpose::Password)
    .with_active(false)
    .with_blur(true)
    .with_cursor(Cursor::Icon(CursorIcon::Pointer))
    .with_cursor_visible(false)
    .with_cursor_hittest(false)
    .with_decorations(false)
    .with_content_protected(true)
    .with_enabled_buttons(WindowButtons::none().with_minimize(true))
    .with_fullscreen(Some(Fullscreen::Borderless(None)))
    .with_window_level(WindowLevel::AlwaysOnTop)
    .with_theme(Some(Theme::Dark))
    .with_window_icon(Some(icon))
    .with_maximized(true)
    .with_transparent(true)
  assert_eq(attrs.title(), "hello")
  assert_false(attrs.visible())
  assert_false(attrs.resizable())
  assert_false(attrs.active())
  assert_true(attrs.blur())
  assert_eq(attrs.cursor(), Cursor::Icon(CursorIcon::Pointer))
  assert_false(attrs.cursor_visible())
  assert_false(attrs.cursor_hittest())
  assert_false(attrs.decorations())
  assert_true(attrs.content_protected())
  let buttons = attrs.enabled_buttons()
  assert_false(buttons.close())
  assert_true(buttons.minimize())
  assert_false(buttons.maximize())
  assert_eq(attrs.fullscreen(), Some(Fullscreen::Borderless(None)))
  assert_eq(attrs.surface_size(), Some(@dpi.PhysicalSize::new(1024, 768)))
  assert_eq(
    attrs.surface_resize_increments(),
    Some(@dpi.PhysicalSize::new(32, 24)),
  )
  assert_eq(attrs.min_surface_size(), Some(@dpi.PhysicalSize::new(640, 480)))
  assert_eq(attrs.max_surface_size(), Some(@dpi.PhysicalSize::new(1920, 1080)))
  assert_eq(attrs.position(), Some(@dpi.PhysicalPosition::new(320, 180)))
  assert_eq(attrs.parent_window(), Some(parent_window))
  assert_eq(attrs.platform_attributes().simple_fullscreen(), Some(true))
  assert_eq(
    attrs.ime_hints(),
    ImeHint::completion()
    .union(ImeHint::spellcheck())
    .union(ImeHint::multiline()),
  )
  assert_eq(attrs.ime_purpose(), ImePurpose::Password)
  assert_eq(attrs.window_level(), WindowLevel::AlwaysOnTop)
  assert_eq(attrs.theme(), Some(Theme::Dark))
  assert_eq(attrs.window_icon(), Some(icon))
  assert_true(attrs.maximized())
  assert_true(attrs.transparent())
}

///|
test "fullscreen enum supports exclusive mode payload" {
  let monitor = MonitorHandle::new(
    (1 : Int).to_uint64(),
    Some("test monitor"),
    @dpi.PhysicalPosition::new(0, 0),
    @dpi.PhysicalSize::new(1920, 1080),
    2.0,
    None,
    [],
  )
  let mode = VideoMode::new(
    @dpi.PhysicalSize::new(1920, 1080),
    Some(32),
    Some(60000),
  )
  let attrs = WindowAttributes::default().with_fullscreen(
    Some(Fullscreen::Exclusive(monitor, mode)),
  )
  assert_eq(attrs.fullscreen(), Some(Fullscreen::Exclusive(monitor, mode)))
}

///|
test "window buttons builders work as expected" {
  let buttons = WindowButtons::all()
    .with_close(false)
    .with_minimize(false)
    .with_maximize(true)
  assert_false(buttons.close())
  assert_false(buttons.minimize())
  assert_true(buttons.maximize())
}

///|
test "ime capability and request models are constructible" {
  let capabilities = ImeCapabilities::new(true, true, false)
  assert_true(capabilities.hint_and_purpose())
  assert_true(capabilities.cursor_area())
  assert_false(capabilities.surrounding_text())
  let surrounding = try! ImeSurroundingText::new("editor", 3, 1)
  let capabilities_for_enable = ImeCapabilities::new(true, true, true)
  let hints = ImeHint::completion().union(ImeHint::spellcheck())
  assert_eq(surrounding.text(), "editor")
  assert_eq(surrounding.cursor(), 3)
  assert_eq(surrounding.anchor(), 1)
  assert_true(hints.contains(ImeHint::completion()))
  assert_true(hints.contains(ImeHint::spellcheck()))
  assert_false(hints.contains(ImeHint::multiline()))
  assert_eq(ImeHint::from_bits(1025), ImeHint::completion())
  assert_eq(
    ImeRequest::Enable(capabilities_for_enable),
    ImeRequest::Enable(capabilities_for_enable),
  )
  assert_eq(ImeRequest::Disable, ImeRequest::Disable)
  assert_eq(
    ImeRequest::SetHintAndPurpose(hints, ImePurpose::Email),
    ImeRequest::SetHintAndPurpose(hints, ImePurpose::Email),
  )
  assert_eq(
    ImeRequest::SetPurpose(ImePurpose::DateTime),
    ImeRequest::SetPurpose(ImePurpose::DateTime),
  )
  assert_eq(
    ImeRequest::SetSurroundingText(Some(surrounding)),
    ImeRequest::SetSurroundingText(Some(surrounding)),
  )
  let cursor_out_of_range = try {
    ImeSurroundingText::new("abc", -1, 0) |> ignore
    false
  } catch {
    ImeSurroundingTextError::CursorOutOfRange(-1, 3) => true
    _ => false
  }
  assert_true(cursor_out_of_range)
  let anchor_out_of_range = try {
    ImeSurroundingText::new("abc", 1, 8) |> ignore
    false
  } catch {
    ImeSurroundingTextError::AnchorOutOfRange(8, 3) => true
    _ => false
  }
  assert_true(anchor_out_of_range)
  let ime_error_show = "\{ImeRequestError::NotSupported}"
  assert_true(ime_error_show.length() > 0)
}

///|
test "activation token can be round-tripped" {
  let token = ActivationToken::from_raw("activation-token")
  assert_eq(token.as_raw(), "activation-token")
  assert_eq(token.into_raw(), "activation-token")
}

///|
test "custom cursor models are constructible" {
  let cursor = CustomCursor::from_raw((7 : Int).to_uint64())
  assert_eq(cursor.into_raw(), (7 : Int).to_uint64())
  assert_eq(Cursor::Custom(cursor), Cursor::Custom(cursor))
  let source = try! CustomCursorSource::from_rgba(
    Bytes::make(4, (255 : Int).to_byte()),
    1,
    1,
    0,
    0,
  )
  assert_eq(
    source,
    CustomCursorSource::Rgba(Bytes::make(4, (255 : Int).to_byte()), 1, 1, 0, 0),
  )
  let animated = try! CustomCursorSource::from_animation(16, [cursor])
  assert_eq(animated, CustomCursorSource::Animation(16, [cursor]))
  let bad_hotspot = try {
    CustomCursorSource::from_rgba(
      Bytes::make(4, (255 : Int).to_byte()),
      1,
      1,
      1,
      0,
    )
    |> ignore
    false
  } catch {
    BadCustomCursorSource::HotspotOutOfBounds(1, 1, 1, 0) => true
    _ => false
  }
  assert_true(bad_hotspot)
  let empty_animation = try {
    CustomCursorSource::from_animation(16, []) |> ignore
    false
  } catch {
    BadCustomCursorAnimation::Empty => true
    _ => false
  }
  assert_true(empty_animation)
  let bad_duration = try {
    CustomCursorSource::from_animation(0, [cursor]) |> ignore
    false
  } catch {
    BadCustomCursorAnimation::NonPositiveFrameDuration(0) => true
    _ => false
  }
  assert_true(bad_duration)
}

///|
test "icon validation follows winit rgba rules" {
  let bad_alignment = try {
    Icon::new(Bytes::make(3, (1 : Int).to_byte()), 1, 1) |> ignore
    false
  } catch {
    BadIcon::ByteCountNotDivisibleBy4(3) => true
    _ => false
  }
  assert_true(bad_alignment)
  let bad_dimensions = try {
    Icon::new(Bytes::make(8, (1 : Int).to_byte()), 1, 1) |> ignore
    false
  } catch {
    BadIcon::DimensionsVsPixelCount(1, 1, 1, 2) => true
    _ => false
  }
  assert_true(bad_dimensions)
  let icon = try! Icon::new(Bytes::make(4, (1 : Int).to_byte()), 1, 1)
  assert_eq(icon.width(), 1)
  assert_eq(icon.height(), 1)
  assert_eq(icon.rgba().length(), 4)
}
