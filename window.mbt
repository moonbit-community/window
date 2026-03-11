///|
/// Convenience entry for the current macOS-first MVP.
pub fn create_event_loop() -> @macos.EventLoop {
  @macos.EventLoop::new()
}

///|
pub fn try_create_event_loop() -> @macos.EventLoop raise @core.EventLoopError {
  @macos.EventLoop::try_new()
}

///|
/// Convenience builder aligned with upstream `EventLoop::builder`.
pub fn create_event_loop_builder() -> @macos.EventLoopBuilder {
  @macos.EventLoop::builder()
}

///|
pub fn create_event_loop_with_platform_attributes(
  attributes : @core.PlatformEventLoopAttributes,
) -> @macos.EventLoop {
  @macos.EventLoop::new_with_platform_attributes(attributes)
}

///|
pub fn try_create_event_loop_with_platform_attributes(
  attributes : @core.PlatformEventLoopAttributes,
) -> @macos.EventLoop raise @core.EventLoopError {
  @macos.EventLoop::try_new_with_platform_attributes(attributes)
}

///|
pub fn default_control_flow() -> @core.ControlFlow {
  @core.ControlFlow::default()
}
