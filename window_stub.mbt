///|
pub fn create_event_loop() -> @macos.EventLoop {
  @macos.EventLoop::new()
}

///|
pub fn default_control_flow() -> @core.ControlFlow {
  @core.ControlFlow::Wait
}
