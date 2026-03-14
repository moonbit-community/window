///|
// Port target: winit-reference/winit-appkit/src/event_loop.rs

///|
pub struct EventLoopProxy {
  priv _unit : Unit
} derive(Eq, Show)

///|
pub fn EventLoopProxy::wake_up(_self : EventLoopProxy) -> Unit {
  app_state_queue_proxy_wake_up()
}

///|
pub fn EventLoop::rwh_06_handle(_self : EventLoop) -> UInt64 {
  cg_main_display_id()
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
  match theme_from_native(native_application_theme()) {
    Some(theme) => Some(theme)
    None => Some(@core.Theme::Light)
  }
}

///|
// Port target: event_loop.rs::hide_application
pub fn EventLoop::hide_application(self : EventLoop) -> Unit {
  self.as_active().hide_application()
}

///|
// Port target: event_loop.rs::hide_other_applications
pub fn EventLoop::hide_other_applications(self : EventLoop) -> Unit {
  self.as_active().hide_other_applications()
}

///|
// Port target: event_loop.rs::set_allows_automatic_window_tabbing
pub fn EventLoop::set_allows_automatic_window_tabbing(
  self : EventLoop,
  enabled : Bool,
) -> Unit {
  self.as_active().set_allows_automatic_window_tabbing(enabled)
}

