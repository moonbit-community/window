///|
pub struct SurfaceSizeWriter {
  size : Ref[@dpi.PhysicalSize]
} derive(Show)

///|
pub fn SurfaceSizeWriter::new(size : @dpi.PhysicalSize) -> SurfaceSizeWriter {
  { size: Ref::new(size) }
}

///|
pub fn SurfaceSizeWriter::surface_size(
  self : SurfaceSizeWriter,
) -> @dpi.PhysicalSize {
  self.size.val
}

///|
pub fn SurfaceSizeWriter::request_surface_size(
  self : SurfaceSizeWriter,
  size : @dpi.PhysicalSize,
) -> Unit {
  self.size.val = size
}

///|
pub(all) enum StartCause {
  Init
  Poll
  WaitCancelled(Int64, Int64?)
  ResumeTimeReached(Int64, Int64)
} derive(Eq, Show)

///|
pub(all) enum ElementState {
  Pressed
  Released
} derive(Eq, Show)

///|
pub fn ElementState::is_pressed(self : ElementState) -> Bool {
  self is ElementState::Pressed
}

///|
pub(all) enum MouseButton {
  Left
  Right
  Middle
  Back
  Forward
  Button6
  Button7
  Button8
  Button9
  Button10
  Button11
  Button12
  Button13
  Button14
  Button15
  Button16
  Button17
  Button18
  Button19
  Button20
  Button21
  Button22
  Button23
  Button24
  Button25
  Button26
  Button27
  Button28
  Button29
  Button30
  Button31
  Button32
} derive(Eq, Show)

///|
pub fn MouseButton::try_from_u8(button : Int) -> MouseButton? {
  match button {
    0 => Some(MouseButton::Left)
    1 => Some(MouseButton::Right)
    2 => Some(MouseButton::Middle)
    3 => Some(MouseButton::Back)
    4 => Some(MouseButton::Forward)
    5 => Some(MouseButton::Button6)
    6 => Some(MouseButton::Button7)
    7 => Some(MouseButton::Button8)
    8 => Some(MouseButton::Button9)
    9 => Some(MouseButton::Button10)
    10 => Some(MouseButton::Button11)
    11 => Some(MouseButton::Button12)
    12 => Some(MouseButton::Button13)
    13 => Some(MouseButton::Button14)
    14 => Some(MouseButton::Button15)
    15 => Some(MouseButton::Button16)
    16 => Some(MouseButton::Button17)
    17 => Some(MouseButton::Button18)
    18 => Some(MouseButton::Button19)
    19 => Some(MouseButton::Button20)
    20 => Some(MouseButton::Button21)
    21 => Some(MouseButton::Button22)
    22 => Some(MouseButton::Button23)
    23 => Some(MouseButton::Button24)
    24 => Some(MouseButton::Button25)
    25 => Some(MouseButton::Button26)
    26 => Some(MouseButton::Button27)
    27 => Some(MouseButton::Button28)
    28 => Some(MouseButton::Button29)
    29 => Some(MouseButton::Button30)
    30 => Some(MouseButton::Button31)
    31 => Some(MouseButton::Button32)
    _ => None
  }
}

///|
pub struct FingerId {
  raw : Int
} derive(Eq, Show)

///|
pub fn FingerId::from_raw(raw : Int) -> FingerId {
  { raw, }
}

///|
pub fn FingerId::into_raw(self : FingerId) -> Int {
  self.raw
}

///|
pub struct AxisId {
  raw : Int
} derive(Eq, Show)

///|
pub fn AxisId::from_raw(raw : Int) -> AxisId {
  { raw, }
}

///|
pub fn AxisId::into_raw(self : AxisId) -> Int {
  self.raw
}

///|
pub struct ButtonId {
  raw : Int
} derive(Eq, Show)

///|
pub fn ButtonId::from_raw(raw : Int) -> ButtonId {
  { raw, }
}

///|
pub fn ButtonId::into_raw(self : ButtonId) -> Int {
  self.raw
}

