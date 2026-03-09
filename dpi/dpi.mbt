///|
pub fn validate_scale_factor(scale_factor : Double) -> Bool {
  scale_factor == scale_factor && scale_factor > 0.0
}

///|
pub struct LogicalSize {
  width : Double
  height : Double
} derive(Eq, Show)

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
} derive(Eq, Show)

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
} derive(Eq, Show)

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
pub struct PhysicalPosition {
  x : Int
  y : Int
} derive(Eq, Show)

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
pub struct PhysicalPositionF64 {
  x : Double
  y : Double
} derive(Eq, Show)

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
