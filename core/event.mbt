///|
pub(all) enum WindowEvent {
  CloseRequested
  SurfaceResized(@dpi.PhysicalSize)
  RedrawRequested
} derive(Eq, Show)
