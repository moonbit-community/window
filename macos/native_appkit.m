#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <moonbit.h>
#import <stdint.h>
#include <dlfcn.h>
#include <string.h>

typedef void (*mbw_window_event_trampoline_t)(void *closure, int32_t kind, int32_t raw_id,
                                              int32_t arg0, int32_t arg1, int32_t arg2,
                                              double argd);
typedef void (*mbw_input_event_trampoline_t)(void *closure, int32_t raw_id, int32_t kind,
                                             double x, double y, int32_t state, int32_t button,
                                             int32_t modifiers, int32_t scancode, int32_t repeat,
                                             int32_t pointer_source, int32_t pointer_kind,
                                             int32_t scroll_delta_kind, double delta_x,
                                             double delta_y, int32_t phase);
typedef void (*mbw_text_input_event_trampoline_t)(void *closure, int32_t raw_id, int32_t kind,
                                                  double x, double y, int32_t state,
                                                  moonbit_bytes_t text, int32_t cursor_start,
                                                  int32_t cursor_end, moonbit_bytes_t path);
typedef void (*mbw_device_event_trampoline_t)(void *closure, int32_t kind, int32_t button,
                                              double delta_x, double delta_y);
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
static mbw_lifecycle_trampoline_t g_lifecycle_trampoline = NULL;
static void *g_lifecycle_closure = NULL;
static mbw_send_event_impl_t g_original_send_event_impl = NULL;
static BOOL g_app_initialized = NO;
static BOOL g_cursor_hidden = NO;
static id g_application_observer = nil;

static void mbw_emit_lifecycle(int32_t kind);

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
@property(nonatomic, assign) BOOL imeActive;
- (void)mbw_emitTextInputWithKind:(int32_t)kind
                                x:(double)x
                                y:(double)y
                             state:(int32_t)state
                              text:(NSString *)text
                       cursorStart:(int32_t)cursorStart
                         cursorEnd:(int32_t)cursorEnd
                              path:(NSString *)path;
@end

@interface MBWWindowDelegate : NSObject <NSWindowDelegate>
@property(nonatomic, assign) int32_t rawId;
@property(nonatomic, assign) BOOL allowClose;
@end

@interface MBWApplicationObserver : NSObject
@end

@interface MBWWindowBox : NSObject
@property(nonatomic, strong) NSWindow *window;
@property(nonatomic, strong) MBWWindowDelegate *delegate;
@property(nonatomic, strong) MBWContentView *contentView;
@property(nonatomic, assign) int32_t rawId;
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

- (NSPoint)mbw_mousePosition:(NSEvent *)event {
  if (event == nil) {
    return NSMakePoint(0.0, 0.0);
  }
  return [self convertPoint:event.locationInWindow fromView:nil];
}

- (int32_t)mbw_modifiers:(NSEvent *)event {
  NSEventModifierFlags flags = event == nil ? 0 : event.modifierFlags;
  int32_t modifiers = 0;
  if ((flags & NSEventModifierFlagShift) != 0) {
    modifiers |= 1;
  }
  if ((flags & NSEventModifierFlagControl) != 0) {
    modifiers |= 2;
  }
  if ((flags & NSEventModifierFlagOption) != 0) {
    modifiers |= 4;
  }
  if ((flags & NSEventModifierFlagCommand) != 0) {
    modifiers |= 8;
  }
  return modifiers;
}

- (int32_t)mbw_phaseFromNSEventPhase:(NSEventPhase)phase {
  switch (phase) {
  case NSEventPhaseMayBegin:
  case NSEventPhaseBegan:
    return 1;
  case NSEventPhaseChanged:
    return 2;
  case NSEventPhaseEnded:
    return 3;
  case NSEventPhaseCancelled:
    return 4;
  default:
    return 0;
  }
}

- (int32_t)mbw_scrollPhase:(NSEvent *)event {
  int32_t phase = [self mbw_phaseFromNSEventPhase:event.momentumPhase];
  if (phase != 0) {
    return phase;
  }
  phase = [self mbw_phaseFromNSEventPhase:event.phase];
  if (phase != 0) {
    return phase;
  }
  return 2;
}

- (void)mbw_emitInputWithKind:(int32_t)kind
                           x:(double)x
                           y:(double)y
                        state:(int32_t)state
                       button:(int32_t)button
                    modifiers:(int32_t)modifiers
                     scancode:(int32_t)scancode
                       repeat:(int32_t)repeat
                pointerSource:(int32_t)pointerSource
                  pointerKind:(int32_t)pointerKind
              scrollDeltaKind:(int32_t)scrollDeltaKind
                       deltaX:(double)deltaX
                       deltaY:(double)deltaY
                        phase:(int32_t)phase {
  if (g_input_event_trampoline == NULL || g_input_event_closure == NULL || self.rawId <= 0) {
    return;
  }
  g_input_event_trampoline(g_input_event_closure, self.rawId, kind, x, y, state, button,
                           modifiers, scancode, repeat, pointerSource, pointerKind,
                           scrollDeltaKind, deltaX, deltaY, phase);
}

