///|
fn[T : Debug] debug_output(value : T, logger : &Logger) -> Unit {
  logger.write_object(to_repr(value))
}

///|
pub impl Show for MenuAction with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for KeyEquivalent with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for MenuItemDescriptor with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for EventLoopProxy with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for EventLoop with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for EventLoopBuilder with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ActiveEventLoop with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Window with output(self, logger) {
  debug_output(self, logger)
}
