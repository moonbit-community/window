///|
fn dispatch_native_window_event(
  kind : Int,
  raw_id : Int,
  arg0 : Int,
  arg1 : Int,
  arg2 : Int,
  argd : Double,
) -> Unit {
  match kind {
    1 => app_state_queue_window_event(raw_id, @core.WindowEvent::CloseRequested)
    2 => app_state_queue_window_event(raw_id, @core.WindowEvent::Destroyed)
    3 =>
      if arg2 == size_minimized {
        ()
      } else {
        let width = arg0
        let height = arg1
        if width > 0 && height > 0 {
          app_state_queue_window_event(
            raw_id,
            @core.WindowEvent::SurfaceResized(
              @dpi.PhysicalSize::new(width, height),
            ),
          )
        }
      }
    4 => {
      let x = arg0
      let y = arg1
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::Moved(@dpi.PhysicalPosition::new(x, y)),
      )
    }
    5 => app_state_queue_redraw(raw_id)
    6 => {
      let active = arg0
      let focused = active == 1 || active == 2
      app_state_queue_window_event(raw_id, @core.WindowEvent::Focused(focused))
    }
    40 => {
      let dpi_x = arg0
      let _dpi_y = arg1
      let scale_factor = argd
      let window_id = @core.WindowId::from_raw(raw_id)
      let new_size = @dpi.PhysicalSize::new(dpi_x * 8, dpi_x * 5)
      app_state_queue_callback(
        DeferredCallback::ScaleFactorChanged(
          window_id,
          scale_factor,
          new_size.width,
          new_size.height,
        ),
      )
    }
    41 => {
      let theme = if argd > 0.0 {
        @core.Theme::Dark
      } else {
        @core.Theme::Light
      }
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::ThemeChanged(theme),
      )
    }
    _ => ()
  }
}

///|
let mk_lbutton : UInt64 = 0x0001

///|
let mk_rbutton : UInt64 = 0x0002

///|
let mk_shift : UInt64 = 0x0004

///|
let mk_control : UInt64 = 0x0008

///|
let mk_mbutton : UInt64 = 0x0010

///|
let mk_xbutton1 : UInt64 = 0x0020

///|
let mk_xbutton2 : UInt64 = 0x0040

///|
fn decode_mouse_modifiers(wparam : UInt64) -> @core.Modifiers {
  let mut state = @core.ModifiersState::none()
  let mut keys = @core.ModifiersKeys::none()
  if (wparam & mk_shift) != (0 : Int).to_uint64() {
    state = state.union(@core.ModifiersState::shift())
    keys = keys.union(@core.ModifiersKeys::lshift())
  }
  if (wparam & mk_control) != (0 : Int).to_uint64() {
    state = state.union(@core.ModifiersState::control())
    keys = keys.union(@core.ModifiersKeys::lcontrol())
  }
  @core.Modifiers::from_state(state, keys)
}

///|
fn decode_lparam_position(lparam : Int64) -> @dpi.PhysicalPositionF64 {
  let x = (lparam & 0xFFFF : Int64).to_int()
  let y = ((lparam >> 16) & 0xFFFF : Int64).to_int()
  @dpi.PhysicalPositionF64::new(x.to_double(), y.to_double())
}

///|
fn decode_lparam_position_signed(lparam : Int64) -> @dpi.PhysicalPositionF64 {
  let x_raw = (lparam & 0xFFFF : Int64).to_int()
  let y_raw = ((lparam >> 16) & 0xFFFF : Int64).to_int()
  let x = if x_raw > 32767 { x_raw - 65536 } else { x_raw }
  let y = if y_raw > 32767 { y_raw - 65536 } else { y_raw }
  @dpi.PhysicalPositionF64::new(x.to_double(), y.to_double())
}

///|
let window_mouse_tracking : Ref[Array[Int]] = Ref::new([])

///|
fn is_mouse_tracking(raw_id : Int) -> Bool {
  window_mouse_tracking.val.search_by(id => id == raw_id) is Some(_)
}

