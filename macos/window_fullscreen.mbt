///|
// Port target: winit-reference/winit-appkit/src/window_delegate.rs fullscreen behavior
pub fn Window::set_fullscreen(
  self : Window,
  fullscreen : @core.Fullscreen?,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    if window.simple_fullscreen() {
      ()
    } else {
      window.fullscreen_state = fullscreen
      let raw_id = window.raw_window_handle
      match fullscreen {
        None =>
          if window.exclusive_fullscreen_state {
            ignore(window.exit_exclusive_fullscreen())
          } else {
            set_window_fullscreen(raw_id, false)
          }
        Some(Borderless(target_monitor)) => {
          if window.exclusive_fullscreen_state {
            ignore(window.exit_exclusive_fullscreen())
          }
          match target_monitor {
            Some(monitor) => {
              let logical_position = monitor_position_to_logical(monitor)
              set_window_position(
                raw_id,
                logical_position.x().to_int(),
                logical_position.y().to_int(),
              )
            }
            None => ()
          }
          set_window_fullscreen(raw_id, true)
        }
        Some(Exclusive(target_monitor, video_mode)) => {
          if window.exclusive_fullscreen_state {
            ignore(window.exit_exclusive_fullscreen())
          }
          if window_fullscreen(raw_id) && !window.exclusive_fullscreen_state {
            set_window_fullscreen(raw_id, false)
          }
          ignore(window.enter_exclusive_fullscreen(target_monitor, video_mode))
        }
      }
    }
  })
}

///|
pub fn Window::fullscreen(self : Window) -> @core.Fullscreen? {
  self.maybe_wait_on_main(fn(window) {
    let raw_id = window.raw_window_handle
    if window.exclusive_fullscreen_state {
      match window.fullscreen_state {
        Some(fullscreen) => Some(fullscreen)
        None => None
      }
    } else if window_fullscreen(raw_id) {
      match window.fullscreen_state {
        Some(fullscreen) => Some(fullscreen)
        None => Some(Borderless(window.current_monitor()))
      }
    } else {
      window.fullscreen_state = None
      None
    }
  })
}

///|
pub fn Window::is_fullscreen(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    if window.exclusive_fullscreen_state {
      true
    } else {
      window_fullscreen(window.raw_window_handle)
    }
  })
}

///|
pub fn Window::simple_fullscreen(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.simple_fullscreen_state })
}

///|
pub fn Window::set_simple_fullscreen(self : Window, fullscreen : Bool) -> Bool {
  self.maybe_wait_on_main(fn(window) {
    let raw_id = window.raw_window_handle
    if window.is_fullscreen() {
      return false
    }
    if fullscreen == window.simple_fullscreen_state {
      return false
    }
    if fullscreen {
      let outer_position = Some(window.outer_position()) catch { _ => None }
      let current_monitor = window.current_monitor()
      match outer_position {
        Some(saved_outer_position) =>
          match current_monitor {
            Some(monitor) => {
              let logical_position = monitor_position_to_logical(monitor)
              window.simple_fullscreen_saved_style_mask_state = Some(
                window_style_mask_bits(raw_id),
              )
              window.simple_fullscreen_saved_presentation_options_state = Some(
                application_presentation_options(),
              )
              window.simple_fullscreen_saved_outer_position_state = Some(
                saved_outer_position,
              )
              window.simple_fullscreen_saved_outer_size_state = Some(
                window.outer_size(),
              )
              window.simple_fullscreen_state = true
              set_application_presentation_options(
                simple_fullscreen_presentation_options(
                  window.borderless_game_state,
                ),
              )
              clear_window_style_mask_bits(
                raw_id,
                fullscreen_removed_style_bits(),
              )
              set_window_position(
                raw_id,
                logical_position.x().to_int(),
                logical_position.y().to_int(),
              )
              set_window_outer_size(
                raw_id,
                monitor.surface_size().width(),
                monitor.surface_size().height(),
              )
              set_window_movable(raw_id, false)
              true
            }
            None => false
          }
        None => false
      }
    } else {
      let saved_style_mask = window.simple_fullscreen_saved_style_mask_state
      let saved_presentation_options = window.simple_fullscreen_saved_presentation_options_state
      let saved_outer_position = window.simple_fullscreen_saved_outer_position_state
      let saved_outer_size = window.simple_fullscreen_saved_outer_size_state
      window.simple_fullscreen_state = false
      window.simple_fullscreen_saved_style_mask_state = None
      window.simple_fullscreen_saved_presentation_options_state = None
      window.simple_fullscreen_saved_outer_position_state = None
      window.simple_fullscreen_saved_outer_size_state = None
      match saved_presentation_options {
        Some(options) => set_application_presentation_options(options)
        None => ()
      }
      match saved_outer_position {
        Some(position) => {
          let logical_position = physical_outer_position_to_logical(
            position,
            window.scale_factor(),
          )
          set_window_position(
            raw_id,
            logical_position.x().to_int(),
            logical_position.y().to_int(),
          )
        }
        None => ()
      }
      match saved_outer_size {
        Some(size) => set_window_outer_size(raw_id, size.width(), size.height())
        None => ()
      }
      set_window_movable(raw_id, true)
      match saved_style_mask {
        Some(style_mask) => set_window_style_mask_bits(raw_id, style_mask)
        None => ()
      }
      true
    }
  })
}

