///|
pub(all) suberror HandleError {
  Unavailable
} derive(Eq, Debug)

///|
pub(open) trait WindowHandleProvider {
  fn raw_window_handle(Self) -> RawWindowHandle raise HandleError
}

///|
pub(open) trait DisplayHandleProvider {
  fn raw_display_handle(Self) -> RawDisplayHandle raise HandleError
}

///|
pub(open) trait HasWindowHandle {
  fn window_handle(Self) -> WindowHandle raise HandleError
}

///|
pub(open) trait HasDisplayHandle {
  fn display_handle(Self) -> DisplayHandle raise HandleError
}

///|
pub struct WindowHandle {
  priv provider : &WindowHandleProvider
}

///|
pub fn WindowHandle::from_provider(
  provider : &WindowHandleProvider,
) -> WindowHandle {
  { provider, }
}

///|
pub fn WindowHandle::as_raw(
  self : WindowHandle,
) -> RawWindowHandle raise HandleError {
  self.provider.raw_window_handle()
}

///|
pub impl Debug for WindowHandle with fn to_repr(_self) {
  Repr::opaque_("WindowHandle", Repr::literal("borrowed"))
}

///|
pub struct DisplayHandle {
  priv provider : &DisplayHandleProvider
}

///|
pub fn DisplayHandle::from_provider(
  provider : &DisplayHandleProvider,
) -> DisplayHandle {
  { provider, }
}

///|
pub fn DisplayHandle::as_raw(
  self : DisplayHandle,
) -> RawDisplayHandle raise HandleError {
  self.provider.raw_display_handle()
}

///|
pub impl Debug for DisplayHandle with fn to_repr(_self) {
  Repr::opaque_("DisplayHandle", Repr::literal("borrowed"))
}