///|
// Port target: event_loop.rs::allows_automatic_window_tabbing
pub fn EventLoop::allows_automatic_window_tabbing(self : EventLoop) -> Bool {
  self.as_active().allows_automatic_window_tabbing()
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
pub fn EventLoop::available_monitors(
  _self : EventLoop,
) -> Array[@core.MonitorHandle] {
  available_monitors()
}

///|
pub fn EventLoop::primary_monitor(_self : EventLoop) -> @core.MonitorHandle? {
  Some(primary_monitor())
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
  priv did_finish_launching_observer_ : UInt64
  priv will_terminate_observer_ : UInt64
  priv before_waiting_observer_ : UInt64
  priv after_waiting_observer_ : UInt64
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
let event_loop_global_created : Ref[Bool] = Ref::new(false)

///|
pub fn EventLoop::drop(self : EventLoop) -> Unit {
  release_main_run_loop_observer(self.before_waiting_observer_)
  release_main_run_loop_observer(self.after_waiting_observer_)
  release_notification_observer(self.did_finish_launching_observer_)
  release_notification_observer(self.will_terminate_observer_)
}

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
// Port target: event_loop.rs::hide_application
pub fn ActiveEventLoop::hide_application(self : ActiveEventLoop) -> Unit {
  let _ = self.inner
  native_application_hide()
}

///|
// Port target: event_loop.rs::hide_other_applications
pub fn ActiveEventLoop::hide_other_applications(self : ActiveEventLoop) -> Unit {
  let _ = self.inner
  native_application_hide_other_applications()
}

///|
// Port target: event_loop.rs::set_allows_automatic_window_tabbing
pub fn ActiveEventLoop::set_allows_automatic_window_tabbing(
  self : ActiveEventLoop,
  enabled : Bool,
) -> Unit {
  let _ = self.inner
  native_application_set_allows_automatic_window_tabbing(enabled)
}

///|
// Port target: event_loop.rs::allows_automatic_window_tabbing
pub fn ActiveEventLoop::allows_automatic_window_tabbing(
  self : ActiveEventLoop,
) -> Bool {
  let _ = self.inner
  native_application_allows_automatic_window_tabbing()
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
  if is_main_thread() == false {
    raise @core.EventLoopError::Os
  }
  if event_loop_global_created.val {
    raise @core.EventLoopError::RecreationAttempt
  }
  app_state_setup_global(
    activation_policy_to_native(attributes.activation_policy()),
    attributes.default_menu(),
    attributes.activate_ignoring_other_apps(),
  )
  override_send_event()
  let did_finish_launching_observer = create_did_finish_launching_observer()
  let will_terminate_observer = create_will_terminate_observer()
  let before_waiting_observer = create_before_waiting_observer()
  let after_waiting_observer = create_after_waiting_observer()
  if app_state_is_launched() {
    app_state_apply_launch_policy()
  }
  let event_loop = {
    did_finish_launching_observer_: did_finish_launching_observer,
    will_terminate_observer_: will_terminate_observer,
    before_waiting_observer_: before_waiting_observer,
    after_waiting_observer_: after_waiting_observer,
  }
  event_loop_global_created.val = true
  event_loop
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
pub fn EventLoop::create_proxy(_self : EventLoop) -> EventLoopProxy {
  { _unit: () }
}

///|
pub fn EventLoop::exit(_self : EventLoop) -> Unit {
  app_state_exit()
}

///|
pub fn EventLoop::exiting(self : EventLoop) -> Bool {
  let _ = self
  app_state_exiting()
}

///|
fn EventLoop::start_running(self : EventLoop) -> Unit {
  let _ = self
  app_state_clear_exit()
  app_state_set_handler_in_use(false)
  if app_state_is_launched() {
    app_state_set_running(true)
  }
}

///|
fn EventLoop::try_start_running(
  self : EventLoop,
) -> Unit raise @core.EventLoopError {
  if app_state_is_running() {
    raise @core.EventLoopError::RecreationAttempt
  }
  self.start_running()
}

///|
fn EventLoop::configure_pump_wait(self : EventLoop, timeout_ms : Int?) -> Unit {
  let _ = self
  match timeout_ms {
    Some(timeout_ms) if timeout_ms <= 0 => {
      app_state_set_wait_timeout_ms(None)
      app_state_set_stop_before_wait(true)
      app_state_set_stop_after_wait(false)
    }
    Some(timeout_ms) => {
      app_state_set_stop_before_wait(false)
      app_state_set_stop_after_wait(true)
      app_state_set_wait_timeout_ms(
        Some(runtime_now_ms() + timeout_ms.to_int64()),
      )
    }
    None => {
      app_state_set_wait_timeout_ms(None)
      app_state_set_stop_before_wait(false)
      app_state_set_stop_after_wait(true)
    }
  }
  app_state_set_stop_on_redraw(true)
}

///|
fn EventLoop::clear_pump_wait(self : EventLoop) -> Unit {
  let _ = self
  app_state_set_wait_timeout_ms(None)
  app_state_set_stop_before_wait(false)
  app_state_set_stop_after_wait(false)
  app_state_set_stop_on_redraw(false)
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_window_events(
  self : EventLoop,
  app : A,
) -> Unit {
  app_state_dispatch_deferred_callbacks(app, self.as_active())
}

///|
// Port target: event_loop.rs::notify_windows_of_exit
fn notify_windows_of_exit() -> Unit {
  native_application_close_all_windows()
}

///|
// Port target: event_loop.rs::stop_app_immediately
fn stop_app_immediately() -> Unit {
  native_application_stop_immediately()
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
  app_state_set_dispatch_handler(app, self.as_active())
  app_state_clear_exit()
  app_state_set_handler_in_use(false)
  self.clear_pump_wait()
  if app_state_is_launched() {
    app_state_set_running(true)
    app_state_dispatch_init_events(app, self.as_active())
  }
  native_application_run()
  self.dispatch_window_events(app)
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
  app_state_set_dispatch_handler(app, self.as_active())
  let result = (fn() -> @core.PumpStatus {
    app_state_set_handler_in_use(false)
    if app_state_is_launched() == false {
      app_state_set_stop_on_launch(true)
      native_application_run()
    } else if app_state_is_running() == false {
      app_state_set_running(true)
      app_state_dispatch_init_events(app, self.as_active())
    } else {
      self.configure_pump_wait(timeout_ms)
      native_application_run()
      self.clear_pump_wait()
    }
    self.dispatch_window_events(app)
    if self.exiting() {
      app_state_internal_exit()
      @core.PumpStatus::Exit(0)
    } else {
      @core.PumpStatus::Continue
    }
  })()
  app_state_clear_dispatch_handler()
  result
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
  app_state_set_dispatch_handler(app, self.as_active())
  let result = (fn() -> Unit raise @core.EventLoopError {
    self.try_start_running()
    if app_state_is_launched() {
      app_state_dispatch_init_events(app, self.as_active())
    }
    native_application_run()
    self.dispatch_window_events(app)
    app_state_internal_exit()
  })() catch {
    err => {
      app_state_clear_dispatch_handler()
      raise err
    }
  }
  app_state_clear_dispatch_handler()
  result
}
