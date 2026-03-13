///|
// Port target: winit-reference/winit-appkit/src/monitor.rs
// MoonBit adaptation:
// 1. We build monitor handles from CoreGraphics display IDs.
// 2. Active displays are enumerated through small native primitives.

fn normalize_display_id(display_id : UInt64) -> UInt64 {
  let uuid = cg_display_create_uuid_from_display_id(display_id)
  if uuid == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let normalized = cg_display_get_display_id_from_uuid(uuid)
  cf_release(uuid)
  normalized
}

///|
fn display_video_mode(display_id : UInt64) -> @core.VideoMode {
  let width = cg_display_pixels_wide(display_id)
  let height = cg_display_pixels_high(display_id)
  @core.VideoMode::new(
    @dpi.PhysicalSize::new(
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
fn clamped_scale_factor(display_id : UInt64) -> Double {
  let scale = cg_display_scale_factor(display_id)
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
  @dpi.PhysicalPosition::new(x, y)
}

///|
fn monitor_from_display_id(display_id : UInt64) -> @core.MonitorHandle? {
  let display_id = normalize_display_id(display_id)
  if display_id == (0 : Int).to_uint64() {
    return None
  }
  let scale_factor = clamped_scale_factor(display_id)
  let mode = display_video_mode(display_id)
  let width = mode.surface_size().width
  let height = mode.surface_size().height
  let model_number = cg_display_model_number(display_id)
  Some(
    @core.MonitorHandle::new(
      display_id,
      Some("Monitor #" + model_number.to_string()),
      display_position(display_id, scale_factor),
      @dpi.PhysicalSize::new(width, height),
      scale_factor,
      Some(mode),
      [mode],
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
