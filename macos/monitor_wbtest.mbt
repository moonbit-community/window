///|
fn primary_monitor_for_test() -> @core.MonitorHandle? {
  monitor_from_native_id(cg_main_display_id())
}

///|
test "uuid_stable" {
  let primary_id = cg_main_display_id()
  assert_true(primary_id > (0 : Int).to_uint64())

  let handle_a = monitor_from_native_id(primary_id)
  let handle_b = monitor_from_native_id(primary_id)
  assert_true(handle_a is Some(_))
  assert_true(handle_b is Some(_))
  match handle_a {
    Some(handle_a) =>
      match handle_b {
        Some(handle_b) => {
          assert_eq(handle_a, handle_b)
          assert_eq(handle_a.native_id(), handle_b.native_id())
        }
        None => ()
      }
    None => ()
  }

  let handle_c = primary_monitor_for_test()
  let handle_d = primary_monitor_for_test()
  assert_true(handle_c is Some(_))
  assert_true(handle_d is Some(_))
  match handle_c {
    Some(handle_c) =>
      match handle_d {
        Some(handle_d) => {
          assert_eq(handle_c, handle_d)
          assert_eq(handle_c.native_id(), handle_d.native_id())
        }
        None => ()
      }
    None => ()
  }
}

///|
test "monitorhandle_from_zero" {
  let primary_id = cg_main_display_id()
  assert_true(primary_id > (0 : Int).to_uint64())

  let handle0 = monitor_from_native_id((0 : Int).to_uint64())
  let handle1 = monitor_from_native_id(primary_id)
  assert_true(handle0 is Some(_))
  assert_true(handle1 is Some(_))
  match handle0 {
    Some(handle0) =>
      match handle1 {
        Some(handle1) => {
          assert_eq(handle0, handle1)
          assert_eq(handle0.native_id(), handle1.native_id())
        }
        None => ()
      }
    None => ()
  }
}

///|
test "from_invalid_id" {
  assert_eq(monitor_from_native_id((10000 : Int).to_uint64()), None)
}

///|
test "invalid_monitor_handle" {
  assert_eq(monitor_from_native_id((10000 : Int).to_uint64()), None)
}

///|
test "primary_monitor_has_ns_screen_handle" {
  let monitor = primary_monitor_for_test()
  assert_true(monitor is Some(_))
  match monitor {
    Some(monitor) => assert_true(monitor_ns_screen(monitor) is Some(_))
    None => ()
  }
}
