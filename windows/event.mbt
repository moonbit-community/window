///|
fn dispatch_native_window_event(
  kind : Int,
  raw_id : Int,
  arg0 : Int,
  arg1 : Int,
  arg2 : Int,
  argd : Double,
) -> Unit {
  if raw_id <= 0 {
    return
  }
  if app_state_window_handle(raw_id) is None {
    return
  }
  match kind {
    1 => app_state_queue_window_event(raw_id, CloseRequested)
    2 => {
      app_state_clear_window_runtime_state(raw_id)
      app_state_queue_window_event(raw_id, Destroyed)
    }
    3 =>
      if arg2 == size_minimized {
        ()
      } else {
        let width = arg0
        let height = arg1
        if width > 0 && height > 0 {
          app_state_queue_window_event(
            raw_id,
            SurfaceResized(PhysicalSize(width, height)),
          )
        }
      }
    4 => {
      let x = arg0
      let y = arg1
      app_state_queue_window_event(raw_id, Moved(PhysicalPosition(x, y)))
    }
    5 => app_state_queue_redraw(raw_id)
    6 => {
      let active = arg0
      let focused = active == 1 || active == 2
      app_state_queue_window_event(raw_id, Focused(focused))
      if !focused {
        app_state_queue_window_event(
          raw_id,
          ModifiersChanged(@core.Modifiers::default()),
        )
      }
    }
    40 => {
      let width = arg0
      let height = arg1
      let scale_factor = windows_normalized_scale_factor(argd)
      if width > 0 && height > 0 {
        let window_id = @core.WindowId::from_raw(raw_id)
        app_state_queue_callback(
          ScaleFactorChanged(
            window_id,
            scale_factor,
            PhysicalSize(width, height),
          ),
        )
      }
    }
    41 => {
      let theme = if argd > 0.0 { @core.Theme::Dark } else { Light }
      app_state_queue_window_event(raw_id, ThemeChanged(theme))
    }
    _ => ()
  }
}

///|
fn decode_lparam_position(lparam : Int64) -> @dpi.PhysicalPositionF64 {
  let x_raw = (lparam & 0xFFFF : Int64).to_int()
  let y_raw = ((lparam >> 16) & 0xFFFF : Int64).to_int()
  let x = if x_raw > 32767 { x_raw - 65536 } else { x_raw }
  let y = if y_raw > 32767 { y_raw - 65536 } else { y_raw }
  PhysicalPositionF64(x.to_double(), y.to_double())
}

///|
fn text_from_native_utf8_ptr(ptr : UInt64, len : Int) -> String {
  @utf8.decode_lossy(native_consume_utf8_text(ptr, len)[:], ignore_bom=false)
}

///|
priv struct PendingWindowsHighSurrogate {
  raw_id : Int
  code : Int
}

///|
let windows_pending_high_surrogates : Ref[Array[PendingWindowsHighSurrogate]] = Ref([],
)

///|
fn pending_windows_high_surrogate(raw_id : Int) -> Int? {
  match
    windows_pending_high_surrogates.val.search_by(entry => {
      entry.raw_id == raw_id
    }) {
    Some(index) => Some(windows_pending_high_surrogates.val[index].code)
    None => None
  }
}

///|
fn set_pending_windows_high_surrogate(raw_id : Int, code : Int) -> Unit {
  let next : Array[PendingWindowsHighSurrogate] = []
  let mut replaced = false
  for entry in windows_pending_high_surrogates.val {
    if entry.raw_id == raw_id {
      next.push({ raw_id, code })
      replaced = true
    } else {
      next.push(entry)
    }
  }
  if !replaced {
    next.push({ raw_id, code })
  }
  windows_pending_high_surrogates.val = next
}

///|
fn clear_pending_windows_high_surrogate(raw_id : Int) -> Unit {
  let next : Array[PendingWindowsHighSurrogate] = []
  for entry in windows_pending_high_surrogates.val {
    if entry.raw_id != raw_id {
      next.push(entry)
    }
  }
  windows_pending_high_surrogates.val = next
}

