///|
// Port target: winit-reference/winit-appkit/src/view.rs

///|
fn ime_from_native_payload(
  ime_kind : Int,
  ime_text : Bytes,
  ime_cursor_start : Int,
  ime_cursor_end : Int,
) -> @core.Ime? {
  match ime_kind {
    1 => Some(@core.Ime::Enabled)
    2 => {
      let cursor_start = ime_cursor_start
      let cursor_end = ime_cursor_end
      let cursor = if cursor_start >= 0 && cursor_end >= cursor_start {
        Some(@core.ImeCursorRange::new(cursor_start, cursor_end))
      } else {
        None
      }
      Some(@core.Ime::Preedit(text_from_native(ime_text), cursor))
    }
    3 => Some(@core.Ime::Commit(text_from_native(ime_text)))
    4 => Some(@core.Ime::Disabled)
    5 => {
      let before = clamp_non_negative(ime_cursor_start)
      let after = clamp_non_negative(ime_cursor_end)
      Some(@core.Ime::DeleteSurrounding(before, after))
    }
    _ => None
  }
}

///|
fn clamp_non_negative(value : Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
fn scroll_phase_from_native(phase : Int) -> @core.TouchPhase {
  match touch_phase_from_native(phase) {
    Some(phase) => phase
    None => @core.TouchPhase::Moved
  }
}

///|
fn queue_view_standard_key_binding(
  window_id : @core.WindowId,
  action : String,
) -> Unit {
  if action.length() == 0 {
    ()
  } else {
    app_state_queue_standard_key_binding_callback(window_id, action)
  }
}

///|
let view_modifier_window_ids : Ref[Array[Int]] = Ref::new([])

///|
let view_modifier_window_values : Ref[Array[@core.ModifiersKeys]] = Ref::new([])

///|
fn view_pressed_modifiers(window_id : Int) -> @core.ModifiersKeys {
  match view_modifier_window_ids.val.search_by(id => id == window_id) {
    Some(index) => view_modifier_window_values.val[index]
    None => @core.ModifiersKeys::none()
  }
}

///|
fn view_set_pressed_modifiers(
  window_id : Int,
  pressed_modifiers : @core.ModifiersKeys,
) -> Unit {
  match view_modifier_window_ids.val.search_by(id => id == window_id) {
    Some(index) => view_modifier_window_values.val[index] = pressed_modifiers
    None => {
      view_modifier_window_ids.val.push(window_id)
      view_modifier_window_values.val.push(pressed_modifiers)
    }
  }
}

///|
fn view_clear_pressed_modifiers(window_id : Int) -> Unit {
  match view_modifier_window_ids.val.search_by(id => id == window_id) {
    Some(index) => {
      ignore(view_modifier_window_ids.val.remove(index))
      ignore(view_modifier_window_values.val.remove(index))
    }
    None => ()
  }
}

///|
fn queue_input_event(
  raw_id : Int,
  kind : Int,
  x : Double,
  y : Double,
  state : Int,
  button : Int,
  modifiers : Int,
  scancode : Int,
  repeat : Int,
  pointer_source : Int,
  pointer_kind : Int,
  scroll_delta_kind : Int,
  delta_x : Double,
  delta_y : Double,
  phase : Int,
  text_with_all_modifiers : Bytes,
  text_ignoring_modifiers : Bytes,
  text_without_modifiers : Bytes,
  ime_kind : Int,
  ime_text : Bytes,
  ime_cursor_start : Int,
  ime_cursor_end : Int,
  path : Bytes,
) -> Unit {
  let window_id = @core.WindowId::from_raw(raw_id)
  let pointer_device_id = Some(@core.DeviceId::from_raw(1L))
  let keyboard_device_id = Some(@core.DeviceId::from_raw(2L))
  let position = @dpi.PhysicalPositionF64::new(x, y)
  match kind {
    1 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::PointerMoved(
          pointer_device_id,
          position,
          true,
          pointer_source_from_native(pointer_source),
        ),
      )
    2 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::PointerEntered(
          pointer_device_id,
          position,
          true,
          pointer_kind_from_native(pointer_kind),
        ),
      )
    3 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::PointerLeft(
          pointer_device_id,
          Some(position),
          true,
          pointer_kind_from_native(pointer_kind),
        ),
      )
    4 =>
      match element_state_from_native(state) {
        Some(state) =>
          app_state_queue_window_callback(
            window_id,
            @core.WindowEvent::PointerButton(
              pointer_device_id,
              state,
              position,
              true,
              button_source_from_native(button),
            ),
          )
        None => ()
      }
    5 =>
      match scroll_delta_from_native(scroll_delta_kind, delta_x, delta_y) {
        Some(delta) => {
          let phase = scroll_phase_from_native(phase)
          app_state_queue_window_callback(
            window_id,
            @core.WindowEvent::MouseWheel(pointer_device_id, delta, phase),
          )
        }
        None => ()
      }
    6 => {
      let state = modifiers_state_from_native(modifiers)
      let pressed_modifiers = normalize_pressed_modifier_keys(
        state,
        view_pressed_modifiers(raw_id),
      )
      view_set_pressed_modifiers(raw_id, pressed_modifiers)
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::ModifiersChanged(
          @core.Modifiers::from_state(state, pressed_modifiers),
        ),
      )
    }
    7 =>
      match element_state_from_native(state) {
        Some(state) => {
          let pressed_modifiers = view_pressed_modifiers(raw_id)
          let modifiers = modifiers_from_native(modifiers, pressed_modifiers)
          let key_event = create_key_event(
            scancode,
            state,
            repeat != 0,
            modifiers,
            optional_text_from_native(text_with_all_modifiers),
            optional_text_from_native(text_ignoring_modifiers),
            optional_text_from_native(text_without_modifiers),
          )
          view_set_pressed_modifiers(
            raw_id,
            update_pressed_modifier_keys(
              modifiers.state(),
              pressed_modifiers,
              key_event.physical_key(),
              state,
            ),
          )
          app_state_queue_window_callback(
            window_id,
            @core.WindowEvent::KeyboardInput(
              keyboard_device_id, key_event, false,
            ),
          )
        }
        None => ()
      }
    8 =>
      match
        ime_from_native_payload(
          ime_kind, ime_text, ime_cursor_start, ime_cursor_end,
        ) {
        Some(ime) =>
          app_state_queue_window_callback(
            window_id,
            @core.WindowEvent::Ime(ime),
          )
        None => ()
      }
    9 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::DragEntered(drag_paths_from_native(path), position),
      )
    10 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::DragMoved(position),
      )
    11 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::DragDropped(drag_paths_from_native(path), position),
      )
    12 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::DragLeft(
          if state != 0 {
            Some(position)
          } else {
            None
          },
        ),
      )
    13 =>
      match touch_phase_from_native(phase) {
        Some(phase) =>
          app_state_queue_window_callback(
            window_id,
            @core.WindowEvent::PinchGesture(pointer_device_id, delta_x, phase),
          )
        None => ()
      }
    14 =>
      match touch_phase_from_native(phase) {
        Some(phase) =>
          app_state_queue_window_callback(
            window_id,
            @core.WindowEvent::PanGesture(
              pointer_device_id,
              @dpi.PhysicalPositionF64::new(delta_x, delta_y),
              phase,
            ),
          )
        None => ()
      }
    15 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::DoubleTapGesture(pointer_device_id),
      )
    16 =>
      match touch_phase_from_native(phase) {
        Some(phase) =>
          app_state_queue_window_callback(
            window_id,
            @core.WindowEvent::RotationGesture(
              pointer_device_id, delta_x, phase,
            ),
          )
        None => ()
      }
    17 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::TouchpadPressure(pointer_device_id, delta_x, state),
      )
    18 => queue_view_standard_key_binding(window_id, text_from_native(ime_text))
    19 =>
      app_state_queue_window_callback(
        window_id,
        @core.WindowEvent::RedrawRequested,
      )
    100 => app_state_queue_device_event(1, button, delta_x, delta_y)
    101 => app_state_queue_device_event(2, button, 0.0, 0.0)
    102 => app_state_queue_device_event(3, button, 0.0, 0.0)
    _ => ()
  }
}

