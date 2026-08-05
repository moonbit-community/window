///|
fn[T : Debug] debug_output(value : T, logger : &Logger) -> Unit {
  logger.write_object(Repr(value))
}

///|
pub impl Show for LogicalSize with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PhysicalSize with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for LogicalPosition with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PhysicalPosition with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PhysicalPositionF64 with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Position with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PhysicalInsets with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Size with fn output(self, logger) {
  debug_output(self, logger)
}
