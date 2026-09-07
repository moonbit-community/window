///|
fn[T : Debug] debug_output(value : T, logger : &Logger) -> Unit {
  logger.write_object(Repr(value))
}

///|
pub impl Show for HandleError with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for RawWindowHandle with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for RawDisplayHandle with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub extend HandleError with Show::{to_string, output}

///|
pub extend RawDisplayHandle with Show::{to_string, output}

///|
pub extend RawWindowHandle with Show::{to_string, output}
