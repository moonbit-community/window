///|
extern "C" fn override_send_event_for_test() -> Bool = "mbw_test_application_override_send_event"

///|
extern "C" fn override_send_event_custom_class_for_test() -> Bool = "mbw_test_application_override_send_event_custom_class"

///|
test "test_override" {
  if !is_main_thread() {
    ()
  } else {
    assert_true(override_send_event_for_test())
  }
}

///|
test "test_custom_class" {
  if !is_main_thread() {
    ()
  } else {
    assert_true(override_send_event_custom_class_for_test())
  }
}
