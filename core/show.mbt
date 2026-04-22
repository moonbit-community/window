///|
fn[T : Debug] debug_output(value : T, logger : &Logger) -> Unit {
  logger.write_object(to_repr(value))
}

///|
pub impl Show for ImeRequestData with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeEnableRequest with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for NativeKeyCode with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for NativeKey with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for KeyCode with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PhysicalKey with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for KeyLocation with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for NamedKey with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Key with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for KeyEvent with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for SurfaceSizeWriter with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for StartCause with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ElementState with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for MouseButton with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for FingerId with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for AxisId with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ButtonId with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for MouseScrollDelta with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for TouchPhase with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Force with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for TabletToolKind with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for TabletToolData with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for TabletToolTilt with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for TabletToolAngle with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for TabletToolButton with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PointerKind with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PointerSource with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ButtonSource with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeCursorRange with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Ime with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for DeviceId with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for RawKeyEvent with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for DeviceEvent with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WinitDeviceEvent with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WindowEvent with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WinitWindowEvent with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ModifiersState with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ModifiersKeyState with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ModifiersKeys with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Modifiers with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Theme with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImePurpose with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeHint with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeSurroundingTextError with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeSurroundingText with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeCapabilities with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeRequest with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ImeRequestError with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for RequestError with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ActivationToken with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WindowLevel with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for CursorGrabMode with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ResizeDirection with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for UserAttentionType with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for CursorIcon with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for CustomCursor with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Cursor with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for CustomCursorSource with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for BadCustomCursorSource with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for BadCustomCursorAnimation with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Fullscreen with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for OptionAsAlt with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ScreenEdge with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PlatformWindowAttributes with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for BadIcon with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for Icon with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WindowButtons with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WindowId with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ParentWindow with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for WindowAttributes with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for VideoMode with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for MonitorHandle with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ControlFlow with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for DeviceEvents with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PumpStatus with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for EventLoopError with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for ActivationPolicy with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for PlatformEventLoopAttributes with output(self, logger) {
  debug_output(self, logger)
}

///|
pub impl Show for AsyncRequestSerial with output(self, logger) {
  debug_output(self, logger)
}
