///|
extern "C" fn native_enum_monitors() -> Int = "mbw_enum_monitors"

///|
extern "C" fn native_monitor_handle_at(index : Int) -> UInt64 = "mbw_monitor_handle_at"

///|
extern "C" fn native_monitor_rect_left_at(index : Int) -> Int = "mbw_monitor_rect_left_at"

///|
extern "C" fn native_monitor_rect_top_at(index : Int) -> Int = "mbw_monitor_rect_top_at"

///|
extern "C" fn native_monitor_rect_width_at(index : Int) -> Int = "mbw_monitor_rect_width_at"

///|
extern "C" fn native_monitor_rect_height_at(index : Int) -> Int = "mbw_monitor_rect_height_at"

///|
extern "C" fn native_monitor_scale_factor_at(index : Int) -> Double = "mbw_monitor_scale_factor_at"

///|
extern "C" fn native_monitor_name_bytes_at(index : Int) -> Bytes = "mbw_monitor_name_bytes_at"

///|
extern "C" fn native_primary_monitor_handle() -> UInt64 = "mbw_primary_monitor_handle"

///|
extern "C" fn native_current_monitor_handle(hwnd : UInt64) -> UInt64 = "mbw_current_monitor_handle"

///|
fn windows_monitor_surface_size(width : Int, height : Int) -> @dpi.PhysicalSize {
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
  )
}

///|
fn windows_normalized_scale_factor(scale : Double) -> Double {
  if scale > 0.0 && !Double::is_nan(scale) && !Double::is_inf(scale) {
    scale
  } else {
    1.0
  }
}

///|
fn windows_monitor_scale_factor(scale : Double) -> Double {
  windows_normalized_scale_factor(scale)
}

///|
fn monitor_handle_at(index : Int) -> @core.MonitorHandle? {
  let native_id = native_monitor_handle_at(index)
  if native_id == (0 : Int).to_uint64() {
    return None
  }
  let name = native_monitor_name_bytes_at(index).to_string()
  let x = native_monitor_rect_left_at(index)
  let y = native_monitor_rect_top_at(index)
  let width = native_monitor_rect_width_at(index)
  let height = native_monitor_rect_height_at(index)
  let scale = native_monitor_scale_factor_at(index)
  let surface_size = windows_monitor_surface_size(width, height)
  Some(
    MonitorHandle(
      native_id,
      Some(name),
      PhysicalPosition(x, y),
      surface_size,
      windows_monitor_scale_factor(scale),
      None,
      [],
    ),
  )
}

///|
fn monitor_from_native_id(native_id : UInt64) -> @core.MonitorHandle? {
  if native_id == (0 : Int).to_uint64() {
    return None
  }
  let count = native_enum_monitors()
  for i in 0..<count {
    if native_monitor_handle_at(i) == native_id {
      return monitor_handle_at(i)
    }
  }
  None
}

///|
fn available_monitors() -> Array[@core.MonitorHandle] {
  let count = native_enum_monitors()
  let handles : Array[@core.MonitorHandle] = []
  for i in 0..<count {
    match monitor_handle_at(i) {
      Some(handle) => handles.push(handle)
      None => ()
    }
  }
  handles
}

///|
fn primary_monitor() -> @core.MonitorHandle? {
  monitor_from_native_id(native_primary_monitor_handle())
}

///|
fn current_monitor_for_window(hwnd : UInt64) -> @core.MonitorHandle? {
  monitor_from_native_id(native_current_monitor_handle(hwnd))
}

///|
pub fn monitor_ns_screen(_handle : @core.MonitorHandle) -> UInt64? {
  None
}
