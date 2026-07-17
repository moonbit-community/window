#import "native_appkit_bridge.h"

typedef struct {
  CFRunLoopObserverRef observer;
  mbw_lifecycle_trampoline_t trampoline;
  void *closure;
  int32_t callback_kind;
} MBWMainRunLoopObserver;

typedef struct {
  MBWMainRunLoopObserver *box;
} MBWMainRunLoopObserverHandle;

@interface MBWNotificationObserver : NSObject
@property(nonatomic, assign) int32_t callbackKind;
@property(nonatomic, assign) mbw_lifecycle_trampoline_t trampoline;
@property(nonatomic, assign) void *closure;
- (void)mbwDestroyExternalOwner;
@end

typedef struct {
  MBWNotificationObserver *observer;
} MBWNotificationObserverHandle;

static void mbw_notification_observer_destroy_now(MBWNotificationObserver *observer) {
  if (observer == nil) {
    return;
  }
  [[NSNotificationCenter defaultCenter] removeObserver:observer];
  if (observer.closure != NULL) {
    moonbit_decref(observer.closure);
    observer.closure = NULL;
  }
  [observer release];
}

static void mbw_notification_observer_destroy(MBWNotificationObserver *observer) {
  if (observer == nil) {
    return;
  }
  if (pthread_main_np() != 0) {
    mbw_notification_observer_destroy_now(observer);
  } else {
    [observer performSelectorOnMainThread:@selector(mbwDestroyExternalOwner)
                               withObject:nil
                            waitUntilDone:NO];
  }
}

static void mbw_notification_observer_handle_finalize(void *ptr) {
  MBWNotificationObserverHandle *handle = (MBWNotificationObserverHandle *)ptr;
  if (handle == NULL) {
    return;
  }
  MBWNotificationObserver *observer = handle->observer;
  handle->observer = nil;
  mbw_notification_observer_destroy(observer);
}

static MBWNotificationObserverHandle *
mbw_notification_observer_handle_create(MBWNotificationObserver *observer) {
  MBWNotificationObserverHandle *handle = (MBWNotificationObserverHandle *)moonbit_make_external_object(
      mbw_notification_observer_handle_finalize, sizeof(MBWNotificationObserverHandle));
  handle->observer = observer;
  return handle;
}

@implementation MBWNotificationObserver

- (void)mbwDestroyExternalOwner {
  mbw_notification_observer_destroy_now(self);
}

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
MBWNotificationObserverHandle *
mbw_notification_center_add_observer(mbw_lifecycle_trampoline_t trampoline, void *closure,
                                     int32_t notification_kind, int32_t callback_kind) {
  NSNotificationName name = mbw_notification_name_from_kind(notification_kind);
  if (name == nil || trampoline == NULL || closure == NULL) {
    if (closure != NULL) {
      moonbit_decref(closure);
    }
    return mbw_notification_observer_handle_create(nil);
  }
  [NSApplication sharedApplication];
  MBWNotificationObserver *observer = [[MBWNotificationObserver alloc] init];
  if (observer == nil) {
    moonbit_decref(closure);
    return mbw_notification_observer_handle_create(nil);
  }
  observer.callbackKind = callback_kind;
  observer.trampoline = trampoline;
  observer.closure = closure;
  [[NSNotificationCenter defaultCenter] addObserver:observer
                                           selector:@selector(handleNotification:)
                                               name:name
                                             object:nil];
  return mbw_notification_observer_handle_create(observer);
}

