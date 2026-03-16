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
fn native_find_display_mode_handle(
  monitor_id : UInt64,
  width : Int,
  height : Int,
  bit_depth : Int,
  refresh_rate_millihertz : Int,
) -> UInt64 {
  native_monitor_find_display_mode_handle(
    monitor_id.to_uint(),
    width,
    height,
    bit_depth,
    refresh_rate_millihertz,
  )
}

///|
fn native_copy_current_display_mode_handle(monitor_id : UInt64) -> UInt64 {
  native_monitor_copy_current_display_mode_handle(monitor_id.to_uint())
}

///|
fn native_copy_display_mode_count(monitor_id : UInt64) -> Int {
  let count = native_monitor_copy_display_mode_count(monitor_id.to_uint())
  if count > 0 {
    count
  } else {
    0
  }
}

///|
fn native_copy_display_mode_handle_at(
  monitor_id : UInt64,
  index : Int,
) -> UInt64 {
  native_monitor_copy_display_mode_handle_at(monitor_id.to_uint(), index)
}

///|
fn native_display_mode_width(mode_handle : UInt64) -> Int {
  let width = native_monitor_display_mode_width(mode_handle)
  if width > 0 {
    width
  } else {
    0
  }
}

///|
fn native_display_mode_height(mode_handle : UInt64) -> Int {
  let height = native_monitor_display_mode_height(mode_handle)
  if height > 0 {
    height
  } else {
    0
  }
}

///|
fn native_display_mode_bit_depth(mode_handle : UInt64) -> Int {
  let bit_depth = native_monitor_display_mode_bit_depth(mode_handle)
  if bit_depth > 0 {
    bit_depth
  } else {
    0
  }
}

///|
fn native_display_mode_refresh_rate_millihertz(mode_handle : UInt64) -> Int {
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
  let maximum_frames_per_second = objc_runtime_selector_handle(
    "maximumFramesPerSecond",
  )
  let mut screen = native_monitor_ns_screen(monitor_id)
  if screen == (0 : Int).to_uint64() {
    let ns_screen_class = objc_runtime_class_handle("NSScreen")
    if ns_screen_class == (0 : Int).to_uint64() {
      return 0
    }
    screen = appkit_objc_msg_send_u64(
      ns_screen_class,
      objc_runtime_selector_handle("mainScreen"),
    )
  }
  if screen == (0 : Int).to_uint64() ||
    appkit_objc_msg_send_bool_u64(
      screen,
      objc_runtime_selector_handle("respondsToSelector:"),
      maximum_frames_per_second,
    ) ==
    false {
    return 0
  }
  let frames_per_second = appkit_objc_msg_send_i64(
    screen, maximum_frames_per_second,
  ).to_int()
  if frames_per_second <= 0 {
    return 0
  }
  if frames_per_second > 2_147_483 {
    2_147_483_647
  } else {
    frames_per_second * 1000
  }
}

///|
fn native_release_display_mode_handle(mode_handle : UInt64) -> Unit {
  native_monitor_release_display_mode_handle(mode_handle)
}

///|
fn native_capture_display(monitor_id : UInt64) -> Bool {
  native_monitor_capture_display(monitor_id.to_uint()) != 0
}

///|
fn native_set_display_mode_handle(
  monitor_id : UInt64,
  mode_handle : UInt64,
) -> Bool {
  native_monitor_set_display_mode_handle(monitor_id.to_uint(), mode_handle) != 0
}

///|
fn native_release_display_capture(monitor_id : UInt64) -> Bool {
  native_monitor_release_display_capture(monitor_id.to_uint()) != 0
}

///|
fn native_monitor_ns_screen(monitor_id : UInt64) -> UInt64 {
  if monitor_id == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let normalized_monitor_id = normalize_display_id(monitor_id)
  if normalized_monitor_id == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let ns_screen_class = objc_runtime_class_handle("NSScreen")
  if ns_screen_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let screens = appkit_objc_msg_send_u64(
    ns_screen_class,
    objc_runtime_selector_handle("screens"),
  )
  if screens == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let count = appkit_objc_msg_send_i64(
    screens,
    objc_runtime_selector_handle("count"),
  ).to_int()
  if count <= 0 {
    return (0 : Int).to_uint64()
  }
  let key = objc_nsstring_from_string("NSScreenNumber")
  if key == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let object_at_index = objc_runtime_selector_handle("objectAtIndex:")
  let device_description = objc_runtime_selector_handle("deviceDescription")
  let object_for_key = objc_runtime_selector_handle("objectForKey:")
  let unsigned_int_value = objc_runtime_selector_handle("unsignedIntValue")
  let mut index = 0
  while index < count {
    let screen = appkit_objc_msg_send_u64_u64(
      screens,
      object_at_index,
      index.to_uint64(),
    )
    if screen != (0 : Int).to_uint64() {
      let description = appkit_objc_msg_send_u64(screen, device_description)
      if description != (0 : Int).to_uint64() {
        let number = appkit_objc_msg_send_u64_u64(
          description, object_for_key, key,
        )
        if number != (0 : Int).to_uint64() {
          let screen_display_id = appkit_objc_msg_send_u64(
            number, unsigned_int_value,
          )
          let normalized_screen_id = normalize_display_id(screen_display_id)
          if normalized_screen_id == normalized_monitor_id {
            return screen
          }
        }
      }
    }
    index = index + 1
  }
  (0 : Int).to_uint64()
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

///|
// Port target: winit-reference/winit-appkit/src/lib.rs::MonitorHandleExtMacOS::ns_screen
// MoonBit adaptation: foreign type extension methods are not allowed, so expose a free function.
pub fn monitor_ns_screen(monitor : @core.MonitorHandle) -> UInt64? {
  let screen = native_monitor_ns_screen(monitor.native_id())
  if screen == (0 : Int).to_uint64() {
    None
  } else {
    Some(screen)
  }
}
