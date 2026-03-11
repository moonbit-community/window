///|
extern "C" fn application_activation_policy_for_test() -> Int = "mbw_test_application_activation_policy"

///|
extern "C" fn application_has_main_menu_for_test() -> Bool = "mbw_test_application_has_main_menu"

///|
extern "C" fn application_activate_ignoring_other_apps_for_test() -> Bool = "mbw_test_application_activate_ignoring_other_apps"

///|
extern "C" fn window_accepts_first_mouse_for_test(window_id : Int) -> Bool = "mbw_test_window_accepts_first_mouse"

///|
extern "C" fn window_disallow_hidpi_for_test(window_id : Int) -> Bool = "mbw_test_window_disallow_hidpi"

///|
extern "C" fn window_movable_by_window_background_for_test(
  window_id : Int,
) -> Bool = "mbw_test_window_movable_by_window_background"

///|
extern "C" fn window_titlebar_transparent_for_test(window_id : Int) -> Bool = "mbw_test_window_titlebar_transparent"

///|
extern "C" fn window_title_hidden_for_test(window_id : Int) -> Bool = "mbw_test_window_title_hidden"

///|
extern "C" fn window_titlebar_hidden_for_test(window_id : Int) -> Bool = "mbw_test_window_titlebar_hidden"

///|
extern "C" fn window_titlebar_buttons_hidden_for_test(window_id : Int) -> Bool = "mbw_test_window_titlebar_buttons_hidden"

///|
extern "C" fn window_fullsize_content_view_for_test(window_id : Int) -> Bool = "mbw_test_window_fullsize_content_view"

///|
extern "C" fn window_content_view_handle_for_test(window_id : Int) -> UInt64 = "mbw_test_window_content_view_handle"

///|
extern "C" fn window_unified_titlebar_for_test(window_id : Int) -> Bool = "mbw_test_window_unified_titlebar"

///|
extern "C" fn window_is_panel_for_test(window_id : Int) -> Bool = "mbw_test_window_is_panel"

///|
extern "C" fn window_tabbing_mode_for_test(window_id : Int) -> Int = "mbw_test_window_tabbing_mode"

///|
extern "C" fn queue_pointer_moved_for_test(
  window_id : Int,
  x : Double,
  y : Double,
) -> Unit = "mbw_test_window_queue_pointer_moved"

///|
#borrow(action)
extern "C" fn queue_standard_key_binding_for_test(
  window_id : Int,
  action : Bytes,
  action_len : Int,
) -> Unit = "mbw_test_window_queue_standard_key_binding"

///|
extern "C" fn runtime_now_set_for_test(ms : Int64) -> Unit = "mbw_runtime_now_ms_set_for_test"

///|
extern "C" fn runtime_now_clear_for_test() -> Unit = "mbw_runtime_now_ms_clear_for_test"

///|
struct LifecycleCallbacksApp {
  can_create_surfaces_called : Ref[Bool]
  destroy_surfaces_called : Ref[Bool]
  resumed_called : Ref[Bool]
  suspended_called : Ref[Bool]
}

///|
struct DeviceEventsPolicyApp {
  policy : @core.DeviceEvents
  device_event_seen : Ref[Bool]
  window_event_seen : Ref[Bool]
}

///|
struct StandardKeyBindingApp {
  action : Ref[String?]
}

///|
struct RunOnDemandApp {
  runs : Ref[Int]
}

///|
struct PumpExitApp {
  init_count : Ref[Int]
  poll_count : Ref[Int]
}

///|
struct PumpContinueApp {
  init_count : Ref[Int]
  poll_count : Ref[Int]
}

///|
struct ProxyWakePreRunApp {
  wake_seen : Ref[Bool]
}

///|
struct ProxyWakeDuringRunApp {
  wake_seen : Ref[Bool]
}

///|
struct PumpCauseApp {
  latest_cause : Ref[@core.StartCause?]
}

///|
impl ApplicationHandler for LifecycleCallbacksApp with resumed(
  self,
  _event_loop,
) {
  self.resumed_called.val = true
}

///|
impl ApplicationHandler for LifecycleCallbacksApp with can_create_surfaces(
  self,
  event_loop,
) {
  self.can_create_surfaces_called.val = true
  event_loop.exit()
}

///|
impl ApplicationHandler for LifecycleCallbacksApp with destroy_surfaces(
  self,
  _event_loop,
) {
  self.destroy_surfaces_called.val = true
}

