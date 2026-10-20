///|
// Port target: winit-reference/winit-appkit/src/ffi.rs
// MoonBit adaptation:
// 1. Borrowed pointer-like values are represented as UInt64.
// 2. Owned native resources use opaque external objects with native finalizers.
// 3. kTISPropertyUnicodeKeyLayoutData is modeled by creating a CFString key.

extern "C" fn native_cf_absolute_time_get_current() -> Double = "CFAbsoluteTimeGetCurrent"

///|
extern "C" fn native_cgfloat_max() -> Double = "mbw_cgfloat_max"

///|
extern "C" fn native_cg_associate_mouse_and_mouse_cursor_position(
  connected : Bool,
) -> Int32 = "CGAssociateMouseAndMouseCursorPosition"

///|
extern "C" fn native_cg_warp_mouse_cursor_position(
  x : Double,
  y : Double,
) -> Int32 = "mbw_cg_warp_mouse_cursor_position"

///|
extern "C" fn native_cgs_set_window_background_blur_radius(
  window_number : Int32,
  radius : Int32,
) -> Bool = "mbw_cgs_set_window_background_blur_radius"

///|
extern "C" fn native_appkit_window_level(kind : Int32) -> UInt64 = "mbw_appkit_window_level"

///|
extern "C" fn native_cg_main_display_id() -> UInt32 = "CGMainDisplayID"

///|
extern "C" fn native_cg_display_model_number(display : UInt32) -> UInt32 = "CGDisplayModelNumber"

///|
extern "C" fn native_cg_display_pixels_wide(display : UInt32) -> UInt64 = "CGDisplayPixelsWide"

///|
extern "C" fn native_cg_display_pixels_high(display : UInt32) -> UInt64 = "CGDisplayPixelsHigh"

///|
extern "C" fn native_cg_display_get_display_id_from_uuid(
  uuid : UInt64,
) -> UInt32 = "CGDisplayGetDisplayIDFromUUID"

///|
extern "C" fn native_pthread_main_np() -> Int32 = "pthread_main_np"

///|
#borrow(call_closure, callback)
extern "C" fn native_run_on_main(
  call_closure : FuncRef[(() -> Unit) -> Unit],
  callback : () -> Unit,
) -> Unit = "mbw_run_on_main"

///|
extern "C" fn native_cg_active_display_count() -> Int32 = "mbw_cg_active_display_count"

///|
extern "C" fn native_cg_active_display_id_at(index : Int32) -> UInt32 = "mbw_cg_active_display_id_at"

///|
extern "C" fn native_cg_display_bounds_x(display : UInt32) -> Int32 = "mbw_cg_display_bounds_x"

///|
extern "C" fn native_cg_display_bounds_y(display : UInt32) -> Int32 = "mbw_cg_display_bounds_y"

///|
extern "C" fn native_cg_display_bounds_height(display : UInt32) -> Double = "mbw_cg_display_bounds_height"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_window_event_callback(
  call_closure : FuncRef[
    (
      (Int32, Int32, Int32, Int32, Int32, Double) -> Unit,
      Int32,
      Int32,
      Int32,
      Int32,
      Int32,
      Double,
    ) -> Unit,
  ],
  callback : (Int32, Int32, Int32, Int32, Int32, Double) -> Unit,
) -> Unit = "mbw_install_window_event_callback"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_notification_center_add_observer(
  call_closure : FuncRef[((Int32) -> Unit, Int32) -> Unit],
  callback : (Int32) -> Unit,
  notification_kind : Int32,
  callback_kind : Int32,
) -> NotificationObserver = "mbw_notification_center_add_observer"

///|
#borrow(observer_handle)
extern "C" fn appkit_notification_center_remove_observer(
  observer_handle : NotificationObserver,
) -> Unit = "mbw_notification_center_remove_observer"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_menu_action_callback(
  call_closure : FuncRef[((Int) -> Unit, Int) -> Unit],
  callback : (Int) -> Unit,
) -> Unit = "mbw_install_menu_action_callback"

///|
extern "C" fn native_create_menu_action_target() -> UInt64 = "mbw_create_menu_action_target"