- (moonbit_bytes_t)mbw_makeBytesFromString:(NSString *)text {
  const char *utf8 = text == nil ? "" : text.UTF8String;
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

- (NSString *)mbw_dragPathsFromDraggingInfo:(id<NSDraggingInfo>)sender {
  NSPasteboard *pasteboard = [sender draggingPasteboard];
  if (pasteboard == nil) {
    return @"";
  }
  NSArray<NSURL *> *urls = [pasteboard readObjectsForClasses:@[ [NSURL class] ]
                                                     options:@{
                                                       NSPasteboardURLReadingFileURLsOnlyKey : @YES
                                                     }];
  if (urls == nil || urls.count == 0) {
    return @"";
  }
  NSMutableArray<NSString *> *paths = [NSMutableArray arrayWithCapacity:urls.count];
  for (NSURL *url in urls) {
    if (url == nil || !url.fileURL) {
      continue;
    }
    NSString *path = url.path;
    if (path != nil && path.length > 0) {
      [paths addObject:path];
    }
  }
  if (paths.count == 0) {
    return @"";
  }
  return [paths componentsJoinedByString:@"\n"];
}

- (void)mbw_emitTextInputWithKind:(int32_t)kind
                                x:(double)x
                                y:(double)y
                             state:(int32_t)state
                              text:(NSString *)text
                       cursorStart:(int32_t)cursorStart
                         cursorEnd:(int32_t)cursorEnd
                              path:(NSString *)path {
  if (g_text_input_event_trampoline == NULL || g_text_input_event_closure == NULL ||
      self.rawId <= 0) {
    return;
  }
  moonbit_bytes_t text_bytes = [self mbw_makeBytesFromString:(text == nil ? @"" : text)];
  moonbit_bytes_t path_bytes = [self mbw_makeBytesFromString:(path == nil ? @"" : path)];
  g_text_input_event_trampoline(g_text_input_event_closure, self.rawId, kind, x, y, state,
                                text_bytes, cursorStart, cursorEnd, path_bytes);
}

- (void)mbw_emitImeEnabledIfNeeded {
  if (!self.imeAllowed || self.imeActive) {
    return;
  }
  self.imeActive = YES;
  [self mbw_emitTextInputWithKind:8
                                x:0.0
                                y:0.0
                             state:1
                              text:@""
                       cursorStart:-1
                         cursorEnd:-1
                              path:nil];
}

- (void)mbw_emitMouseMotion:(NSEvent *)event {
  NSPoint point = [self mbw_mousePosition:event];
  [self mbw_emitInputWithKind:1
                           x:point.x
                           y:point.y
                        state:0
                       button:0
                    modifiers:[self mbw_modifiers:event]
                     scancode:0
                       repeat:0
                pointerSource:1
                  pointerKind:1
              scrollDeltaKind:0
                       deltaX:0.0
                       deltaY:0.0
                        phase:0];
}

- (void)mbw_emitMouseButton:(NSEvent *)event state:(int32_t)state {
  [self mbw_emitMouseMotion:event];
  NSPoint point = [self mbw_mousePosition:event];
  [self mbw_emitInputWithKind:4
                           x:point.x
                           y:point.y
                        state:state
                       button:(int32_t)event.buttonNumber
                    modifiers:[self mbw_modifiers:event]
                     scancode:0
                       repeat:0
                pointerSource:1
                  pointerKind:1
              scrollDeltaKind:0
                       deltaX:0.0
                       deltaY:0.0
                        phase:0];
}

- (void)mbw_emitKeyboard:(NSEvent *)event state:(int32_t)state {
  [self mbw_emitInputWithKind:7
                           x:0.0
                           y:0.0
                        state:state
                       button:0
                    modifiers:[self mbw_modifiers:event]
                     scancode:(int32_t)event.keyCode
                       repeat:(event.isARepeat ? 1 : 0)
                pointerSource:0
                  pointerKind:0
              scrollDeltaKind:0
                       deltaX:0.0
                       deltaY:0.0
                        phase:0];
}

- (int32_t)mbw_flagsChangedState:(NSEvent *)event {
  uint16_t scancode = event.keyCode;
  NSEventModifierFlags flags = event.modifierFlags;
  BOOL pressed = NO;
  BOOL valid = YES;
  switch (scancode) {
  case 56:
  case 60:
    pressed = (flags & NSEventModifierFlagShift) != 0;
    break;
  case 59:
  case 62:
    pressed = (flags & NSEventModifierFlagControl) != 0;
    break;
  case 58:
  case 61:
    pressed = (flags & NSEventModifierFlagOption) != 0;
    break;
  case 55:
  case 54:
    pressed = (flags & NSEventModifierFlagCommand) != 0;
    break;
  case 57:
    pressed = (flags & NSEventModifierFlagCapsLock) != 0;
    break;
  case 63:
    pressed = (flags & NSEventModifierFlagFunction) != 0;
    break;
  default:
    valid = NO;
    break;
  }
  if (!valid) {
    return 0;
  }
  return pressed ? 1 : 2;
}

- (void)drawRect:(NSRect)dirtyRect {
  (void)dirtyRect;
  [self mbw_emitInputWithKind:19
                           x:0.0
                           y:0.0
                        state:0
                       button:0
                    modifiers:0
                     scancode:0
                       repeat:0
                pointerSource:0
                  pointerKind:0
              scrollDeltaKind:0
                       deltaX:0.0
                       deltaY:0.0
                        phase:0];
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
  NSPoint point = [self mbw_mousePosition:event];
  [self mbw_emitInputWithKind:2
                           x:point.x
                           y:point.y
                        state:0
                       button:0
                    modifiers:[self mbw_modifiers:event]
                     scancode:0
                       repeat:0
                pointerSource:1
                  pointerKind:1
              scrollDeltaKind:0
                       deltaX:0.0
                       deltaY:0.0
                        phase:0];
}

- (void)mouseExited:(NSEvent *)event {
  NSPoint point = [self mbw_mousePosition:event];
  [self mbw_emitInputWithKind:3
                           x:point.x
                           y:point.y
                        state:0
                       button:0
                    modifiers:[self mbw_modifiers:event]
                     scancode:0
                       repeat:0
                pointerSource:1
                  pointerKind:1
              scrollDeltaKind:0
                       deltaX:0.0
                       deltaY:0.0
                        phase:0];
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
  [self mbw_emitInputWithKind:5
                           x:0.0
                           y:0.0
                        state:0
                       button:0
                    modifiers:[self mbw_modifiers:event]
                     scancode:0
                       repeat:0
                pointerSource:1
                  pointerKind:1
              scrollDeltaKind:(event.hasPreciseScrollingDeltas ? 2 : 1)
                       deltaX:event.scrollingDeltaX
                       deltaY:event.scrollingDeltaY
                        phase:[self mbw_scrollPhase:event]];
}

- (void)magnifyWithEvent:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
  int32_t phase = [self mbw_phaseFromNSEventPhase:event.phase];
  if (phase == 0) {
    return;
  }
  [self mbw_emitInputWithKind:13
                           x:0.0
                           y:0.0
                        state:0
                       button:0
                    modifiers:[self mbw_modifiers:event]
                     scancode:0
                       repeat:0
                pointerSource:1
                  pointerKind:1
              scrollDeltaKind:0
                       deltaX:event.magnification
                       deltaY:0.0
                        phase:phase];
}

- (void)swipeWithEvent:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
  int32_t phase = [self mbw_phaseFromNSEventPhase:event.phase];
  if (phase == 0) {
    phase = 2;
  }
  [self mbw_emitInputWithKind:14
                           x:0.0
                           y:0.0
                        state:0
                       button:0
                    modifiers:[self mbw_modifiers:event]
                     scancode:0
                       repeat:0
                pointerSource:1
                  pointerKind:1
              scrollDeltaKind:0
                       deltaX:event.deltaX
                       deltaY:event.deltaY
                        phase:phase];
}

- (void)smartMagnifyWithEvent:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
  [self mbw_emitInputWithKind:15
                           x:0.0
                           y:0.0
                        state:0
                       button:0
                    modifiers:[self mbw_modifiers:event]
                     scancode:0
                       repeat:0
                pointerSource:1
                  pointerKind:1
              scrollDeltaKind:0
                       deltaX:0.0
                       deltaY:0.0
                        phase:0];
}

- (void)rotateWithEvent:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
  int32_t phase = [self mbw_phaseFromNSEventPhase:event.phase];
  if (phase == 0) {
    return;
  }
  [self mbw_emitInputWithKind:16
                           x:0.0
                           y:0.0
                        state:0
                       button:0
                    modifiers:[self mbw_modifiers:event]
                     scancode:0
                       repeat:0
                pointerSource:1
                  pointerKind:1
              scrollDeltaKind:0
                       deltaX:event.rotation
                       deltaY:0.0
                        phase:phase];
}

- (void)pressureChangeWithEvent:(NSEvent *)event {
  [self mbw_emitMouseMotion:event];
  [self mbw_emitInputWithKind:17
                           x:0.0
                           y:0.0
                        state:(int32_t)event.stage
                       button:0
                    modifiers:[self mbw_modifiers:event]
                     scancode:0
                       repeat:0
                pointerSource:1
                  pointerKind:1
              scrollDeltaKind:0
                       deltaX:event.pressure
                       deltaY:0.0
                        phase:0];
}

- (void)keyDown:(NSEvent *)event {
  [self mbw_emitKeyboard:event state:1];
  if (self.imeAllowed) {
    NSArray<NSEvent *> *events = @[ event ];
    [self interpretKeyEvents:events];
  }
}

