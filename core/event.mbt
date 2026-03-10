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
pub(all) enum MouseButton {
  Left
  Right
  Middle
  Back
  Forward
  Other(Int)
} derive(Eq, Show)

///|
pub(all) enum PointerKind {
  Mouse
  Unknown
} derive(Eq, Show)

///|
pub(all) enum PointerSource {
  Mouse
  Unknown
} derive(Eq, Show)

///|
pub(all) enum ButtonSource {
  Mouse(MouseButton)
  Unknown(Int)
} derive(Eq, Show)

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
  Disabled
} derive(Eq, Show)

///|
pub struct Modifiers {
  alt : Bool
  control : Bool
  meta : Bool
  shift : Bool
} derive(Eq, Show)

///|
pub fn Modifiers::new(
  shift : Bool,
  control : Bool,
  alt : Bool,
  meta : Bool,
) -> Modifiers {
  { shift, control, alt, meta }
}

///|
pub fn Modifiers::default() -> Modifiers {
  { shift: false, control: false, alt: false, meta: false }
}

///|
pub fn Modifiers::shift_key(self : Modifiers) -> Bool {
  self.shift
}

///|
pub fn Modifiers::control_key(self : Modifiers) -> Bool {
  self.control
}

///|
pub fn Modifiers::alt_key(self : Modifiers) -> Bool {
  self.alt
}

///|
pub fn Modifiers::meta_key(self : Modifiers) -> Bool {
  self.meta
}

///|
pub fn Modifiers::is_empty(self : Modifiers) -> Bool {
  self.shift == false &&
  self.control == false &&
  self.alt == false &&
  self.meta == false
}

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
  Button(Int, ElementState)
  Key(RawKeyEvent)
} derive(Eq, Show)

///|
pub(all) enum WindowEvent {
  ActivationTokenDone(Int, ActivationToken)
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