///|
fn Window::enter_exclusive_fullscreen(
  self : Window,
  target_monitor : @core.MonitorHandle,
  video_mode : @core.VideoMode,
) -> Bool {
  let raw_id = self.raw_window_handle
  let saved_outer_position = Some(self.outer_position()) catch { _ => None }
  let saved_style_mask = window_style_mask_bits(raw_id)
  let saved_outer_size = self.outer_size()
  match saved_outer_position {
    Some(saved_outer_position) => {
      let display_id = target_monitor.native_id()
      let mode_size = video_mode.surface_size()
      let target_mode = find_display_mode_handle(
        display_id,
        mode_size.width(),
        mode_size.height(),
        match video_mode.bit_depth() {
          Some(bit_depth) => bit_depth
          None => 0
        },
        match video_mode.refresh_rate_millihertz() {
          Some(refresh_rate) => refresh_rate
          None => 0
        },
      )
      if display_mode_handle_valid(target_mode) == false {
        return false
      }
      let saved_mode = copy_current_display_mode_handle(display_id)
      if display_mode_handle_valid(saved_mode) == false {
        release_display_mode_handle(target_mode)
        return false
      }
      if capture_display(display_id) == false {
        release_display_mode_handle(target_mode)
        release_display_mode_handle(saved_mode)
        return false
      }
      if set_display_mode_handle(display_id, target_mode) == false {
        ignore(release_display_capture(display_id))
        release_display_mode_handle(target_mode)
        release_display_mode_handle(saved_mode)
        return false
      }
      release_display_mode_handle(target_mode)
      self.exclusive_fullscreen_state = true
      self.exclusive_fullscreen_display_id_state = Some(display_id)
      self.exclusive_fullscreen_saved_mode_state = Some(saved_mode)
      self.exclusive_fullscreen_saved_style_mask_state = Some(saved_style_mask)
      self.exclusive_fullscreen_saved_outer_position_state = Some(
        saved_outer_position,
      )
      self.exclusive_fullscreen_saved_outer_size_state = Some(saved_outer_size)
      set_window_exclusive_runtime_state(raw_id, true, display_id)
      clear_window_style_mask_bits(raw_id, fullscreen_removed_style_bits())
      let logical_target_position = monitor_position_to_logical(target_monitor)
      set_window_position(
        raw_id,
        logical_target_position.x().to_int(),
        logical_target_position.y().to_int(),
      )
      set_window_outer_size(
        raw_id,
        target_monitor.surface_size().width(),
        target_monitor.surface_size().height(),
      )
      set_window_movable(raw_id, false)
      true
    }
    None => false
  }
}

///|
fn Window::exit_exclusive_fullscreen(self : Window) -> Bool {
  if self.exclusive_fullscreen_state == false {
    return false
  }
  let raw_id = self.raw_window_handle
  let saved_display_id = self.exclusive_fullscreen_display_id_state
  let saved_mode = self.exclusive_fullscreen_saved_mode_state
  let saved_style_mask = self.exclusive_fullscreen_saved_style_mask_state
  let saved_outer_position = self.exclusive_fullscreen_saved_outer_position_state
  let saved_outer_size = self.exclusive_fullscreen_saved_outer_size_state
  self.exclusive_fullscreen_state = false
  self.exclusive_fullscreen_display_id_state = None
  self.exclusive_fullscreen_saved_mode_state = None
  self.exclusive_fullscreen_saved_style_mask_state = None
  self.exclusive_fullscreen_saved_outer_position_state = None
  self.exclusive_fullscreen_saved_outer_size_state = None
  match saved_display_id {
    Some(display_id) =>
      match saved_mode {
        Some(saved_mode) => {
          ignore(set_display_mode_handle(display_id, saved_mode))
          ignore(release_display_capture(display_id))
          release_display_mode_handle(saved_mode)
        }
        None => ignore(release_display_capture(display_id))
      }
    None =>
      match saved_mode {
        Some(saved_mode) => release_display_mode_handle(saved_mode)
        None => ()
      }
  }
  set_window_exclusive_runtime_state(raw_id, false, (0 : Int).to_uint64())
  match saved_style_mask {
    Some(style_mask) => set_window_style_mask_bits(raw_id, style_mask)
    None => ()
  }
  match saved_outer_position {
    Some(position) => {
      let logical_position = physical_outer_position_to_logical(
        position,
        self.scale_factor(),
      )
      set_window_position(
        raw_id,
        logical_position.x().to_int(),
        logical_position.y().to_int(),
      )
    }
    None => ()
  }
  match saved_outer_size {
    Some(size) => set_window_outer_size(raw_id, size.width(), size.height())
    None => ()
  }
  set_window_movable(raw_id, true)
  true
}