///|
fn native_modifiers_from_modifier_flags(modifier_flags : Int) -> Int {
  let mut modifiers = 0
  if (modifier_flags & 131_072) != 0 {
    modifiers = modifiers | 1
  }
  if (modifier_flags & 262_144) != 0 {
    modifiers = modifiers | 2
  }
  if (modifier_flags & 524_288) != 0 {
    modifiers = modifiers | 4
  }
  if (modifier_flags & 1_048_576) != 0 {
    modifiers = modifiers | 8
  }
  modifiers
}

///|
fn option_as_alt_for_window(raw_id : Int) -> Int {
  match app_state_window_handle(raw_id) {
    Some(window_handle) => {
      let content_view = native_window_content_view_objc_handle(window_handle)
      if content_view == (0 : Int).to_uint64() {
        0
      } else {
        appkit_objc_msg_send_u64(
          content_view,
          objc_runtime_selector_handle("optionAsAlt"),
        ).to_int()
      }
    }
    None => 0
  }
}

///|
fn pointer_button_state_from_event_type(event_type : Int) -> Int {
  match event_type {
    // NSEventTypeLeftMouseDown | RightMouseDown | OtherMouseDown.
    1 | 3 | 25 => 1
    // NSEventTypeLeftMouseUp | RightMouseUp | OtherMouseUp.
    2 | 4 | 26 => 2
    _ => 0
  }
}

