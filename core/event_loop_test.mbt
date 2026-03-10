///|
test "platform event loop attributes follow winit defaults" {
  let attrs = PlatformEventLoopAttributes::default()
  assert_eq(attrs.activation_policy(), None)
  assert_true(attrs.default_menu())
  assert_true(attrs.activate_ignoring_other_apps())
}

///|
test "platform event loop attributes builders update fields" {
  let attrs = PlatformEventLoopAttributes::default()
    .with_activation_policy(ActivationPolicy::Accessory)
    .with_default_menu(false)
    .with_activate_ignoring_other_apps(false)
  assert_eq(attrs.activation_policy(), Some(ActivationPolicy::Accessory))
  assert_false(attrs.default_menu())
  assert_false(attrs.activate_ignoring_other_apps())
}