///|
fn set_mouse_tracking(raw_id : Int, tracking : Bool) -> Unit {
  let next : Array[Int] = []
  let mut found = false
  for id in window_mouse_tracking.val {
    if id == raw_id {
      if tracking {
        next.push(id)
      }
      found = true
    } else {
      next.push(id)
    }
  }
  if !found && tracking {
    next.push(raw_id)
  }
  window_mouse_tracking.val = next
}

///|
fn dispatch_native_input_event(
  raw_id : Int,
  kind : Int,
  wparam : UInt64,
  lparam : Int64,
) -> Unit {
  match kind {
    10 => {
      let position = decode_lparam_position(lparam)
      let modifiers = decode_mouse_modifiers(wparam)
      if is_mouse_tracking(raw_id) == false {
        set_mouse_tracking(raw_id, true)
        ignore(
          native_track_mouse_event(
            match app_state_window_handle(raw_id) {
              Some(hwnd) => hwnd
              None => (0 : Int).to_uint64()
            },
            tme_leave,
          ),
        )
        app_state_queue_window_event(
          raw_id,
          @core.WindowEvent::PointerEntered(
            None,
            position,
            false,
            @core.PointerKind::Mouse,
          ),
        )
      }
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::PointerMoved(
          None,
          position,
          false,
          @core.PointerSource::Mouse,
        ),
      )
    }
    11 => {
      set_mouse_tracking(raw_id, false)
      let position = decode_lparam_position_signed(lparam)
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::PointerLeft(
          None,
          Some(position),
          false,
          @core.PointerKind::Mouse,
        ),
      )
    }
    12 => {
      let position = decode_lparam_position(lparam)
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::PointerButton(
          None,
          @core.ElementState::Pressed,
          position,
          false,
          @core.ButtonSource::Mouse(@core.MouseButton::Left),
        ),
      )
    }
    13 => {
      let position = decode_lparam_position(lparam)
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::PointerButton(
          None,
          @core.ElementState::Released,
          position,
          false,
          @core.ButtonSource::Mouse(@core.MouseButton::Left),
        ),
      )
    }
    14 => {
      let position = decode_lparam_position(lparam)
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::PointerButton(
          None,
          @core.ElementState::Pressed,
          position,
          false,
          @core.ButtonSource::Mouse(@core.MouseButton::Right),
        ),
      )
    }
    15 => {
      let position = decode_lparam_position(lparam)
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::PointerButton(
          None,
          @core.ElementState::Released,
          position,
          false,
          @core.ButtonSource::Mouse(@core.MouseButton::Right),
        ),
      )
    }
    16 => {
      let position = decode_lparam_position(lparam)
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::PointerButton(
          None,
          @core.ElementState::Pressed,
          position,
          false,
          @core.ButtonSource::Mouse(@core.MouseButton::Middle),
        ),
      )
    }
    17 => {
      let position = decode_lparam_position(lparam)
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::PointerButton(
          None,
          @core.ElementState::Released,
          position,
          false,
          @core.ButtonSource::Mouse(@core.MouseButton::Middle),
        ),
      )
    }
    18 => {
      let position = decode_lparam_position(lparam)
      let xbutton = ((wparam >> 16) & 0xFFFF : UInt64).to_int()
      let button = if xbutton == 1 {
        @core.MouseButton::Back
      } else {
        @core.MouseButton::Forward
      }
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::PointerButton(
          None,
          @core.ElementState::Pressed,
          position,
          false,
          @core.ButtonSource::Mouse(button),
        ),
      )
    }
    19 => {
      let position = decode_lparam_position(lparam)
      let xbutton = ((wparam >> 16) & 0xFFFF : UInt64).to_int()
      let button = if xbutton == 1 {
        @core.MouseButton::Back
      } else {
        @core.MouseButton::Forward
      }
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::PointerButton(
          None,
          @core.ElementState::Released,
          position,
          false,
          @core.ButtonSource::Mouse(button),
        ),
      )
    }
    20 => {
      let delta = ((wparam >> 16) & 0xFFFF : UInt64).to_int()
      let signed_delta = if delta > 32767 { delta - 65536 } else { delta }
      let lines = signed_delta.to_double() / wheel_delta.to_double()
      let position = decode_lparam_position_signed(lparam)
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::MouseWheel(
          None,
          @core.MouseScrollDelta::LineDelta(0.0, lines),
          @core.TouchPhase::Moved,
        ),
      )
    }
    21 => {
      let delta = ((wparam >> 16) & 0xFFFF : UInt64).to_int()
      let signed_delta = if delta > 32767 { delta - 65536 } else { delta }
      let lines = signed_delta.to_double() / wheel_delta.to_double()
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::MouseWheel(
          None,
          @core.MouseScrollDelta::LineDelta(lines, 0.0),
          @core.TouchPhase::Moved,
        ),
      )
    }
    30 => {
      let vk_code = wparam.to_int()
      let physical_key = vk_to_physical_key(vk_code, lparam)
      let logical_key = vk_to_logical_key(vk_code)
      let scan_code = ((lparam >> 16) & 0xFF : Int64).to_int()
      let is_extended = ((lparam >> 24) & 0x1 : Int64).to_int() != 0
      let repeat = ((lparam >> 30) & 0x1 : Int64).to_int() != 0
      let location = vk_to_key_location(vk_code, is_extended)
      let key_event = @core.KeyEvent::new(
        physical_key,
        logical_key,
        logical_key,
        location,
        @core.ElementState::Pressed,
        repeat,
        None,
        None,
      )
      let modifiers = compute_modifiers_from_vk()
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::KeyboardInput(None, key_event, false),
      )
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::ModifiersChanged(modifiers),
      )
    }
    31 => {
      let vk_code = wparam.to_int()
      let physical_key = vk_to_physical_key(vk_code, lparam)
      let logical_key = vk_to_logical_key(vk_code)
      let scan_code = ((lparam >> 16) & 0xFF : Int64).to_int()
      let is_extended = ((lparam >> 24) & 0x1 : Int64).to_int() != 0
      let location = vk_to_key_location(vk_code, is_extended)
      let key_event = @core.KeyEvent::new(
        physical_key,
        logical_key,
        logical_key,
        location,
        @core.ElementState::Released,
        false,
        None,
        None,
      )
      let modifiers = compute_modifiers_from_vk()
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::KeyboardInput(None, key_event, false),
      )
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::ModifiersChanged(modifiers),
      )
    }
    32 => {
      let vk_code = wparam.to_int()
      let physical_key = vk_to_physical_key(vk_code, lparam)
      let logical_key = vk_to_logical_key(vk_code)
      let is_extended = ((lparam >> 24) & 0x1 : Int64).to_int() != 0
      let location = vk_to_key_location(vk_code, is_extended)
      let repeat = ((lparam >> 30) & 0x1 : Int64).to_int() != 0
      let key_event = @core.KeyEvent::new(
        physical_key,
        logical_key,
        logical_key,
        location,
        @core.ElementState::Pressed,
        repeat,
        None,
        None,
      )
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::KeyboardInput(None, key_event, true),
      )
    }
    33 => {
      let vk_code = wparam.to_int()
      let physical_key = vk_to_physical_key(vk_code, lparam)
      let logical_key = vk_to_logical_key(vk_code)
      let is_extended = ((lparam >> 24) & 0x1 : Int64).to_int() != 0
      let location = vk_to_key_location(vk_code, is_extended)
      let key_event = @core.KeyEvent::new(
        physical_key,
        logical_key,
        logical_key,
        location,
        @core.ElementState::Released,
        false,
        None,
        None,
      )
      app_state_queue_window_event(
        raw_id,
        @core.WindowEvent::KeyboardInput(None, key_event, true),
      )
    }
    34 => {
      let char_code = wparam.to_int()
      if char_code > 0 {
        let ch = Char::from_int(char_code)
        let text = ch.to_string()
        app_state_queue_window_event(
          raw_id,
          @core.WindowEvent::Ime(@core.Ime::Commit(text)),
        )
      }
    }
    _ => ()
  }
}