///|
pub(all) enum MouseScrollDelta {
  LineDelta(Double, Double)
  PixelDelta(@dpi.PhysicalPositionF64)
} derive(Eq, Show)

///|
pub(all) enum TouchPhase {
  Started
  Moved
  Ended
  Cancelled
} derive(Eq, Show)

///|
pub(all) enum Force {
  Calibrated(Double, Double)
  Normalized(Double)
} derive(Eq, Show)

///|
pub fn Force::normalized(self : Force, angle : TabletToolAngle?) -> Double {
  match self {
    Calibrated(force, max_possible_force) => {
      let adjusted = match angle {
        Some(angle) => force / @math.sin(angle.altitude())
        None => force
      }
      adjusted / max_possible_force
    }
    Normalized(force) => force
  }
}

///|
pub(all) enum TabletToolKind {
  Pen
  Eraser
  Brush
  Pencil
  Airbrush
  Finger
  Mouse
  Lens
} derive(Eq, Show)

///|
pub fn TabletToolKind::default() -> TabletToolKind {
  TabletToolKind::Pen
}

///|
pub struct TabletToolData {
  force : Force?
  tangential_force : Double?
  twist : Int?
  tilt : TabletToolTilt?
  angle : TabletToolAngle?
} derive(Eq, Show)

///|
pub fn TabletToolData::new(
  force : Force?,
  tangential_force : Double?,
  twist : Int?,
  tilt : TabletToolTilt?,
  angle : TabletToolAngle?,
) -> TabletToolData {
  { force, tangential_force, twist, tilt, angle }
}

///|
pub fn TabletToolData::force(self : TabletToolData) -> Force? {
  self.force
}

///|
pub fn TabletToolData::tangential_force(self : TabletToolData) -> Double? {
  self.tangential_force
}

///|
pub fn TabletToolData::twist(self : TabletToolData) -> Int? {
  self.twist
}

///|
pub fn TabletToolData::tilt(self : TabletToolData) -> TabletToolTilt? {
  match self.tilt {
    Some(tilt) => Some(tilt)
    None =>
      match self.angle {
        Some(angle) => Some(angle.tilt())
        None => None
      }
  }
}

///|
pub fn TabletToolData::angle(self : TabletToolData) -> TabletToolAngle? {
  match self.angle {
    Some(angle) => Some(angle)
    None =>
      match self.tilt {
        Some(tilt) => Some(tilt.angle())
        None => None
      }
  }
}

///|
pub struct TabletToolTilt {
  x : Int
  y : Int
} derive(Eq, Show)

///|
pub fn TabletToolTilt::new(x : Int, y : Int) -> TabletToolTilt {
  { x, y }
}

///|
pub fn TabletToolTilt::x(self : TabletToolTilt) -> Int {
  self.x
}

///|
pub fn TabletToolTilt::y(self : TabletToolTilt) -> Int {
  self.y
}

///|
pub fn TabletToolTilt::angle(self : TabletToolTilt) -> TabletToolAngle {
  let pi_0_5 = @math.PI / 2.0
  let pi_1_5 = 3.0 * @math.PI / 2.0
  let pi_2 = 2.0 * @math.PI
  let x = degrees_to_radians(self.x.to_double())
  let y = degrees_to_radians(self.y.to_double())
  let mut azimuth = 0.0
  if self.x == 0 {
    if self.y > 0 {
      azimuth = pi_0_5
    } else if self.y < 0 {
      azimuth = pi_1_5
    }
  } else if self.y == 0 {
    if self.x < 0 {
      azimuth = @math.PI
    }
  } else if int_abs(self.x) == 90 || int_abs(self.y) == 90 {
    azimuth = 0.0
  } else {
    azimuth = @math.atan2(@math.tan(y), @math.tan(x))
    if azimuth < 0.0 {
      azimuth = azimuth + pi_2
    }
  }
  let altitude = if int_abs(self.x) == 90 || int_abs(self.y) == 90 {
    0.0
  } else if self.x == 0 {
    pi_0_5 - double_abs(y)
  } else if self.y == 0 {
    pi_0_5 - double_abs(x)
  } else {
    let tx = @math.tan(x)
    let ty = @math.tan(y)
    let denom = Double::sqrt(tx * tx + ty * ty)
    @math.atan(1.0 / denom)
  }
  TabletToolAngle::new(altitude, azimuth)
}