///|
fn flags_changed_state_from_scancode_and_flags(
  scancode : Int,
  modifier_flags : Int,
) -> Int {
  let pressed = match scancode {
    // Shift.
    56 | 60 => (modifier_flags & 131_072) != 0
    // Control.
    59 | 62 => (modifier_flags & 262_144) != 0
    // Option.
    58 | 61 => (modifier_flags & 524_288) != 0
    // Command.
    55 | 54 => (modifier_flags & 1_048_576) != 0
    // CapsLock.
    57 => (modifier_flags & 65_536) != 0
    // Function.
    63 => (modifier_flags & 8_388_608) != 0
    _ => return 0
  }
  if pressed {
    1
  } else {
    2
  }
}

///|
fn keyboard_state_from_event_type(
  event_type : Int,
  scancode : Int,
  modifier_flags : Int,
) -> Int {
  match event_type {
    // NSEventTypeKeyDown.
    10 => 1
    // NSEventTypeKeyUp.
    11 => 2
    // NSEventTypeFlagsChanged.
    12 => flags_changed_state_from_scancode_and_flags(scancode, modifier_flags)
    _ => 0
  }
}

///|
fn nsevent_phase_to_native(phase : Int) -> Int {
  match phase {
    // NSEventPhaseMayBegin | NSEventPhaseBegan.
    32 | 1 => 1
    // NSEventPhaseChanged.
    4 => 2
    // NSEventPhaseEnded.
    8 => 3
    // NSEventPhaseCancelled.
    16 => 4
    _ => 0
  }
}

///|
fn drag_paths_from_native_path_list(path_list_handle : UInt64) -> Array[String] {
  if path_list_handle == (0 : Int).to_uint64() {
    return []
  }
  let count = appkit_objc_msg_send_u64(
    path_list_handle,
    objc_runtime_selector_handle("count"),
  ).to_int()
  if count <= 0 {
    return []
  }
  let paths : Array[String] = []
  let mut index = 0
  while index < count {
    let path_object = appkit_objc_msg_send_u64_u64(
      path_list_handle,
      objc_runtime_selector_handle("objectAtIndex:"),
      index.to_uint64(),
    )
    if path_object != (0 : Int).to_uint64() {
      let path = text_from_native(objc_utf8_bytes_from_object(path_object))
      if path.length() > 0 {
        paths.push(path)
      }
    }
    index = index + 1
  }
  paths
}

