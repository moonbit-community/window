///|
test "cursor_position_to_logical_preserves_logical_input" {
  let logical = cursor_position_to_logical(
    @dpi.LogicalPosition::new(120.0, 45.0).into_position(),
    2.0,
  )
  assert_eq(logical, @dpi.LogicalPosition::new(120.0, 45.0))
}

///|
test "cursor_position_to_logical_converts_physical_input" {
  let logical = cursor_position_to_logical(
    @dpi.PhysicalPosition::new(240, 90).into_position(),
    2.0,
  )
  assert_eq(logical, @dpi.LogicalPosition::new(120.0, 45.0))
}
