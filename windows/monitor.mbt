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
fn available_monitors() -> Array[@core.MonitorHandle] {
  let count = native_enum_monitors()
  let handles : Array[@core.MonitorHandle] = []
  for i in 0..<count {
    let native_id = native_monitor_handle_at(i)
    let name = native_monitor_name_bytes_at(i).to_string()
    let x = native_monitor_rect_left_at(i)
    let y = native_monitor_rect_top_at(i)
    let width = native_monitor_rect_width_at(i)
    let height = native_monitor_rect_height_at(i)
    let scale = native_monitor_scale_factor_at(i)
    let position = @dpi.PhysicalPosition::new(x, y)
    let size = @dpi.PhysicalSize::new(width, height)
    let handle = @core.MonitorHandle::new(
      native_id,
      Some(name),
      position,
      size,
      scale,
      None,
      [],
    )
    handles.push(handle)
  }
  handles
}

///|
fn primary_monitor() -> @core.MonitorHandle? {
  let native_id = native_primary_monitor_handle()
  if native_id == (0 : Int).to_uint64() {
    return None
  }
  let count = native_enum_monitors()
  for i in 0..<count {
    let handle = native_monitor_handle_at(i)
    if handle == native_id {
      let name = native_monitor_name_bytes_at(i).to_string()
      let x = native_monitor_rect_left_at(i)
      let y = native_monitor_rect_top_at(i)
      let width = native_monitor_rect_width_at(i)
      let height = native_monitor_rect_height_at(i)
      let scale = native_monitor_scale_factor_at(i)
      return Some(
        @core.MonitorHandle::new(
          native_id,
          Some(name),
          @dpi.PhysicalPosition::new(x, y),
          @dpi.PhysicalSize::new(width, height),
          scale,
          None,
          [],
        ),
      )
    }
  }
  None
}

///|
pub fn monitor_ns_screen(_handle : @core.MonitorHandle) -> UInt64? {
  None
}
