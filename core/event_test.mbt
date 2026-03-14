///|
fn approx_eq(left : Double, right : Double) -> Bool {
  Double::abs(left - right) < 0.000001
}

///|
struct TiltAngleCase {
  expected_angle : TabletToolAngle
  label : String
  tilt : TabletToolTilt
}

///|
struct AngleTiltCase {
  angle : TabletToolAngle
  expected_tilt : TabletToolTilt
}

///|
test "test_event_clone" {
  let device_events = [
    DeviceEvent::PointerMotion(0.0, 0.0),
    DeviceEvent::MouseWheel(MouseScrollDelta::LineDelta(0.0, 0.0)),
    DeviceEvent::Button(ButtonId::from_raw(0), ElementState::Pressed),
  ]
  for event in device_events {
    let event2 = event
    assert_eq(event, event2)
  }
}

///|
test "test_tilt_angle_conversions" {
  let pi = @math.PI
  let pi_0_5 = pi / 2.0
  let pi_0_25 = pi / 4.0
  let pi_1_5 = 3.0 * pi / 2.0
  let tilt_to_angle = [
    {
      tilt: TabletToolTilt::new(0, 0),
      expected_angle: TabletToolAngle::new(pi_0_5, 0.0),
      label: "0/0",
    },
    {
      tilt: TabletToolTilt::new(0, 90),
      expected_angle: TabletToolAngle::new(0.0, pi_0_5),
      label: "0/90",
    },
    {
      tilt: TabletToolTilt::new(0, -90),
      expected_angle: TabletToolAngle::new(0.0, pi_1_5),
      label: "0/-90",
    },
    {
      tilt: TabletToolTilt::new(90, 0),
      expected_angle: TabletToolAngle::new(0.0, 0.0),
      label: "90/0",
    },
    {
      tilt: TabletToolTilt::new(-90, 0),
      expected_angle: TabletToolAngle::new(0.0, pi),
      label: "-90/0",
    },
    {
      tilt: TabletToolTilt::new(0, 45),
      expected_angle: TabletToolAngle::new(pi_0_25, pi_0_5),
      label: "0/45",
    },
    {
      tilt: TabletToolTilt::new(0, -45),
      expected_angle: TabletToolAngle::new(pi_0_25, pi_1_5),
      label: "0/-45",
    },
    {
      tilt: TabletToolTilt::new(45, 0),
      expected_angle: TabletToolAngle::new(pi_0_25, 0.0),
      label: "45/0",
    },
    {
      tilt: TabletToolTilt::new(-45, 0),
      expected_angle: TabletToolAngle::new(pi_0_25, pi),
      label: "-45/0",
    },
  ]

  for case in tilt_to_angle {
    let actual = case.tilt.angle()
    let _ = case.label
    assert_true(approx_eq(actual.altitude(), case.expected_angle.altitude()))
    assert_true(approx_eq(actual.azimuth(), case.expected_angle.azimuth()))
  }

  let angle_to_tilt = [
    {
      angle: TabletToolAngle::new(0.0, 0.0),
      expected_tilt: TabletToolTilt::new(90, 0),
    },
    {
      angle: TabletToolAngle::new(pi_0_25, 0.0),
      expected_tilt: TabletToolTilt::new(45, 0),
    },
    {
      angle: TabletToolAngle::new(pi_0_5, 0.0),
      expected_tilt: TabletToolTilt::new(0, 0),
    },
    {
      angle: TabletToolAngle::new(0.0, pi_0_5),
      expected_tilt: TabletToolTilt::new(0, 90),
    },
    {
      angle: TabletToolAngle::new(pi_0_25, pi_0_5),
      expected_tilt: TabletToolTilt::new(0, 45),
    },
    {
      angle: TabletToolAngle::new(0.0, pi),
      expected_tilt: TabletToolTilt::new(-90, 0),
    },
    {
      angle: TabletToolAngle::new(pi_0_25, pi),
      expected_tilt: TabletToolTilt::new(-45, 0),
    },
    {
      angle: TabletToolAngle::new(0.0, pi_1_5),
      expected_tilt: TabletToolTilt::new(0, -90),
    },
    {
      angle: TabletToolAngle::new(pi_0_25, pi_1_5),
      expected_tilt: TabletToolTilt::new(0, -45),
    },
  ]
  for case in angle_to_tilt {
    assert_eq(case.angle.tilt(), case.expected_tilt)
  }
}

