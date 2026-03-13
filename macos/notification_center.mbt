///|
// Port target: winit-reference/winit-appkit/src/notification_center.rs

///|
priv enum NotificationObserverKind {
  DidFinishLaunching
  WillTerminate
} derive(Show)

///|
priv struct NotificationObserver {
  kind : NotificationObserverKind
} derive(Show)

///|
// Port target: notification_center.rs::create_observer
fn create_observer(name : String) -> NotificationObserver {
  let kind = match name {
    "NSApplicationDidFinishLaunchingNotification" =>
      NotificationObserverKind::DidFinishLaunching
    "NSApplicationWillTerminateNotification" =>
      NotificationObserverKind::WillTerminate
    _ => abort("unsupported notification observer: " + name)
  }
  { kind, }
}

///|
fn NotificationObserver::take_pending(self : NotificationObserver) -> Bool {
  match self.kind {
    NotificationObserverKind::DidFinishLaunching =>
      app_state_take_did_finish_launching_notification()
    NotificationObserverKind::WillTerminate =>
      app_state_take_will_terminate_notification()
  }
}