///|
impl ApplicationHandler for LifecycleCallbacksApp with suspended(
  self,
  _event_loop,
) {
  self.suspended_called.val = true
}

///|
impl ApplicationHandler for DeviceEventsPolicyApp with can_create_surfaces(
  self,
  event_loop,
) {
  event_loop.listen_device_events(self.policy)
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  queue_pointer_moved_for_test(window.id().into_raw(), 24.5, 48.25)
}

///|
impl ApplicationHandler for DeviceEventsPolicyApp with window_event(
  self,
  event_loop,
  _id,
  event,
) {
  match event {
    @core.WindowEvent::PointerMoved(
      Some(_),
      position,
      true,
      @core.PointerSource::Mouse
    ) =>
      if position == @dpi.PhysicalPositionF64::new(24.5, 48.25) {
        self.window_event_seen.val = true
        event_loop.exit()
      }
    _ => ()
  }
}

///|
impl ApplicationHandler for DeviceEventsPolicyApp with device_event(
  self,
  _event_loop,
  _device_id,
  event,
) {
  match event {
    @core.DeviceEvent::PointerMotion(_, _) => self.device_event_seen.val = true
    _ => ()
  }
}

///|
impl ApplicationHandler for StandardKeyBindingApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let action = @utf8.encode("moveForward:"[:], bom=false)
  queue_standard_key_binding_for_test(
    window.id().into_raw(),
    action,
    action.length(),
  )
}

///|
impl ApplicationHandler for StandardKeyBindingApp with standard_key_binding(
  self,
  event_loop,
  _window_id,
  action,
) {
  self.action.val = Some(action)
  event_loop.exit()
}

///|
impl ApplicationHandler for StandardKeyBindingApp with about_to_wait(
  _self,
  event_loop,
) {
  event_loop.exit()
}

///|
impl ApplicationHandler for StandardKeyBindingApp with macos_handler(_self) {
  true
}

///|
impl ApplicationHandler for RunOnDemandApp with can_create_surfaces(
  self,
  event_loop,
) {
  self.runs.val = self.runs.val + 1
  event_loop.exit()
}

///|
impl ApplicationHandler for PumpExitApp with new_events(self, event_loop, cause) {
  match cause {
    @core.StartCause::Init => self.init_count.val = self.init_count.val + 1
    @core.StartCause::Poll => {
      self.poll_count.val = self.poll_count.val + 1
      event_loop.exit()
    }
    _ => ()
  }
}

///|
impl ApplicationHandler for PumpContinueApp with new_events(
  self,
  _event_loop,
  cause,
) {
  match cause {
    @core.StartCause::Init => self.init_count.val = self.init_count.val + 1
    @core.StartCause::Poll => self.poll_count.val = self.poll_count.val + 1
    _ => ()
  }
}

///|
impl ApplicationHandler for ProxyWakePreRunApp with can_create_surfaces(
  _self,
  _event_loop,
) {
  ()
}

///|
impl ApplicationHandler for ProxyWakePreRunApp with proxy_wake_up(
  self,
  _event_loop,
) {
  self.wake_seen.val = true
}

///|
impl ApplicationHandler for ProxyWakePreRunApp with about_to_wait(
  _self,
  event_loop,
) {
  event_loop.exit()
}

///|
impl ApplicationHandler for ProxyWakeDuringRunApp with can_create_surfaces(
  _self,
  event_loop,
) {
  let proxy = event_loop.create_proxy()
  proxy.wake_up()
}

///|
impl ApplicationHandler for ProxyWakeDuringRunApp with proxy_wake_up(
  self,
  event_loop,
) {
  self.wake_seen.val = true
  event_loop.exit()
}

///|
impl ApplicationHandler for ProxyWakeDuringRunApp with about_to_wait(
  _self,
  event_loop,
) {
  event_loop.exit()
}

///|
impl ApplicationHandler for PumpCauseApp with new_events(
  self,
  _event_loop,
  cause,
) {
  match cause {
    @core.StartCause::Init => ()
    _ => self.latest_cause.val = Some(cause)
  }
}

///|
fn run_device_events_policy(policy : @core.DeviceEvents) -> (Bool, Bool) {
  let app : DeviceEventsPolicyApp = {
    policy,
    device_event_seen: Ref::new(false),
    window_event_seen: Ref::new(false),
  }
  let event_loop = EventLoop::new()
  event_loop.run_app(app)
  (app.window_event_seen.val, app.device_event_seen.val)
}

