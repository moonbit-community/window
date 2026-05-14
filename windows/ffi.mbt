///|
extern "C" fn native_register_window_class() -> Int = "mbw_register_window_class"

///|
extern "C" fn native_create_msg_window() -> UInt64 = "mbw_create_msg_window"

///|
extern "C" fn native_create_window(
  width : Int,
  height : Int,
  ex_style : UInt64,
  style : UInt64,
  x : Int,
  y : Int,
  parent_hwnd : UInt64,
) -> UInt64 = "mbw_create_window"

///|
extern "C" fn native_set_window_raw_id(hwnd : UInt64, raw_id : Int) -> Unit = "mbw_set_window_raw_id"

///|
extern "C" fn native_get_window_raw_id(hwnd : UInt64) -> Int = "mbw_get_window_raw_id"

///|
extern "C" fn native_destroy_window(hwnd : UInt64) -> Unit = "mbw_destroy_window"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_window_event_callback(
  call_closure : FuncRef[
    ((Int, Int, Int, Int, Int, Double) -> Unit, Int, Int, Int, Int, Int, Double) -> Unit,
  ],
  callback : (Int, Int, Int, Int, Int, Double) -> Unit,
) -> Unit = "mbw_install_window_event_callback"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_input_event_callback(
  call_closure : FuncRef[
    ((Int, Int, UInt64, Int64) -> Unit, Int, Int, UInt64, Int64) -> Unit,
  ],
  callback : (Int, Int, UInt64, Int64) -> Unit,
) -> Unit = "mbw_install_input_event_callback"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_sync_query_callback(
  call_closure : FuncRef[((Int, Int, Int) -> Int, Int, Int, Int) -> Int],
  callback : (Int, Int, Int) -> Int,
) -> Unit = "mbw_install_sync_query_callback"

///|
extern "C" fn native_process_one_message(
  hwnd : UInt64,
  min_msg : UInt,
  max_msg : UInt,
  remove_msg : UInt,
) -> Int = "mbw_process_one_message"

///|
extern "C" fn native_wait_and_process_message(
  hwnd : UInt64,
  min_msg : UInt,
  max_msg : UInt,
) -> Int = "mbw_wait_and_process_message"

///|
extern "C" fn native_wait_timeout_and_process(timeout_ms : UInt) -> Int = "mbw_wait_timeout_and_process"

///|
#borrow(key_path)
#borrow(value_name)
extern "C" fn native_read_registry_dword_bytes(
  key_path : Bytes,
  value_name : Bytes,
) -> Bytes = "mbw_read_registry_utf8"

///|
extern "C" fn native_post_thread_message(
  thread_id : UInt,
  msg : UInt,
  wparam : UInt64,
  lparam : Int64,
) -> Int = "mbw_post_thread_message"

///|
extern "C" fn native_post_quit_message(exit_code : Int) -> Unit = "mbw_post_quit_message"

///|
extern "C" fn native_get_current_thread_id() -> UInt = "mbw_get_current_thread_id"

///|
extern "C" fn native_get_module_handle() -> UInt64 = "mbw_get_module_handle"

///|
#borrow(text)
extern "C" fn native_set_window_text(
  hwnd : UInt64,
  text : Bytes,
  text_len : Int,
) -> Int = "mbw_set_window_text"

///|
extern "C" fn native_set_window_pos(
  hwnd : UInt64,
  insert_after : UInt64,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  flags : UInt64,
) -> Int = "mbw_set_window_pos"

///|
extern "C" fn native_show_window(hwnd : UInt64, cmd : Int) -> Int = "mbw_show_window"

///|
extern "C" fn native_get_window_rect_left(hwnd : UInt64) -> Int = "mbw_get_window_rect_left"

///|
extern "C" fn native_get_window_rect_top(hwnd : UInt64) -> Int = "mbw_get_window_rect_top"

///|
extern "C" fn native_get_window_rect_right(hwnd : UInt64) -> Int = "mbw_get_window_rect_right"

///|
extern "C" fn native_get_window_rect_bottom(hwnd : UInt64) -> Int = "mbw_get_window_rect_bottom"

///|
extern "C" fn native_get_client_rect_left(hwnd : UInt64) -> Int = "mbw_get_client_rect_left"

///|
extern "C" fn native_get_client_rect_top(hwnd : UInt64) -> Int = "mbw_get_client_rect_top"

///|
extern "C" fn native_get_client_rect_right(hwnd : UInt64) -> Int = "mbw_get_client_rect_right"

