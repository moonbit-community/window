#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <moonbit.h>
#import <stdint.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <string.h>

typedef void (*mbw_window_event_trampoline_t)(void *closure, int32_t kind, int32_t raw_id,
                                              int32_t arg0, int32_t arg1, int32_t arg2,
                                              double argd);
typedef void (*mbw_input_event_trampoline_t)(void *closure, int32_t raw_id, int32_t kind,
                                             uint64_t event_handle);
typedef void (*mbw_text_input_event_trampoline_t)(void *closure, int32_t raw_id, int32_t kind,
                                                  uint64_t event_handle, int32_t state,
                                                  uint64_t text_handle, int32_t cursor_start,
                                                  int32_t cursor_end, uint64_t path_handle);
typedef void (*mbw_device_event_trampoline_t)(void *closure, uint64_t event_handle);
typedef int32_t (*mbw_view_state_query_trampoline_t)(void *closure, int32_t raw_id, int32_t kind);
typedef int32_t (*mbw_drag_query_trampoline_t)(void *closure, int32_t raw_id,
                                               uint64_t dragging_info_handle);
typedef void (*mbw_lifecycle_trampoline_t)(void *closure, int32_t kind);
typedef void (*mbw_send_event_impl_t)(id self, SEL _cmd, NSEvent *event);

static mbw_window_event_trampoline_t g_window_event_trampoline = NULL;
static void *g_window_event_closure = NULL;
static mbw_input_event_trampoline_t g_input_event_trampoline = NULL;
static void *g_input_event_closure = NULL;
static mbw_text_input_event_trampoline_t g_text_input_event_trampoline = NULL;
static void *g_text_input_event_closure = NULL;
static mbw_device_event_trampoline_t g_device_event_trampoline = NULL;
static void *g_device_event_closure = NULL;
static mbw_view_state_query_trampoline_t g_view_state_query_trampoline = NULL;
static void *g_view_state_query_closure = NULL;
static mbw_drag_query_trampoline_t g_drag_query_trampoline = NULL;
static void *g_drag_query_closure = NULL;
static mbw_send_event_impl_t g_original_send_event_impl = NULL;
static BOOL g_app_initialized = NO;

typedef struct {
  CFRunLoopObserverRef observer;
  mbw_lifecycle_trampoline_t trampoline;
  void *closure;
  int32_t callback_kind;
} MBWMainRunLoopObserver;

static void mbw_ensure_app_initialized(void);
static void mbw_override_send_event_for_application(NSApplication *app, BOOL update_original);
static CFRunLoopActivity mbw_main_run_loop_activity_from_kind(int32_t activity_kind);
static void mbw_main_run_loop_observer_callback(CFRunLoopObserverRef observer,
                                                CFRunLoopActivity activity, void *info);

enum {
  MBW_VIEW_STATE_QUERY_IME_ALLOWED = 1,
  MBW_VIEW_STATE_QUERY_MARKED_TEXT_LENGTH = 2,
  MBW_VIEW_STATE_QUERY_SELECTED_RANGE_LOCATION = 3,
  MBW_VIEW_STATE_QUERY_SELECTED_RANGE_LENGTH = 4,
  MBW_VIEW_STATE_QUERY_IME_CURSOR_X = 5,
  MBW_VIEW_STATE_QUERY_IME_CURSOR_Y = 6,
  MBW_VIEW_STATE_QUERY_IME_CURSOR_WIDTH = 7,
  MBW_VIEW_STATE_QUERY_IME_CURSOR_HEIGHT = 8,
  MBW_VIEW_STATE_QUERY_ACCEPTS_FIRST_MOUSE = 9,
};

static void mbw_call_window_event_trampoline(int32_t kind, int32_t raw_id, int32_t arg0,
                                             int32_t arg1, int32_t arg2, double argd) {
  if (g_window_event_trampoline == NULL || g_window_event_closure == NULL) {
    return;
  }
  g_window_event_trampoline(g_window_event_closure, kind, raw_id, arg0, arg1, arg2, argd);
}

static void mbw_call_input_event_trampoline(int32_t raw_id, int32_t kind, uint64_t event_handle) {
  if (g_input_event_trampoline == NULL || g_input_event_closure == NULL) {
    return;
  }
  g_input_event_trampoline(g_input_event_closure, raw_id, kind, event_handle);
}

static void mbw_call_text_input_event_trampoline(
    int32_t raw_id, int32_t kind, uint64_t event_handle, int32_t state, uint64_t text_handle,
    int32_t cursor_start, int32_t cursor_end, uint64_t path_handle) {
  if (g_text_input_event_trampoline == NULL || g_text_input_event_closure == NULL) {
    return;
  }
  g_text_input_event_trampoline(g_text_input_event_closure, raw_id, kind, event_handle, state,
                                text_handle, cursor_start, cursor_end, path_handle);
}

static void mbw_call_device_event_trampoline(uint64_t event_handle) {
  if (g_device_event_trampoline == NULL || g_device_event_closure == NULL) {
    return;
  }
  g_device_event_trampoline(g_device_event_closure, event_handle);
}

static int32_t mbw_query_view_state(int32_t raw_id, int32_t kind, int32_t default_value) {
  if (raw_id <= 0 || g_view_state_query_trampoline == NULL || g_view_state_query_closure == NULL) {
    return default_value;
  }
  return g_view_state_query_trampoline(g_view_state_query_closure, raw_id, kind);
}

static void mbw_call_lifecycle_trampoline(mbw_lifecycle_trampoline_t trampoline, void *closure,
                                          int32_t callback_kind) {
  if (trampoline == NULL || closure == NULL) {
    return;
  }
  trampoline(closure, callback_kind);
}