///|
test "run_app dispatches macos lifecycle without resumed/suspended hooks" {
  let app : LifecycleCallbacksApp = {
    can_create_surfaces_called: Ref::new(false),
    destroy_surfaces_called: Ref::new(false),
    resumed_called: Ref::new(false),
    suspended_called: Ref::new(false),
  }
  let event_loop = EventLoop::new()
  event_loop.run_app(app)
  assert_true(app.can_create_surfaces_called.val)
  assert_false(app.resumed_called.val)
  assert_false(app.destroy_surfaces_called.val)
  assert_false(app.suspended_called.val)
}

///|
test "system theme and device event policy APIs are callable" {
  let event_loop = EventLoop::new()
  event_loop.listen_device_events(@core.DeviceEvents::Always)
  let _ = event_loop.system_theme()
  assert_eq(event_loop.owned_display_handle(), event_loop.rwh_06_handle())
  assert_eq(event_loop.display_handle(), event_loop.rwh_06_handle())
}

///|
test "event loop window_target exposes active-event-loop APIs" {
  let event_loop = EventLoop::new()
  let active = event_loop.window_target()
  assert_eq(active.control_flow(), @core.ControlFlow::Wait)
  active.set_control_flow(@core.ControlFlow::Poll)
  assert_eq(event_loop.control_flow(), @core.ControlFlow::Poll)
  assert_eq(active.rwh_06_handle(), event_loop.rwh_06_handle())
  assert_eq(active.owned_display_handle(), event_loop.owned_display_handle())
  let _ = active.available_monitors()
}

///|
test "try_new and try_build expose raise-based event-loop constructors" {
  let event_loop_from_new = Some(EventLoop::try_new()) catch { _ => None }
  assert_true(event_loop_from_new is Some(_))

  let event_loop_from_builder = Some(EventLoop::builder().try_build()) catch {
    _ => None
  }
  assert_true(event_loop_from_builder is Some(_))

  let event_loop_from_platform_attributes = Some(
    EventLoop::try_new_with_platform_attributes(
      @core.PlatformEventLoopAttributes::default(),
    ),
  ) catch {
    _ => None
  }
  assert_true(event_loop_from_platform_attributes is Some(_))
}

///|
test "event loop builder default mirrors new constructor" {
  let from_default = EventLoopBuilder::default().build()
  let from_new = EventLoopBuilder::new().build()
  assert_eq(from_default.control_flow(), from_new.control_flow())
}

///|
test "try_create_window exposes raise-based window creation API" {
  let event_loop = try! EventLoop::try_new()
  let window = try! event_loop.try_create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  assert_true(window.id().into_raw() > 0)

  let active = event_loop.window_target()
  let active_window = try! active.try_create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  assert_true(active_window.id().into_raw() > 0)
}

///|
test "device events remain delivered when policy is never on macos" {
  let (window_event_seen, device_event_seen) = run_device_events_policy(
    @core.DeviceEvents::Never,
  )
  assert_true(window_event_seen)
  assert_true(device_event_seen)
}

///|
test "device events remain delivered when policy is when-focused on macos" {
  let (window_event_seen, device_event_seen) = run_device_events_policy(
    @core.DeviceEvents::WhenFocused,
  )
  assert_true(window_event_seen)
  assert_true(device_event_seen)
}

///|
test "device events are delivered when policy is always" {
  let (window_event_seen, device_event_seen) = run_device_events_policy(
    @core.DeviceEvents::Always,
  )
  assert_true(window_event_seen)
  assert_true(device_event_seen)
}

///|
test "standard key binding callback is delivered when handler is enabled" {
  let action = Ref::new(None)
  let app : StandardKeyBindingApp = { action, }
  let event_loop = EventLoop::new()
  event_loop.run_app(app)
  assert_eq(action.val, Some("moveForward:"))
}

///|
test "run_app_on_demand can re-enter the same event loop instance" {
  let runs = Ref::new(0)
  let app : RunOnDemandApp = { runs, }
  let event_loop = EventLoop::new()
  event_loop.run_app_on_demand(app)
  event_loop.run_app_on_demand(app)
  assert_eq(runs.val, 2)
}