///|
extern "C" fn native_set_menu_item_action_id(
  item_handle : UInt64,
  action_id : Int,
) -> Unit = "mbw_set_menu_item_action_id"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_main_run_loop_add_observer(
  call_closure : FuncRef[((Int32) -> Unit, Int32) -> Unit],
  callback : (Int32) -> Unit,
  activity_kind : Int32,
  callback_kind : Int32,
  order : Int32,
) -> MainRunLoopObserver = "mbw_main_run_loop_add_observer"

///|
#borrow(observer_handle)
extern "C" fn appkit_main_run_loop_remove_observer(
  observer_handle : MainRunLoopObserver,
) -> Unit = "mbw_main_run_loop_remove_observer"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_input_event_callback(
  call_closure : FuncRef[
    (
      (
        Int32,
        Int32,
        Int32,
        Double,
        Double,
        Int32,
        Int32,
        Int32,
        Int32,
        Int32,
        Int32,
        Int32,
        Int32,
        Double,
        Double,
        Int32,
        UInt64,
        UInt64,
        UInt64,
      ) -> Unit,
      Int32,
      Int32,
      Int32,
      Double,
      Double,
      Int32,
      Int32,
      Int32,
      Int32,
      Int32,
      Int32,
      Int32,
      Int32,
      Double,
      Double,
      Int32,
      UInt64,
      UInt64,
      UInt64,
    ) -> Unit,
  ],
  callback : (
    Int32,
    Int32,
    Int32,
    Double,
    Double,
    Int32,
    Int32,
    Int32,
    Int32,
    Int32,
    Int32,
    Int32,
    Int32,
    Double,
    Double,
    Int32,
    UInt64,
    UInt64,
    UInt64,
  ) -> Unit,
) -> Unit = "mbw_install_input_event_callback"

///|
extern "C" fn native_objc_copy_utf8_bytes(object_handle : UInt64) -> Bytes = "mbw_objc_copy_utf8_bytes"

///|
extern "C" fn native_copy_utf8_cstr_bytes(cstr_handle : UInt64) -> Bytes = "mbw_copy_utf8_cstr_bytes"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_text_input_event_callback(
  call_closure : FuncRef[
    (
      (Int32, Int32, Int32, UInt64, Int32, Int32, UInt64) -> Unit,
      Int32,
      Int32,
      Int32,
      UInt64,
      Int32,
      Int32,
      UInt64,
    ) -> Unit,
  ],
  callback : (Int32, Int32, Int32, UInt64, Int32, Int32, UInt64) -> Unit,
) -> Unit = "mbw_install_text_input_event_callback"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_device_event_callback(
  call_closure : FuncRef[
    ((Int32, Int32, Double, Double) -> Unit, Int32, Int32, Double, Double) -> Unit,
  ],
  callback : (Int32, Int32, Double, Double) -> Unit,
) -> Unit = "mbw_install_device_event_callback"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_drag_event_callback(
  call_closure : FuncRef[
    (
      (Int32, Int32, Double, Double, Int32, UInt64) -> Unit,
      Int32,
      Int32,
      Double,
      Double,
      Int32,
      UInt64,
    ) -> Unit,
  ],
  callback : (Int32, Int32, Double, Double, Int32, UInt64) -> Unit,
) -> Unit = "mbw_install_drag_event_callback"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_sync_query_callback(
  call_closure : FuncRef[
    ((Int32, Int32, UInt64) -> Int32, Int32, Int32, UInt64) -> Int32,
  ],
  callback : (Int32, Int32, UInt64) -> Int32,
) -> Unit = "mbw_install_sync_query_callback"

///|
extern "C" fn native_override_send_event() -> Unit = "mbw_override_send_event"

///|
type NativeWindow

///|
type NotificationObserver

///|
impl Debug for NotificationObserver with fn to_repr(_self) {
  Repr::opaque_("NotificationObserver", Repr::literal("<appkit>"))
}

///|
type MainRunLoopObserver

///|
impl Debug for MainRunLoopObserver with fn to_repr(_self) {
  Repr::opaque_("MainRunLoopObserver", Repr::literal("<appkit>"))
}

///|
type NativeDisplayMode

///|
priv type NativeDisplayModeList

///|
priv type NativeCfObject

///|
priv type NativeObjcObject

