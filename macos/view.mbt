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
let view_ime_state_disabled = 0

///|
let view_ime_state_ground = 1

///|
let view_ime_state_preedit = 2

///|
let view_ime_state_committed = 3

///|
let native_view_state_query_ime_allowed = 1

///|
let native_view_state_query_marked_text_length = 2

///|
let native_view_state_query_selected_range_location = 3

///|
let native_view_state_query_selected_range_length = 4

///|
let native_view_state_query_ime_cursor_x = 5

///|
let native_view_state_query_ime_cursor_y = 6

///|
let native_view_state_query_ime_cursor_width = 7

///|
let native_view_state_query_ime_cursor_height = 8

///|
let native_view_state_query_accepts_first_mouse = 9

///|
let native_sync_query_drag_accept = 100

///|
let view_ime_window_ids : Ref[Array[Int]] = Ref::new([])

///|
let view_ime_states : Ref[Array[Int]] = Ref::new([])

///|
let view_ime_old_states : Ref[Array[Int]] = Ref::new([])

///|
let view_ime_forward_key_to_apps : Ref[Array[Bool]] = Ref::new([])

///|
let view_ime_input_sources : Ref[Array[String]] = Ref::new([])

///|
let view_ime_has_marked_texts : Ref[Array[Bool]] = Ref::new([])

///|
let view_ime_marked_text_lengths : Ref[Array[Int]] = Ref::new([])

///|
let view_ime_selected_range_locations : Ref[Array[Int]] = Ref::new([])

///|
let view_ime_selected_range_lengths : Ref[Array[Int]] = Ref::new([])

///|
fn view_ime_index(raw_id : Int) -> Int? {
  view_ime_window_ids.val.search_by(id => id == raw_id)
}

///|
fn view_ime_ensure_index(raw_id : Int) -> Int {
  match view_ime_index(raw_id) {
    Some(index) => index
    None => {
      view_ime_window_ids.val.push(raw_id)
      view_ime_states.val.push(view_ime_state_disabled)
      view_ime_old_states.val.push(view_ime_state_disabled)
      view_ime_forward_key_to_apps.val.push(false)
      view_ime_input_sources.val.push("")
      view_ime_has_marked_texts.val.push(false)
      view_ime_marked_text_lengths.val.push(0)
      view_ime_selected_range_locations.val.push(-1)
      view_ime_selected_range_lengths.val.push(0)
      view_ime_window_ids.val.length() - 1
    }
  }
}

///|
fn view_ime_state(raw_id : Int) -> Int {
  match view_ime_index(raw_id) {
    Some(index) => view_ime_states.val[index]
    None => view_ime_state_disabled
  }
}

///|
fn view_set_ime_state(raw_id : Int, state : Int) -> Unit {
  let index = view_ime_ensure_index(raw_id)
  view_ime_states.val[index] = state
}

///|
fn view_ime_old_state(raw_id : Int) -> Int {
  match view_ime_index(raw_id) {
    Some(index) => view_ime_old_states.val[index]
    None => view_ime_state_disabled
  }
}

///|
fn view_set_ime_old_state(raw_id : Int, state : Int) -> Unit {
  let index = view_ime_ensure_index(raw_id)
  view_ime_old_states.val[index] = state
}

///|
fn view_ime_forward_key_to_app(raw_id : Int) -> Bool {
  match view_ime_index(raw_id) {
    Some(index) => view_ime_forward_key_to_apps.val[index]
    None => false
  }
}

///|
fn view_set_ime_forward_key_to_app(raw_id : Int, forward : Bool) -> Unit {
  let index = view_ime_ensure_index(raw_id)
  view_ime_forward_key_to_apps.val[index] = forward
}

///|
fn view_ime_input_source(raw_id : Int) -> String {
  match view_ime_index(raw_id) {
    Some(index) => view_ime_input_sources.val[index]
    None => ""
  }
}

///|
fn view_set_ime_input_source(raw_id : Int, input_source : String) -> Unit {
  let index = view_ime_ensure_index(raw_id)
  view_ime_input_sources.val[index] = input_source
}

///|
fn view_has_marked_text(raw_id : Int) -> Bool {
  match view_ime_index(raw_id) {
    Some(index) => view_ime_has_marked_texts.val[index]
    None => false
  }
}

