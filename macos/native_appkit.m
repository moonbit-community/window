#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>
#import <Foundation/Foundation.h>
#import <moonbit.h>
#import <stdint.h>

typedef void (*mbw_window_event_trampoline_t)(void *closure, int32_t kind, int32_t raw_id,
                                              int32_t arg0, int32_t arg1, int32_t arg2,
                                              double argd);
typedef void (*mbw_lifecycle_trampoline_t)(void *closure, int32_t kind);

static mbw_window_event_trampoline_t g_window_event_trampoline = NULL;
static void *g_window_event_closure = NULL;
static mbw_lifecycle_trampoline_t g_lifecycle_trampoline = NULL;
static void *g_lifecycle_closure = NULL;
static BOOL g_app_initialized = NO;
static BOOL g_cursor_hidden = NO;

@interface MBWWindowDelegate : NSObject <NSWindowDelegate>
@property(nonatomic, assign) int32_t rawId;
@property(nonatomic, assign) BOOL allowClose;
@end

@interface MBWWindowBox : NSObject
@property(nonatomic, strong) NSWindow *window;
@property(nonatomic, strong) MBWWindowDelegate *delegate;
@property(nonatomic, assign) int32_t rawId;
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

  MBWWindowBox *box = [[MBWWindowBox alloc] init];
  box.window = window;
  box.delegate = delegate;
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
int32_t mbw_window_set_custom_cursor(uint64_t handle, uint64_t custom_cursor) {
  (void)handle;
  (void)custom_cursor;
  return 0;
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
  CGWarpMouseCursorPosition(point);
  return 1;
}

MOONBIT_FFI_EXPORT
int32_t mbw_window_set_cursor_grab(uint64_t handle, int32_t mode) {
  (void)handle;
  if (mode == 0) {
    CGAssociateMouseAndMouseCursorPosition(true);
    return 1;
  }
  if (mode == 1) {
    CGAssociateMouseAndMouseCursorPosition(false);
    return 1;
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
