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
fn fallback_display_video_mode(display_id : UInt64) -> @core.VideoMode {
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
fn display_video_mode_from_handle(
  display_id : UInt64,
  mode_handle : UInt64,
) -> @core.VideoMode? {
  if mode_handle == (0 : Int).to_uint64() {
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
      native_display_refresh_rate_millihertz(display_id)
    }
  }
  Some(
    @core.VideoMode::new(
      @dpi.PhysicalSize::new(width, height),
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
  let count = native_copy_display_mode_count(display_id)
  let mut index = 0
  while index < count {
    let mode_handle = native_copy_display_mode_handle_at(display_id, index)
    if mode_handle != (0 : Int).to_uint64() {
      match display_video_mode_from_handle(display_id, mode_handle) {
        Some(mode) => push_unique_video_mode(modes, mode)
        None => ()
      }
      native_release_display_mode_handle(mode_handle)
    }
    index = index + 1
  }
  modes
}

///|
fn current_display_video_mode(display_id : UInt64) -> @core.VideoMode? {
  let mode_handle = native_copy_current_display_mode_handle(display_id)
  if mode_handle == (0 : Int).to_uint64() {
    return None
  }
  let mode = display_video_mode_from_handle(display_id, mode_handle)
  native_release_display_mode_handle(mode_handle)
  mode
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
  let current_mode = match current_display_video_mode(display_id) {
    Some(mode) => mode
    None => fallback_display_video_mode(display_id)
  }
  let video_modes = available_display_video_modes(display_id)
  push_unique_video_mode(video_modes, current_mode)
  let width = current_mode.surface_size().width
  let height = current_mode.surface_size().height
  let model_number = cg_display_model_number(display_id)
  Some(
    @core.MonitorHandle::new(
      display_id,
      Some("Monitor #" + model_number.to_string()),
      display_position(display_id, scale_factor),
      @dpi.PhysicalSize::new(width, height),
      scale_factor,
      Some(current_mode),
      video_modes,
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
