///|
test "validate scale factor rejects zero and nan" {
  assert_true(validate_scale_factor(1.0))
  assert_false(validate_scale_factor(0.0))
  assert_false(validate_scale_factor(0.0 / 0.0))
}

///|
test "logical size converts to physical size" {
  let logical = LogicalSize::new(320.0, 240.0)
  assert_eq(logical.to_physical(2.0), PhysicalSize::new(640, 480))
}

///|
test "physical size converts to logical size" {
  let physical = PhysicalSize::new(1280, 720)
  assert_eq(physical.to_logical(2.0), LogicalSize::new(640.0, 360.0))
}
