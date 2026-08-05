///|
fn[T : Debug] debug_output(value : T, logger : &Logger) -> Unit {
  logger.write_object(Repr(value))
}

///|
impl Show for Mode with fn output(self, logger) {
  debug_output(self, logger)
}
