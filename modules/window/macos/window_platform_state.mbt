///|
priv struct WindowPlatformStateEntry {
  window_handle : UInt64
  mut ime_allowed : Bool
  mut cursor_visible : Bool
  mut accepts_first_mouse : Bool
  mut option_as_alt : Int
  mut ime_purpose : Int
  mut ime_hints : Int
  mut ime_cursor_x : Int
  mut ime_cursor_y : Int
  mut ime_cursor_width : Int
  mut ime_cursor_height : Int
}

///|
fn default_window_platform_state_entry(
  window_handle : UInt64,
) -> WindowPlatformStateEntry {
  {
    window_handle,
    ime_allowed: false,
    cursor_visible: true,
    accepts_first_mouse: false,
    option_as_alt: 0,
    ime_purpose: 0,
    ime_hints: 0,
    ime_cursor_x: 0,
    ime_cursor_y: 0,
    ime_cursor_width: 1,
    ime_cursor_height: 1,
  }
}

///|
let window_platform_state_entries : Ref[Array[WindowPlatformStateEntry]] = Ref([])

///|
fn window_platform_state_index(window_handle : UInt64) -> Int? {
  let window_identity = window_handle
  window_platform_state_entries.val.search_by(entry => {
    entry.window_handle == window_identity
  })
}

///|
fn window_platform_state_ensure_index(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => index
    None => {
      window_platform_state_entries.val.push(
        default_window_platform_state_entry(window_handle),
      )
      window_platform_state_entries.val.length() - 1
    }
  }
}

///|
fn clear_window_platform_state(window_handle : UInt64) -> Unit {
  match window_platform_state_index(window_handle) {
    Some(index) => ignore(window_platform_state_entries.val.remove(index))
    None => ()
  }
}

///|
fn set_window_ime_allowed_state(window_handle : UInt64, allowed : Bool) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  window_platform_state_entries.val[index].ime_allowed = allowed
}

///|
fn window_ime_allowed_state(window_handle : UInt64) -> Bool {
  match window_platform_state_index(window_handle) {
    Some(index) => window_platform_state_entries.val[index].ime_allowed
    None => false
  }
}

///|
fn set_window_cursor_visible_state(
  window_handle : UInt64,
  visible : Bool,
) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  window_platform_state_entries.val[index].cursor_visible = visible
}

///|
fn window_cursor_visible_state(window_handle : UInt64) -> Bool {
  match window_platform_state_index(window_handle) {
    Some(index) => window_platform_state_entries.val[index].cursor_visible
    None => true
  }
}

///|
fn set_window_option_as_alt_state(
  window_handle : UInt64,
  option_as_alt : Int,
) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  window_platform_state_entries.val[index].option_as_alt = option_as_alt
}

///|
fn window_option_as_alt_native(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_platform_state_entries.val[index].option_as_alt
    None => 0
  }
}

///|
fn set_window_accepts_first_mouse_state(
  window_handle : UInt64,
  accepts_first_mouse : Bool,
) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  window_platform_state_entries.val[index].accepts_first_mouse = accepts_first_mouse
}

///|
fn window_accepts_first_mouse_state(window_handle : UInt64) -> Bool {
  match window_platform_state_index(window_handle) {
    Some(index) => window_platform_state_entries.val[index].accepts_first_mouse
    None => false
  }
}

///|
fn set_window_ime_purpose_state(window_handle : UInt64, purpose : Int) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  window_platform_state_entries.val[index].ime_purpose = purpose
}

///|
fn window_ime_purpose_state(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_platform_state_entries.val[index].ime_purpose
    None => 0
  }
}

///|
fn set_window_ime_hints_state(window_handle : UInt64, hints : Int) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  window_platform_state_entries.val[index].ime_hints = hints
}

///|
fn window_ime_hints_state(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_platform_state_entries.val[index].ime_hints
    None => 0
  }
}

///|
fn set_window_ime_cursor_area_state(
  window_handle : UInt64,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Unit {
  let index = window_platform_state_ensure_index(window_handle)
  let entry = window_platform_state_entries.val[index]
  entry.ime_cursor_x = x
  entry.ime_cursor_y = y
  entry.ime_cursor_width = clamp_size(width)
  entry.ime_cursor_height = clamp_size(height)
}

///|
fn window_ime_cursor_x_state(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_platform_state_entries.val[index].ime_cursor_x
    None => 0
  }
}

///|
fn window_ime_cursor_y_state(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_platform_state_entries.val[index].ime_cursor_y
    None => 0
  }
}

///|
fn window_ime_cursor_width_state(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_platform_state_entries.val[index].ime_cursor_width
    None => 1
  }
}

///|
fn window_ime_cursor_height_state(window_handle : UInt64) -> Int {
  match window_platform_state_index(window_handle) {
    Some(index) => window_platform_state_entries.val[index].ime_cursor_height
    None => 1
  }
}
