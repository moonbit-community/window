///|
fn approx_eq(left : Double, right : Double) -> Bool {
  Double::abs(left - right) < 0.000001
}

///|
struct TiltAngleCase {
  expected_angle : @core.TabletToolAngle
  label : String
  tilt : @core.TabletToolTilt
}

///|
struct AngleTiltCase {
  angle : @core.TabletToolAngle
  expected_tilt : @core.TabletToolTilt
}

///|
test "test_event_clone" {
  let device_events = [
    @core.DeviceEvent::PointerMotion(0.0, 0.0),
    MouseWheel(LineDelta(0.0, 0.0)),
    Button(@core.ButtonId::from_raw(0), Pressed),
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
      tilt: TabletToolTilt(0, 0),
      expected_angle: TabletToolAngle(pi_0_5, 0.0),
      label: "0/0",
    },
    {
      tilt: TabletToolTilt(0, 90),
      expected_angle: TabletToolAngle(0.0, pi_0_5),
      label: "0/90",
    },
    {
      tilt: TabletToolTilt(0, -90),
      expected_angle: TabletToolAngle(0.0, pi_1_5),
      label: "0/-90",
    },
    {
      tilt: TabletToolTilt(90, 0),
      expected_angle: TabletToolAngle(0.0, 0.0),
      label: "90/0",
    },
    {
      tilt: TabletToolTilt(-90, 0),
      expected_angle: TabletToolAngle(0.0, pi),
      label: "-90/0",
    },
    {
      tilt: TabletToolTilt(0, 45),
      expected_angle: TabletToolAngle(pi_0_25, pi_0_5),
      label: "0/45",
    },
    {
      tilt: TabletToolTilt(0, -45),
      expected_angle: TabletToolAngle(pi_0_25, pi_1_5),
      label: "0/-45",
    },
    {
      tilt: TabletToolTilt(45, 0),
      expected_angle: TabletToolAngle(pi_0_25, 0.0),
      label: "45/0",
    },
    {
      tilt: TabletToolTilt(-45, 0),
      expected_angle: TabletToolAngle(pi_0_25, pi),
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
    { angle: TabletToolAngle(0.0, 0.0), expected_tilt: TabletToolTilt(90, 0), },
    {
      angle: TabletToolAngle(pi_0_25, 0.0),
      expected_tilt: TabletToolTilt(45, 0),
    },
    {
      angle: TabletToolAngle(pi_0_5, 0.0),
      expected_tilt: TabletToolTilt(0, 0),
    },
    {
      angle: TabletToolAngle(0.0, pi_0_5),
      expected_tilt: TabletToolTilt(0, 90),
    },
    {
      angle: TabletToolAngle(pi_0_25, pi_0_5),
      expected_tilt: TabletToolTilt(0, 45),
    },
    { angle: TabletToolAngle(0.0, pi), expected_tilt: TabletToolTilt(-90, 0), },
    {
      angle: TabletToolAngle(pi_0_25, pi),
      expected_tilt: TabletToolTilt(-45, 0),
    },
    {
      angle: TabletToolAngle(0.0, pi_1_5),
      expected_tilt: TabletToolTilt(0, -90),
    },
    {
      angle: TabletToolAngle(pi_0_25, pi_1_5),
      expected_tilt: TabletToolTilt(0, -45),
    },
  ]
  for case in angle_to_tilt {
    assert_eq(case.angle.tilt(), case.expected_tilt)
  }
}

///|
test "test_force_normalize" {
  let force = @core.Force::Normalized(0.0)
  assert_true(approx_eq(force.normalized(None), 0.0))

  let force2 = @core.Force::Calibrated(5.0, 2.5)
  assert_true(approx_eq(force2.normalized(None), 2.0))

  let force3 = @core.Force::Calibrated(5.0, 2.5)
  assert_true(
    approx_eq(
      force3.normalized(Some(TabletToolAngle(@math.PI / 2.0, 0.0))),
      2.0,
    ),
  )
}

///|
test "ensure_attrs_do_not_panic" {
  let window_events = [
    @core.WindowEvent::CloseRequested,
    Destroyed,
    Focused(true),
    Moved(PhysicalPosition(0, 0)),
    SurfaceResized(PhysicalSize(0, 0)),
    DragEntered(["x.txt"], PhysicalPositionF64(0.0, 0.0)),
    DragMoved(PhysicalPositionF64(0.0, 0.0)),
    DragDropped(["x.txt"], PhysicalPositionF64(0.0, 0.0)),
    DragLeft(Some(PhysicalPositionF64(0.0, 0.0))),
    Ime(Enabled),
    PointerMoved(None, PhysicalPositionF64(0.0, 0.0), true, Mouse),
    ModifiersChanged(@core.Modifiers::default()),
    PointerEntered(None, PhysicalPositionF64(0.0, 0.0), true, Mouse),
    PointerLeft(None, Some(PhysicalPositionF64(0.0, 0.0)), true, Mouse),
    MouseWheel(None, LineDelta(0.0, 0.0), Started),
    PointerButton(
      None,
      Pressed,
      PhysicalPositionF64(0.0, 0.0),
      true,
      Unknown(0),
    ),
    PinchGesture(None, 0.0, Started),
    DoubleTapGesture(None),
    RotationGesture(None, 0.0, Started),
    PanGesture(None, PhysicalPositionF64(0.0, 0.0), Started),
    TouchpadPressure(None, 0.0, 0),
    ThemeChanged(Light),
    Occluded(true),
    RedrawRequested,
  ]

  for event in window_events {
    let _ = "\{event}"
  }

  let device_events = [
    @core.DeviceEvent::PointerMotion(0.0, 0.0),
    MouseWheel(LineDelta(0.0, 0.0)),
    Button(@core.ButtonId::from_raw(0), Pressed),
  ]
  for event in device_events {
    let _ = "\{event}"
  }

  let _ = "\{@core.StartCause::Init}"
  let _ = "\{@core.FingerId::from_raw(0)}"
  let _ = "\{@core.TouchPhase::Started}"
  let _ = "\{@core.MouseButton::Left}"
  let _ = "\{@core.Ime::Enabled}"
  let _ = "\{@core.Force::Calibrated(0.0, 0.0)}"
}