///|
impl Eq for NativeDisplayMode with fn equal(self, other) {
  native_monitor_display_mode_identity(self) ==
  native_monitor_display_mode_identity(other)
}

///|
impl Eq for NativeDisplayMode with fn not_equal(self, other) {
  native_monitor_display_mode_identity(self) !=
  native_monitor_display_mode_identity(other)
}

///|
impl Debug for NativeDisplayMode with fn to_repr(self) {
  Repr::opaque_(
    "NativeDisplayMode",
    Repr::literal("0x" + native_monitor_display_mode_identity(self).to_string()),
  )
}

///|
impl Eq for NativeWindow with fn equal(self, other) {
  appkit_window_identity(self) == appkit_window_identity(other)
}

///|
impl Eq for NativeWindow with fn not_equal(self, other) {
  appkit_window_identity(self) != appkit_window_identity(other)
}

///|
impl Debug for NativeWindow with fn to_repr(self) {
  Repr::opaque_(
    "NativeWindow",
    Repr::literal("0x" + appkit_window_identity(self).to_string()),
  )
}

///|
extern "C" fn appkit_create_window(
  width : Int32,
  height : Int32,
) -> NativeWindow = "mbw_create_window"

///|
#borrow(window_handle)
extern "C" fn appkit_window_identity(window_handle : NativeWindow) -> UInt64 = "mbw_window_identity"

///|
#borrow(window_handle)
extern "C" fn appkit_window_objc_handle(window_handle : NativeWindow) -> UInt64 = "mbw_window_objc_handle"

///|
#borrow(window_handle)
extern "C" fn appkit_window_destroy(window_handle : NativeWindow) -> Unit = "mbw_window_destroy"

///|
#borrow(window_handle)
extern "C" fn appkit_window_mark_closing(window_handle : NativeWindow) -> Unit = "mbw_window_mark_closing"

///|
#borrow(rgba)
extern "C" fn appkit_custom_cursor_create_rgba(
  rgba : Bytes,
  rgba_len : Int32,
  width : Int32,
  height : Int32,
  hotspot_x : Int32,
  hotspot_y : Int32,
) -> @core.CustomCursorHandle = "mbw_custom_cursor_create_rgba"

///|
#borrow(cursor_handle)
extern "C" fn appkit_custom_cursor_objc_handle(
  cursor_handle : @core.CustomCursorHandle,
) -> UInt64 = "mbw_custom_cursor_objc_handle"

///|
extern "C" fn appkit_objc_msg_send_u64(
  target : UInt64,
  selector : UInt64,
) -> UInt64 = "mbw_objc_msg_send_u64"

///|
#borrow(arg0)
extern "C" fn appkit_objc_msg_send_u64_bytes(
  target : UInt64,
  selector : UInt64,
  arg0 : Bytes,
) -> UInt64 = "mbw_objc_msg_send_u64_bytes"

///|
extern "C" fn appkit_objc_msg_send_u64_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : UInt64,
) -> UInt64 = "mbw_objc_msg_send_u64_u64"

///|
extern "C" fn appkit_objc_msg_send_u64_u64_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : UInt64,
  arg1 : UInt64,
) -> UInt64 = "mbw_objc_msg_send_u64_u64_u64"

///|
extern "C" fn appkit_objc_msg_send_void(
  target : UInt64,
  selector : UInt64,
) -> Unit = "mbw_objc_msg_send_void"

///|
extern "C" fn appkit_objc_msg_send_void_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : UInt64,
) -> Unit = "mbw_objc_msg_send_void_u64"

///|
extern "C" fn appkit_objc_msg_send_void_i32(
  target : UInt64,
  selector : UInt64,
  arg0 : Int32,
) -> Unit = "mbw_objc_msg_send_void_i32"

///|
extern "C" fn appkit_objc_msg_send_void_rect_u64(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  arg1 : UInt64,
) -> Unit = "mbw_objc_msg_send_void_rect_u64"

///|
extern "C" fn appkit_objc_msg_send_void_rect_bool(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  arg1 : Bool,
) -> Unit = "mbw_objc_msg_send_void_rect_bool"

