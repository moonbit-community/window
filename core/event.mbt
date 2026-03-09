///|
pub struct SurfaceSizeWriter {
  size : Ref[@dpi.PhysicalSize]
} derive(Show)

///|
pub fn SurfaceSizeWriter::new(size : @dpi.PhysicalSize) -> SurfaceSizeWriter {
  { size: Ref::new(size) }
}

///|
pub fn SurfaceSizeWriter::surface_size(
  self : SurfaceSizeWriter,
) -> @dpi.PhysicalSize {
  self.size.val
}

///|
pub fn SurfaceSizeWriter::request_surface_size(
  self : SurfaceSizeWriter,
  size : @dpi.PhysicalSize,
) -> Unit {
  self.size.val = size
}

///|
pub(all) enum StartCause {
  Init
  Poll
  WaitCancelled(Int64, Int64?)
  ResumeTimeReached(Int64, Int64)
} derive(Eq, Show)

///|
pub(all) enum ElementState {
  Pressed
  Released
} derive(Eq, Show)

///|
pub(all) enum MouseButton {
  Left
  Right
  Middle
  Back
  Forward
  Other(Int)
} derive(Eq, Show)

///|
pub(all) enum PointerKind {
  Mouse
  Unknown
} derive(Eq, Show)

///|
pub(all) enum PointerSource {
  Mouse
  Unknown
} derive(Eq, Show)

///|
pub(all) enum ButtonSource {
  Mouse(MouseButton)
  Unknown(Int)
} derive(Eq, Show)

///|
pub(all) enum MouseScrollDelta {
  LineDelta(Double, Double)
  PixelDelta(@dpi.PhysicalPositionF64)
} derive(Eq, Show)

///|
pub(all) enum TouchPhase {
  Started
  Moved
  Ended
  Cancelled
} derive(Eq, Show)

///|
pub(all) enum WindowEvent {
  SurfaceResized(@dpi.PhysicalSize)
  Moved(@dpi.PhysicalPosition)
  CloseRequested
  Destroyed
  Focused(Bool)
  PointerMoved(@dpi.PhysicalPositionF64, Bool, PointerSource)
  PointerEntered(@dpi.PhysicalPositionF64, Bool, PointerKind)
  PointerLeft(@dpi.PhysicalPositionF64?, Bool, PointerKind)
  PointerButton(ElementState, @dpi.PhysicalPositionF64, Bool, ButtonSource)
  MouseWheel(MouseScrollDelta, TouchPhase)
  ScaleFactorChanged(Double, SurfaceSizeWriter)
  ThemeChanged(Theme)
  Occluded(Bool)
  RedrawRequested
} derive(Show)
