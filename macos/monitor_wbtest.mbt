///|
fn primary_monitor_for_test() -> @core.MonitorHandle? {
  monitor_from_native_id(cg_main_display_id())
}

///|
extern "C" fn native_test_display_refresh_rate_off_main(
  monitor_id : UInt,
) -> Int = "mbw_test_display_refresh_rate_off_main"

///|
extern "C" fn native_test_refresh_rate_millihertz_from_cvtime(
  time_scale : Int,
  time_value : Int,
) -> Int = "mbw_test_refresh_rate_millihertz_from_cvtime"

///|
test "CoreVideo refresh fallback preserves fractional rates" {
  assert_eq(native_test_refresh_rate_millihertz_from_cvtime(60000, 1001), 59940)
  assert_eq(native_test_refresh_rate_millihertz_from_cvtime(24000, 1001), 23976)
  assert_eq(native_test_refresh_rate_millihertz_from_cvtime(60, 1), 60000)
  assert_eq(native_test_refresh_rate_millihertz_from_cvtime(1, 2000), 1)
  assert_eq(native_test_refresh_rate_millihertz_from_cvtime(0, 1001), 0)
  assert_eq(native_test_refresh_rate_millihertz_from_cvtime(60000, 0), 0)
  assert_eq(
    native_test_refresh_rate_millihertz_from_cvtime(2147483647, 1),
    2147483647,
  )
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
  assert_true(monitor_from_native_id((10000 : Int).to_uint64()) == None)
}

///|
test "invalid_monitor_handle" {
  assert_true(monitor_from_native_id((10000 : Int).to_uint64()) == None)
}

///|
test "primary_monitor_has_ns_screen_handle" {
  let monitor = primary_monitor_for_test()
  assert_true(monitor is Some(_))
  match monitor {
    Some(monitor) =>
      match monitor_ns_screen(monitor) {
        Some(screen) => {
          assert_true(screen.objc_handle() != (0 : Int).to_uint64())
          screen.drop()
          assert_eq(screen.objc_handle(), (0 : Int).to_uint64())
          screen.drop()
        }
        None => fail("primary monitor NSScreen unavailable")
      }
    None => ()
  }
}

///|
test "primary monitor resolves its AppKit backing scale factor" {
  assert_eq(
    native_monitor_backing_scale_factor((10000 : Int).reinterpret_as_uint()),
    0.0,
  )
  match primary_monitor_for_test() {
    Some(monitor) => {
      let native_scale = native_monitor_backing_scale_factor(
        monitor.native_id().to_uint(),
      )
      assert_true(native_scale > 0.0)
      assert_eq(monitor.scale_factor(), native_scale)
    }
    None => fail("primary monitor unavailable")
  }
}

///|
test "display refresh fallback completes off the main thread" {
  assert_eq(
    native_test_display_refresh_rate_off_main(cg_main_display_id().to_uint()),
    1,
  )
}

///|
test "primary monitor video modes remain available on demand" {
  match primary_monitor_for_test() {
    Some(monitor) => {
      let modes = monitor.video_modes()
      assert_false(modes.is_empty())
      match monitor.current_video_mode() {
        Some(current_mode) =>
          assert_true(modes.search_by(mode => mode == current_mode) is Some(_))
        None => ()
      }
    }
    None => fail("primary monitor unavailable")
  }
}

///|
test "available monitor handles remain stable across 90 syncs" {
  let baseline = available_monitors()
  assert_false(baseline.is_empty())
  for _ in 0..<90 {
    let current = available_monitors()
    assert_eq(current.length(), baseline.length())
    for monitor in current {
      assert_true(
        baseline.search_by(existing => existing == monitor) is Some(_),
      )
    }
  }
}
