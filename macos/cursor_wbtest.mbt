///|
extern "C" fn native_test_custom_cursor_rgba_layout_is_valid(
  rgba_len : Int,
  width : Int,
  height : Int,
  hotspot_x : Int,
  hotspot_y : Int,
) -> Bool = "mbw_test_custom_cursor_rgba_layout_is_valid"

///|
test "native custom cursor validates RGBA layout without overflow" {
  assert_true(native_test_custom_cursor_rgba_layout_is_valid(4, 1, 1, 0, 0))
  assert_true(
    native_test_custom_cursor_rgba_layout_is_valid(
      16777216, 2048, 2048, 2047, 2047,
    ),
  )
  assert_false(
    native_test_custom_cursor_rgba_layout_is_valid(4, 1073741825, 1, 0, 0),
  )
  assert_false(native_test_custom_cursor_rgba_layout_is_valid(-1, 1, 1, 0, 0))
  assert_false(native_test_custom_cursor_rgba_layout_is_valid(8, 1, 1, 0, 0))
  assert_false(native_test_custom_cursor_rgba_layout_is_valid(4, 1, 1, 1, 0))
  assert_false(native_test_custom_cursor_rgba_layout_is_valid(4, 2049, 1, 0, 0))
}

///|
test "native custom cursor creation rejects overflowing RGBA layout" {
  let handle = appkit_custom_cursor_create_rgba(
    Bytes::make(4, (0 : Int).to_byte()),
    4,
    1073741825,
    1,
    0,
    0,
  )
  assert_eq(appkit_custom_cursor_objc_handle(handle), (0 : Int).to_uint64())
}

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
test "move and cell cursors use public AppKit fallbacks" {
  ignore(native_application_shared_handle())
  let cursor_class = objc_runtime_class_handle("NSCursor")
  let open_hand = native_cursor_class_cursor(cursor_class, "openHandCursor")
  let crosshair = native_cursor_class_cursor(cursor_class, "crosshairCursor")
  assert_true(open_hand != (0 : Int).to_uint64())
  assert_true(crosshair != (0 : Int).to_uint64())
  assert_eq(cursor_from_icon(Move), open_hand)
  assert_eq(cursor_from_icon(AllScroll), open_hand)
  assert_eq(cursor_from_icon(Cell), crosshair)
}

///|
test "invisible cursor is cached" {
  ignore(native_application_shared_handle())
  let first = invisible_cursor()
  assert_true(first != (0 : Int).to_uint64())
  assert_eq(invisible_cursor(), first)
}
