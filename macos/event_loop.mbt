///|
// Port target: winit-reference/winit-appkit/src/event_loop.rs

///|
pub struct EventLoopProxy {
  priv _unit : Unit
} derive(Eq, Show)

///|
pub fn EventLoopProxy::wake_up(_self : EventLoopProxy) -> Unit {
  native_event_loop_wake_up()
}

///|
pub fn EventLoop::rwh_06_handle(_self : EventLoop) -> UInt64 {
  display_handle()
}

///|
pub fn EventLoop::owned_display_handle(self : EventLoop) -> UInt64 {
  self.rwh_06_handle()
}

///|
pub fn EventLoop::display_handle(self : EventLoop) -> UInt64 {
  self.owned_display_handle()
}

///|
pub fn EventLoop::system_theme(_self : EventLoop) -> @core.Theme? {
  theme_from_native(system_theme())
}

///|
pub fn EventLoop::window_target(self : EventLoop) -> ActiveEventLoop {
  self.as_active()
}

///|
pub fn EventLoop::listen_device_events(
  _self : EventLoop,
  _allowed : @core.DeviceEvents,
) -> Unit {
  ()
}

///|
fn activation_policy_to_native(
  activation_policy : @core.ActivationPolicy?,
) -> Int {
  match activation_policy {
    Some(@core.ActivationPolicy::Regular) => 0
    Some(@core.ActivationPolicy::Accessory) => 1
    Some(@core.ActivationPolicy::Prohibited) => 2
    None => -1
  }
}

///|
pub struct EventLoop {
  priv mut control_flow_ : @core.ControlFlow
  priv mut exit_requested : Bool
  priv mut pump_started_ : Bool
  priv mut pressed_modifiers_ : @core.ModifiersKeys
  priv mut window_ids : Array[Int]
} derive(Show)

///|
pub struct EventLoopBuilder {
  priv mut platform_attributes_ : @core.PlatformEventLoopAttributes
} derive(Eq, Show)

///|
pub struct ActiveEventLoop {
  priv inner : EventLoop
} derive(Show)

///|
fn EventLoop::as_active(self : EventLoop) -> ActiveEventLoop {
  { inner: self }
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
  activation_policy : @core.ActivationPolicy,
) -> EventLoopBuilder {
  self.platform_attributes_ = self.platform_attributes_.with_activation_policy(
    activation_policy,
  )
  self
}

///|
pub fn EventLoopBuilder::with_default_menu(
  self : EventLoopBuilder,
  default_menu : Bool,
) -> EventLoopBuilder {
  self.platform_attributes_ = self.platform_attributes_.with_default_menu(
    default_menu,
  )
  self
}