///|
extern "C" fn appkit_objc_msg_send_u64_i32_double_double_i32_u64_i32_i32_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : Int32,
  arg1 : Double,
  arg2 : Double,
  arg3 : Int32,
  arg4 : UInt64,
  arg5 : Int32,
  arg6 : Int32,
  arg7 : UInt64,
) -> UInt64 = "mbw_objc_msg_send_u64_i32_double_double_i32_u64_i32_i32_u64"

///|
extern "C" fn appkit_objc_msg_send_void_size(
  target : UInt64,
  selector : UInt64,
  width : Double,
  height : Double,
) -> Unit = "mbw_objc_msg_send_void_size"

///|
extern "C" fn appkit_objc_msg_send_void_point(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
) -> Unit = "mbw_objc_msg_send_void_point"

///|
extern "C" fn appkit_objc_msg_send_void_u64_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : UInt64,
  arg1 : UInt64,
) -> Unit = "mbw_objc_msg_send_void_u64_u64"

///|
extern "C" fn appkit_objc_msg_send_void_bool(
  target : UInt64,
  selector : UInt64,
  arg0 : Bool,
) -> Unit = "mbw_objc_msg_send_void_bool"

///|
extern "C" fn appkit_objc_msg_send_bool(
  target : UInt64,
  selector : UInt64,
) -> Bool = "mbw_objc_msg_send_bool"

///|
extern "C" fn appkit_objc_msg_send_bool_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : UInt64,
) -> Bool = "mbw_objc_msg_send_bool_u64"

///|
extern "C" fn appkit_objc_msg_send_i64(
  target : UInt64,
  selector : UInt64,
) -> Int64 = "mbw_objc_msg_send_i64"

