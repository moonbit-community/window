///|
// Port target: winit-reference/winit-appkit/src/lib.rs

///|
pub type PlatformSpecificEventLoopAttributes = @core.PlatformEventLoopAttributes

///|
pub type PlatformSpecificWindowAttributes = @core.PlatformWindowAttributes

///|
pub type ActivationPolicy = @core.ActivationPolicy

///|
pub type OptionAsAlt = @core.OptionAsAlt

///|
pub type WindowAttributesExtMacOS = PlatformSpecificWindowAttributes

///|
pub type WindowExtMacOS = Window

///|
pub type EventLoopBuilderExtMacOS = EventLoopBuilder

///|
pub type ActiveEventLoopExtMacOS = ActiveEventLoop

///|
pub type MonitorHandleExtMacOS = @core.MonitorHandle

///|
pub fn default_platform_specific_event_loop_attributes() -> PlatformSpecificEventLoopAttributes {
  PlatformSpecificEventLoopAttributes::default()
}

///|
pub fn default_platform_specific_window_attributes() -> PlatformSpecificWindowAttributes {
  PlatformSpecificWindowAttributes::default()
}

///|
pub fn monitor_handle_ns_screen(monitor : @core.MonitorHandle) -> UInt64? {
  monitor_ns_screen(monitor)
}

///|
pub fn with_activation_policy_macos(
  builder : EventLoopBuilder,
  activation_policy : ActivationPolicy,
) -> EventLoopBuilder {
  builder.with_activation_policy(activation_policy)
}

///|
pub fn with_default_menu_macos(
  builder : EventLoopBuilder,
  enabled : Bool,
) -> EventLoopBuilder {
  builder.with_default_menu(enabled)
}

///|
pub fn with_activate_ignoring_other_apps_macos(
  builder : EventLoopBuilder,
  ignore : Bool,
) -> EventLoopBuilder {
  builder.with_activate_ignoring_other_apps(ignore)
}

///|
pub fn hide_application_macos(event_loop : ActiveEventLoop) -> Unit {
  event_loop.hide_application()
}

///|
pub fn hide_other_applications_macos(event_loop : ActiveEventLoop) -> Unit {
  event_loop.hide_other_applications()
}

///|
pub fn set_allows_automatic_window_tabbing_macos(
  event_loop : ActiveEventLoop,
  enabled : Bool,
) -> Unit {
  event_loop.set_allows_automatic_window_tabbing(enabled)
}

///|
pub fn allows_automatic_window_tabbing_macos(
  event_loop : ActiveEventLoop,
) -> Bool {
  event_loop.allows_automatic_window_tabbing()
}