///|
fn view_set_has_marked_text(raw_id : Int, has_marked_text : Bool) -> Unit {
  let index = view_ime_ensure_index(raw_id)
  view_ime_has_marked_texts.val[index] = has_marked_text
}

///|
fn view_marked_text_length(raw_id : Int) -> Int {
  match view_ime_index(raw_id) {
    Some(index) => view_ime_marked_text_lengths.val[index]
    None => 0
  }
}

///|
fn view_set_marked_text_length(raw_id : Int, length : Int) -> Unit {
  let index = view_ime_ensure_index(raw_id)
  view_ime_marked_text_lengths.val[index] = clamp_non_negative(length)
}

///|
fn view_selected_range_location(raw_id : Int) -> Int {
  match view_ime_index(raw_id) {
    Some(index) => view_ime_selected_range_locations.val[index]
    None => -1
  }
}

///|
fn view_selected_range_length(raw_id : Int) -> Int {
  match view_ime_index(raw_id) {
    Some(index) => view_ime_selected_range_lengths.val[index]
    None => 0
  }
}

///|
fn view_set_selected_range(raw_id : Int, location : Int, length : Int) -> Unit {
  let index = view_ime_ensure_index(raw_id)
  if location < 0 {
    view_ime_selected_range_locations.val[index] = -1
    view_ime_selected_range_lengths.val[index] = 0
  } else {
    view_ime_selected_range_locations.val[index] = location
    view_ime_selected_range_lengths.val[index] = clamp_non_negative(length)
  }
}

///|
fn view_content_view_handle(raw_id : Int) -> UInt64 {
  match app_state_window_handle(raw_id) {
    Some(window_handle) => native_window_content_view_objc_handle(window_handle)
    None => (0 : Int).to_uint64()
  }
}

///|
fn view_window_scale_factor(raw_id : Int) -> Double {
  match app_state_window_handle(raw_id) {
    Some(window_handle) => native_window_scale_factor(window_handle)
    None => 1.0
  }
}

///|
fn view_event_pointer_position(
  raw_id : Int,
  event_handle : UInt64,
) -> @dpi.PhysicalPositionF64 {
  if event_handle == (0 : Int).to_uint64() {
    return @dpi.PhysicalPositionF64::new(0.0, 0.0)
  }
  let window_x = appkit_objc_msg_send_point_x(
    event_handle,
    objc_runtime_selector_handle("locationInWindow"),
  )
  let window_y = appkit_objc_msg_send_point_y(
    event_handle,
    objc_runtime_selector_handle("locationInWindow"),
  )
  let content_view = view_content_view_handle(raw_id)
  let logical_x = if content_view == (0 : Int).to_uint64() {
    window_x
  } else {
    appkit_objc_msg_send_point_x_point_u64(
      content_view,
      objc_runtime_selector_handle("convertPoint:fromView:"),
      window_x,
      window_y,
      (0 : Int).to_uint64(),
    )
  }
  let logical_y = if content_view == (0 : Int).to_uint64() {
    window_y
  } else {
    appkit_objc_msg_send_point_y_point_u64(
      content_view,
      objc_runtime_selector_handle("convertPoint:fromView:"),
      window_x,
      window_y,
      (0 : Int).to_uint64(),
    )
  }
  let scale_factor = view_window_scale_factor(raw_id)
  @dpi.PhysicalPositionF64::new(
    logical_x * scale_factor,
    logical_y * scale_factor,
  )
}

///|
fn view_ime_allowed(raw_id : Int) -> Bool {
  match app_state_window_handle(raw_id) {
    Some(window_handle) => window_ime_allowed(window_handle)
    None => false
  }
}

///|
fn view_clear_marked_text(raw_id : Int) -> Unit {
  view_set_has_marked_text(raw_id, false)
  view_set_marked_text_length(raw_id, 0)
  view_set_selected_range(raw_id, -1, 0)
}

