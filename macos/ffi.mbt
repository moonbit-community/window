///|
// Port target: winit-reference/winit-appkit/src/ffi.rs
// MoonBit adaptation:
// 1. Raw pointer-like values are represented as UInt64.
// 2. kTISPropertyUnicodeKeyLayoutData is modeled by creating a CFString key.

let application_launch_finished : Ref[Bool] = Ref::new(false)

///|
fn cg_display_create_uuid_from_display_id(display_id : UInt64) -> UInt64 {
  native_cg_display_create_uuid_from_display_id(display_id.to_uint())
}

///|
fn cg_main_display_id() -> UInt64 {
  native_cg_main_display_id().to_uint64()
}

///|
fn cg_display_model_number(display_id : UInt64) -> Int {
  native_cg_display_model_number(display_id.to_uint()).reinterpret_as_int()
}

///|
fn cg_display_pixels_wide(display_id : UInt64) -> Int {
  native_cg_display_pixels_wide(display_id.to_uint()).to_int()
}

///|
fn cg_display_pixels_high(display_id : UInt64) -> Int {
  native_cg_display_pixels_high(display_id.to_uint()).to_int()
}

///|
fn cg_display_get_display_id_from_uuid(uuid : UInt64) -> UInt64 {
  native_cg_display_get_display_id_from_uuid(uuid).to_uint64()
}

///|
fn cf_release(cf_type : UInt64) -> Unit {
  if cf_type != (0 : Int).to_uint64() {
    native_cf_release(cf_type)
  }
}

///|
fn pthread_is_main_thread() -> Bool {
  native_pthread_main_np() != 0
}

///|
fn cg_active_display_count() -> Int {
  let count = native_cg_active_display_count()
  if count < 0 {
    0
  } else {
    count
  }
}

///|
fn cg_active_display_id_at(index : Int) -> UInt64 {
  native_cg_active_display_id_at(index).to_uint64()
}

///|
fn cg_display_bounds_x(display_id : UInt64) -> Int {
  native_cg_display_bounds_x(display_id.to_uint())
}

///|
fn cg_display_bounds_y(display_id : UInt64) -> Int {
  native_cg_display_bounds_y(display_id.to_uint())
}

///|
fn cg_display_scale_factor(display_id : UInt64) -> Double {
  let factor = native_cg_display_scale_factor(display_id.to_uint())
  if factor > 0.0 {
    factor
  } else {
    1.0
  }
}

///|
fn native_main_run_loop_remove_observer(observer_handle : UInt64) -> Unit {
  if observer_handle != (0 : Int).to_uint64() {
    appkit_main_run_loop_remove_observer(observer_handle)
  }
}

///|
fn native_notification_center_remove_observer(observer_handle : UInt64) -> Unit {
  if observer_handle != (0 : Int).to_uint64() {
    appkit_notification_center_remove_observer(observer_handle)
  }
}

///|
fn native_create_window(width : Int, height : Int) -> UInt64 {
  appkit_create_window(width, height)
}

///|
fn native_custom_cursor_create_rgba(
  rgba : Bytes,
  width : Int,
  height : Int,
  hotspot_x : Int,
  hotspot_y : Int,
) -> UInt64 {
  appkit_custom_cursor_create_rgba(
    rgba,
    rgba.length(),
    width,
    height,
    hotspot_x,
    hotspot_y,
  )
}

///|
fn native_cursor_objc_handle_from_kind(cursor : Int) -> UInt64 {
  let ns_cursor_class = objc_runtime_class_handle("NSCursor")
  if ns_cursor_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let selector_name = if cursor == 10 {
    "openHandCursor"
  } else if cursor == 11 {
    "closedHandCursor"
  } else if cursor == 12 || cursor == 19 || cursor == 20 || cursor == 24 {
    "resizeLeftRightCursor"
  } else if cursor == 13 || cursor == 16 || cursor == 21 || cursor == 25 {
    "resizeUpDownCursor"
  } else if cursor == 29 {
    "pointingHandCursor"
  } else if cursor == 30 {
    "IBeamCursor"
  } else if cursor == 31 {
    "crosshairCursor"
  } else if cursor == 33 {
    "operationNotAllowedCursor"
  } else {
    "arrowCursor"
  }
  appkit_objc_msg_send_u64(
    ns_cursor_class,
    objc_runtime_selector_handle(selector_name),
  )
}

