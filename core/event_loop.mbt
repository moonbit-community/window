///|
pub(all) enum ControlFlow {
  Poll
  Wait
  WaitUntil(Int64)
} derive(Eq, Show)

///|
pub(all) enum DeviceEvents {
  Always
  WhenFocused
  Never
} derive(Eq, Show)

///|
pub(all) enum ActivationPolicy {
  Regular
  Accessory
  Prohibited
} derive(Eq, Show)

///|
pub struct PlatformEventLoopAttributes {
  priv mut activation_policy : ActivationPolicy?
  priv mut default_menu : Bool
  priv mut activate_ignoring_other_apps : Bool
} derive(Eq, Show)

///|
pub fn PlatformEventLoopAttributes::default() -> PlatformEventLoopAttributes {
  {
    activation_policy: None,
    default_menu: true,
    activate_ignoring_other_apps: true,
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
pub struct AsyncRequestSerial {
  raw : Int
} derive(Eq, Show)

///|
let async_request_serial_counter : Ref[Int] = Ref::new(0)

///|
pub fn AsyncRequestSerial::get() -> AsyncRequestSerial {
  let current = async_request_serial_counter.val
  async_request_serial_counter.val = current + 1
  { raw: current }
}

///|
pub fn AsyncRequestSerial::from_raw(raw : Int) -> AsyncRequestSerial {
  { raw, }
}

///|
pub fn AsyncRequestSerial::into_raw(self : AsyncRequestSerial) -> Int {
  self.raw
}

///|
pub fn ControlFlow::wait_until(resume_time_ms : Int64) -> ControlFlow {
  ControlFlow::WaitUntil(resume_time_ms)
}

///|
pub fn ControlFlow::wait_duration(
  start_time_ms : Int64,
  timeout_ms : Int,
) -> ControlFlow {
  if timeout_ms <= 0 {
    ControlFlow::WaitUntil(start_time_ms)
  } else {
    ControlFlow::WaitUntil(start_time_ms + timeout_ms.to_int64())
  }
}