///|
fn view_native_query_state(raw_id : Int, kind : Int) -> Int {
  match kind {
    _ if kind == native_view_state_query_ime_allowed =>
      if view_ime_allowed(raw_id) {
        1
      } else {
        0
      }
    _ if kind == native_view_state_query_marked_text_length =>
      view_marked_text_length(raw_id)
    _ if kind == native_view_state_query_selected_range_location =>
      view_selected_range_location(raw_id)
    _ if kind == native_view_state_query_selected_range_length =>
      view_selected_range_length(raw_id)
    _ =>
      match app_state_window_handle(raw_id) {
        Some(window_handle) =>
          match kind {
            _ if kind == native_view_state_query_ime_cursor_x =>
              window_ime_cursor_x(window_handle)
            _ if kind == native_view_state_query_ime_cursor_y =>
              window_ime_cursor_y(window_handle)
            _ if kind == native_view_state_query_ime_cursor_width =>
              window_ime_cursor_width(window_handle)
            _ if kind == native_view_state_query_ime_cursor_height =>
              window_ime_cursor_height(window_handle)
            _ if kind == native_view_state_query_accepts_first_mouse =>
              if window_accepts_first_mouse_state(window_handle) {
                1
              } else {
                0
              }
            _ => 0
          }
        None =>
          match kind {
            _ if kind == native_view_state_query_ime_cursor_width => 1
            _ if kind == native_view_state_query_ime_cursor_height => 1
            _ => 0
          }
      }
  }
}

///|
fn view_current_input_source(raw_id : Int) -> String {
  let content_view = view_content_view_handle(raw_id)
  if content_view == (0 : Int).to_uint64() {
    return ""
  }
  let input_context = appkit_objc_msg_send_u64(
    content_view,
    objc_runtime_selector_handle("inputContext"),
  )
  if input_context == (0 : Int).to_uint64() {
    return ""
  }
  let input_source = appkit_objc_msg_send_u64(
    input_context,
    objc_runtime_selector_handle("selectedKeyboardInputSource"),
  )
  if input_source == (0 : Int).to_uint64() {
    return ""
  }
  let description = appkit_objc_msg_send_u64(
    input_source,
    objc_runtime_selector_handle("description"),
  )
  text_from_native(
    objc_utf8_bytes_from_object(
      if description == (0 : Int).to_uint64() {
        input_source
      } else {
        description
      },
    ),
  )
}

///|
fn view_utf8_offset_for_utf16_index(text_handle : UInt64, index : Int) -> Int {
  if text_handle == (0 : Int).to_uint64() || index < 0 {
    return -1
  }
  let length = appkit_objc_msg_send_i64(
    text_handle,
    objc_runtime_selector_handle("length"),
  ).to_int()
  if length < 0 {
    return -1
  }
  let clamped = if index <= length { index } else { length }
  let prefix = appkit_objc_msg_send_u64_u64(
    text_handle,
    objc_runtime_selector_handle("substringToIndex:"),
    clamped.to_uint64(),
  )
  if prefix == (0 : Int).to_uint64() {
    -1
  } else {
    objc_utf8_bytes_from_object(prefix).length()
  }
}

///|
fn view_utf16_length(text_handle : UInt64) -> Int {
  if text_handle == (0 : Int).to_uint64() {
    return 0
  }
  clamp_non_negative(
    appkit_objc_msg_send_i64(
      text_handle,
      objc_runtime_selector_handle("length"),
    ).to_int(),
  )
}

///|
fn view_text_object_string_handle(text_object_handle : UInt64) -> UInt64 {
  if text_object_handle == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let nsstring_class = objc_runtime_class_handle("NSString")
  if nsstring_class != (0 : Int).to_uint64() &&
    appkit_objc_msg_send_bool_u64(
      text_object_handle,
      objc_runtime_selector_handle("isKindOfClass:"),
      nsstring_class,
    ) {
    return text_object_handle
  }
  let attributed_string_class = objc_runtime_class_handle("NSAttributedString")
  if attributed_string_class != (0 : Int).to_uint64() &&
    appkit_objc_msg_send_bool_u64(
      text_object_handle,
      objc_runtime_selector_handle("isKindOfClass:"),
      attributed_string_class,
    ) {
    return appkit_objc_msg_send_u64(
      text_object_handle,
      objc_runtime_selector_handle("string"),
    )
  }
  if appkit_objc_msg_send_bool_u64(
      text_object_handle,
      objc_runtime_selector_handle("respondsToSelector:"),
      objc_runtime_selector_handle("description"),
    ) {
    return appkit_objc_msg_send_u64(
      text_object_handle,
      objc_runtime_selector_handle("description"),
    )
  }
  (0 : Int).to_uint64()
}

