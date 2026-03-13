///|
// Port target: winit-reference/winit-appkit/src/app.rs

///|
pub(open) trait ApplicationHandler {
  new_events(Self, ActiveEventLoop, @core.StartCause) -> Unit = _
  resumed(Self, ActiveEventLoop) -> Unit = _
  can_create_surfaces(Self, ActiveEventLoop) -> Unit = _
  proxy_wake_up(Self, ActiveEventLoop) -> Unit = _
  window_event(Self, ActiveEventLoop, @core.WindowId, @core.WindowEvent) -> Unit = _
  device_event(Self, ActiveEventLoop, @core.DeviceId?, @core.DeviceEvent) -> Unit = _
  about_to_wait(Self, ActiveEventLoop) -> Unit = _
  suspended(Self, ActiveEventLoop) -> Unit = _
  destroy_surfaces(Self, ActiveEventLoop) -> Unit = _
  memory_warning(Self, ActiveEventLoop) -> Unit = _
  standard_key_binding(Self, ActiveEventLoop, @core.WindowId, String) -> Unit = _
  macos_handler(Self) -> Bool = _
}

///|
impl ApplicationHandler with new_events(_self, _event_loop, _cause) {
  ()
}

///|
impl ApplicationHandler with resumed(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with can_create_surfaces(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with proxy_wake_up(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with window_event(_self, _event_loop, _id, _event) {
  ()
}

///|
impl ApplicationHandler with device_event(
  _self,
  _event_loop,
  _device_id,
  _event,
) {
  ()
}

///|
impl ApplicationHandler with about_to_wait(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with suspended(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with destroy_surfaces(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with memory_warning(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with standard_key_binding(
  _self,
  _event_loop,
  _window_id,
  _action,
) {
  ()
}

///|
impl ApplicationHandler with macos_handler(_self) {
  false
}

///|
// Port target: app.rs::send_event
fn[A : ApplicationHandler] EventLoop::send_event(
  self : EventLoop,
  app : A,
) -> Unit {
  dispatch_deferred_callbacks(app, self.as_active())
}

///|
// Port target: app.rs::override_send_event
fn override_send_event() -> Unit {
  native_override_send_event()
}
