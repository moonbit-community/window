///|
#derive(Eq, Debug)
pub(all) enum ControlFlow {
  Poll
  Wait
  WaitUntil(Int64)
}

///|
pub fn ControlFlow::default() -> ControlFlow {
  Wait
}

///|
#derive(Eq, Debug)
pub(all) enum DeviceEvents {
  Always
  WhenFocused
  Never
}

///|
pub fn DeviceEvents::default() -> DeviceEvents {
  WhenFocused
}

///|
#derive(Eq, Debug)
pub(all) enum PumpStatus {
  Continue
  Exit(Int32)
}

///|
#derive(Eq, Debug)
pub(all) suberror EventLoopError {
  RecreationAttempt
  ExitFailure(Int32)
  NotSupported(NotSupportedError)
  Os(OsError)
}

///|
pub fn EventLoopError::not_supported(reason : String) -> EventLoopError {
  NotSupported(NotSupportedError(reason))
}

///|
pub fn EventLoopError::os(
  message : String,
  code? : Int32,
  domain? : String,
) -> EventLoopError {
  Os(OsError(message, code, domain))
}

///|
#derive(Eq, Debug)
pub(all) enum ActivationPolicy {
  Regular
  Accessory
  Prohibited
}

///|
pub fn ActivationPolicy::default() -> ActivationPolicy {
  Regular
}

///|
#derive(Eq, Debug)
pub struct PlatformEventLoopAttributes {
  priv mut activation_policy : ActivationPolicy?
  priv mut default_menu : Bool
  priv mut activate_ignoring_other_apps : Bool
  priv mut any_thread : Bool
}

///|
pub fn PlatformEventLoopAttributes::default() -> PlatformEventLoopAttributes {
  {
    activation_policy: None,
    default_menu: true,
    activate_ignoring_other_apps: true,
    any_thread: false,
  }
}

///|
pub fn PlatformEventLoopAttributes::with_activation_policy(
  self : PlatformEventLoopAttributes,
  activation_policy : ActivationPolicy,
) -> PlatformEventLoopAttributes {
  self.activation_policy = Some(activation_policy)
  self
}

///|
pub fn PlatformEventLoopAttributes::activation_policy(
  self : PlatformEventLoopAttributes,
) -> ActivationPolicy? {
  self.activation_policy
}

///|
pub fn PlatformEventLoopAttributes::with_default_menu(
  self : PlatformEventLoopAttributes,
  default_menu : Bool,
) -> PlatformEventLoopAttributes {
  self.default_menu = default_menu
  self
}

///|
pub fn PlatformEventLoopAttributes::default_menu(
  self : PlatformEventLoopAttributes,
) -> Bool {
  self.default_menu
}

///|
pub fn PlatformEventLoopAttributes::with_activate_ignoring_other_apps(
  self : PlatformEventLoopAttributes,
  activate_ignoring_other_apps : Bool,
) -> PlatformEventLoopAttributes {
  self.activate_ignoring_other_apps = activate_ignoring_other_apps
  self
}

///|
pub fn PlatformEventLoopAttributes::activate_ignoring_other_apps(
  self : PlatformEventLoopAttributes,
) -> Bool {
  self.activate_ignoring_other_apps
}

///|
/// Set whether a backend may create its event loop away from the main thread.
///
/// Backends with a mandatory main-thread UI model may ignore this preference.
/// In particular, macOS always requires `EventLoop` creation on the process
/// main thread.
pub fn PlatformEventLoopAttributes::with_any_thread(
  self : PlatformEventLoopAttributes,
  any_thread : Bool,
) -> PlatformEventLoopAttributes {
  self.any_thread = any_thread
  self
}

///|
pub fn PlatformEventLoopAttributes::any_thread(
  self : PlatformEventLoopAttributes,
) -> Bool {
  self.any_thread
}

///|
#derive(Eq, Debug)
pub struct AsyncRequestSerial {
  raw : Int32
}

///|
let async_request_serial_counter : Ref[Int32] = Ref(0)

///|
pub fn AsyncRequestSerial::get() -> AsyncRequestSerial {
  let current = async_request_serial_counter.val
  async_request_serial_counter.val = current + 1
  { raw: current, }
}

///|
pub fn AsyncRequestSerial::from_raw(raw : Int32) -> AsyncRequestSerial {
  { raw, }
}

///|
pub fn AsyncRequestSerial::into_raw(self : AsyncRequestSerial) -> Int32 {
  self.raw
}

///|
pub fn ControlFlow::wait_until(resume_time_ms : Int64) -> ControlFlow {
  WaitUntil(resume_time_ms)
}

///|
pub fn ControlFlow::wait_duration(
  start_time_ms : Int64,
  timeout_ms : Int32,
) -> ControlFlow {
  if timeout_ms <= 0 {
    WaitUntil(start_time_ms)
  } else {
    WaitUntil(start_time_ms + timeout_ms.to_int64())
  }
}

///|
pub extend ActivationPolicy with Debug::{to_repr}

///|
pub extend ActivationPolicy with Eq::{not_equal, equal}

///|
pub extend AsyncRequestSerial with Debug::{to_repr}

///|
pub extend AsyncRequestSerial with Eq::{not_equal, equal}

///|
pub extend ControlFlow with Debug::{to_repr}

///|
pub extend ControlFlow with Eq::{not_equal, equal}

///|
pub extend DeviceEvents with Debug::{to_repr}

///|
pub extend DeviceEvents with Eq::{not_equal, equal}

///|
pub extend EventLoopError with Debug::{to_repr}

///|
pub extend EventLoopError with Eq::{not_equal, equal}

///|
pub extend PlatformEventLoopAttributes with Debug::{to_repr}

///|
pub extend PlatformEventLoopAttributes with Eq::{not_equal, equal}

///|
pub extend PumpStatus with Debug::{to_repr}

///|
pub extend PumpStatus with Eq::{not_equal, equal}
