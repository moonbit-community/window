///|
priv struct BorrowedObjcHandle {
  raw : UInt64
}

///|
fn BorrowedObjcHandle::BorrowedObjcHandle(raw : UInt64) -> BorrowedObjcHandle {
  { raw, }
}

///|
fn BorrowedObjcHandle::null() -> BorrowedObjcHandle {
  BorrowedObjcHandle((0 : Int).to_uint64())
}

///|
fn BorrowedObjcHandle::raw(self : BorrowedObjcHandle) -> UInt64 {
  self.raw
}

///|
fn BorrowedObjcHandle::is_null(self : BorrowedObjcHandle) -> Bool {
  self.raw == (0 : Int).to_uint64()
}

///|
fn BorrowedObjcHandle::is_non_null(self : BorrowedObjcHandle) -> Bool {
  self.raw != (0 : Int).to_uint64()
}

///|
fn borrowed_objc_handle(raw : UInt64) -> BorrowedObjcHandle {
  BorrowedObjcHandle(raw)
}
