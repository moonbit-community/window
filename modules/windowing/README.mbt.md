# Milky2018/windowing

`Milky2018/windowing` defines backend-neutral raw window and display handle
contracts for MoonBit window systems and renderer libraries.

The module does not create windows or rendering surfaces. Window libraries
implement `HasWindowHandle` and `HasDisplayHandle`; renderer libraries consume
the resulting structured handles.

The current implemented producer is AppKit. Win32, Wayland, Xlib, and Xcb
handle types are present as interoperability placeholders for future backends.

## Contracts

- `HasWindowHandle` produces a `WindowHandle`.
- `HasDisplayHandle` produces a `DisplayHandle`.
- `WindowHandle::as_raw()` and `DisplayHandle::as_raw()` expose a
  platform-specific enum at the renderer boundary.
- Handle objects retain their provider, allowing a window implementation to
  keep its native owner reachable while a renderer holds the handle.

Pointer-backed constructors reject zero addresses with
`HandleError::Unavailable`. The provider may also return `Unavailable` after
the underlying native object has been explicitly destroyed.

The module deliberately has no dependency on `Milky2018/window` or a renderer
implementation.