///|
pub struct TabletToolAngle {
  altitude : Double
  azimuth : Double
} derive(Eq, Show)

///|
pub fn TabletToolAngle::new(
  altitude : Double,
  azimuth : Double,
) -> TabletToolAngle {
  { altitude, azimuth }
}

///|
pub fn TabletToolAngle::default() -> TabletToolAngle {
  { altitude: 2.0 / @math.PI, azimuth: 0.0 }
}

///|
pub fn TabletToolAngle::altitude(self : TabletToolAngle) -> Double {
  self.altitude
}

///|
pub fn TabletToolAngle::azimuth(self : TabletToolAngle) -> Double {
  self.azimuth
}

///|
pub fn TabletToolAngle::tilt(self : TabletToolAngle) -> TabletToolTilt {
  let pi_0_5 = @math.PI / 2.0
  let pi_1_5 = 3.0 * @math.PI / 2.0
  let pi_2 = 2.0 * @math.PI
  let mut x = 0.0
  let mut y = 0.0
  if self.altitude == 0.0 {
    if self.azimuth == 0.0 || self.azimuth == pi_2 {
      x = pi_0_5
    } else if self.azimuth == pi_0_5 {
      y = pi_0_5
    } else if self.azimuth == @math.PI {
      x = -pi_0_5
    } else if self.azimuth == pi_1_5 {
      y = -pi_0_5
    } else if self.azimuth > 0.0 && self.azimuth < pi_0_5 {
      x = pi_0_5
      y = pi_0_5
    } else if self.azimuth > pi_0_5 && self.azimuth < @math.PI {
      x = -pi_0_5
      y = pi_0_5
    } else if self.azimuth > @math.PI && self.azimuth < pi_1_5 {
      x = -pi_0_5
      y = -pi_0_5
    } else if self.azimuth > pi_1_5 && self.azimuth < pi_2 {
      x = pi_0_5
      y = -pi_0_5
    }
  }
  if self.altitude != 0.0 {
    let altitude = @math.tan(self.altitude)
    x = @math.atan(@math.cos(self.azimuth) / altitude)
    y = @math.atan(@math.sin(self.azimuth) / altitude)
  }
  TabletToolTilt::new(
    @math.round(radians_to_degrees(x)).to_int(),
    @math.round(radians_to_degrees(y)).to_int(),
  )
}

///|
pub(all) enum TabletToolButton {
  Contact
  Barrel
  Other(Int)
} derive(Eq, Show)

///|
pub fn TabletToolButton::mouse_button(self : TabletToolButton) -> MouseButton? {
  match self {
    Contact => Some(MouseButton::Left)
    Barrel => Some(MouseButton::Right)
    Other(1) => Some(MouseButton::Middle)
    Other(3) => Some(MouseButton::Back)
    Other(4) => Some(MouseButton::Forward)
    Other(_) => None
  }
}

///|
pub(all) enum PointerKind {
  Mouse
  Touch(FingerId)
  TabletTool(TabletToolKind)
  Unknown
} derive(Eq, Show)

///|
pub(all) enum PointerSource {
  Mouse
  Touch(FingerId, Force?)
  TabletTool(TabletToolKind, TabletToolData)
  Unknown
} derive(Eq, Show)

///|
pub(all) enum ButtonSource {
  Mouse(MouseButton)
  Touch(FingerId, Force?)
  TabletTool(TabletToolKind, TabletToolButton, TabletToolData)
  Unknown(Int)
} derive(Eq, Show)

///|
pub fn ButtonSource::mouse_button(self : ButtonSource) -> MouseButton? {
  match self {
    Mouse(mouse) => Some(mouse)
    Touch(_, _) => Some(MouseButton::Left)
    TabletTool(_, button, _) => button.mouse_button()
    Unknown(_) => None
  }
}

