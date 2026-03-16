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
static mbw_send_event_impl_t g_original_send_event_impl = NULL;
static BOOL g_app_initialized = NO;

typedef struct {
  CFRunLoopObserverRef observer;
  mbw_lifecycle_trampoline_t trampoline;
  void *closure;
  int32_t callback_kind;
} MBWMainRunLoopObserver;

typedef NS_ENUM(int32_t, MBWImeState) {
  MBWImeStateDisabled = 0,
  MBWImeStateGround = 1,
  MBWImeStatePreedit = 2,
  MBWImeStateCommitted = 3,
};

static void mbw_ensure_app_initialized(void);
static void mbw_override_send_event_for_application(NSApplication *app, BOOL update_original);
static CFRunLoopActivity mbw_main_run_loop_activity_from_kind(int32_t activity_kind);
static void mbw_main_run_loop_observer_callback(CFRunLoopObserverRef observer,
                                                CFRunLoopActivity activity, void *info);

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

static void mbw_call_lifecycle_trampoline(mbw_lifecycle_trampoline_t trampoline, void *closure,
                                          int32_t callback_kind) {
  if (trampoline == NULL || closure == NULL) {
    return;
  }
  trampoline(closure, callback_kind);
}

@interface MBWContentView : NSView <NSTextInputClient, NSDraggingDestination>
@property(nonatomic, assign) BOOL acceptsFirstMouseEnabled;
@property(nonatomic, assign) int32_t optionAsAlt;
@property(nonatomic, assign) int32_t imePurpose;
@property(nonatomic, assign) int32_t imeHints;
@property(nonatomic, assign) BOOL imeAllowed;
@property(nonatomic, assign) int32_t imeCursorX;
@property(nonatomic, assign) int32_t imeCursorY;
@property(nonatomic, assign) int32_t imeCursorWidth;
@property(nonatomic, assign) int32_t imeCursorHeight;
@property(nonatomic, assign) int32_t rawId;
@property(nonatomic, strong) NSTrackingArea *trackingArea;
@property(nonatomic, copy) NSString *markedText;
@property(nonatomic, copy) NSString *inputSource;
@property(nonatomic, assign) BOOL forwardKeyToApp;
@property(nonatomic, assign) MBWImeState imeState;
- (void)mbw_emitTextInputWithKind:(int32_t)kind
                      eventHandle:(uint64_t)eventHandle
                           state:(int32_t)state
                            text:(NSString *)text
                     cursorStart:(int32_t)cursorStart
                       cursorEnd:(int32_t)cursorEnd
                       pathHandle:(uint64_t)pathHandle;
@end