///|
fn windows_codepoint_to_text(codepoint : Int) -> String? {
  if codepoint < 0x20 ||
    codepoint == 0x7F ||
    codepoint > 0x10FFFF ||
    (codepoint >= 0xD800 && codepoint <= 0xDFFF) {
    None
  } else {
    Some(codepoint.unsafe_to_char().to_string())
  }
}

///|
fn text_from_windows_char_code(raw_id : Int, char_code : Int) -> String? {
  if char_code >= 0xD800 && char_code <= 0xDBFF {
    set_pending_windows_high_surrogate(raw_id, char_code)
    None
  } else if char_code >= 0xDC00 && char_code <= 0xDFFF {
    match pending_windows_high_surrogate(raw_id) {
      Some(high) => {
        clear_pending_windows_high_surrogate(raw_id)
        let codepoint = 0x10000 + ((high - 0xD800) << 10) + (char_code - 0xDC00)
        windows_codepoint_to_text(codepoint)
      }
      None => None
    }
  } else {
    clear_pending_windows_high_surrogate(raw_id)
    windows_codepoint_to_text(char_code)
  }
}

///|
let window_mouse_tracking : Ref[Array[Int]] = Ref([])

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
fn clear_windows_window_input_state(raw_id : Int) -> Unit {
  set_mouse_tracking(raw_id, false)
  clear_pending_windows_high_surrogate(raw_id)
}

