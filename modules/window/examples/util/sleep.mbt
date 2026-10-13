///|
extern "C" fn native_sleep_millis(ms : Int32) -> Unit = "mbw_examples_sleep_millis"

///|
pub fn sleep_millis(ms : Int32) -> Unit {
  if ms > 0 {
    native_sleep_millis(ms)
  }
}