///|
fn dispatch_native_sync_query(raw_id : Int, kind : Int, _arg0 : Int) -> Int {
  match kind {
    1 => 0
    10 =>
      match app_state_window_handle(raw_id) {
        Some(_hwnd) => 1
        None => 0
      }
    _ => 0
  }
}

///|
fn vk_to_physical_key(vk_code : Int, _lparam : Int64) -> @core.PhysicalKey {
  let key_code = match vk_code {
    0x41 => @core.KeyCode::KeyA
    0x42 => @core.KeyCode::KeyB
    0x43 => @core.KeyCode::KeyC
    0x44 => @core.KeyCode::KeyD
    0x45 => @core.KeyCode::KeyE
    0x46 => @core.KeyCode::KeyF
    0x47 => @core.KeyCode::KeyG
    0x48 => @core.KeyCode::KeyH
    0x49 => @core.KeyCode::KeyI
    0x4A => @core.KeyCode::KeyJ
    0x4B => @core.KeyCode::KeyK
    0x4C => @core.KeyCode::KeyL
    0x4D => @core.KeyCode::KeyM
    0x4E => @core.KeyCode::KeyN
    0x4F => @core.KeyCode::KeyO
    0x50 => @core.KeyCode::KeyP
    0x51 => @core.KeyCode::KeyQ
    0x52 => @core.KeyCode::KeyR
    0x53 => @core.KeyCode::KeyS
    0x54 => @core.KeyCode::KeyT
    0x55 => @core.KeyCode::KeyU
    0x56 => @core.KeyCode::KeyV
    0x57 => @core.KeyCode::KeyW
    0x58 => @core.KeyCode::KeyX
    0x59 => @core.KeyCode::KeyY
    0x5A => @core.KeyCode::KeyZ
    0x30 => @core.KeyCode::Digit0
    0x31 => @core.KeyCode::Digit1
    0x32 => @core.KeyCode::Digit2
    0x33 => @core.KeyCode::Digit3
    0x34 => @core.KeyCode::Digit4
    0x35 => @core.KeyCode::Digit5
    0x36 => @core.KeyCode::Digit6
    0x37 => @core.KeyCode::Digit7
    0x38 => @core.KeyCode::Digit8
    0x39 => @core.KeyCode::Digit9
    0x70 => @core.KeyCode::F1
    0x71 => @core.KeyCode::F2
    0x72 => @core.KeyCode::F3
    0x73 => @core.KeyCode::F4
    0x74 => @core.KeyCode::F5
    0x75 => @core.KeyCode::F6
    0x76 => @core.KeyCode::F7
    0x77 => @core.KeyCode::F8
    0x78 => @core.KeyCode::F9
    0x79 => @core.KeyCode::F10
    0x7A => @core.KeyCode::F11
    0x7B => @core.KeyCode::F12
    0x7C => @core.KeyCode::F13
    0x7D => @core.KeyCode::F14
    0x7E => @core.KeyCode::F15
    0x7F => @core.KeyCode::F16
    0x80 => @core.KeyCode::F17
    0x81 => @core.KeyCode::F18
    0x82 => @core.KeyCode::F19
    0x83 => @core.KeyCode::F20
    0x84 => @core.KeyCode::F21
    0x85 => @core.KeyCode::F22
    0x86 => @core.KeyCode::F23
    0x87 => @core.KeyCode::F24
    0x08 => @core.KeyCode::Backspace
    0x09 => @core.KeyCode::Tab
    0x0D => @core.KeyCode::Enter
    0x1B => @core.KeyCode::Escape
    0x20 => @core.KeyCode::Space
    0x2D => @core.KeyCode::Insert
    0x2E => @core.KeyCode::Delete
    0x24 => @core.KeyCode::Home
    0x23 => @core.KeyCode::End
    0x21 => @core.KeyCode::PageUp
    0x22 => @core.KeyCode::PageDown
    0x25 => @core.KeyCode::ArrowLeft
    0x26 => @core.KeyCode::ArrowUp
    0x27 => @core.KeyCode::ArrowRight
    0x28 => @core.KeyCode::ArrowDown
    0x10 => @core.KeyCode::ShiftLeft
    0x11 => @core.KeyCode::ControlLeft
    0x12 => @core.KeyCode::AltLeft
    0x5D => @core.KeyCode::ContextMenu
    0x14 => @core.KeyCode::CapsLock
    0x90 => @core.KeyCode::NumLock
    0x91 => @core.KeyCode::ScrollLock
    0x2C => @core.KeyCode::PrintScreen
    0x13 => @core.KeyCode::Pause
    0x60 => @core.KeyCode::Numpad0
    0x61 => @core.KeyCode::Numpad1
    0x62 => @core.KeyCode::Numpad2
    0x63 => @core.KeyCode::Numpad3
    0x64 => @core.KeyCode::Numpad4
    0x65 => @core.KeyCode::Numpad5
    0x66 => @core.KeyCode::Numpad6
    0x67 => @core.KeyCode::Numpad7
    0x68 => @core.KeyCode::Numpad8
    0x69 => @core.KeyCode::Numpad9
    0x6E => @core.KeyCode::NumpadDecimal
    0x6A => @core.KeyCode::NumpadMultiply
    0x6B => @core.KeyCode::NumpadAdd
    0x6D => @core.KeyCode::NumpadSubtract
    0x6F => @core.KeyCode::NumpadDivide
    0x6C => @core.KeyCode::NumpadEnter
    0xBB => @core.KeyCode::Equal
    0xBD => @core.KeyCode::Minus
    0xDB => @core.KeyCode::BracketLeft
    0xDD => @core.KeyCode::BracketRight
    0xBA => @core.KeyCode::Semicolon
    0xDE => @core.KeyCode::Quote
    0xDC => @core.KeyCode::Backslash
    0xBC => @core.KeyCode::Comma
    0xBE => @core.KeyCode::Period
    0xBF => @core.KeyCode::Slash
    0xC0 => @core.KeyCode::Backquote
    _ => @core.KeyCode::Unidentified
  }
  @core.PhysicalKey::from_key_code(key_code)
}

