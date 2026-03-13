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
} derive(Eq, Show)

///|
pub(all) struct KeyEquivalent {
  key : String
  masks : Int?
} derive(Eq, Show)

///|
pub(all) struct MenuItemDescriptor {
  title : String
  action : MenuAction
  key_equivalent : KeyEquivalent?
} derive(Eq, Show)

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
  let _ = enabled
}
