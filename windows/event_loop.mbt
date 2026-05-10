///|
pub struct EventLoopProxy {
  priv thread_id : UInt
} derive(Eq, Debug)

///|
pub fn EventLoopProxy::wake_up(self : EventLoopProxy) -> Unit {
  ignore(native_post_thread_message(self.thread_id, 0x8000 + 0x100, 0, 0))
}

///|
pub struct EventLoop {
  priv msg_window : UInt64
  priv thread_id : UInt
} derive(Debug)

///|
pub struct EventLoopBuilder {
  priv mut platform_attributes_ : @core.PlatformEventLoopAttributes
} derive(Eq, Debug)

///|
pub struct ActiveEventLoop {
  priv inner : EventLoop
} derive(Debug)

///|
pub fn EventLoop::builder() -> EventLoopBuilder {
  EventLoopBuilder::new()
}

///|
pub fn EventLoopBuilder::new() -> EventLoopBuilder {
  { platform_attributes_: @core.PlatformEventLoopAttributes::default() }
}

///|
pub fn EventLoopBuilder::default() -> EventLoopBuilder {
  EventLoopBuilder::new()
}

///|
pub fn EventLoopBuilder::with_platform_attributes(
  self : EventLoopBuilder,
  platform_attributes : @core.PlatformEventLoopAttributes,
) -> EventLoopBuilder {
  self.platform_attributes_ = platform_attributes
  self
}

///|
pub fn EventLoopBuilder::platform_attributes(
  self : EventLoopBuilder,
) -> @core.PlatformEventLoopAttributes {
  self.platform_attributes_
}

///|
pub fn EventLoopBuilder::with_activation_policy(
  self : EventLoopBuilder,
  _activation_policy : @core.ActivationPolicy,
) -> EventLoopBuilder {
  self
}

///|
pub fn EventLoopBuilder::with_default_menu(
  self : EventLoopBuilder,
  _default_menu : Bool,
) -> EventLoopBuilder {
  self
}

///|
pub fn EventLoopBuilder::with_activate_ignoring_other_apps(
  self : EventLoopBuilder,
  _activate : Bool,
) -> EventLoopBuilder {
  self
}

///|
pub fn EventLoopBuilder::with_any_thread(
  self : EventLoopBuilder,
  _any_thread : Bool,
) -> EventLoopBuilder {
  self
}

///|
pub fn EventLoopBuilder::build(self : EventLoopBuilder) -> EventLoop {
  try! self.try_build()
}

///|
pub fn EventLoopBuilder::try_build(
  self : EventLoopBuilder,
) -> EventLoop raise @core.EventLoopError {
  EventLoop::try_new_with_platform_attributes(self.platform_attributes_)
}

///|
pub fn EventLoop::new() -> EventLoop {
  try! EventLoop::try_new()
}

///|
pub fn EventLoop::try_new() -> EventLoop raise @core.EventLoopError {
  EventLoop::builder().try_build()
}

///|
pub fn EventLoop::new_with_platform_attributes(
  attributes : @core.PlatformEventLoopAttributes,
) -> EventLoop {
  try! EventLoop::try_new_with_platform_attributes(attributes)
}

///|
pub fn EventLoop::try_new_with_platform_attributes(
  _attributes : @core.PlatformEventLoopAttributes,
) -> EventLoop raise @core.EventLoopError {
  if event_loop_global_created.val {
    raise @core.EventLoopError::RecreationAttempt
  }
  ignore(native_set_process_dpi_awareness_context((-4 : Int).to_uint64()))
  if native_register_window_class() == 0 {
    raise @core.EventLoopError::Os
  }
  let msg_window = native_create_msg_window()
  let thread_id = native_get_current_thread_id()
  app_state_set_msg_window(msg_window)
  app_state_set_thread_id(thread_id)
  app_state_install_native_callbacks()
  event_loop_global_created.val = true
  { msg_window, thread_id }
}

///|
fn EventLoop::as_active(self : EventLoop) -> ActiveEventLoop {
  { inner: self }
}

///|
pub fn EventLoop::window_target(self : EventLoop) -> ActiveEventLoop {
  self.as_active()
}

///|
pub fn EventLoop::drop(self : EventLoop) -> Unit {
  let _ = self
}

///|
pub fn EventLoop::create_window(
  self : EventLoop,
  attributes : @core.WindowAttributes,
) -> Window {
  try! self.try_create_window(attributes)
}

///|
pub fn EventLoop::try_create_window(
  self : EventLoop,
  attributes : @core.WindowAttributes,
) -> Window raise @core.RequestError {
  Window::new(self, attributes)
}

///|
pub fn EventLoop::create_proxy(self : EventLoop) -> EventLoopProxy {
  { thread_id: self.thread_id }
}

///|
pub fn EventLoop::set_control_flow(
  _self : EventLoop,
  control_flow : @core.ControlFlow,
) -> Unit {
  app_state_set_control_flow(control_flow)
}

///|
pub fn EventLoop::control_flow(self : EventLoop) -> @core.ControlFlow {
  let _ = self
  app_state_control_flow()
}

