///|
test "get_on_main executes on the process main thread" {
  assert_true(get_on_main(fn() { is_main_thread() }))
}

///|
test "nested get_on_main calls execute without redispatch" {
  assert_eq(get_on_main(fn() { get_on_main(fn() { 42 }) }), 42)
}

///|
test "get_on_main_result preserves typed errors" {
  let ignored = Ref(false)
  let _ = get_on_main_result(fn() -> Unit raise @core.RequestError {
    raise Ignored
  }) catch {
    Ignored => ignored.val = true
    _ => ()
  }
  assert_true(ignored.val)
}