///|
fn degrees_to_radians(degrees : Double) -> Double {
  degrees * (@math.PI / 180.0)
}

///|
fn radians_to_degrees(radians : Double) -> Double {
  radians * (180.0 / @math.PI)
}

///|
fn int_abs(value : Int) -> Int {
  if value < 0 {
    -value
  } else {
    value
  }
}

///|
fn double_abs(value : Double) -> Double {
  if value < 0.0 {
    -value
  } else {
    value
  }
}

///|
pub struct ImeCursorRange {
  end : Int
  start : Int
} derive(Eq, Show)

///|
pub fn ImeCursorRange::new(start : Int, end : Int) -> ImeCursorRange {
  { start, end }
}

///|
pub fn ImeCursorRange::start(self : ImeCursorRange) -> Int {
  self.start
}

///|
pub fn ImeCursorRange::end(self : ImeCursorRange) -> Int {
  self.end
}

///|
pub(all) enum Ime {
  Enabled
  Preedit(String, ImeCursorRange?)
  Commit(String)
  DeleteSurrounding(Int, Int)
  Disabled
} derive(Eq, Show)

///|
pub struct DeviceId {
  raw : Int64
} derive(Eq, Show)

///|
pub fn DeviceId::from_raw(raw : Int64) -> DeviceId {
  { raw, }
}

///|
pub fn DeviceId::into_raw(self : DeviceId) -> Int64 {
  self.raw
}

///|
pub struct RawKeyEvent {
  physical_key : PhysicalKey
  state : ElementState
} derive(Eq, Show)

///|
pub fn RawKeyEvent::new(
  physical_key : PhysicalKey,
  state : ElementState,
) -> RawKeyEvent {
  { physical_key, state }
}

///|
pub fn RawKeyEvent::physical_key(self : RawKeyEvent) -> PhysicalKey {
  self.physical_key
}

///|
pub fn RawKeyEvent::state(self : RawKeyEvent) -> ElementState {
  self.state
}

///|
pub(all) enum DeviceEvent {
  PointerMotion(Double, Double)
  MouseWheel(MouseScrollDelta)
  Button(ButtonId, ElementState)
  Key(RawKeyEvent)
} derive(Eq, Show)

///|
pub(all) enum WindowEvent {
  ActivationTokenDone(AsyncRequestSerial, ActivationToken)
  SurfaceResized(@dpi.PhysicalSize)
  Moved(@dpi.PhysicalPosition)
  CloseRequested
  Destroyed
  DragEntered(Array[String], @dpi.PhysicalPositionF64)
  DragMoved(@dpi.PhysicalPositionF64)
  DragDropped(Array[String], @dpi.PhysicalPositionF64)
  DragLeft(@dpi.PhysicalPositionF64?)
  Focused(Bool)
  Ime(Ime)
  KeyboardInput(DeviceId?, KeyEvent, Bool)
  ModifiersChanged(Modifiers)
  PointerMoved(DeviceId?, @dpi.PhysicalPositionF64, Bool, PointerSource)
  PointerEntered(DeviceId?, @dpi.PhysicalPositionF64, Bool, PointerKind)
  PointerLeft(DeviceId?, @dpi.PhysicalPositionF64?, Bool, PointerKind)
  PointerButton(
    DeviceId?,
    ElementState,
    @dpi.PhysicalPositionF64,
    Bool,
    ButtonSource
  )
  PinchGesture(DeviceId?, Double, TouchPhase)
  PanGesture(DeviceId?, @dpi.PhysicalPositionF64, TouchPhase)
  DoubleTapGesture(DeviceId?)
  RotationGesture(DeviceId?, Double, TouchPhase)
  TouchpadPressure(DeviceId?, Double, Int)
  MouseWheel(DeviceId?, MouseScrollDelta, TouchPhase)
  ScaleFactorChanged(Double, SurfaceSizeWriter)
  ThemeChanged(Theme)
  Occluded(Bool)
  RedrawRequested
} derive(Show)