///|
fn native_find_display_mode_handle(
  monitor_id : UInt64,
  width : Int,
  height : Int,
  bit_depth : Int,
  refresh_rate_millihertz : Int,
) -> UInt64 {
  native_monitor_find_display_mode_handle(
    monitor_id.to_uint(),
    width,
    height,
    bit_depth,
    refresh_rate_millihertz,
  )
}

///|
fn native_copy_current_display_mode_handle(monitor_id : UInt64) -> UInt64 {
  native_monitor_copy_current_display_mode_handle(monitor_id.to_uint())
}

///|
fn native_copy_display_mode_count(monitor_id : UInt64) -> Int {
  let count = native_monitor_copy_display_mode_count(monitor_id.to_uint())
  if count > 0 {
    count
  } else {
    0
  }
}

///|
fn native_copy_display_mode_handle_at(
  monitor_id : UInt64,
  index : Int,
) -> UInt64 {
  native_monitor_copy_display_mode_handle_at(monitor_id.to_uint(), index)
}

///|
fn native_display_mode_width(mode_handle : UInt64) -> Int {
  let width = native_monitor_display_mode_width(mode_handle)
  if width > 0 {
    width
  } else {
    0
  }
}

///|
fn native_display_mode_height(mode_handle : UInt64) -> Int {
  let height = native_monitor_display_mode_height(mode_handle)
  if height > 0 {
    height
  } else {
    0
  }
}

///|
fn native_display_mode_bit_depth(mode_handle : UInt64) -> Int {
  let bit_depth = native_monitor_display_mode_bit_depth(mode_handle)
  if bit_depth > 0 {
    bit_depth
  } else {
    0
  }
}

///|
fn native_display_mode_refresh_rate_millihertz(mode_handle : UInt64) -> Int {
  let refresh_rate_millihertz = native_monitor_display_mode_refresh_rate_millihertz(
    mode_handle,
  )
  if refresh_rate_millihertz > 0 {
    refresh_rate_millihertz
  } else {
    0
  }
}

///|
fn ffi_normalize_display_id(display_id : UInt64) -> UInt64 {
  if display_id == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let uuid = cg_display_create_uuid_from_display_id(display_id)
  if uuid == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let normalized = cg_display_get_display_id_from_uuid(uuid)
  cf_release(uuid)
  normalized
}

///|
fn native_monitor_ns_screen(monitor_id : UInt64) -> UInt64 {
  if monitor_id == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let normalized_monitor_id = ffi_normalize_display_id(monitor_id)
  if normalized_monitor_id == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let ns_screen_class = objc_runtime_class_handle("NSScreen")
  if ns_screen_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let screens = appkit_objc_msg_send_u64(
    ns_screen_class,
    objc_runtime_selector_handle("screens"),
  )
  if screens == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let count = appkit_objc_msg_send_i64(
    screens,
    objc_runtime_selector_handle("count"),
  ).to_int()
  if count <= 0 {
    return (0 : Int).to_uint64()
  }
  let key = objc_nsstring_from_string("NSScreenNumber")
  if key == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let object_at_index = objc_runtime_selector_handle("objectAtIndex:")
  let device_description = objc_runtime_selector_handle("deviceDescription")
  let object_for_key = objc_runtime_selector_handle("objectForKey:")
  let unsigned_int_value = objc_runtime_selector_handle("unsignedIntValue")
  let mut index = 0
  while index < count {
    let screen = appkit_objc_msg_send_u64_u64(
      screens,
      object_at_index,
      index.to_uint64(),
    )
    if screen != (0 : Int).to_uint64() {
      let description = appkit_objc_msg_send_u64(screen, device_description)
      if description != (0 : Int).to_uint64() {
        let number = appkit_objc_msg_send_u64_u64(
          description, object_for_key, key,
        )
        if number != (0 : Int).to_uint64() {
          let screen_display_id = appkit_objc_msg_send_u64(
            number, unsigned_int_value,
          )
          let normalized_screen_id = ffi_normalize_display_id(screen_display_id)
          if normalized_screen_id == normalized_monitor_id {
            return screen
          }
        }
      }
    }
    index = index + 1
  }
  (0 : Int).to_uint64()
}

