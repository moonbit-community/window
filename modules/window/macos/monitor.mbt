///|
// Port target: winit-reference/winit-appkit/src/monitor.rs
// MoonBit adaptation:
// 1. We build monitor handles from CoreGraphics display IDs.
// 2. Active displays are enumerated through small native primitives.

///|
fn native_find_display_mode_handle(
  monitor_id : UInt64,
  width : Int,
  height : Int,
  bit_depth : Int,
  refresh_rate_millihertz : Int,
) -> NativeDisplayMode {
  native_monitor_find_display_mode_handle(
    monitor_id.to_uint(),
    width,
    height,
    bit_depth,
    refresh_rate_millihertz,
  )
}

///|
fn native_copy_current_display_mode_handle(
  monitor_id : UInt64,
) -> NativeDisplayMode {
  native_monitor_copy_current_display_mode_handle(monitor_id.to_uint())
}

///|
fn native_copy_display_mode_list(monitor_id : UInt64) -> NativeDisplayModeList {
  native_monitor_copy_display_mode_list(monitor_id.to_uint())
}

///|
fn native_display_mode_list_count(mode_list : NativeDisplayModeList) -> Int {
  let count = native_monitor_display_mode_list_count(mode_list)
  if count > 0 {
    count
  } else {
    0
  }
}

///|
fn native_display_mode_list_mode_at(
  mode_list : NativeDisplayModeList,
  index : Int,
) -> NativeDisplayMode {
  native_monitor_display_mode_list_mode_at(mode_list, index)
}

///|
fn native_release_display_mode_list(mode_list : NativeDisplayModeList) -> Unit {
  native_monitor_release_display_mode_list(mode_list)
}

///|
fn native_display_mode_valid(mode_handle : NativeDisplayMode) -> Bool {
  native_monitor_display_mode_is_valid(mode_handle) != 0
}

///|
fn native_display_mode_width(mode_handle : NativeDisplayMode) -> Int {
  let width = native_monitor_display_mode_width(mode_handle)
  if width > 0 {
    width
  } else {
    0
  }
}

///|
fn native_display_mode_height(mode_handle : NativeDisplayMode) -> Int {
  let height = native_monitor_display_mode_height(mode_handle)
  if height > 0 {
    height
  } else {
    0
  }
}

///|
fn native_display_mode_bit_depth(mode_handle : NativeDisplayMode) -> Int {
  let bit_depth = native_monitor_display_mode_bit_depth(mode_handle)
  if bit_depth > 0 {
    bit_depth
  } else {
    0
  }
}

///|
fn native_display_mode_refresh_rate_millihertz(
  mode_handle : NativeDisplayMode,
) -> Int {
  let refresh_rate_millihertz = native_monitor_display_mode_refresh_rate_millihertz(
    mode_handle,
  )
  if refresh_rate_millihertz > 0 {
    refresh_rate_millihertz
  } else {
    0
  }
}

///|
fn native_display_refresh_rate_millihertz(monitor_id : UInt64) -> Int {
  native_monitor_display_refresh_rate_millihertz(monitor_id.to_uint())
}

///|
fn native_release_display_mode_handle(mode_handle : NativeDisplayMode) -> Unit {
  native_monitor_release_display_mode_handle(mode_handle)
}

///|
fn native_capture_display(monitor_id : UInt64) -> Bool {
  native_monitor_capture_display(monitor_id.to_uint()) != 0
}

///|
fn native_set_display_mode_handle(
  monitor_id : UInt64,
  mode_handle : NativeDisplayMode,
) -> Bool {
  native_monitor_set_display_mode_handle(monitor_id.to_uint(), mode_handle) != 0
}

///|
fn native_release_display_capture(monitor_id : UInt64) -> Bool {
  native_monitor_release_display_capture(monitor_id.to_uint()) != 0
}

///|
fn native_monitor_ns_screen(monitor_id : UInt64) -> NSScreenHandle? {
  if monitor_id == (0 : Int).to_uint64() {
    return None
  }
  let screen_owner = native_monitor_copy_ns_screen(monitor_id.to_uint())
  if appkit_objc_owned_object_handle(screen_owner) == (0 : Int).to_uint64() {
    None
  } else {
    Some({ object: screen_owner })
  }
}

///|
fn fallback_display_video_mode(display_id : UInt64) -> @core.VideoMode {
  let width = cg_display_pixels_wide(display_id)
  let height = cg_display_pixels_high(display_id)
  VideoMode(
    PhysicalSize(
      if width > 0 {
        width
      } else {
        1
      },
      if height > 0 {
        height
      } else {
        1
      },
    ),
    None,
    None,
  )
}

