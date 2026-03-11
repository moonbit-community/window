///|
test "root package creates event loop with wait control flow" {
  let event_loop = create_event_loop()
  assert_eq(event_loop.control_flow(), @core.ControlFlow::Wait)
}

///|
test "root package exposes raise-based event loop constructors" {
  let event_loop = try! try_create_event_loop()
  assert_eq(event_loop.control_flow(), @core.ControlFlow::Wait)

  let event_loop_with_platform_attributes = try! try_create_event_loop_with_platform_attributes(
    @core.PlatformEventLoopAttributes::default(),
  )
  assert_eq(
    event_loop_with_platform_attributes.control_flow(),
    @core.ControlFlow::Wait,
  )
}

///|
test "root package exposes event loop builder convenience" {
  let event_loop = create_event_loop_builder()
    .with_activation_policy(@core.ActivationPolicy::Accessory)
    .with_default_menu(false)
    .with_activate_ignoring_other_apps(false)
    .build()
  assert_eq(event_loop.control_flow(), @core.ControlFlow::Wait)
}

///|
test "root package default control flow mirrors core defaults" {
  assert_eq(default_control_flow(), @core.ControlFlow::default())
}
