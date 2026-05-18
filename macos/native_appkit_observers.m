#import "native_appkit_bridge.h"

typedef struct {
  CFRunLoopObserverRef observer;
  mbw_lifecycle_trampoline_t trampoline;
  void *closure;
  int32_t callback_kind;
} MBWMainRunLoopObserver;

@interface MBWNotificationObserver : NSObject
@property(nonatomic, assign) int32_t callbackKind;
@property(nonatomic, assign) mbw_lifecycle_trampoline_t trampoline;
@property(nonatomic, assign) void *closure;
@end

@implementation MBWNotificationObserver

- (void)handleNotification:(NSNotification *)notification {
  (void)notification;
  [self retain];
  mbw_lifecycle_trampoline_t trampoline = self.trampoline;
  void *closure = self.closure;
  int32_t callback_kind = self.callbackKind;
  mbw_call_lifecycle_trampoline(trampoline, closure, callback_kind);
  [self release];
}

@end

static NSNotificationName mbw_notification_name_from_kind(int32_t notification_kind) {
  switch (notification_kind) {
  case 1:
    return NSApplicationDidFinishLaunchingNotification;
  case 2:
    return NSApplicationWillTerminateNotification;
  default:
    return nil;
  }
}

MOONBIT_FFI_EXPORT
uint64_t mbw_notification_center_add_observer(mbw_lifecycle_trampoline_t trampoline,
                                              void *closure, int32_t notification_kind,
                                              int32_t callback_kind) {
  NSNotificationName name = mbw_notification_name_from_kind(notification_kind);
  if (name == nil || trampoline == NULL || closure == NULL) {
    if (closure != NULL) {
      moonbit_decref(closure);
    }
    return 0;
  }
  [NSApplication sharedApplication];
  MBWNotificationObserver *observer = [[MBWNotificationObserver alloc] init];
  if (observer == nil) {
    moonbit_decref(closure);
    return 0;
  }
  observer.callbackKind = callback_kind;
  observer.trampoline = trampoline;
  observer.closure = closure;
  [[NSNotificationCenter defaultCenter] addObserver:observer
                                           selector:@selector(handleNotification:)
                                               name:name
                                             object:nil];
  return (uint64_t)(void *)observer;
}

MOONBIT_FFI_EXPORT
void mbw_notification_center_remove_observer(uint64_t observer_handle) {
  if (observer_handle == 0) {
    return;
  }
  MBWNotificationObserver *observer = (MBWNotificationObserver *)(void *)observer_handle;
  if (observer != nil) {
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
    if (observer.closure != NULL) {
      moonbit_decref(observer.closure);
      observer.closure = NULL;
    }
    [observer release];
  }
}

static CFRunLoopActivity mbw_main_run_loop_activity_from_kind(int32_t activity_kind) {
  switch (activity_kind) {
  case 1:
    return kCFRunLoopBeforeWaiting;
  case 2:
    return kCFRunLoopAfterWaiting;
  default:
    return 0;
  }
}

static void mbw_main_run_loop_observer_callback(CFRunLoopObserverRef observer,
                                                CFRunLoopActivity activity, void *info) {
  (void)observer;
  (void)activity;
  MBWMainRunLoopObserver *box = (MBWMainRunLoopObserver *)info;
  if (box == NULL) {
    return;
  }
  mbw_call_lifecycle_trampoline(box->trampoline, box->closure, box->callback_kind);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_main_run_loop_add_observer(mbw_lifecycle_trampoline_t trampoline, void *closure,
                                         int32_t activity_kind, int32_t callback_kind,
                                         int32_t order) {
  if (trampoline == NULL || closure == NULL) {
    if (closure != NULL) {
      moonbit_decref(closure);
    }
    return 0;
  }
  CFRunLoopActivity activity = mbw_main_run_loop_activity_from_kind(activity_kind);
  if (activity == 0) {
    moonbit_decref(closure);
    return 0;
  }
  mbw_ensure_app_initialized();
  MBWMainRunLoopObserver *box = (MBWMainRunLoopObserver *)malloc(sizeof(MBWMainRunLoopObserver));
  if (box == NULL) {
    moonbit_decref(closure);
    return 0;
  }
  memset(box, 0, sizeof(MBWMainRunLoopObserver));
  box->trampoline = trampoline;
  box->closure = closure;
  box->callback_kind = callback_kind;
  CFRunLoopObserverContext context = { 0 };
  context.info = box;
  CFRunLoopObserverRef observer_ref = CFRunLoopObserverCreate(
      kCFAllocatorDefault, activity, true, (CFIndex)order, mbw_main_run_loop_observer_callback,
      &context);
  if (observer_ref == NULL) {
    moonbit_decref(box->closure);
    free(box);
    return 0;
  }
  box->observer = observer_ref;
  CFRunLoopAddObserver(CFRunLoopGetMain(), observer_ref, kCFRunLoopCommonModes);
  return (uint64_t)(void *)box;
}

MOONBIT_FFI_EXPORT
void mbw_main_run_loop_remove_observer(uint64_t observer_handle) {
  if (observer_handle == 0) {
    return;
  }
  MBWMainRunLoopObserver *box = (MBWMainRunLoopObserver *)(void *)observer_handle;
  if (box == NULL) {
    return;
  }
  if (box->observer != NULL) {
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), box->observer, kCFRunLoopCommonModes);
    CFRelease(box->observer);
    box->observer = NULL;
  }
  if (box->closure != NULL) {
    moonbit_decref(box->closure);
    box->closure = NULL;
  }
  free(box);
}