///|
fn display_video_mode_from_handle(
  mode_handle : NativeDisplayMode,
  fallback_refresh_rate_millihertz : Int,
) -> @core.VideoMode? {
  if native_display_mode_valid(mode_handle) == false {
    return None
  }
  let width = native_display_mode_width(mode_handle)
  let height = native_display_mode_height(mode_handle)
  if width <= 0 || height <= 0 {
    return None
  }
  let bit_depth = native_display_mode_bit_depth(mode_handle)
  let refresh_rate_millihertz = {
    let mode_refresh_rate_millihertz = native_display_mode_refresh_rate_millihertz(
      mode_handle,
    )
    if mode_refresh_rate_millihertz > 0 {
      mode_refresh_rate_millihertz
    } else {
      fallback_refresh_rate_millihertz
    }
  }
  Some(
    VideoMode(
      PhysicalSize(width, height),
      if bit_depth > 0 {
        Some(bit_depth)
      } else {
        None
      },
      if refresh_rate_millihertz > 0 {
        Some(refresh_rate_millihertz)
      } else {
        None
      },
    ),
  )
}

///|
fn push_unique_video_mode(
  video_modes : Array[@core.VideoMode],
  mode : @core.VideoMode,
) -> Unit {
  match video_modes.search_by(existing => existing == mode) {
    Some(_) => ()
    None => video_modes.push(mode)
  }
}

///|
fn available_display_video_modes(display_id : UInt64) -> Array[@core.VideoMode] {
  let modes : Array[@core.VideoMode] = []
  let mode_list = native_copy_display_mode_list(display_id)
  let count = native_display_mode_list_count(mode_list)
  let fallback_refresh_rate_millihertz = native_display_refresh_rate_millihertz(
    display_id,
  )
  for index in 0..<count {
    let mode_handle = native_display_mode_list_mode_at(mode_list, index)
    if native_display_mode_valid(mode_handle) {
      match
        display_video_mode_from_handle(
          mode_handle, fallback_refresh_rate_millihertz,
        ) {
        Some(mode) => push_unique_video_mode(modes, mode)
        None => ()
      }
    }
    native_release_display_mode_handle(mode_handle)
  }
  native_release_display_mode_list(mode_list)
  modes
}

///|
fn current_display_video_mode(display_id : UInt64) -> @core.VideoMode? {
  let mode_handle = native_copy_current_display_mode_handle(display_id)
  if native_display_mode_valid(mode_handle) == false {
    return None
  }
  let mode = display_video_mode_from_handle(
    mode_handle,
    native_display_refresh_rate_millihertz(display_id),
  )
  native_release_display_mode_handle(mode_handle)
  mode
}

///|
fn clamped_scale_factor(display_id : UInt64) -> Double {
  let scale = native_monitor_backing_scale_factor(display_id.to_uint())
  if scale > 0.0 {
    scale
  } else {
    1.0
  }
}

///|
fn display_position(
  display_id : UInt64,
  scale_factor : Double,
) -> @dpi.PhysicalPosition {
  let x = (cg_display_bounds_x(display_id).to_double() * scale_factor).to_int()
  let y = (cg_display_bounds_y(display_id).to_double() * scale_factor).to_int()
  PhysicalPosition(x, y)
}

///|
priv struct MacosMonitorHandleProvider {
  uuid : NativeCfObject
}

///|
impl @core.MonitorHandleProvider for MacosMonitorHandleProvider with fn id(self) {
  (native_cf_uuid_high(self.uuid), native_cf_uuid_low(self.uuid))
}

///|
impl @core.MonitorHandleProvider for MacosMonitorHandleProvider with fn native_id(
  self,
) {
  cg_display_get_display_id_from_uuid(cf_object_handle(self.uuid))
}

///|
impl @core.MonitorHandleProvider for MacosMonitorHandleProvider with fn name(
  self,
) {
  let display_id = @core.MonitorHandleProvider::native_id(self)
  if display_id == (0 : Int).to_uint64() {
    None
  } else {
    Some("Monitor #" + cg_display_model_number(display_id).to_string())
  }
}

///|
impl @core.MonitorHandleProvider for MacosMonitorHandleProvider with fn position(
  self,
) {
  let display_id = @core.MonitorHandleProvider::native_id(self)
  if display_id == (0 : Int).to_uint64() {
    PhysicalPosition(0, 0)
  } else {
    display_position(display_id, clamped_scale_factor(display_id))
  }
}