///|
fn queue_native_input_event(
  raw_id : Int,
  kind : Int,
  event_handle : UInt64,
) -> Unit {
  let empty_text = @utf8.encode(""[:], bom=false)
  let event_type = if event_handle == (0 : Int).to_uint64() {
    0
  } else {
    appkit_objc_msg_send_i64(event_handle, objc_runtime_selector_handle("type")).to_int()
  }
  let modifier_flags = if event_handle == (0 : Int).to_uint64() {
    0
  } else {
    appkit_objc_msg_send_i64(
      event_handle,
      objc_runtime_selector_handle("modifierFlags"),
    ).to_int()
  }
  let modifiers = native_modifiers_from_modifier_flags(modifier_flags)
  let x = if event_handle == (0 : Int).to_uint64() {
    0.0
  } else {
    appkit_objc_msg_send_point_x(
      event_handle,
      objc_runtime_selector_handle("locationInWindow"),
    )
  }
  let y = if event_handle == (0 : Int).to_uint64() {
    0.0
  } else {
    appkit_objc_msg_send_point_y(
      event_handle,
      objc_runtime_selector_handle("locationInWindow"),
    )
  }
  let mut state = 0
  let mut button = 0
  let mut scancode = 0
  let mut repeat = 0
  let mut pointer_source = 0
  let mut pointer_kind = 0
  let mut scroll_delta_kind = 0
  let mut delta_x = 0.0
  let mut delta_y = 0.0
  let mut phase = 0
  let mut text_with_all_modifiers = empty_text
  let mut text_ignoring_modifiers = empty_text
  let mut text_without_modifiers = empty_text
  match kind {
    1 => {
      pointer_source = 1
      pointer_kind = 1
    }
    2 => {
      pointer_source = 1
      pointer_kind = 1
    }
    3 => {
      pointer_source = 1
      pointer_kind = 1
    }
    4 => {
      pointer_source = 1
      pointer_kind = 1
      state = pointer_button_state_from_event_type(event_type)
      button = if event_handle == (0 : Int).to_uint64() {
        0
      } else {
        appkit_objc_msg_send_i64(
          event_handle,
          objc_runtime_selector_handle("buttonNumber"),
        ).to_int()
      }
    }
    5 => {
      pointer_source = 1
      pointer_kind = 1
      if event_handle != (0 : Int).to_uint64() {
        scroll_delta_kind = if appkit_objc_msg_send_bool(
            event_handle,
            objc_runtime_selector_handle("hasPreciseScrollingDeltas"),
          ) {
          2
        } else {
          1
        }
        delta_x = appkit_objc_msg_send_double(
          event_handle,
          objc_runtime_selector_handle("scrollingDeltaX"),
        )
        delta_y = appkit_objc_msg_send_double(
          event_handle,
          objc_runtime_selector_handle("scrollingDeltaY"),
        )
        let momentum_phase = nsevent_phase_to_native(
          appkit_objc_msg_send_i64(
            event_handle,
            objc_runtime_selector_handle("momentumPhase"),
          ).to_int(),
        )
        if momentum_phase != 0 {
          phase = momentum_phase
        } else {
          let event_phase = nsevent_phase_to_native(
            appkit_objc_msg_send_i64(
              event_handle,
              objc_runtime_selector_handle("phase"),
            ).to_int(),
          )
          phase = if event_phase != 0 { event_phase } else { 2 }
        }
      }
    }
    6 => ()
    7 => {
      if event_handle != (0 : Int).to_uint64() {
        scancode = appkit_objc_msg_send_i64(
          event_handle,
          objc_runtime_selector_handle("keyCode"),
        ).to_int()
      }
      state = keyboard_state_from_event_type(
        event_type, scancode, modifier_flags,
      )
      repeat = if event_type == 10 &&
        event_handle != (0 : Int).to_uint64() &&
        appkit_objc_msg_send_bool(
          event_handle,
          objc_runtime_selector_handle("isARepeat"),
        ) {
        1
      } else {
        0
      }
      if (event_type == 10 || event_type == 11) &&
        event_handle != (0 : Int).to_uint64() {
        let characters = objc_utf8_bytes_from_object(
          appkit_objc_msg_send_u64(
            event_handle,
            objc_runtime_selector_handle("characters"),
          ),
        )
        let characters_ignoring_modifiers = objc_utf8_bytes_from_object(
          appkit_objc_msg_send_u64(
            event_handle,
            objc_runtime_selector_handle("charactersIgnoringModifiers"),
          ),
        )
        text_with_all_modifiers = characters
        text_ignoring_modifiers = characters_ignoring_modifiers
        text_without_modifiers = characters_ignoring_modifiers
        let left_alt_pressed = (modifier_flags & 0x20) != 0
        let right_alt_pressed = (modifier_flags & 0x40) != 0
        let alt_pressed = left_alt_pressed || right_alt_pressed
        let control_pressed = (modifier_flags & 262_144) != 0
        let meta_pressed = (modifier_flags & 1_048_576) != 0
        if !control_pressed && !meta_pressed {
          let option_as_alt = option_as_alt_for_window(raw_id)
          if (option_as_alt == 1 && left_alt_pressed) ||
            (option_as_alt == 2 && right_alt_pressed) ||
            (option_as_alt == 3 && alt_pressed) {
            text_with_all_modifiers = characters_ignoring_modifiers
          }
        }
      }
    }
    13 => {
      pointer_source = 1
      pointer_kind = 1
      if event_handle != (0 : Int).to_uint64() {
        delta_x = appkit_objc_msg_send_double(
          event_handle,
          objc_runtime_selector_handle("magnification"),
        )
        phase = nsevent_phase_to_native(
          appkit_objc_msg_send_i64(
            event_handle,
            objc_runtime_selector_handle("phase"),
          ).to_int(),
        )
      }
    }
    14 => {
      pointer_source = 1
      pointer_kind = 1
      if event_handle != (0 : Int).to_uint64() {
        delta_x = appkit_objc_msg_send_double(
          event_handle,
          objc_runtime_selector_handle("deltaX"),
        )
        delta_y = appkit_objc_msg_send_double(
          event_handle,
          objc_runtime_selector_handle("deltaY"),
        )
        phase = nsevent_phase_to_native(
          appkit_objc_msg_send_i64(
            event_handle,
            objc_runtime_selector_handle("phase"),
          ).to_int(),
        )
        if phase == 0 {
          phase = 2
        }
      }
    }
    15 => {
      pointer_source = 1
      pointer_kind = 1
    }
    16 => {
      pointer_source = 1
      pointer_kind = 1
      if event_handle != (0 : Int).to_uint64() {
        delta_x = appkit_objc_msg_send_double(
          event_handle,
          objc_runtime_selector_handle("rotation"),
        )
        phase = nsevent_phase_to_native(
          appkit_objc_msg_send_i64(
            event_handle,
            objc_runtime_selector_handle("phase"),
          ).to_int(),
        )
      }
    }
    17 => {
      pointer_source = 1
      pointer_kind = 1
      if event_handle != (0 : Int).to_uint64() {
        state = appkit_objc_msg_send_i64(
          event_handle,
          objc_runtime_selector_handle("stage"),
        ).to_int()
        delta_x = appkit_objc_msg_send_double(
          event_handle,
          objc_runtime_selector_handle("pressure"),
        )
      }
    }
    19 => ()
    _ => ()
  }
  if kind == 6 {
    state = 0
  }
  if kind == 7 && state == 0 {
    repeat = 0
  }
  queue_input_event(
    raw_id, kind, x, y, state, button, modifiers, scancode, repeat, pointer_source,
    pointer_kind, scroll_delta_kind, delta_x, delta_y, phase, text_with_all_modifiers,
    text_ignoring_modifiers, text_without_modifiers, 0, empty_text, -1, -1, empty_text,
  )
}

