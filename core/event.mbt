///|
pub(all) enum StartCause {
  Init
  Poll
  WaitCancelled(Int64, Int64?)
  ResumeTimeReached(Int64, Int64)
} derive(Eq, Show)

///|
pub(all) enum WindowEvent {
  CloseRequested
  SurfaceResized(@dpi.PhysicalSize)
  RedrawRequested
} derive(Eq, Show)
