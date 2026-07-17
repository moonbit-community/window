///|
priv struct TestWindowProvider {
  raw : RawWindowHandle
}

///|
impl WindowHandleProvider for TestWindowProvider with fn raw_window_handle(self) {
  self.raw
}

///|
priv struct TestDisplayProvider {
  raw : RawDisplayHandle
}

///|
impl DisplayHandleProvider for TestDisplayProvider with fn raw_display_handle(
  self,
) {
  self.raw
}

///|
test "AppKit handle providers preserve structured handles" {
  let appkit_window = AppKitWindowHandle::new(42UL)
  let window_provider : TestWindowProvider = { raw: AppKit(appkit_window) }
  let window = WindowHandle::from_provider(
    window_provider as &WindowHandleProvider,
  )
  assert_eq(window.as_raw(), AppKit(appkit_window))
  let appkit_display = AppKitDisplayHandle::new()
  let display_provider : TestDisplayProvider = { raw: AppKit(appkit_display) }
  let display = DisplayHandle::from_provider(
    display_provider as &DisplayHandleProvider,
  )
  assert_eq(display.as_raw(), AppKit(appkit_display))
}

///|
test "pointer-backed window handles reject null values" {
  let appkit = try AppKitWindowHandle::new(0UL) catch {
    Unavailable => None
  } noraise {
    handle => Some(handle)
  }
  assert_eq(appkit, None)
  let win32 = try Win32WindowHandle::new(0UL) catch {
    Unavailable => None
  } noraise {
    handle => Some(handle)
  }
  assert_eq(win32, None)
  let wayland = try WaylandWindowHandle::new(0UL) catch {
    Unavailable => None
  } noraise {
    handle => Some(handle)
  }
  assert_eq(wayland, None)
}

///|
test "placeholder platform handles retain platform-specific fields" {
  let win32 = Win32WindowHandle::new(7UL, hinstance=9UL)
  assert_eq(win32.hwnd(), 7UL)
  assert_eq(win32.hinstance(), Some(9UL))
  let xlib = XlibWindowHandle::new(11UL, visual_id=13UL)
  assert_eq(xlib.window(), 11UL)
  assert_eq(xlib.visual_id(), 13UL)
  let xcb = XcbWindowHandle::new(17U, visual_id=19U)
  assert_eq(xcb.window(), 17U)
  assert_eq(xcb.visual_id(), Some(19U))
}