///|
fn native_display_refresh_rate_millihertz(monitor_id : UInt64) -> Int {
  let maximum_frames_per_second = objc_runtime_selector_handle(
    "maximumFramesPerSecond",
  )
  let mut screen = native_monitor_ns_screen(monitor_id)
  if screen == (0 : Int).to_uint64() {
    let ns_screen_class = objc_runtime_class_handle("NSScreen")
    if ns_screen_class == (0 : Int).to_uint64() {
      return 0
    }
    screen = appkit_objc_msg_send_u64(
      ns_screen_class,
      objc_runtime_selector_handle("mainScreen"),
    )
  }
  if screen == (0 : Int).to_uint64() ||
    appkit_objc_msg_send_bool_u64(
      screen,
      objc_runtime_selector_handle("respondsToSelector:"),
      maximum_frames_per_second,
    ) ==
    false {
    return 0
  }
  let frames_per_second = appkit_objc_msg_send_i64(
    screen, maximum_frames_per_second,
  ).to_int()
  if frames_per_second <= 0 {
    return 0
  }
  if frames_per_second > 2_147_483 {
    2_147_483_647
  } else {
    frames_per_second * 1000
  }
}

///|
fn native_release_display_mode_handle(mode_handle : UInt64) -> Unit {
  native_monitor_release_display_mode_handle(mode_handle)
}

///|
fn native_capture_display(monitor_id : UInt64) -> Bool {
  native_monitor_capture_display(monitor_id.to_uint()) != 0
}

///|
fn native_set_display_mode_handle(
  monitor_id : UInt64,
  mode_handle : UInt64,
) -> Bool {
  native_monitor_set_display_mode_handle(monitor_id.to_uint(), mode_handle) != 0
}

///|
fn native_release_display_capture(monitor_id : UInt64) -> Bool {
  native_monitor_release_display_capture(monitor_id.to_uint()) != 0
}

///|
fn objc_runtime_class_handle(name : String) -> UInt64 {
  appkit_objc_get_class(@utf8.encode(name[:], bom=false))
}

///|
fn objc_runtime_selector_handle(name : String) -> UInt64 {
  appkit_objc_sel_register_name(@utf8.encode(name[:], bom=false))
}

///|
fn native_application_shared_handle() -> UInt64 {
  let app_class = objc_runtime_class_handle("NSApplication")
  if app_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(
    app_class,
    objc_runtime_selector_handle("sharedApplication"),
  )
}

///|
fn native_window_objc_handle(handle : UInt64) -> UInt64 {
  if handle == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let window_or_self = appkit_objc_msg_send_u64(
    handle,
    objc_runtime_selector_handle("window"),
  )
  if window_or_self == (0 : Int).to_uint64() {
    handle
  } else {
    window_or_self
  }
}

///|
fn native_window_content_view_objc_handle(handle : UInt64) -> UInt64 {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(window, objc_runtime_selector_handle("contentView"))
}

///|
fn native_window_delegate_objc_handle(handle : UInt64) -> UInt64 {
  let window = native_window_objc_handle(handle)
  if window == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(window, objc_runtime_selector_handle("delegate"))
}

///|
fn objc_utf8_bytes_from_object(handle : UInt64) -> Bytes {
  if handle == (0 : Int).to_uint64() {
    return b""
  }
  native_objc_copy_utf8_bytes(handle)
}

///|
fn objc_nsstring_from_string(value : String) -> UInt64 {
  let ns_string = objc_runtime_class_handle("NSString")
  if ns_string == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64_bytes(
    ns_string,
    objc_runtime_selector_handle("stringWithUTF8String:"),
    @utf8.encode(value[:], bom=false),
  )
}

///|
fn objc_theme_from_appearance_handle(appearance : UInt64) -> Int {
  if appearance == (0 : Int).to_uint64() {
    return 0
  }
  let name_handle = appkit_objc_msg_send_u64(
    appearance,
    objc_runtime_selector_handle("name"),
  )
  if name_handle == (0 : Int).to_uint64() {
    return 0
  }
  let name = @utf8.decode_lossy(
    objc_utf8_bytes_from_object(name_handle)[:],
    ignore_bom=false,
  )
  if name == "NSAppearanceNameDarkAqua" ||
    name == "NSAppearanceNameVibrantDark" ||
    name == "NSAppearanceNameAccessibilityHighContrastDarkAqua" {
    2
  } else if name == "NSAppearanceNameAqua" ||
    name == "NSAppearanceNameVibrantLight" ||
    name == "NSAppearanceNameAccessibilityHighContrastAqua" {
    1
  } else {
    0
  }
}

///|
fn native_application_presentation_options() -> UInt64 {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  appkit_objc_msg_send_u64(
    app,
    objc_runtime_selector_handle("presentationOptions"),
  )
}

