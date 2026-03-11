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

///|
test "control flow and activation policy default values match winit" {
  assert_eq(ControlFlow::default(), ControlFlow::Wait)
  assert_eq(ActivationPolicy::default(), ActivationPolicy::Regular)
  assert_eq(DeviceEvents::default(), DeviceEvents::WhenFocused)
}

///|
test "pump status variants are stable values" {
  assert_eq(PumpStatus::Continue, PumpStatus::Continue)
  assert_eq(PumpStatus::Exit(0), PumpStatus::Exit(0))
}

///|
test "event loop error variants are available for raise-based APIs" {
  assert_eq(EventLoopError::NotSupported, EventLoopError::NotSupported)
  assert_eq(
    EventLoopError::RecreationAttempt,
    EventLoopError::RecreationAttempt,
  )
  assert_eq(EventLoopError::ExitFailure(1), EventLoopError::ExitFailure(1))
  assert_eq(EventLoopError::Os, EventLoopError::Os)
}
