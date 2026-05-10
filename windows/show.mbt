///|
pub impl Show for EventLoop with output(self, logger) {
  logger.write_string("EventLoop(msg_window=")
  logger.write_string(self.msg_window.to_string())
  logger.write_string(", thread_id=")
  logger.write_string(self.thread_id.to_string())
  logger.write_string(")")
}

///|
pub impl Show for ActiveEventLoop with output(self, logger) {
  logger.write_string("ActiveEventLoop(")
  logger.write_string(self.inner.to_string())
  logger.write_string(")")
}

///|
pub impl Show for EventLoopProxy with output(self, logger) {
  logger.write_string("EventLoopProxy(thread_id=")
  logger.write_string(self.thread_id.to_string())
  logger.write_string(")")
}

///|
pub impl Show for EventLoopBuilder with output(self, logger) {
  logger.write_string("EventLoopBuilder()")
}

///|
pub impl Show for Window with output(self, logger) {
  logger.write_string("Window(id=")
  logger.write_string(self.id.into_raw().to_string())
  logger.write_string(", hwnd=")
  logger.write_string(self.hwnd.to_string())
  logger.write_string(")")
}
