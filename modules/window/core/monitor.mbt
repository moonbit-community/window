///|
pub struct VideoMode {
  priv bit_depth_ : Int?
  priv refresh_rate_millihertz_ : Int?
  priv surface_size_ : @dpi.PhysicalSize
} derive(Eq, Debug)

///|
pub fn VideoMode::VideoMode(
  surface_size : @dpi.PhysicalSize,
  bit_depth : Int?,
  refresh_rate_millihertz : Int?,
) -> VideoMode {
  {
    bit_depth_: bit_depth,
    refresh_rate_millihertz_: refresh_rate_millihertz,
    surface_size_: surface_size,
  }
}

///|
pub fn VideoMode::surface_size(self : VideoMode) -> @dpi.PhysicalSize {
  self.surface_size_
}

///|
pub fn VideoMode::bit_depth(self : VideoMode) -> Int? {
  self.bit_depth_
}

///|
pub fn VideoMode::refresh_rate_millihertz(self : VideoMode) -> Int? {
  self.refresh_rate_millihertz_
}

///|
/// Backend operations used by `MonitorHandle`.
pub(open) trait MonitorHandleProvider {
  fn id(Self) -> (UInt64, UInt64)
  fn native_id(Self) -> UInt64
  fn name(Self) -> String?
  fn position(Self) -> @dpi.PhysicalPosition
  fn surface_size(Self) -> @dpi.PhysicalSize
  fn scale_factor(Self) -> Double
  fn current_video_mode(Self) -> VideoMode?
  fn video_modes(Self) -> Array[VideoMode]
}

///|
priv struct SnapshotMonitorHandleProvider {
  current_video_mode_ : VideoMode?
  name_ : String?
  native_id_ : UInt64
  position_ : @dpi.PhysicalPosition
  surface_size_ : @dpi.PhysicalSize
  scale_factor_ : Double
  video_modes_ : Array[VideoMode]
}

///|
impl MonitorHandleProvider for SnapshotMonitorHandleProvider with fn id(self) {
  (0, self.native_id_)
}

///|
impl MonitorHandleProvider for SnapshotMonitorHandleProvider with fn native_id(
  self,
) {
  self.native_id_
}

///|
impl MonitorHandleProvider for SnapshotMonitorHandleProvider with fn name(self) {
  self.name_
}

///|
impl MonitorHandleProvider for SnapshotMonitorHandleProvider with fn position(
  self,
) {
  self.position_
}

///|
impl MonitorHandleProvider for SnapshotMonitorHandleProvider with fn surface_size(
  self,
) {
  self.surface_size_
}

///|
impl MonitorHandleProvider for SnapshotMonitorHandleProvider with fn scale_factor(
  self,
) {
  self.scale_factor_
}

///|
impl MonitorHandleProvider for SnapshotMonitorHandleProvider with fn current_video_mode(
  self,
) {
  self.current_video_mode_
}

///|
impl MonitorHandleProvider for SnapshotMonitorHandleProvider with fn video_modes(
  self,
) {
  self.video_modes_
}

///|
pub struct MonitorHandle {
  priv provider : &MonitorHandleProvider
}

///|
pub impl Eq for MonitorHandle with fn equal(self, other) {
  self.provider.id() == other.provider.id()
}

///|
pub impl Eq for MonitorHandle with fn not_equal(self, other) {
  self.provider.id() != other.provider.id()
}

///|
pub impl Debug for MonitorHandle with fn to_repr(self) {
  let (high, low) = self.provider.id()
  Repr::opaque_(
    "MonitorHandle",
    Repr::literal(high.to_string() + ":" + low.to_string()),
  )
}

///|
/// Construct a monitor handle from a backend provider.
pub fn MonitorHandle::from_provider(
  provider : &MonitorHandleProvider,
) -> MonitorHandle {
  { provider, }
}

///|
pub fn MonitorHandle::MonitorHandle(
  native_id : UInt64,
  name : String?,
  position : @dpi.PhysicalPosition,
  surface_size : @dpi.PhysicalSize,
  scale_factor : Double,
  current_video_mode : VideoMode?,
  video_modes : Array[VideoMode],
) -> MonitorHandle {
  MonitorHandle::from_provider(
    {
      current_video_mode_: current_video_mode,
      name_: name,
      native_id_: native_id,
      position_: position,
      surface_size_: surface_size,
      scale_factor_: if scale_factor > 0.0 {
        scale_factor
      } else {
        1.0
      },
      video_modes_: video_modes,
    }
    as &MonitorHandleProvider,
  )
}

///|
pub fn MonitorHandle::native_id(self : MonitorHandle) -> UInt64 {
  self.provider.native_id()
}

///|
pub fn MonitorHandle::name(self : MonitorHandle) -> String? {
  self.provider.name()
}

///|
pub fn MonitorHandle::position(self : MonitorHandle) -> @dpi.PhysicalPosition {
  self.provider.position()
}

///|
pub fn MonitorHandle::surface_size(self : MonitorHandle) -> @dpi.PhysicalSize {
  self.provider.surface_size()
}

///|
pub fn MonitorHandle::scale_factor(self : MonitorHandle) -> Double {
  self.provider.scale_factor()
}

///|
pub fn MonitorHandle::current_video_mode(self : MonitorHandle) -> VideoMode? {
  self.provider.current_video_mode()
}

///|
pub fn MonitorHandle::video_modes(self : MonitorHandle) -> Array[VideoMode] {
  self.provider.video_modes()
}
