///|
// Port target: winit-reference/winit-appkit/src/menu.rs

///|
pub(all) enum MenuAction {
  About
  Services
  Hide
  HideOthers
  ShowAll
  Quit
  Separator
} derive(Eq, Debug)

///|
pub(all) struct KeyEquivalent {
  key : String
  masks : Int?
} derive(Eq, Debug)

///|
pub(all) struct MenuItemDescriptor {
  title : String
  action : MenuAction
  key_equivalent : KeyEquivalent?
} derive(Eq, Debug)

///|
fn menu_item_descriptor(
  title : String,
  action : MenuAction,
  key_equivalent : KeyEquivalent?,
) -> MenuItemDescriptor {
  { title, action, key_equivalent }
}

///|
// Port target: menu.rs::menu_item
fn menu_item(
  title : String,
  action : MenuAction,
  key_equivalent : KeyEquivalent?,
) -> MenuItemDescriptor {
  menu_item_descriptor(title, action, key_equivalent)
}

///|
fn default_menu_process_name() -> String {
  "Application"
}

///|
fn default_menu_descriptors(process_name : String) -> Array[MenuItemDescriptor] {
  [
    menu_item("About " + process_name, About, None),
    menu_item("", Separator, None),
    menu_item("Services", Services, None),
    menu_item("Hide " + process_name, Hide, Some({ key: "h", masks: None })),
    menu_item("Hide Others", HideOthers, Some({ key: "h", masks: Some(3) })),
    menu_item("Show All", ShowAll, None),
    menu_item("", Separator, None),
    menu_item("Quit " + process_name, Quit, Some({ key: "q", masks: None })),
  ]
}

///|
// Port target: menu.rs::initialize
fn initialize(default_menu : Bool) -> Unit {
  initialize_default_menu(default_menu)
}

///|
let default_menu_initialized : Ref[Bool] = Ref(false)

///|
fn native_appkit_new_menu(title : String) -> NativeObjcObject {
  let ns_menu_class = objc_runtime_class_handle("NSMenu")
  if ns_menu_class == (0 : Int).to_uint64() {
    return native_objc_owned_null()
  }
  let menu_alloc = appkit_objc_msg_send_u64(
    ns_menu_class,
    objc_runtime_selector_handle("alloc"),
  )
  if menu_alloc == (0 : Int).to_uint64() {
    return native_objc_owned_null()
  }
  let title_handle = objc_nsstring_from_string(title)
  if title_handle == (0 : Int).to_uint64() {
    appkit_objc_release_raw_object(menu_alloc)
    return native_objc_owned_null()
  }
  let menu = appkit_objc_msg_send_u64_u64(
    menu_alloc,
    objc_runtime_selector_handle("initWithTitle:"),
    title_handle,
  )
  if menu == (0 : Int).to_uint64() {
    appkit_objc_release_raw_object(menu_alloc)
  }
  appkit_objc_wrap_owned_object(menu)
}