///|
fn queue_native_text_input_event(
  raw_id : Int,
  kind : Int,
  x : Double,
  y : Double,
  state : Int,
  text_handle : UInt64,
  cursor_start : Int,
  cursor_end : Int,
  path_handle : UInt64,
) -> Unit {
  let empty_text = @utf8.encode(""[:], bom=false)
  let text = if text_handle == (0 : Int).to_uint64() {
    empty_text
  } else {
    objc_utf8_bytes_from_object(text_handle)
  }
  let window_id = @core.WindowId::from_raw(raw_id)
  let position = @dpi.PhysicalPositionF64::new(x, y)
  match kind {
    8 =>
      queue_input_event(
        raw_id, 8, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0, empty_text, empty_text,
        empty_text, state, text, cursor_start, cursor_end, empty_text,
      )
    9 => {
      let paths = drag_paths_from_native_path_list(path_handle)
      if paths.length() > 0 {
        app_state_queue_window_callback(
          window_id,
          @core.WindowEvent::DragEntered(paths, position),
        )
      }
    }
    11 => {
      let paths = drag_paths_from_native_path_list(path_handle)
      if paths.length() > 0 {
        app_state_queue_window_callback(
          window_id,
          @core.WindowEvent::DragDropped(paths, position),
        )
      }
    }
    10 | 12 =>
      queue_input_event(
        raw_id, kind, x, y, state, 0, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0, empty_text,
        empty_text, empty_text, 0, empty_text, -1, -1, empty_text,
      )
    18 =>
      queue_input_event(
        raw_id, 18, 0.0, 0.0, 0, 0, 0, 0, 0, 0, 0, 0, 0.0, 0.0, 0, empty_text, empty_text,
        empty_text, 0, text, -1, -1, empty_text,
      )
    _ => ()
  }
}