///|
fn native_set_application_presentation_options(options : UInt64) -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("setPresentationOptions:"),
    options,
  )
}

///|
fn native_application_hide() -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("hide:"),
    (0 : Int).to_uint64(),
  )
}

///|
fn native_application_hide_other_applications() -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("hideOtherApplications:"),
    (0 : Int).to_uint64(),
  )
}

///|
fn native_application_set_allows_automatic_window_tabbing(
  enabled : Bool,
) -> Unit {
  let window_class = objc_runtime_class_handle("NSWindow")
  if window_class == (0 : Int).to_uint64() {
    return ()
  }
  let responds_to_selector = objc_runtime_selector_handle("respondsToSelector:")
  let setter = objc_runtime_selector_handle("setAllowsAutomaticWindowTabbing:")
  if appkit_objc_msg_send_bool_u64(window_class, responds_to_selector, setter) {
    appkit_objc_msg_send_void_bool(window_class, setter, enabled)
  }
}

///|
fn native_application_allows_automatic_window_tabbing() -> Bool {
  let window_class = objc_runtime_class_handle("NSWindow")
  if window_class == (0 : Int).to_uint64() {
    return false
  }
  let responds_to_selector = objc_runtime_selector_handle("respondsToSelector:")
  let getter = objc_runtime_selector_handle("allowsAutomaticWindowTabbing")
  if appkit_objc_msg_send_bool_u64(window_class, responds_to_selector, getter) ==
    false {
    return false
  }
  appkit_objc_msg_send_bool(window_class, getter)
}

///|
fn native_application_is_bundled() -> Bool {
  let running_application_class = objc_runtime_class_handle(
    "NSRunningApplication",
  )
  if running_application_class == (0 : Int).to_uint64() {
    return false
  }
  let app = appkit_objc_msg_send_u64(
    running_application_class,
    objc_runtime_selector_handle("currentApplication"),
  )
  if app == (0 : Int).to_uint64() {
    return false
  }
  appkit_objc_msg_send_u64(
    app,
    objc_runtime_selector_handle("bundleIdentifier"),
  ) !=
  (0 : Int).to_uint64()
}

///|
fn native_application_set_activation_policy(activation_policy : Int) -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  let policy = if activation_policy < 0 { 0 } else { activation_policy }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("setActivationPolicy:"),
    policy.to_uint64(),
  )
}

///|
fn native_application_set_activate_ignoring_other_apps(
  activate_ignoring_other_apps : Bool,
) -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_bool(
    app,
    objc_runtime_selector_handle("activateIgnoringOtherApps:"),
    activate_ignoring_other_apps,
  )
}

///|
fn native_application_theme() -> Int {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return 0
  }
  let appearance = appkit_objc_msg_send_u64(
    app,
    objc_runtime_selector_handle("effectiveAppearance"),
  )
  objc_theme_from_appearance_handle(appearance)
}

///|
fn native_application_close_all_windows() -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  let windows = appkit_objc_msg_send_u64(
    app,
    objc_runtime_selector_handle("windows"),
  )
  if windows == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    windows,
    objc_runtime_selector_handle("makeObjectsPerformSelector:"),
    objc_runtime_selector_handle("close"),
  )
}

///|
fn native_appkit_new_menu(title : String) -> UInt64 {
  let ns_menu_class = objc_runtime_class_handle("NSMenu")
  if ns_menu_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let menu_alloc = appkit_objc_msg_send_u64(
    ns_menu_class,
    objc_runtime_selector_handle("alloc"),
  )
  if menu_alloc == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let title_handle = objc_nsstring_from_string(title)
  if title_handle == (0 : Int).to_uint64() {
    appkit_objc_release_object(menu_alloc)
    return (0 : Int).to_uint64()
  }
  let menu = appkit_objc_msg_send_u64_u64(
    menu_alloc,
    objc_runtime_selector_handle("initWithTitle:"),
    title_handle,
  )
  if menu == (0 : Int).to_uint64() {
    appkit_objc_release_object(menu_alloc)
  }
  menu
}