///|
pub fn EventLoop::exit(_self : EventLoop) -> Unit {
  app_state_set_exit(0)
}

///|
pub fn EventLoop::exiting(self : EventLoop) -> Bool {
  let _ = self
  app_state_exit_requested()
}

///|
pub fn EventLoop::available_monitors(
  _self : EventLoop,
) -> Array[@core.MonitorHandle] {
  available_monitors()
}

///|
pub fn EventLoop::primary_monitor(_self : EventLoop) -> @core.MonitorHandle? {
  primary_monitor()
}

///|
pub fn EventLoop::system_theme(_self : EventLoop) -> @core.Theme? {
  theme_from_native(native_system_theme())
}

///|
pub fn EventLoop::hide_application(self : EventLoop) -> Unit {
  self.as_active().hide_application()
}

///|
pub fn EventLoop::hide_other_applications(self : EventLoop) -> Unit {
  self.as_active().hide_other_applications()
}

///|
pub fn EventLoop::set_allows_automatic_window_tabbing(
  self : EventLoop,
  _enabled : Bool,
) -> Unit {
  let _ = self
  ()
}

///|
pub fn EventLoop::allows_automatic_window_tabbing(self : EventLoop) -> Bool {
  let _ = self
  false
}

///|
pub fn EventLoop::listen_device_events(
  _self : EventLoop,
  _allowed : @core.DeviceEvents,
) -> Unit {
  ()
}

///|
pub fn EventLoop::create_custom_cursor(
  self : EventLoop,
  _source : @core.CustomCursorSource,
) -> @core.CustomCursor raise @core.RequestError {
  let _ = self
  raise @core.RequestError::NotSupported
}

///|
pub fn EventLoop::display_handle(self : EventLoop) -> UInt64 {
  self.owned_display_handle()
}

///|
pub fn EventLoop::owned_display_handle(self : EventLoop) -> UInt64 {
  (0 : Int).to_uint64()
}

///|
pub fn EventLoop::rwh_06_handle(self : EventLoop) -> UInt64 {
  (0 : Int).to_uint64()
}

///|
pub fn ActiveEventLoop::create_window(
  self : ActiveEventLoop,
  attributes : @core.WindowAttributes,
) -> Window {
  try! self.try_create_window(attributes)
}

///|
pub fn ActiveEventLoop::try_create_window(
  self : ActiveEventLoop,
  attributes : @core.WindowAttributes,
) -> Window raise @core.RequestError {
  self.inner.try_create_window(attributes)
}

///|
pub fn ActiveEventLoop::create_custom_cursor(
  self : ActiveEventLoop,
  source : @core.CustomCursorSource,
) -> @core.CustomCursor raise @core.RequestError {
  self.inner.create_custom_cursor(source)
}

///|
pub fn ActiveEventLoop::available_monitors(
  self : ActiveEventLoop,
) -> Array[@core.MonitorHandle] {
  self.inner.available_monitors()
}

///|
pub fn ActiveEventLoop::primary_monitor(
  self : ActiveEventLoop,
) -> @core.MonitorHandle? {
  self.inner.primary_monitor()
}

///|
pub fn ActiveEventLoop::create_proxy(self : ActiveEventLoop) -> EventLoopProxy {
  self.inner.create_proxy()
}

///|
pub fn ActiveEventLoop::listen_device_events(
  self : ActiveEventLoop,
  allowed : @core.DeviceEvents,
) -> Unit {
  self.inner.listen_device_events(allowed)
}

///|
pub fn ActiveEventLoop::system_theme(self : ActiveEventLoop) -> @core.Theme? {
  self.inner.system_theme()
}

///|
pub fn ActiveEventLoop::hide_application(self : ActiveEventLoop) -> Unit {
  let _ = self
  ()
}

///|
pub fn ActiveEventLoop::hide_other_applications(self : ActiveEventLoop) -> Unit {
  let _ = self
  ()
}

///|
pub fn ActiveEventLoop::set_allows_automatic_window_tabbing(
  self : ActiveEventLoop,
  _enabled : Bool,
) -> Unit {
  let _ = self
  ()
}

///|
pub fn ActiveEventLoop::allows_automatic_window_tabbing(
  self : ActiveEventLoop,
) -> Bool {
  let _ = self
  false
}

///|
pub fn ActiveEventLoop::set_control_flow(
  self : ActiveEventLoop,
  control_flow : @core.ControlFlow,
) -> Unit {
  self.inner.set_control_flow(control_flow)
}

///|
pub fn ActiveEventLoop::control_flow(
  self : ActiveEventLoop,
) -> @core.ControlFlow {
  self.inner.control_flow()
}

///|
pub fn ActiveEventLoop::exit(self : ActiveEventLoop) -> Unit {
  self.inner.exit()
}

///|
pub fn ActiveEventLoop::exiting(self : ActiveEventLoop) -> Bool {
  self.inner.exiting()
}

///|
pub fn ActiveEventLoop::rwh_06_handle(self : ActiveEventLoop) -> UInt64 {
  self.inner.rwh_06_handle()
}

///|
pub fn ActiveEventLoop::owned_display_handle(self : ActiveEventLoop) -> UInt64 {
  self.inner.owned_display_handle()
}

