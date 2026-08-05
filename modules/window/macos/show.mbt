///|
fn[T : Debug] debug_output(value : T, logger : &Logger) -> Unit {
  logger.write_object(Repr(value))
}

///|
pub impl Show for MenuAction with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for KeyEquivalent with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for MenuItemDescriptor with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for EventLoopProxy with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for EventLoop with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for EventLoopBuilder with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ActiveEventLoop with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Window with fn output(self, logger) {
  debug_output(self, logger)
}
