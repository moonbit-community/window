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
fn default_menu_process_name() -> String {
  // The native backend currently owns app/bundle-name resolution.
  "Application"
}

///|
fn default_menu_descriptors(process_name : String) -> Array[MenuItemDescriptor] {
  [
    menu_item_descriptor("About " + process_name, MenuAction::About, None),
    menu_item_descriptor("", MenuAction::Separator, None),
    menu_item_descriptor("Services", MenuAction::Services, None),
    menu_item_descriptor(
      "Hide " + process_name,
      MenuAction::Hide,
      Some({ key: "h", masks: None }),
    ),
    menu_item_descriptor(
      "Hide Others",
      MenuAction::HideOthers,
      Some({ key: "h", masks: Some(3) }),
    ),
    menu_item_descriptor("Show All", MenuAction::ShowAll, None),
    menu_item_descriptor("", MenuAction::Separator, None),
    menu_item_descriptor(
      "Quit " + process_name,
      MenuAction::Quit,
      Some({ key: "q", masks: None }),
    ),
  ]
}

///|
let default_menu_initialized : Ref[Bool] = Ref::new(false)

///|
// Upstream `menu::initialize(app)` materializes a default menu tree.
// Here the native backend owns the concrete NSMenu construction.
pub fn initialize_default_menu(enabled : Bool) -> Unit {
  if enabled {
    // Keep a local, upstream-shaped descriptor model for parity and debugging.
    let _ = default_menu_descriptors(default_menu_process_name())
    default_menu_initialized.val = true
  } else {
    default_menu_initialized.val = false
  }
  set_application_default_menu(enabled)
}

///|
pub fn EventLoop::hide_application(_self : EventLoop) -> Unit {
  hide_application()
}

///|
pub fn EventLoop::hide_other_applications(_self : EventLoop) -> Unit {
  hide_other_applications()
}

///|
pub fn EventLoop::set_allows_automatic_window_tabbing(
  _self : EventLoop,
  enabled : Bool,
) -> Unit {
  set_allows_automatic_window_tabbing(enabled)
}

///|
pub fn EventLoop::allows_automatic_window_tabbing(_self : EventLoop) -> Bool {
  allows_automatic_window_tabbing()
}

///|
pub fn ActiveEventLoop::hide_application(self : ActiveEventLoop) -> Unit {
  self.inner.hide_application()
}

///|
pub fn ActiveEventLoop::hide_other_applications(self : ActiveEventLoop) -> Unit {
  self.inner.hide_other_applications()
}

///|
pub fn ActiveEventLoop::set_allows_automatic_window_tabbing(
  self : ActiveEventLoop,
  enabled : Bool,
) -> Unit {
  self.inner.set_allows_automatic_window_tabbing(enabled)
}

///|
pub fn ActiveEventLoop::allows_automatic_window_tabbing(
  self : ActiveEventLoop,
) -> Bool {
  self.inner.allows_automatic_window_tabbing()
}
