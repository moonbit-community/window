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

///|
pub extend ActivationPolicy with Show::{to_string, output}

///|
pub extend ActivationToken with Show::{to_string, output}

///|
pub extend AsyncRequestSerial with Show::{to_string, output}

///|
pub extend AxisId with Show::{to_string, output}

///|
pub extend BadCustomCursorAnimation with Show::{to_string, output}

///|
pub extend BadCustomCursorSource with Show::{to_string, output}

///|
pub extend BadIcon with Show::{to_string, output}

///|
pub extend ButtonId with Show::{to_string, output}

///|
pub extend ButtonSource with Show::{to_string, output}

///|
pub extend ControlFlow with Show::{to_string, output}

///|
pub extend Cursor with Show::{to_string, output}

///|
pub extend CursorGrabMode with Show::{to_string, output}

///|
pub extend CursorIcon with Show::{to_string, output}

///|
pub extend CustomCursor with Show::{to_string, output}

///|
pub extend CustomCursorSource with Show::{to_string, output}

///|
pub extend DeviceEvent with Show::{to_string, output}

///|
pub extend DeviceEvents with Show::{to_string, output}

///|
pub extend DeviceId with Show::{to_string, output}

///|
pub extend ElementState with Show::{to_string, output}

///|
pub extend EventLoopError with Show::{to_string, output}

///|
pub extend FingerId with Show::{to_string, output}

///|
pub extend Force with Show::{to_string, output}

///|
pub extend Fullscreen with Show::{to_string, output}

///|
pub extend Icon with Show::{to_string, output}

///|
pub extend Ime with Show::{to_string, output}

///|
pub extend ImeCapabilities with Show::{to_string, output}

///|
pub extend ImeCursorRange with Show::{to_string, output}

///|
pub extend ImeEnableRequest with Show::{to_string, output}

///|
pub extend ImeHint with Show::{to_string, output}

///|
pub extend ImePurpose with Show::{to_string, output}

///|
pub extend ImeRequest with Show::{to_string, output}

///|
pub extend ImeRequestData with Show::{to_string, output}

///|
pub extend ImeRequestError with Show::{to_string, output}

///|
pub extend ImeSurroundingText with Show::{to_string, output}

///|
pub extend ImeSurroundingTextError with Show::{to_string, output}

///|
pub extend Key with Show::{to_string, output}

///|
pub extend KeyCode with Show::{to_string, output}

///|
pub extend KeyEvent with Show::{to_string, output}

///|
pub extend KeyLocation with Show::{to_string, output}

///|
pub extend Modifiers with Show::{to_string, output}

///|
pub extend ModifiersKeyState with Show::{to_string, output}

///|
pub extend ModifiersKeys with Show::{to_string, output}

///|
pub extend ModifiersState with Show::{to_string, output}

///|
pub extend MonitorHandle with Show::{to_string, output}

///|
pub extend MouseButton with Show::{to_string, output}

///|
pub extend MouseScrollDelta with Show::{to_string, output}

///|
pub extend NamedKey with Show::{to_string, output}

///|
pub extend NativeKey with Show::{to_string, output}

///|
pub extend NativeKeyCode with Show::{to_string, output}

///|
pub extend NotSupportedError with Show::{to_string, output}

///|
pub extend OptionAsAlt with Show::{to_string, output}

///|
pub extend OsError with Show::{to_string, output}

///|
pub extend ParentWindow with Show::{to_string, output}

///|
pub extend PhysicalKey with Show::{to_string, output}

///|
pub extend PlatformEventLoopAttributes with Show::{to_string, output}

///|
pub extend PlatformWindowAttributes with Show::{to_string, output}

///|
pub extend PointerKind with Show::{to_string, output}

///|
pub extend PointerSource with Show::{to_string, output}

///|
pub extend PumpStatus with Show::{to_string, output}

///|
pub extend RawKeyEvent with Show::{to_string, output}

///|
pub extend RequestError with Show::{to_string, output}

///|
pub extend ResizeDirection with Show::{to_string, output}

///|
pub extend ScreenEdge with Show::{to_string, output}

///|
pub extend StartCause with Show::{to_string, output}

///|
pub extend SurfaceSizeWriter with Show::{to_string, output}

///|
pub extend TabletToolAngle with Show::{to_string, output}

///|
pub extend TabletToolButton with Show::{to_string, output}

///|
pub extend TabletToolData with Show::{to_string, output}

///|
pub extend TabletToolKind with Show::{to_string, output}

///|
pub extend TabletToolTilt with Show::{to_string, output}

///|
pub extend Theme with Show::{to_string, output}

///|
pub extend TouchPhase with Show::{to_string, output}

///|
pub extend UserAttentionType with Show::{to_string, output}

///|
pub extend VideoMode with Show::{to_string, output}

///|
pub extend WindowAttributes with Show::{to_string, output}

///|
pub extend WindowButtons with Show::{to_string, output}

///|
pub extend WindowEvent with Show::{to_string, output}

///|
pub extend WindowId with Show::{to_string, output}

///|
pub extend WindowLevel with Show::{to_string, output}

///|
pub extend WinitDeviceEvent with Show::{to_string, output}

///|
pub extend WinitWindowEvent with Show::{to_string, output}
