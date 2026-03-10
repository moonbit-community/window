///|
test "device id can round-trip through raw integer" {
  let device_id = DeviceId::from_raw(42L)
  assert_eq(device_id.into_raw(), 42L)
}

///|
test "raw key event preserves physical key and state" {
  let event = RawKeyEvent::new(
    PhysicalKey::Code(KeyCode::KeyA),
    ElementState::Pressed,
  )
  assert_eq(event.physical_key(), PhysicalKey::Code(KeyCode::KeyA))
  assert_eq(event.state(), ElementState::Pressed)
}

///|
test "device event variants are constructible" {
  assert_eq(
    DeviceEvent::PointerMotion(1.5, -2.0),
    DeviceEvent::PointerMotion(1.5, -2.0),
  )
  assert_eq(
    DeviceEvent::MouseWheel(MouseScrollDelta::LineDelta(0.0, 1.0)),
    DeviceEvent::MouseWheel(MouseScrollDelta::LineDelta(0.0, 1.0)),
  )
  assert_eq(
    DeviceEvent::Button(ButtonId::from_raw(1), ElementState::Released),
    DeviceEvent::Button(ButtonId::from_raw(1), ElementState::Released),
  )
  assert_eq(
    DeviceEvent::PointerMotion(1.5, -2.0).into_winit_event(),
    WinitDeviceEvent::MouseMotion(1.5, -2.0),
  )
  assert_eq(
    DeviceEvent::MouseWheel(MouseScrollDelta::LineDelta(0.0, 1.0)).into_winit_event(),
    WinitDeviceEvent::MouseWheel(MouseScrollDelta::LineDelta(0.0, 1.0)),
  )
}

///|
test "ime event variants are constructible" {
  let range = ImeCursorRange::new(1, 2)
  assert_eq(Ime::Enabled, Ime::Enabled)
  assert_eq(Ime::Preedit("a", Some(range)), Ime::Preedit("a", Some(range)))
  assert_eq(Ime::Commit("text"), Ime::Commit("text"))
  assert_eq(Ime::DeleteSurrounding(2, 3), Ime::DeleteSurrounding(2, 3))
  assert_eq(Ime::Disabled, Ime::Disabled)
}

///|
test "async request serials can be created and round-tripped" {
  let serial = AsyncRequestSerial::get()
  assert_true(serial.into_raw() >= 0)
  let restored = AsyncRequestSerial::from_raw(7)
  assert_eq(restored.into_raw(), 7)
}

///|
test "mouse button conversion and button source helpers" {
  assert_eq(MouseButton::try_from_u8(0), Some(MouseButton::Left))
  assert_eq(MouseButton::try_from_u8(4), Some(MouseButton::Forward))
  assert_eq(MouseButton::try_from_u8(31), Some(MouseButton::Button32))
  assert_eq(MouseButton::try_from_u8(32), None)
  let from_touch = ButtonSource::Touch(FingerId::from_raw(3), None)
  assert_eq(from_touch.mouse_button(), Some(MouseButton::Left))
  let from_tool = ButtonSource::TabletTool(
    TabletToolKind::Pen,
    TabletToolButton::Barrel,
    TabletToolData::new(None, None, None, None, None),
  )
  assert_eq(from_tool.mouse_button(), Some(MouseButton::Right))
  let unknown = ButtonSource::Unknown(99)
  assert_eq(unknown.mouse_button(), None)
}

///|
test "tablet tool helpers and force normalization are available" {
  let angle = TabletToolAngle::new(@math.PI / 2.0, 0.0)
  let normalized = Force::Calibrated(1.0, 2.0).normalized(Some(angle))
  assert_true(Double::abs(normalized - 0.5) < 0.000001)
  let direct = Force::Normalized(0.25).normalized(None)
  assert_true(Double::abs(direct - 0.25) < 0.000001)
  let tilt = TabletToolTilt::new(0, 0)
  let angle_from_tilt = tilt.angle()
  assert_true(angle_from_tilt.altitude() >= 0.0)
  let tilt_from_angle = angle_from_tilt.tilt()
  assert_true(tilt_from_angle.x() <= 90)
}

///|
test "window events can be projected to winit-compatible events" {
  let hovered = WindowEvent::DragEntered(
    ["/tmp/a.txt", "/tmp/b.txt"],
    @dpi.PhysicalPositionF64::new(12.0, 24.0),
  ).into_winit_events()
  assert_eq(hovered.length(), 2)
  match hovered[0] {
    WinitWindowEvent::HoveredFile(path) => assert_eq(path, "/tmp/a.txt")
    _ => fail("expected first hovered file event")
  }
  match hovered[1] {
    WinitWindowEvent::HoveredFile(path) => assert_eq(path, "/tmp/b.txt")
    _ => fail("expected second hovered file event")
  }

  let cursor_moved = WindowEvent::PointerMoved(
    Some(DeviceId::from_raw(5L)),
    @dpi.PhysicalPositionF64::new(3.0, 4.0),
    true,
    PointerSource::Mouse,
  ).into_winit_events()
  assert_eq(cursor_moved.length(), 1)
  match cursor_moved[0] {
    WinitWindowEvent::CursorMoved(Some(device_id), position) => {
      assert_eq(device_id, DeviceId::from_raw(5L))
      assert_eq(position, @dpi.PhysicalPositionF64::new(3.0, 4.0))
    }
    _ => fail("expected cursor moved event")
  }

  let mouse_input = WindowEvent::PointerButton(
    Some(DeviceId::from_raw(7L)),
    ElementState::Pressed,
    @dpi.PhysicalPositionF64::new(8.0, 9.0),
    true,
    ButtonSource::Mouse(MouseButton::Left),
  ).into_winit_events()
  assert_eq(mouse_input.length(), 1)
  match mouse_input[0] {
    WinitWindowEvent::MouseInput(Some(device_id), state, button) => {
      assert_eq(device_id, DeviceId::from_raw(7L))
      assert_eq(state, ElementState::Pressed)
      assert_eq(button, MouseButton::Left)
    }
    _ => fail("expected mouse input event")
  }

  let touch_button = WindowEvent::PointerButton(
    None,
    ElementState::Pressed,
    @dpi.PhysicalPositionF64::new(8.0, 9.0),
    true,
    ButtonSource::Touch(FingerId::from_raw(2), None),
  ).into_winit_events()
  assert_eq(touch_button.length(), 0)

  let resized = WindowEvent::SurfaceResized(@dpi.PhysicalSize::new(640, 480)).into_winit_events()
  assert_eq(resized.length(), 1)
  match resized[0] {
    WinitWindowEvent::Resized(size) =>
      assert_eq(size, @dpi.PhysicalSize::new(640, 480))
    _ => fail("expected resized event")
  }
}