///|
test "test_force_normalize" {
  let force = Force::Normalized(0.0)
  assert_true(approx_eq(force.normalized(None), 0.0))

  let force2 = Force::Calibrated(5.0, 2.5)
  assert_true(approx_eq(force2.normalized(None), 2.0))

  let force3 = Force::Calibrated(5.0, 2.5)
  assert_true(
    approx_eq(
      force3.normalized(Some(TabletToolAngle::new(@math.PI / 2.0, 0.0))),
      2.0,
    ),
  )
}

///|
test "ensure_attrs_do_not_panic" {
  let window_events = [
    WindowEvent::CloseRequested,
    WindowEvent::Destroyed,
    WindowEvent::Focused(true),
    WindowEvent::Moved(@dpi.PhysicalPosition::new(0, 0)),
    WindowEvent::SurfaceResized(@dpi.PhysicalSize::new(0, 0)),
    WindowEvent::DragEntered(["x.txt"], @dpi.PhysicalPositionF64::new(0.0, 0.0)),
    WindowEvent::DragMoved(@dpi.PhysicalPositionF64::new(0.0, 0.0)),
    WindowEvent::DragDropped(["x.txt"], @dpi.PhysicalPositionF64::new(0.0, 0.0)),
    WindowEvent::DragLeft(Some(@dpi.PhysicalPositionF64::new(0.0, 0.0))),
    WindowEvent::Ime(Ime::Enabled),
    WindowEvent::PointerMoved(
      None,
      @dpi.PhysicalPositionF64::new(0.0, 0.0),
      true,
      PointerSource::Mouse,
    ),
    WindowEvent::ModifiersChanged(Modifiers::default()),
    WindowEvent::PointerEntered(
      None,
      @dpi.PhysicalPositionF64::new(0.0, 0.0),
      true,
      PointerKind::Mouse,
    ),
    WindowEvent::PointerLeft(
      None,
      Some(@dpi.PhysicalPositionF64::new(0.0, 0.0)),
      true,
      PointerKind::Mouse,
    ),
    WindowEvent::MouseWheel(
      None,
      MouseScrollDelta::LineDelta(0.0, 0.0),
      TouchPhase::Started,
    ),
    WindowEvent::PointerButton(
      None,
      ElementState::Pressed,
      @dpi.PhysicalPositionF64::new(0.0, 0.0),
      true,
      ButtonSource::Unknown(0),
    ),
    WindowEvent::PinchGesture(None, 0.0, TouchPhase::Started),
    WindowEvent::DoubleTapGesture(None),
    WindowEvent::RotationGesture(None, 0.0, TouchPhase::Started),
    WindowEvent::PanGesture(
      None,
      @dpi.PhysicalPositionF64::new(0.0, 0.0),
      TouchPhase::Started,
    ),
    WindowEvent::TouchpadPressure(None, 0.0, 0),
    WindowEvent::ThemeChanged(Theme::Light),
    WindowEvent::Occluded(true),
    WindowEvent::RedrawRequested,
  ]

  for event in window_events {
    let _ = "\{event}"
  }

  let device_events = [
    DeviceEvent::PointerMotion(0.0, 0.0),
    DeviceEvent::MouseWheel(MouseScrollDelta::LineDelta(0.0, 0.0)),
    DeviceEvent::Button(ButtonId::from_raw(0), ElementState::Pressed),
  ]
  for event in device_events {
    let _ = "\{event}"
  }

  let _ = "\{StartCause::Init}"
  let _ = "\{FingerId::from_raw(0)}"
  let _ = "\{TouchPhase::Started}"
  let _ = "\{MouseButton::Left}"
  let _ = "\{Ime::Enabled}"
  let _ = "\{Force::Calibrated(0.0, 0.0)}"
}