///|
fn initial_fullscreen_state(
  attributes : @core.WindowAttributes,
) -> @core.Fullscreen? {
  attributes.fullscreen()
}

///|
fn modifiers_state_from_native(modifiers : Int) -> @core.ModifiersState {
  let mut state = @core.ModifiersState::none()
  if (modifiers & 1) != 0 {
    state = state.union(@core.ModifiersState::shift())
  }
  if (modifiers & 2) != 0 {
    state = state.union(@core.ModifiersState::control())
  }
  if (modifiers & 4) != 0 {
    state = state.union(@core.ModifiersState::alt())
  }
  if (modifiers & 8) != 0 {
    state = state.union(@core.ModifiersState::meta())
  }
  state
}

///|
fn modifiers_from_native(
  modifiers : Int,
  pressed_mods : @core.ModifiersKeys,
) -> @core.Modifiers {
  @core.Modifiers::from_state(
    modifiers_state_from_native(modifiers),
    pressed_mods,
  )
}

///|
fn modifier_keys_from_physical_key(
  physical_key : @core.PhysicalKey,
) -> @core.ModifiersKeys? {
  match physical_key {
    @core.PhysicalKey::Code(@core.KeyCode::ShiftLeft) =>
      Some(@core.ModifiersKeys::lshift())
    @core.PhysicalKey::Code(@core.KeyCode::ShiftRight) =>
      Some(@core.ModifiersKeys::rshift())
    @core.PhysicalKey::Code(@core.KeyCode::ControlLeft) =>
      Some(@core.ModifiersKeys::lcontrol())
    @core.PhysicalKey::Code(@core.KeyCode::ControlRight) =>
      Some(@core.ModifiersKeys::rcontrol())
    @core.PhysicalKey::Code(@core.KeyCode::AltLeft) =>
      Some(@core.ModifiersKeys::lalt())
    @core.PhysicalKey::Code(@core.KeyCode::AltRight) =>
      Some(@core.ModifiersKeys::ralt())
    @core.PhysicalKey::Code(@core.KeyCode::MetaLeft) =>
      Some(@core.ModifiersKeys::lmeta())
    @core.PhysicalKey::Code(@core.KeyCode::MetaRight) =>
      Some(@core.ModifiersKeys::rmeta())
    _ => None
  }
}

///|
fn update_pressed_modifier_keys(
  state : @core.ModifiersState,
  pressed_mods : @core.ModifiersKeys,
  physical_key : @core.PhysicalKey,
  element_state : @core.ElementState,
) -> @core.ModifiersKeys {
  let updated = match modifier_keys_from_physical_key(physical_key) {
    Some(modifier_key) =>
      match element_state {
        @core.ElementState::Pressed => pressed_mods.union(modifier_key)
        @core.ElementState::Released => pressed_mods.without(modifier_key)
      }
    None => pressed_mods
  }
  normalize_pressed_modifier_keys(state, updated)
}

///|
fn normalize_pressed_modifier_keys(
  state : @core.ModifiersState,
  pressed_mods : @core.ModifiersKeys,
) -> @core.ModifiersKeys {
  @core.Modifiers::from_state(state, pressed_mods).pressed_mods()
}
