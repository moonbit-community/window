///|
fn is_main_thread() -> Bool {
  native_get_current_thread_id() == app_state_thread_id()
}