- (void)keyUp:(NSEvent *)event {
  [self mbw_emitKeyboard:event state:2];
}

- (void)flagsChanged:(NSEvent *)event {
  int32_t modifiers = [self mbw_modifiers:event];
  [self mbw_emitInputWithKind:6
                           x:0.0
                           y:0.0
                        state:0
                       button:0
                    modifiers:modifiers
                     scancode:0
                       repeat:0
                pointerSource:0
                  pointerKind:0
              scrollDeltaKind:0
                       deltaX:0.0
                       deltaY:0.0
                        phase:0];
  int32_t key_state = [self mbw_flagsChangedState:event];
  if (key_state != 0) {
    [self mbw_emitKeyboard:event state:key_state];
  }
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
    NSUInteger utf16_end = selectedRange.location + selectedRange.length;
    cursor_start = [self mbw_utf8OffsetForUTF16Index:selectedRange.location inString:text];
    cursor_end = [self mbw_utf8OffsetForUTF16Index:utf16_end inString:text];
  }

  [self mbw_emitTextInputWithKind:8
                                x:0.0
                                y:0.0
                             state:2
                              text:text
                       cursorStart:cursor_start
                         cursorEnd:cursor_end
                              path:nil];
}

- (void)unmarkText {
  if (!self.imeAllowed) {
    return;
  }
  self.markedText = @"";
  [self mbw_emitImeEnabledIfNeeded];
  [self mbw_emitTextInputWithKind:8
                                x:0.0
                                y:0.0
                             state:2
                              text:@""
                       cursorStart:-1
                         cursorEnd:-1
                              path:nil];
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
    return in_window;
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
  [self mbw_emitImeEnabledIfNeeded];
  self.markedText = @"";
  [self mbw_emitTextInputWithKind:8
                                x:0.0
                                y:0.0
                             state:3
                              text:text
                       cursorStart:-1
                         cursorEnd:-1
                              path:nil];
}

- (void)doCommandBySelector:(SEL)selector {
  NSString *action = NSStringFromSelector(selector);
  [self mbw_emitTextInputWithKind:18
                                x:0.0
                                y:0.0
                             state:0
                              text:(action == nil ? @"" : action)
                       cursorStart:-1
                         cursorEnd:-1
                              path:nil];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
  NSPoint point = [self convertPoint:[sender draggingLocation] fromView:nil];
  [self mbw_emitTextInputWithKind:9
                                x:point.x
                                y:point.y
                             state:1
                              text:nil
                       cursorStart:-1
                         cursorEnd:-1
                              path:[self mbw_dragPathsFromDraggingInfo:sender]];
  return NSDragOperationCopy;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
  NSPoint point = [self convertPoint:[sender draggingLocation] fromView:nil];
  [self mbw_emitTextInputWithKind:10
                                x:point.x
                                y:point.y
                             state:0
                              text:nil
                       cursorStart:-1
                         cursorEnd:-1
                              path:nil];
  return NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
  (void)sender;
  [self mbw_emitTextInputWithKind:12
                                x:0.0
                                y:0.0
                             state:0
                              text:nil
                       cursorStart:-1
                         cursorEnd:-1
                              path:nil];
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
  (void)sender;
  return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
  NSPoint point = [self convertPoint:[sender draggingLocation] fromView:nil];
  [self mbw_emitTextInputWithKind:11
                                x:point.x
                                y:point.y
                             state:0
                              text:nil
                       cursorStart:-1
                         cursorEnd:-1
                              path:[self mbw_dragPathsFromDraggingInfo:sender]];
  return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
  (void)sender;
}

@end

@implementation MBWWindowDelegate

- (BOOL)windowShouldClose:(id)sender {
  (void)sender;
  if (g_window_event_trampoline != NULL && g_window_event_closure != NULL) {
    g_window_event_trampoline(g_window_event_closure, 1, self.rawId, 0, 0, 0, 0.0);
  }
  return self.allowClose;
}

- (void)windowWillClose:(NSNotification *)notification {
  (void)notification;
  if (g_window_event_trampoline != NULL && g_window_event_closure != NULL) {
    g_window_event_trampoline(g_window_event_closure, 2, self.rawId, 0, 0, 0, 0.0);
  }
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
  (void)notification;
  if (g_window_event_trampoline != NULL && g_window_event_closure != NULL) {
    g_window_event_trampoline(g_window_event_closure, 3, self.rawId, 1, 0, 0, 0.0);
  }
}

- (void)windowDidResignKey:(NSNotification *)notification {
  (void)notification;
  if (g_window_event_trampoline != NULL && g_window_event_closure != NULL) {
    g_window_event_trampoline(g_window_event_closure, 3, self.rawId, 0, 0, 0, 0.0);
  }
}

- (void)windowDidMove:(NSNotification *)notification {
  (void)notification;
  if (g_window_event_trampoline != NULL && g_window_event_closure != NULL) {
    NSWindow *window = (NSWindow *)notification.object;
    NSRect frame = window.frame;
    g_window_event_trampoline(g_window_event_closure, 4, self.rawId, (int32_t)frame.origin.x,
                              (int32_t)frame.origin.y, 0, 0.0);
  }
}

- (void)windowDidResize:(NSNotification *)notification {
  (void)notification;
  if (g_window_event_trampoline != NULL && g_window_event_closure != NULL) {
    NSWindow *window = (NSWindow *)notification.object;
    NSRect contentRect = [window contentRectForFrameRect:window.frame];
    g_window_event_trampoline(g_window_event_closure, 8, self.rawId,
                              (int32_t)contentRect.size.width, (int32_t)contentRect.size.height,
                              0, 0.0);
  }
}

- (void)windowDidChangeBackingProperties:(NSNotification *)notification {
  (void)notification;
  if (g_window_event_trampoline != NULL && g_window_event_closure != NULL) {
    NSWindow *window = (NSWindow *)notification.object;
    NSRect contentRect = [window contentRectForFrameRect:window.frame];
    g_window_event_trampoline(g_window_event_closure, 5, self.rawId,
                              (int32_t)contentRect.size.width, (int32_t)contentRect.size.height,
                              0, window.backingScaleFactor);
  }
}

- (void)windowDidChangeOcclusionState:(NSNotification *)notification {
  (void)notification;
  if (g_window_event_trampoline != NULL && g_window_event_closure != NULL) {
    NSWindow *window = (NSWindow *)notification.object;
    BOOL occluded = (window.occlusionState & NSWindowOcclusionStateVisible) == 0;
    g_window_event_trampoline(g_window_event_closure, 7, self.rawId, occluded ? 1 : 0, 0, 0, 0.0);
  }
}

@end

@implementation MBWApplicationObserver

- (void)applicationWillTerminate:(NSNotification *)notification {
  (void)notification;
  mbw_emit_lifecycle(2);
}

@end

@implementation MBWWindowBox
@end

static void mbw_emit_lifecycle(int32_t kind) {
  if (g_lifecycle_trampoline != NULL && g_lifecycle_closure != NULL) {
    g_lifecycle_trampoline(g_lifecycle_closure, kind);
  }
}

