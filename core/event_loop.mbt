///|
pub(all) enum ControlFlow {
  Poll
  Wait
  WaitUntil(Int)
} derive(Eq, Show)

///|
pub fn ControlFlow::wait_duration(timeout_ms : Int) -> ControlFlow {
  ControlFlow::WaitUntil(timeout_ms)
}
