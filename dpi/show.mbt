///|
fn[T : Debug] debug_output(value : T, logger : &Logger) -> Unit {
  logger.write_object(to_repr(value))
}

///|
pub impl Show for LogicalSize with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PhysicalSize with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for LogicalPosition with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PhysicalPosition with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PhysicalPositionF64 with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Position with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PhysicalInsets with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Size with output(self, logger) {
  debug_output(self, logger)
}