static void mbw_ensure_app_initialized(void) {
  if (g_app_initialized) {
    return;
  }
  NSApplication *app = [NSApplication sharedApplication];
  if (g_application_observer == nil) {
    g_application_observer = [[MBWApplicationObserver alloc] init];
    [[NSNotificationCenter defaultCenter]
        addObserver:g_application_observer
           selector:@selector(applicationWillTerminate:)
               name:NSApplicationWillTerminateNotification
             object:app];
  }
  [app setActivationPolicy:NSApplicationActivationPolicyRegular];
  [app finishLaunching];
  g_app_initialized = YES;
  mbw_emit_lifecycle(1);
}

static MBWWindowBox *mbw_window_box_from_handle(uint64_t handle) {
  if (handle == 0) {
    return nil;
  }
  return (__bridge MBWWindowBox *)(void *)handle;
}

static NSWindow *mbw_window_from_box_or_native_handle(uint64_t handle) {
  if (handle == 0) {
    return nil;
  }
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box != nil && box.window != nil) {
    return box.window;
  }
  id obj = (__bridge id)(void *)handle;
  if (obj != nil && [obj isKindOfClass:[NSWindow class]]) {
    return (NSWindow *)obj;
  }
  return nil;
}

static NSString *mbw_string_from_utf8(const char *text) {
  if (text == NULL) {
    return @"";
  }
  NSString *value = [NSString stringWithUTF8String:text];
  return value == nil ? @"" : value;
}

static NSURL *mbw_url_from_utf8(const char *text) {
  NSString *value = mbw_string_from_utf8(text);
  if (value.length == 0) {
    return nil;
  }
  NSURL *url = [NSURL URLWithString:value];
  if (url == nil || url.scheme == nil) {
    url = [NSURL fileURLWithPath:value];
  }
  return url;
}

static void mbw_install_default_menu(void) {
  NSApplication *app = [NSApplication sharedApplication];
  NSString *process_name = [[NSProcessInfo processInfo] processName];
  if (process_name == nil || process_name.length == 0) {
    process_name = @"Application";
  }

  NSMenu *main_menu = [[NSMenu alloc] initWithTitle:@""];
  NSMenuItem *app_menu_item = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
  [main_menu addItem:app_menu_item];

  NSMenu *app_menu = [[NSMenu alloc] initWithTitle:@""];
  [app_menu_item setSubmenu:app_menu];

  NSMenuItem *about_item = [[NSMenuItem alloc]
      initWithTitle:[NSString stringWithFormat:@"About %@", process_name]
             action:@selector(orderFrontStandardAboutPanel:)
      keyEquivalent:@""];
  [about_item setTarget:app];
  [app_menu addItem:about_item];
  [about_item release];

  [app_menu addItem:[NSMenuItem separatorItem]];

  NSMenuItem *services_item =
      [[NSMenuItem alloc] initWithTitle:@"Services" action:nil keyEquivalent:@""];
  NSMenu *services_menu = [[NSMenu alloc] initWithTitle:@"Services"];
  [app setServicesMenu:services_menu];
  [services_item setSubmenu:services_menu];
  [app_menu addItem:services_item];
  [services_menu release];
  [services_item release];

  NSMenuItem *hide_item = [[NSMenuItem alloc]
      initWithTitle:[NSString stringWithFormat:@"Hide %@", process_name]
             action:@selector(hide:)
      keyEquivalent:@"h"];
  [hide_item setTarget:app];
  [app_menu addItem:hide_item];
  [hide_item release];

  NSMenuItem *hide_others_item =
      [[NSMenuItem alloc] initWithTitle:@"Hide Others"
                                 action:@selector(hideOtherApplications:)
                          keyEquivalent:@"h"];
  [hide_others_item setTarget:app];
  [hide_others_item setKeyEquivalentModifierMask:(NSEventModifierFlagOption |
                                                  NSEventModifierFlagCommand)];
  [app_menu addItem:hide_others_item];
  [hide_others_item release];

  NSMenuItem *show_all_item =
      [[NSMenuItem alloc] initWithTitle:@"Show All"
                                 action:@selector(unhideAllApplications:)
                          keyEquivalent:@""];
  [show_all_item setTarget:app];
  [app_menu addItem:show_all_item];
  [show_all_item release];

  [app_menu addItem:[NSMenuItem separatorItem]];

  NSMenuItem *quit_item = [[NSMenuItem alloc]
      initWithTitle:[NSString stringWithFormat:@"Quit %@", process_name]
             action:@selector(terminate:)
      keyEquivalent:@"q"];
  [quit_item setTarget:app];
  [app_menu addItem:quit_item];
  [quit_item release];

  [app setMainMenu:main_menu];
  [app_menu release];
  [app_menu_item release];
  [main_menu release];
}

static NSCursor *mbw_cursor_from_kind(int32_t cursor) {
  switch (cursor) {
  case 10:
    return [NSCursor openHandCursor];
  case 11:
    return [NSCursor closedHandCursor];
  case 12:
  case 19:
  case 20:
  case 24:
    return [NSCursor resizeLeftRightCursor];
  case 13:
  case 16:
  case 21:
  case 25:
    return [NSCursor resizeUpDownCursor];
  case 29:
    return [NSCursor pointingHandCursor];
  case 30:
    return [NSCursor IBeamCursor];
  case 31:
    return [NSCursor crosshairCursor];
  case 33:
    return [NSCursor operationNotAllowedCursor];
  default:
    return [NSCursor arrowCursor];
  }
}

static void mbw_emit_device_event(int32_t kind, int32_t button, double delta_x, double delta_y) {
  if (g_device_event_trampoline == NULL || g_device_event_closure == NULL) {
    return;
  }
  g_device_event_trampoline(g_device_event_closure, kind, button, delta_x, delta_y);
}

