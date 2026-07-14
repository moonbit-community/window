///|
/// Execute a borrowed closure synchronously on the process main thread.
///
/// The native bridge never stores the closure beyond this call.
fn run_on_main(callback : () -> Unit) -> Unit {
  native_run_on_main(fn(callback) { callback() }, callback)
}

///|
/// Return a value from a complete main-thread operation.
fn[T] get_on_main(callback : () -> T) -> T {
  let result : Ref[T?] = Ref(None)
  run_on_main(fn() { result.val = Some(callback()) })
  result.val.unwrap()
}

///|
fn[T, E : Error] get_on_main_result(callback : () -> T raise E) -> T raise E {
  get_on_main(fn() -> Result[T, E] {
    Ok(callback()) catch {
      error => Err(error)
    }
  }).unwrap_or_error()
}

///|
fn[T] Window::maybe_wait_on_main(self : Window, callback : (Window) -> T) -> T {
  get_on_main(fn() { callback(self) })
}

///|
fn[T, E : Error] Window::maybe_wait_on_main_result(
  self : Window,
  callback : (Window) -> T raise E,
) -> T raise E {
  get_on_main_result(fn() -> T raise E { callback(self) })
}
