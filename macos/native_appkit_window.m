#import "native_appkit_bridge.h"

static NSString *mbw_drag_paths_string(id<NSDraggingInfo> sender) {
  if (sender == nil) {
    return @"";
  }
  NSPasteboard *pasteboard = [sender draggingPasteboard];
  if (pasteboard == nil) {
    return @"";
  }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  NSArray *paths = [pasteboard propertyListForType:NSFilenamesPboardType];
#pragma clang diagnostic pop
  if (![paths isKindOfClass:[NSArray class]] || paths.count == 0) {
    return @"";
  }
  NSMutableArray<NSString *> *strings = [NSMutableArray arrayWithCapacity:paths.count];
  for (id path in paths) {
    if ([path isKindOfClass:[NSString class]] && [(NSString *)path length] > 0) {
      [strings addObject:(NSString *)path];
    }
  }
  if (strings.count == 0) {
    return @"";
  }
  return [strings componentsJoinedByString:@"\n"];
}

static BOOL mbw_drag_has_paths(id<NSDraggingInfo> sender) {
  return [mbw_drag_paths_string(sender) length] > 0;
}

static NSPoint mbw_drag_location_in_content_view(id<NSDraggingInfo> sender) {
  if (sender == nil) {
    return NSZeroPoint;
  }
  NSPoint location = [sender draggingLocation];
  NSWindow *window = [sender draggingDestinationWindow];
  NSView *content_view = [window contentView];
  if (content_view != nil) {
    return [content_view convertPoint:location fromView:nil];
  }
  return location;
}

static double mbw_drag_scale_factor(id<NSDraggingInfo> sender) {
  if (sender == nil) {
    return 1.0;
  }
  NSWindow *window = [sender draggingDestinationWindow];
  if (window == nil || window.backingScaleFactor <= 0.0) {
    return 1.0;
  }
  return (double)window.backingScaleFactor;
}

static void mbw_emit_drag_event(int32_t raw_id, int32_t kind, id<NSDraggingInfo> sender) {
  if (raw_id <= 0) {
    return;
  }
  NSString *paths = mbw_drag_paths_string(sender);
  NSPoint location = mbw_drag_location_in_content_view(sender);
  double scale = mbw_drag_scale_factor(sender);
  const char *path_cstr = paths == nil ? "" : [paths UTF8String];
  mbw_call_drag_event_trampoline(raw_id, kind, (double)location.x * scale,
                                 (double)location.y * scale, sender == nil ? 0 : 1,
                                 (uint64_t)(uintptr_t)(path_cstr == NULL ? "" : path_cstr));
}

@interface MBWContentView : NSView <NSTextInputClient>
@property(nonatomic, assign) int32_t rawId;
@property(nonatomic, retain) NSMutableAttributedString *markedText;
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

@interface MBWWindowBox : NSObject
@property(nonatomic, strong) NSWindow *window;
@property(nonatomic, strong) MBWWindowDelegate *delegate;
@property(nonatomic, strong) MBWContentView *contentView;
@end

@implementation MBWContentView

- (instancetype)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self != nil) {
    self.markedText = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
    NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |
                                    NSTrackingActiveAlways | NSTrackingInVisibleRect;
    NSTrackingArea *tracking_area = [[NSTrackingArea alloc] initWithRect:NSZeroRect
                                                                  options:options
                                                                    owner:self
                                                                 userInfo:nil];
    if (tracking_area != nil) {
      [self addTrackingArea:tracking_area];
      [tracking_area release];
    }
  }
  return self;
}

- (void)dealloc {
  [_markedText release];
  [super dealloc];
}