///|
fn fullscreen_removed_style_bits() -> UInt64 {
  (13 : Int).to_uint64()
}

///|
fn simple_fullscreen_presentation_options(borderless_game : Bool) -> UInt64 {
  if borderless_game {
    (10 : Int).to_uint64()
  } else {
    (5 : Int).to_uint64()
  }
}

///|
pub fn Window::set_borderless_game(
  self : Window,
  borderless_game : Bool,
) -> Unit {
  self.maybe_wait_on_main(fn(window) {
    window.borderless_game_state = borderless_game
    set_window_borderless_game(window.raw_window_handle, borderless_game)
    if window.simple_fullscreen_state {
      set_application_presentation_options(
        simple_fullscreen_presentation_options(borderless_game),
      )
    }
  })
}

///|
pub fn Window::is_borderless_game(self : Window) -> Bool {
  self.maybe_wait_on_main(fn(window) { window.borderless_game_state })
}

///|
fn application_presentation_options() -> UInt64 {
  native_application_presentation_options()
}

///|
fn set_application_presentation_options(options : UInt64) -> Unit {
  native_set_application_presentation_options(options)
}

///|
fn find_display_mode_handle(
  monitor_id : UInt64,
  width : Int,
  height : Int,
  bit_depth : Int,
  refresh_rate_millihertz : Int,
) -> NativeDisplayMode {
  native_find_display_mode_handle(
    monitor_id, width, height, bit_depth, refresh_rate_millihertz,
  )
}

///|
fn copy_current_display_mode_handle(monitor_id : UInt64) -> NativeDisplayMode {
  native_copy_current_display_mode_handle(monitor_id)
}

///|
fn display_mode_handle_valid(mode_handle : NativeDisplayMode) -> Bool {
  native_display_mode_valid(mode_handle)
}

///|
fn release_display_mode_handle(mode_handle : NativeDisplayMode) -> Unit {
  native_release_display_mode_handle(mode_handle)
}

///|
fn capture_display(monitor_id : UInt64) -> Bool {
  native_capture_display(monitor_id)
}

///|
fn set_display_mode_handle(
  monitor_id : UInt64,
  mode_handle : NativeDisplayMode,
) -> Bool {
  native_set_display_mode_handle(monitor_id, mode_handle)
}

///|
fn release_display_capture(monitor_id : UInt64) -> Bool {
  native_release_display_capture(monitor_id)
}

///|
fn set_window_exclusive_runtime_state(
  window_handle : NativeWindow,
  exclusive_fullscreen : Bool,
  display_id : UInt64,
) -> Unit {
  let _ = display_id
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() {
    native_window_set_movable(window_handle, exclusive_fullscreen == false)
  }
}

///|
fn set_window_borderless_game(
  window_handle : NativeWindow,
  borderless_game : Bool,
) -> Unit {
  if registered_native_handle(window_handle) != (0 : Int).to_uint64() &&
    native_window_is_fullscreen(window_handle) {
    set_application_presentation_options(
      simple_fullscreen_presentation_options(borderless_game),
    )
  }
}

///|
fn set_window_fullscreen(
  window_handle : NativeWindow,
  fullscreen : Bool,
) -> Unit {
  let native_handle = registered_native_handle(window_handle)
  if native_handle == (0 : Int).to_uint64() {
    return ()
  }
  let window_identity = native_window_identity(window_handle)
  if window_in_fullscreen_transition(window_handle) {
    set_window_target_fullscreen_state(window_identity, fullscreen)
  } else {
    clear_window_target_fullscreen_state(window_identity)
    toggle_window_fullscreen(window_handle, fullscreen)
  }
}