static void mbw_maybe_dispatch_device_event(NSEvent *event) {
  if (event == nil) {
    return;
  }
  switch (event.type) {
  case NSEventTypeMouseMoved:
  case NSEventTypeLeftMouseDragged:
  case NSEventTypeRightMouseDragged:
  case NSEventTypeOtherMouseDragged: {
    double delta_x = event.deltaX;
    double delta_y = event.deltaY;
    if (delta_x != 0.0 || delta_y != 0.0) {
      mbw_emit_device_event(1, 0, delta_x, delta_y);
    }
    break;
  }
  case NSEventTypeLeftMouseDown:
  case NSEventTypeRightMouseDown:
  case NSEventTypeOtherMouseDown:
    mbw_emit_device_event(2, (int32_t)event.buttonNumber, 0.0, 0.0);
    break;
  case NSEventTypeLeftMouseUp:
  case NSEventTypeRightMouseUp:
  case NSEventTypeOtherMouseUp:
    mbw_emit_device_event(3, (int32_t)event.buttonNumber, 0.0, 0.0);
    break;
  default:
    break;
  }
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

MOONBIT_FFI_EXPORT
void mbw_install_window_event_callback(mbw_window_event_trampoline_t trampoline, void *closure) {
  if (g_window_event_closure != NULL) {
    moonbit_decref(g_window_event_closure);
  }
  g_window_event_trampoline = trampoline;
  g_window_event_closure = closure;
  if (g_window_event_closure != NULL) {
    moonbit_incref(g_window_event_closure);
  }
}

MOONBIT_FFI_EXPORT
void mbw_install_input_event_callback(mbw_input_event_trampoline_t trampoline, void *closure) {
  if (g_input_event_closure != NULL) {
    moonbit_decref(g_input_event_closure);
  }
  g_input_event_trampoline = trampoline;
  g_input_event_closure = closure;
  if (g_input_event_closure != NULL) {
    moonbit_incref(g_input_event_closure);
  }
}

MOONBIT_FFI_EXPORT
void mbw_install_text_input_event_callback(mbw_text_input_event_trampoline_t trampoline,
                                           void *closure) {
  if (g_text_input_event_closure != NULL) {
    moonbit_decref(g_text_input_event_closure);
  }
  g_text_input_event_trampoline = trampoline;
  g_text_input_event_closure = closure;
  if (g_text_input_event_closure != NULL) {
    moonbit_incref(g_text_input_event_closure);
  }
}

MOONBIT_FFI_EXPORT
void mbw_install_device_event_callback(mbw_device_event_trampoline_t trampoline, void *closure) {
  if (g_device_event_closure != NULL) {
    moonbit_decref(g_device_event_closure);
  }
  g_device_event_trampoline = trampoline;
  g_device_event_closure = closure;
  if (g_device_event_closure != NULL) {
    moonbit_incref(g_device_event_closure);
  }
}

MOONBIT_FFI_EXPORT
void mbw_install_lifecycle_callback(mbw_lifecycle_trampoline_t trampoline, void *closure) {
  if (g_lifecycle_closure != NULL) {
    moonbit_decref(g_lifecycle_closure);
  }
  g_lifecycle_trampoline = trampoline;
  g_lifecycle_closure = closure;
  if (g_lifecycle_closure != NULL) {
    moonbit_incref(g_lifecycle_closure);
  }
}

MOONBIT_FFI_EXPORT
void mbw_override_send_event(void) {
  mbw_ensure_app_initialized();
  NSApplication *app = [NSApplication sharedApplication];
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
  g_original_send_event_impl = (mbw_send_event_impl_t)original;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_create_window(int32_t raw_id, int32_t width, int32_t height, int32_t visible,
                           int32_t active, int32_t resizable, int32_t decorations, int32_t panel,
                           const char *title) {
  mbw_ensure_app_initialized();

  NSRect rect = NSMakeRect(100.0, 100.0, (CGFloat)(width > 0 ? width : 1),
                           (CGFloat)(height > 0 ? height : 1));

  NSUInteger style = 0;
  if (decorations) {
    style |= NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable;
  }
  if (resizable) {
    style |= NSWindowStyleMaskResizable;
  }
  if (panel) {
    style |= NSWindowStyleMaskUtilityWindow;
  }
  if (style == 0) {
    style = NSWindowStyleMaskBorderless;
  }

  NSWindow *window = [[NSWindow alloc] initWithContentRect:rect
                                                  styleMask:style
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO];
  if (window == nil) {
    return 0;
  }
  window.releasedWhenClosed = NO;
  window.title = mbw_string_from_utf8(title);

  MBWWindowDelegate *delegate = [[MBWWindowDelegate alloc] init];
  delegate.rawId = raw_id;
  delegate.allowClose = NO;
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
  content_view.imeActive = NO;
  content_view.rawId = raw_id;
  content_view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
  [content_view registerForDraggedTypes:@[ NSPasteboardTypeFileURL ]];
  window.contentView = content_view;
  [window setAcceptsMouseMovedEvents:YES];

  MBWWindowBox *box = [[MBWWindowBox alloc] init];
  box.window = window;
  box.delegate = delegate;
  box.contentView = content_view;
  box.rawId = raw_id;

  if (visible) {
    [window makeKeyAndOrderFront:nil];
  } else {
    [window orderOut:nil];
  }
  if (active && visible) {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  }

  [box retain];
  return (uint64_t)(void *)box;
}

MOONBIT_FFI_EXPORT
void mbw_close_window(uint64_t handle) {
  if (handle == 0) {
    return;
  }
  MBWWindowBox *box = (MBWWindowBox *)(void *)handle;
  if (box.window == nil) {
    [box release];
    return;
  }
  box.delegate.allowClose = YES;
  [box.window close];
  box.window.delegate = nil;
  box.window = nil;
  [box release];
}

MOONBIT_FFI_EXPORT
void mbw_window_show(uint64_t handle, int32_t active) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  if (active) {
    [box.window makeKeyAndOrderFront:nil];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  } else {
    [box.window orderFront:nil];
  }
}

MOONBIT_FFI_EXPORT
void mbw_window_set_visible(uint64_t handle, int32_t visible) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  if (visible) {
    [box.window orderFront:nil];
  } else {
    [box.window orderOut:nil];
  }
}

MOONBIT_FFI_EXPORT
void mbw_window_set_resizable(uint64_t handle, int32_t resizable) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  NSUInteger style = box.window.styleMask;
  if (resizable) {
    style |= NSWindowStyleMaskResizable;
  } else {
    style &= ~NSWindowStyleMaskResizable;
  }
  box.window.styleMask = style;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_title(uint64_t handle, const char *title) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  box.window.title = mbw_string_from_utf8(title);
}

MOONBIT_FFI_EXPORT
void mbw_window_focus(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  [box.window makeKeyAndOrderFront:nil];
  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}

MOONBIT_FFI_EXPORT
void mbw_window_set_content_size(uint64_t handle, int32_t width, int32_t height) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  NSSize size = NSMakeSize((CGFloat)(width > 0 ? width : 1), (CGFloat)(height > 0 ? height : 1));
  [box.window setContentSize:size];
}

MOONBIT_FFI_EXPORT
void mbw_window_set_min_content_size(uint64_t handle, int32_t width, int32_t height) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  NSSize size = NSMakeSize((CGFloat)(width > 0 ? width : 0), (CGFloat)(height > 0 ? height : 0));
  [box.window setContentMinSize:size];
}

MOONBIT_FFI_EXPORT
void mbw_window_set_max_content_size(uint64_t handle, int32_t width, int32_t height) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  NSSize size =
      NSMakeSize((CGFloat)(width > 0 ? width : CGFLOAT_MAX), (CGFloat)(height > 0 ? height : CGFLOAT_MAX));
  [box.window setContentMaxSize:size];
}

MOONBIT_FFI_EXPORT
void mbw_window_set_resize_increments(uint64_t handle, int32_t width, int32_t height) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  CGFloat x = (CGFloat)(width > 0 ? width : 1);
  CGFloat y = (CGFloat)(height > 0 ? height : 1);
  [box.window setContentResizeIncrements:NSMakeSize(x, y)];
}

