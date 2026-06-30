///|
fn reset_window_fullscreen_state_for_test() -> Unit {
  maximized_standard_frame_entries.val = []
  fullscreen_transition_entries.val = []
}

///|
test "fullscreen_transition_state_preserves_other_windows" {
  reset_window_fullscreen_state_for_test()
  let first = (701 : Int).to_uint64()
  let second = (702 : Int).to_uint64()

  set_window_fullscreen_transition_state(first, true)
  set_window_fullscreen_transition_state(second, true)
  clear_window_fullscreen_transition_state(first)

  assert_true(fullscreen_transition_index(first) == None)
  match fullscreen_transition_index(second) {
    Some(index) =>
      assert_true(fullscreen_transition_entries.val[index].in_transition)
    None => fail("expected second transition state")
  }
}

///|
test "maximized_standard_frame_state_preserves_other_windows" {
  reset_window_fullscreen_state_for_test()
  let first = (703 : Int).to_uint64()
  let second = (704 : Int).to_uint64()

  set_maximized_standard_frame_state(first, 1.0, 2.0, 3.0, 4.0)
  set_maximized_standard_frame_state(second, 5.0, 6.0, 7.0, 8.0)
  clear_maximized_standard_frame_state(first)

  assert_true(maximized_standard_frame_state(first) is None)
  match maximized_standard_frame_state(second) {
    Some(frame) => {
      assert_eq(frame.x, 5.0)
      assert_eq(frame.y, 6.0)
      assert_eq(frame.width, 7.0)
      assert_eq(frame.height, 8.0)
    }
    None => fail("expected second standard frame")
  }
}
