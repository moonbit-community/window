///|
// Port target: winit-reference/winit-appkit/src/view.rs

///|
fn ime_from_native(window_id : Int) -> @core.Ime? {
  match input_event_ime_kind(window_id) {
    1 => Some(@core.Ime::Enabled)
    2 => {
      let cursor_start = input_event_ime_cursor_start(window_id)
      let cursor_end = input_event_ime_cursor_end(window_id)
      let cursor = if cursor_start >= 0 && cursor_end >= cursor_start {
        Some(@core.ImeCursorRange::new(cursor_start, cursor_end))
      } else {
        None
      }
      Some(
        @core.Ime::Preedit(
          text_from_native(input_event_ime_text(window_id)),
          cursor,
        ),
      )
    }
    3 =>
      Some(@core.Ime::Commit(text_from_native(input_event_ime_text(window_id))))
    4 => Some(@core.Ime::Disabled)
    5 => {
      let before = clamp_non_negative(input_event_ime_cursor_start(window_id))
      let after = clamp_non_negative(input_event_ime_cursor_end(window_id))
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
fn[A : ApplicationHandler] dispatch_view_device_pointer_motion(
  app : A,
  event_loop : ActiveEventLoop,
  device_id : @core.DeviceId?,
  delta_x : Double,
  delta_y : Double,
) -> Unit {
  if delta_x != 0.0 || delta_y != 0.0 {
    app.device_event(
      event_loop,
      device_id,
      @core.DeviceEvent::PointerMotion(delta_x, delta_y),
    )
  }
}

///|
fn[A : ApplicationHandler] dispatch_view_standard_key_binding(
  app : A,
  event_loop : ActiveEventLoop,
  window_id : @core.WindowId,
  action : String,
) -> Unit {
  if action.length() == 0 {
    ()
  } else if app.macos_handler() {
    app.standard_key_binding(event_loop, window_id, action)
  }
}

///|
fn EventLoop::device_events_allowed(self : EventLoop, raw_id : Int) -> Bool {
  let _ = self
  let _ = raw_id
  true
}

///|
fn[A : ApplicationHandler] EventLoop::dispatch_input_events(
  self : EventLoop,
  app : A,
  raw_id : Int,
  window_id : @core.WindowId,
) -> Unit {
  let active = self.as_active()
  while take_input_event(raw_id) {
    let emit_device_events = self.device_events_allowed(raw_id)
    let pointer_device_id = Some(@core.DeviceId::from_raw(1L))
    let keyboard_device_id = Some(@core.DeviceId::from_raw(2L))
    let position = @dpi.PhysicalPositionF64::new(
      input_event_x(raw_id),
      input_event_y(raw_id),
    )
    match input_event_kind(raw_id) {
      1 => {
        app.window_event(
          active,
          window_id,
          @core.WindowEvent::PointerMoved(
            pointer_device_id,
            position,
            true,
            pointer_source_from_native(input_event_pointer_source(raw_id)),
          ),
        )
        if emit_device_events {
          dispatch_view_device_pointer_motion(
            app,
            active,
            pointer_device_id,
            position.x(),
            position.y(),
          )
        }
      }
      2 =>
        app.window_event(
          active,
          window_id,
          @core.WindowEvent::PointerEntered(
            pointer_device_id,
            position,
            true,
            pointer_kind_from_native(input_event_pointer_kind(raw_id)),
          ),
        )
      3 =>
        app.window_event(
          active,
          window_id,
          @core.WindowEvent::PointerLeft(
            pointer_device_id,
            Some(position),
            true,
            pointer_kind_from_native(input_event_pointer_kind(raw_id)),
          ),
        )
      4 =>
        match element_state_from_native(input_event_state(raw_id)) {
          Some(state) => {
            app.window_event(
              active,
              window_id,
              @core.WindowEvent::PointerButton(
                pointer_device_id,
                state,
                position,
                true,
                button_source_from_native(input_event_button(raw_id)),
              ),
            )
            if emit_device_events {
              app.device_event(
                active,
                pointer_device_id,
                @core.DeviceEvent::Button(
                  @core.ButtonId::from_raw(input_event_button(raw_id)),
                  state,
                ),
              )
            }
          }
          None => ()
        }
      5 =>
        match
          scroll_delta_from_native(
            input_event_scroll_delta_kind(raw_id),
            input_event_scroll_delta_x(raw_id),
            input_event_scroll_delta_y(raw_id),
          ) {
          Some(delta) => {
            let phase = scroll_phase_from_native(input_event_phase(raw_id))
            app.window_event(
              active,
              window_id,
              @core.WindowEvent::MouseWheel(pointer_device_id, delta, phase),
            )
            if emit_device_events {
              app.device_event(
                active,
                pointer_device_id,
                @core.DeviceEvent::MouseWheel(delta),
              )
            }
          }
          None => ()
        }
      6 => {
        let state = modifiers_state_from_native(input_event_modifiers(raw_id))
        self.pressed_modifiers_ = normalize_pressed_modifier_keys(
          state,
          self.pressed_modifiers_,
        )
        app.window_event(
          active,
          window_id,
          @core.WindowEvent::ModifiersChanged(
            @core.Modifiers::from_state(state, self.pressed_modifiers_),
          ),
        )
      }
      7 =>
        match element_state_from_native(input_event_state(raw_id)) {
          Some(state) => {
            let modifiers = modifiers_from_native(
              input_event_modifiers(raw_id),
              self.pressed_modifiers_,
            )
            let key_event = create_key_event(
              input_event_scancode(raw_id),
              state,
              input_event_repeat(raw_id),
              modifiers,
              optional_text_from_native(
                input_event_text_with_all_modifiers(raw_id),
              ),
              optional_text_from_native(
                input_event_text_ignoring_modifiers(raw_id),
              ),
              optional_text_from_native(
                input_event_text_without_modifiers(raw_id),
              ),
            )
            self.pressed_modifiers_ = update_pressed_modifier_keys(
              modifiers.state(),
              self.pressed_modifiers_,
              key_event.physical_key(),
              state,
            )
            app.window_event(
              active,
              window_id,
              @core.WindowEvent::KeyboardInput(
                keyboard_device_id, key_event, false,
              ),
            )
            if emit_device_events {
              app.device_event(
                active,
                keyboard_device_id,
                @core.DeviceEvent::Key(
                  @core.RawKeyEvent::new(key_event.physical_key(), state),
                ),
              )
            }
          }
          None => ()
        }
      8 =>
        match ime_from_native(raw_id) {
          Some(ime) =>
            app.window_event(active, window_id, @core.WindowEvent::Ime(ime))
          None => ()
        }
      9 =>
        app.window_event(
          active,
          window_id,
          @core.WindowEvent::DragEntered(
            drag_paths_from_native(input_event_path(raw_id)),
            position,
          ),
        )
      10 =>
        app.window_event(
          active,
          window_id,
          @core.WindowEvent::DragMoved(position),
        )
      11 =>
        app.window_event(
          active,
          window_id,
          @core.WindowEvent::DragDropped(
            drag_paths_from_native(input_event_path(raw_id)),
            position,
          ),
        )
      12 =>
        app.window_event(
          active,
          window_id,
          @core.WindowEvent::DragLeft(
            if input_event_state(raw_id) != 0 {
              Some(position)
            } else {
              None
            },
          ),
        )
      13 =>
        match touch_phase_from_native(input_event_phase(raw_id)) {
          Some(phase) =>
            app.window_event(
              active,
              window_id,
              @core.WindowEvent::PinchGesture(
                pointer_device_id,
                input_event_scroll_delta_x(raw_id),
                phase,
              ),
            )
          None => ()
        }
      14 =>
        match touch_phase_from_native(input_event_phase(raw_id)) {
          Some(phase) =>
            app.window_event(
              active,
              window_id,
              @core.WindowEvent::PanGesture(
                pointer_device_id,
                @dpi.PhysicalPositionF64::new(
                  input_event_scroll_delta_x(raw_id),
                  input_event_scroll_delta_y(raw_id),
                ),
                phase,
              ),
            )
          None => ()
        }
      15 =>
        app.window_event(
          active,
          window_id,
          @core.WindowEvent::DoubleTapGesture(pointer_device_id),
        )
      16 =>
        match touch_phase_from_native(input_event_phase(raw_id)) {
          Some(phase) =>
            app.window_event(
              active,
              window_id,
              @core.WindowEvent::RotationGesture(
                pointer_device_id,
                input_event_scroll_delta_x(raw_id),
                phase,
              ),
            )
          None => ()
        }
      17 =>
        app.window_event(
          active,
          window_id,
          @core.WindowEvent::TouchpadPressure(
            pointer_device_id,
            input_event_scroll_delta_x(raw_id),
            input_event_state(raw_id),
          ),
        )
      18 =>
        dispatch_view_standard_key_binding(
          app,
          active,
          window_id,
          text_from_native(input_event_ime_text(raw_id)),
        )
      19 =>
        app.window_event(active, window_id, @core.WindowEvent::RedrawRequested)
      _ => ()
    }
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