///|
fn vk_to_logical_key(vk_code : Int) -> @core.Key {
  match vk_code {
    0x08 => @core.Key::Named(@core.NamedKey::Backspace)
    0x09 => @core.Key::Named(@core.NamedKey::Tab)
    0x0D => @core.Key::Named(@core.NamedKey::Enter)
    0x1B => @core.Key::Named(@core.NamedKey::Escape)
    0x20 => @core.Key::Character(" ")
    0x21 => @core.Key::Named(@core.NamedKey::PageUp)
    0x22 => @core.Key::Named(@core.NamedKey::PageDown)
    0x23 => @core.Key::Named(@core.NamedKey::End)
    0x24 => @core.Key::Named(@core.NamedKey::Home)
    0x25 => @core.Key::Named(@core.NamedKey::ArrowLeft)
    0x26 => @core.Key::Named(@core.NamedKey::ArrowUp)
    0x27 => @core.Key::Named(@core.NamedKey::ArrowRight)
    0x28 => @core.Key::Named(@core.NamedKey::ArrowDown)
    0x2D => @core.Key::Named(@core.NamedKey::Insert)
    0x2E => @core.Key::Named(@core.NamedKey::Delete)
    0x10 => @core.Key::Named(@core.NamedKey::Shift)
    0x11 => @core.Key::Named(@core.NamedKey::Control)
    0x12 => @core.Key::Named(@core.NamedKey::Alt)
    0x14 => @core.Key::Named(@core.NamedKey::CapsLock)
    0x90 => @core.Key::Named(@core.NamedKey::NumLock)
    0x91 => @core.Key::Named(@core.NamedKey::ScrollLock)
    0x2C => @core.Key::Named(@core.NamedKey::PrintScreen)
    0x13 => @core.Key::Named(@core.NamedKey::Pause)
    0x5D => @core.Key::Named(@core.NamedKey::ContextMenu)
    _ =>
      if vk_code >= 0x41 && vk_code <= 0x5A {
        @core.Key::Character(Char::from_int(vk_code + 32).to_string())
      } else if vk_code >= 0x30 && vk_code <= 0x39 {
        @core.Key::Character(Char::from_int(vk_code).to_string())
      } else if vk_code >= 0x70 && vk_code <= 0x87 {
        let f_num = vk_code - 0x70 + 1
        match f_num {
          1 => @core.Key::Named(@core.NamedKey::F1)
          2 => @core.Key::Named(@core.NamedKey::F2)
          3 => @core.Key::Named(@core.NamedKey::F3)
          4 => @core.Key::Named(@core.NamedKey::F4)
          5 => @core.Key::Named(@core.NamedKey::F5)
          6 => @core.Key::Named(@core.NamedKey::F6)
          7 => @core.Key::Named(@core.NamedKey::F7)
          8 => @core.Key::Named(@core.NamedKey::F8)
          9 => @core.Key::Named(@core.NamedKey::F9)
          10 => @core.Key::Named(@core.NamedKey::F10)
          11 => @core.Key::Named(@core.NamedKey::F11)
          12 => @core.Key::Named(@core.NamedKey::F12)
          13 => @core.Key::Named(@core.NamedKey::F13)
          14 => @core.Key::Named(@core.NamedKey::F14)
          15 => @core.Key::Named(@core.NamedKey::F15)
          16 => @core.Key::Named(@core.NamedKey::F16)
          17 => @core.Key::Named(@core.NamedKey::F17)
          18 => @core.Key::Named(@core.NamedKey::F18)
          19 => @core.Key::Named(@core.NamedKey::F19)
          20 => @core.Key::Named(@core.NamedKey::F20)
          _ => @core.Key::Unidentified(@core.NativeKey::Windows(vk_code))
        }
      } else {
        @core.Key::Unidentified(@core.NativeKey::Windows(vk_code))
      }
  }
}

