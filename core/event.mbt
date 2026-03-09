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
pub(all) enum WindowEvent {
  CloseRequested
  Destroyed
  Focused(Bool)
  SurfaceResized(@dpi.PhysicalSize)
  ScaleFactorChanged(Double, SurfaceSizeWriter)
  RedrawRequested
} derive(Show)
