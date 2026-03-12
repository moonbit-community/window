///|
// Port target: winit-reference/winit-appkit/src/monitor.rs

///|
pub fn EventLoop::available_monitors(
  _self : EventLoop,
) -> Array[@core.MonitorHandle] {
  available_monitors()
}

///|
pub fn EventLoop::primary_monitor(_self : EventLoop) -> @core.MonitorHandle? {
  primary_monitor()
}

///|
pub fn monitor_ns_screen(monitor : @core.MonitorHandle) -> UInt64? {
  let screen_handle = monitor_screen_handle(monitor.native_id())
  if screen_handle == (0 : Int).to_uint64() {
    None
  } else {
    Some(screen_handle)
  }
}

///|
pub fn ns_screen(monitor : @core.MonitorHandle) -> UInt64? {
  monitor_ns_screen(monitor)
}

///|
pub fn Window::available_monitors(self : Window) -> Array[@core.MonitorHandle] {
  let _ = self
  available_monitors()
}

///|
pub fn Window::primary_monitor(self : Window) -> @core.MonitorHandle? {
  let _ = self
  primary_monitor()
}

///|
pub fn Window::current_monitor(self : Window) -> @core.MonitorHandle? {
  let monitor_id = window_current_monitor_id(self.id.into_raw())
  if monitor_id == (0 : Int).to_uint64() {
    None
  } else {
    monitor_from_native_id(monitor_id)
  }
}

///|
fn available_monitors() -> Array[@core.MonitorHandle] {
  let monitors : Array[@core.MonitorHandle] = []
  let count = available_monitor_count()
  let mut index = 0
  while index < count {
    match monitor_from_native_id(monitor_id_at(index)) {
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
  monitors
}

///|
fn primary_monitor() -> @core.MonitorHandle? {
  match monitor_from_native_id(primary_monitor_id()) {
    Some(monitor) => Some(monitor)
    None => {
      let monitors = available_monitors()
      if monitors.length() == 0 {
        None
      } else {
        Some(monitors[0])
      }
    }
  }
}

///|
fn video_mode_from_native(
  monitor_id : UInt64,
  mode_index : Int,
) -> @core.VideoMode? {
  let mode_width = monitor_video_mode_width(monitor_id, mode_index)
  let mode_height = monitor_video_mode_height(monitor_id, mode_index)
  if mode_width <= 0 || mode_height <= 0 {
    None
  } else {
    let bit_depth_raw = monitor_video_mode_bit_depth(monitor_id, mode_index)
    let refresh_rate_raw = monitor_video_mode_refresh_rate_millihertz(
      monitor_id, mode_index,
    )
    Some(
      @core.VideoMode::new(
        @dpi.PhysicalSize::new(mode_width, mode_height),
        if bit_depth_raw > 0 {
          Some(bit_depth_raw)
        } else {
          None
        },
        if refresh_rate_raw > 0 {
          Some(refresh_rate_raw)
        } else {
          None
        },
      ),
    )
  }
}

///|
fn video_modes_from_native(monitor_id : UInt64) -> Array[@core.VideoMode] {
  let video_mode_count = monitor_video_mode_count(monitor_id)
  let video_modes : Array[@core.VideoMode] = []
  let mut mode_index = 0
  while mode_index < video_mode_count {
    match video_mode_from_native(monitor_id, mode_index) {
      Some(mode) =>
        match video_modes.search_by(existing => existing == mode) {
          Some(_) => ()
          None => video_modes.push(mode)
        }
      None => ()
    }
    mode_index = mode_index + 1
  }
  video_modes
}

///|
fn current_video_mode_from_native(
  monitor_id : UInt64,
  video_modes : Array[@core.VideoMode],
) -> @core.VideoMode? {
  if video_modes.length() == 0 {
    return None
  }
  let current_mode_index = monitor_current_video_mode_index(monitor_id)
  if current_mode_index >= 0 && current_mode_index < video_modes.length() {
    Some(video_modes[current_mode_index])
  } else {
    Some(video_modes[0])
  }
}

///|
fn monitor_from_native_id(monitor_id : UInt64) -> @core.MonitorHandle? {
  let monitor_id = monitor_normalize_id(monitor_id)
  if monitor_id == (0 : Int).to_uint64() {
    None
  } else {
    let width = monitor_width(monitor_id)
    let height = monitor_height(monitor_id)
    let base_video_modes = video_modes_from_native(monitor_id)
    let video_modes = if base_video_modes.length() == 0 {
      [
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
        ),
      ]
    } else {
      base_video_modes
    }
    Some(
      @core.MonitorHandle::new(
        monitor_id,
        optional_text_from_native(monitor_name(monitor_id)),
        @dpi.PhysicalPosition::new(
          monitor_position_x(monitor_id),
          monitor_position_y(monitor_id),
        ),
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
        monitor_scale_factor(monitor_id),
        current_video_mode_from_native(monitor_id, video_modes),
        video_modes,
      ),
    )
  }
}