///|
fn view_string_is_control(text_handle : UInt64) -> Bool {
  let string_handle = view_text_object_string_handle(text_handle)
  if string_handle == (0 : Int).to_uint64() {
    return false
  }
  let length = appkit_objc_msg_send_i64(
    string_handle,
    objc_runtime_selector_handle("length"),
  ).to_int()
  if length <= 0 {
    return false
  }
  let char0 = appkit_objc_msg_send_u64_u64(
    string_handle,
    objc_runtime_selector_handle("characterAtIndex:"),
    (0 : Int).to_uint64(),
  ).to_int()
  char0 < 32 || char0 == 127
}

///|
fn view_queue_ime_event(raw_id : Int, ime : @core.Ime) -> Unit {
  app_state_queue_window_callback(
    @core.WindowId::from_raw(raw_id),
    @core.WindowEvent::Ime(ime),
  )
}

///|
fn text_from_cstr_handle(cstr_handle : UInt64) -> String {
  if cstr_handle == (0 : Int).to_uint64() {
    ""
  } else {
    text_from_native(native_copy_utf8_cstr_bytes(cstr_handle))
  }
}

///|
fn view_disable_ime(raw_id : Int) -> Unit {
  view_clear_marked_text(raw_id)
  if view_ime_state(raw_id) != view_ime_state_disabled {
    view_set_ime_state(raw_id, view_ime_state_disabled)
    view_queue_ime_event(raw_id, @core.Ime::Disabled)
  }
}

///|
fn view_ime_allows_key_up(raw_id : Int) -> Bool {
  let state = view_ime_state(raw_id)
  state == view_ime_state_disabled || state == view_ime_state_ground
}

///|
fn view_clear_ime_state(raw_id : Int) -> Unit {
  match view_ime_index(raw_id) {
    Some(index) => {
      ignore(view_ime_window_ids.val.remove(index))
      ignore(view_ime_states.val.remove(index))
      ignore(view_ime_old_states.val.remove(index))
      ignore(view_ime_forward_key_to_apps.val.remove(index))
      ignore(view_ime_input_sources.val.remove(index))
      ignore(view_ime_has_marked_texts.val.remove(index))
      ignore(view_ime_marked_text_lengths.val.remove(index))
      ignore(view_ime_selected_range_locations.val.remove(index))
      ignore(view_ime_selected_range_lengths.val.remove(index))
    }
    None => ()
  }
}

