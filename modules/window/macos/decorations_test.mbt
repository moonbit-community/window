///|
test "set_decorations_true_preserves_traffic_lights" {
  let event_loop = EventLoop::EventLoop()
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )

  window.set_decorations(true)
  let first = window.enabled_buttons()
  assert_true(first.close())
  assert_true(first.minimize())
  if window.is_resizable() {
    assert_true(first.maximize())
  }

  window.set_decorations(false)
  assert_false(window.is_decorated())

  window.set_decorations(true)
  assert_true(window.is_decorated())
  let second = window.enabled_buttons()
  assert_true(second.close())
  assert_true(second.minimize())
  if window.is_resizable() {
    assert_true(second.maximize())
  }

  let handle = window.window_handle()
  let raw = try! handle.as_raw()
  guard raw is AppKit(appkit) else { fail("expected an AppKit window handle") }
  let content_view = try! window.content_view_handle()
  assert_eq(content_view, appkit.ns_view())
  let display = window.display_handle()
  let raw_display = try! display.as_raw()
  guard raw_display is AppKit(_) else {
    fail("expected an AppKit display handle")
  }

  window.drop()
  let unavailable = try {
    ignore(handle.as_raw())
    false
  } catch {
    _ => true
  }
  assert_true(unavailable)
}
