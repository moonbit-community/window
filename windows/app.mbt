///|
pub(open) trait ApplicationHandler {
  fn new_events(Self, ActiveEventLoop, @core.StartCause) -> Unit = _
  fn resumed(Self, ActiveEventLoop) -> Unit = _
  fn can_create_surfaces(Self, ActiveEventLoop) -> Unit = _
  fn proxy_wake_up(Self, ActiveEventLoop) -> Unit = _
  fn window_event(Self, ActiveEventLoop, @core.WindowId, @core.WindowEvent) -> Unit = _
  fn device_event(Self, ActiveEventLoop, @core.DeviceId?, @core.DeviceEvent) -> Unit = _
  fn about_to_wait(Self, ActiveEventLoop) -> Unit = _
  fn suspended(Self, ActiveEventLoop) -> Unit = _
  fn destroy_surfaces(Self, ActiveEventLoop) -> Unit = _
  fn memory_warning(Self, ActiveEventLoop) -> Unit = _
  fn standard_key_binding(Self, ActiveEventLoop, @core.WindowId, String) -> Unit = _
}

///|
impl ApplicationHandler with fn new_events(_self, _event_loop, _cause) {
  ()
}

///|
impl ApplicationHandler with fn resumed(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with fn can_create_surfaces(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with fn proxy_wake_up(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with fn window_event(_self, _event_loop, _id, _event) {
  ()
}

///|
impl ApplicationHandler with fn device_event(
  _self,
  _event_loop,
  _device_id,
  _event,
) {
  ()
}

///|
impl ApplicationHandler with fn about_to_wait(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with fn suspended(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with fn destroy_surfaces(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with fn memory_warning(_self, _event_loop) {
  ()
}

///|
impl ApplicationHandler with fn standard_key_binding(
  _self,
  _event_loop,
  _window_id,
  _action,
) {
  ()
}
