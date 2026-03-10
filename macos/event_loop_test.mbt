///|
struct LifecycleCallbacksApp {
  can_create_surfaces_called : Ref[Bool]
  destroy_surfaces_called : Ref[Bool]
  resumed_called : Ref[Bool]
  suspended_called : Ref[Bool]
}

///|
impl ApplicationHandler for LifecycleCallbacksApp with resumed(
  self,
  _event_loop,
) {
  self.resumed_called.val = true
}

///|
impl ApplicationHandler for LifecycleCallbacksApp with can_create_surfaces(
  self,
  event_loop,
) {
  self.can_create_surfaces_called.val = true
  event_loop.exit()
}

///|
impl ApplicationHandler for LifecycleCallbacksApp with destroy_surfaces(
  self,
  _event_loop,
) {
  self.destroy_surfaces_called.val = true
}

///|
impl ApplicationHandler for LifecycleCallbacksApp with suspended(
  self,
  _event_loop,
) {
  self.suspended_called.val = true
}

///|
test "run_app dispatches lifecycle callbacks on startup and shutdown" {
  let app : LifecycleCallbacksApp = {
    can_create_surfaces_called: Ref::new(false),
    destroy_surfaces_called: Ref::new(false),
    resumed_called: Ref::new(false),
    suspended_called: Ref::new(false),
  }
  let event_loop = EventLoop::new()
  event_loop.run_app(app)
  assert_true(app.resumed_called.val)
  assert_true(app.can_create_surfaces_called.val)
  assert_true(app.destroy_surfaces_called.val)
  assert_true(app.suspended_called.val)
}

///|
test "system theme and device event policy APIs are callable" {
  let event_loop = EventLoop::new()
  event_loop.listen_device_events(@core.DeviceEvents::Always)
  let _ = event_loop.system_theme()
  assert_eq(event_loop.owned_display_handle(), event_loop.rwh_06_handle())
  assert_eq(event_loop.display_handle(), event_loop.rwh_06_handle())
}

///|
test "create_custom_cursor supports url cursor sources" {
  let event_loop = EventLoop::new()
  let cursor = try! event_loop.create_custom_cursor(
    @core.CustomCursorSource::Url(
      "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericDocumentIcon.icns",
      1, 1,
    ),
  )
  assert_true(cursor.into_raw() > (0 : Int).to_uint64())
}

///|
test "create_custom_cursor supports rgba cursor sources" {
  let event_loop = EventLoop::new()
  let source = try! @core.CustomCursorSource::from_rgba(
    Bytes::make(4, (255 : Int).to_byte()),
    1,
    1,
    0,
    0,
  )
  let cursor = try! event_loop.create_custom_cursor(source)
  assert_true(cursor.into_raw() > (0 : Int).to_uint64())
}

///|
test "create_custom_cursor reports not supported for animation sources" {
  let event_loop = EventLoop::new()
  let frame_source = try! @core.CustomCursorSource::from_rgba(
    Bytes::make(4, (255 : Int).to_byte()),
    1,
    1,
    0,
    0,
  )
  let frame = try! event_loop.create_custom_cursor(frame_source)
  let animated = try! @core.CustomCursorSource::from_animation(16, [frame])
  let not_supported = try {
    event_loop.create_custom_cursor(animated) |> ignore
    false
  } catch {
    @core.RequestError::NotSupported(_) => true
    _ => false
  }
  assert_true(not_supported)
}

///|
test "parent window attribute accepts native window handles" {
  let event_loop = EventLoop::new()
  let parent = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let parent_handle = parent.rwh_06_window_handle()
  assert_eq(parent.display_handle(), parent.rwh_06_display_handle())
  assert_eq(parent.window_handle(), parent_handle)
  let child = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_parent_window(Some(@core.ParentWindow::from_raw(parent_handle))),
  )
  assert_true(parent_handle > (0 : Int).to_uint64())
  assert_true(child.rwh_06_window_handle() > (0 : Int).to_uint64())
}

///|
test "simple fullscreen can be toggled independently of native fullscreen" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  assert_false(window.simple_fullscreen())
  assert_false(window.is_fullscreen())
  assert_eq(window.fullscreen(), None)
  assert_true(window.set_simple_fullscreen(true))
  assert_true(window.simple_fullscreen())
  assert_false(window.is_fullscreen())
  assert_eq(window.fullscreen(), None)
  assert_false(window.set_simple_fullscreen(true))
  assert_true(window.set_simple_fullscreen(false))
  assert_false(window.simple_fullscreen())
  assert_false(window.set_simple_fullscreen(false))
}

///|
test "borderless game flag can be configured at create and runtime" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_platform_attributes(
      @core.PlatformWindowAttributes::default().with_borderless_game(true),
    ),
  )
  assert_true(window.is_borderless_game())
  window.set_borderless_game(false)
  assert_false(window.is_borderless_game())
  window.set_borderless_game(true)
  assert_true(window.is_borderless_game())
}

///|
test "simple fullscreen attribute applies at creation time without native fullscreen state" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_platform_attributes(
      @core.PlatformWindowAttributes::default().with_simple_fullscreen(
        Some(true),
      ),
    ),
  )
  assert_true(window.simple_fullscreen())
  assert_false(window.is_fullscreen())
  assert_eq(window.fullscreen(), None)
  assert_true(window.set_simple_fullscreen(false))
}

///|
test "macos shadow and document edited APIs reflect runtime updates" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let initial_shadow = window.has_shadow()
  window.set_has_shadow(false)
  assert_false(window.has_shadow())
  window.set_has_shadow(true)
  assert_true(window.has_shadow())
  ignore(initial_shadow)
  assert_false(window.is_document_edited())
  window.set_document_edited(true)
  assert_true(window.is_document_edited())
  window.set_document_edited(false)
  assert_false(window.is_document_edited())
}

///|
test "macos platform window attributes apply tabbing option-as-alt and shadow at creation time" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_platform_attributes(
      @core.PlatformWindowAttributes::default()
      .with_has_shadow(false)
      .with_tabbing_identifier("group-a")
      .with_option_as_alt(@core.OptionAsAlt::OnlyLeft),
    ),
  )
  assert_false(window.has_shadow())
  assert_eq(window.tabbing_identifier(), "group-a")
  assert_eq(window.option_as_alt(), @core.OptionAsAlt::OnlyLeft)
  assert_eq(window.num_tabs(), 1)
}

///|
test "macos tabbing and option-as-alt APIs reflect runtime updates" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  window.set_tabbing_identifier("group-b")
  assert_eq(window.tabbing_identifier(), "group-b")
  window.select_next_tab()
  window.select_previous_tab()
  window.select_tab_at_index(0)
  window.select_tab_at_index(99)
  assert_true(window.num_tabs() >= 1)
  assert_eq(window.option_as_alt(), @core.OptionAsAlt::None)
  window.set_option_as_alt(@core.OptionAsAlt::Both)
  assert_eq(window.option_as_alt(), @core.OptionAsAlt::Both)
  window.set_option_as_alt(@core.OptionAsAlt::OnlyRight)
  assert_eq(window.option_as_alt(), @core.OptionAsAlt::OnlyRight)
}

///|
test "macos event loop automatic tabbing can be toggled" {
  let event_loop = EventLoop::new()
  let initial = event_loop.allows_automatic_window_tabbing()
  event_loop.set_allows_automatic_window_tabbing(false)
  assert_false(event_loop.allows_automatic_window_tabbing())
  event_loop.set_allows_automatic_window_tabbing(true)
  assert_true(event_loop.allows_automatic_window_tabbing())
  event_loop.set_allows_automatic_window_tabbing(initial)
}