@interface MBWWindowDelegate : NSObject <NSWindowDelegate>
@property(nonatomic, assign) int32_t rawId;
@property(nonatomic, assign) BOOL allowClose;
@property(nonatomic, assign) BOOL inFullscreenTransition;
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
  return self.acceptsFirstMouseEnabled;
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (void)updateTrackingAreas {
  [super updateTrackingAreas];
  if (self.trackingArea != nil) {
    [self removeTrackingArea:self.trackingArea];
    self.trackingArea = nil;
  }
  NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |
                                  NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect;
  self.trackingArea = [[[NSTrackingArea alloc] initWithRect:self.bounds
                                                    options:options
                                                      owner:self
                                                   userInfo:nil] autorelease];
  if (self.trackingArea != nil) {
    [self addTrackingArea:self.trackingArea];
  }
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

- (int32_t)mbw_utf8OffsetForUTF16Index:(NSUInteger)index inString:(NSString *)string {
  if (string == nil || index == NSNotFound) {
    return -1;
  }
  NSUInteger clamped = index <= string.length ? index : string.length;
  NSString *prefix = [string substringToIndex:clamped];
  return (int32_t)[prefix lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)mbw_plainStringFromTextObject:(id)object {
  if (object == nil) {
    return @"";
  }
  if ([object isKindOfClass:[NSAttributedString class]]) {
    return [(NSAttributedString *)object string];
  }
  if ([object isKindOfClass:[NSString class]]) {
    return (NSString *)object;
  }
  return @"";
}

- (NSString *)mbw_currentInputSource {
  NSTextInputContext *input_context = [self inputContext];
  if (input_context == nil) {
    return @"";
  }

  id source = [input_context selectedKeyboardInputSource];
  if ([source isKindOfClass:[NSString class]]) {
    return (NSString *)source;
  }
  if ([source respondsToSelector:@selector(description)]) {
    NSString *description = [source description];
    return description == nil ? @"" : description;
  }
  return @"";
}

- (BOOL)mbw_isImeEnabled {
  return self.imeState != MBWImeStateDisabled;
}

- (BOOL)mbw_isControlString:(NSString *)text {
  if (text == nil || text.length == 0) {
    return NO;
  }
  NSCharacterSet *control = [NSCharacterSet controlCharacterSet];
  return [control characterIsMember:[text characterAtIndex:0]];
}

- (uint64_t)mbw_dragPathListHandleFromDraggingInfo:(id<NSDraggingInfo>)sender {
  NSPasteboard *pasteboard = [sender draggingPasteboard];
  if (pasteboard == nil) {
    return 0;
  }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  id property_list = [pasteboard propertyListForType:NSFilenamesPboardType];
#pragma clang diagnostic pop
  if (property_list == nil) {
    return 0;
  }
  return (uint64_t)(uintptr_t)(__bridge void *)property_list;
}

- (void)mbw_emitTextInputWithKind:(int32_t)kind
                      eventHandle:(uint64_t)eventHandle
                           state:(int32_t)state
                            text:(NSString *)text
                     cursorStart:(int32_t)cursorStart
                       cursorEnd:(int32_t)cursorEnd
                       pathHandle:(uint64_t)pathHandle {
  if (self.rawId <= 0) {
    return;
  }
  NSString *safe_text = text == nil ? @"" : text;
  id event_object = eventHandle == 0 ? nil : (__bridge id)(void *)(uintptr_t)eventHandle;
  id path_object = pathHandle == 0 ? nil : (__bridge id)(void *)(uintptr_t)pathHandle;
  [safe_text retain];
  if (event_object != nil) {
    [event_object retain];
  }
  if (path_object != nil) {
    [path_object retain];
  }
  mbw_call_text_input_event_trampoline(self.rawId, kind, eventHandle, state,
                                       (uint64_t)(uintptr_t)(__bridge void *)safe_text,
                                       cursorStart, cursorEnd, pathHandle);
  if (event_object != nil) {
    [event_object release];
  }
  if (path_object != nil) {
    [path_object release];
  }
  [safe_text release];
}

- (void)mbw_emitImeEnabledIfNeeded {
  if (!self.imeAllowed || self.imeState != MBWImeStateDisabled) {
    return;
  }
  self.inputSource = [self mbw_currentInputSource];
  self.imeState = MBWImeStateGround;
  [self mbw_emitTextInputWithKind:8
                      eventHandle:0
                             state:1
                              text:@""
                       cursorStart:-1
                         cursorEnd:-1
                        pathHandle:0];
}

- (void)mbw_emitMouseMotion:(NSEvent *)event {
  [self mbw_emitInputWithKind:1 event:event];
}

- (void)mbw_emitMouseButton:(NSEvent *)event state:(int32_t)state {
  (void)state;
  [self mbw_emitMouseMotion:event];
  [self mbw_emitInputWithKind:4 event:event];
}

- (void)mbw_emitKeyboard:(NSEvent *)event state:(int32_t)state {
  (void)state;
  [self mbw_emitInputWithKind:7 event:event];
}

- (void)drawRect:(NSRect)dirtyRect {
  (void)dirtyRect;
  [self mbw_emitInputWithKind:19 event:nil];
}

- (void)mouseMoved:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
}

- (void)mouseDragged:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
}

- (void)rightMouseDragged:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
}

- (void)otherMouseDragged:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
}

- (void)mouseEntered:(NSEvent *)event {
  [self mbw_emitInputWithKind:2 event:event];
}

- (void)mouseExited:(NSEvent *)event {
  [self mbw_emitInputWithKind:3 event:event];
}

- (void)mouseDown:(NSEvent *)event {
  [self mbw_emitMouseButton:event state:1];
}

- (void)mouseUp:(NSEvent *)event {
  [self mbw_emitMouseButton:event state:2];
}

- (void)rightMouseDown:(NSEvent *)event {
  [self mbw_emitMouseButton:event state:1];
}

- (void)rightMouseUp:(NSEvent *)event {
  [self mbw_emitMouseButton:event state:2];
}

- (void)otherMouseDown:(NSEvent *)event {
  [self mbw_emitMouseButton:event state:1];
}

- (void)otherMouseUp:(NSEvent *)event {
  [self mbw_emitMouseButton:event state:2];
}

- (void)scrollWheel:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
  [self mbw_emitInputWithKind:5 event:event];
}

- (void)magnifyWithEvent:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
  [self mbw_emitInputWithKind:13 event:event];
}

