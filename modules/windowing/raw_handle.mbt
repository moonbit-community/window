///|
pub struct AppKitWindowHandle {
  priv ns_view_ : UInt64
} derive(Eq, Debug)

///|
pub fn AppKitWindowHandle::new(
  ns_view : UInt64,
) -> AppKitWindowHandle raise HandleError {
  guard ns_view != 0UL else { raise Unavailable }
  { ns_view_: ns_view, }
}

///|
pub fn AppKitWindowHandle::ns_view(self : AppKitWindowHandle) -> UInt64 {
  self.ns_view_
}

///|
pub struct AppKitDisplayHandle {
  priv _unit : Unit
} derive(Eq, Debug)

///|
pub fn AppKitDisplayHandle::new() -> AppKitDisplayHandle {
  { _unit: (), }
}

///|
pub struct Win32WindowHandle {
  priv hwnd_ : UInt64
  priv hinstance_ : UInt64?
} derive(Eq, Debug)

///|
pub fn Win32WindowHandle::new(
  hwnd : UInt64,
  hinstance? : UInt64,
) -> Win32WindowHandle raise HandleError {
  guard hwnd != 0UL else { raise Unavailable }
  { hwnd_: hwnd, hinstance_: hinstance, }
}

///|
pub fn Win32WindowHandle::hwnd(self : Win32WindowHandle) -> UInt64 {
  self.hwnd_
}

///|
pub fn Win32WindowHandle::hinstance(self : Win32WindowHandle) -> UInt64? {
  self.hinstance_
}

///|
pub struct WindowsDisplayHandle {
  priv _unit : Unit
} derive(Eq, Debug)

///|
pub fn WindowsDisplayHandle::new() -> WindowsDisplayHandle {
  { _unit: (), }
}

///|
pub struct WaylandWindowHandle {
  priv surface_ : UInt64
} derive(Eq, Debug)

///|
pub fn WaylandWindowHandle::new(
  surface : UInt64,
) -> WaylandWindowHandle raise HandleError {
  guard surface != 0UL else { raise Unavailable }
  { surface_: surface, }
}

///|
pub fn WaylandWindowHandle::surface(self : WaylandWindowHandle) -> UInt64 {
  self.surface_
}

///|
pub struct WaylandDisplayHandle {
  priv display_ : UInt64
} derive(Eq, Debug)

///|
pub fn WaylandDisplayHandle::new(
  display : UInt64,
) -> WaylandDisplayHandle raise HandleError {
  guard display != 0UL else { raise Unavailable }
  { display_: display, }
}

///|
pub fn WaylandDisplayHandle::display(self : WaylandDisplayHandle) -> UInt64 {
  self.display_
}

///|
pub struct XlibWindowHandle {
  priv window_ : UInt64
  priv visual_id_ : UInt64
} derive(Eq, Debug)

///|
pub fn XlibWindowHandle::new(
  window : UInt64,
  visual_id? : UInt64 = 0UL,
) -> XlibWindowHandle raise HandleError {
  guard window != 0UL else { raise Unavailable }
  { window_: window, visual_id_: visual_id, }
}

///|
pub fn XlibWindowHandle::window(self : XlibWindowHandle) -> UInt64 {
  self.window_
}

///|
pub fn XlibWindowHandle::visual_id(self : XlibWindowHandle) -> UInt64 {
  self.visual_id_
}

///|
pub struct XlibDisplayHandle {
  priv display_ : UInt64?
  priv screen_ : Int
} derive(Eq, Debug)

///|
pub fn XlibDisplayHandle::new(
  display : UInt64?,
  screen : Int,
) -> XlibDisplayHandle {
  { display_: display, screen_: screen, }
}

///|
pub fn XlibDisplayHandle::display(self : XlibDisplayHandle) -> UInt64? {
  self.display_
}

///|
pub fn XlibDisplayHandle::screen(self : XlibDisplayHandle) -> Int {
  self.screen_
}

///|
pub struct XcbWindowHandle {
  priv window_ : UInt
  priv visual_id_ : UInt?
} derive(Eq, Debug)

///|
pub fn XcbWindowHandle::new(
  window : UInt,
  visual_id? : UInt,
) -> XcbWindowHandle raise HandleError {
  guard window != 0U else { raise Unavailable }
  { window_: window, visual_id_: visual_id, }
}

///|
pub fn XcbWindowHandle::window(self : XcbWindowHandle) -> UInt {
  self.window_
}

///|
pub fn XcbWindowHandle::visual_id(self : XcbWindowHandle) -> UInt? {
  self.visual_id_
}

///|
pub struct XcbDisplayHandle {
  priv connection_ : UInt64?
  priv screen_ : Int
} derive(Eq, Debug)

///|
pub fn XcbDisplayHandle::new(
  connection : UInt64?,
  screen : Int,
) -> XcbDisplayHandle {
  { connection_: connection, screen_: screen, }
}

///|
pub fn XcbDisplayHandle::connection(self : XcbDisplayHandle) -> UInt64? {
  self.connection_
}

///|
pub fn XcbDisplayHandle::screen(self : XcbDisplayHandle) -> Int {
  self.screen_
}

///|
pub(all) enum RawWindowHandle {
  AppKit(AppKitWindowHandle)
  Win32(Win32WindowHandle)
  Wayland(WaylandWindowHandle)
  Xlib(XlibWindowHandle)
  Xcb(XcbWindowHandle)
} derive(Eq, Debug)

///|
pub(all) enum RawDisplayHandle {
  AppKit(AppKitDisplayHandle)
  Windows(WindowsDisplayHandle)
  Wayland(WaylandDisplayHandle)
  Xlib(XlibDisplayHandle)
  Xcb(XcbDisplayHandle)
} derive(Eq, Debug)

///|
pub extend AppKitDisplayHandle with Debug::{to_repr}

///|
pub extend AppKitDisplayHandle with Eq::{not_equal, equal}

///|
pub extend AppKitWindowHandle with Debug::{to_repr}

///|
pub extend AppKitWindowHandle with Eq::{not_equal, equal}

///|
pub extend RawDisplayHandle with Debug::{to_repr}

///|
pub extend RawDisplayHandle with Eq::{not_equal, equal}

///|
pub extend RawWindowHandle with Debug::{to_repr}

///|
pub extend RawWindowHandle with Eq::{not_equal, equal}

///|
pub extend WaylandDisplayHandle with Debug::{to_repr}

///|
pub extend WaylandDisplayHandle with Eq::{not_equal, equal}

///|
pub extend WaylandWindowHandle with Debug::{to_repr}

///|
pub extend WaylandWindowHandle with Eq::{not_equal, equal}

///|
pub extend Win32WindowHandle with Debug::{to_repr}

///|
pub extend Win32WindowHandle with Eq::{not_equal, equal}

///|
pub extend WindowsDisplayHandle with Debug::{to_repr}

///|
pub extend WindowsDisplayHandle with Eq::{not_equal, equal}

///|
pub extend XcbDisplayHandle with Debug::{to_repr}

///|
pub extend XcbDisplayHandle with Eq::{not_equal, equal}

///|
pub extend XcbWindowHandle with Debug::{to_repr}

///|
pub extend XcbWindowHandle with Eq::{not_equal, equal}

///|
pub extend XlibDisplayHandle with Debug::{to_repr}

///|
pub extend XlibDisplayHandle with Eq::{not_equal, equal}

///|
pub extend XlibWindowHandle with Debug::{to_repr}

///|
pub extend XlibWindowHandle with Eq::{not_equal, equal}
