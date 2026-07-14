///|
fn reset_window_fullscreen_state_for_test() -> Unit {
  clear_all_window_fullscreen_state()
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
test "fullscreen target keeps only the latest request" {
  reset_window_fullscreen_state_for_test()
  let window = (705 : Int).to_uint64()

  set_window_target_fullscreen_state(window, true)
  set_window_target_fullscreen_state(window, false)

  assert_true(take_window_target_fullscreen_state(window) == Some(false))
  assert_true(take_window_target_fullscreen_state(window) == None)
}

///|
test "fullscreen target state is isolated per window" {
  reset_window_fullscreen_state_for_test()
  let first = (706 : Int).to_uint64()
  let second = (707 : Int).to_uint64()

  set_window_fullscreen_transition_state(first, true)
  set_window_target_fullscreen_state(first, false)
  set_window_target_fullscreen_state(second, true)
  clear_window_target_fullscreen_state(first)

  match fullscreen_transition_index(first) {
    Some(index) =>
      assert_true(fullscreen_transition_entries.val[index].in_transition)
    None => fail("expected first transition state")
  }
  assert_true(take_window_target_fullscreen_state(first) == None)
  assert_true(take_window_target_fullscreen_state(second) == Some(true))
}

///|
test "clearing fullscreen state removes transition and target" {
  reset_window_fullscreen_state_for_test()
  let window = (708 : Int).to_uint64()

  set_window_fullscreen_transition_state(window, true)
  set_window_target_fullscreen_state(window, false)
  clear_window_fullscreen_transition_state(window)

  assert_true(fullscreen_transition_index(window) == None)
  assert_true(take_window_target_fullscreen_state(window) == None)
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