- (void)swipeWithEvent:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
  [self mbw_emitInputWithKind:14 event:event];
}

- (void)smartMagnifyWithEvent:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
  [self mbw_emitInputWithKind:15 event:event];
}

- (void)rotateWithEvent:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
  [self mbw_emitInputWithKind:16 event:event];
}

- (void)pressureChangeWithEvent:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
  [self mbw_emitInputWithKind:17 event:event];
}

- (void)keyDown:(NSEvent *)event {
  if (self.imeAllowed && [self mbw_isImeEnabled]) {
    NSString *current_input_source = [self mbw_currentInputSource];
    NSString *previous_input_source = self.inputSource == nil ? @"" : self.inputSource;
    if (![previous_input_source isEqualToString:current_input_source]) {
      self.inputSource = current_input_source;
      self.imeState = MBWImeStateDisabled;
      [self mbw_emitTextInputWithKind:8
                          eventHandle:0
                                 state:4
                                  text:@""
                           cursorStart:-1
                             cursorEnd:-1
                            pathHandle:0];
    }
  }

  MBWImeState old_ime_state = self.imeState;
  self.forwardKeyToApp = NO;

  if (self.imeAllowed) {
    NSArray<NSEvent *> *events = @[ event ];
    [self interpretKeyEvents:events];
    if (self.imeState == MBWImeStateCommitted) {
      self.markedText = @"";
    }
  }

  BOOL had_ime_input = NO;
  switch (self.imeState) {
  case MBWImeStateCommitted:
    self.imeState = MBWImeStateGround;
    had_ime_input = YES;
    break;
  case MBWImeStatePreedit:
    had_ime_input = YES;
    break;
  case MBWImeStateGround:
  case MBWImeStateDisabled:
    had_ime_input = old_ime_state != self.imeState;
    break;
  }

  if (!had_ime_input || self.forwardKeyToApp) {
    [self mbw_emitKeyboard:event state:1];
  }
}

- (void)keyUp:(NSEvent *)event {
  if (self.imeState == MBWImeStateGround || self.imeState == MBWImeStateDisabled) {
    [self mbw_emitKeyboard:event state:2];
  }
}

- (void)flagsChanged:(NSEvent *)event {
  [self mbw_emitInputWithKind:6 event:event];
  [self mbw_emitKeyboard:event state:0];
}

- (BOOL)hasMarkedText {
  return self.markedText.length > 0;
}

- (NSRange)markedRange {
  if (self.markedText.length == 0) {
    return NSMakeRange(NSNotFound, 0);
  }
  return NSMakeRange(0, self.markedText.length);
}

- (NSRange)selectedRange {
  return NSMakeRange(NSNotFound, 0);
}

- (void)setMarkedText:(id)string
        selectedRange:(NSRange)selectedRange
     replacementRange:(NSRange)replacementRange {
  (void)replacementRange;
  if (!self.imeAllowed) {
    return;
  }
  NSString *text = [self mbw_plainStringFromTextObject:string];
  if (text == nil) {
    text = @"";
  }
  self.markedText = text;
  [self mbw_emitImeEnabledIfNeeded];

  int32_t cursor_start = -1;
  int32_t cursor_end = -1;
  if (selectedRange.location != NSNotFound) {
    NSUInteger clamped_start = selectedRange.location <= text.length ? selectedRange.location : text.length;
    NSUInteger utf16_end = selectedRange.location + selectedRange.length;
    NSUInteger clamped_end = utf16_end <= text.length ? utf16_end : text.length;
    cursor_start = [self mbw_utf8OffsetForUTF16Index:clamped_start inString:text];
    cursor_end = [self mbw_utf8OffsetForUTF16Index:clamped_end inString:text];
  }

  if (self.hasMarkedText) {
    self.imeState = MBWImeStatePreedit;
  } else {
    self.imeState = MBWImeStateGround;
  }

  [self mbw_emitTextInputWithKind:8
                      eventHandle:0
                             state:2
                              text:text
                       cursorStart:cursor_start
                         cursorEnd:cursor_end
                        pathHandle:0];
}