///|
test "try_run_app and try_run_app_on_demand expose raise-based runner APIs" {
  let lifecycle_app : LifecycleCallbacksApp = {
    can_create_surfaces_called: Ref::new(false),
    destroy_surfaces_called: Ref::new(false),
    resumed_called: Ref::new(false),
    suspended_called: Ref::new(false),
  }
  let lifecycle_loop = try! EventLoop::try_new()
  let run_ok = try {
    lifecycle_loop.try_run_app(lifecycle_app)
    true
  } catch {
    _ => false
  }
  assert_true(run_ok)
  assert_true(lifecycle_app.can_create_surfaces_called.val)

  let runs = Ref::new(0)
  let on_demand_app : RunOnDemandApp = { runs, }
  let on_demand_loop = try! EventLoop::try_new()
  let first_ok = try {
    on_demand_loop.try_run_app_on_demand(on_demand_app)
    true
  } catch {
    _ => false
  }
  let second_ok = try {
    on_demand_loop.try_run_app_on_demand(on_demand_app)
    true
  } catch {
    _ => false
  }
  assert_true(first_ok)
  assert_true(second_ok)
  assert_eq(runs.val, 2)
}

///|
test "try_pump_app_events exposes raise-based pump API" {
  let init_count = Ref::new(0)
  let poll_count = Ref::new(0)
  let app : PumpContinueApp = { init_count, poll_count }
  let event_loop = try! EventLoop::try_new()
  event_loop.set_control_flow(@core.ControlFlow::Poll)
  let status = try! event_loop.try_pump_app_events(Some(0), app)
  assert_eq(status, @core.PumpStatus::Continue)
  assert_eq(init_count.val, 1)
  assert_eq(poll_count.val, 1)
  event_loop.exit()
  let cleanup_status = try! event_loop.try_pump_app_events(Some(0), app)
  assert_eq(cleanup_status, @core.PumpStatus::Exit(0))
}

///|
test "pump_app_events returns continue for non-exiting app state" {
  let init_count = Ref::new(0)
  let poll_count = Ref::new(0)
  let app : PumpContinueApp = { init_count, poll_count }
  let event_loop = EventLoop::new()
  event_loop.set_control_flow(@core.ControlFlow::Poll)
  let status = event_loop.pump_app_events(Some(0), app)
  assert_eq(status, @core.PumpStatus::Continue)
  assert_eq(init_count.val, 1)
  assert_eq(poll_count.val, 1)
  event_loop.exit()
  let cleanup_status = event_loop.pump_app_events(Some(0), app)
  assert_eq(cleanup_status, @core.PumpStatus::Exit(0))
}

///|
test "pump_app_events reports exit when app requests shutdown" {
  let init_count = Ref::new(0)
  let poll_count = Ref::new(0)
  let app : PumpExitApp = { init_count, poll_count }
  let event_loop = EventLoop::new()
  event_loop.set_control_flow(@core.ControlFlow::Poll)
  let status = event_loop.pump_app_events(Some(0), app)
  assert_eq(status, @core.PumpStatus::Exit(0))
  assert_eq(init_count.val, 1)
  assert_eq(poll_count.val, 1)
}

///|
test "event loop proxy wake_up before run is ignored on macos" {
  let wake_seen = Ref::new(false)
  let app : ProxyWakePreRunApp = { wake_seen, }
  let event_loop = EventLoop::new()
  let proxy = event_loop.create_proxy()
  proxy.wake_up()
  event_loop.run_app(app)
  assert_false(wake_seen.val)
}

///|
test "event loop proxy wake_up during run dispatches callback" {
  let wake_seen = Ref::new(false)
  let app : ProxyWakeDuringRunApp = { wake_seen, }
  let event_loop = EventLoop::new()
  event_loop.run_app(app)
  assert_true(wake_seen.val)
}

///|
test "pump_app_events timeout is capped by wait-until control flow" {
  runtime_now_set_for_test(1000L)
  let latest_cause = Ref::new(None)
  let app : PumpCauseApp = { latest_cause, }
  let event_loop = EventLoop::new()
  event_loop.set_control_flow(@core.ControlFlow::WaitUntil(1010L))
  let status = event_loop.pump_app_events(Some(5), app)
  assert_eq(status, @core.PumpStatus::Continue)
  assert_eq(
    latest_cause.val,
    Some(@core.StartCause::WaitCancelled(1000L, Some(1010L))),
  )
  event_loop.exit()
  let cleanup_status = event_loop.pump_app_events(Some(0), app)
  assert_eq(cleanup_status, @core.PumpStatus::Exit(0))
  runtime_now_clear_for_test()
}

