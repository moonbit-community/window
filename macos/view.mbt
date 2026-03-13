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
    queue_standard_key_binding_callback(window_id, action)
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
      queue_window_callback(
        window_id,
        @core.WindowEvent::PointerMoved(
          pointer_device_id,
          position,
          true,
          pointer_source_from_native(pointer_source),
        ),
      )
    2 =>
      queue_window_callback(
        window_id,
        @core.WindowEvent::PointerEntered(
          pointer_device_id,
          position,
          true,
          pointer_kind_from_native(pointer_kind),
        ),
      )
    3 =>
      queue_window_callback(
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
          queue_window_callback(
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
          queue_window_callback(
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
      queue_window_callback(
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
          queue_window_callback(
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
          queue_window_callback(window_id, @core.WindowEvent::Ime(ime))
        None => ()
      }
    9 =>
      queue_window_callback(
        window_id,
        @core.WindowEvent::DragEntered(drag_paths_from_native(path), position),
      )
    10 =>
      queue_window_callback(window_id, @core.WindowEvent::DragMoved(position))
    11 =>
      queue_window_callback(
        window_id,
        @core.WindowEvent::DragDropped(drag_paths_from_native(path), position),
      )
    12 =>
      queue_window_callback(
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
          queue_window_callback(
            window_id,
            @core.WindowEvent::PinchGesture(pointer_device_id, delta_x, phase),
          )
        None => ()
      }
    14 =>
      match touch_phase_from_native(phase) {
        Some(phase) =>
          queue_window_callback(
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
      queue_window_callback(
        window_id,
        @core.WindowEvent::DoubleTapGesture(pointer_device_id),
      )
    16 =>
      match touch_phase_from_native(phase) {
        Some(phase) =>
          queue_window_callback(
            window_id,
            @core.WindowEvent::RotationGesture(
              pointer_device_id, delta_x, phase,
            ),
          )
        None => ()
      }
    17 =>
      queue_window_callback(
        window_id,
        @core.WindowEvent::TouchpadPressure(pointer_device_id, delta_x, state),
      )
    18 => queue_view_standard_key_binding(window_id, text_from_native(ime_text))
    19 => queue_window_callback(window_id, @core.WindowEvent::RedrawRequested)
    100 => native_callback_device_event(1, button, delta_x, delta_y)
    101 => native_callback_device_event(2, button, 0.0, 0.0)
    102 => native_callback_device_event(3, button, 0.0, 0.0)
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

///|
pub fn Window::set_cursor(self : Window, cursor : @core.Cursor) -> Unit {
  match cursor {
    @core.Cursor::Icon(icon) => {
      self.cursor_state = cursor
      set_window_cursor(self.raw_window_handle, cursor_icon_to_native(icon))
    }
    @core.Cursor::Custom(custom_cursor) =>
      if set_window_custom_cursor(
          self.raw_window_handle,
          custom_cursor.into_raw(),
        ) {
        self.cursor_state = cursor
      } else {
        self.cursor_state = @core.Cursor::Icon(@core.CursorIcon::Default)
        set_window_cursor(
          self.raw_window_handle,
          cursor_icon_to_native(@core.CursorIcon::Default),
        )
      }
  }
}

///|
pub fn Window::set_cursor_icon(
  self : Window,
  cursor : @core.CursorIcon,
) -> Unit {
  self.set_cursor(@core.Cursor::Icon(cursor))
}

///|
pub fn Window::set_cursor_visible(self : Window, visible : Bool) -> Unit {
  self.cursor_visible_state = visible
  set_window_cursor_visible(self.raw_window_handle, visible)
}

///|
pub fn Window::set_cursor_hittest(
  self : Window,
  hittest : Bool,
) -> Unit raise @core.RequestError {
  if set_window_cursor_hittest(self.raw_window_handle, hittest) == false {
    raise @core.RequestError::NotSupported
  }
  self.cursor_hittest_state = hittest
}

///|
pub fn Window::set_cursor_position(
  self : Window,
  position : @dpi.Position,
) -> Unit raise @core.RequestError {
  let physical_position = position.to_physical(self.scale_factor())
  if set_cursor_position(
      self.raw_window_handle,
      physical_position.x(),
      physical_position.y(),
    ) ==
    false {
    raise @core.RequestError::NotSupported
  }
}

///|
pub fn Window::set_cursor_grab(
  self : Window,
  mode : @core.CursorGrabMode,
) -> Unit raise @core.RequestError {
  if mode is @core.CursorGrabMode::Confined {
    raise @core.RequestError::NotSupported
  }
  if set_cursor_grab(self.raw_window_handle, cursor_grab_mode_to_native(mode)) ==
    false {
    raise @core.RequestError::NotSupported
  }
}

///|
pub fn Window::drag_window(self : Window) -> Unit raise @core.RequestError {
  if drag_window(self.raw_window_handle) == false {
    raise @core.RequestError::NotSupported
  }
}

///|
pub fn Window::drag_resize_window(
  self : Window,
  direction : @core.ResizeDirection,
) -> Unit raise @core.RequestError {
  if drag_resize_window(
      self.raw_window_handle,
      resize_direction_to_native(direction),
    ) ==
    false {
    raise @core.RequestError::NotSupported
  }
}

///|
pub fn Window::show_window_menu(
  self : Window,
  position : @dpi.Position,
) -> Unit {
  let physical_position = position.to_physical(self.scale_factor())
  let _ = show_window_menu(
    self.raw_window_handle,
    physical_position.x(),
    physical_position.y(),
  )
}

///|
pub fn Window::cursor(self : Window) -> @core.Cursor {
  self.cursor_state
}

///|
pub fn Window::is_cursor_visible(self : Window) -> Bool {
  self.cursor_visible_state
}

///|
pub fn Window::is_cursor_hittest(self : Window) -> Bool {
  self.cursor_hittest_state
}

///|
pub fn Window::set_ime_purpose(
  self : Window,
  purpose : @core.ImePurpose,
) -> Unit {
  match self.ime_capabilities() {
    Some(capabilities) =>
      if capabilities.hint_and_purpose() {
        let _ = self.request_ime_update(
          @core.ImeRequestData::default()
          .with_hint_and_purpose(@core.ImeHint::none(), purpose)
          .into_request(),
        ) catch {
          _ => ()
        }
      }
    None => ()
  }
}

///|
fn Window::set_ime_purpose_raw(
  self : Window,
  purpose : @core.ImePurpose,
) -> Unit {
  self.ime_purpose_state = purpose
  set_ime_purpose(
    self.raw_window_handle,
    normalize_ime_purpose_native(ime_purpose_to_native(purpose)),
  )
}

///|
pub fn Window::set_ime_hints(self : Window, hints : @core.ImeHint) -> Unit {
  self.ime_hints_state = hints
  set_ime_hints(self.raw_window_handle, normalize_ime_hints_bits(hints.bits()))
}

///|
pub fn Window::set_ime_allowed(self : Window, allowed : Bool) -> Unit {
  let request : @core.ImeRequest? = if allowed {
    let capabilities = @core.ImeCapabilities::default()
      .with_hint_and_purpose()
      .with_cursor_area()
    let request_data = @core.ImeRequestData::default()
      .with_hint_and_purpose(@core.ImeHint::none(), @core.ImePurpose::Normal)
      .with_cursor_area(
        @dpi.LogicalPosition::new(0.0, 0.0).into_position(),
        @dpi.LogicalSize::new(0.0, 0.0).into_size(),
      )
    match @core.ImeEnableRequest::new(capabilities, request_data) {
      Some(enable_request) => Some(@core.ImeRequest::Enable(enable_request))
      None => None
    }
  } else {
    Some(@core.ImeRequest::Disable)
  }
  match request {
    Some(request) => {
      let _ = self.request_ime_update(request) catch { _ => () }
      ()
    }
    None => ()
  }
}

///|
fn Window::set_ime_allowed_raw(self : Window, allowed : Bool) -> Unit {
  self.ime_allowed_state = allowed
  if allowed == false {
    self.ime_capabilities_state = None
    self.ime_surrounding_text_state = None
  }
  set_ime_allowed(self.raw_window_handle, allowed)
}

///|
pub fn Window::ime_allowed(self : Window) -> Bool {
  self.ime_allowed_state
}

///|
pub fn Window::set_ime_cursor_area(
  self : Window,
  position : @dpi.Position,
  size : @dpi.Size,
) -> Unit {
  match self.ime_capabilities() {
    Some(capabilities) =>
      if capabilities.cursor_area() {
        let _ = self.request_ime_update(
          @core.ImeRequestData::default()
          .with_cursor_area(position, size)
          .into_request(),
        ) catch {
          _ => ()
        }
      }
    None => ()
  }
}

///|
fn Window::set_ime_cursor_area_raw(
  self : Window,
  position : @dpi.Position,
  size : @dpi.Size,
) -> Unit {
  let scale_factor = self.scale_factor()
  let physical_position = position.to_physical(scale_factor)
  let physical_size = size.to_physical(scale_factor)
  let width = if physical_size.width() > 0 { physical_size.width() } else { 1 }
  let height = if physical_size.height() > 0 {
    physical_size.height()
  } else {
    1
  }
  self.ime_cursor_area_position_state = physical_position
  self.ime_cursor_area_size_state = @dpi.PhysicalSize::new(width, height)
  set_ime_cursor_area(
    self.raw_window_handle,
    physical_position.x(),
    physical_position.y(),
    width,
    height,
  )
}

///|
pub fn Window::set_ime_surrounding_text(
  self : Window,
  surrounding_text : @core.ImeSurroundingText?,
) -> Unit {
  match surrounding_text {
    Some(surrounding_text) =>
      self.ime_surrounding_text_state = Some(surrounding_text)
    None => self.ime_surrounding_text_state = None
  }
}

///|
pub fn Window::ime_cursor_area_position(self : Window) -> @dpi.PhysicalPosition {
  self.ime_cursor_area_position_state
}

///|
pub fn Window::ime_cursor_area_size(self : Window) -> @dpi.PhysicalSize {
  self.ime_cursor_area_size_state
}

///|
pub fn Window::ime_surrounding_text(self : Window) -> @core.ImeSurroundingText? {
  self.ime_surrounding_text_state
}

///|
pub fn Window::ime_purpose(self : Window) -> @core.ImePurpose {
  self.ime_purpose_state
}

///|
pub fn Window::ime_hints(self : Window) -> @core.ImeHint {
  self.ime_hints_state
}

///|
fn Window::apply_ime_request_data(
  self : Window,
  request_data : @core.ImeRequestData,
) -> Unit raise @core.ImeRequestError {
  if self.ime_allowed() == false {
    raise @core.ImeRequestError::NotEnabled
  }
  if request_data.has_hint_and_purpose() {
    if self.ime_supports_hint_and_purpose() {
      match request_data.hint_and_purpose() {
        Some((hints, purpose)) => {
          self.set_ime_hints(hints)
          self.set_ime_purpose_raw(purpose)
        }
        None => ()
      }
    }
  }
  if request_data.has_cursor_area() {
    if self.ime_supports_cursor_area() {
      match request_data.cursor_area() {
        Some((position, size)) => self.set_ime_cursor_area_raw(position, size)
        None => ()
      }
    }
  }
  if request_data.has_surrounding_text() {
    if self.ime_supports_surrounding_text() {
      match request_data.surrounding_text() {
        Some(surrounding_text) =>
          self.set_ime_surrounding_text(Some(surrounding_text))
        None => ()
      }
    }
  }
}

///|
pub fn Window::request_ime_update(
  self : Window,
  request : @core.ImeRequest,
) -> Unit raise @core.ImeRequestError {
  match request {
    @core.ImeRequest::Enable(enable_request) =>
      if self.ime_allowed() {
        raise @core.ImeRequestError::AlreadyEnabled
      } else {
        let capabilities = enable_request.capabilities()
        let request_data = enable_request.request_data()
        self.set_ime_allowed_raw(true)
        self.ime_capabilities_state = Some(capabilities)
        self.apply_ime_request_data(request_data)
      }
    @core.ImeRequest::Update(request_data) =>
      self.apply_ime_request_data(request_data)
    @core.ImeRequest::Disable => {
      self.set_ime_allowed_raw(false)
      ()
    }
  }
}

///|
pub fn Window::ime_capabilities(self : Window) -> @core.ImeCapabilities? {
  self.ime_capabilities_state
}

///|
fn Window::ime_supports_hint_and_purpose(self : Window) -> Bool {
  match self.ime_capabilities_state {
    Some(capabilities) => capabilities.hint_and_purpose()
    None => true
  }
}

///|
fn Window::ime_supports_cursor_area(self : Window) -> Bool {
  match self.ime_capabilities_state {
    Some(capabilities) => capabilities.cursor_area()
    None => true
  }
}

///|
fn Window::ime_supports_surrounding_text(self : Window) -> Bool {
  match self.ime_capabilities_state {
    Some(capabilities) => capabilities.surrounding_text()
    None => true
  }
}
