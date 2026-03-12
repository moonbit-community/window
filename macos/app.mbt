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
// Port target: app.rs::maybe_dispatch_device_event
pub fn[A : ApplicationHandler] dispatch_device_pointer_motion(
  app : A,
  event_loop : ActiveEventLoop,
  delta_x : Double,
  delta_y : Double,
) -> Unit {
  if delta_x == 0.0 && delta_y == 0.0 {
    ()
  } else {
    app.device_event(
      event_loop,
      None,
      @core.DeviceEvent::PointerMotion(delta_x, delta_y),
    )
  }
}

///|
// Port target: app.rs::maybe_dispatch_device_event
pub fn[A : ApplicationHandler] dispatch_device_button(
  app : A,
  event_loop : ActiveEventLoop,
  button : Int,
  state : @core.ElementState,
) -> Unit {
  if button >= 0 {
    app.device_event(
      event_loop,
      None,
      @core.DeviceEvent::Button(@core.ButtonId::from_raw(button), state),
    )
  }
}

///|
// Port target: app.rs::maybe_dispatch_device_event
pub fn[A : ApplicationHandler] maybe_dispatch_device_event(
  app : A,
  event_loop : ActiveEventLoop,
  native_event_kind : Int,
  button : Int,
  delta_x : Double,
  delta_y : Double,
) -> Bool {
  match native_event_kind {
    1 => {
      dispatch_device_pointer_motion(app, event_loop, delta_x, delta_y)
      true
    }
    2 => {
      dispatch_device_button(
        app,
        event_loop,
        button,
        @core.ElementState::Pressed,
      )
      true
    }
    3 => {
      dispatch_device_button(
        app,
        event_loop,
        button,
        @core.ElementState::Released,
      )
      true
    }
    _ => false
  }
}

///|
// Port target: app.rs::override_send_event
pub fn install_application_event_hook() -> Unit {
  ()
}
