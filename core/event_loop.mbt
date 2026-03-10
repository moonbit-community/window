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
