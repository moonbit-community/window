///|
fn system_cursor_icons_for_test() -> Array[@core.CursorIcon] {
  [
    Default,
    ContextMenu,
    Help,
    Progress,
    Wait,
    Cell,
    VerticalText,
    Alias,
    Copy,
    NoDrop,
    Grab,
    Grabbing,
    EResize,
    NResize,
    NeResize,
    NwResize,
    SResize,
    SeResize,
    SwResize,
    WResize,
    EwResize,
    NsResize,
    NeswResize,
    NwseResize,
    ColResize,
    RowResize,
    AllScroll,
    ZoomIn,
    ZoomOut,
    Pointer,
    Text,
    Crosshair,
    Move,
    NotAllowed,
  ]
}

///|
test "all system cursor icons resolve to AppKit cursors" {
  ignore(native_application_shared_handle())
  for icon in system_cursor_icons_for_test() {
    if cursor_from_icon(icon) == (0 : Int).to_uint64() {
      fail("failed to resolve cursor: \{icon}")
    }
  }
}

///|
test "invisible cursor is cached" {
  ignore(native_application_shared_handle())
  let first = invisible_cursor()
  assert_true(first != (0 : Int).to_uint64())
  assert_eq(invisible_cursor(), first)
}
