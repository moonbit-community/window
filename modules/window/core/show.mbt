///|
fn[T : Debug] debug_output(value : T, logger : &Logger) -> Unit {
  logger.write_object(Repr(value))
}

///|
pub impl Show for ImeRequestData with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeEnableRequest with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for NativeKeyCode with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for NativeKey with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for KeyCode with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PhysicalKey with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for KeyLocation with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for NamedKey with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Key with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for KeyEvent with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for SurfaceSizeWriter with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for StartCause with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ElementState with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for MouseButton with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for FingerId with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for AxisId with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ButtonId with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for MouseScrollDelta with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for TouchPhase with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Force with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for TabletToolKind with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for TabletToolData with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for TabletToolTilt with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for TabletToolAngle with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for TabletToolButton with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PointerKind with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PointerSource with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ButtonSource with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeCursorRange with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Ime with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for DeviceId with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for RawKeyEvent with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for DeviceEvent with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WinitDeviceEvent with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WindowEvent with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WinitWindowEvent with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ModifiersState with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ModifiersKeyState with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ModifiersKeys with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Modifiers with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Theme with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImePurpose with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeHint with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeSurroundingTextError with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeSurroundingText with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeCapabilities with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeRequest with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeRequestError with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for NotSupportedError with fn output(self, logger) {
  logger.write_string("Operation is not supported: ")
  logger.write_string(self.reason())
}

///|
pub impl Show for OsError with fn output(self, logger) {
  logger.write_string("os error: ")
  logger.write_string(self.message())
  match self.domain() {
    Some(domain) => {
      logger.write_string(" (domain=")
      logger.write_string(domain)
      match self.code() {
        Some(code) => {
          logger.write_string(", code=")
          logger.write_string(code.to_string())
        }
        None => ()
      }
      logger.write_string(")")
    }
    None =>
      match self.code() {
        Some(code) => {
          logger.write_string(" (code=")
          logger.write_string(code.to_string())
          logger.write_string(")")
        }
        None => ()
      }
  }
}

///|
pub impl Show for RequestError with fn output(self, logger) {
  match self {
    NotSupported(err) => logger.write_string("\{err}")
    Ignored => logger.write_string("The request was ignored")
    Os(err) => logger.write_string("\{err}")
  }
}

///|
pub impl Show for ActivationToken with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WindowLevel with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for CursorGrabMode with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ResizeDirection with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for UserAttentionType with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for CursorIcon with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for CustomCursor with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Cursor with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for CustomCursorSource with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for BadCustomCursorSource with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for BadCustomCursorAnimation with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Fullscreen with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for OptionAsAlt with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ScreenEdge with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PlatformWindowAttributes with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for BadIcon with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Icon with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WindowButtons with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WindowId with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ParentWindow with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WindowAttributes with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for VideoMode with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for MonitorHandle with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ControlFlow with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for DeviceEvents with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PumpStatus with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for EventLoopError with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ActivationPolicy with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PlatformEventLoopAttributes with fn output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for AsyncRequestSerial with fn output(self, logger) {
  debug_output(self, logger)
}
