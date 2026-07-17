///|
// Private owner wrapper helpers for short-lived +1 Objective-C objects.

///|
fn native_objc_owned_null() -> NativeObjcObject {
  appkit_objc_wrap_owned_object((0 : Int).to_uint64())
}

///|
fn native_objc_owned_handle(handle : NativeObjcObject) -> UInt64 {
  appkit_objc_owned_object_handle(handle)
}

///|
fn native_objc_owned_valid(handle : NativeObjcObject) -> Bool {
  native_objc_owned_handle(handle) != (0 : Int).to_uint64()
}
