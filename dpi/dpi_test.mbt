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
  let logical = LogicalSize::new(1.0, 2.0)
  assert_eq(logical.to_physical(1.0), PhysicalSize::new(1, 2))
  assert_eq(logical.to_physical(2.0), PhysicalSize::new(2, 4))
  assert_eq(
    logical.to_physical(2.0).to_logical(2.0),
    LogicalSize::new(1.0, 2.0),
  )
  assert_eq(logical.into_size(), Size::Logical(logical))
}

///|
test "test_physical_size" {
  let physical = PhysicalSize::new(1, 2)
  assert_eq(physical.to_logical(1.0), LogicalSize::new(1.0, 2.0))
  assert_eq(physical.to_logical(2.0), LogicalSize::new(0.5, 1.0))
  assert_eq(physical.to_logical(2.0).to_physical(2.0), PhysicalSize::new(1, 2))
  assert_eq(physical.into_size(), Size::Physical(physical))
}

///|
test "test_logical_position" {
  let logical = LogicalPosition::new(1.0, 2.0)
  assert_eq(logical.to_physical(1.0), PhysicalPosition::new(1, 2))
  assert_eq(logical.to_physical(2.0), PhysicalPosition::new(2, 4))
  assert_eq(
    logical.to_physical(2.0).to_logical(2.0),
    LogicalPosition::new(1.0, 2.0),
  )
  assert_eq(logical.into_position(), Position::Logical(logical))
}

///|
test "test_physical_position" {
  let physical = PhysicalPosition::new(1, 2)
  assert_eq(physical.to_logical(1.0), LogicalPosition::new(1.0, 2.0))
  assert_eq(physical.to_logical(2.0), LogicalPosition::new(0.5, 1.0))
  assert_eq(
    physical.to_logical(2.0).to_physical(2.0),
    PhysicalPosition::new(1, 2),
  )
  assert_eq(physical.into_position(), Position::Physical(physical))
}

///|
test "test_size" {
  assert_eq(
    Size::from_physical(PhysicalSize::new(1, 2)),
    Size::Physical(PhysicalSize::new(1, 2)),
  )
  assert_eq(
    Size::from_logical(LogicalSize::new(1.0, 2.0)),
    Size::Logical(LogicalSize::new(1.0, 2.0)),
  )

  assert_eq(
    Size::from_physical(PhysicalSize::new(1, 2)).to_logical(1.0),
    LogicalSize::new(1.0, 2.0),
  )
  assert_eq(
    Size::from_physical(PhysicalSize::new(1, 2)).to_logical(2.0),
    LogicalSize::new(0.5, 1.0),
  )
  assert_eq(
    Size::from_logical(LogicalSize::new(1.0, 2.0)).to_physical(2.0),
    PhysicalSize::new(2, 4),
  )
}

///|
test "test_position" {
  assert_eq(
    Position::from_physical(PhysicalPosition::new(1, 2)),
    Position::Physical(PhysicalPosition::new(1, 2)),
  )
  assert_eq(
    Position::from_logical(LogicalPosition::new(1.0, 2.0)),
    Position::Logical(LogicalPosition::new(1.0, 2.0)),
  )

  assert_eq(
    Position::from_physical(PhysicalPosition::new(1, 2)).to_logical(1.0),
    LogicalPosition::new(1.0, 2.0),
  )
  assert_eq(
    Position::from_physical(PhysicalPosition::new(1, 2)).to_logical(2.0),
    LogicalPosition::new(0.5, 1.0),
  )
  assert_eq(
    Position::from_logical(LogicalPosition::new(1.0, 2.0)).to_physical(2.0),
    PhysicalPosition::new(2, 4),
  )
}

///|
test "test_physical_insets" {
  let insets = PhysicalInsets::new(10, 20, 30, 40)
  assert_eq(insets.top(), 10)
  assert_eq(insets.left(), 20)
  assert_eq(insets.bottom(), 30)
  assert_eq(insets.right(), 40)
}

///|
test "logical_size_constructor_and_accessors" {
  let logical = LogicalSize::new(123.5, 456.25)
  assert_true(approx_eq(logical.width(), 123.5))
  assert_true(approx_eq(logical.height(), 456.25))
}

///|
test "physical_size_constructor_and_accessors" {
  let physical = PhysicalSize::new(123, 456)
  assert_eq(physical.width(), 123)
  assert_eq(physical.height(), 456)
}

///|
test "logical_position_constructor_and_accessors" {
  let logical = LogicalPosition::new(12.5, 45.75)
  assert_true(approx_eq(logical.x(), 12.5))
  assert_true(approx_eq(logical.y(), 45.75))
}

///|
test "physical_position_constructor_and_accessors" {
  let physical = PhysicalPosition::new(12, 45)
  assert_eq(physical.x(), 12)
  assert_eq(physical.y(), 45)
}

///|
test "size_roundtrip_through_scale_factor" {
  let original = Size::from_logical(LogicalSize::new(640.0, 480.0))
  let physical = original.to_physical(2.0)
  let roundtrip = Size::from_physical(physical).to_logical(2.0)
  assert_eq(roundtrip, LogicalSize::new(640.0, 480.0))
}

///|
test "position_roundtrip_through_scale_factor" {
  let original = Position::from_logical(LogicalPosition::new(320.0, 180.0))
  let physical = original.to_physical(2.0)
  let roundtrip = Position::from_physical(physical).to_logical(2.0)
  assert_eq(roundtrip, LogicalPosition::new(320.0, 180.0))
}

///|
test "ensure_attrs_do_not_panic" {
  let _ = "\{LogicalPosition::new(0.0, 0.0)}"
  let _ = "\{PhysicalPosition::new(0, 0)}"
  let _ = "\{LogicalSize::new(0.0, 0.0)}"
  let _ = "\{PhysicalSize::new(0, 0)}"
  let _ = "\{Size::Physical(PhysicalSize::new(1, 2))}"
  let _ = "\{Position::Physical(PhysicalPosition::new(1, 2))}"
}