MOONBIT_FFI_EXPORT
void mbw_window_set_position(uint64_t handle, int32_t x, int32_t y) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  [box.window setFrameOrigin:NSMakePoint((CGFloat)x, (CGFloat)y)];
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_content_width(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 800;
  }
  NSRect contentRect = [box.window contentRectForFrameRect:box.window.frame];
  return (int32_t)contentRect.size.width;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_content_height(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 600;
  }
  NSRect contentRect = [box.window contentRectForFrameRect:box.window.frame];
  return (int32_t)contentRect.size.height;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_min_content_width(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  NSSize min_size = box.window.contentMinSize;
  return min_size.width > 0 ? (int32_t)min_size.width : 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_min_content_height(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  NSSize min_size = box.window.contentMinSize;
  return min_size.height > 0 ? (int32_t)min_size.height : 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_max_content_width(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  NSSize max_size = box.window.contentMaxSize;
  return max_size.width >= (CGFloat)(CGFLOAT_MAX / 2.0) ? 0 : (int32_t)max_size.width;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_max_content_height(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  NSSize max_size = box.window.contentMaxSize;
  return max_size.height >= (CGFloat)(CGFLOAT_MAX / 2.0) ? 0 : (int32_t)max_size.height;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_outer_width(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  return (int32_t)box.window.frame.size.width;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_outer_height(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  return (int32_t)box.window.frame.size.height;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_resize_increment_width(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  NSSize increments = box.window.contentResizeIncrements;
  return increments.width > 1 ? (int32_t)increments.width : 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_resize_increment_height(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  NSSize increments = box.window.contentResizeIncrements;
  return increments.height > 1 ? (int32_t)increments.height : 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_safe_area_top(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil || box.window.contentView == nil) {
    return 0;
  }
  NSView *view = box.window.contentView;
  if (![view respondsToSelector:@selector(safeAreaInsets)]) {
    return 0;
  }
  NSEdgeInsets insets = view.safeAreaInsets;
  return (int32_t)insets.top;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_safe_area_left(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil || box.window.contentView == nil) {
    return 0;
  }
  NSView *view = box.window.contentView;
  if (![view respondsToSelector:@selector(safeAreaInsets)]) {
    return 0;
  }
  NSEdgeInsets insets = view.safeAreaInsets;
  return (int32_t)insets.left;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_safe_area_bottom(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil || box.window.contentView == nil) {
    return 0;
  }
  NSView *view = box.window.contentView;
  if (![view respondsToSelector:@selector(safeAreaInsets)]) {
    return 0;
  }
  NSEdgeInsets insets = view.safeAreaInsets;
  return (int32_t)insets.bottom;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_safe_area_right(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil || box.window.contentView == nil) {
    return 0;
  }
  NSView *view = box.window.contentView;
  if (![view respondsToSelector:@selector(safeAreaInsets)]) {
    return 0;
  }
  NSEdgeInsets insets = view.safeAreaInsets;
  return (int32_t)insets.right;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_window_current_monitor_id(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  NSScreen *screen = box.window.screen;
  if (screen == nil) {
    screen = [NSScreen mainScreen];
  }
  if (screen == nil) {
    return 0;
  }
  NSDictionary *description = [screen deviceDescription];
  NSNumber *number = [description objectForKey:@"NSScreenNumber"];
  if (number == nil) {
    return 0;
  }
  return (uint64_t)[number unsignedIntValue];
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_x(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  return (int32_t)box.window.frame.origin.x;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_y(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  return (int32_t)box.window.frame.origin.y;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_has_focus(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  return box.window.keyWindow ? 1 : 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_is_occluded(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  BOOL occluded = (box.window.occlusionState & NSWindowOcclusionStateVisible) == 0;
  return occluded ? 1 : 0;
}

MOONBIT_FFI_EXPORT
double mbw_window_scale_factor(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 1.0;
  }
  double scale = box.window.backingScaleFactor;
  return scale > 0.0 ? scale : 1.0;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_minimized(uint64_t handle, int32_t minimized) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  if (minimized) {
    [box.window miniaturize:nil];
  } else {
    [box.window deminiaturize:nil];
  }
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_is_minimized(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  return box.window.miniaturized ? 1 : 0;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_maximized(uint64_t handle, int32_t maximized) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  BOOL isZoomed = box.window.zoomed;
  if ((maximized && !isZoomed) || (!maximized && isZoomed)) {
    [box.window zoom:nil];
  }
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_is_maximized(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  return box.window.zoomed ? 1 : 0;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_fullscreen(uint64_t handle, int32_t fullscreen) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  BOOL isFullscreen = (box.window.styleMask & NSWindowStyleMaskFullScreen) != 0;
  if ((fullscreen && !isFullscreen) || (!fullscreen && isFullscreen)) {
    [box.window toggleFullScreen:nil];
  }
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_is_fullscreen(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  return (box.window.styleMask & NSWindowStyleMaskFullScreen) != 0 ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_window_style_mask(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  return (uint64_t)box.window.styleMask;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_style_mask(uint64_t handle, uint64_t style_mask) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  box.window.styleMask = (NSUInteger)style_mask;
}

MOONBIT_FFI_EXPORT
void mbw_window_clear_style_mask_bits(uint64_t handle, uint64_t style_mask) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  box.window.styleMask = box.window.styleMask & (~(NSUInteger)style_mask);
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_num_tabs(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 1;
  }
  if (![box.window respondsToSelector:@selector(tabbedWindows)]) {
    return 1;
  }
  NSArray *tabbed = [box.window tabbedWindows];
  if (tabbed == nil || tabbed.count == 0) {
    return 1;
  }
  return (int32_t)tabbed.count;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_theme(uint64_t handle, int32_t theme) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  if (theme == 1) {
    box.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
  } else if (theme == 2) {
    box.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
  } else {
    box.window.appearance = nil;
  }
}

MOONBIT_FFI_EXPORT
void mbw_window_set_has_shadow(uint64_t handle, int32_t has_shadow) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  box.window.hasShadow = has_shadow ? YES : NO;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_document_edited(uint64_t handle, int32_t edited) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  box.window.documentEdited = edited ? YES : NO;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_level(uint64_t handle, int32_t level) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  if (level == 1) {
    box.window.level = NSFloatingWindowLevel;
  } else if (level == 2) {
    box.window.level = NSNormalWindowLevel - 1;
  } else {
    box.window.level = NSNormalWindowLevel;
  }
}

MOONBIT_FFI_EXPORT
void mbw_window_set_movable_by_window_background(uint64_t handle, int32_t movable) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  box.window.movableByWindowBackground = movable ? YES : NO;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_accepts_first_mouse(uint64_t handle, int32_t accepts_first_mouse) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.contentView == nil) {
    return;
  }
  box.contentView.acceptsFirstMouseEnabled = accepts_first_mouse ? YES : NO;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_option_as_alt(uint64_t handle, int32_t option_as_alt) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.contentView == nil) {
    return;
  }
  box.contentView.optionAsAlt = option_as_alt;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_ime_purpose(uint64_t handle, int32_t purpose) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.contentView == nil) {
    return;
  }
  box.contentView.imePurpose = purpose;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_ime_hints(uint64_t handle, int32_t hints) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.contentView == nil) {
    return;
  }
  box.contentView.imeHints = hints;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_ime_allowed(uint64_t handle, int32_t allowed) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.contentView == nil) {
    return;
  }
  BOOL next = allowed ? YES : NO;
  if (!next && box.contentView.imeActive) {
    [box.contentView mbw_emitTextInputWithKind:8
                                             x:0.0
                                             y:0.0
                                          state:4
                                           text:@""
                                    cursorStart:-1
                                      cursorEnd:-1
                                           path:nil];
    box.contentView.imeActive = NO;
    box.contentView.markedText = @"";
  }
  box.contentView.imeAllowed = next;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_ime_cursor_area(uint64_t handle, int32_t x, int32_t y, int32_t width,
                                    int32_t height) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.contentView == nil) {
    return;
  }
  box.contentView.imeCursorX = x;
  box.contentView.imeCursorY = y;
  box.contentView.imeCursorWidth = width > 0 ? width : 1;
  box.contentView.imeCursorHeight = height > 0 ? height : 1;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_titlebar_transparent(uint64_t handle, int32_t transparent) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  box.window.titlebarAppearsTransparent = transparent ? YES : NO;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_title_hidden(uint64_t handle, int32_t hidden) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  box.window.titleVisibility = hidden ? NSWindowTitleHidden : NSWindowTitleVisible;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_titlebar_hidden(uint64_t handle, int32_t hidden) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  NSUInteger style = box.window.styleMask;
  if (hidden) {
    box.window.titleVisibility = NSWindowTitleHidden;
    box.window.titlebarAppearsTransparent = YES;
    style |= NSWindowStyleMaskFullSizeContentView;
  } else {
    box.window.titleVisibility = NSWindowTitleVisible;
    box.window.titlebarAppearsTransparent = NO;
    style &= ~NSWindowStyleMaskFullSizeContentView;
  }
  box.window.styleMask = style;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_titlebar_buttons_hidden(uint64_t handle, int32_t hidden) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  NSButton *close_button = [box.window standardWindowButton:NSWindowCloseButton];
  NSButton *mini_button = [box.window standardWindowButton:NSWindowMiniaturizeButton];
  NSButton *zoom_button = [box.window standardWindowButton:NSWindowZoomButton];
  BOOL value = hidden ? YES : NO;
  if (close_button != nil) {
    close_button.hidden = value;
  }
  if (mini_button != nil) {
    mini_button.hidden = value;
  }
  if (zoom_button != nil) {
    zoom_button.hidden = value;
  }
}

MOONBIT_FFI_EXPORT
void mbw_window_set_fullsize_content_view(uint64_t handle, int32_t enabled) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  NSUInteger style = box.window.styleMask;
  if (enabled) {
    style |= NSWindowStyleMaskFullSizeContentView;
  } else {
    style &= ~NSWindowStyleMaskFullSizeContentView;
  }
  box.window.styleMask = style;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_unified_titlebar(uint64_t handle, int32_t unified_titlebar) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  if (unified_titlebar) {
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"window-unified-titlebar"];
    box.window.toolbar = toolbar;
    if ([box.window respondsToSelector:@selector(setToolbarStyle:)]) {
      box.window.toolbarStyle = NSWindowToolbarStyleUnified;
    }
    [toolbar release];
  } else {
    box.window.toolbar = nil;
    if ([box.window respondsToSelector:@selector(setToolbarStyle:)]) {
      box.window.toolbarStyle = NSWindowToolbarStyleAutomatic;
    }
  }
}

MOONBIT_FFI_EXPORT
void mbw_window_set_enabled_buttons(uint64_t handle, int32_t close, int32_t minimize,
                                    int32_t maximize) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  NSButton *close_button = [box.window standardWindowButton:NSWindowCloseButton];
  NSButton *mini_button = [box.window standardWindowButton:NSWindowMiniaturizeButton];
  NSButton *zoom_button = [box.window standardWindowButton:NSWindowZoomButton];
  if (close_button != nil) {
    close_button.enabled = close ? YES : NO;
  }
  if (mini_button != nil) {
    mini_button.enabled = minimize ? YES : NO;
  }
  if (zoom_button != nil) {
    zoom_button.enabled = maximize ? YES : NO;
  }
}

MOONBIT_FFI_EXPORT
void mbw_window_set_blur(uint64_t handle, int32_t blur) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }

  typedef int32_t (*mbw_cgs_main_connection_id_t)(void);
  typedef int32_t (*mbw_cgs_set_blur_t)(int32_t, int32_t, int32_t);

  mbw_cgs_main_connection_id_t main_connection =
      (mbw_cgs_main_connection_id_t)dlsym(RTLD_DEFAULT, "CGSMainConnectionID");
  mbw_cgs_set_blur_t set_blur = (mbw_cgs_set_blur_t)dlsym(
      RTLD_DEFAULT, "CGSSetWindowBackgroundBlurRadius");
  if (main_connection == NULL || set_blur == NULL) {
    return;
  }

  int32_t radius = blur ? 80 : 0;
  (void)set_blur(main_connection(), (int32_t)box.window.windowNumber, radius);
}

MOONBIT_FFI_EXPORT
void mbw_window_request_user_attention(int32_t request_type) {
  mbw_ensure_app_initialized();
  if (request_type == 0) {
    return;
  }
  NSRequestUserAttentionType attention =
      request_type == 1 ? NSCriticalRequest : NSInformationalRequest;
  [[NSApplication sharedApplication] requestUserAttention:attention];
}

MOONBIT_FFI_EXPORT
void mbw_window_set_movable(uint64_t handle, int32_t movable) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  box.window.movable = movable ? YES : NO;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_transparent(uint64_t handle, int32_t transparent) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  if (transparent) {
    box.window.opaque = NO;
    box.window.backgroundColor = [NSColor clearColor];
  } else {
    box.window.opaque = YES;
    box.window.backgroundColor = [NSColor windowBackgroundColor];
  }
}