///|
extern "C" fn appkit_objc_msg_send_double(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_double"

///|
extern "C" fn appkit_objc_msg_send_rect_x(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_rect_x"

///|
extern "C" fn appkit_objc_msg_send_rect_y(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_rect_y"

///|
extern "C" fn appkit_objc_msg_send_rect_width(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_rect_width"

///|
extern "C" fn appkit_objc_msg_send_rect_height(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_rect_height"

///|
extern "C" fn appkit_objc_msg_send_rect_x_rect(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Double = "mbw_objc_msg_send_rect_x_rect"

///|
extern "C" fn appkit_objc_msg_send_rect_y_rect(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Double = "mbw_objc_msg_send_rect_y_rect"

///|
extern "C" fn appkit_objc_msg_send_rect_height_rect(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Double = "mbw_objc_msg_send_rect_height_rect"

///|
extern "C" fn appkit_objc_msg_send_size_width(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_size_width"

///|
extern "C" fn appkit_objc_msg_send_size_height(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_size_height"

///|
extern "C" fn appkit_objc_msg_send_edge_insets_top(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_edge_insets_top"

///|
extern "C" fn appkit_objc_msg_send_edge_insets_left(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_edge_insets_left"

///|
extern "C" fn appkit_objc_msg_send_edge_insets_bottom(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_edge_insets_bottom"

///|
extern "C" fn appkit_objc_msg_send_edge_insets_right(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_edge_insets_right"

///|
#borrow(name)
extern "C" fn appkit_objc_get_class(name : Bytes) -> UInt64 = "mbw_objc_get_class"

///|
extern "C" fn appkit_objc_release_raw_object(handle : UInt64) -> Unit = "mbw_objc_release"

///|
extern "C" fn appkit_objc_wrap_owned_object(
  handle : UInt64,
) -> NativeObjcObject = "mbw_objc_wrap_owned_object"

///|
#borrow(handle)
extern "C" fn appkit_objc_owned_object_handle(
  handle : NativeObjcObject,
) -> UInt64 = "mbw_objc_owned_object_handle"

///|
#borrow(handle)
extern "C" fn appkit_objc_release_object(handle : NativeObjcObject) -> Unit = "mbw_objc_owned_object_release"

///|
#borrow(name)
extern "C" fn appkit_objc_sel_register_name(name : Bytes) -> UInt64 = "mbw_objc_sel_register_name"

///|
extern "C" fn native_monitor_find_display_mode_handle(
  monitor_id : UInt32,
  width : Int32,
  height : Int32,
  bit_depth : Int32,
  refresh_rate_millihertz : Int32,
) -> NativeDisplayMode = "mbw_find_display_mode_handle"

///|
extern "C" fn native_monitor_copy_current_display_mode_handle(
  monitor_id : UInt32,
) -> NativeDisplayMode = "mbw_copy_current_display_mode_handle"

///|
extern "C" fn native_monitor_copy_display_mode_list(
  monitor_id : UInt32,
) -> NativeDisplayModeList = "mbw_copy_display_mode_list"

///|
#borrow(mode_list)
extern "C" fn native_monitor_display_mode_list_count(
  mode_list : NativeDisplayModeList,
) -> Int32 = "mbw_display_mode_list_count"

///|
#borrow(mode_list)
extern "C" fn native_monitor_display_mode_list_mode_at(
  mode_list : NativeDisplayModeList,
  index : Int32,
) -> NativeDisplayMode = "mbw_display_mode_list_mode_at"

///|
#borrow(mode_list)
extern "C" fn native_monitor_release_display_mode_list(
  mode_list : NativeDisplayModeList,
) -> Unit = "mbw_release_display_mode_list"

///|
#borrow(mode_handle)
extern "C" fn native_monitor_display_mode_identity(
  mode_handle : NativeDisplayMode,
) -> UInt64 = "mbw_display_mode_identity"

///|
#borrow(mode_handle)
extern "C" fn native_monitor_display_mode_is_valid(
  mode_handle : NativeDisplayMode,
) -> Int32 = "mbw_display_mode_is_valid"

///|
#borrow(mode_handle)
extern "C" fn native_monitor_display_mode_width(
  mode_handle : NativeDisplayMode,
) -> Int32 = "mbw_display_mode_width"

///|
#borrow(mode_handle)
extern "C" fn native_monitor_display_mode_height(
  mode_handle : NativeDisplayMode,
) -> Int32 = "mbw_display_mode_height"

///|
#borrow(mode_handle)
extern "C" fn native_monitor_display_mode_bit_depth(
  mode_handle : NativeDisplayMode,
) -> Int32 = "mbw_display_mode_bit_depth"

///|
#borrow(mode_handle)
extern "C" fn native_monitor_display_mode_refresh_rate_millihertz(
  mode_handle : NativeDisplayMode,
) -> Int32 = "mbw_display_mode_refresh_rate_millihertz"

///|
extern "C" fn native_monitor_display_refresh_rate_millihertz(
  monitor_id : UInt32,
) -> Int32 = "mbw_display_refresh_rate_millihertz"

///|
extern "C" fn native_monitor_backing_scale_factor(
  monitor_id : UInt32,
) -> Double = "mbw_monitor_backing_scale_factor"

///|
extern "C" fn native_monitor_copy_ns_screen(
  monitor_id : UInt32,
) -> NativeObjcObject = "mbw_monitor_copy_ns_screen"

///|
#borrow(mode_handle)
extern "C" fn native_monitor_release_display_mode_handle(
  mode_handle : NativeDisplayMode,
) -> Unit = "mbw_release_display_mode_handle"

///|
extern "C" fn native_monitor_capture_display(monitor_id : UInt32) -> Int32 = "mbw_capture_display"

///|
#borrow(mode_handle)
extern "C" fn native_monitor_set_display_mode_handle(
  monitor_id : UInt32,
  mode_handle : NativeDisplayMode,
) -> Int32 = "mbw_set_display_mode_handle"

///|
extern "C" fn native_monitor_release_display_capture(
  monitor_id : UInt32,
) -> Int32 = "mbw_release_display_capture"

///|
extern "C" fn native_cg_display_create_uuid_from_display_id(
  display : UInt32,
) -> NativeCfObject = "mbw_cg_display_create_uuid_from_display_id"

///|
#borrow(handle)
extern "C" fn native_cf_object_handle(handle : NativeCfObject) -> UInt64 = "mbw_cf_object_handle"

///|
#borrow(handle)
extern "C" fn native_cf_uuid_high(handle : NativeCfObject) -> UInt64 = "mbw_cf_uuid_high"

///|
#borrow(handle)
extern "C" fn native_cf_uuid_low(handle : NativeCfObject) -> UInt64 = "mbw_cf_uuid_low"

///|
#borrow(handle)
extern "C" fn native_cf_object_release(handle : NativeCfObject) -> Unit = "mbw_cf_object_release"