///|
test "pump_app_events reports resume-time-reached at wait-until deadline" {
  runtime_now_set_for_test(1000L)
  let latest_cause = Ref::new(None)
  let app : PumpCauseApp = { latest_cause, }
  let event_loop = EventLoop::new()
  event_loop.set_control_flow(@core.ControlFlow::WaitUntil(1010L))
  let status = event_loop.pump_app_events(Some(50), app)
  assert_eq(status, @core.PumpStatus::Continue)
  assert_eq(
    latest_cause.val,
    Some(@core.StartCause::ResumeTimeReached(1000L, 1010L)),
  )
  event_loop.exit()
  let cleanup_status = event_loop.pump_app_events(Some(0), app)
  assert_eq(cleanup_status, @core.PumpStatus::Exit(0))
  runtime_now_clear_for_test()
}

///|
test "monitor ns_screen exposes the Cocoa screen handle when available" {
  let event_loop = EventLoop::new()
  match event_loop.primary_monitor() {
    Some(monitor) => {
      let handle = monitor_ns_screen(monitor)
      assert_true(handle is Some(_))
      assert_eq(ns_screen(monitor), handle)
    }
    None => ()
  }
}

///|
test "platform event loop attributes apply activation and menu configuration" {
  let event_loop = EventLoop::new_with_platform_attributes(
    @core.PlatformEventLoopAttributes::default()
    .with_activation_policy(@core.ActivationPolicy::Accessory)
    .with_default_menu(false)
    .with_activate_ignoring_other_apps(false),
  )
  let _ = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  assert_eq(application_activation_policy_for_test(), 1)
  assert_false(application_has_main_menu_for_test())
  assert_false(application_activate_ignoring_other_apps_for_test())
}

///|
test "upstream appkit type aliases map to core platform attributes" {
  let loop_attrs = PlatformSpecificEventLoopAttributes::default()
    .with_default_menu(false)
    .with_activate_ignoring_other_apps(false)
  assert_false(loop_attrs.default_menu())
  assert_false(loop_attrs.activate_ignoring_other_apps())

  let window_attrs = WindowAttributesMacOS::default()
    .with_panel(true)
    .with_unified_titlebar(true)
  assert_true(window_attrs.panel())
  assert_true(window_attrs.unified_titlebar())
}

///|
test "event loop builder macos extensions apply activation and menu configuration" {
  let event_loop = EventLoop::builder()
    .with_activation_policy(@core.ActivationPolicy::Prohibited)
    .with_default_menu(true)
    .with_activate_ignoring_other_apps(false)
    .build()
  let _ = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  assert_eq(application_activation_policy_for_test(), 2)
  assert_true(application_has_main_menu_for_test())
  assert_false(application_activate_ignoring_other_apps_for_test())
}

///|
test "macos creation-only platform window attributes apply at creation time" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_platform_attributes(
      @core.PlatformWindowAttributes::default()
      .with_accepts_first_mouse(false)
      .with_disallow_hidpi(true)
      .with_fullsize_content_view(true)
      .with_movable_by_window_background(true)
      .with_title_hidden(true)
      .with_titlebar_hidden(true)
      .with_titlebar_buttons_hidden(true)
      .with_titlebar_transparent(true)
      .with_panel(true),
    ),
  )
  let raw_id = window.id().into_raw()
  assert_false(window_accepts_first_mouse_for_test(raw_id))
  assert_true(window_disallow_hidpi_for_test(raw_id))
  assert_true(window_movable_by_window_background_for_test(raw_id))
  assert_true(window_titlebar_transparent_for_test(raw_id))
  assert_true(window_title_hidden_for_test(raw_id))
  assert_true(window_titlebar_hidden_for_test(raw_id))
  assert_true(window_titlebar_buttons_hidden_for_test(raw_id))
  assert_true(window_fullsize_content_view_for_test(raw_id))
  assert_true(window_is_panel_for_test(raw_id))
}

///|
test "window unified titlebar can be updated at runtime" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_platform_attributes(
      @core.PlatformWindowAttributes::default().with_unified_titlebar(true),
    ),
  )
  let raw_id = window.id().into_raw()
  assert_true(window.unified_titlebar())
  assert_true(window_unified_titlebar_for_test(raw_id))
  window.set_unified_titlebar(false)
  assert_false(window.unified_titlebar())
  assert_false(window_unified_titlebar_for_test(raw_id))
}