MOONBIT_FFI_EXPORT
void mbw_window_set_parent(uint64_t handle, uint64_t parent_handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  NSWindow *parent_window = mbw_window_from_box_or_native_handle(parent_handle);
  if (box == nil || box.window == nil || parent_window == nil) {
    return;
  }
  [parent_window addChildWindow:box.window ordered:NSWindowAbove];
}

MOONBIT_FFI_EXPORT
void mbw_window_set_content_protected(uint64_t handle, int32_t content_protected) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  box.window.sharingType = content_protected ? NSWindowSharingNone : NSWindowSharingReadOnly;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_tabbing_identifier(uint64_t handle, const char *identifier) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  box.window.tabbingIdentifier = mbw_string_from_utf8(identifier);
}

MOONBIT_FFI_EXPORT
void mbw_window_set_tabbing_mode_preferred(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  if ([box.window respondsToSelector:@selector(setTabbingMode:)]) {
    box.window.tabbingMode = NSWindowTabbingModePreferred;
  }
}

MOONBIT_FFI_EXPORT
void mbw_window_select_next_tab(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  [box.window selectNextTab:nil];
}

MOONBIT_FFI_EXPORT
void mbw_window_select_previous_tab(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  [box.window selectPreviousTab:nil];
}

MOONBIT_FFI_EXPORT
void mbw_window_select_tab_at_index(uint64_t handle, int32_t index) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil || index < 0) {
    return;
  }
  if (![box.window respondsToSelector:@selector(tabbedWindows)]) {
    return;
  }
  NSArray *tabbed = [box.window tabbedWindows];
  if (tabbed == nil || tabbed.count == 0) {
    return;
  }
  if ((NSUInteger)index >= tabbed.count) {
    return;
  }
  NSWindow *selected = [tabbed objectAtIndex:(NSUInteger)index];
  [selected makeKeyAndOrderFront:nil];
}

