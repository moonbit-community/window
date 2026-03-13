///|
// Port target: winit-reference/winit-appkit/src/event_loop.rs

///|
pub struct EventLoopProxy {
  priv _unit : Unit
} derive(Eq, Show)

///|
pub fn EventLoopProxy::wake_up(_self : EventLoopProxy) -> Unit {
  queue_proxy_wake_up()
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
  Some(@core.Theme::Light)
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
  priv mut pump_started_ : Bool
  priv _did_finish_launching_observer : NotificationObserver
  priv _will_terminate_observer : NotificationObserver
  priv mut next_window_id_ : Int
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
let application_hidden_state : Ref[Bool] = Ref::new(false)

///|
let other_applications_hidden_state : Ref[Bool] = Ref::new(false)

///|
let allows_automatic_window_tabbing_state : Ref[Bool] = Ref::new(false)

///|
let event_loop_global_created : Ref[Bool] = Ref::new(false)

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
  application_hidden_state.val = true
}

///|
// Port target: event_loop.rs::hide_other_applications
pub fn ActiveEventLoop::hide_other_applications(self : ActiveEventLoop) -> Unit {
  let _ = self.inner
  native_application_hide_other_applications()
  other_applications_hidden_state.val = true
}

///|
// Port target: event_loop.rs::set_allows_automatic_window_tabbing
pub fn ActiveEventLoop::set_allows_automatic_window_tabbing(
  self : ActiveEventLoop,
  enabled : Bool,
) -> Unit {
  let _ = self.inner
  native_application_set_allows_automatic_window_tabbing(enabled)
  allows_automatic_window_tabbing_state.val = enabled
}

///|
// Port target: event_loop.rs::allows_automatic_window_tabbing
pub fn ActiveEventLoop::allows_automatic_window_tabbing(
  self : ActiveEventLoop,
) -> Bool {
  let _ = self.inner
  let enabled = native_application_allows_automatic_window_tabbing()
  allows_automatic_window_tabbing_state.val = enabled
  enabled
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
  if is_running() == false {
    clear_exit()
    app_state_set_handler_in_use(false)
    app_state_set_control_flow(@core.ControlFlow::Wait)
  }
  setup_global(
    activation_policy_to_native(attributes.activation_policy()),
    attributes.default_menu(),
    attributes.activate_ignoring_other_apps(),
  )
  override_send_event()
  if is_launched() {
    app_state_apply_launch_policy()
  }
  let did_finish_launching_observer = create_observer(
    "NSApplicationDidFinishLaunchingNotification",
  )
  let will_terminate_observer = create_observer(
    "NSApplicationWillTerminateNotification",
  )
  let event_loop = {
    pump_started_: false,
    _did_finish_launching_observer: did_finish_launching_observer,
    _will_terminate_observer: will_terminate_observer,
    next_window_id_: 1,
    window_ids: [],
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
  event_loop_proxy()
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
fn EventLoop::reset_run_state(self : EventLoop) -> Unit {
  internal_exit()
  app_state_clear_redraws()
  self.pump_started_ = false
}

///|
fn EventLoop::start_running(self : EventLoop) -> Unit {
  clear_exit()
  self.reset_run_state()
  app_state_set_running(true)
}

///|
fn EventLoop::try_start_running(
  self : EventLoop,
) -> Unit raise @core.EventLoopError {
  if is_running() {
    raise @core.EventLoopError::RecreationAttempt
  }
  self.start_running()
}

///|
fn EventLoop::clear_running(_self : EventLoop) -> Unit {
  app_state_set_running(false)
}

///|
fn EventLoop::configure_pump_wait(self : EventLoop, timeout_ms : Int?) -> Unit {
  let _ = self
  match timeout_ms {
    Some(timeout_ms) if timeout_ms <= 0 => {
      set_wait_timeout(None)
      set_stop_before_wait(true)
      set_stop_after_wait(false)
    }
    Some(timeout_ms) => {
      set_stop_before_wait(false)
      set_stop_after_wait(true)
      set_wait_timeout(Some(runtime_now_ms() + timeout_ms.to_int64()))
    }
    None => {
      set_wait_timeout(None)
      set_stop_before_wait(false)
      set_stop_after_wait(true)
    }
  }
  set_stop_on_redraw(true)
}

///|
fn EventLoop::clear_pump_wait(self : EventLoop) -> Unit {
  let _ = self
  set_wait_timeout(None)
  set_stop_before_wait(false)
  set_stop_after_wait(false)
  set_stop_on_redraw(false)
}

///|
fn[A : ApplicationHandler] EventLoop::run_init_sequence(
  self : EventLoop,
  app : A,
) -> Unit {
  let launched_before = is_launched()
  if launched_before == false {
    app_state_queue_did_finish_launching_notification()
  }
  self.dispatch_application_notifications(app)
  if launched_before {
    dispatch_init_events(app, self.as_active())
  } else if is_launched() == false {
    app_state_did_finish_launching_and_dispatch(app, self.as_active())
  }
}

///|
fn[A : ApplicationHandler] EventLoop::run_iteration(
  self : EventLoop,
  app : A,
) -> @core.PumpStatus {
  self.dispatch_application_notifications(app)
  self.send_event(app)
  self.dispatch_window_events(app)
  cleared(app, self.as_active())
  if self.exiting() {
    return self.finish_exit(app)
  }
  let cause = app_state_wait()
  self.dispatch_application_notifications(app)
  self.send_event(app)
  wakeup(app, self.as_active(), cause)
  if self.exiting() {
    self.finish_exit(app)
  } else {
    @core.PumpStatus::Continue
  }
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_application_notifications(
  self : EventLoop,
  app : A,
) -> Unit {
  if self._did_finish_launching_observer.take_pending() &&
    is_launched() == false {
    app_state_did_finish_launching_and_dispatch(app, self.as_active())
  }
  if self._will_terminate_observer.take_pending() {
    self.notify_windows_of_exit()
    will_terminate()
  }
}

///|
fn EventLoop::notify_windows_of_exit(self : EventLoop) -> Unit {
  for raw_id in self.window_ids {
    let _ = window_handle_for_id(raw_id)
    app_state_clear_window_redraw(raw_id)
    view_clear_pressed_modifiers(raw_id)
    unregister_window_handle(raw_id)
  }
}

///|
// Port target: event_loop.rs::stop_app_immediately
fn stop_app_immediately() -> Unit {
  queue_proxy_wake_up()
}

///|
fn[A : ApplicationHandler] EventLoop::run_loop(
  self : EventLoop,
  app : A,
) -> Unit {
  while self.exiting() == false {
    let status = self.run_iteration(app)
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
  app_state_set_handler_in_use(false)
  app_state_queue_will_terminate_notification()
  self.dispatch_application_notifications(app)
  self.dispatch_window_events(app)
  self.clear_running()
  self.pump_started_ = false
  internal_exit()
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
  if is_running() {
    raise @core.EventLoopError::RecreationAttempt
  }
  clear_exit()
  app_state_set_handler_in_use(false)
  self.clear_pump_wait()
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
  let started_now = self.pump_started_ == false
  match self.try_start_pump(app) {
    @core.PumpStatus::Exit(code) => return @core.PumpStatus::Exit(code)
    _ => ()
  }
  if started_now {
    self.clear_pump_wait()
    return @core.PumpStatus::Continue
  }
  self.configure_pump_wait(timeout_ms)
  let status = self.run_iteration(app)
  self.clear_pump_wait()
  status
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
  self.run_init_sequence(app)
  if self.exiting() {
    ignore(self.finish_exit(app))
  } else {
    self.run_loop(app)
  }
}