///|
fn vk_to_key_location(vk_code : Int, is_extended : Bool) -> @core.KeyLocation {
  match vk_code {
    0x10 =>
      if is_extended {
        @core.KeyLocation::Right
      } else {
        @core.KeyLocation::Left
      }
    0x11 =>
      if is_extended {
        @core.KeyLocation::Right
      } else {
        @core.KeyLocation::Left
      }
    0x12 =>
      if is_extended {
        @core.KeyLocation::Right
      } else {
        @core.KeyLocation::Left
      }
    _ =>
      if vk_code >= 0x60 && vk_code <= 0x6F {
        @core.KeyLocation::Numpad
      } else {
        @core.KeyLocation::Standard
      }
  }
}

///|
fn compute_modifiers_from_vk() -> @core.Modifiers {
  let mut state = @core.ModifiersState::none()
  let mut keys = @core.ModifiersKeys::none()
  if native_get_key_state(0x10) != 0 {
    state = state.union(@core.ModifiersState::shift())
    keys = keys.union(@core.ModifiersKeys::lshift())
  }
  if native_get_key_state(0x11) != 0 {
    state = state.union(@core.ModifiersState::control())
    keys = keys.union(@core.ModifiersKeys::lcontrol())
  }
  if native_get_key_state(0x12) != 0 {
    state = state.union(@core.ModifiersState::alt())
    keys = keys.union(@core.ModifiersKeys::lalt())
  }
  @core.Modifiers::from_state(state, keys)
}
