///|
priv struct NativeInputPayload {
  raw_id : Int
  kind : Int
  event_type : Int
  x : Double
  y : Double
  state : Int
  button : Int
  modifier_flags : Int
  scancode : Int
  repeat : Int
  pointer_source : Int
  pointer_kind : Int
  scroll_delta_kind : Int
  delta_x : Double
  delta_y : Double
  phase : Int
  text_with_all_modifiers : UInt64
  text_ignoring_modifiers : UInt64
  text_without_modifiers : UInt64
}

///|
priv struct NativeTextInputPayload {
  raw_id : Int
  kind : Int
  state : Int
  text_handle : UInt64
  cursor_start : Int
  cursor_end : Int
  path_handle : UInt64
}

///|
priv struct NativeInputTextPayload {
  text_with_all_modifiers : Bytes
  text_ignoring_modifiers : Bytes
  text_without_modifiers : Bytes
}

///|
priv struct NativeInputEventPayload {
  raw_id : Int
  kind : Int
  event_type : Int
  x : Double
  y : Double
  state : Int
  button : Int
  modifiers : Int
  scancode : Int
  repeat : Int
  pointer_source : Int
  pointer_kind : Int
  scroll_delta_kind : Int
  delta_x : Double
  delta_y : Double
  phase : Int
  text : NativeInputTextPayload
}

///|
fn queue_native_text_input_payload(payload : NativeTextInputPayload) -> Unit {
  queue_native_text_input_event(
    payload.raw_id,
    payload.kind,
    payload.state,
    payload.text_handle,
    payload.cursor_start,
    payload.cursor_end,
    payload.path_handle,
  )
}

///|
fn native_input_keyboard_text_payload(
  kind : Int,
  event_type : Int,
  modifier_flags : Int,
  option_as_alt : Int,
  text_with_all_modifiers : Bytes,
  text_ignoring_modifiers : Bytes,
  text_without_modifiers : Bytes,
) -> NativeInputTextPayload {
  let mut text_without_modifiers = text_without_modifiers
  let mut text_with_all_modifiers = text_with_all_modifiers
  if (kind == 7 || kind == 26) && (event_type == 10 || event_type == 11) {
    let left_alt_pressed = (modifier_flags & 0x20) != 0
    let right_alt_pressed = (modifier_flags & 0x40) != 0
    let alt_pressed = left_alt_pressed || right_alt_pressed
    let control_pressed = (modifier_flags & 262_144) != 0
    let meta_pressed = (modifier_flags & 1_048_576) != 0
    if !control_pressed && !meta_pressed {
      if (option_as_alt == 1 && left_alt_pressed) ||
        (option_as_alt == 2 && right_alt_pressed) ||
        (option_as_alt == 3 && alt_pressed) {
        text_with_all_modifiers = text_ignoring_modifiers
      }
    }
    text_without_modifiers = text_ignoring_modifiers
  }
  { text_with_all_modifiers, text_ignoring_modifiers, text_without_modifiers }
}

///|
fn native_input_payload_to_event(
  payload : NativeInputPayload,
) -> NativeInputEventPayload {
  let text_with_all_modifiers = native_copy_utf8_cstr_bytes(
    payload.text_with_all_modifiers,
  )
  let text_ignoring_modifiers = native_copy_utf8_cstr_bytes(
    payload.text_ignoring_modifiers,
  )
  let text_without_modifiers = native_copy_utf8_cstr_bytes(
    payload.text_without_modifiers,
  )
  {
    raw_id: payload.raw_id,
    kind: payload.kind,
    event_type: payload.event_type,
    x: payload.x,
    y: payload.y,
    state: payload.state,
    button: payload.button,
    modifiers: native_modifiers_from_modifier_flags(payload.modifier_flags),
    scancode: payload.scancode,
    repeat: payload.repeat,
    pointer_source: payload.pointer_source,
    pointer_kind: payload.pointer_kind,
    scroll_delta_kind: payload.scroll_delta_kind,
    delta_x: payload.delta_x,
    delta_y: payload.delta_y,
    phase: payload.phase,
    text: native_input_keyboard_text_payload(
      payload.kind,
      payload.event_type,
      payload.modifier_flags,
      option_as_alt_for_window(payload.raw_id),
      text_with_all_modifiers,
      text_ignoring_modifiers,
      text_without_modifiers,
    ),
  }
}