///|
extern "C" fn native_get_client_rect_bottom(hwnd : UInt64) -> Int = "mbw_get_client_rect_bottom"

///|
extern "C" fn native_client_to_screen_x(hwnd : UInt64, x : Int, y : Int) -> Int = "mbw_client_to_screen_x"

///|
extern "C" fn native_client_to_screen_y(hwnd : UInt64, x : Int, y : Int) -> Int = "mbw_client_to_screen_y"

///|
extern "C" fn native_get_key_state(vk : Int) -> Int = "mbw_get_key_state"

///|
extern "C" fn native_set_window_long_ptr(
  hwnd : UInt64,
  index : Int,
  value : UInt64,
) -> UInt64 = "mbw_set_window_long_ptr"

///|
extern "C" fn native_get_window_long_ptr(hwnd : UInt64, index : Int) -> UInt64 = "mbw_get_window_long_ptr"

///|
extern "C" fn native_def_window_proc(
  hwnd : UInt64,
  msg : UInt,
  wparam : UInt64,
  lparam : Int64,
) -> UInt64 = "mbw_def_window_proc"

///|
extern "C" fn native_invalidate_rect(hwnd : UInt64, erase : Bool) -> Int = "mbw_invalidate_rect"

///|
extern "C" fn native_set_cursor(cursor : UInt64) -> UInt64 = "mbw_set_cursor"

///|
extern "C" fn native_load_cursor(
  instance : UInt64,
  cursor_name : UInt64,
) -> UInt64 = "mbw_load_cursor"

///|
extern "C" fn native_clip_cursor(
  left : Int,
  top : Int,
  right : Int,
  bottom : Int,
) -> Int = "mbw_clip_cursor"

///|
extern "C" fn native_get_cursor_pos(x : UInt64, y : UInt64) -> Int = "mbw_get_cursor_pos"

///|
extern "C" fn native_set_cursor_pos(x : Int, y : Int) -> Int = "mbw_set_cursor_pos"

///|
extern "C" fn native_enable_modern_dpi_awareness() -> Int = "mbw_enable_modern_dpi_awareness"

///|
extern "C" fn native_get_dpi_for_window(hwnd : UInt64) -> UInt = "mbw_get_dpi_for_window"

///|
extern "C" fn native_is_iconic(hwnd : UInt64) -> Int = "mbw_is_iconic"

///|
extern "C" fn native_is_zoomed(hwnd : UInt64) -> Int = "mbw_is_zoomed"

///|
extern "C" fn native_is_window_visible(hwnd : UInt64) -> Int = "mbw_is_window_visible"

///|
extern "C" fn native_get_foreground_window() -> UInt64 = "mbw_get_foreground_window"

///|
extern "C" fn native_set_foreground_window(hwnd : UInt64) -> Int = "mbw_set_foreground_window"

///|
extern "C" fn native_get_window_long_style(hwnd : UInt64) -> UInt64 = "mbw_get_window_long_style"

///|
extern "C" fn native_get_window_long_ex_style(hwnd : UInt64) -> UInt64 = "mbw_get_window_long_ex_style"

///|
extern "C" fn native_set_window_long_style(
  hwnd : UInt64,
  style : UInt64,
) -> UInt64 = "mbw_set_window_long_style"

///|
extern "C" fn native_set_window_long_ex_style(
  hwnd : UInt64,
  ex_style : UInt64,
) -> UInt64 = "mbw_set_window_long_ex_style"

///|
extern "C" fn native_adjust_window_rect_ex(
  left : UInt64,
  top : UInt64,
  right : UInt64,
  bottom : UInt64,
  style : UInt64,
  menu : Bool,
  ex_style : UInt64,
) -> Int = "mbw_adjust_window_rect_ex"

///|
extern "C" fn native_release_capture() -> Unit = "mbw_release_capture"

///|
extern "C" fn native_send_message(
  hwnd : UInt64,
  msg : UInt,
  wparam : UInt64,
  lparam : Int64,
) -> UInt64 = "mbw_send_message"

///|
extern "C" fn native_get_system_metrics(index : Int) -> Int = "mbw_get_system_metrics"

///|
extern "C" fn native_track_mouse_event(hwnd : UInt64, flags : UInt) -> Int = "mbw_track_mouse_event"

///|
extern "C" fn native_get_double_click_time() -> Double = "mbw_getDoubleClickTime"
