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
    menu_item("About " + process_name, MenuAction::About, None),
    menu_item("", MenuAction::Separator, None),
    menu_item("Services", MenuAction::Services, None),
    menu_item(
      "Hide " + process_name,
      MenuAction::Hide,
      Some({ key: "h", masks: None }),
    ),
    menu_item(
      "Hide Others",
      MenuAction::HideOthers,
      Some({ key: "h", masks: Some(3) }),
    ),
    menu_item("Show All", MenuAction::ShowAll, None),
    menu_item("", MenuAction::Separator, None),
    menu_item(
      "Quit " + process_name,
      MenuAction::Quit,
      Some({ key: "q", masks: None }),
    ),
  ]
}

///|
// Port target: menu.rs::initialize
fn initialize(default_menu : Bool) -> Unit {
  initialize_default_menu(default_menu)
}

///|
let default_menu_initialized : Ref[Bool] = Ref::new(false)

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