///|
fn queue_pointer_motion_event(raw_id : Int, x : Double, y : Double) -> Unit {
  let empty_text = @utf8.encode(""[:], bom=false)
  queue_input_event(
    raw_id, 1, x, y, 0, 0, 0, 0, 0, 1, 1, 0, 0.0, 0.0, 0, empty_text, empty_text,
    empty_text, 0, empty_text, -1, -1, empty_text,
  )
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
    9 | 10 | 11 | 12 =>
      queue_drag_event_from_payload(raw_id, kind, position, path, state != 0)
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
    Some(window_handle) => window_option_as_alt_native(window_handle)
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
fn queue_native_input_event(
  raw_id : Int,
  kind : Int,
  event_handle : UInt64,
) -> Unit {
  let empty_text = @utf8.encode(""[:], bom=false)
  let window_id = @core.WindowId::from_raw(raw_id)
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
  let position = view_event_pointer_position(raw_id, event_handle)
  let x = position.x()
  let y = position.y()
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
      queue_pointer_motion_event(raw_id, x, y)
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
      queue_pointer_motion_event(raw_id, x, y)
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
      if event_type == 12 {
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
      if event_type == 11 && !view_ime_allows_key_up(raw_id) {
        return ()
      }
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
      queue_pointer_motion_event(raw_id, x, y)
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
      queue_pointer_motion_event(raw_id, x, y)
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
      queue_pointer_motion_event(raw_id, x, y)
      pointer_source = 1
      pointer_kind = 1
    }
    16 => {
      queue_pointer_motion_event(raw_id, x, y)
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
      queue_pointer_motion_event(raw_id, x, y)
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
  event_handle : UInt64,
  state : Int,
  text_handle : UInt64,
  cursor_start : Int,
  cursor_end : Int,
  path_handle : UInt64,
) -> Unit {
  ignore(cursor_end)
  let text_string_handle = view_text_object_string_handle(text_handle)
  let text_bytes = if text_string_handle == (0 : Int).to_uint64() {
    @utf8.encode(""[:], bom=false)
  } else {
    objc_utf8_bytes_from_object(text_string_handle)
  }
  let text = text_from_native(text_bytes)
  let window_id = @core.WindowId::from_raw(raw_id)
  match kind {
    // keyDown begin
    20 => {
      if view_ime_allowed(raw_id) {
        if view_ime_state(raw_id) != view_ime_state_disabled {
          let current_input_source = view_current_input_source(raw_id)
          if current_input_source != view_ime_input_source(raw_id) {
            view_set_ime_input_source(raw_id, current_input_source)
            view_disable_ime(raw_id)
          }
        } else {
          view_set_ime_input_source(raw_id, view_current_input_source(raw_id))
        }
      }
      view_set_ime_old_state(raw_id, view_ime_state(raw_id))
      view_set_ime_forward_key_to_app(raw_id, false)
    }
    // keyDown end
    21 => {
      let old_ime_state = view_ime_old_state(raw_id)
      let mut had_ime_input = false
      match view_ime_state(raw_id) {
        _ if view_ime_state(raw_id) == view_ime_state_committed => {
          view_set_ime_state(raw_id, view_ime_state_ground)
          view_clear_marked_text(raw_id)
          had_ime_input = true
        }
        _ if view_ime_state(raw_id) == view_ime_state_preedit =>
          had_ime_input = true
        _ => had_ime_input = old_ime_state != view_ime_state(raw_id)
      }
      if !had_ime_input || view_ime_forward_key_to_app(raw_id) {
        queue_native_input_event(raw_id, 7, event_handle)
      }
      view_set_ime_forward_key_to_app(raw_id, false)
    }
    // setMarkedText:selectedRange:replacementRange:
    22 => {
      if !view_ime_allowed(raw_id) {
        return ()
      }
      if view_ime_state(raw_id) == view_ime_state_disabled {
        view_set_ime_input_source(raw_id, view_current_input_source(raw_id))
        view_set_ime_state(raw_id, view_ime_state_ground)
        view_queue_ime_event(raw_id, @core.Ime::Enabled)
      }
      let cursor = if state >= 0 {
        let start = view_utf8_offset_for_utf16_index(text_string_handle, state)
        let utf16_end = state + clamp_non_negative(cursor_start)
        let end = view_utf8_offset_for_utf16_index(
          text_string_handle, utf16_end,
        )
        if start >= 0 && end >= start {
          Some(@core.ImeCursorRange::new(start, end))
        } else {
          None
        }
      } else {
        None
      }
      if text.length() > 0 {
        view_set_ime_state(raw_id, view_ime_state_preedit)
        view_set_has_marked_text(raw_id, true)
        view_set_marked_text_length(
          raw_id,
          view_utf16_length(text_string_handle),
        )
        view_set_selected_range(raw_id, state, cursor_start)
      } else {
        view_set_ime_state(raw_id, view_ime_state_ground)
        view_clear_marked_text(raw_id)
      }
      view_queue_ime_event(raw_id, @core.Ime::Preedit(text, cursor))
    }
    // unmarkText
    23 => {
      if !view_ime_allowed(raw_id) {
        return ()
      }
      view_set_ime_state(raw_id, view_ime_state_ground)
      view_clear_marked_text(raw_id)
      view_queue_ime_event(raw_id, @core.Ime::Preedit("", None))
    }
    // insertText:replacementRange:
    24 => {
      if !view_ime_allowed(raw_id) || text.length() == 0 {
        return ()
      }
      if view_has_marked_text(raw_id) &&
        view_ime_state(raw_id) != view_ime_state_disabled &&
        !view_string_is_control(text_handle) {
        view_queue_ime_event(raw_id, @core.Ime::Preedit("", None))
        view_queue_ime_event(raw_id, @core.Ime::Commit(text))
        view_set_ime_state(raw_id, view_ime_state_committed)
      }
    }
    // doCommandBySelector:
    25 => {
      if view_ime_state(raw_id) == view_ime_state_committed {
        return ()
      }
      view_set_ime_forward_key_to_app(raw_id, true)
      if view_has_marked_text(raw_id) &&
        view_ime_state(raw_id) == view_ime_state_preedit {
        view_set_ime_state(raw_id, view_ime_state_ground)
        view_clear_marked_text(raw_id)
      }
      queue_view_standard_key_binding(
        window_id,
        text_from_cstr_handle(path_handle),
      )
    }
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