///|
test "winit-compatible window aliases reuse macos surface APIs" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_inner_size(@dpi.PhysicalSize::new(320, 240).into_size())
    .with_resize_increments(@dpi.PhysicalSize::new(5, 7).into_size())
    .with_min_inner_size(@dpi.PhysicalSize::new(100, 80).into_size())
    .with_max_inner_size(@dpi.PhysicalSize::new(640, 480).into_size()),
  )
  assert_eq(window.inner_size(), window.surface_size())
  assert_eq(window.inner_position(), window.surface_position())
  assert_eq(window.resize_increments(), window.surface_resize_increments())
  assert_eq(window.min_inner_size(), window.min_surface_size())
  assert_eq(window.max_inner_size(), window.max_surface_size())
  assert_eq(
    window.request_inner_size(@dpi.PhysicalSize::new(400, 300).into_size()),
    None,
  )
  window.set_resize_increments(Some(@dpi.PhysicalSize::new(9, 11).into_size()))
  window.set_min_inner_size(Some(@dpi.PhysicalSize::new(120, 90).into_size()))
  window.set_max_inner_size(Some(@dpi.PhysicalSize::new(800, 600).into_size()))
  assert_eq(window.resize_increments(), Some(@dpi.PhysicalSize::new(9, 11)))
  assert_eq(window.min_inner_size(), Some(@dpi.PhysicalSize::new(120, 90)))
  assert_eq(window.max_inner_size(), Some(@dpi.PhysicalSize::new(800, 600)))
  window.set_cursor_icon(@core.CursorIcon::Pointer)
  assert_eq(window.cursor(), @core.Cursor::Icon(@core.CursorIcon::Pointer))
}

///|
test "set_cursor_hittest supports request-error style API on macos" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let first_ok = try {
    window.set_cursor_hittest(false)
    true
  } catch {
    _ => false
  }
  let second_ok = try {
    window.set_cursor_hittest(true)
    true
  } catch {
    _ => false
  }
  assert_true(first_ok)
  assert_true(second_ok)
}

///|
test "outer_position supports request-error style API on macos" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let position = Some(window.outer_position()) catch { _ => None }
  assert_true(position is Some(_))
}

///|
test "create_custom_cursor supports url cursor sources" {
  let event_loop = EventLoop::new()
  let cursor = try! event_loop.create_custom_cursor(
    @core.CustomCursorSource::Url(
      "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericDocumentIcon.icns",
      1, 1,
    ),
  )
  assert_true(cursor.into_raw() > (0 : Int).to_uint64())
}

///|
test "create_custom_cursor supports rgba cursor sources" {
  let event_loop = EventLoop::new()
  let source = try! @core.CustomCursorSource::from_rgba(
    Bytes::make(4, (255 : Int).to_byte()),
    1,
    1,
    0,
    0,
  )
  let cursor = try! event_loop.create_custom_cursor(source)
  assert_true(cursor.into_raw() > (0 : Int).to_uint64())
}

///|
test "create_custom_cursor reports not supported for animation sources" {
  let event_loop = EventLoop::new()
  let frame_source = try! @core.CustomCursorSource::from_rgba(
    Bytes::make(4, (255 : Int).to_byte()),
    1,
    1,
    0,
    0,
  )
  let frame = try! event_loop.create_custom_cursor(frame_source)
  let animated = try! @core.CustomCursorSource::from_animation(16, [frame])
  let not_supported = try {
    event_loop.create_custom_cursor(animated) |> ignore
    false
  } catch {
    @core.RequestError::NotSupported => true
    _ => false
  }
  assert_true(not_supported)
}

///|
test "parent window attribute accepts native window handles" {
  let event_loop = EventLoop::new()
  let parent = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let parent_raw_id = parent.id().into_raw()
  let parent_handle = parent.rwh_06_window_handle()
  assert_eq(parent_handle, window_content_view_handle_for_test(parent_raw_id))
  assert_eq(parent.display_handle(), parent.rwh_06_display_handle())
  assert_eq(parent.window_handle(), parent_handle)
  let child = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_parent_window(Some(@core.ParentWindow::from_raw(parent_handle))),
  )
  assert_true(parent_handle > (0 : Int).to_uint64())
  let child_raw_id = child.id().into_raw()
  let child_handle = child.rwh_06_window_handle()
  assert_eq(child_handle, window_content_view_handle_for_test(child_raw_id))
  assert_true(child_handle > (0 : Int).to_uint64())
}

