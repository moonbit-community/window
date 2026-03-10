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
  let _ = event_loop.rwh_06_handle()
  let _ = event_loop.owned_display_handle()
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
test "parent window attribute accepts native window handles" {
  let event_loop = EventLoop::new()
  let parent = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let parent_handle = parent.rwh_06_window_handle()
  let child = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_parent_window(Some(@core.ParentWindow::from_raw(parent_handle))),
  )
  assert_true(parent_handle > (0 : Int).to_uint64())
  assert_true(child.rwh_06_window_handle() > (0 : Int).to_uint64())
}
