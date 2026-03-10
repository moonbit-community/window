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
  assert_eq(
    attrs.surface_size(),
    Some(@dpi.PhysicalSize::new(800, 600).into_size()),
  )
  assert_eq(attrs.surface_resize_increments(), None)
  assert_eq(attrs.min_surface_size(), None)
  assert_eq(attrs.max_surface_size(), None)
  assert_eq(attrs.position(), None)
  assert_eq(attrs.parent_window(), None)
  assert_true(attrs.platform_attributes().accepts_first_mouse())
  assert_false(attrs.platform_attributes().disallow_hidpi())
  assert_false(attrs.platform_attributes().fullsize_content_view())
  assert_true(attrs.platform_attributes().has_shadow())
  assert_false(attrs.platform_attributes().movable_by_window_background())
  assert_eq(attrs.platform_attributes().simple_fullscreen(), None)
  assert_false(attrs.platform_attributes().borderless_game())
  assert_eq(attrs.platform_attributes().option_as_alt(), OptionAsAlt::None)
  assert_eq(attrs.platform_attributes().tabbing_identifier(), None)
  assert_false(attrs.platform_attributes().title_hidden())
  assert_false(attrs.platform_attributes().titlebar_hidden())
  assert_false(attrs.platform_attributes().titlebar_buttons_hidden())
  assert_false(attrs.platform_attributes().titlebar_transparent())
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
    .with_surface_size(@dpi.PhysicalSize::new(1024, 768).into_size())
    .with_surface_resize_increments(@dpi.PhysicalSize::new(32, 24).into_size())
    .with_min_surface_size(@dpi.PhysicalSize::new(640, 480).into_size())
    .with_max_surface_size(@dpi.PhysicalSize::new(1920, 1080).into_size())
    .with_position(@dpi.PhysicalPosition::new(320, 180).into_position())
    .with_parent_window(Some(parent_window))
    .with_platform_attributes(
      PlatformWindowAttributes::default()
      .with_accepts_first_mouse(false)
      .with_disallow_hidpi(true)
      .with_fullsize_content_view(true)
      .with_has_shadow(false)
      .with_movable_by_window_background(true)
      .with_simple_fullscreen(Some(true))
      .with_borderless_game(true)
      .with_option_as_alt(OptionAsAlt::OnlyLeft)
      .with_tabbing_identifier("group-a")
      .with_title_hidden(true)
      .with_titlebar_hidden(true)
      .with_titlebar_buttons_hidden(true)
      .with_titlebar_transparent(true),
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
  assert_eq(
    attrs.surface_size(),
    Some(@dpi.PhysicalSize::new(1024, 768).into_size()),
  )
  assert_eq(
    attrs.surface_resize_increments(),
    Some(@dpi.PhysicalSize::new(32, 24).into_size()),
  )
  assert_eq(
    attrs.min_surface_size(),
    Some(@dpi.PhysicalSize::new(640, 480).into_size()),
  )
  assert_eq(
    attrs.max_surface_size(),
    Some(@dpi.PhysicalSize::new(1920, 1080).into_size()),
  )
  assert_eq(
    attrs.position(),
    Some(@dpi.PhysicalPosition::new(320, 180).into_position()),
  )
  assert_eq(attrs.parent_window(), Some(parent_window))
  assert_false(attrs.platform_attributes().accepts_first_mouse())
  assert_true(attrs.platform_attributes().disallow_hidpi())
  assert_true(attrs.platform_attributes().fullsize_content_view())
  assert_false(attrs.platform_attributes().has_shadow())
  assert_true(attrs.platform_attributes().movable_by_window_background())
  assert_eq(attrs.platform_attributes().simple_fullscreen(), Some(true))
  assert_true(attrs.platform_attributes().borderless_game())
  assert_eq(attrs.platform_attributes().option_as_alt(), OptionAsAlt::OnlyLeft)
  assert_eq(attrs.platform_attributes().tabbing_identifier(), Some("group-a"))
  assert_true(attrs.platform_attributes().title_hidden())
  assert_true(attrs.platform_attributes().titlebar_hidden())
  assert_true(attrs.platform_attributes().titlebar_buttons_hidden())
  assert_true(attrs.platform_attributes().titlebar_transparent())
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
test "winit-compatible window attribute aliases reuse surface fields" {
  let attrs = WindowAttributes::default()
    .with_inner_size(@dpi.PhysicalSize::new(111, 222).into_size())
    .with_resize_increments(@dpi.PhysicalSize::new(3, 4).into_size())
    .with_min_inner_size(@dpi.PhysicalSize::new(10, 20).into_size())
    .with_max_inner_size(@dpi.PhysicalSize::new(300, 400).into_size())
  assert_eq(attrs.inner_size(), attrs.surface_size())
  assert_eq(attrs.resize_increments(), attrs.surface_resize_increments())
  assert_eq(attrs.min_inner_size(), attrs.min_surface_size())
  assert_eq(attrs.max_inner_size(), attrs.max_surface_size())
  assert_eq(
    attrs.inner_size(),
    Some(@dpi.PhysicalSize::new(111, 222).into_size()),
  )
  assert_eq(
    attrs.resize_increments(),
    Some(@dpi.PhysicalSize::new(3, 4).into_size()),
  )
  assert_eq(
    attrs.min_inner_size(),
    Some(@dpi.PhysicalSize::new(10, 20).into_size()),
  )
  assert_eq(
    attrs.max_inner_size(),
    Some(@dpi.PhysicalSize::new(300, 400).into_size()),
  )
}

///|
test "ime capability and request models are constructible" {
  let capabilities = ImeCapabilities::default()
    .with_hint_and_purpose()
    .with_cursor_area()
  assert_true(capabilities.hint_and_purpose())
  assert_true(capabilities.cursor_area())
  assert_false(capabilities.surrounding_text())
  let surrounding = try! ImeSurroundingText::new("editor", 3, 1)
  let surrounding_for_into_text = try! ImeSurroundingText::new("editor", 3, 1)
  let capabilities_for_enable = ImeCapabilities::all()
  let hints = ImeHint::completion().union(ImeHint::spellcheck())
  let request_data = ImeRequestData::default()
    .with_hint_and_purpose(hints, ImePurpose::Email)
    .with_cursor_area(
      @dpi.PhysicalPosition::new(48, 96).into_position(),
      @dpi.PhysicalSize::new(20, 32).into_size(),
    )
    .with_surrounding_text(surrounding)
  let empty_request_data = ImeRequestData::default()
  assert_eq(surrounding.text(), "editor")
  assert_eq(surrounding.cursor(), 3)
  assert_eq(surrounding.anchor(), 1)
  assert_eq(ImeSurroundingText::max_text_bytes(), 4000)
  assert_eq(surrounding_for_into_text.into_text(), "editor")
  assert_true(hints.contains(ImeHint::completion()))
  assert_true(hints.contains(ImeHint::spellcheck()))
  assert_false(hints.contains(ImeHint::multiline()))
  assert_eq(ImeHint::from_bits(1025), ImeHint::completion())
  assert_eq(request_data.hint(), Some(hints))
  assert_eq(request_data.hint_and_purpose(), Some((hints, ImePurpose::Email)))
  assert_eq(request_data.purpose(), Some(ImePurpose::Email))
  assert_eq(
    request_data.cursor_area_position(),
    Some(@dpi.PhysicalPosition::new(48, 96).into_position()),
  )
  assert_eq(
    request_data.cursor_area(),
    Some(
      (
        @dpi.PhysicalPosition::new(48, 96).into_position(),
        @dpi.PhysicalSize::new(20, 32).into_size(),
      ),
    ),
  )
  assert_eq(
    request_data.cursor_area_size(),
    Some(@dpi.PhysicalSize::new(20, 32).into_size()),
  )
  assert_eq(request_data.surrounding_text(), Some(surrounding))
  assert_true(request_data.has_hint_and_purpose())
  assert_true(request_data.has_cursor_area())
  assert_true(request_data.has_surrounding_text())
  assert_false(request_data.is_empty())
  assert_true(
    empty_request_data
    .with_hint_and_purpose(hints, ImePurpose::Phone)
    .without_hint_and_purpose()
    .with_cursor_area(
      @dpi.PhysicalPosition::new(1, 2).into_position(),
      @dpi.PhysicalSize::new(3, 4).into_size(),
    )
    .without_cursor_area()
    .with_surrounding_text(surrounding)
    .without_surrounding_text()
    .is_empty(),
  )
  let enable_request = match
    ImeEnableRequest::new(capabilities_for_enable, request_data) {
    Some(enable_request) => enable_request
    None => abort("expected valid IME enable request")
  }
  assert_eq(enable_request.capabilities(), capabilities_for_enable)
  assert_eq(enable_request.request_data(), request_data)
  assert_eq(enable_request.into_raw(), (capabilities_for_enable, request_data))
  assert_eq(
    enable_request.into_request(),
    ImeRequest::EnableRequest(enable_request),
  )
  assert_eq(request_data.into_request(), ImeRequest::Update(request_data))
  assert_true(ImeEnableRequest::new(capabilities, request_data) is None)
  assert_true(
    ImeEnableRequest::new(ImeCapabilities::default(), empty_request_data)
    is Some(_),
  )
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
