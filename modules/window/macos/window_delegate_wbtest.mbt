///|
test "ime_cursor_area_state_tracks_position_and_clamps_size" {
  let handle = (91 : Int).to_uint64()
  set_window_ime_cursor_area_state(handle, 12, 34, 0, -5)

  assert_eq(window_ime_cursor_x_state(handle), 12)
  assert_eq(window_ime_cursor_y_state(handle), 34)
  assert_eq(window_ime_cursor_width_state(handle), 1)
  assert_eq(window_ime_cursor_height_state(handle), 1)
}

///|
test "ime_cursor_area_state_preserves_positive_size" {
  let handle = (92 : Int).to_uint64()
  set_window_ime_cursor_area_state(handle, 7, 8, 21, 22)

  assert_eq(window_ime_cursor_x_state(handle), 7)
  assert_eq(window_ime_cursor_y_state(handle), 8)
  assert_eq(window_ime_cursor_width_state(handle), 21)
  assert_eq(window_ime_cursor_height_state(handle), 22)
}

///|
test "flip_window_screen_coordinate_y_is_symmetric" {
  let logical_y = 128.0
  let frame_height = 320.0
  let appkit_y = flip_window_screen_coordinate_y(logical_y, frame_height)
  assert_eq(flip_window_screen_coordinate_y(appkit_y, frame_height), logical_y)
}

///|
test "window_surface_offset_y_from_frame_and_content_matches_expected" {
  assert_eq(
    window_surface_offset_y_from_frame_and_content(100.0, 600.0, 120.0, 560.0),
    20.0,
  )
}

///|
test "cursor_screen_y_from_content_rect_matches_top_edge_at_zero_offset" {
  let content_y = 120.0
  let content_height = 560.0
  assert_eq(
    cursor_screen_y_from_content_rect(content_y, content_height, 0),
    flip_window_screen_coordinate_y(content_y, content_height),
  )
}

///|
test "cursor_screen_y_from_content_rect_increases_with_cursor_offset" {
  let content_y = 120.0
  let content_height = 560.0
  let base = cursor_screen_y_from_content_rect(content_y, content_height, 0)
  let moved = cursor_screen_y_from_content_rect(content_y, content_height, 37)
  assert_eq(moved - base, 37.0)
}

///|
test "accepts_first_mouse_state_defaults_to_false_and_tracks_updates" {
  let handle = (94 : Int).to_uint64()

  assert_false(window_accepts_first_mouse_state(handle))

  set_window_accepts_first_mouse_state(handle, true)
  assert_true(window_accepts_first_mouse_state(handle))
}

///|
test "cursor_visible_state_defaults_to_true_and_tracks_updates" {
  let handle = (95 : Int).to_uint64()

  assert_true(window_cursor_visible_state(handle))

  set_window_cursor_visible_state(handle, false)
  assert_false(window_cursor_visible_state(handle))

  set_window_cursor_visible_state(handle, true)
  assert_true(window_cursor_visible_state(handle))
}

///|
test "clear_window_platform_state_resets_cursor_visible_state" {
  let handle = (96 : Int).to_uint64()

  set_window_cursor_visible_state(handle, false)
  assert_false(window_cursor_visible_state(handle))

  clear_window_platform_state(handle)
  assert_true(window_cursor_visible_state(handle))
}

///|
test "clear_window_platform_state_preserves_other_windows" {
  reset_window_platform_state_for_test()
  let first = (97 : Int).to_uint64()
  let second = (98 : Int).to_uint64()

  set_window_ime_allowed_state(first, true)
  set_window_cursor_visible_state(first, false)
  set_window_accepts_first_mouse_state(second, true)
  set_window_option_as_alt_state(second, 3)
  set_window_ime_cursor_area_state(second, 11, 12, 13, 14)

  clear_window_platform_state(first)

  assert_false(window_ime_allowed_state(first))
  assert_true(window_cursor_visible_state(first))
  assert_true(window_accepts_first_mouse_state(second))
  assert_eq(window_option_as_alt_native(second), 3)
  assert_eq(window_ime_cursor_x_state(second), 11)
  assert_eq(window_ime_cursor_y_state(second), 12)
  assert_eq(window_ime_cursor_width_state(second), 13)
  assert_eq(window_ime_cursor_height_state(second), 14)
}
