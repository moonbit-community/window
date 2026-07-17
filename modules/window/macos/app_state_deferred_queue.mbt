///|
fn app_state_deferred_queue_push(callback : DeferredCallback) -> Unit {
  app_state_runtime.val.deferred_callbacks.push(callback)
}

///|
fn app_state_deferred_queue_clear() -> Unit {
  app_state_runtime.val.deferred_callbacks = []
}

///|
fn app_state_deferred_queue_contains(
  predicate : (DeferredCallback) -> Bool,
) -> Bool {
  for callback in app_state_runtime.val.deferred_callbacks {
    if predicate(callback) {
      return true
    }
  }
  false
}

///|
fn app_state_deferred_queue_take_next_dispatchable(
  is_running : Bool,
) -> DeferredCallback? {
  if app_state_runtime.val.deferred_callbacks.is_empty() {
    return None
  }
  if is_running {
    return Some(app_state_runtime.val.deferred_callbacks.remove(0))
  }
  match
    app_state_runtime.val.deferred_callbacks.search_by(callback => {
      app_state_callback_requires_running(callback) == false
    }) {
    Some(index) => Some(app_state_runtime.val.deferred_callbacks.remove(index))
    None => None
  }
}