///|
pub fn ActiveEventLoop::display_handle(self : ActiveEventLoop) -> UInt64 {
  self.inner.display_handle()
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_events(
  self : EventLoop,
  app : A,
) -> Unit {
  app_state_dispatch_redraws(app, self.as_active())
  app_state_dispatch_deferred_callbacks(app, self.as_active())
}

///|
fn[A : ApplicationHandler] EventLoop::run_message_loop(
  self : EventLoop,
  app : A,
  blocking : Bool,
  timeout_ms : Int?,
) -> Unit {
  let mut continue_loop = true
  while continue_loop {
    let has_msg = match app_state_control_flow() {
      Poll =>
        native_process_one_message((0 : Int).to_uint64(), 0, 0, pm_remove) != 0
      Wait =>
        if blocking {
          native_wait_and_process_message((0 : Int).to_uint64(), 0, 0) > 0
        } else {
          native_process_one_message((0 : Int).to_uint64(), 0, 0, pm_remove) !=
          0
        }
      WaitUntil(ms) =>
        match timeout_ms {
          Some(t) if t <= 0 =>
            native_process_one_message((0 : Int).to_uint64(), 0, 0, pm_remove) !=
            0
          Some(t) => native_wait_timeout_and_process(t.to_uint()) != 0
          None =>
            native_wait_and_process_message((0 : Int).to_uint64(), 0, 0) > 0
        }
    }
    self.dispatch_events(app)
    app_state_queue_callback(AboutToWait)
    app_state_dispatch_deferred_callbacks(app, self.as_active())
    if app_state_exit_requested() {
      continue_loop = false
    }
    match app_state_control_flow() {
      Poll => continue
      Wait => if has_msg == false && blocking == false { continue_loop = false }
      WaitUntil(_) =>
        if has_msg == false && blocking == false {
          continue_loop = false
        }
    }
  }
}

///|
pub fn[A : ApplicationHandler] EventLoop::run_app(
  self : EventLoop,
  app : A,
) -> Unit {
  try! self.try_run_app(app)
}

///|
pub fn[A : ApplicationHandler] EventLoop::try_run_app(
  self : EventLoop,
  app : A,
) -> Unit raise @core.EventLoopError {
  if app_state_is_running() {
    raise @core.EventLoopError::RecreationAttempt
  }
  app_state_set_running(true)
  app_state_set_dispatch_handler(app, self.as_active())
  app_state_dispatch_init_events(app, self.as_active())
  self.run_message_loop(app, true, None)
  app_state_internal_exit()
  app_state_clear_dispatch_handler()
}

///|
pub fn[A : ApplicationHandler] EventLoop::run_app_on_demand(
  self : EventLoop,
  app : A,
) -> Unit {
  try! self.try_run_app_on_demand(app)
}

///|
pub fn[A : ApplicationHandler] EventLoop::try_run_app_on_demand(
  self : EventLoop,
  app : A,
) -> Unit raise @core.EventLoopError {
  if app_state_is_running() {
    raise @core.EventLoopError::RecreationAttempt
  }
  app_state_set_running(true)
  app_state_clear_exit()
  app_state_set_dispatch_handler(app, self.as_active())
  app_state_dispatch_init_events(app, self.as_active())
  self.run_message_loop(app, true, None)
  app_state_internal_exit()
  app_state_clear_dispatch_handler()
}

///|
pub fn[A : ApplicationHandler] EventLoop::pump_app_events(
  self : EventLoop,
  timeout_ms : Int?,
  app : A,
) -> @core.PumpStatus {
  self.try_pump_app_events(timeout_ms, app)
}

///|
pub fn[A : ApplicationHandler] EventLoop::try_pump_app_events(
  self : EventLoop,
  timeout_ms : Int?,
  app : A,
) -> @core.PumpStatus {
  if app_state_is_running() == false {
    app_state_set_running(true)
    app_state_set_dispatch_handler(app, self.as_active())
    app_state_dispatch_init_events(app, self.as_active())
  } else {
    app_state_set_dispatch_handler(app, self.as_active())
  }
  self.run_message_loop(app, false, timeout_ms)
  app_state_clear_dispatch_handler()
  if app_state_exit_requested() {
    @core.PumpStatus::Exit(app_state_exit_code())
  } else {
    @core.PumpStatus::Continue
  }
}

///|
fn native_system_theme() -> Int {
  let key_path = @utf8.encode(
    "Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize",
    bom=false,
  )
  let value_name = @utf8.encode("AppsUseLightTheme", bom=false)
  let result_bytes = native_read_registry_dword_bytes(key_path, value_name)
  if result_bytes.length() >= 4 {
    let val = result_bytes[0].to_int() |
      (result_bytes[1].to_int() << 8) |
      (result_bytes[2].to_int() << 16) |
      (result_bytes[3].to_int() << 24)
    if val == 0 {
      1
    } else {
      0
    }
  } else {
    0
  }
}

///|
fn theme_from_native(theme : Int) -> @core.Theme? {
  match theme {
    0 => Some(@core.Theme::Light)
    1 => Some(@core.Theme::Dark)
    _ => None
  }
}
