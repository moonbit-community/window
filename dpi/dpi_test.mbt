///|
fn approx_eq(left : Double, right : Double) -> Bool {
  Double::abs(left - right) < 0.001
}

///|
test "test_validate_scale_factor" {
  assert_true(validate_scale_factor(1.0))
  assert_true(validate_scale_factor(2.0))
  assert_true(validate_scale_factor(3.0))
  assert_true(validate_scale_factor(1.5))
  assert_true(validate_scale_factor(0.5))

  assert_false(validate_scale_factor(0.0))
  assert_false(validate_scale_factor(-1.0))
  assert_false(validate_scale_factor(1.0 / 0.0))
  assert_false(validate_scale_factor(0.0 / 0.0))
  assert_false(validate_scale_factor(-1.0 / 0.0))
}

///|
test "test_logical_size" {
  let logical = LogicalSize::LogicalSize(1.0, 2.0)
  assert_eq(logical.to_physical(1.0), PhysicalSize(1, 2))
  assert_eq(logical.to_physical(2.0), PhysicalSize(2, 4))
  assert_eq(logical.to_physical(2.0).to_logical(2.0), LogicalSize(1.0, 2.0))
  assert_eq(logical.into_size(), Logical(logical))
}

///|
test "test_physical_size" {
  let physical = PhysicalSize::PhysicalSize(1, 2)
  assert_eq(physical.to_logical(1.0), LogicalSize(1.0, 2.0))
  assert_eq(physical.to_logical(2.0), LogicalSize(0.5, 1.0))
  assert_eq(physical.to_logical(2.0).to_physical(2.0), PhysicalSize(1, 2))
  assert_eq(physical.into_size(), Physical(physical))
}

///|
test "test_logical_position" {
  let logical = LogicalPosition::LogicalPosition(1.0, 2.0)
  assert_eq(logical.to_physical(1.0), PhysicalPosition(1, 2))
  assert_eq(logical.to_physical(2.0), PhysicalPosition(2, 4))
  assert_eq(logical.to_physical(2.0).to_logical(2.0), LogicalPosition(1.0, 2.0))
  assert_eq(logical.into_position(), Logical(logical))
}

///|
test "test_physical_position" {
  let physical = PhysicalPosition::PhysicalPosition(1, 2)
  assert_eq(physical.to_logical(1.0), LogicalPosition(1.0, 2.0))
  assert_eq(physical.to_logical(2.0), LogicalPosition(0.5, 1.0))
  assert_eq(physical.to_logical(2.0).to_physical(2.0), PhysicalPosition(1, 2))
  assert_eq(physical.into_position(), Physical(physical))
}

///|
test "test_size" {
  assert_eq(
    Size::from_physical(PhysicalSize(1, 2)),
    Physical(PhysicalSize(1, 2)),
  )
  assert_eq(
    Size::from_logical(LogicalSize(1.0, 2.0)),
    Logical(LogicalSize(1.0, 2.0)),
  )

  assert_eq(
    Size::from_physical(PhysicalSize(1, 2)).to_logical(1.0),
    LogicalSize(1.0, 2.0),
  )
  assert_eq(
    Size::from_physical(PhysicalSize(1, 2)).to_logical(2.0),
    LogicalSize(0.5, 1.0),
  )
  assert_eq(
    Size::from_logical(LogicalSize(1.0, 2.0)).to_physical(2.0),
    PhysicalSize(2, 4),
  )
}

///|
test "test_position" {
  assert_eq(
    Position::from_physical(PhysicalPosition(1, 2)),
    Physical(PhysicalPosition(1, 2)),
  )
  assert_eq(
    Position::from_logical(LogicalPosition(1.0, 2.0)),
    Logical(LogicalPosition(1.0, 2.0)),
  )

  assert_eq(
    Position::from_physical(PhysicalPosition(1, 2)).to_logical(1.0),
    LogicalPosition(1.0, 2.0),
  )
  assert_eq(
    Position::from_physical(PhysicalPosition(1, 2)).to_logical(2.0),
    LogicalPosition(0.5, 1.0),
  )
  assert_eq(
    Position::from_logical(LogicalPosition(1.0, 2.0)).to_physical(2.0),
    PhysicalPosition(2, 4),
  )
}

///|
test "test_physical_insets" {
  let insets = PhysicalInsets::PhysicalInsets(10, 20, 30, 40)
  assert_eq(insets.top(), 10)
  assert_eq(insets.left(), 20)
  assert_eq(insets.bottom(), 30)
  assert_eq(insets.right(), 40)
}

///|
test "logical_size_constructor_and_accessors" {
  let logical = LogicalSize::LogicalSize(123.5, 456.25)
  assert_true(approx_eq(logical.width(), 123.5))
  assert_true(approx_eq(logical.height(), 456.25))
}

///|
test "physical_size_constructor_and_accessors" {
  let physical = PhysicalSize::PhysicalSize(123, 456)
  assert_eq(physical.width(), 123)
  assert_eq(physical.height(), 456)
}

///|
test "logical_position_constructor_and_accessors" {
  let logical = LogicalPosition::LogicalPosition(12.5, 45.75)
  assert_true(approx_eq(logical.x(), 12.5))
  assert_true(approx_eq(logical.y(), 45.75))
}

///|
test "physical_position_constructor_and_accessors" {
  let physical = PhysicalPosition::PhysicalPosition(12, 45)
  assert_eq(physical.x(), 12)
  assert_eq(physical.y(), 45)
}

///|
test "size_roundtrip_through_scale_factor" {
  let original = Size::from_logical(LogicalSize(640.0, 480.0))
  let physical = original.to_physical(2.0)
  let roundtrip = Size::from_physical(physical).to_logical(2.0)
  assert_eq(roundtrip, LogicalSize(640.0, 480.0))
}

///|
test "position_roundtrip_through_scale_factor" {
  let original = Position::from_logical(LogicalPosition(320.0, 180.0))
  let physical = original.to_physical(2.0)
  let roundtrip = Position::from_physical(physical).to_logical(2.0)
  assert_eq(roundtrip, LogicalPosition(320.0, 180.0))
}

///|
test "ensure_attrs_do_not_panic" {
  let _ = "\{LogicalPosition::LogicalPosition(0.0, 0.0)}"
  let _ = "\{PhysicalPosition::PhysicalPosition(0, 0)}"
  let _ = "\{LogicalSize::LogicalSize(0.0, 0.0)}"
  let _ = "\{PhysicalSize::PhysicalSize(0, 0)}"
  let _ = "\{Size::Physical(PhysicalSize(1, 2))}"
  let _ = "\{Position::Physical(PhysicalPosition(1, 2))}"
}
