///|
pub struct VideoMode {
  priv bit_depth_ : Int?
  priv refresh_rate_millihertz_ : Int?
  priv surface_size_ : @dpi.PhysicalSize
} derive(Eq, Show)

///|
pub fn VideoMode::new(
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
pub struct MonitorHandle {
  priv current_video_mode_ : VideoMode?
  priv name_ : String?
  priv native_id_ : UInt64
  priv position_ : @dpi.PhysicalPosition
  priv surface_size_ : @dpi.PhysicalSize
  priv scale_factor_ : Double
  priv video_modes_ : Array[VideoMode]
} derive(Eq, Show)

///|
pub fn MonitorHandle::new(
  native_id : UInt64,
  name : String?,
  position : @dpi.PhysicalPosition,
  surface_size : @dpi.PhysicalSize,
  scale_factor : Double,
  current_video_mode : VideoMode?,
  video_modes : Array[VideoMode],
) -> MonitorHandle {
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
}

///|
pub fn MonitorHandle::native_id(self : MonitorHandle) -> UInt64 {
  self.native_id_
}

///|
pub fn MonitorHandle::name(self : MonitorHandle) -> String? {
  self.name_
}

///|
pub fn MonitorHandle::position(self : MonitorHandle) -> @dpi.PhysicalPosition {
  self.position_
}

///|
pub fn MonitorHandle::surface_size(self : MonitorHandle) -> @dpi.PhysicalSize {
  self.surface_size_
}

///|
pub fn MonitorHandle::scale_factor(self : MonitorHandle) -> Double {
  self.scale_factor_
}

///|
pub fn MonitorHandle::current_video_mode(self : MonitorHandle) -> VideoMode? {
  self.current_video_mode_
}

///|
pub fn MonitorHandle::video_modes(self : MonitorHandle) -> Array[VideoMode] {
  self.video_modes_
}