MOONBIT_FFI_EXPORT
void mbw_notification_center_remove_observer(MBWNotificationObserverHandle *observer_handle) {
  if (observer_handle == NULL) {
    return;
  }
  MBWNotificationObserver *observer = observer_handle->observer;
  observer_handle->observer = nil;
  mbw_notification_observer_destroy(observer);
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

static void mbw_main_run_loop_observer_destroy_box_now(MBWMainRunLoopObserver *box);

@interface MBWMainRunLoopObserverOwner : NSObject {
@public
  MBWMainRunLoopObserver *box;
}
- (instancetype)initWithBox:(MBWMainRunLoopObserver *)box;
- (void)mbwDestroyExternalOwner;
@end

@implementation MBWMainRunLoopObserverOwner

- (instancetype)initWithBox:(MBWMainRunLoopObserver *)observerBox {
  self = [super init];
  if (self != nil) {
    box = observerBox;
  }
  return self;
}

- (void)mbwDestroyExternalOwner {
  MBWMainRunLoopObserver *ownedBox = box;
  box = NULL;
  mbw_main_run_loop_observer_destroy_box_now(ownedBox);
  [self release];
}

@end

static void mbw_main_run_loop_observer_destroy_box_now(MBWMainRunLoopObserver *box) {
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

static void mbw_main_run_loop_observer_destroy_box(MBWMainRunLoopObserver *box) {
  if (box == NULL) {
    return;
  }
  if (pthread_main_np() != 0) {
    mbw_main_run_loop_observer_destroy_box_now(box);
  } else {
    MBWMainRunLoopObserverOwner *owner =
        [[MBWMainRunLoopObserverOwner alloc] initWithBox:box];
    if (owner == nil) {
      mbw_main_run_loop_observer_destroy_box_now(box);
      return;
    }
    [owner performSelectorOnMainThread:@selector(mbwDestroyExternalOwner)
                            withObject:nil
                         waitUntilDone:NO];
  }
}

static void mbw_main_run_loop_observer_handle_finalize(void *ptr) {
  MBWMainRunLoopObserverHandle *handle = (MBWMainRunLoopObserverHandle *)ptr;
  if (handle == NULL) {
    return;
  }
  MBWMainRunLoopObserver *box = handle->box;
  handle->box = NULL;
  mbw_main_run_loop_observer_destroy_box(box);
}

static MBWMainRunLoopObserverHandle *
mbw_main_run_loop_observer_handle_create(MBWMainRunLoopObserver *box) {
  MBWMainRunLoopObserverHandle *handle = (MBWMainRunLoopObserverHandle *)moonbit_make_external_object(
      mbw_main_run_loop_observer_handle_finalize, sizeof(MBWMainRunLoopObserverHandle));
  handle->box = box;
  return handle;
}

MOONBIT_FFI_EXPORT
MBWMainRunLoopObserverHandle *
mbw_main_run_loop_add_observer(mbw_lifecycle_trampoline_t trampoline, void *closure,
                               int32_t activity_kind, int32_t callback_kind, int32_t order) {
  if (trampoline == NULL || closure == NULL) {
    if (closure != NULL) {
      moonbit_decref(closure);
    }
    return mbw_main_run_loop_observer_handle_create(NULL);
  }
  CFRunLoopActivity activity = mbw_main_run_loop_activity_from_kind(activity_kind);
  if (activity == 0) {
    moonbit_decref(closure);
    return mbw_main_run_loop_observer_handle_create(NULL);
  }
  mbw_ensure_app_initialized();
  MBWMainRunLoopObserver *box = (MBWMainRunLoopObserver *)malloc(sizeof(MBWMainRunLoopObserver));
  if (box == NULL) {
    moonbit_decref(closure);
    return mbw_main_run_loop_observer_handle_create(NULL);
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
    return mbw_main_run_loop_observer_handle_create(NULL);
  }
  box->observer = observer_ref;
  CFRunLoopAddObserver(CFRunLoopGetMain(), observer_ref, kCFRunLoopCommonModes);
  return mbw_main_run_loop_observer_handle_create(box);
}

MOONBIT_FFI_EXPORT
void mbw_main_run_loop_remove_observer(MBWMainRunLoopObserverHandle *observer_handle) {
  if (observer_handle == NULL) {
    return;
  }
  MBWMainRunLoopObserver *box = observer_handle->box;
  observer_handle->box = NULL;
  mbw_main_run_loop_observer_destroy_box(box);
}
