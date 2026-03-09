///|
pub struct MonitorHandle {
  priv name_ : String?
  priv native_id_ : UInt64
  priv position_ : @dpi.PhysicalPosition
  priv surface_size_ : @dpi.PhysicalSize
  priv scale_factor_ : Double
} derive(Eq, Show)

///|
pub fn MonitorHandle::new(
  native_id : UInt64,
  name : String?,
  position : @dpi.PhysicalPosition,
  surface_size : @dpi.PhysicalSize,
  scale_factor : Double,
) -> MonitorHandle {
  {
    name_: name,
    native_id_: native_id,
    position_: position,
    surface_size_: surface_size,
    scale_factor_: if scale_factor > 0.0 {
      scale_factor
    } else {
      1.0
    },
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