///|
fn native_appkit_new_menu_item(
  title : String,
  action_selector_name : String,
  key_equivalent : String,
  target : UInt64,
  key_modifier_mask : Int,
) -> UInt64 {
  let ns_menu_item_class = objc_runtime_class_handle("NSMenuItem")
  if ns_menu_item_class == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let item_alloc = appkit_objc_msg_send_u64(
    ns_menu_item_class,
    objc_runtime_selector_handle("alloc"),
  )
  if item_alloc == (0 : Int).to_uint64() {
    return (0 : Int).to_uint64()
  }
  let item = appkit_objc_msg_send_u64(
    item_alloc,
    objc_runtime_selector_handle("init"),
  )
  if item == (0 : Int).to_uint64() {
    appkit_objc_release_object(item_alloc)
    return (0 : Int).to_uint64()
  }
  let title_handle = objc_nsstring_from_string(title)
  if title_handle != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_u64(
      item,
      objc_runtime_selector_handle("setTitle:"),
      title_handle,
    )
  }
  if action_selector_name != "" {
    appkit_objc_msg_send_void_u64(
      item,
      objc_runtime_selector_handle("setAction:"),
      objc_runtime_selector_handle(action_selector_name),
    )
  }
  let key_handle = objc_nsstring_from_string(key_equivalent)
  if key_handle != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_u64(
      item,
      objc_runtime_selector_handle("setKeyEquivalent:"),
      key_handle,
    )
  }
  if target != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_u64(
      item,
      objc_runtime_selector_handle("setTarget:"),
      target,
    )
  }
  if key_modifier_mask >= 0 {
    appkit_objc_msg_send_void_u64(
      item,
      objc_runtime_selector_handle("setKeyEquivalentModifierMask:"),
      key_modifier_mask.to_uint64(),
    )
  }
  item
}

///|
fn native_appkit_add_menu_item(menu : UInt64, item : UInt64) -> Unit {
  if menu == (0 : Int).to_uint64() || item == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    menu,
    objc_runtime_selector_handle("addItem:"),
    item,
  )
}

///|
fn native_appkit_add_separator_item(menu : UInt64) -> Unit {
  if menu == (0 : Int).to_uint64() {
    return ()
  }
  let ns_menu_item_class = objc_runtime_class_handle("NSMenuItem")
  if ns_menu_item_class == (0 : Int).to_uint64() {
    return ()
  }
  let separator = appkit_objc_msg_send_u64(
    ns_menu_item_class,
    objc_runtime_selector_handle("separatorItem"),
  )
  native_appkit_add_menu_item(menu, separator)
}