///|
fn native_appkit_new_menu_item(
  title : String,
  action_selector_name : String,
  key_equivalent : String,
  target : UInt64,
  key_modifier_mask : Int,
) -> NativeObjcObject {
  let ns_menu_item_class = objc_runtime_class_handle("NSMenuItem")
  if ns_menu_item_class == (0 : Int).to_uint64() {
    return native_objc_owned_null()
  }
  let item_alloc = appkit_objc_msg_send_u64(
    ns_menu_item_class,
    objc_runtime_selector_handle("alloc"),
  )
  if item_alloc == (0 : Int).to_uint64() {
    return native_objc_owned_null()
  }
  let item = appkit_objc_msg_send_u64(
    item_alloc,
    objc_runtime_selector_handle("init"),
  )
  if item == (0 : Int).to_uint64() {
    appkit_objc_release_raw_object(item_alloc)
    return native_objc_owned_null()
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
  appkit_objc_wrap_owned_object(item)
}

///|
fn native_appkit_add_menu_item(
  menu : NativeObjcObject,
  item : NativeObjcObject,
) -> Unit {
  let menu_raw = native_objc_owned_handle(menu)
  let item_raw = native_objc_owned_handle(item)
  if menu_raw == (0 : Int).to_uint64() || item_raw == (0 : Int).to_uint64() {
    return ()
  }
  appkit_objc_msg_send_void_u64(
    menu_raw,
    objc_runtime_selector_handle("addItem:"),
    item_raw,
  )
}

///|
fn native_appkit_add_separator_item(menu : NativeObjcObject) -> Unit {
  let menu_raw = native_objc_owned_handle(menu)
  if menu_raw == (0 : Int).to_uint64() {
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
  if separator != (0 : Int).to_uint64() {
    appkit_objc_msg_send_void_u64(
      menu_raw,
      objc_runtime_selector_handle("addItem:"),
      separator,
    )
  }
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
  if native_objc_owned_valid(main_menu) == false {
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
  if native_objc_owned_valid(app_menu_item) {
    native_appkit_add_menu_item(main_menu, app_menu_item)
    if native_objc_owned_valid(app_menu) {
      appkit_objc_msg_send_void_u64(
        native_objc_owned_handle(app_menu_item),
        objc_runtime_selector_handle("setSubmenu:"),
        native_objc_owned_handle(app_menu),
      )
    }
  }
  if native_objc_owned_valid(app_menu) {
    let about_item = native_appkit_new_menu_item(
      "About " + app_name,
      "orderFrontStandardAboutPanel:",
      "",
      app,
      -1,
    )
    if native_objc_owned_valid(about_item) {
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
    if native_objc_owned_valid(services_menu) {
      appkit_objc_msg_send_void_u64(
        app,
        objc_runtime_selector_handle("setServicesMenu:"),
        native_objc_owned_handle(services_menu),
      )
      if native_objc_owned_valid(services_item) {
        appkit_objc_msg_send_void_u64(
          native_objc_owned_handle(services_item),
          objc_runtime_selector_handle("setSubmenu:"),
          native_objc_owned_handle(services_menu),
        )
      }
      appkit_objc_release_object(services_menu)
    }
    if native_objc_owned_valid(services_item) {
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
    if native_objc_owned_valid(hide_item) {
      native_appkit_add_menu_item(app_menu, hide_item)
      appkit_objc_release_object(hide_item)
    }
    let option_command_modifier_mask = 524288 + 1_048_576
    let hide_others_item = native_appkit_new_menu_item(
      "Hide Others", "hideOtherApplications:", "h", app, option_command_modifier_mask,
    )
    if native_objc_owned_valid(hide_others_item) {
      native_appkit_add_menu_item(app_menu, hide_others_item)
      appkit_objc_release_object(hide_others_item)
    }
    let show_all_item = native_appkit_new_menu_item(
      "Show All", "unhideAllApplications:", "", app, -1,
    )
    if native_objc_owned_valid(show_all_item) {
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
    if native_objc_owned_valid(quit_item) {
      native_appkit_add_menu_item(app_menu, quit_item)
      appkit_objc_release_object(quit_item)
    }
  }
  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("setMainMenu:"),
    native_objc_owned_handle(main_menu),
  )
  if native_objc_owned_valid(app_menu) {
    appkit_objc_release_object(app_menu)
  }
  if native_objc_owned_valid(app_menu_item) {
    appkit_objc_release_object(app_menu_item)
  }
  appkit_objc_release_object(main_menu)
}

///|
// Upstream `menu::initialize(app)` materializes a default menu tree.
// Here the native backend owns the concrete NSMenu construction.
fn initialize_default_menu(enabled : Bool) -> Unit {
  if enabled {
    // Keep a local, upstream-shaped descriptor model for parity and debugging.
    let _ = default_menu_descriptors(default_menu_process_name())
    default_menu_initialized.val = true
  } else {
    default_menu_initialized.val = false
  }
  native_application_initialize_default_menu(enabled)
}

///|
/// A single item in a custom system menu. For separator items, set
/// `separator = true`; all other fields are ignored.
pub struct SystemMenuItemDescriptor {
  title : String
  action_id : Int
  key_equivalent : String
  key_modifier_mask : Int
  separator : Bool
} derive(Debug)

///|
pub fn SystemMenuItemDescriptor::new(
  title~ : String,
  action_id~ : Int,
  key_equivalent~ : String,
  key_modifier_mask~ : Int,
  separator~ : Bool,
) -> SystemMenuItemDescriptor {
  { title, action_id, key_equivalent, key_modifier_mask, separator }
}

///|
/// A top-level custom system menu, such as File, Edit, or View.
pub struct SystemMenuDescriptor {
  title : String
  items : Array[SystemMenuItemDescriptor]
} derive(Debug)

///|
pub fn SystemMenuDescriptor::new(
  title~ : String,
  items~ : Array[SystemMenuItemDescriptor],
) -> SystemMenuDescriptor {
  { title, items }
}

///|
/// Keeps the registered native callback alive for the lifetime of the process.
let menu_action_callback_ref : Ref[((Int) -> Unit)?] = Ref(None)

///|
/// Registers the callback invoked when a custom system menu item is selected.
/// The callback receives that item's `action_id`.
pub fn set_system_menu_action_handler(handler : (Int) -> Unit) -> Unit {
  menu_action_callback_ref.val = Some(handler)
  native_install_menu_action_callback(
    fn(callback, action_id) { callback(action_id) },
    handler,
  )
}

///|
/// Builds and installs a native macOS system menu bar from `menus`.
///
/// The standard application menu (About, Services, Hide, and Quit) remains
/// available. Register an action handler with `set_system_menu_action_handler`
/// before installing menus that contain actionable items.
pub fn set_system_menus(menus : Array[SystemMenuDescriptor]) -> Unit {
  let app = native_application_shared_handle()
  if app == (0 : Int).to_uint64() {
    return ()
  }

  let main_menu = native_appkit_new_menu("")
  if native_objc_owned_valid(main_menu) == false {
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
  if native_objc_owned_valid(app_menu_item) {
    native_appkit_add_menu_item(main_menu, app_menu_item)
    if native_objc_owned_valid(app_menu) {
      appkit_objc_msg_send_void_u64(
        native_objc_owned_handle(app_menu_item),
        objc_runtime_selector_handle("setSubmenu:"),
        native_objc_owned_handle(app_menu),
      )
    }
  }
  if native_objc_owned_valid(app_menu) {
    let about_item = native_appkit_new_menu_item(
      "About", "orderFrontStandardAboutPanel:", "", app, -1,
    )
    if native_objc_owned_valid(about_item) {
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
    if native_objc_owned_valid(services_menu) {
      appkit_objc_msg_send_void_u64(
        app,
        objc_runtime_selector_handle("setServicesMenu:"),
        native_objc_owned_handle(services_menu),
      )
      if native_objc_owned_valid(services_item) {
        appkit_objc_msg_send_void_u64(
          native_objc_owned_handle(services_item),
          objc_runtime_selector_handle("setSubmenu:"),
          native_objc_owned_handle(services_menu),
        )
      }
      appkit_objc_release_object(services_menu)
    }
    if native_objc_owned_valid(services_item) {
      native_appkit_add_menu_item(app_menu, services_item)
      appkit_objc_release_object(services_item)
    }
    let hide_item = native_appkit_new_menu_item("Hide", "hide:", "h", app, -1)
    if native_objc_owned_valid(hide_item) {
      native_appkit_add_menu_item(app_menu, hide_item)
      appkit_objc_release_object(hide_item)
    }
    let option_cmd = 524288 + 1_048_576
    let hide_others = native_appkit_new_menu_item(
      "Hide Others", "hideOtherApplications:", "h", app, option_cmd,
    )
    if native_objc_owned_valid(hide_others) {
      native_appkit_add_menu_item(app_menu, hide_others)
      appkit_objc_release_object(hide_others)
    }
    let show_all = native_appkit_new_menu_item(
      "Show All", "unhideAllApplications:", "", app, -1,
    )
    if native_objc_owned_valid(show_all) {
      native_appkit_add_menu_item(app_menu, show_all)
      appkit_objc_release_object(show_all)
    }
    native_appkit_add_separator_item(app_menu)
    let quit_item = native_appkit_new_menu_item(
      "Quit", "terminate:", "q", app, -1,
    )
    if native_objc_owned_valid(quit_item) {
      native_appkit_add_menu_item(app_menu, quit_item)
      appkit_objc_release_object(quit_item)
    }
  }

  let target = native_create_menu_action_target()
  for menu_desc in menus {
    let menu_item_obj = native_appkit_new_menu_item(
      "",
      "",
      "",
      (0 : Int).to_uint64(),
      -1,
    )
    let submenu = native_appkit_new_menu(menu_desc.title)
    if native_objc_owned_valid(menu_item_obj) {
      native_appkit_add_menu_item(main_menu, menu_item_obj)
      if native_objc_owned_valid(submenu) {
        appkit_objc_msg_send_void_u64(
          native_objc_owned_handle(menu_item_obj),
          objc_runtime_selector_handle("setSubmenu:"),
          native_objc_owned_handle(submenu),
        )
      }
    }
    if native_objc_owned_valid(submenu) {
      for item_desc in menu_desc.items {
        if item_desc.separator {
          native_appkit_add_separator_item(submenu)
        } else {
          let key_modifier_mask = if item_desc.key_modifier_mask >= 0 {
            item_desc.key_modifier_mask
          } else {
            -1
          }
          let item = native_appkit_new_menu_item(
            item_desc.title,
            "handleMenuAction:",
            item_desc.key_equivalent,
            target,
            key_modifier_mask,
          )
          if native_objc_owned_valid(item) {
            native_set_menu_item_action_id(
              native_objc_owned_handle(item),
              item_desc.action_id,
            )
            native_appkit_add_menu_item(submenu, item)
            appkit_objc_release_object(item)
          }
        }
      }
    }
    if native_objc_owned_valid(submenu) {
      appkit_objc_release_object(submenu)
    }
    if native_objc_owned_valid(menu_item_obj) {
      appkit_objc_release_object(menu_item_obj)
    }
  }

  appkit_objc_msg_send_void_u64(
    app,
    objc_runtime_selector_handle("setMainMenu:"),
    native_objc_owned_handle(main_menu),
  )
  if native_objc_owned_valid(app_menu) {
    appkit_objc_release_object(app_menu)
  }
  if native_objc_owned_valid(app_menu_item) {
    appkit_objc_release_object(app_menu_item)
  }
  appkit_objc_release_object(main_menu)
}