///|
test "simple fullscreen can be toggled independently of native fullscreen" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  assert_false(window.simple_fullscreen())
  assert_false(window.is_fullscreen())
  assert_eq(window.fullscreen(), None)
  assert_true(window.set_simple_fullscreen(true))
  assert_true(window.simple_fullscreen())
  assert_false(window.is_fullscreen())
  assert_eq(window.fullscreen(), None)
  assert_false(window.set_simple_fullscreen(true))
  assert_true(window.set_simple_fullscreen(false))
  assert_false(window.simple_fullscreen())
  assert_false(window.set_simple_fullscreen(false))
}

///|
test "borderless game flag can be configured at create and runtime" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_platform_attributes(
      @core.PlatformWindowAttributes::default().with_borderless_game(true),
    ),
  )
  assert_true(window.is_borderless_game())
  window.set_borderless_game(false)
  assert_false(window.is_borderless_game())
  window.set_borderless_game(true)
  assert_true(window.is_borderless_game())
}

///|
test "simple fullscreen attribute applies at creation time without native fullscreen state" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_platform_attributes(
      @core.PlatformWindowAttributes::default().with_simple_fullscreen(
        Some(true),
      ),
    ),
  )
  assert_true(window.simple_fullscreen())
  assert_false(window.is_fullscreen())
  assert_eq(window.fullscreen(), None)
  assert_true(window.set_simple_fullscreen(false))
}

///|
test "macos shadow and document edited APIs reflect runtime updates" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  let initial_shadow = window.has_shadow()
  window.set_has_shadow(false)
  assert_false(window.has_shadow())
  window.set_has_shadow(true)
  assert_true(window.has_shadow())
  ignore(initial_shadow)
  assert_false(window.is_document_edited())
  window.set_document_edited(true)
  assert_true(window.is_document_edited())
  window.set_document_edited(false)
  assert_false(window.is_document_edited())
}

///|
test "macos platform window attributes apply tabbing option-as-alt and shadow at creation time" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default()
    .with_visible(false)
    .with_platform_attributes(
      @core.PlatformWindowAttributes::default()
      .with_has_shadow(false)
      .with_tabbing_identifier("group-a")
      .with_option_as_alt(@core.OptionAsAlt::OnlyLeft),
    ),
  )
  assert_false(window.has_shadow())
  assert_eq(window.tabbing_identifier(), "group-a")
  assert_eq(window_tabbing_mode_for_test(window.id().into_raw()), 1)
  assert_eq(window.option_as_alt(), @core.OptionAsAlt::OnlyLeft)
  assert_eq(window.num_tabs(), 1)
}

///|
test "macos tabbing and option-as-alt APIs reflect runtime updates" {
  let event_loop = EventLoop::new()
  let window = event_loop.create_window(
    @core.WindowAttributes::default().with_visible(false),
  )
  window.set_tabbing_identifier("group-b")
  assert_eq(window.tabbing_identifier(), "group-b")
  assert_eq(window_tabbing_mode_for_test(window.id().into_raw()), 0)
  window.select_next_tab()
  window.select_previous_tab()
  window.select_tab_at_index(0)
  window.select_tab_at_index(99)
  assert_true(window.num_tabs() >= 1)
  assert_eq(window.option_as_alt(), @core.OptionAsAlt::None)
  window.set_option_as_alt(@core.OptionAsAlt::Both)
  assert_eq(window.option_as_alt(), @core.OptionAsAlt::Both)
  window.set_option_as_alt(@core.OptionAsAlt::OnlyRight)
  assert_eq(window.option_as_alt(), @core.OptionAsAlt::OnlyRight)
}

///|
test "macos event loop automatic tabbing can be toggled" {
  let event_loop = EventLoop::new()
  let initial = event_loop.allows_automatic_window_tabbing()
  event_loop.set_allows_automatic_window_tabbing(false)
  assert_false(event_loop.allows_automatic_window_tabbing())
  event_loop.set_allows_automatic_window_tabbing(true)
  assert_true(event_loop.allows_automatic_window_tabbing())
  event_loop.set_allows_automatic_window_tabbing(initial)
}