MOONBIT_FFI_EXPORT
void mbw_window_set_cursor(uint64_t handle, int32_t cursor) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return;
  }
  NSCursor *native_cursor = mbw_cursor_from_kind(cursor);
  [native_cursor set];
  NSView *content_view = box.window.contentView;
  if (content_view != nil) {
    [content_view discardCursorRects];
    [content_view addCursorRect:content_view.bounds cursor:native_cursor];
  }
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
uint64_t mbw_custom_cursor_create_url(const char *url, int32_t hotspot_x, int32_t hotspot_y) {
  if (hotspot_x < 0 || hotspot_y < 0) {
    return 0;
  }
  NSURL *nsurl = mbw_url_from_utf8(url);
  if (nsurl == nil) {
    return 0;
  }
  NSImage *image = [[NSImage alloc] initWithContentsOfURL:nsurl];
  if (image == nil) {
    return 0;
  }
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
int32_t mbw_window_set_custom_cursor(uint64_t handle, uint64_t custom_cursor) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil || custom_cursor == 0) {
    return 0;
  }
  id cursor_obj = (__bridge id)(void *)custom_cursor;
  if (cursor_obj == nil || ![cursor_obj isKindOfClass:[NSCursor class]]) {
    return 0;
  }
  NSCursor *cursor = (NSCursor *)cursor_obj;
  [cursor set];
  NSView *content_view = box.window.contentView;
  if (content_view != nil) {
    [content_view discardCursorRects];
    [content_view addCursorRect:content_view.bounds cursor:cursor];
  }
  return 1;
}

MOONBIT_FFI_EXPORT
void mbw_window_set_cursor_visible(uint64_t handle, int32_t visible) {
  (void)handle;
  BOOL should_show = visible ? YES : NO;
  if (should_show && g_cursor_hidden) {
    [NSCursor unhide];
    g_cursor_hidden = NO;
  } else if (!should_show && !g_cursor_hidden) {
    [NSCursor hide];
    g_cursor_hidden = YES;
  }
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_set_cursor_hittest(uint64_t handle, int32_t hittest) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  box.window.ignoresMouseEvents = hittest ? NO : YES;
  return 1;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_set_cursor_position(uint64_t handle, int32_t x, int32_t y) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  NSRect content_rect = [box.window contentRectForFrameRect:box.window.frame];
  CGPoint point = CGPointMake(content_rect.origin.x + (CGFloat)x,
                              content_rect.origin.y + content_rect.size.height - (CGFloat)y);
  CGError warp_err = CGWarpMouseCursorPosition(point);
  if (warp_err != kCGErrorSuccess) {
    return 0;
  }
  CGError associate_err = CGAssociateMouseAndMouseCursorPosition(true);
  return associate_err == kCGErrorSuccess ? 1 : 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_set_cursor_grab(uint64_t handle, int32_t mode) {
  (void)handle;
  if (mode == 0) {
    CGError err = CGAssociateMouseAndMouseCursorPosition(true);
    return err == kCGErrorSuccess ? 1 : 0;
  }
  if (mode == 1) {
    CGError err = CGAssociateMouseAndMouseCursorPosition(false);
    return err == kCGErrorSuccess ? 1 : 0;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_drag_window(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  NSEvent *event = [NSApp currentEvent];
  if (event == nil) {
    return 0;
  }
  if ([box.window respondsToSelector:@selector(performWindowDragWithEvent:)]) {
    [box.window performWindowDragWithEvent:event];
    return 1;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_drag_resize_window(uint64_t handle, int32_t direction) {
  (void)handle;
  (void)direction;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_show_window_menu(uint64_t handle, int32_t x, int32_t y) {
  (void)handle;
  (void)x;
  (void)y;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_theme(uint64_t handle) {
  MBWWindowBox *box = mbw_window_box_from_handle(handle);
  if (box == nil || box.window == nil) {
    return 0;
  }
  NSAppearance *appearance = box.window.effectiveAppearance;
  NSArray<NSAppearanceName> *names = @[ NSAppearanceNameAqua, NSAppearanceNameDarkAqua ];
  NSAppearanceName best = [appearance bestMatchFromAppearancesWithNames:names];
  if ([best isEqualToString:NSAppearanceNameDarkAqua]) {
    return 2;
  }
  if ([best isEqualToString:NSAppearanceNameAqua]) {
    return 1;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_application_presentation_options(void) {
  mbw_ensure_app_initialized();
  NSApplication *app = [NSApplication sharedApplication];
  return (uint64_t)app.presentationOptions;
}

MOONBIT_FFI_EXPORT
void mbw_set_application_presentation_options(uint64_t options) {
  mbw_ensure_app_initialized();
  NSApplication *app = [NSApplication sharedApplication];
  app.presentationOptions = (NSApplicationPresentationOptions)options;
}

MOONBIT_FFI_EXPORT
void mbw_application_hide(void) {
  mbw_ensure_app_initialized();
  [[NSApplication sharedApplication] hide:nil];
}

MOONBIT_FFI_EXPORT
void mbw_application_hide_other_applications(void) {
  mbw_ensure_app_initialized();
  [[NSApplication sharedApplication] hideOtherApplications:nil];
}

MOONBIT_FFI_EXPORT
void mbw_application_set_allows_automatic_window_tabbing(int32_t enabled) {
  if ([NSWindow respondsToSelector:@selector(setAllowsAutomaticWindowTabbing:)]) {
    [NSWindow setAllowsAutomaticWindowTabbing:(enabled ? YES : NO)];
  }
}

MOONBIT_FFI_EXPORT
int32_t mbw_application_allows_automatic_window_tabbing(void) {
  if ([NSWindow respondsToSelector:@selector(allowsAutomaticWindowTabbing)]) {
    return [NSWindow allowsAutomaticWindowTabbing] ? 1 : 0;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
void mbw_application_set_activation_policy(int32_t activation_policy) {
  mbw_ensure_app_initialized();
  NSApplicationActivationPolicy policy = NSApplicationActivationPolicyRegular;
  if (activation_policy == 1) {
    policy = NSApplicationActivationPolicyAccessory;
  } else if (activation_policy == 2) {
    policy = NSApplicationActivationPolicyProhibited;
  }
  [[NSApplication sharedApplication] setActivationPolicy:policy];
}

MOONBIT_FFI_EXPORT
void mbw_application_set_activate_ignoring_other_apps(
    int32_t activate_ignoring_other_apps) {
  mbw_ensure_app_initialized();
  [[NSApplication sharedApplication]
      activateIgnoringOtherApps:(activate_ignoring_other_apps ? YES : NO)];
}

MOONBIT_FFI_EXPORT
void mbw_application_initialize_default_menu(int32_t enabled) {
  mbw_ensure_app_initialized();
  if (enabled) {
    mbw_install_default_menu();
  } else {
    [[NSApplication sharedApplication] setMainMenu:nil];
  }
}

MOONBIT_FFI_EXPORT
void mbw_event_loop_wake_up(void) {
  mbw_ensure_app_initialized();
  NSEvent *event = [NSEvent otherEventWithType:NSEventTypeApplicationDefined
                                      location:NSZeroPoint
                                 modifierFlags:0
                                     timestamp:0
                                  windowNumber:0
                                       context:nil
                                       subtype:0
                                         data1:0
                                         data2:0];
  [[NSApplication sharedApplication] postEvent:event atStart:NO];
}

MOONBIT_FFI_EXPORT
int32_t mbw_event_loop_wait_millis(int32_t timeout_ms) {
  mbw_ensure_app_initialized();
  NSApplication *app = [NSApplication sharedApplication];
  NSDate *until = timeout_ms < 0 ? [NSDate distantFuture]
                                 : [NSDate dateWithTimeIntervalSinceNow:((double)timeout_ms) / 1000.0];
  NSEvent *event = [app nextEventMatchingMask:NSEventMaskAny
                                    untilDate:until
                                       inMode:NSDefaultRunLoopMode
                                      dequeue:YES];
  if (event == nil) {
    return 0;
  }
  [app sendEvent:event];
  [app updateWindows];
  return 1;
}