///|
impl @core.MonitorHandleProvider for MacosMonitorHandleProvider with fn surface_size(
  self,
) {
  let display_id = @core.MonitorHandleProvider::native_id(self)
  if display_id == (0 : Int).to_uint64() {
    PhysicalSize(1, 1)
  } else {
    match current_display_video_mode(display_id) {
      Some(mode) => mode.surface_size()
      None => fallback_display_video_mode(display_id).surface_size()
    }
  }
}

///|
impl @core.MonitorHandleProvider for MacosMonitorHandleProvider with fn scale_factor(
  self,
) {
  clamped_scale_factor(@core.MonitorHandleProvider::native_id(self))
}

///|
impl @core.MonitorHandleProvider for MacosMonitorHandleProvider with fn current_video_mode(
  self,
) {
  let display_id = @core.MonitorHandleProvider::native_id(self)
  if display_id == (0 : Int).to_uint64() {
    None
  } else {
    current_display_video_mode(display_id)
  }
}

///|
impl @core.MonitorHandleProvider for MacosMonitorHandleProvider with fn video_modes(
  self,
) {
  let display_id = @core.MonitorHandleProvider::native_id(self)
  if display_id == (0 : Int).to_uint64() {
    []
  } else {
    let modes = available_display_video_modes(display_id)
    match current_display_video_mode(display_id) {
      Some(mode) => push_unique_video_mode(modes, mode)
      None => ()
    }
    modes
  }
}

///|
fn monitor_from_display_id(display_id : UInt64) -> @core.MonitorHandle? {
  let uuid = cg_display_create_uuid_from_display_id(display_id)
  if !cf_object_valid(uuid) {
    cf_object_release(uuid)
    return None
  }
  Some(
    @core.MonitorHandle::from_provider(
      { uuid, } as &@core.MonitorHandleProvider,
    ),
  )
}

///|
fn monitor_from_native_id(monitor_id : UInt64) -> @core.MonitorHandle? {
  monitor_from_display_id(monitor_id)
}

///|
fn primary_monitor() -> @core.MonitorHandle {
  let display_id = cg_main_display_id()
  match monitor_from_display_id(display_id) {
    Some(monitor) => monitor
    None => abort("primary monitor unavailable")
  }
}

///|
fn available_monitors() -> Array[@core.MonitorHandle] {
  let count = cg_active_display_count()
  let monitors : Array[@core.MonitorHandle] = []
  let mut index = 0
  while index < count {
    let display_id = cg_active_display_id_at(index)
    match monitor_from_display_id(display_id) {
      Some(monitor) =>
        match
          monitors.search_by(existing => {
            existing.native_id() == monitor.native_id()
          }) {
          Some(_) => ()
          None => monitors.push(monitor)
        }
      None => ()
    }
    index = index + 1
  }
  if monitors.is_empty() {
    [primary_monitor()]
  } else {
    monitors
  }
}

///|
// Port target: winit-reference/winit-appkit/src/lib.rs::MonitorHandleExtMacOS::ns_screen
// MoonBit adaptation: foreign type extension methods are not allowed, so expose a free function.

///|
/// A retained snapshot of the `NSScreen` matched to a monitor.
///
/// Display reconfiguration can change which `NSScreen` corresponds to a
/// monitor. Existing handles remain memory-valid, but callers should resolve a
/// new handle after a reconfiguration event instead of treating this snapshot
/// as the current screen indefinitely.
pub struct NSScreenHandle {
  priv object : NativeObjcObject
}

///|
pub impl Debug for NSScreenHandle with fn to_repr(self) {
  Repr::opaque_(
    "NSScreenHandle",
    Repr::literal("0x" + self.objc_handle().to_string()),
  )
}

///|
/// Borrow the underlying `NSScreen*`.
///
/// The pointer remains valid only while this `NSScreenHandle` is alive and has
/// not been dropped. Keep the handle strongly reachable for every native call
/// that uses the pointer, and do not release the pointer directly.
pub fn NSScreenHandle::objc_handle(self : NSScreenHandle) -> UInt64 {
  appkit_objc_owned_object_handle(self.object)
}

///|
/// Release the retained `NSScreen` promptly. Repeated calls are safe.
pub fn NSScreenHandle::drop(self : NSScreenHandle) -> Unit {
  appkit_objc_release_object(self.object)
}

///|
/// Resolve and retain the current `NSScreen` matched to this monitor.
///
/// Resolution always runs on the AppKit main thread. The returned handle owns
/// a snapshot reference; call again after display reconfiguration.
pub fn monitor_ns_screen(monitor : @core.MonitorHandle) -> NSScreenHandle? {
  native_monitor_ns_screen(monitor.native_id())
}
