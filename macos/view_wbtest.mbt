///|
fn reset_view_state_for_test() -> Unit {
  view_ime_window_ids.val = []
  view_ime_states.val = []
  view_ime_old_states.val = []
  view_ime_forward_key_to_apps.val = []
  view_ime_input_sources.val = []
  view_ime_has_marked_texts.val = []
  view_ime_marked_text_lengths.val = []
  view_ime_selected_range_locations.val = []
  view_ime_selected_range_lengths.val = []

  app_state_runtime.val = AppStateRuntime::new()
  app_state_window_position_raw_ids.val = []
  app_state_window_position_xs.val = []
  app_state_window_position_ys.val = []

  window_platform_state_handles.val = []
  window_ime_allowed_values.val = []
  window_accepts_first_mouse_values.val = []
  window_option_as_alt_values.val = []
  window_ime_purpose_values.val = []
  window_ime_hints_values.val = []
  window_ime_cursor_x_values.val = []
  window_ime_cursor_y_values.val = []
  window_ime_cursor_width_values.val = []
  window_ime_cursor_height_values.val = []
}

///|
test "native view state query reads moonbit ime state" {
  reset_view_state_for_test()

  let raw_id = 17
  let window_handle = (91 : Int).to_uint64()
  app_state_runtime.val.window_handles.push({ raw_id, handle: window_handle })
  set_window_ime_allowed_state(window_handle, true)
  set_window_ime_cursor_area_state(window_handle, 12, 34, 0, -5)
  view_set_has_marked_text(raw_id, true)
  view_set_marked_text_length(raw_id, 5)
  view_set_selected_range(raw_id, 2, 3)

  assert_eq(
    view_native_query_state(raw_id, native_view_state_query_ime_allowed),
    1,
  )
  assert_eq(
    view_native_query_state(raw_id, native_view_state_query_marked_text_length),
    5,
  )
  assert_eq(
    view_native_query_state(
      raw_id, native_view_state_query_selected_range_location,
    ),
    2,
  )
  assert_eq(
    view_native_query_state(
      raw_id, native_view_state_query_selected_range_length,
    ),
    3,
  )
  assert_eq(
    view_native_query_state(raw_id, native_view_state_query_ime_cursor_x),
    12,
  )
  assert_eq(
    view_native_query_state(raw_id, native_view_state_query_ime_cursor_y),
    34,
  )
  assert_eq(
    view_native_query_state(raw_id, native_view_state_query_ime_cursor_width),
    1,
  )
  assert_eq(
    view_native_query_state(raw_id, native_view_state_query_ime_cursor_height),
    1,
  )
}

///|
test "native view state query reads accepts first mouse from moonbit" {
  reset_view_state_for_test()

  let raw_id = 19
  let window_handle = (93 : Int).to_uint64()
  app_state_runtime.val.window_handles.push({ raw_id, handle: window_handle })

  assert_eq(
    view_native_query_state(raw_id, native_view_state_query_accepts_first_mouse),
    0,
  )

  set_window_accepts_first_mouse_state(window_handle, true)

  assert_eq(
    view_native_query_state(raw_id, native_view_state_query_accepts_first_mouse),
    1,
  )
}

///|
test "clear_marked_text_resets_queryable_ime_state" {
  reset_view_state_for_test()

  let raw_id = 23
  view_set_has_marked_text(raw_id, true)
  view_set_marked_text_length(raw_id, 6)
  view_set_selected_range(raw_id, 1, 2)

  view_clear_marked_text(raw_id)

  assert_false(view_has_marked_text(raw_id))
  assert_eq(view_marked_text_length(raw_id), 0)
  assert_eq(view_selected_range_location(raw_id), -1)
  assert_eq(view_selected_range_length(raw_id), 0)
}

///|
test "disable_ime_clears_marked_text_query_state" {
  reset_view_state_for_test()

  let raw_id = 31
  view_set_ime_state(raw_id, view_ime_state_preedit)
  view_set_has_marked_text(raw_id, true)
  view_set_marked_text_length(raw_id, 4)
  view_set_selected_range(raw_id, 0, 2)

  view_disable_ime(raw_id)

  assert_eq(view_ime_state(raw_id), view_ime_state_disabled)
  assert_false(view_has_marked_text(raw_id))
  assert_eq(view_marked_text_length(raw_id), 0)
  assert_eq(view_selected_range_location(raw_id), -1)
  assert_eq(view_selected_range_length(raw_id), 0)
}