///|
fn native_application_initialize_default_menu(enabled : Bool) -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  if !enabled {
    appkit_objc_msg_send_void_u64(
      app,
      objc_runtime_selector_handle("setMainMenu:"),
      (0 : Int).to_uint64(),
    )
    return ()
  }
  let process_info_class = objc_runtime_class_handle("NSProcessInfo")
  let process_info = if process_info_class == (0 : Int).to_uint64() {
    (0 : Int).to_uint64()
  } else {
    appkit_objc_msg_send_u64(
      process_info_class,
      objc_runtime_selector_handle("processInfo"),
    )
  }
  let process_name_handle = if process_info == (0 : Int).to_uint64() {
    (0 : Int).to_uint64()
  } else {
    appkit_objc_msg_send_u64(
      process_info,
      objc_runtime_selector_handle("processName"),
    )
  }
  let process_name = @utf8.decode(
    objc_utf8_bytes_from_object(process_name_handle)[:],
    ignore_bom=false,
  ) catch {
    _ => ""
  }
  let app_name = if process_name == "" { "Application" } else { process_name }
  let main_menu = native_appkit_new_menu("")
  if main_menu == (0 : Int).to_uint64() {
    return ()
  }
  let app_menu_item = native_appkit_new_menu_item(
    "",
    "",
    "",
    (0 : Int).to_uint64(),
    -1,
  )
  let app_menu = native_appkit_new_menu("")
  if app_menu_item != (0 : Int).to_uint64() {
    native_appkit_add_menu_item(main_menu, app_menu_item)
    if app_menu != (0 : Int).to_uint64() {
      appkit_objc_msg_send_void_u64(
        app_menu_item,
        objc_runtime_selector_handle("setSubmenu:"),
        app_menu,
      )
    }
  }
  if app_menu != (0 : Int).to_uint64() {
    let about_item = native_appkit_new_menu_item(
      "About " + app_name,
      "orderFrontStandardAboutPanel:",
      "",
      app,
      -1,
    )
    if about_item != (0 : Int).to_uint64() {
      native_appkit_add_menu_item(app_menu, about_item)
      appkit_objc_release_object(about_item)
    }
    native_appkit_add_separator_item(app_menu)
    let services_item = native_appkit_new_menu_item(
      "Services",
      "",
      "",
      (0 : Int).to_uint64(),
      -1,
    )
    let services_menu = native_appkit_new_menu("Services")
    if services_menu != (0 : Int).to_uint64() {
      appkit_objc_msg_send_void_u64(
        app,
        objc_runtime_selector_handle("setServicesMenu:"),
        services_menu,
      )
      if services_item != (0 : Int).to_uint64() {
        appkit_objc_msg_send_void_u64(
          services_item,
          objc_runtime_selector_handle("setSubmenu:"),
          services_menu,
        )
      }
      appkit_objc_release_object(services_menu)
    }
    if services_item != (0 : Int).to_uint64() {
      native_appkit_add_menu_item(app_menu, services_item)
      appkit_objc_release_object(services_item)
    }
    let hide_item = native_appkit_new_menu_item(
      "Hide " + app_name,
      "hide:",
      "h",
      app,
      -1,
    )
    if hide_item != (0 : Int).to_uint64() {
      native_appkit_add_menu_item(app_menu, hide_item)
      appkit_objc_release_object(hide_item)
    }
    let option_command_modifier_mask = 524288 + 1_048_576
    let hide_others_item = native_appkit_new_menu_item(
      "Hide Others", "hideOtherApplications:", "h", app, option_command_modifier_mask,
    )
    if hide_others_item != (0 : Int).to_uint64() {
      native_appkit_add_menu_item(app_menu, hide_others_item)
      appkit_objc_release_object(hide_others_item)
    }
    let show_all_item = native_appkit_new_menu_item(
      "Show All", "unhideAllApplications:", "", app, -1,
    )
    if show_all_item != (0 : Int).to_uint64() {
      native_appkit_add_menu_item(app_menu, show_all_item)
      appkit_objc_release_object(show_all_item)
    }
    native_appkit_add_separator_item(app_menu)
    let quit_item = native_appkit_new_menu_item(
      "Quit " + app_name,
      "terminate:",
      "q",
      app,
      -1,
    )
    if quit_item != (0 : Int).to_uint64() {
      native_appkit_add_menu_item(app_menu, quit_item)
      appkit_objc_release_object(quit_item)
    }
  }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("setMainMenu:"),
    main_menu,
  )
  if app_menu != (0 : Int).to_uint64() {
    appkit_objc_release_object(app_menu)
  }
  if app_menu_item != (0 : Int).to_uint64() {
    appkit_objc_release_object(app_menu_item)
  }
  appkit_objc_release_object(main_menu)
}

///|
fn native_post_application_defined_event(at_start : Bool) -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  let ns_event_class = objc_runtime_class_handle("NSEvent")
  if ns_event_class == (0 : Int).to_uint64() {
    return ()
  }
  // NSEventTypeApplicationDefined = 15.
  let event = appkit_objc_msg_send_u64_i32_double_double_i32_u64_i32_i32_u64(
    ns_event_class,
    objc_runtime_selector_handle(
      "otherEventWithType:location:modifierFlags:timestamp:windowNumber:context:subtype:data1:data2:",
    ),
    15,
    0.0,
    0.0,
    0,
    (0 : Int).to_uint64(),
    0,
    0,
    (0 : Int).to_uint64(),
  )
  if event == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64_u64(
    app,
    objc_runtime_selector_handle("postEvent:atStart:"),
    event,
    if at_start {
      (1 : Int).to_uint64()
    } else {
      (0 : Int).to_uint64()
    },
  )
}

///|
fn native_application_run() -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  if !application_launch_finished.val {
    appkit_objc_msg_send_void(
      app,
      objc_runtime_selector_handle("finishLaunching"),
    )
    application_launch_finished.val = true
  }
  appkit_objc_msg_send_void(app, objc_runtime_selector_handle("run"))
}

///|
fn native_application_stop_immediately() -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }
  if !application_launch_finished.val {
    appkit_objc_msg_send_void(
      app,
      objc_runtime_selector_handle("finishLaunching"),
    )
    application_launch_finished.val = true
  }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("stop:"),
    (0 : Int).to_uint64(),
  )
  native_post_application_defined_event(true)
}

///|
extern "C" fn native_cg_display_create_uuid_from_display_id(
  display : UInt,
) -> UInt64 = "CGDisplayCreateUUIDFromDisplayID"