static void mbw_emit_drag_event(int32_t raw_id, int32_t kind, id<NSDraggingInfo> sender) {
  if (raw_id <= 0) {
    return;
  }
  uint64_t dragging_info_handle = sender == nil ? 0 : (uint64_t)(uintptr_t)(__bridge void *)sender;
  mbw_call_text_input_event_trampoline(raw_id, kind, dragging_info_handle, 0, 0, 0, 0, 0);
}

static BOOL mbw_query_drag_operation(int32_t raw_id, id<NSDraggingInfo> sender) {
  if (raw_id <= 0 || sender == nil || g_drag_query_trampoline == NULL || g_drag_query_closure == NULL) {
    return NO;
  }
  uint64_t dragging_info_handle = (uint64_t)(uintptr_t)(__bridge void *)sender;
  return g_drag_query_trampoline(g_drag_query_closure, raw_id, dragging_info_handle) != 0;
}

@interface MBWContentView : NSView <NSTextInputClient>
@property(nonatomic, assign) int32_t rawId;
@property(nonatomic, assign) NSTrackingRectTag trackingRectTag;
- (void)mbw_emitTextInputWithKind:(int32_t)kind
                      eventHandle:(uint64_t)eventHandle
                           state:(int32_t)state
                            text:(id)text
                     cursorStart:(int32_t)cursorStart
                       cursorEnd:(int32_t)cursorEnd
                       pathHandle:(uint64_t)pathHandle;
@end

@interface MBWWindowDelegate : NSObject <NSWindowDelegate, NSDraggingDestination>
@property(nonatomic, assign) int32_t rawId;
@end

@interface MBWNotificationObserver : NSObject
@property(nonatomic, assign) int32_t callbackKind;
@property(nonatomic, assign) mbw_lifecycle_trampoline_t trampoline;
@property(nonatomic, assign) void *closure;
@end

@interface MBWWindowBox : NSObject
@property(nonatomic, strong) NSWindow *window;
@property(nonatomic, strong) MBWWindowDelegate *delegate;
@property(nonatomic, strong) MBWContentView *contentView;
@end

@implementation MBWContentView