///|
fn dispatch_native_input_event(
  raw_id : Int,
  kind : Int,
  wparam : UInt64,
  lparam : Int64,
) -> Unit {
  if raw_id <= 0 || app_state_window_handle(raw_id) is None {
    return
  }
  match kind {
    10 => {
      let position = decode_lparam_position(lparam)
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
          PointerEntered(None, position, false, Mouse),
        )
      }
      app_state_queue_window_event(
        raw_id,
        PointerMoved(None, position, false, Mouse),
      )
    }
    11 => {
      set_mouse_tracking(raw_id, false)
      let position = decode_lparam_position(lparam)
      app_state_queue_window_event(
        raw_id,
        PointerLeft(None, Some(position), false, Mouse),
      )
    }
    12 => {
      let position = decode_lparam_position(lparam)
      app_state_queue_window_event(
        raw_id,
        PointerButton(None, Pressed, position, false, Mouse(Left)),
      )
    }
    13 => {
      let position = decode_lparam_position(lparam)
      app_state_queue_window_event(
        raw_id,
        PointerButton(None, Released, position, false, Mouse(Left)),
      )
    }
    14 => {
      let position = decode_lparam_position(lparam)
      app_state_queue_window_event(
        raw_id,
        PointerButton(None, Pressed, position, false, Mouse(Right)),
      )
    }
    15 => {
      let position = decode_lparam_position(lparam)
      app_state_queue_window_event(
        raw_id,
        PointerButton(None, Released, position, false, Mouse(Right)),
      )
    }
    16 => {
      let position = decode_lparam_position(lparam)
      app_state_queue_window_event(
        raw_id,
        PointerButton(None, Pressed, position, false, Mouse(Middle)),
      )
    }
    17 => {
      let position = decode_lparam_position(lparam)
      app_state_queue_window_event(
        raw_id,
        PointerButton(None, Released, position, false, Mouse(Middle)),
      )
    }
    18 => {
      let position = decode_lparam_position(lparam)
      let xbutton = ((wparam >> 16) & 0xFFFF : UInt64).to_int()
      let button = if xbutton == 1 { @core.MouseButton::Back } else { Forward }
      app_state_queue_window_event(
        raw_id,
        PointerButton(None, Pressed, position, false, Mouse(button)),
      )
    }
    19 => {
      let position = decode_lparam_position(lparam)
      let xbutton = ((wparam >> 16) & 0xFFFF : UInt64).to_int()
      let button = if xbutton == 1 { @core.MouseButton::Back } else { Forward }
      app_state_queue_window_event(
        raw_id,
        PointerButton(None, Released, position, false, Mouse(button)),
      )
    }
    20 => {
      let delta = ((wparam >> 16) & 0xFFFF : UInt64).to_int()
      let signed_delta = if delta > 32767 { delta - 65536 } else { delta }
      let lines = signed_delta.to_double() / wheel_delta.to_double()
      app_state_queue_window_event(
        raw_id,
        MouseWheel(None, LineDelta(0.0, lines), Moved),
      )
    }
    21 => {
      let delta = ((wparam >> 16) & 0xFFFF : UInt64).to_int()
      let signed_delta = if delta > 32767 { delta - 65536 } else { delta }
      let lines = signed_delta.to_double() / wheel_delta.to_double()
      app_state_queue_window_event(
        raw_id,
        MouseWheel(None, LineDelta(lines, 0.0), Moved),
      )
    }
    30 => {
      let vk_code = wparam.to_int()
      let physical_key = vk_to_physical_key(vk_code, lparam)
      let modifiers = compute_modifiers_from_vk()
      let logical_key = vk_to_logical_key(vk_code, modifiers)
      let key_without_modifiers = vk_to_key_without_modifiers(vk_code)
      let repeat = ((lparam >> 30) & 0x1 : Int64).to_int() != 0
      let location = vk_to_key_location(vk_code, lparam)
      let key_event = @core.KeyEvent::KeyEvent(
        physical_key,
        logical_key,
        key_without_modifiers,
        location,
        Pressed,
        repeat,
        None,
        None,
      )
      app_state_queue_window_event(
        raw_id,
        KeyboardInput(None, key_event, false),
      )
      app_state_queue_window_event(raw_id, ModifiersChanged(modifiers))
    }
    31 => {
      let vk_code = wparam.to_int()
      let physical_key = vk_to_physical_key(vk_code, lparam)
      let modifiers = compute_modifiers_from_vk()
      let logical_key = vk_to_logical_key(vk_code, modifiers)
      let key_without_modifiers = vk_to_key_without_modifiers(vk_code)
      let location = vk_to_key_location(vk_code, lparam)
      let key_event = @core.KeyEvent::KeyEvent(
        physical_key,
        logical_key,
        key_without_modifiers,
        location,
        Released,
        false,
        None,
        None,
      )
      app_state_queue_window_event(
        raw_id,
        KeyboardInput(None, key_event, false),
      )
      app_state_queue_window_event(raw_id, ModifiersChanged(modifiers))
    }
    32 => {
      let vk_code = wparam.to_int()
      let physical_key = vk_to_physical_key(vk_code, lparam)
      let modifiers = compute_modifiers_from_vk()
      let logical_key = vk_to_logical_key(vk_code, modifiers)
      let key_without_modifiers = vk_to_key_without_modifiers(vk_code)
      let location = vk_to_key_location(vk_code, lparam)
      let repeat = ((lparam >> 30) & 0x1 : Int64).to_int() != 0
      let key_event = @core.KeyEvent::KeyEvent(
        physical_key,
        logical_key,
        key_without_modifiers,
        location,
        Pressed,
        repeat,
        None,
        None,
      )
      app_state_queue_window_event(raw_id, KeyboardInput(None, key_event, true))
    }
    33 => {
      let vk_code = wparam.to_int()
      let physical_key = vk_to_physical_key(vk_code, lparam)
      let modifiers = compute_modifiers_from_vk()
      let logical_key = vk_to_logical_key(vk_code, modifiers)
      let key_without_modifiers = vk_to_key_without_modifiers(vk_code)
      let location = vk_to_key_location(vk_code, lparam)
      let key_event = @core.KeyEvent::KeyEvent(
        physical_key,
        logical_key,
        key_without_modifiers,
        location,
        Released,
        false,
        None,
        None,
      )
      app_state_queue_window_event(raw_id, KeyboardInput(None, key_event, true))
    }
    34 => {
      let char_code = wparam.to_int()
      match text_from_windows_char_code(raw_id, char_code) {
        Some(text) => app_state_queue_window_event(raw_id, Ime(Commit(text)))
        None => ()
      }
    }
    35 => app_state_queue_window_event(raw_id, Ime(Enabled))
    36 => {
      let text = text_from_native_utf8_ptr(wparam, lparam.to_int())
      if wparam == 0 && lparam == 0 {
        app_state_queue_window_event(raw_id, Ime(Disabled))
      } else {
        app_state_queue_window_event(raw_id, Ime(Preedit(text, None)))
      }
    }
    37 => {
      let text = text_from_native_utf8_ptr(wparam, lparam.to_int())
      if text != "" {
        app_state_queue_window_event(raw_id, Ime(Commit(text)))
      }
    }
    _ => ()
  }
}