- (void)unmarkText {
  if (!self.imeAllowed) {
    return;
  }
  self.markedText = @"";

  NSTextInputContext *input_context = [self inputContext];
  if (input_context != nil) {
    [input_context discardMarkedText];
  }

  [self mbw_emitTextInputWithKind:8
                      eventHandle:0
                             state:2
                              text:@""
                       cursorStart:-1
                         cursorEnd:-1
                        pathHandle:0];

  if ([self mbw_isImeEnabled]) {
    self.imeState = MBWImeStateGround;
  }
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
  NSRect local = NSMakeRect((CGFloat)self.imeCursorX, (CGFloat)self.imeCursorY,
                            (CGFloat)(self.imeCursorWidth > 0 ? self.imeCursorWidth : 1),
                            (CGFloat)(self.imeCursorHeight > 0 ? self.imeCursorHeight : 1));
  NSRect in_window = [self convertRect:local toView:nil];
  if (self.window == nil) {
    return NSZeroRect;
  }
  return [self.window convertRectToScreen:in_window];
}

- (void)insertText:(id)string replacementRange:(NSRange)replacementRange {
  (void)replacementRange;
  if (!self.imeAllowed) {
    return;
  }
  NSString *text = [self mbw_plainStringFromTextObject:string];
  if (text == nil || text.length == 0) {
    return;
  }

  if (self.hasMarkedText && [self mbw_isImeEnabled] && ![self mbw_isControlString:text]) {
    [self mbw_emitTextInputWithKind:8
                        eventHandle:0
                               state:2
                                text:@""
                         cursorStart:-1
                           cursorEnd:-1
                          pathHandle:0];
    [self mbw_emitTextInputWithKind:8
                        eventHandle:0
                               state:3
                                text:text
                         cursorStart:-1
                           cursorEnd:-1
                          pathHandle:0];
    self.imeState = MBWImeStateCommitted;
  }
}

- (void)doCommandBySelector:(SEL)selector {
  if (self.imeState == MBWImeStateCommitted) {
    return;
  }

  self.forwardKeyToApp = YES;
  if (self.hasMarkedText && self.imeState == MBWImeStatePreedit) {
    self.imeState = MBWImeStateGround;
  }

  NSString *action = NSStringFromSelector(selector);
  [self mbw_emitTextInputWithKind:18
                      eventHandle:0
                             state:0
                              text:(action == nil ? @"" : action)
                       cursorStart:-1
                         cursorEnd:-1
                        pathHandle:0];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
  uint64_t dragging_info_handle = sender == nil ? 0 : (uint64_t)(uintptr_t)(__bridge void *)sender;
  uint64_t path_list_handle = [self mbw_dragPathListHandleFromDraggingInfo:sender];
  if (path_list_handle == 0) {
    return NSDragOperationNone;
  }
  [self mbw_emitTextInputWithKind:9
                      eventHandle:dragging_info_handle
                             state:1
                              text:nil
                       cursorStart:-1
                         cursorEnd:-1
                        pathHandle:path_list_handle];
  return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
  uint64_t dragging_info_handle = sender == nil ? 0 : (uint64_t)(uintptr_t)(__bridge void *)sender;
  [self mbw_emitTextInputWithKind:10
                      eventHandle:dragging_info_handle
                             state:0
                              text:nil
                       cursorStart:-1
                         cursorEnd:-1
                        pathHandle:0];
  return NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
  uint64_t dragging_info_handle = sender == nil ? 0 : (uint64_t)(uintptr_t)(__bridge void *)sender;
  [self mbw_emitTextInputWithKind:12
                      eventHandle:dragging_info_handle
                             state:0
                              text:nil
                       cursorStart:-1
                         cursorEnd:-1
                        pathHandle:0];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
  (void)sender;
  return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
  uint64_t dragging_info_handle = sender == nil ? 0 : (uint64_t)(uintptr_t)(__bridge void *)sender;
  uint64_t path_list_handle = [self mbw_dragPathListHandleFromDraggingInfo:sender];
  if (path_list_handle == 0) {
    return NO;
  }
  [self mbw_emitTextInputWithKind:11
                      eventHandle:dragging_info_handle
                             state:0
                              text:nil
                       cursorStart:-1
                         cursorEnd:-1
                        pathHandle:path_list_handle];
  return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
  (void)sender;
}

@end

@implementation MBWWindowDelegate

- (BOOL)windowShouldClose:(id)sender {
  (void)sender;
  mbw_call_window_event_trampoline(1, self.rawId, 0, 0, 0, 0.0);
  return self.allowClose;
}

- (void)windowWillClose:(NSNotification *)notification {
  (void)notification;
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
  NSWindow *window = (NSWindow *)notification.object;
  NSRect frame = window.frame;
  mbw_call_window_event_trampoline(4, self.rawId, (int32_t)frame.origin.x,
                                   (int32_t)frame.origin.y, 0, 0.0);
}