///|
extern "C" fn native_cf_absolute_time_get_current() -> Double = "CFAbsoluteTimeGetCurrent"

///|
extern "C" fn native_cgfloat_max() -> Double = "mbw_cgfloat_max"

///|
extern "C" fn native_cg_associate_mouse_and_mouse_cursor_position(
  connected : Bool,
) -> Int = "CGAssociateMouseAndMouseCursorPosition"

///|
extern "C" fn native_cg_warp_mouse_cursor_position(
  x : Double,
  y : Double,
) -> Bool = "mbw_cg_warp_mouse_cursor_position"

///|
extern "C" fn native_cgs_set_window_background_blur_radius(
  window_number : Int,
  radius : Int,
) -> Bool = "mbw_cgs_set_window_background_blur_radius"

///|
extern "C" fn native_appkit_window_level(kind : Int) -> UInt64 = "mbw_appkit_window_level"

///|
extern "C" fn native_cg_main_display_id() -> UInt = "CGMainDisplayID"

///|
extern "C" fn native_cg_display_model_number(display : UInt) -> UInt = "CGDisplayModelNumber"

///|
extern "C" fn native_cg_display_pixels_wide(display : UInt) -> UInt64 = "CGDisplayPixelsWide"

///|
extern "C" fn native_cg_display_pixels_high(display : UInt) -> UInt64 = "CGDisplayPixelsHigh"

///|
extern "C" fn native_cg_display_get_display_id_from_uuid(uuid : UInt64) -> UInt = "CGDisplayGetDisplayIDFromUUID"

///|
extern "C" fn native_cf_release(cf_type : UInt64) -> Unit = "CFRelease"

///|
extern "C" fn native_pthread_main_np() -> Int = "pthread_main_np"

///|
extern "C" fn native_cg_active_display_count() -> Int = "mbw_cg_active_display_count"

///|
extern "C" fn native_cg_active_display_id_at(index : Int) -> UInt = "mbw_cg_active_display_id_at"

///|
extern "C" fn native_cg_display_bounds_x(display : UInt) -> Int = "mbw_cg_display_bounds_x"

///|
extern "C" fn native_cg_display_bounds_y(display : UInt) -> Int = "mbw_cg_display_bounds_y"

///|
extern "C" fn native_cg_display_scale_factor(display : UInt) -> Double = "mbw_cg_display_scale_factor"

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
extern "C" fn native_notification_center_add_observer(
  call_closure : FuncRef[((Int) -> Unit, Int) -> Unit],
  callback : (Int) -> Unit,
  notification_kind : Int,
  callback_kind : Int,
) -> UInt64 = "mbw_notification_center_add_observer"

///|
extern "C" fn appkit_notification_center_remove_observer(
  observer_handle : UInt64,
) -> Unit = "mbw_notification_center_remove_observer"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_main_run_loop_add_observer(
  call_closure : FuncRef[((Int) -> Unit, Int) -> Unit],
  callback : (Int) -> Unit,
  activity_kind : Int,
  callback_kind : Int,
  order : Int,
) -> UInt64 = "mbw_main_run_loop_add_observer"

///|
extern "C" fn appkit_main_run_loop_remove_observer(
  observer_handle : UInt64,
) -> Unit = "mbw_main_run_loop_remove_observer"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_input_event_callback(
  call_closure : FuncRef[((Int, Int, UInt64) -> Unit, Int, Int, UInt64) -> Unit],
  callback : (Int, Int, UInt64) -> Unit,
) -> Unit = "mbw_install_input_event_callback"

///|
extern "C" fn native_objc_copy_utf8_bytes(object_handle : UInt64) -> Bytes = "mbw_objc_copy_utf8_bytes"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_text_input_event_callback(
  call_closure : FuncRef[
    (
      (Int, Int, UInt64, Int, UInt64, Int, Int, UInt64) -> Unit,
      Int,
      Int,
      UInt64,
      Int,
      UInt64,
      Int,
      Int,
      UInt64,
    ) -> Unit,
  ],
  callback : (Int, Int, UInt64, Int, UInt64, Int, Int, UInt64) -> Unit,
) -> Unit = "mbw_install_text_input_event_callback"

///|
#borrow(call_closure)
#owned(callback)
extern "C" fn native_install_device_event_callback(
  call_closure : FuncRef[((UInt64) -> Unit, UInt64) -> Unit],
  callback : (UInt64) -> Unit,
) -> Unit = "mbw_install_device_event_callback"