- (BOOL)isFlipped {
  return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)event {
  (void)event;
  return mbw_sync_query(self.rawId, MBW_VIEW_STATE_QUERY_ACCEPTS_FIRST_MOUSE, 0, 0) != 0;
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (void)mbw_emitInputWithKind:(int32_t)kind event:(NSEvent *)event {
  if (self.rawId <= 0) {
    return;
  }
  uint64_t event_handle = 0;
  if (event != nil) {
    [event retain];
    event_handle = (uint64_t)(uintptr_t)(__bridge void *)event;
  }
  mbw_call_input_event_trampoline(self.rawId, kind, event_handle);
  if (event != nil) {
    [event release];
  }
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

// Normalize NSTextInputClient text payload into an attributed string snapshot.
- (NSMutableAttributedString *)mbw_markedTextFromObject:(id)text {
  if ([text isKindOfClass:[NSAttributedString class]]) {
    return [[[NSMutableAttributedString alloc] initWithAttributedString:(NSAttributedString *)text]
        autorelease];
  }
  if ([text isKindOfClass:[NSString class]]) {
    return [[[NSMutableAttributedString alloc] initWithString:(NSString *)text] autorelease];
  }
  if (text != nil) {
    return [[[NSMutableAttributedString alloc] initWithString:[text description]] autorelease];
  }
  return [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
}

- (void)mbw_clearMarkedText {
  self.markedText = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
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
  if (mbw_sync_query(self.rawId, MBW_VIEW_STATE_QUERY_IME_ALLOWED, 0, 0) != 0) {
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
  return mbw_sync_query(self.rawId, MBW_VIEW_STATE_QUERY_MARKED_TEXT_LENGTH, 0, 0) > 0;
}

- (NSRange)markedRange {
  int32_t marked_text_length =
      mbw_sync_query(self.rawId, MBW_VIEW_STATE_QUERY_MARKED_TEXT_LENGTH, 0, 0);
  if (marked_text_length <= 0) {
    return NSMakeRange(NSNotFound, 0);
  }
  return NSMakeRange(0, (NSUInteger)marked_text_length);
}

- (NSRange)selectedRange {
  int32_t location =
      mbw_sync_query(self.rawId, MBW_VIEW_STATE_QUERY_SELECTED_RANGE_LOCATION, 0, -1);
  if (location < 0) {
    return NSMakeRange(NSNotFound, 0);
  }
  int32_t length = mbw_sync_query(self.rawId, MBW_VIEW_STATE_QUERY_SELECTED_RANGE_LENGTH, 0, 0);
  if (length < 0) {
    length = 0;
  }
  return NSMakeRange((NSUInteger)location, (NSUInteger)length);
}

- (void)setMarkedText:(id)string
        selectedRange:(NSRange)selectedRange
     replacementRange:(NSRange)replacementRange {
  (void)replacementRange;
  self.markedText = [self mbw_markedTextFromObject:string];
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
  [self mbw_clearMarkedText];
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
  NSUInteger marked_length = self.markedText.length;
  if (marked_length == 0 || range.location == NSNotFound || range.location >= marked_length) {
    if (actualRange != NULL) {
      *actualRange = NSMakeRange(NSNotFound, 0);
    }
    return nil;
  }

  NSUInteger length = range.length;
  NSUInteger max_length = marked_length - range.location;
  if (length > max_length) {
    length = max_length;
  }
  NSRange clamped = NSMakeRange(range.location, length);
  if (actualRange != NULL) {
    *actualRange = clamped;
  }
  return [self.markedText attributedSubstringFromRange:clamped];
}

- (NSUInteger)characterIndexForPoint:(NSPoint)point {
  (void)point;
  int32_t location =
      mbw_sync_query(self.rawId, MBW_VIEW_STATE_QUERY_SELECTED_RANGE_LOCATION, 0, -1);
  if (location < 0) {
    return NSNotFound;
  }
  return (NSUInteger)location;
}

- (NSRect)firstRectForCharacterRange:(NSRange)range actualRange:(NSRangePointer)actualRange {
  (void)range;
  (void)actualRange;
  CGFloat x =
      (CGFloat)mbw_sync_query(self.rawId, MBW_VIEW_STATE_QUERY_IME_CURSOR_X, 0, 0);
  CGFloat y =
      (CGFloat)mbw_sync_query(self.rawId, MBW_VIEW_STATE_QUERY_IME_CURSOR_Y, 0, 0);
  NSSize size = NSMakeSize(
      (CGFloat)mbw_sync_query(self.rawId, MBW_VIEW_STATE_QUERY_IME_CURSOR_WIDTH, 0, 1),
      (CGFloat)mbw_sync_query(self.rawId, MBW_VIEW_STATE_QUERY_IME_CURSOR_HEIGHT, 0, 1));
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
  [self mbw_clearMarkedText];
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
  if (!mbw_drag_has_paths(sender)) {
    return NSDragOperationNone;
  }
  mbw_emit_drag_event(self.rawId, 9, sender);
  return NSDragOperationCopy;
}

- (BOOL)wantsPeriodicDraggingUpdates {
  return YES;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
  if (!mbw_drag_has_paths(sender)) {
    return NSDragOperationNone;
  }
  mbw_emit_drag_event(self.rawId, 10, sender);
  return NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
  mbw_emit_drag_event(self.rawId, 12, sender);
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
  return mbw_drag_has_paths(sender);
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
  if (!mbw_drag_has_paths(sender)) {
    return NO;
  }
  mbw_emit_drag_event(self.rawId, 11, sender);
  return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender {
  (void)sender;
}

@end

@implementation MBWWindowBox
@end

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
