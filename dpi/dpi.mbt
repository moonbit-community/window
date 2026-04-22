///|
pub fn validate_scale_factor(scale_factor : Double) -> Bool {
  let exponent_mask = (0x7ff : Int).to_uint64()
  let exponent = (Double::reinterpret_as_uint64(scale_factor) >> 52) &
    exponent_mask
  scale_factor > 0.0 &&
  Double::is_nan(scale_factor) == false &&
  Double::is_inf(scale_factor) == false &&
  exponent != (0 : Int).to_uint64()
}

///|
pub struct LogicalSize {
  width : Double
  height : Double
} derive(Eq, Debug)

///|
pub fn LogicalSize::new(width : Double, height : Double) -> LogicalSize {
  { width, height }
}

///|
pub fn LogicalSize::width(self : LogicalSize) -> Double {
  self.width
}

///|
pub fn LogicalSize::height(self : LogicalSize) -> Double {
  self.height
}

///|
pub fn LogicalSize::to_physical(
  self : LogicalSize,
  scale_factor : Double,
) -> PhysicalSize {
  guard validate_scale_factor(scale_factor) else {
    abort("scale_factor must be positive")
  }
  PhysicalSize::new(
    (self.width * scale_factor).to_int(),
    (self.height * scale_factor).to_int(),
  )
}

///|
pub struct PhysicalSize {
  width : Int
  height : Int
} derive(Eq, Debug)

///|
pub fn PhysicalSize::new(width : Int, height : Int) -> PhysicalSize {
  { width, height }
}

///|
pub fn PhysicalSize::width(self : PhysicalSize) -> Int {
  self.width
}

///|
pub fn PhysicalSize::height(self : PhysicalSize) -> Int {
  self.height
}

///|
pub fn PhysicalSize::to_logical(
  self : PhysicalSize,
  scale_factor : Double,
) -> LogicalSize {
  guard validate_scale_factor(scale_factor) else {
    abort("scale_factor must be positive")
  }
  LogicalSize::new(
    self.width.to_double() / scale_factor,
    self.height.to_double() / scale_factor,
  )
}

///|
pub struct LogicalPosition {
  x : Double
  y : Double
} derive(Eq, Debug)

///|
pub fn LogicalPosition::new(x : Double, y : Double) -> LogicalPosition {
  { x, y }
}

///|
pub fn LogicalPosition::x(self : LogicalPosition) -> Double {
  self.x
}

///|
pub fn LogicalPosition::y(self : LogicalPosition) -> Double {
  self.y
}

///|
pub fn LogicalPosition::to_physical(
  self : LogicalPosition,
  scale_factor : Double,
) -> PhysicalPosition {
  guard validate_scale_factor(scale_factor) else {
    abort("scale_factor must be positive")
  }
  PhysicalPosition::new(
    (self.x * scale_factor).to_int(),
    (self.y * scale_factor).to_int(),
  )
}

///|
pub fn LogicalPosition::into_position(self : LogicalPosition) -> Position {
  Position::Logical(self)
}

///|
pub struct PhysicalPosition {
  x : Int
  y : Int
} derive(Eq, Debug)

///|
pub fn PhysicalPosition::new(x : Int, y : Int) -> PhysicalPosition {
  { x, y }
}

///|
pub fn PhysicalPosition::x(self : PhysicalPosition) -> Int {
  self.x
}

///|
pub fn PhysicalPosition::y(self : PhysicalPosition) -> Int {
  self.y
}

///|
pub fn PhysicalPosition::to_logical(
  self : PhysicalPosition,
  scale_factor : Double,
) -> LogicalPosition {
  guard validate_scale_factor(scale_factor) else {
    abort("scale_factor must be positive")
  }
  LogicalPosition::new(
    self.x.to_double() / scale_factor,
    self.y.to_double() / scale_factor,
  )
}

///|
pub fn PhysicalPosition::into_position(self : PhysicalPosition) -> Position {
  Position::Physical(self)
}

///|
pub struct PhysicalPositionF64 {
  x : Double
  y : Double
} derive(Eq, Debug)

///|
pub fn PhysicalPositionF64::new(x : Double, y : Double) -> PhysicalPositionF64 {
  { x, y }
}

///|
pub fn PhysicalPositionF64::x(self : PhysicalPositionF64) -> Double {
  self.x
}

///|
pub fn PhysicalPositionF64::y(self : PhysicalPositionF64) -> Double {
  self.y
}

///|
pub(all) enum Position {
  Logical(LogicalPosition)
  Physical(PhysicalPosition)
} derive(Eq, Debug)

///|
pub fn Position::from_logical(position : LogicalPosition) -> Position {
  Position::Logical(position)
}

///|
pub fn Position::from_physical(position : PhysicalPosition) -> Position {
  Position::Physical(position)
}

///|
pub fn Position::to_physical(
  self : Position,
  scale_factor : Double,
) -> PhysicalPosition {
  match self {
    Logical(position) => position.to_physical(scale_factor)
    Physical(position) => position
  }
}

///|
pub fn Position::to_logical(
  self : Position,
  scale_factor : Double,
) -> LogicalPosition {
  match self {
    Logical(position) => position
    Physical(position) => position.to_logical(scale_factor)
  }
}

///|
pub struct PhysicalInsets {
  top : Int
  left : Int
  bottom : Int
  right : Int
} derive(Eq, Debug)

///|
pub fn PhysicalInsets::new(
  top : Int,
  left : Int,
  bottom : Int,
  right : Int,
) -> PhysicalInsets {
  { top, left, bottom, right }
}

///|
pub fn PhysicalInsets::top(self : PhysicalInsets) -> Int {
  self.top
}

///|
pub fn PhysicalInsets::left(self : PhysicalInsets) -> Int {
  self.left
}

///|
pub fn PhysicalInsets::bottom(self : PhysicalInsets) -> Int {
  self.bottom
}

///|
pub fn PhysicalInsets::right(self : PhysicalInsets) -> Int {
  self.right
}

///|
pub(all) enum Size {
  Logical(LogicalSize)
  Physical(PhysicalSize)
} derive(Eq, Debug)

///|
pub fn LogicalSize::into_size(self : LogicalSize) -> Size {
  Size::Logical(self)
}

///|
pub fn PhysicalSize::into_size(self : PhysicalSize) -> Size {
  Size::Physical(self)
}

///|
pub fn Size::from_logical(size : LogicalSize) -> Size {
  Size::Logical(size)
}

///|
pub fn Size::from_physical(size : PhysicalSize) -> Size {
  Size::Physical(size)
}

///|
pub fn Size::to_physical(self : Size, scale_factor : Double) -> PhysicalSize {
  match self {
    Logical(size) => size.to_physical(scale_factor)
    Physical(size) => size
  }
}

///|
pub fn Size::to_logical(self : Size, scale_factor : Double) -> LogicalSize {
  match self {
    Logical(size) => size
    Physical(size) => size.to_logical(scale_factor)
  }
}