- (void)windowDidResize:(NSNotification *)notification {
  (void)notification;
  NSWindow *window = (NSWindow *)notification.object;
  NSRect contentRect = [window contentRectForFrameRect:window.frame];
  mbw_call_window_event_trampoline(8, self.rawId, (int32_t)contentRect.size.width,
                                   (int32_t)contentRect.size.height, 0, 0.0);
}

- (void)windowDidChangeBackingProperties:(NSNotification *)notification {
  (void)notification;
  NSWindow *window = (NSWindow *)notification.object;
  NSRect contentRect = [window contentRectForFrameRect:window.frame];
  mbw_call_window_event_trampoline(5, self.rawId, (int32_t)contentRect.size.width,
                                   (int32_t)contentRect.size.height, 0,
                                   window.backingScaleFactor);
}

- (void)windowDidChangeOcclusionState:(NSNotification *)notification {
  (void)notification;
  NSWindow *window = (NSWindow *)notification.object;
  BOOL occluded = (window.occlusionState & NSWindowOcclusionStateVisible) == 0;
  mbw_call_window_event_trampoline(7, self.rawId, occluded ? 1 : 0, 0, 0, 0.0);
}

- (void)windowWillEnterFullScreen:(NSNotification *)notification {
  (void)notification;
  self.inFullscreenTransition = YES;
  mbw_call_window_event_trampoline(9, self.rawId, 0, 0, 0, 0.0);
}

- (void)windowWillExitFullScreen:(NSNotification *)notification {
  (void)notification;
  self.inFullscreenTransition = YES;
  mbw_call_window_event_trampoline(10, self.rawId, 0, 0, 0, 0.0);
}

- (void)windowDidEnterFullScreen:(NSNotification *)notification {
  (void)notification;
  self.inFullscreenTransition = NO;
  NSWindow *window = (NSWindow *)notification.object;
  NSRect contentRect = [window contentRectForFrameRect:window.frame];
  mbw_call_window_event_trampoline(11, self.rawId, (int32_t)contentRect.size.width,
                                   (int32_t)contentRect.size.height, 0, 0.0);
}

- (void)windowDidExitFullScreen:(NSNotification *)notification {
  (void)notification;
  self.inFullscreenTransition = NO;
  NSWindow *window = (NSWindow *)notification.object;
  NSRect contentRect = [window contentRectForFrameRect:window.frame];
  mbw_call_window_event_trampoline(12, self.rawId, (int32_t)contentRect.size.width,
                                   (int32_t)contentRect.size.height, 0, 0.0);
}

- (void)windowDidFailToEnterFullScreen:(NSWindow *)window {
  (void)window;
  self.inFullscreenTransition = NO;
  mbw_call_window_event_trampoline(13, self.rawId, 0, 0, 0, 0.0);
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
  delegate.allowClose = NO;
  delegate.inFullscreenTransition = NO;
  window.delegate = delegate;

  MBWContentView *content_view = [[MBWContentView alloc] initWithFrame:window.contentView.bounds];
  content_view.acceptsFirstMouseEnabled = NO;
  content_view.optionAsAlt = 0;
  content_view.imePurpose = 0;
  content_view.imeHints = 0;
  content_view.imeAllowed = NO;
  content_view.imeCursorX = 0;
  content_view.imeCursorY = 0;
  content_view.imeCursorWidth = 1;
  content_view.imeCursorHeight = 1;
  content_view.markedText = @"";
  content_view.inputSource = [content_view mbw_currentInputSource];
  content_view.forwardKeyToApp = NO;
  content_view.imeState = MBWImeStateDisabled;
  content_view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  [content_view registerForDraggedTypes:@[ NSPasteboardTypeFileURL ]];
  window.contentView = content_view;
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
void mbw_objc_msg_send_void_i32_u64_i32_u64_i32_i32_u64(
    uint64_t target_handle, uint64_t selector_handle, int32_t arg0, uint64_t arg1, int32_t arg2,
    uint64_t arg3, int32_t arg4, int32_t arg5, uint64_t arg6) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  id arg1_obj = (__bridge id)(void *)(uintptr_t)arg1;
  id arg3_obj = (__bridge id)(void *)(uintptr_t)arg3;
  id arg6_obj = (__bridge id)(void *)(uintptr_t)arg6;
  void (*send_fn)(id, SEL, int32_t, id, int32_t, id, int32_t, int32_t, id) =
      (void (*)(id, SEL, int32_t, id, int32_t, id, int32_t, int32_t, id))objc_msgSend;
  send_fn(target, selector, arg0, arg1_obj, arg2, arg3_obj, arg4, arg5, arg6_obj);
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