- (BOOL)isFlipped {
  return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
  (void)event;
  return mbw_query_view_state(self.rawId, MBW_VIEW_STATE_QUERY_ACCEPTS_FIRST_MOUSE, 0) != 0;
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (void)mbw_refreshTrackingRect {
  if (self.trackingRectTag != 0) {
    [self removeTrackingRect:self.trackingRectTag];
    self.trackingRectTag = 0;
  }
  self.trackingRectTag = [self addTrackingRect:self.frame
                                         owner:self
                                      userData:NULL
                                  assumeInside:NO];
}

- (void)viewDidMoveToWindow {
  [self mbw_refreshTrackingRect];
}

- (void)mbw_emitInputWithKind:(int32_t)kind event:(NSEvent *)event {
  if (self.rawId <= 0) {
    return;
  }
  uint64_t event_handle = 0;
  if (event != nil) {
    event_handle = (uint64_t)(uintptr_t)(__bridge void *)event;
  }
  mbw_call_input_event_trampoline(self.rawId, kind, event_handle);
}

- (int32_t)mbw_i32FromRangeValue:(NSUInteger)value {
  if (value == NSNotFound) {
    return -1;
  }
  if (value > INT32_MAX) {
    return INT32_MAX;
  }
  return (int32_t)value;
}

- (void)mbw_emitTextInputWithKind:(int32_t)kind
                      eventHandle:(uint64_t)eventHandle
                           state:(int32_t)state
                            text:(id)text
                     cursorStart:(int32_t)cursorStart
                       cursorEnd:(int32_t)cursorEnd
                       pathHandle:(uint64_t)pathHandle {
  if (self.rawId <= 0) {
    return;
  }
  id text_object = text == nil ? nil : text;
  id event_object = eventHandle == 0 ? nil : (__bridge id)(void *)(uintptr_t)eventHandle;
  if (text_object != nil) {
    [text_object retain];
  }
  if (event_object != nil) {
    [event_object retain];
  }
  mbw_call_text_input_event_trampoline(self.rawId, kind, eventHandle, state,
                                       (uint64_t)(uintptr_t)(__bridge void *)text_object,
                                       cursorStart, cursorEnd, pathHandle);
  if (event_object != nil) {
    [event_object release];
  }
  if (text_object != nil) {
    [text_object release];
  }
}

- (void)mbw_emitKeyboard:(NSEvent *)event state:(int32_t)state {
  (void)state;
  [self mbw_emitInputWithKind:7 event:event];
}

- (void)drawRect:(NSRect)dirtyRect {
  (void)dirtyRect;
  [self mbw_emitInputWithKind:19 event:nil];
}

- (void)viewFrameDidChangeNotification:(NSNotification *)notification {
  (void)notification;
  if (self.rawId <= 0) {
    return;
  }
  [self mbw_refreshTrackingRect];
  mbw_call_window_event_trampoline(8, self.rawId, 0, 0, 0, 0.0);
}

- (void)mouseMoved:(NSEvent *)event {
  [self mbw_emitInputWithKind:1 event:event];
}

- (void)mouseDragged:(NSEvent *)event {
  [self mbw_emitInputWithKind:1 event:event];
}

- (void)rightMouseDragged:(NSEvent *)event {
  [self mbw_emitInputWithKind:1 event:event];
}

- (void)otherMouseDragged:(NSEvent *)event {
  [self mbw_emitInputWithKind:1 event:event];
}

- (void)mouseEntered:(NSEvent *)event {
  [self mbw_emitInputWithKind:2 event:event];
}

- (void)mouseExited:(NSEvent *)event {
  [self mbw_emitInputWithKind:3 event:event];
}

- (void)mouseDown:(NSEvent *)event {
  [self mbw_emitInputWithKind:4 event:event];
}

- (void)mouseUp:(NSEvent *)event {
  [self mbw_emitInputWithKind:4 event:event];
}

- (void)rightMouseDown:(NSEvent *)event {
  [self mbw_emitInputWithKind:4 event:event];
}

- (void)rightMouseUp:(NSEvent *)event {
  [self mbw_emitInputWithKind:4 event:event];
}

- (void)otherMouseDown:(NSEvent *)event {
  [self mbw_emitInputWithKind:4 event:event];
}

- (void)otherMouseUp:(NSEvent *)event {
  [self mbw_emitInputWithKind:4 event:event];
}

- (void)scrollWheel:(NSEvent *)event {
  [self mbw_emitInputWithKind:5 event:event];
}

- (void)magnifyWithEvent:(NSEvent *)event {
  [self mbw_emitInputWithKind:13 event:event];
}

- (void)swipeWithEvent:(NSEvent *)event {
  [self mbw_emitInputWithKind:14 event:event];
}

- (void)smartMagnifyWithEvent:(NSEvent *)event {
  [self mbw_emitInputWithKind:15 event:event];
}

- (void)rotateWithEvent:(NSEvent *)event {
  [self mbw_emitInputWithKind:16 event:event];
}

- (void)pressureChangeWithEvent:(NSEvent *)event {
  [self mbw_emitInputWithKind:17 event:event];
}

- (void)keyDown:(NSEvent *)event {
  uint64_t event_handle = event == nil ? 0 : (uint64_t)(uintptr_t)(__bridge void *)event;
  [self mbw_emitTextInputWithKind:20
                      eventHandle:event_handle
                            state:0
                             text:nil
                      cursorStart:0
                        cursorEnd:0
                       pathHandle:0];
  if (mbw_query_view_state(self.rawId, MBW_VIEW_STATE_QUERY_IME_ALLOWED, 0) != 0) {
    NSArray<NSEvent *> *events = @[ event ];
    [self interpretKeyEvents:events];
  }
  [self mbw_emitTextInputWithKind:21
                      eventHandle:event_handle
                            state:0
                             text:nil
                      cursorStart:0
                        cursorEnd:0
                       pathHandle:0];
}

- (void)keyUp:(NSEvent *)event {
  [self mbw_emitKeyboard:event state:2];
}

- (void)flagsChanged:(NSEvent *)event {
  [self mbw_emitKeyboard:event state:0];
}

- (BOOL)hasMarkedText {
  return mbw_query_view_state(self.rawId, MBW_VIEW_STATE_QUERY_MARKED_TEXT_LENGTH, 0) > 0;
}

- (NSRange)markedRange {
  int32_t marked_text_length =
      mbw_query_view_state(self.rawId, MBW_VIEW_STATE_QUERY_MARKED_TEXT_LENGTH, 0);
  if (marked_text_length <= 0) {
    return NSMakeRange(NSNotFound, 0);
  }
  return NSMakeRange(0, (NSUInteger)marked_text_length);
}

- (NSRange)selectedRange {
  int32_t location =
      mbw_query_view_state(self.rawId, MBW_VIEW_STATE_QUERY_SELECTED_RANGE_LOCATION, -1);
  if (location < 0) {
    return NSMakeRange(NSNotFound, 0);
  }
  int32_t length = mbw_query_view_state(self.rawId, MBW_VIEW_STATE_QUERY_SELECTED_RANGE_LENGTH, 0);
  if (length < 0) {
    length = 0;
  }
  return NSMakeRange((NSUInteger)location, (NSUInteger)length);
}

- (void)setMarkedText:(id)string
        selectedRange:(NSRange)selectedRange
     replacementRange:(NSRange)replacementRange {
  (void)replacementRange;
  [self mbw_emitTextInputWithKind:22
                      eventHandle:0
                             state:[self mbw_i32FromRangeValue:selectedRange.location]
                              text:string
                       cursorStart:[self mbw_i32FromRangeValue:selectedRange.length]
                         cursorEnd:0
                        pathHandle:0];
}

- (void)unmarkText {
  NSTextInputContext *input_context = [self inputContext];
  if (input_context != nil) {
    [input_context discardMarkedText];
  }
  [self mbw_emitTextInputWithKind:23
                      eventHandle:0
                             state:0
                              text:@""
                       cursorStart:0
                         cursorEnd:0
                        pathHandle:0];
}

- (NSArray<NSAttributedStringKey> *)validAttributesForMarkedText {
  return @[];
}

- (NSAttributedString *)attributedSubstringForProposedRange:(NSRange)range
                                                 actualRange:(NSRangePointer)actualRange {
  (void)range;
  (void)actualRange;
  return nil;
}

- (NSUInteger)characterIndexForPoint:(NSPoint)point {
  (void)point;
  return 0;
}

- (NSRect)firstRectForCharacterRange:(NSRange)range actualRange:(NSRangePointer)actualRange {
  (void)range;
  (void)actualRange;
  CGFloat x =
      (CGFloat)mbw_query_view_state(self.rawId, MBW_VIEW_STATE_QUERY_IME_CURSOR_X, 0);
  CGFloat y =
      (CGFloat)mbw_query_view_state(self.rawId, MBW_VIEW_STATE_QUERY_IME_CURSOR_Y, 0);
  NSSize size = NSMakeSize(
      (CGFloat)mbw_query_view_state(self.rawId, MBW_VIEW_STATE_QUERY_IME_CURSOR_WIDTH, 1),
      (CGFloat)mbw_query_view_state(self.rawId, MBW_VIEW_STATE_QUERY_IME_CURSOR_HEIGHT, 1));
  if (size.width <= 0) {
    size.width = 1;
  }
  if (size.height <= 0) {
    size.height = 1;
  }
  NSRect local = NSMakeRect(x, y, size.width, size.height);
  NSRect in_window = [self convertRect:local toView:nil];
  if (self.window == nil) {
    return NSZeroRect;
  }
  return [self.window convertRectToScreen:in_window];
}

- (void)insertText:(id)string replacementRange:(NSRange)replacementRange {
  (void)replacementRange;
  [self mbw_emitTextInputWithKind:24
                      eventHandle:0
                            state:0
                             text:string
                      cursorStart:0
                        cursorEnd:0
                       pathHandle:0];
}

- (void)doCommandBySelector:(SEL)selector {
  [self mbw_emitTextInputWithKind:25
                      eventHandle:0
                             state:0
                              text:nil
                       cursorStart:0
                         cursorEnd:0
                        pathHandle:(uint64_t)(uintptr_t)sel_getName(selector)];
}

@end

@implementation MBWWindowDelegate

- (BOOL)windowShouldClose:(id)sender {
  (void)sender;
  mbw_call_window_event_trampoline(1, self.rawId, 0, 0, 0, 0.0);
  return NO;
}

- (void)windowWillClose:(NSNotification *)notification {
  NSWindow *window = notification.object;
  if ([window isKindOfClass:[NSWindow class]]) {
    NSView *content_view = [window contentView];
    if (content_view != nil) {
      [[NSNotificationCenter defaultCenter] removeObserver:content_view
                                                      name:NSViewFrameDidChangeNotification
                                                    object:content_view];
    }
    [window setDelegate:nil];
  }
  mbw_call_window_event_trampoline(2, self.rawId, 0, 0, 0, 0.0);
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
  (void)notification;
  mbw_call_window_event_trampoline(3, self.rawId, 1, 0, 0, 0.0);
}

- (void)windowDidResignKey:(NSNotification *)notification {
  (void)notification;
  mbw_call_window_event_trampoline(3, self.rawId, 0, 0, 0, 0.0);
}

- (void)windowDidMove:(NSNotification *)notification {
  (void)notification;
  mbw_call_window_event_trampoline(4, self.rawId, 0, 0, 0, 0.0);
}

- (void)windowDidResize:(NSNotification *)notification {
  (void)notification;
  mbw_call_window_event_trampoline(4, self.rawId, 0, 0, 0, 0.0);
}

- (void)windowDidChangeBackingProperties:(NSNotification *)notification {
  (void)notification;
  mbw_call_window_event_trampoline(5, self.rawId, 0, 0, 0, 0.0);
}

- (void)windowDidChangeOcclusionState:(NSNotification *)notification {
  (void)notification;
  mbw_call_window_event_trampoline(7, self.rawId, 0, 0, 0, 0.0);
}

- (void)windowWillEnterFullScreen:(NSNotification *)notification {
  (void)notification;
  mbw_call_window_event_trampoline(9, self.rawId, 0, 0, 0, 0.0);
}

- (void)windowWillExitFullScreen:(NSNotification *)notification {
  (void)notification;
  mbw_call_window_event_trampoline(10, self.rawId, 0, 0, 0, 0.0);
}

- (void)windowDidEnterFullScreen:(NSNotification *)notification {
  (void)notification;
  mbw_call_window_event_trampoline(11, self.rawId, 0, 0, 0, 0.0);
}

- (void)windowDidExitFullScreen:(NSNotification *)notification {
  (void)notification;
  mbw_call_window_event_trampoline(12, self.rawId, 0, 0, 0, 0.0);
}

- (void)windowDidFailToEnterFullScreen:(NSWindow *)window {
  (void)window;
  mbw_call_window_event_trampoline(13, self.rawId, 0, 0, 0, 0.0);
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
  if (!mbw_query_drag_operation(self.rawId, sender)) {
    return NSDragOperationNone;
  }
  mbw_emit_drag_event(self.rawId, 9, sender);
  return NSDragOperationCopy;
}

- (BOOL)wantsPeriodicDraggingUpdates {
  return YES;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
  if (!mbw_query_drag_operation(self.rawId, sender)) {
    return NSDragOperationNone;
  }
  mbw_emit_drag_event(self.rawId, 10, sender);
  return NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
  mbw_emit_drag_event(self.rawId, 12, sender);
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
  return mbw_query_drag_operation(self.rawId, sender);
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
  if (!mbw_query_drag_operation(self.rawId, sender)) {
    return NO;
  }
  mbw_emit_drag_event(self.rawId, 11, sender);
  return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
  (void)sender;
}

@end

@implementation MBWNotificationObserver

- (void)handleNotification:(NSNotification *)notification {
  (void)notification;
  mbw_call_lifecycle_trampoline(self.trampoline, self.closure, self.callbackKind);
}

@end

@implementation MBWWindowBox
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
    return 0;
  }
  NSApplication *app = [NSApplication sharedApplication];
  MBWNotificationObserver *observer = [[MBWNotificationObserver alloc] init];
  if (observer == nil) {
    return 0;
  }
  observer.callbackKind = callback_kind;
  observer.trampoline = trampoline;
  observer.closure = closure;
  [[NSNotificationCenter defaultCenter] addObserver:observer
                                           selector:@selector(handleNotification:)
                                               name:name
                                             object:nil];
  [observer retain];
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
    return 0;
  }
  CFRunLoopActivity activity = mbw_main_run_loop_activity_from_kind(activity_kind);
  if (activity == 0) {
    return 0;
  }
  mbw_ensure_app_initialized();
  MBWMainRunLoopObserver *box = (MBWMainRunLoopObserver *)malloc(sizeof(MBWMainRunLoopObserver));
  if (box == NULL) {
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

static void mbw_ensure_app_initialized(void) {
  if (g_app_initialized) {
    return;
  }
  [NSApplication sharedApplication];
  g_app_initialized = YES;
}

static void mbw_maybe_dispatch_device_event(NSEvent *event) {
  if (event == nil) {
    return;
  }
  [event retain];
  mbw_call_device_event_trampoline((uint64_t)(uintptr_t)(__bridge void *)event);
  [event release];
}

static void mbw_overridden_send_event(id self, SEL _cmd, NSEvent *event) {
  NSApplication *app = (NSApplication *)self;
  if (event != nil && event.type == NSEventTypeKeyUp &&
      (event.modifierFlags & NSEventModifierFlagCommand) != 0) {
    NSWindow *key_window = app.keyWindow;
    if (key_window != nil) {
      [key_window sendEvent:event];
      return;
    }
  }
  mbw_maybe_dispatch_device_event(event);
  if (g_original_send_event_impl != NULL) {
    g_original_send_event_impl(self, _cmd, event);
  }
}

static void mbw_override_send_event_for_application(NSApplication *app, BOOL update_original) {
  if (app == nil) {
    return;
  }
  Class cls = object_getClass(app);
  Method method = class_getInstanceMethod(cls, @selector(sendEvent:));
  if (method == NULL) {
    return;
  }
  IMP overridden = (IMP)mbw_overridden_send_event;
  IMP current = method_getImplementation(method);
  if (current == overridden) {
    return;
  }
  IMP original = method_setImplementation(method, overridden);
  if (update_original) {
    g_original_send_event_impl = (mbw_send_event_impl_t)original;
  }
}

MOONBIT_FFI_EXPORT
void mbw_install_window_event_callback(mbw_window_event_trampoline_t trampoline, void *closure) {
  if (g_window_event_closure != NULL) {
    moonbit_decref(g_window_event_closure);
  }
  g_window_event_trampoline = trampoline;
  g_window_event_closure = closure;
}

MOONBIT_FFI_EXPORT
void mbw_install_input_event_callback(mbw_input_event_trampoline_t trampoline, void *closure) {
  if (g_input_event_closure != NULL) {
    moonbit_decref(g_input_event_closure);
  }
  g_input_event_trampoline = trampoline;
  g_input_event_closure = closure;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t mbw_objc_copy_utf8_bytes(uint64_t object_handle) {
  if (object_handle == 0) {
    moonbit_bytes_t empty = moonbit_make_bytes(0, 0);
    return empty;
  }
  id object = (__bridge id)(void *)(uintptr_t)object_handle;
  if (object == nil || ![object respondsToSelector:@selector(UTF8String)]) {
    moonbit_bytes_t empty = moonbit_make_bytes(0, 0);
    return empty;
  }
  const char *utf8 = ((const char *(*)(id, SEL))objc_msgSend)(object, @selector(UTF8String));
  if (utf8 == NULL) {
    utf8 = "";
  }
  size_t len = strlen(utf8);
  moonbit_bytes_t bytes = moonbit_make_bytes((int32_t)len, 0);
  if (len > 0) {
    memcpy(bytes, utf8, len);
  }
  return bytes;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t mbw_copy_utf8_cstr_bytes(uint64_t cstr_handle) {
  if (cstr_handle == 0) {
    return moonbit_make_bytes(0, 0);
  }
  const char *utf8 = (const char *)(uintptr_t)cstr_handle;
  size_t len = strlen(utf8);
  moonbit_bytes_t bytes = moonbit_make_bytes((int32_t)len, 0);
  if (len > 0) {
    memcpy(bytes, utf8, len);
  }
  return bytes;
}

MOONBIT_FFI_EXPORT
void mbw_install_text_input_event_callback(mbw_text_input_event_trampoline_t trampoline,
                                           void *closure) {
  if (g_text_input_event_closure != NULL) {
    moonbit_decref(g_text_input_event_closure);
  }
  g_text_input_event_trampoline = trampoline;
  g_text_input_event_closure = closure;
}

MOONBIT_FFI_EXPORT
void mbw_install_device_event_callback(mbw_device_event_trampoline_t trampoline, void *closure) {
  if (g_device_event_closure != NULL) {
    moonbit_decref(g_device_event_closure);
  }
  g_device_event_trampoline = trampoline;
  g_device_event_closure = closure;
}

MOONBIT_FFI_EXPORT
void mbw_install_view_state_query_callback(mbw_view_state_query_trampoline_t trampoline,
                                           void *closure) {
  if (g_view_state_query_closure != NULL) {
    moonbit_decref(g_view_state_query_closure);
  }
  g_view_state_query_trampoline = trampoline;
  g_view_state_query_closure = closure;
}

MOONBIT_FFI_EXPORT
void mbw_install_drag_query_callback(mbw_drag_query_trampoline_t trampoline, void *closure) {
  if (g_drag_query_closure != NULL) {
    moonbit_decref(g_drag_query_closure);
  }
  g_drag_query_trampoline = trampoline;
  g_drag_query_closure = closure;
}

MOONBIT_FFI_EXPORT
double mbw_cgfloat_max(void) {
  return (double)CGFLOAT_MAX;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_appkit_window_level(int32_t kind) {
  switch (kind) {
  case 1:
    return (uint64_t)(int64_t)NSFloatingWindowLevel;
  case 2:
    return (uint64_t)(int64_t)(NSNormalWindowLevel - 1);
  default:
    return (uint64_t)(int64_t)NSNormalWindowLevel;
  }
}

MOONBIT_FFI_EXPORT
void mbw_override_send_event(void) {
  mbw_ensure_app_initialized();
  mbw_override_send_event_for_application([NSApplication sharedApplication], YES);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_create_window(int32_t width, int32_t height) {
  mbw_ensure_app_initialized();

  NSRect rect = NSMakeRect(100.0, 100.0, (CGFloat)(width > 0 ? width : 1),
                           (CGFloat)(height > 0 ? height : 1));

  NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                     NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;

  NSWindow *window = [[NSWindow alloc] initWithContentRect:rect
                                                  styleMask:style
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO];
  if (window == nil) {
    return 0;
  }
  window.releasedWhenClosed = NO;

  MBWWindowDelegate *delegate = [[MBWWindowDelegate alloc] init];
  window.delegate = delegate;

  MBWContentView *content_view = [[MBWContentView alloc] initWithFrame:window.contentView.bounds];
  content_view.trackingRectTag = 0;
  content_view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  window.contentView = content_view;
  [window setInitialFirstResponder:content_view];
  [window registerForDraggedTypes:@[ @"NSFilenamesPboardType" ]];
  [content_view setPostsFrameChangedNotifications:YES];
  [[NSNotificationCenter defaultCenter] addObserver:content_view
                                           selector:@selector(viewFrameDidChangeNotification:)
                                               name:NSViewFrameDidChangeNotification
                                             object:content_view];
  [content_view setWantsLayer:YES];
  if (content_view.layer != nil) {
    content_view.layer.masksToBounds = YES;
  }
  [window setAcceptsMouseMovedEvents:YES];

  MBWWindowBox *box = [[MBWWindowBox alloc] init];
  box.window = window;
  box.delegate = delegate;
  box.contentView = content_view;
  [window orderOut:nil];

  [box retain];
  return (uint64_t)(void *)box;
}

int32_t mbw_cgs_set_window_background_blur_radius(int32_t window_number, int32_t radius) {
  typedef int32_t (*mbw_cgs_main_connection_id_t)(void);
  typedef int32_t (*mbw_cgs_set_blur_t)(int32_t, int32_t, int32_t);

  mbw_cgs_main_connection_id_t main_connection =
      (mbw_cgs_main_connection_id_t)dlsym(RTLD_DEFAULT, "CGSMainConnectionID");
  mbw_cgs_set_blur_t set_blur = (mbw_cgs_set_blur_t)dlsym(
      RTLD_DEFAULT, "CGSSetWindowBackgroundBlurRadius");
  if (main_connection == NULL || set_blur == NULL) {
    return 0;
  }

  int32_t result = set_blur(main_connection(), window_number, radius);
  return result == 0 ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_custom_cursor_create_rgba(const uint8_t *rgba, int32_t rgba_len, int32_t width,
                                       int32_t height, int32_t hotspot_x, int32_t hotspot_y) {
  if (rgba == NULL || width <= 0 || height <= 0 || hotspot_x < 0 || hotspot_y < 0) {
    return 0;
  }
  int32_t expected_len = width * height * 4;
  if (expected_len <= 0 || rgba_len < expected_len) {
    return 0;
  }

  NSBitmapImageRep *rep =
      [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                               pixelsWide:width
                                               pixelsHigh:height
                                            bitsPerSample:8
                                          samplesPerPixel:4
                                                 hasAlpha:YES
                                                 isPlanar:NO
                                           colorSpaceName:NSDeviceRGBColorSpace
                                             bitmapFormat:0
                                              bytesPerRow:width * 4
                                             bitsPerPixel:32];
  if (rep == nil || [rep bitmapData] == NULL) {
    [rep release];
    return 0;
  }
  memcpy([rep bitmapData], rgba, (size_t)expected_len);

  NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize((CGFloat)width, (CGFloat)height)];
  if (image == nil) {
    [rep release];
    return 0;
  }
  [image addRepresentation:rep];
  [rep release];

  NSCursor *cursor = [[NSCursor alloc]
      initWithImage:image
            hotSpot:NSMakePoint((CGFloat)hotspot_x, (CGFloat)hotspot_y)];
  [image release];
  if (cursor == nil) {
    return 0;
  }

  return (uint64_t)(void *)cursor;
}

MOONBIT_FFI_EXPORT
int32_t mbw_cg_warp_mouse_cursor_position(double x, double y) {
  CGPoint point = CGPointMake((CGFloat)x, (CGFloat)y);
  CGError warp_err = CGWarpMouseCursorPosition(point);
  return warp_err == kCGErrorSuccess ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_objc_get_class(const char *name) {
  if (name == NULL) {
    return 0;
  }
  return (uint64_t)(uintptr_t)objc_getClass(name);
}

MOONBIT_FFI_EXPORT
void mbw_objc_release(uint64_t object_handle) {
  if (object_handle == 0) {
    return;
  }
  id object = (__bridge id)(void *)(uintptr_t)object_handle;
  if (object == nil) {
    return;
  }
  [object release];
}

MOONBIT_FFI_EXPORT
uint64_t mbw_objc_sel_register_name(const char *name) {
  if (name == NULL) {
    return 0;
  }
  SEL selector = sel_registerName(name);
  if (selector == NULL) {
    return 0;
  }
  return (uint64_t)(uintptr_t)sel_getName(selector);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_objc_msg_send_u64(uint64_t target_handle, uint64_t selector_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  uint64_t (*send_fn)(id, SEL) = (uint64_t(*)(id, SEL))objc_msgSend;
  return send_fn(target, selector);
}

uint64_t mbw_objc_msg_send_u64_bytes(uint64_t target_handle, uint64_t selector_handle,
                                     const char *arg0) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  uint64_t (*send_fn)(id, SEL, const char *) = (uint64_t(*)(id, SEL, const char *))objc_msgSend;
  return send_fn(target, selector, arg0 == NULL ? "" : arg0);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_objc_msg_send_u64_u64(uint64_t target_handle, uint64_t selector_handle,
                                   uint64_t arg0) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  uint64_t (*send_fn)(id, SEL, uint64_t) = (uint64_t(*)(id, SEL, uint64_t))objc_msgSend;
  return send_fn(target, selector, arg0);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void(uint64_t target_handle, uint64_t selector_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  void (*send_fn)(id, SEL) = (void (*)(id, SEL))objc_msgSend;
  send_fn(target, selector);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_u64(uint64_t target_handle, uint64_t selector_handle, uint64_t arg0) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  void (*send_fn)(id, SEL, uint64_t) = (void (*)(id, SEL, uint64_t))objc_msgSend;
  send_fn(target, selector, arg0);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_i32(uint64_t target_handle, uint64_t selector_handle, int32_t arg0) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  void (*send_fn)(id, SEL, int32_t) = (void (*)(id, SEL, int32_t))objc_msgSend;
  send_fn(target, selector, arg0);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_rect_u64(uint64_t target_handle, uint64_t selector_handle, double x,
                                     double y, double width, double height, uint64_t arg1) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  NSRect arg0 = NSMakeRect((CGFloat)x, (CGFloat)y, (CGFloat)width, (CGFloat)height);
  id arg1_obj = (__bridge id)(void *)(uintptr_t)arg1;
  void (*send_fn)(id, SEL, NSRect, id) = (void (*)(id, SEL, NSRect, id))objc_msgSend;
  send_fn(target, selector, arg0, arg1_obj);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_rect_bool(uint64_t target_handle, uint64_t selector_handle, double x,
                                      double y, double width, double height, int32_t arg1) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  NSRect arg0 = NSMakeRect((CGFloat)x, (CGFloat)y, (CGFloat)width, (CGFloat)height);
  BOOL arg1_bool = arg1 ? YES : NO;
  void (*send_fn)(id, SEL, NSRect, BOOL) = (void (*)(id, SEL, NSRect, BOOL))objc_msgSend;
  send_fn(target, selector, arg0, arg1_bool);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_objc_msg_send_u64_i32_double_double_i32_u64_i32_i32_u64(
    uint64_t target_handle, uint64_t selector_handle, int32_t arg0, double arg1, double arg2,
    int32_t arg3, uint64_t arg4, int32_t arg5, int32_t arg6, uint64_t arg7) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  id arg4_obj = (__bridge id)(void *)(uintptr_t)arg4;
  id (*send_fn)(id, SEL, int32_t, double, double, int32_t, id, int32_t, int32_t, uint64_t) =
      (id (*)(id, SEL, int32_t, double, double, int32_t, id, int32_t, int32_t, uint64_t))objc_msgSend;
  id result = send_fn(target, selector, arg0, arg1, arg2, arg3, arg4_obj, arg5, arg6, arg7);
  if (result == nil) {
    return 0;
  }
  return (uint64_t)(uintptr_t)(__bridge void *)result;
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_size(uint64_t target_handle, uint64_t selector_handle, double width,
                                 double height) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  NSSize arg0 = NSMakeSize((CGFloat)width, (CGFloat)height);
  void (*send_fn)(id, SEL, NSSize) = (void (*)(id, SEL, NSSize))objc_msgSend;
  send_fn(target, selector, arg0);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_point(uint64_t target_handle, uint64_t selector_handle, double x,
                                  double y) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  NSPoint arg0 = NSMakePoint((CGFloat)x, (CGFloat)y);
  void (*send_fn)(id, SEL, NSPoint) = (void (*)(id, SEL, NSPoint))objc_msgSend;
  send_fn(target, selector, arg0);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_u64_u64(uint64_t target_handle, uint64_t selector_handle,
                                    uint64_t arg0, uint64_t arg1) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  void (*send_fn)(id, SEL, uint64_t, uint64_t) =
      (void (*)(id, SEL, uint64_t, uint64_t))objc_msgSend;
  send_fn(target, selector, arg0, arg1);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_bool(uint64_t target_handle, uint64_t selector_handle, int32_t arg0) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  void (*send_fn)(id, SEL, BOOL) = (void (*)(id, SEL, BOOL))objc_msgSend;
  send_fn(target, selector, arg0 ? YES : NO);
}

MOONBIT_FFI_EXPORT
int32_t mbw_objc_msg_send_bool(uint64_t target_handle, uint64_t selector_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  BOOL (*send_fn)(id, SEL) = (BOOL(*)(id, SEL))objc_msgSend;
  return send_fn(target, selector) ? 1 : 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_objc_msg_send_bool_u64(uint64_t target_handle, uint64_t selector_handle,
                                   uint64_t arg0) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  BOOL (*send_fn)(id, SEL, uint64_t) = (BOOL(*)(id, SEL, uint64_t))objc_msgSend;
  return send_fn(target, selector, arg0) ? 1 : 0;
}

MOONBIT_FFI_EXPORT
int64_t mbw_objc_msg_send_i64(uint64_t target_handle, uint64_t selector_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  int64_t (*send_fn)(id, SEL) = (int64_t(*)(id, SEL))objc_msgSend;
  return send_fn(target, selector);
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_double(uint64_t target_handle, uint64_t selector_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0.0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  double (*send_fn)(id, SEL) = (double(*)(id, SEL))objc_msgSend;
  return send_fn(target, selector);
}

static BOOL mbw_objc_msg_send_value_no_args(uint64_t target_handle, uint64_t selector_handle,
                                            void *out_value, size_t out_size) {
  if (target_handle == 0 || selector_handle == 0 || out_value == NULL || out_size == 0) {
    return NO;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  if (target == nil) {
    return NO;
  }
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  if (selector == NULL) {
    return NO;
  }
  NSMethodSignature *signature = [target methodSignatureForSelector:selector];
  if (signature == nil || [signature numberOfArguments] != 2) {
    return NO;
  }
  NSUInteger return_length = [signature methodReturnLength];
  if (return_length == 0 || return_length > out_size) {
    return NO;
  }
  memset(out_value, 0, out_size);
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
  [invocation setTarget:target];
  [invocation setSelector:selector];
  [invocation invoke];
  [invocation getReturnValue:out_value];
  return YES;
}

static BOOL mbw_objc_msg_send_value_rect_arg(uint64_t target_handle, uint64_t selector_handle,
                                             NSRect arg0, void *out_value, size_t out_size) {
  if (target_handle == 0 || selector_handle == 0 || out_value == NULL || out_size == 0) {
    return NO;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  if (target == nil) {
    return NO;
  }
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  if (selector == NULL) {
    return NO;
  }
  NSMethodSignature *signature = [target methodSignatureForSelector:selector];
  if (signature == nil || [signature numberOfArguments] != 3) {
    return NO;
  }
  NSUInteger return_length = [signature methodReturnLength];
  if (return_length == 0 || return_length > out_size) {
    return NO;
  }
  memset(out_value, 0, out_size);
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
  [invocation setTarget:target];
  [invocation setSelector:selector];
  [invocation setArgument:&arg0 atIndex:2];
  [invocation invoke];
  [invocation getReturnValue:out_value];
  return YES;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_x(uint64_t target_handle, uint64_t selector_handle) {
  NSRect rect = NSZeroRect;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &rect, sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.origin.x;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_y(uint64_t target_handle, uint64_t selector_handle) {
  NSRect rect = NSZeroRect;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &rect, sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.origin.y;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_width(uint64_t target_handle, uint64_t selector_handle) {
  NSRect rect = NSZeroRect;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &rect, sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.size.width;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_height(uint64_t target_handle, uint64_t selector_handle) {
  NSRect rect = NSZeroRect;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &rect, sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.size.height;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_x_rect(uint64_t target_handle, uint64_t selector_handle, double x,
                                     double y, double width, double height) {
  NSRect rect = NSZeroRect;
  NSRect arg0 = NSMakeRect((CGFloat)x, (CGFloat)y, (CGFloat)width, (CGFloat)height);
  if (!mbw_objc_msg_send_value_rect_arg(target_handle, selector_handle, arg0, &rect,
                                        sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.origin.x;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_y_rect(uint64_t target_handle, uint64_t selector_handle, double x,
                                     double y, double width, double height) {
  NSRect rect = NSZeroRect;
  NSRect arg0 = NSMakeRect((CGFloat)x, (CGFloat)y, (CGFloat)width, (CGFloat)height);
  if (!mbw_objc_msg_send_value_rect_arg(target_handle, selector_handle, arg0, &rect,
                                        sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.origin.y;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_height_rect(uint64_t target_handle, uint64_t selector_handle,
                                          double x, double y, double width, double height) {
  NSRect rect = NSZeroRect;
  NSRect arg0 = NSMakeRect((CGFloat)x, (CGFloat)y, (CGFloat)width, (CGFloat)height);
  if (!mbw_objc_msg_send_value_rect_arg(target_handle, selector_handle, arg0, &rect,
                                        sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.size.height;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_size_width(uint64_t target_handle, uint64_t selector_handle) {
  NSSize size = NSZeroSize;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &size, sizeof(size))) {
    return 0.0;
  }
  return (double)size.width;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_size_height(uint64_t target_handle, uint64_t selector_handle) {
  NSSize size = NSZeroSize;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &size, sizeof(size))) {
    return 0.0;
  }
  return (double)size.height;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_point_x(uint64_t target_handle, uint64_t selector_handle) {
  NSPoint point = NSZeroPoint;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &point, sizeof(point))) {
    return 0.0;
  }
  return (double)point.x;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_point_y(uint64_t target_handle, uint64_t selector_handle) {
  NSPoint point = NSZeroPoint;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &point, sizeof(point))) {
    return 0.0;
  }
  return (double)point.y;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_point_x_point_u64(uint64_t target_handle, uint64_t selector_handle,
                                           double x, double y, uint64_t arg1_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0.0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  NSPoint arg0 = NSMakePoint((CGFloat)x, (CGFloat)y);
  id arg1 = arg1_handle == 0 ? nil : (__bridge id)(void *)(uintptr_t)arg1_handle;
  NSPoint (*send_fn)(id, SEL, NSPoint, id) = (NSPoint(*)(id, SEL, NSPoint, id))objc_msgSend;
  NSPoint point = send_fn(target, selector, arg0, arg1);
  return (double)point.x;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_point_y_point_u64(uint64_t target_handle, uint64_t selector_handle,
                                           double x, double y, uint64_t arg1_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0.0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  NSPoint arg0 = NSMakePoint((CGFloat)x, (CGFloat)y);
  id arg1 = arg1_handle == 0 ? nil : (__bridge id)(void *)(uintptr_t)arg1_handle;
  NSPoint (*send_fn)(id, SEL, NSPoint, id) = (NSPoint(*)(id, SEL, NSPoint, id))objc_msgSend;
  NSPoint point = send_fn(target, selector, arg0, arg1);
  return (double)point.y;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_edge_insets_top(uint64_t target_handle, uint64_t selector_handle) {
  NSEdgeInsets insets = NSEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &insets,
                                       sizeof(insets))) {
    return 0.0;
  }
  return (double)insets.top;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_edge_insets_left(uint64_t target_handle, uint64_t selector_handle) {
  NSEdgeInsets insets = NSEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &insets,
                                       sizeof(insets))) {
    return 0.0;
  }
  return (double)insets.left;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_edge_insets_bottom(uint64_t target_handle, uint64_t selector_handle) {
  NSEdgeInsets insets = NSEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &insets,
                                       sizeof(insets))) {
    return 0.0;
  }
  return (double)insets.bottom;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_edge_insets_right(uint64_t target_handle, uint64_t selector_handle) {
  NSEdgeInsets insets = NSEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &insets,
                                       sizeof(insets))) {
    return 0.0;
  }
  return (double)insets.right;
}