///|
pub fn EventLoopBuilder::with_activate_ignoring_other_apps(
  self : EventLoopBuilder,
  activate_ignoring_other_apps : Bool,
) -> EventLoopBuilder {
  self.platform_attributes_ = self.platform_attributes_.with_activate_ignoring_other_apps(
    activate_ignoring_other_apps,
  )
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
pub fn EventLoop::builder() -> EventLoopBuilder {
  EventLoopBuilder::new()
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
  attributes : @core.PlatformEventLoopAttributes,
) -> EventLoop raise @core.EventLoopError {
  guard backend_available() else { raise @core.EventLoopError::NotSupported }
  guard is_main_thread() else { raise @core.EventLoopError::Os }
  reset_proxy_wake_state()
  app_state_internal_exit()
  app_state_clear_exit()
  app_state_set_handler_in_use(false)
  app_state_set_launched(false)
  app_state_set_control_flow(@core.ControlFlow::Wait)
  set_application_activation_policy(
    activation_policy_to_native(attributes.activation_policy()),
  )
  initialize_default_menu(attributes.default_menu())
  set_application_activate_ignoring_other_apps(
    attributes.activate_ignoring_other_apps(),
  )
  {
    control_flow_: @core.ControlFlow::Wait,
    exit_requested: false,
    pump_started_: false,
    pressed_modifiers_: @core.ModifiersKeys::none(),
    window_ids: [],
  }
}

///|
pub fn EventLoop::create_window(
  self : EventLoop,
  attributes : @core.WindowAttributes,
) -> Window {
  try! self.try_create_window(attributes)
}

///|
pub fn EventLoop::set_control_flow(
  self : EventLoop,
  control_flow : @core.ControlFlow,
) -> Unit {
  self.control_flow_ = control_flow
  app_state_set_control_flow(control_flow)
}

///|
pub fn EventLoop::control_flow(self : EventLoop) -> @core.ControlFlow {
  self.control_flow_
}

///|
pub fn EventLoop::create_proxy(_self : EventLoop) -> EventLoopProxy {
  { _unit: () }
}

///|
pub fn EventLoop::exit(self : EventLoop) -> Unit {
  self.exit_requested = true
  app_state_exit()
}

///|
pub fn EventLoop::exiting(self : EventLoop) -> Bool {
  self.exit_requested || app_state_exiting()
}

///|
fn EventLoop::reset_run_state(self : EventLoop) -> Unit {
  set_event_loop_running(false)
  app_state_internal_exit()
  app_state_clear_exit()
  app_state_set_launched(false)
  app_state_clear_redraws()
  self.exit_requested = false
  self.pump_started_ = false
}

///|
fn EventLoop::start_running(self : EventLoop) -> Unit {
  self.reset_run_state()
  set_event_loop_running(true)
  app_state_set_running(true)
}

///|
fn EventLoop::try_start_running(
  self : EventLoop,
) -> Unit raise @core.EventLoopError {
  if event_loop_running() {
    raise @core.EventLoopError::RecreationAttempt
  }
  self.start_running()
}

///|
fn EventLoop::clear_running(_self : EventLoop) -> Unit {
  set_event_loop_running(false)
  app_state_set_running(false)
}

///|
fn[A : ApplicationHandler] EventLoop::run_init_sequence(
  self : EventLoop,
  app : A,
) -> Unit {
  app_state_set_launched(true)
  app_state_dispatch_init_events(app, self.as_active())
}

///|
fn[A : ApplicationHandler] EventLoop::run_iteration(
  self : EventLoop,
  app : A,
  timeout_ms : Int?,
) -> @core.PumpStatus {
  self.dispatch_window_events(app)
  self.dispatch_proxy_wake_up(app)
  if self.exiting() {
    return self.finish_exit(app)
  }
  if app_state_dispatch_about_to_wait(app, self.as_active()) {
    self.exit_requested = true
  }
  if self.exiting() {
    return self.finish_exit(app)
  }
  let cause = match timeout_ms {
    Some(timeout_ms) => self.wait_for_timeout(timeout_ms)
    None => self.wait_next_iteration()
  }
  app.new_events(self.as_active(), cause)
  if self.exiting() {
    self.finish_exit(app)
  } else {
    @core.PumpStatus::Continue
  }
}

///|
fn[A : ApplicationHandler] EventLoop::run_loop(
  self : EventLoop,
  app : A,
) -> Unit {
  while self.exiting() == false {
    let status = self.run_iteration(app, None)
    if status is @core.PumpStatus::Exit(_) {
      return
    }
  }
  self.clear_running()
}

///|
fn[A : ApplicationHandler] EventLoop::try_start_pump(
  self : EventLoop,
  app : A,
) -> @core.PumpStatus raise @core.EventLoopError {
  if self.pump_started_ {
    @core.PumpStatus::Continue
  } else {
    self.try_start_running()
    self.pump_started_ = true
    app_state_set_handler_in_use(true)
    self.run_init_sequence(app)
    if self.exiting() {
      self.finish_exit(app)
    } else {
      @core.PumpStatus::Continue
    }
  }
}

///|
fn[A : ApplicationHandler] EventLoop::finish_exit(
  self : EventLoop,
  app : A,
) -> @core.PumpStatus {
  self.clear_running()
  app_state_set_handler_in_use(false)
  self.close_windows()
  self.dispatch_window_events(app)
  self.pump_started_ = false
  app_state_internal_exit()
  app_state_clear_exit()
  @core.PumpStatus::Exit(0)
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
  if event_loop_running() {
    raise @core.EventLoopError::RecreationAttempt
  }
  self.exit_requested = false
  app_state_clear_exit()
  app_state_set_handler_in_use(false)
  self.pump_started_ = false
  self.try_run_app(app)
  self.reset_run_state()
}

///|
pub fn[A : ApplicationHandler] EventLoop::pump_app_events(
  self : EventLoop,
  timeout_ms : Int?,
  app : A,
) -> @core.PumpStatus {
  try! self.try_pump_app_events(timeout_ms, app)
}

///|
pub fn[A : ApplicationHandler] EventLoop::try_pump_app_events(
  self : EventLoop,
  timeout_ms : Int?,
  app : A,
) -> @core.PumpStatus raise @core.EventLoopError {
  match self.try_start_pump(app) {
    @core.PumpStatus::Exit(code) => return @core.PumpStatus::Exit(code)
    _ => ()
  }
  self.run_iteration(app, timeout_ms)
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
  self.try_start_running()
  app_state_set_handler_in_use(true)
  self.run_init_sequence(app)
  if self.exiting() {
    ignore(self.finish_exit(app))
  } else {
    self.run_loop(app)
  }
}