///|
extern "C" fn native_override_send_event() -> Unit = "mbw_override_send_event"

///|
extern "C" fn appkit_create_window(width : Int, height : Int) -> UInt64 = "mbw_create_window"

///|
#borrow(rgba)
extern "C" fn appkit_custom_cursor_create_rgba(
  rgba : Bytes,
  rgba_len : Int,
  width : Int,
  height : Int,
  hotspot_x : Int,
  hotspot_y : Int,
) -> UInt64 = "mbw_custom_cursor_create_rgba"

///|
fn native_event_loop_wake_up_appkit() -> Unit {
  native_post_application_defined_event(false)
}

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
  arg0 : Int,
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
extern "C" fn appkit_objc_msg_send_void_i32_u64_i32_u64_i32_i32_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : Int,
  arg1 : UInt64,
  arg2 : Int,
  arg3 : UInt64,
  arg4 : Int,
  arg5 : Int,
  arg6 : UInt64,
) -> Unit = "mbw_objc_msg_send_void_i32_u64_i32_u64_i32_i32_u64"

///|
extern "C" fn appkit_objc_msg_send_u64_i32_double_double_i32_u64_i32_i32_u64(
  target : UInt64,
  selector : UInt64,
  arg0 : Int,
  arg1 : Double,
  arg2 : Double,
  arg3 : Int,
  arg4 : UInt64,
  arg5 : Int,
  arg6 : Int,
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
extern "C" fn appkit_objc_msg_send_point_x(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_point_x"

///|
extern "C" fn appkit_objc_msg_send_point_y(
  target : UInt64,
  selector : UInt64,
) -> Double = "mbw_objc_msg_send_point_y"

///|
extern "C" fn appkit_objc_msg_send_point_x_point_u64(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  arg1 : UInt64,
) -> Double = "mbw_objc_msg_send_point_x_point_u64"

///|
extern "C" fn appkit_objc_msg_send_point_y_point_u64(
  target : UInt64,
  selector : UInt64,
  x : Double,
  y : Double,
  arg1 : UInt64,
) -> Double = "mbw_objc_msg_send_point_y_point_u64"

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
extern "C" fn appkit_objc_release_object(handle : UInt64) -> Unit = "mbw_objc_release"

///|
#borrow(name)
extern "C" fn appkit_objc_sel_register_name(name : Bytes) -> UInt64 = "mbw_objc_sel_register_name"

///|
extern "C" fn native_monitor_find_display_mode_handle(
  monitor_id : UInt,
  width : Int,
  height : Int,
  bit_depth : Int,
  refresh_rate_millihertz : Int,
) -> UInt64 = "mbw_find_display_mode_handle"

///|
extern "C" fn native_monitor_copy_current_display_mode_handle(
  monitor_id : UInt,
) -> UInt64 = "mbw_copy_current_display_mode_handle"

///|
extern "C" fn native_monitor_copy_display_mode_count(monitor_id : UInt) -> Int = "mbw_copy_display_mode_count"

///|
extern "C" fn native_monitor_copy_display_mode_handle_at(
  monitor_id : UInt,
  index : Int,
) -> UInt64 = "mbw_copy_display_mode_handle_at"

///|
extern "C" fn native_monitor_display_mode_width(mode_handle : UInt64) -> Int = "mbw_display_mode_width"

///|
extern "C" fn native_monitor_display_mode_height(mode_handle : UInt64) -> Int = "mbw_display_mode_height"

///|
extern "C" fn native_monitor_display_mode_bit_depth(
  mode_handle : UInt64,
) -> Int = "mbw_display_mode_bit_depth"

///|
extern "C" fn native_monitor_display_mode_refresh_rate_millihertz(
  mode_handle : UInt64,
) -> Int = "mbw_display_mode_refresh_rate_millihertz"

///|
extern "C" fn native_monitor_release_display_mode_handle(
  mode_handle : UInt64,
) -> Unit = "mbw_release_display_mode_handle"

///|
extern "C" fn native_monitor_capture_display(monitor_id : UInt) -> Int = "mbw_capture_display"

///|
extern "C" fn native_monitor_set_display_mode_handle(
  monitor_id : UInt,
  mode_handle : UInt64,
) -> Int = "mbw_set_display_mode_handle"

///|
extern "C" fn native_monitor_release_display_capture(monitor_id : UInt) -> Int = "mbw_release_display_capture"
