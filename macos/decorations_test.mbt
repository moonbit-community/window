///|
test "set_decorations_true_preserves_traffic_lights" {
  let event_loop = EventLoop::new()
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
}