///|
fn dispatch_native_sync_query(raw_id : Int, kind : Int, _arg0 : Int) -> Int {
  if raw_id <= 0 {
    return 0
  }
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
fn windows_lparam_scan_code(lparam : Int64) -> Int {
  ((lparam >> 16) & 0xFF : Int64).to_int()
}

///|
fn windows_lparam_is_extended(lparam : Int64) -> Bool {
  ((lparam >> 24) & 0x1 : Int64).to_int() != 0
}

///|
fn vk_to_physical_key(vk_code : Int, lparam : Int64) -> @core.PhysicalKey {
  let key_code = match vk_code {
    0x41 => @core.KeyCode::KeyA
    0x42 => KeyB
    0x43 => KeyC
    0x44 => KeyD
    0x45 => KeyE
    0x46 => KeyF
    0x47 => KeyG
    0x48 => KeyH
    0x49 => KeyI
    0x4A => KeyJ
    0x4B => KeyK
    0x4C => KeyL
    0x4D => KeyM
    0x4E => KeyN
    0x4F => KeyO
    0x50 => KeyP
    0x51 => KeyQ
    0x52 => KeyR
    0x53 => KeyS
    0x54 => KeyT
    0x55 => KeyU
    0x56 => KeyV
    0x57 => KeyW
    0x58 => KeyX
    0x59 => KeyY
    0x5A => KeyZ
    0x30 => Digit0
    0x31 => Digit1
    0x32 => Digit2
    0x33 => Digit3
    0x34 => Digit4
    0x35 => Digit5
    0x36 => Digit6
    0x37 => Digit7
    0x38 => Digit8
    0x39 => Digit9
    0x70 => F1
    0x71 => F2
    0x72 => F3
    0x73 => F4
    0x74 => F5
    0x75 => F6
    0x76 => F7
    0x77 => F8
    0x78 => F9
    0x79 => F10
    0x7A => F11
    0x7B => F12
    0x7C => F13
    0x7D => F14
    0x7E => F15
    0x7F => F16
    0x80 => F17
    0x81 => F18
    0x82 => F19
    0x83 => F20
    0x84 => F21
    0x85 => F22
    0x86 => F23
    0x87 => F24
    0x08 => Backspace
    0x09 => Tab
    0x0D => if windows_lparam_is_extended(lparam) { NumpadEnter } else { Enter }
    0x1B => Escape
    0x20 => Space
    0x2D => Insert
    0x2E => Delete
    0x24 => Home
    0x23 => End
    0x21 => PageUp
    0x22 => PageDown
    0x25 => ArrowLeft
    0x26 => ArrowUp
    0x27 => ArrowRight
    0x28 => ArrowDown
    0x10 =>
      if windows_lparam_scan_code(lparam) == 0x36 {
        ShiftRight
      } else {
        ShiftLeft
      }
    0xA0 => ShiftLeft
    0xA1 => ShiftRight
    0x11 =>
      if windows_lparam_is_extended(lparam) {
        ControlRight
      } else {
        ControlLeft
      }
    0xA2 => ControlLeft
    0xA3 => ControlRight
    0x12 => if windows_lparam_is_extended(lparam) { AltRight } else { AltLeft }
    0xA4 => AltLeft
    0xA5 => AltRight
    0x5B => MetaLeft
    0x5C => MetaRight
    0x5D => ContextMenu
    0x14 => CapsLock
    0x90 => NumLock
    0x91 => ScrollLock
    0x2C => PrintScreen
    0x13 => Pause
    0x60 => Numpad0
    0x61 => Numpad1
    0x62 => Numpad2
    0x63 => Numpad3
    0x64 => Numpad4
    0x65 => Numpad5
    0x66 => Numpad6
    0x67 => Numpad7
    0x68 => Numpad8
    0x69 => Numpad9
    0x6E => NumpadDecimal
    0x6A => NumpadMultiply
    0x6B => NumpadAdd
    0x6D => NumpadSubtract
    0x6F => NumpadDivide
    0x6C => NumpadEnter
    0xBB => Equal
    0xBD => Minus
    0xDB => BracketLeft
    0xDD => BracketRight
    0xBA => Semicolon
    0xDE => Quote
    0xDC => Backslash
    0xBC => Comma
    0xBE => Period
    0xBF => Slash
    0xC0 => Backquote
    _ => Unidentified
  }
  @core.PhysicalKey::from_key_code(key_code)
}

///|
fn windows_unshifted_text_for_vk(vk_code : Int) -> String? {
  if vk_code >= 0x41 && vk_code <= 0x5A {
    Some((vk_code + 32).unsafe_to_char().to_string())
  } else if vk_code >= 0x30 && vk_code <= 0x39 {
    Some(vk_code.unsafe_to_char().to_string())
  } else {
    match vk_code {
      0x20 => Some(" ")
      0xBB => Some("=")
      0xBD => Some("-")
      0xDB => Some("[")
      0xDD => Some("]")
      0xBA => Some(";")
      0xDE => Some("'")
      0xDC => Some("\\")
      0xBC => Some(",")
      0xBE => Some(".")
      0xBF => Some("/")
      0xC0 => Some("`")
      _ => None
    }
  }
}

///|
fn windows_shifted_text_for_vk(vk_code : Int) -> String? {
  if vk_code >= 0x41 && vk_code <= 0x5A {
    Some(vk_code.unsafe_to_char().to_string())
  } else {
    match vk_code {
      0x30 => Some(")")
      0x31 => Some("!")
      0x32 => Some("@")
      0x33 => Some("#")
      0x34 => Some("$")
      0x35 => Some("%")
      0x36 => Some("^")
      0x37 => Some("&")
      0x38 => Some("*")
      0x39 => Some("(")
      0x20 => Some(" ")
      0xBB => Some("+")
      0xBD => Some("_")
      0xDB => Some("{")
      0xDD => Some("}")
      0xBA => Some(":")
      0xDE => Some("\"")
      0xDC => Some("|")
      0xBC => Some("<")
      0xBE => Some(">")
      0xBF => Some("?")
      0xC0 => Some("~")
      _ => None
    }
  }
}

///|
fn windows_text_for_vk(vk_code : Int, modifiers : @core.Modifiers) -> String? {
  if modifiers.shift_key() {
    windows_shifted_text_for_vk(vk_code)
  } else {
    windows_unshifted_text_for_vk(vk_code)
  }
}

///|
fn vk_to_logical_key(vk_code : Int, modifiers : @core.Modifiers) -> @core.Key {
  match vk_code {
    0x08 => Named(Backspace)
    0x09 => Named(Tab)
    0x0D => Named(Enter)
    0x1B => Named(Escape)
    0x21 => Named(PageUp)
    0x22 => Named(PageDown)
    0x23 => Named(End)
    0x24 => Named(Home)
    0x25 => Named(ArrowLeft)
    0x26 => Named(ArrowUp)
    0x27 => Named(ArrowRight)
    0x28 => Named(ArrowDown)
    0x2D => Named(Insert)
    0x2E => Named(Delete)
    0x10 | 0xA0 | 0xA1 => Named(Shift)
    0x11 | 0xA2 | 0xA3 => Named(Control)
    0x12 | 0xA4 | 0xA5 => Named(Alt)
    0x5B | 0x5C => Named(Meta)
    0x14 => Named(CapsLock)
    0x90 => Named(NumLock)
    0x91 => Named(ScrollLock)
    0x2C => Named(PrintScreen)
    0x13 => Named(Pause)
    0x5D => Named(ContextMenu)
    _ =>
      if vk_code >= 0x70 && vk_code <= 0x87 {
        let f_num = vk_code - 0x70 + 1
        match f_num {
          1 => Named(F1)
          2 => Named(F2)
          3 => Named(F3)
          4 => Named(F4)
          5 => Named(F5)
          6 => Named(F6)
          7 => Named(F7)
          8 => Named(F8)
          9 => Named(F9)
          10 => Named(F10)
          11 => Named(F11)
          12 => Named(F12)
          13 => Named(F13)
          14 => Named(F14)
          15 => Named(F15)
          16 => Named(F16)
          17 => Named(F17)
          18 => Named(F18)
          19 => Named(F19)
          20 => Named(F20)
          _ => Unidentified(Windows(vk_code))
        }
      } else {
        match windows_text_for_vk(vk_code, modifiers) {
          Some(text) => Character(text)
          None => Unidentified(Windows(vk_code))
        }
      }
  }
}

///|
fn vk_to_key_without_modifiers(vk_code : Int) -> @core.Key {
  vk_to_logical_key(vk_code, @core.Modifiers::default())
}

///|
fn vk_to_key_location(vk_code : Int, lparam : Int64) -> @core.KeyLocation {
  let is_extended = windows_lparam_is_extended(lparam)
  match vk_code {
    0x0D => if is_extended { Numpad } else { Standard }
    0x10 => if windows_lparam_scan_code(lparam) == 0x36 { Right } else { Left }
    0xA0 => Left
    0xA1 => Right
    0x11 => if is_extended { Right } else { Left }
    0xA2 => Left
    0xA3 => Right
    0x12 => if is_extended { Right } else { Left }
    0xA4 => Left
    0xA5 => Right
    0x5B => Left
    0x5C => Right
    _ => if vk_code >= 0x60 && vk_code <= 0x6F { Numpad } else { Standard }
  }
}

///|
priv struct WindowsModifierKeyStates {
  shift : Bool
  lshift : Bool
  rshift : Bool
  control : Bool
  lcontrol : Bool
  rcontrol : Bool
  alt : Bool
  lalt : Bool
  ralt : Bool
  lmeta : Bool
  rmeta : Bool
}

///|
fn windows_modifier_key_states_from_vk() -> WindowsModifierKeyStates {
  {
    shift: native_get_key_state(0x10) != 0,
    lshift: native_get_key_state(0xA0) != 0,
    rshift: native_get_key_state(0xA1) != 0,
    control: native_get_key_state(0x11) != 0,
    lcontrol: native_get_key_state(0xA2) != 0,
    rcontrol: native_get_key_state(0xA3) != 0,
    alt: native_get_key_state(0x12) != 0,
    lalt: native_get_key_state(0xA4) != 0,
    ralt: native_get_key_state(0xA5) != 0,
    lmeta: native_get_key_state(0x5B) != 0,
    rmeta: native_get_key_state(0x5C) != 0,
  }
}

///|
fn windows_modifiers_from_key_states(
  states : WindowsModifierKeyStates,
) -> @core.Modifiers {
  let mut state = @core.ModifiersState::none()
  let mut keys = @core.ModifiersKeys::none()
  if states.shift || states.lshift || states.rshift {
    state = state.union(@core.ModifiersState::shift())
  }
  if states.lshift {
    keys = keys.union(@core.ModifiersKeys::lshift())
  }
  if states.rshift {
    keys = keys.union(@core.ModifiersKeys::rshift())
  }
  if states.control || states.lcontrol || states.rcontrol {
    state = state.union(@core.ModifiersState::control())
  }
  if states.lcontrol {
    keys = keys.union(@core.ModifiersKeys::lcontrol())
  }
  if states.rcontrol {
    keys = keys.union(@core.ModifiersKeys::rcontrol())
  }
  if states.alt || states.lalt || states.ralt {
    state = state.union(@core.ModifiersState::alt())
  }
  if states.lalt {
    keys = keys.union(@core.ModifiersKeys::lalt())
  }
  if states.ralt {
    keys = keys.union(@core.ModifiersKeys::ralt())
  }
  if states.lmeta || states.rmeta {
    state = state.union(@core.ModifiersState::meta())
  }
  if states.lmeta {
    keys = keys.union(@core.ModifiersKeys::lmeta())
  }
  if states.rmeta {
    keys = keys.union(@core.ModifiersKeys::rmeta())
  }
  @core.Modifiers::from_state(state, keys)
}

///|
fn compute_modifiers_from_vk() -> @core.Modifiers {
  windows_modifiers_from_key_states(windows_modifier_key_states_from_vk())
}
