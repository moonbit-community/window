///|
test "root package creates event loop with wait control flow" {
  let event_loop = create_event_loop()
  assert_eq(event_loop.control_flow(), @core.ControlFlow::Wait)
}