///|
fn native_input_kind_tracks_pointer_motion(kind : Int) -> Bool {
  kind == 4 ||
  kind == 5 ||
  kind == 13 ||
  kind == 14 ||
  kind == 15 ||
  kind == 16 ||
  kind == 17
}

///|
fn queue_native_input_event(payload : NativeInputPayload) -> Unit {
  let event = native_input_payload_to_event(payload)
  if event.kind == 7 && event.event_type == 12 {
    let state = modifiers_state_from_native(event.modifiers)
    let pressed_modifiers = normalize_pressed_modifier_keys(
      state,
      view_pressed_modifiers(event.raw_id),
    )
    view_set_pressed_modifiers(event.raw_id, pressed_modifiers)
    app_state_queue_window_callback(
      @core.WindowId::from_raw(event.raw_id),
      ModifiersChanged(@core.Modifiers::from_state(state, pressed_modifiers)),
    )
  }
  if event.kind == 7 &&
    event.event_type == 11 &&
    !view_ime_allows_key_up(event.raw_id) {
    return ()
  }
  if event.kind == 26 {
    view_set_pending_key_snapshot(event.raw_id, {
      x: event.x,
      y: event.y,
      state: event.state,
      button: event.button,
      modifiers: event.modifiers,
      scancode: event.scancode,
      repeat: event.repeat,
      pointer_source: event.pointer_source,
      pointer_kind: event.pointer_kind,
      scroll_delta_kind: event.scroll_delta_kind,
      delta_x: event.delta_x,
      delta_y: event.delta_y,
      phase: event.phase,
      text_with_all_modifiers: event.text.text_with_all_modifiers,
      text_ignoring_modifiers: event.text.text_ignoring_modifiers,
      text_without_modifiers: event.text.text_without_modifiers,
    })
    return ()
  }
  if native_input_kind_tracks_pointer_motion(event.kind) {
    queue_pointer_motion_event(event.raw_id, event.x, event.y)
  }
  queue_input_event(
    event.raw_id,
    event.kind,
    event.x,
    event.y,
    event.state,
    event.button,
    event.modifiers,
    event.scancode,
    event.repeat,
    event.pointer_source,
    event.pointer_kind,
    event.scroll_delta_kind,
    event.delta_x,
    event.delta_y,
    event.phase,
    event.text.text_with_all_modifiers,
    event.text.text_ignoring_modifiers,
    event.text.text_without_modifiers,
    0,
    @utf8.encode(""[:], bom=false),
    -1,
    -1,
    @utf8.encode(""[:], bom=false),
  )
}

///|
fn native_callback_input_event(
  raw_id : Int,
  kind : Int,
  event_type : Int,
  x : Double,
  y : Double,
  state : Int,
  button : Int,
  modifier_flags : Int,
  scancode : Int,
  repeat : Int,
  pointer_source : Int,
  pointer_kind : Int,
  scroll_delta_kind : Int,
  delta_x : Double,
  delta_y : Double,
  phase : Int,
  text_with_all_modifiers : UInt64,
  text_ignoring_modifiers : UInt64,
  text_without_modifiers : UInt64,
) -> Unit {
  queue_native_input_event({
    raw_id,
    kind,
    event_type,
    x,
    y,
    state,
    button,
    modifier_flags,
    scancode,
    repeat,
    pointer_source,
    pointer_kind,
    scroll_delta_kind,
    delta_x,
    delta_y,
    phase,
    text_with_all_modifiers,
    text_ignoring_modifiers,
    text_without_modifiers,
  })
}

///|
fn native_callback_text_input_event(
  raw_id : Int,
  kind : Int,
  state : Int,
  text_handle : UInt64,
  cursor_start : Int,
  cursor_end : Int,
  path_handle : UInt64,
) -> Unit {
  queue_native_text_input_payload({
    raw_id,
    kind,
    state,
    text_handle,
    cursor_start,
    cursor_end,
    path_handle,
  })
}
