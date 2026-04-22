///|
fn[T : Debug] debug_output(value : T, logger : &Logger) -> Unit {
  logger.write_object(to_repr(value))
}

///|
impl Show for Mode with output(self, logger) {
  debug_output(self, logger)
}
