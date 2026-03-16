///|
// Port target: winit-reference/winit-appkit/src/notification_center.rs

///|
const NOTIFICATION_DID_FINISH_LAUNCHING : Int = 1

///|
const NOTIFICATION_WILL_TERMINATE : Int = 2

///|
fn create_observer(notification_kind : Int, callback_kind : Int) -> UInt64 {
  native_notification_center_add_observer(
    fn(callback, kind) { callback(kind) },
    native_callback_lifecycle,
    notification_kind,
    callback_kind,
  )
}

///|
fn create_did_finish_launching_observer() -> UInt64 {
  create_observer(NOTIFICATION_DID_FINISH_LAUNCHING, 1)
}

///|
fn create_will_terminate_observer() -> UInt64 {
  create_observer(NOTIFICATION_WILL_TERMINATE, 2)
}

///|
fn native_notification_center_remove_observer(observer_handle : UInt64) -> Unit {
  if observer_handle != (0 : Int).to_uint64() {
    appkit_notification_center_remove_observer(observer_handle)
  }
}

///|
fn release_notification_observer(observer_handle : UInt64) -> Unit {
  native_notification_center_remove_observer(observer_handle)
}
