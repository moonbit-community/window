///|
test "platform_event_loop_attributes_any_thread_defaults_false" {
  let attributes = PlatformEventLoopAttributes::default()
  assert_false(attributes.any_thread())
}

///|
test "platform_event_loop_attributes_with_any_thread_updates_value" {
  let attributes = PlatformEventLoopAttributes::default().with_any_thread(true)
  assert_true(attributes.any_thread())
}
