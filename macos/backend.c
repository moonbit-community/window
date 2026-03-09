#include <stdbool.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

#include "moonbit.h"

#if defined(__APPLE__)
#include <CoreGraphics/CGDirectDisplay.h>
#include <Carbon/Carbon.h>
#include <objc/message.h>
#include <objc/runtime.h>
#endif

#define MBW_KEY_TEXT_CAP 64

typedef struct mbw_input_event {
  int kind;
  double x;
  double y;
  int scancode;
  int state;
  int button;
  int modifiers;
  int repeat;
  int pointer_source;
  int pointer_kind;
  int scroll_delta_kind;
  double delta_x;
  double delta_y;
  int phase;
  int text_with_all_modifiers_len;
  uint8_t text_with_all_modifiers[MBW_KEY_TEXT_CAP];
  int text_ignoring_modifiers_len;
  uint8_t text_ignoring_modifiers[MBW_KEY_TEXT_CAP];
  int text_without_modifiers_len;
  uint8_t text_without_modifiers[MBW_KEY_TEXT_CAP];
  int ime_kind;
  int ime_text_len;
  uint8_t ime_text[MBW_KEY_TEXT_CAP];
  int ime_cursor_start;
  int ime_cursor_end;
} mbw_input_event_t;

typedef struct mbw_window {
  int id;
  int width;
  int height;
  int x;
  int y;
  double scale_factor;
  double reported_scale_factor;
  int reported_position_valid;
  int reported_x;
  int reported_y;
  int pending_moved;
  int pending_move_x;
  int pending_move_y;
  int should_close;
  int allow_close;
  int pending_close_requested;
  int pending_destroyed;
  int pending_focused_changed;
  int focused;
  int maximized;
  int minimized;
  int fullscreen;
  int pending_focus_value;
  int theme_kind;
  int reported_theme_kind;
  int pending_theme_changed;
  int pending_theme_kind;
  int occluded;
  int reported_occluded;
  int pending_occluded_changed;
  int pending_occluded;
  int pending_scale_factor_changed;
  double pending_scale_factor;
  int pending_scale_width;
  int pending_scale_height;
  int pending_surface_resized;
  int pending_redraw_requested;
  int reported_width;
  int reported_height;
  int min_width;
  int min_height;
  int max_width;
  int max_height;
  int resize_increment_width;
  int resize_increment_height;
  int modifiers_state;
  int ime_marked_active;
  int ime_cursor_start;
  int ime_cursor_end;
  int ime_allowed;
  int ime_purpose;
  int ime_cursor_area_x;
  int ime_cursor_area_y;
  int ime_cursor_area_width;
  int ime_cursor_area_height;
  int visible;
  int resizable;
  int content_protected;
  int decorated;
  int close_button_enabled;
  int minimize_button_enabled;
  int maximize_button_enabled;
  int blur;
  int transparent;
  int window_level;
  mbw_input_event_t *queued_input_events;
  size_t queued_input_events_len;
  size_t queued_input_events_cap;
  mbw_input_event_t current_input_event;
#if defined(__APPLE__)
  void *window;
  void *content_view;
  void *delegate;
#endif
} mbw_window_t;

static mbw_window_t **g_windows = NULL;
static size_t g_windows_len = 0;
static size_t g_windows_cap = 0;
static int g_next_window_id = 1;
static atomic_int g_pending_proxy_wake_up = 0;
static int64_t g_now_ms_override_for_test = -1;

#define MBW_INPUT_EVENT_NONE 0
#define MBW_INPUT_EVENT_POINTER_MOVED 1
#define MBW_INPUT_EVENT_POINTER_ENTERED 2
#define MBW_INPUT_EVENT_POINTER_LEFT 3
#define MBW_INPUT_EVENT_POINTER_BUTTON 4
#define MBW_INPUT_EVENT_MOUSE_WHEEL 5
#define MBW_INPUT_EVENT_MODIFIERS_CHANGED 6
#define MBW_INPUT_EVENT_KEYBOARD_INPUT 7
#define MBW_INPUT_EVENT_IME 8

#define MBW_IME_EVENT_NONE 0
#define MBW_IME_EVENT_ENABLED 1
#define MBW_IME_EVENT_PREEDIT 2
#define MBW_IME_EVENT_COMMIT 3
#define MBW_IME_EVENT_DISABLED 4

#define MBW_IME_PURPOSE_NORMAL 0
#define MBW_IME_PURPOSE_PASSWORD 1
#define MBW_IME_PURPOSE_TERMINAL 2

#define MBW_WINDOW_LEVEL_NORMAL 0
#define MBW_WINDOW_LEVEL_ALWAYS_ON_TOP 1
#define MBW_WINDOW_LEVEL_ALWAYS_ON_BOTTOM 2

#define MBW_ELEMENT_STATE_NONE 0
#define MBW_ELEMENT_STATE_PRESSED 1
#define MBW_ELEMENT_STATE_RELEASED 2

#define MBW_POINTER_SOURCE_UNKNOWN 0
#define MBW_POINTER_SOURCE_MOUSE 1

#define MBW_POINTER_KIND_UNKNOWN 0
#define MBW_POINTER_KIND_MOUSE 1

#define MBW_SCROLL_DELTA_NONE 0
#define MBW_SCROLL_DELTA_LINE 1
#define MBW_SCROLL_DELTA_PIXEL 2

#define MBW_TOUCH_PHASE_NONE 0
#define MBW_TOUCH_PHASE_STARTED 1
#define MBW_TOUCH_PHASE_MOVED 2
#define MBW_TOUCH_PHASE_ENDED 3
#define MBW_TOUCH_PHASE_CANCELLED 4

#define MBW_MODIFIERS_SHIFT 1
#define MBW_MODIFIERS_CONTROL 2
#define MBW_MODIFIERS_ALT 4
#define MBW_MODIFIERS_META 8

void mbw_window_set_enabled_buttons(
  int window_id,
  bool close,
  bool minimize,
  bool maximize
);

static int mbw_clamp_size(int value) {
  return value <= 0 ? 1 : value;
}

static void mbw_apply_surface_constraints(
  mbw_window_t *window,
  int *width,
  int *height
) {
  if (!width || !height) {
    return;
  }
  *width = mbw_clamp_size(*width);
  *height = mbw_clamp_size(*height);
  if (window) {
    if (window->min_width > 0 && *width < window->min_width) {
      *width = window->min_width;
    }
    if (window->min_height > 0 && *height < window->min_height) {
      *height = window->min_height;
    }
    if (window->max_width > 0 && *width > window->max_width) {
      *width = window->max_width;
    }
    if (window->max_height > 0 && *height > window->max_height) {
      *height = window->max_height;
    }
  }
}

static mbw_window_t *mbw_find_window(int id) {
  for (size_t i = 0; i < g_windows_len; ++i) {
    if (g_windows[i] && g_windows[i]->id == id) {
      return g_windows[i];
    }
  }
  return NULL;
}

static void mbw_push_window(mbw_window_t *window) {
  if (g_windows_len + 1 > g_windows_cap) {
    size_t next_cap = g_windows_cap == 0 ? 8 : g_windows_cap * 2;
    mbw_window_t **next =
      (mbw_window_t **)realloc(g_windows, next_cap * sizeof(mbw_window_t *));
    if (!next) {
      return;
    }
    g_windows = next;
    g_windows_cap = next_cap;
  }
  g_windows[g_windows_len++] = window;
}

static bool mbw_push_input_event(
  mbw_window_t *window,
  const mbw_input_event_t *event
) {
  if (!window || !event) {
    return false;
  }
  if (window->queued_input_events_len + 1 > window->queued_input_events_cap) {
    size_t next_cap =
      window->queued_input_events_cap == 0 ? 8 : window->queued_input_events_cap * 2;
    mbw_input_event_t *next = (mbw_input_event_t *)realloc(
      window->queued_input_events,
      next_cap * sizeof(mbw_input_event_t));
    if (!next) {
      return false;
    }
    window->queued_input_events = next;
    window->queued_input_events_cap = next_cap;
  }
  window->queued_input_events[window->queued_input_events_len++] = *event;
  return true;
}

static char *mbw_copy_utf8(const uint8_t *bytes, uint64_t len) {
  size_t n = (size_t)len;
  char *out = (char *)malloc(n + 1);
  if (!out) {
    return NULL;
  }
  if (bytes && n > 0) {
    memcpy(out, bytes, n);
  }
  out[n] = '\0';
  return out;
}

#if defined(__APPLE__)
typedef signed char mbw_bool_t;
typedef double mbw_cgfloat_t;
typedef long mbw_nsinteger_t;
typedef unsigned long mbw_nsuint_t;

typedef struct {
  mbw_cgfloat_t x;
  mbw_cgfloat_t y;
} mbw_point_t;

typedef struct {
  mbw_cgfloat_t width;
  mbw_cgfloat_t height;
} mbw_size_t;

typedef struct {
  mbw_point_t origin;
  mbw_size_t size;
} mbw_rect_t;

typedef struct {
  mbw_nsuint_t location;
  mbw_nsuint_t length;
} mbw_range_t;

#ifndef YES
#define YES ((mbw_bool_t)1)
#endif

#ifndef NO
#define NO ((mbw_bool_t)0)
#endif

#define MBW_NSEVENT_TYPE_APPLICATION_DEFINED ((mbw_nsuint_t)15)
#define MBW_PROXY_WAKE_EVENT_SUBTYPE ((short)0x4d42)
#define MBW_THEME_UNKNOWN 0
#define MBW_THEME_LIGHT 1
#define MBW_THEME_DARK 2
#define MBW_NSWINDOW_STYLE_MASK_FULLSCREEN (1UL << 14)
#define MBW_NSWINDOW_OCCLUSION_STATE_VISIBLE (1UL << 1)
#define MBW_NSEVENT_PHASE_BEGAN (1UL << 0)
#define MBW_NSEVENT_PHASE_CHANGED (1UL << 2)
#define MBW_NSEVENT_PHASE_ENDED (1UL << 3)
#define MBW_NSEVENT_PHASE_CANCELLED (1UL << 4)
#define MBW_NSEVENT_PHASE_MAY_BEGIN (1UL << 5)
#define MBW_NSEVENT_MODIFIER_SHIFT (1UL << 17)
#define MBW_NSEVENT_MODIFIER_CONTROL (1UL << 18)
#define MBW_NSEVENT_MODIFIER_OPTION (1UL << 19)
#define MBW_NSEVENT_MODIFIER_COMMAND (1UL << 20)
#define MBW_NSEVENT_TYPE_KEY_UP ((mbw_nsuint_t)11)
#define MBW_NX_DEVICELCTLKEYMASK 0x00000001UL
#define MBW_NX_DEVICELSHIFTKEYMASK 0x00000002UL
#define MBW_NX_DEVICERSHIFTKEYMASK 0x00000004UL
#define MBW_NX_DEVICELCMDKEYMASK 0x00000008UL
#define MBW_NX_DEVICERCMDKEYMASK 0x00000010UL
#define MBW_NX_DEVICELALTKEYMASK 0x00000020UL
#define MBW_NX_DEVICERALTKEYMASK 0x00000040UL
#define MBW_NX_DEVICERCTLKEYMASK 0x00002000UL
#define MBW_NSTRACKING_MOUSE_ENTERED_AND_EXITED (1UL << 0)
#define MBW_NSTRACKING_MOUSE_MOVED (1UL << 1)
#define MBW_NSTRACKING_ACTIVE_ALWAYS (1UL << 7)
#define MBW_NSTRACKING_IN_VISIBLE_RECT (1UL << 9)
#define MBW_NS_NOT_FOUND ((mbw_nsuint_t)-1)
#define MBW_NSWINDOW_BUTTON_CLOSE ((mbw_nsinteger_t)0)
#define MBW_NSWINDOW_BUTTON_MINIMIZE ((mbw_nsinteger_t)1)
#define MBW_NSWINDOW_BUTTON_MAXIMIZE ((mbw_nsinteger_t)2)
#define MBW_NSWINDOW_SHARING_NONE ((mbw_nsuint_t)0)
#define MBW_NSWINDOW_SHARING_READ_ONLY ((mbw_nsuint_t)1)

static bool g_bootstrap_done = false;
static bool g_bootstrap_ok = false;
static id g_ns_app = nil;
static Class g_window_delegate_class = Nil;
static Class g_content_view_class = Nil;

static mbw_nsinteger_t mbw_native_window_level(int level) {
  switch (level) {
    case MBW_WINDOW_LEVEL_ALWAYS_ON_TOP:
      return (mbw_nsinteger_t)CGWindowLevelForKey(kCGFloatingWindowLevelKey);
    case MBW_WINDOW_LEVEL_ALWAYS_ON_BOTTOM:
      return (mbw_nsinteger_t)(CGWindowLevelForKey(kCGNormalWindowLevelKey) - 1);
    case MBW_WINDOW_LEVEL_NORMAL:
    default:
      return (mbw_nsinteger_t)CGWindowLevelForKey(kCGNormalWindowLevelKey);
  }
}

static id mbw_make_nsstring(const char *utf8);
static void mbw_update_window_state(mbw_window_t *window);
static int mbw_window_theme_kind(mbw_window_t *window);
static int mbw_window_occluded(mbw_window_t *window);
static void mbw_window_position(mbw_window_t *window, int *x, int *y);
static mbw_window_t *mbw_view_window(id view);
static id mbw_view_tracking_area(id view);
static void mbw_view_set_tracking_area(id view, id tracking_area);
static void mbw_view_refresh_tracking_area(id view);
static void mbw_view_pointer_position(id view, id event, double *x, double *y);
static int mbw_window_scroll_phase(id event);
static int mbw_event_modifiers_state(id event);
static mbw_nsuint_t mbw_event_modifier_device_flags(id event);
static bool mbw_modifier_active_for_scancode(id event, int scancode);
static void mbw_window_queue_pointer_moved(mbw_window_t *window, double x, double y);
static void mbw_window_queue_pointer_entered(mbw_window_t *window, double x, double y);
static void mbw_window_queue_pointer_left(mbw_window_t *window, double x, double y);
static void mbw_window_queue_modifiers_changed(mbw_window_t *window, int modifiers);
static void mbw_window_update_modifiers_from_event(mbw_window_t *window, id event);
static void mbw_window_queue_keyboard_input(
  mbw_window_t *window,
  int scancode,
  int state,
  int modifiers,
  int repeat,
  const uint8_t *text_with_all_modifiers,
  int text_with_all_modifiers_len,
  const uint8_t *text_ignoring_modifiers,
  int text_ignoring_modifiers_len,
  const uint8_t *text_without_modifiers,
  int text_without_modifiers_len
);
static void mbw_window_queue_ime(
  mbw_window_t *window,
  int ime_kind,
  const uint8_t *text,
  int text_len,
  int cursor_start,
  int cursor_end
);
static void mbw_window_queue_pointer_button(
  mbw_window_t *window,
  int state,
  double x,
  double y,
  int button
);
static void mbw_window_queue_mouse_wheel(
  mbw_window_t *window,
  int delta_kind,
  double delta_x,
  double delta_y,
  int phase
);
static int mbw_text_input_object_utf8(id text_input, uint8_t *dst, int dst_cap);

static SEL mbw_sel(const char *name) {
  return sel_registerName(name);
}

static id mbw_msg_id(id obj, const char *sel_name) {
  return ((id(*)(id, SEL))objc_msgSend)(obj, mbw_sel(sel_name));
}

static void mbw_msg_void(id obj, const char *sel_name) {
  ((void(*)(id, SEL))objc_msgSend)(obj, mbw_sel(sel_name));
}

static id mbw_default_runloop_mode(void) {
  return mbw_make_nsstring("NSDefaultRunLoopMode");
}

static int mbw_copy_utf8_slice(
  const uint8_t *src,
  int src_len,
  uint8_t *dst,
  int dst_cap
) {
  if (!dst || dst_cap <= 0 || !src || src_len <= 0) {
    return 0;
  }
  int copy_len = src_len;
  if (copy_len >= dst_cap) {
    copy_len = dst_cap - 1;
  }
  if (copy_len <= 0) {
    return 0;
  }
  memcpy(dst, src, (size_t)copy_len);
  dst[copy_len] = '\0';
  return copy_len;
}

static int mbw_copy_nsstring_utf8(id string, uint8_t *dst, int dst_cap) {
  if (!string || !dst || dst_cap <= 0) {
    return 0;
  }
  const char *utf8 = ((const char *(*)(id, SEL))objc_msgSend)(string, mbw_sel("UTF8String"));
  if (!utf8 || utf8[0] == '\0') {
    return 0;
  }
  return mbw_copy_utf8_slice((const uint8_t *)utf8, (int)strlen(utf8), dst, dst_cap);
}

static int mbw_event_nsstring_utf8(
  id event,
  const char *selector_name,
  uint8_t *dst,
  int dst_cap
) {
  if (!event) {
    return 0;
  }
  id string = ((id(*)(id, SEL))objc_msgSend)(event, mbw_sel(selector_name));
  return mbw_copy_nsstring_utf8(string, dst, dst_cap);
}

static int mbw_text_input_object_utf8(id text_input, uint8_t *dst, int dst_cap) {
  if (!text_input) {
    return 0;
  }
  id candidate = text_input;
  if (((mbw_bool_t(*)(id, SEL, SEL))objc_msgSend)(
        candidate,
        mbw_sel("respondsToSelector:"),
        mbw_sel("string"))) {
    candidate = ((id(*)(id, SEL))objc_msgSend)(candidate, mbw_sel("string"));
  }
  return mbw_copy_nsstring_utf8(candidate, dst, dst_cap);
}

static int mbw_modifierless_char_from_scancode(
  int scancode,
  uint8_t *dst,
  int dst_cap
) {
  if (scancode < 0 || !dst || dst_cap <= 1) {
    return 0;
  }

  TISInputSourceRef input_source = TISCopyCurrentKeyboardLayoutInputSource();
  if (!input_source) {
    return 0;
  }

  CFDataRef layout_data = TISGetInputSourceProperty(
    input_source,
    kTISPropertyUnicodeKeyLayoutData);
  if (!layout_data) {
    CFRelease(input_source);
    return 0;
  }

  const UCKeyboardLayout *layout =
    (const UCKeyboardLayout *)CFDataGetBytePtr(layout_data);
  if (!layout) {
    CFRelease(input_source);
    return 0;
  }

  UInt32 dead_keys = 0;
  UniChar chars[8];
  UniCharCount char_count = 0;
  OSStatus status = UCKeyTranslate(
    layout,
    (UInt16)scancode,
    kUCKeyActionDisplay,
    0,
    (UInt32)LMGetKbdType(),
    kUCKeyTranslateNoDeadKeysMask,
    &dead_keys,
    (UniCharCount)(sizeof(chars) / sizeof(chars[0])),
    &char_count,
    chars);
  CFRelease(input_source);
  if (status != noErr || char_count == 0) {
    return 0;
  }

  CFStringRef string = CFStringCreateWithCharacters(
    kCFAllocatorDefault,
    chars,
    (CFIndex)char_count);
  if (!string) {
    return 0;
  }

  CFIndex bytes_used = 0;
  Boolean ok = CFStringGetBytes(
    string,
    CFRangeMake(0, CFStringGetLength(string)),
    kCFStringEncodingUTF8,
    '?',
    false,
    dst,
    (CFIndex)(dst_cap - 1),
    &bytes_used);
  CFRelease(string);
  if (!ok || bytes_used <= 0) {
    return 0;
  }

  dst[bytes_used] = '\0';
  return (int)bytes_used;
}

static mbw_window_t *mbw_delegate_window(id delegate) {
  void *window_ptr = NULL;
  object_getInstanceVariable(delegate, "mbwWindow", &window_ptr);
  return (mbw_window_t *)window_ptr;
}

static mbw_window_t *mbw_view_window(id view) {
  void *window_ptr = NULL;
  object_getInstanceVariable(view, "mbwWindow", &window_ptr);
  return (mbw_window_t *)window_ptr;
}

static id mbw_view_tracking_area(id view) {
  void *tracking_area = NULL;
  object_getInstanceVariable(view, "mbwTrackingArea", &tracking_area);
  return (id)tracking_area;
}

static void mbw_view_set_tracking_area(id view, id tracking_area) {
  object_setInstanceVariable(view, "mbwTrackingArea", (void *)tracking_area);
}

static void mbw_view_refresh_tracking_area(id view) {
  if (!view) {
    return;
  }
  id previous = mbw_view_tracking_area(view);
  if (previous) {
    ((void(*)(id, SEL, id))objc_msgSend)(view, mbw_sel("removeTrackingArea:"), previous);
    mbw_view_set_tracking_area(view, nil);
  }

  Class tracking_area_class = objc_getClass("NSTrackingArea");
  if (!tracking_area_class) {
    return;
  }
  id allocated = mbw_msg_id((id)tracking_area_class, "alloc");
  if (!allocated) {
    return;
  }
  mbw_rect_t rect = {
    .origin = {0.0, 0.0},
    .size = {0.0, 0.0},
  };
  id tracking_area =
    ((id(*)(id, SEL, mbw_rect_t, mbw_nsuint_t, id, id))objc_msgSend)(
      allocated,
      mbw_sel("initWithRect:options:owner:userInfo:"),
      rect,
      MBW_NSTRACKING_MOUSE_ENTERED_AND_EXITED |
        MBW_NSTRACKING_MOUSE_MOVED |
        MBW_NSTRACKING_ACTIVE_ALWAYS |
        MBW_NSTRACKING_IN_VISIBLE_RECT,
      view,
      nil);
  if (!tracking_area) {
    return;
  }
  ((void(*)(id, SEL, id))objc_msgSend)(view, mbw_sel("addTrackingArea:"), tracking_area);
  mbw_view_set_tracking_area(view, tracking_area);
}

static double mbw_view_scale_factor(id view, mbw_window_t *window) {
  double scale_factor = 1.0;
  id ns_window = window && window->window
    ? (id)window->window
    : mbw_msg_id(view, "window");
  if (ns_window) {
    scale_factor = ((double(*)(id, SEL))objc_msgSend)(
      ns_window, mbw_sel("backingScaleFactor"));
    if (scale_factor <= 0.0) {
      scale_factor = 1.0;
    }
    if (window) {
      window->scale_factor = scale_factor;
    }
  }
  return scale_factor;
}

static void mbw_view_pointer_position_from_view_point(
  id view,
  mbw_window_t *window,
  mbw_point_t view_point,
  double *x,
  double *y
) {
  double scale_factor = mbw_view_scale_factor(view, window);
  if (x) {
    *x = view_point.x * scale_factor;
  }
  if (y) {
    *y = view_point.y * scale_factor;
  }
}

static void mbw_view_pointer_position(id view, id event, double *x, double *y) {
  if (x) {
    *x = 0.0;
  }
  if (y) {
    *y = 0.0;
  }
  if (!view || !event) {
    return;
  }
  mbw_point_t window_point =
    ((mbw_point_t(*)(id, SEL))objc_msgSend)(event, mbw_sel("locationInWindow"));
  mbw_point_t view_point =
    ((mbw_point_t(*)(id, SEL, mbw_point_t, id))objc_msgSend)(
      view,
      mbw_sel("convertPoint:fromView:"),
      window_point,
      nil);
  mbw_view_pointer_position_from_view_point(
    view,
    mbw_view_window(view),
    view_point,
    x,
    y);
}

static void mbw_window_queue_pointer_moved(mbw_window_t *window, double x, double y) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_POINTER_MOVED,
    .x = x,
    .y = y,
    .pointer_source = MBW_POINTER_SOURCE_MOUSE,
  };
  (void)mbw_push_input_event(window, &event);
}

static void mbw_window_queue_pointer_entered(mbw_window_t *window, double x, double y) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_POINTER_ENTERED,
    .x = x,
    .y = y,
    .pointer_kind = MBW_POINTER_KIND_MOUSE,
  };
  (void)mbw_push_input_event(window, &event);
}

static void mbw_window_queue_pointer_left(mbw_window_t *window, double x, double y) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_POINTER_LEFT,
    .x = x,
    .y = y,
    .pointer_kind = MBW_POINTER_KIND_MOUSE,
  };
  (void)mbw_push_input_event(window, &event);
}

static void mbw_window_queue_modifiers_changed(mbw_window_t *window, int modifiers) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_MODIFIERS_CHANGED,
    .modifiers = modifiers,
  };
  (void)mbw_push_input_event(window, &event);
}

static void mbw_window_queue_keyboard_input(
  mbw_window_t *window,
  int scancode,
  int state,
  int modifiers,
  int repeat,
  const uint8_t *text_with_all_modifiers,
  int text_with_all_modifiers_len,
  const uint8_t *text_ignoring_modifiers,
  int text_ignoring_modifiers_len,
  const uint8_t *text_without_modifiers,
  int text_without_modifiers_len
) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_KEYBOARD_INPUT,
    .scancode = scancode,
    .state = state,
    .modifiers = modifiers,
    .repeat = repeat,
    .text_with_all_modifiers_len = 0,
    .text_ignoring_modifiers_len = 0,
    .text_without_modifiers_len = 0,
  };
  event.text_with_all_modifiers_len = mbw_copy_utf8_slice(
    text_with_all_modifiers,
    text_with_all_modifiers_len,
    event.text_with_all_modifiers,
    MBW_KEY_TEXT_CAP);
  event.text_ignoring_modifiers_len = mbw_copy_utf8_slice(
    text_ignoring_modifiers,
    text_ignoring_modifiers_len,
    event.text_ignoring_modifiers,
    MBW_KEY_TEXT_CAP);
  event.text_without_modifiers_len = mbw_copy_utf8_slice(
    text_without_modifiers,
    text_without_modifiers_len,
    event.text_without_modifiers,
    MBW_KEY_TEXT_CAP);
  (void)mbw_push_input_event(window, &event);
}

static void mbw_window_queue_ime(
  mbw_window_t *window,
  int ime_kind,
  const uint8_t *text,
  int text_len,
  int cursor_start,
  int cursor_end
) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_IME,
    .ime_kind = ime_kind,
    .ime_text_len = 0,
    .ime_cursor_start = cursor_start,
    .ime_cursor_end = cursor_end,
  };
  event.ime_text_len = mbw_copy_utf8_slice(
    text,
    text_len,
    event.ime_text,
    MBW_KEY_TEXT_CAP);
  (void)mbw_push_input_event(window, &event);
}

static void mbw_window_queue_pointer_button(
  mbw_window_t *window,
  int state,
  double x,
  double y,
  int button
) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_POINTER_BUTTON,
    .x = x,
    .y = y,
    .state = state,
    .button = button,
  };
  (void)mbw_push_input_event(window, &event);
}

static void mbw_window_queue_mouse_wheel(
  mbw_window_t *window,
  int delta_kind,
  double delta_x,
  double delta_y,
  int phase
) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_MOUSE_WHEEL,
    .scroll_delta_kind = delta_kind,
    .delta_x = delta_x,
    .delta_y = delta_y,
    .phase = phase,
  };
  (void)mbw_push_input_event(window, &event);
}

static int mbw_event_modifiers_state(id event) {
  if (!event) {
    return 0;
  }
  mbw_nsuint_t flags =
    ((mbw_nsuint_t(*)(id, SEL))objc_msgSend)(event, mbw_sel("modifierFlags"));
  int modifiers = 0;
  if (flags & MBW_NSEVENT_MODIFIER_SHIFT) {
    modifiers |= MBW_MODIFIERS_SHIFT;
  }
  if (flags & MBW_NSEVENT_MODIFIER_CONTROL) {
    modifiers |= MBW_MODIFIERS_CONTROL;
  }
  if (flags & MBW_NSEVENT_MODIFIER_OPTION) {
    modifiers |= MBW_MODIFIERS_ALT;
  }
  if (flags & MBW_NSEVENT_MODIFIER_COMMAND) {
    modifiers |= MBW_MODIFIERS_META;
  }
  return modifiers;
}

static mbw_nsuint_t mbw_event_modifier_device_flags(id event) {
  if (!event) {
    return 0;
  }
  return ((mbw_nsuint_t(*)(id, SEL))objc_msgSend)(event, mbw_sel("modifierFlags"));
}

static bool mbw_modifier_active_for_scancode(id event, int scancode) {
  mbw_nsuint_t flags = mbw_event_modifier_device_flags(event);
  mbw_nsuint_t mask = 0;
  switch (scancode) {
    case 0x38:
      mask = MBW_NX_DEVICELSHIFTKEYMASK;
      break;
    case 0x3C:
      mask = MBW_NX_DEVICERSHIFTKEYMASK;
      break;
    case 0x3B:
      mask = MBW_NX_DEVICELCTLKEYMASK;
      break;
    case 0x3E:
      mask = MBW_NX_DEVICERCTLKEYMASK;
      break;
    case 0x3A:
      mask = MBW_NX_DEVICELALTKEYMASK;
      break;
    case 0x3D:
      mask = MBW_NX_DEVICERALTKEYMASK;
      break;
    case 0x37:
      mask = MBW_NX_DEVICELCMDKEYMASK;
      break;
    case 0x36:
      mask = MBW_NX_DEVICERCMDKEYMASK;
      break;
    default:
      return false;
  }
  return (flags & mask) != 0;
}

static void mbw_window_update_modifiers_from_event(mbw_window_t *window, id event) {
  if (!window || !event) {
    return;
  }
  int next_modifiers = mbw_event_modifiers_state(event);
  if (next_modifiers == window->modifiers_state) {
    return;
  }
  window->modifiers_state = next_modifiers;
  mbw_window_queue_modifiers_changed(window, next_modifiers);
}

static int mbw_window_scroll_phase(id event) {
  if (!event) {
    return MBW_TOUCH_PHASE_MOVED;
  }
  mbw_nsuint_t momentum_phase =
    ((mbw_nsuint_t(*)(id, SEL))objc_msgSend)(event, mbw_sel("momentumPhase"));
  if (
    (momentum_phase & MBW_NSEVENT_PHASE_MAY_BEGIN) ||
    (momentum_phase & MBW_NSEVENT_PHASE_BEGAN)) {
    return MBW_TOUCH_PHASE_STARTED;
  }
  if (
    (momentum_phase & MBW_NSEVENT_PHASE_ENDED) ||
    (momentum_phase & MBW_NSEVENT_PHASE_CANCELLED)) {
    return MBW_TOUCH_PHASE_ENDED;
  }

  mbw_nsuint_t phase = ((mbw_nsuint_t(*)(id, SEL))objc_msgSend)(event, mbw_sel("phase"));
  if ((phase & MBW_NSEVENT_PHASE_MAY_BEGIN) || (phase & MBW_NSEVENT_PHASE_BEGAN)) {
    return MBW_TOUCH_PHASE_STARTED;
  }
  if ((phase & MBW_NSEVENT_PHASE_ENDED) || (phase & MBW_NSEVENT_PHASE_CANCELLED)) {
    return MBW_TOUCH_PHASE_ENDED;
  }
  return MBW_TOUCH_PHASE_MOVED;
}

static void mbw_content_view_view_did_move_to_window(id self, SEL _cmd) {
  (void)_cmd;
  if (!self) {
    return;
  }
  id ns_window = mbw_msg_id(self, "window");
  if (ns_window) {
    ((void(*)(id, SEL, mbw_bool_t))objc_msgSend)(
      ns_window,
      mbw_sel("setAcceptsMouseMovedEvents:"),
      YES);
    (void)((mbw_bool_t(*)(id, SEL, id))objc_msgSend)(
      ns_window,
      mbw_sel("makeFirstResponder:"),
      self);
  }
  mbw_view_refresh_tracking_area(self);
}

static mbw_bool_t mbw_content_view_is_flipped(id self, SEL _cmd) {
  (void)self;
  (void)_cmd;
  return YES;
}

static mbw_bool_t mbw_content_view_accepts_first_responder(id self, SEL _cmd) {
  (void)self;
  (void)_cmd;
  return YES;
}

static void mbw_content_view_queue_ime(
  id self,
  int ime_kind,
  id text_input,
  int cursor_start,
  int cursor_end
) {
  mbw_window_t *window = mbw_view_window(self);
  if (!window || !window->ime_allowed) {
    return;
  }
  uint8_t text[MBW_KEY_TEXT_CAP];
  int text_len = mbw_text_input_object_utf8(text_input, text, MBW_KEY_TEXT_CAP);
  mbw_window_queue_ime(window, ime_kind, text, text_len, cursor_start, cursor_end);
}

static void mbw_content_view_insert_text(
  id self,
  SEL _cmd,
  id text_input,
  mbw_range_t replacement_range
) {
  (void)_cmd;
  (void)replacement_range;
  mbw_window_t *window = mbw_view_window(self);
  if (!window || !window->ime_allowed) {
    return;
  }
  window->ime_marked_active = 0;
  window->ime_cursor_start = -1;
  window->ime_cursor_end = -1;
  mbw_content_view_queue_ime(
    self,
    MBW_IME_EVENT_COMMIT,
    text_input,
    -1,
    -1);
}

static void mbw_content_view_insert_text_legacy(id self, SEL _cmd, id text_input) {
  mbw_content_view_insert_text(
    self,
    _cmd,
    text_input,
    (mbw_range_t){ .location = MBW_NS_NOT_FOUND, .length = 0 });
}

static void mbw_content_view_set_marked_text(
  id self,
  SEL _cmd,
  id text_input,
  mbw_range_t selected_range,
  mbw_range_t replacement_range
) {
  (void)_cmd;
  (void)replacement_range;
  mbw_window_t *window = mbw_view_window(self);
  if (!window || !window->ime_allowed) {
    return;
  }
  int cursor_start = -1;
  int cursor_end = -1;
  if (selected_range.location != MBW_NS_NOT_FOUND) {
    cursor_start = (int)selected_range.location;
    cursor_end = (int)(selected_range.location + selected_range.length);
  }
  if (!window->ime_marked_active) {
    mbw_content_view_queue_ime(
      self,
      MBW_IME_EVENT_ENABLED,
      nil,
      -1,
      -1);
  }
  window->ime_marked_active = 1;
  window->ime_cursor_start = cursor_start;
  window->ime_cursor_end = cursor_end;
  mbw_content_view_queue_ime(
    self,
    MBW_IME_EVENT_PREEDIT,
    text_input,
    cursor_start,
    cursor_end);
}

static void mbw_content_view_set_marked_text_legacy(
  id self,
  SEL _cmd,
  id text_input,
  mbw_range_t selected_range
) {
  mbw_content_view_set_marked_text(
    self,
    _cmd,
    text_input,
    selected_range,
    (mbw_range_t){ .location = MBW_NS_NOT_FOUND, .length = 0 });
}

static void mbw_content_view_unmark_text(id self, SEL _cmd) {
  (void)_cmd;
  mbw_window_t *window = mbw_view_window(self);
  if (!window) {
    return;
  }
  int had_marked_text = window->ime_marked_active;
  window->ime_marked_active = 0;
  window->ime_cursor_start = -1;
  window->ime_cursor_end = -1;
  if (had_marked_text) {
    mbw_content_view_queue_ime(
      self,
      MBW_IME_EVENT_DISABLED,
      nil,
      -1,
      -1);
  }
}

static mbw_bool_t mbw_content_view_has_marked_text(id self, SEL _cmd) {
  (void)_cmd;
  mbw_window_t *window = mbw_view_window(self);
  return window && window->ime_allowed && window->ime_marked_active ? YES : NO;
}

static mbw_range_t mbw_content_view_marked_range(id self, SEL _cmd) {
  (void)_cmd;
  mbw_window_t *window = mbw_view_window(self);
  if (!window || !window->ime_marked_active) {
    return (mbw_range_t){ .location = MBW_NS_NOT_FOUND, .length = 0 };
  }
  return (mbw_range_t){ .location = 0, .length = 1 };
}

static mbw_range_t mbw_content_view_selected_range(id self, SEL _cmd) {
  (void)_cmd;
  mbw_window_t *window = mbw_view_window(self);
  if (!window || window->ime_cursor_start < 0 || window->ime_cursor_end < window->ime_cursor_start) {
    return (mbw_range_t){ .location = MBW_NS_NOT_FOUND, .length = 0 };
  }
  return (mbw_range_t){
    .location = (mbw_nsuint_t)window->ime_cursor_start,
    .length = (mbw_nsuint_t)(window->ime_cursor_end - window->ime_cursor_start),
  };
}

static id mbw_content_view_valid_attributes_for_marked_text(id self, SEL _cmd) {
  (void)self;
  (void)_cmd;
  Class ns_array = objc_getClass("NSArray");
  if (!ns_array) {
    return nil;
  }
  return ((id(*)(id, SEL))objc_msgSend)((id)ns_array, mbw_sel("array"));
}

static id mbw_content_view_attributed_substring_for_proposed_range(
  id self,
  SEL _cmd,
  mbw_range_t range,
  mbw_range_t *actual_range
) {
  (void)self;
  (void)_cmd;
  (void)range;
  if (actual_range) {
    actual_range->location = MBW_NS_NOT_FOUND;
    actual_range->length = 0;
  }
  return nil;
}

static mbw_nsuint_t mbw_content_view_character_index_for_point(
  id self,
  SEL _cmd,
  mbw_point_t point
) {
  (void)self;
  (void)_cmd;
  (void)point;
  return 0;
}

static mbw_rect_t mbw_content_view_first_rect_for_character_range(
  id self,
  SEL _cmd,
  mbw_range_t range,
  mbw_range_t *actual_range
) {
  (void)_cmd;
  (void)range;
  if (actual_range) {
    actual_range->location = MBW_NS_NOT_FOUND;
    actual_range->length = 0;
  }
  mbw_rect_t rect = {
    .origin = {0.0, 0.0},
    .size = {1.0, 1.0},
  };
  mbw_window_t *window = mbw_view_window(self);
  if (window && window->window) {
    double scale_factor = mbw_view_scale_factor(self, window);
    if (scale_factor <= 0.0) {
      scale_factor = 1.0;
    }
    mbw_rect_t view_rect = {
      .origin = {
        (double)window->ime_cursor_area_x / scale_factor,
        (double)window->ime_cursor_area_y / scale_factor,
      },
      .size = {
        (double)window->ime_cursor_area_width / scale_factor,
        (double)window->ime_cursor_area_height / scale_factor,
      },
    };
    mbw_rect_t window_rect = ((mbw_rect_t(*)(id, SEL, mbw_rect_t, id))objc_msgSend)(
      self,
      mbw_sel("convertRect:toView:"),
      view_rect,
      nil);
    rect = ((mbw_rect_t(*)(id, SEL, mbw_rect_t))objc_msgSend)(
      (id)window->window,
      mbw_sel("convertRectToScreen:"),
      window_rect);
  }
  return rect;
}

static void mbw_content_view_key_down(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_window_t *window = mbw_view_window(self);
  if (!window || !event) {
    return;
  }
  mbw_window_update_modifiers_from_event(window, event);
  int modifiers = window->modifiers_state;
  int scancode = (int)((mbw_nsinteger_t(*)(id, SEL))objc_msgSend)(
    event, mbw_sel("keyCode"));
  mbw_bool_t is_repeat = ((mbw_bool_t(*)(id, SEL))objc_msgSend)(event, mbw_sel("isARepeat"));
  uint8_t text_with_all_modifiers[MBW_KEY_TEXT_CAP];
  uint8_t text_ignoring_modifiers[MBW_KEY_TEXT_CAP];
  uint8_t text_without_modifiers[MBW_KEY_TEXT_CAP];
  int text_with_all_modifiers_len = mbw_event_nsstring_utf8(
    event,
    "characters",
    text_with_all_modifiers,
    MBW_KEY_TEXT_CAP);
  int text_ignoring_modifiers_len = mbw_event_nsstring_utf8(
    event,
    "charactersIgnoringModifiers",
    text_ignoring_modifiers,
    MBW_KEY_TEXT_CAP);
  int text_without_modifiers_len = mbw_modifierless_char_from_scancode(
    scancode,
    text_without_modifiers,
    MBW_KEY_TEXT_CAP);
  if (text_without_modifiers_len <= 0) {
    text_without_modifiers_len = mbw_copy_utf8_slice(
      text_ignoring_modifiers,
      text_ignoring_modifiers_len,
      text_without_modifiers,
      MBW_KEY_TEXT_CAP);
  }
  mbw_window_queue_keyboard_input(
    window,
    scancode,
    MBW_ELEMENT_STATE_PRESSED,
    modifiers,
    is_repeat ? 1 : 0,
    text_with_all_modifiers,
    text_with_all_modifiers_len,
    text_ignoring_modifiers,
    text_ignoring_modifiers_len,
    text_without_modifiers,
    text_without_modifiers_len);
  if (window->ime_allowed && (modifiers & MBW_MODIFIERS_META) == 0) {
    Class ns_array = objc_getClass("NSArray");
    if (ns_array) {
      id events = ((id(*)(id, SEL, id))objc_msgSend)(
        (id)ns_array,
        mbw_sel("arrayWithObject:"),
        event);
      if (events) {
        ((void(*)(id, SEL, id))objc_msgSend)(
          self,
          mbw_sel("interpretKeyEvents:"),
          events);
      }
    }
  }
}

static void mbw_content_view_key_up(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_window_t *window = mbw_view_window(self);
  if (!window || !event) {
    return;
  }
  mbw_window_update_modifiers_from_event(window, event);
  int scancode = (int)((mbw_nsinteger_t(*)(id, SEL))objc_msgSend)(
    event, mbw_sel("keyCode"));
  uint8_t text_with_all_modifiers[MBW_KEY_TEXT_CAP];
  uint8_t text_ignoring_modifiers[MBW_KEY_TEXT_CAP];
  uint8_t text_without_modifiers[MBW_KEY_TEXT_CAP];
  int text_with_all_modifiers_len = mbw_event_nsstring_utf8(
    event,
    "characters",
    text_with_all_modifiers,
    MBW_KEY_TEXT_CAP);
  int text_ignoring_modifiers_len = mbw_event_nsstring_utf8(
    event,
    "charactersIgnoringModifiers",
    text_ignoring_modifiers,
    MBW_KEY_TEXT_CAP);
  int text_without_modifiers_len = mbw_modifierless_char_from_scancode(
    scancode,
    text_without_modifiers,
    MBW_KEY_TEXT_CAP);
  if (text_without_modifiers_len <= 0) {
    text_without_modifiers_len = mbw_copy_utf8_slice(
      text_ignoring_modifiers,
      text_ignoring_modifiers_len,
      text_without_modifiers,
      MBW_KEY_TEXT_CAP);
  }
  mbw_window_queue_keyboard_input(
    window,
    scancode,
    MBW_ELEMENT_STATE_RELEASED,
    window->modifiers_state,
    0,
    text_with_all_modifiers,
    text_with_all_modifiers_len,
    text_ignoring_modifiers,
    text_ignoring_modifiers_len,
    text_without_modifiers,
    text_without_modifiers_len);
}

static void mbw_content_view_mouse_motion(id self, id event) {
  mbw_window_t *window = mbw_view_window(self);
  if (!window || !event) {
    return;
  }
  mbw_window_update_modifiers_from_event(window, event);
  mbw_point_t window_point =
    ((mbw_point_t(*)(id, SEL))objc_msgSend)(event, mbw_sel("locationInWindow"));
  mbw_point_t view_point =
    ((mbw_point_t(*)(id, SEL, mbw_point_t, id))objc_msgSend)(
      self,
      mbw_sel("convertPoint:fromView:"),
      window_point,
      nil);
  mbw_rect_t bounds =
    ((mbw_rect_t(*)(id, SEL))objc_msgSend)(self, mbw_sel("bounds"));
  if (
    view_point.x < 0.0 ||
    view_point.y < 0.0 ||
    view_point.x > bounds.size.width ||
    view_point.y > bounds.size.height) {
    Class event_class = objc_getClass("NSEvent");
    mbw_nsuint_t buttons_down = event_class
      ? ((mbw_nsuint_t(*)(id, SEL))objc_msgSend)(
          (id)event_class,
          mbw_sel("pressedMouseButtons"))
      : 0;
    if (buttons_down == 0) {
      return;
    }
  }
  double x = 0.0;
  double y = 0.0;
  mbw_view_pointer_position_from_view_point(self, window, view_point, &x, &y);
  mbw_window_queue_pointer_moved(window, x, y);
}

static void mbw_content_view_mouse_click(id self, id event, int state) {
  mbw_window_t *window = mbw_view_window(self);
  if (!window || !event) {
    return;
  }
  mbw_window_update_modifiers_from_event(window, event);
  double x = 0.0;
  double y = 0.0;
  mbw_view_pointer_position(self, event, &x, &y);
  int button = (int)((mbw_nsinteger_t(*)(id, SEL))objc_msgSend)(
    event, mbw_sel("buttonNumber"));
  mbw_window_queue_pointer_button(window, state, x, y, button);
}

static void mbw_content_view_mouse_down(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_content_view_mouse_motion(self, event);
  mbw_content_view_mouse_click(self, event, MBW_ELEMENT_STATE_PRESSED);
}

static void mbw_content_view_mouse_up(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_content_view_mouse_motion(self, event);
  mbw_content_view_mouse_click(self, event, MBW_ELEMENT_STATE_RELEASED);
}

static void mbw_content_view_right_mouse_down(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_content_view_mouse_motion(self, event);
  mbw_content_view_mouse_click(self, event, MBW_ELEMENT_STATE_PRESSED);
}

static void mbw_content_view_right_mouse_up(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_content_view_mouse_motion(self, event);
  mbw_content_view_mouse_click(self, event, MBW_ELEMENT_STATE_RELEASED);
}

static void mbw_content_view_other_mouse_down(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_content_view_mouse_motion(self, event);
  mbw_content_view_mouse_click(self, event, MBW_ELEMENT_STATE_PRESSED);
}

static void mbw_content_view_other_mouse_up(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_content_view_mouse_motion(self, event);
  mbw_content_view_mouse_click(self, event, MBW_ELEMENT_STATE_RELEASED);
}

static void mbw_content_view_mouse_moved(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_content_view_mouse_motion(self, event);
}

static void mbw_content_view_mouse_dragged(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_content_view_mouse_motion(self, event);
}

static void mbw_content_view_right_mouse_dragged(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_content_view_mouse_motion(self, event);
}

static void mbw_content_view_other_mouse_dragged(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_content_view_mouse_motion(self, event);
}

static void mbw_content_view_mouse_entered(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_window_t *window = mbw_view_window(self);
  if (!window) {
    return;
  }
  mbw_window_update_modifiers_from_event(window, event);
  double x = 0.0;
  double y = 0.0;
  mbw_view_pointer_position(self, event, &x, &y);
  mbw_window_queue_pointer_entered(window, x, y);
}

static void mbw_content_view_mouse_exited(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_window_t *window = mbw_view_window(self);
  if (!window) {
    return;
  }
  mbw_window_update_modifiers_from_event(window, event);
  double x = 0.0;
  double y = 0.0;
  mbw_view_pointer_position(self, event, &x, &y);
  mbw_window_queue_pointer_left(window, x, y);
}

static void mbw_content_view_scroll_wheel(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_window_t *window = mbw_view_window(self);
  if (!window || !event) {
    return;
  }
  mbw_window_update_modifiers_from_event(window, event);
  mbw_content_view_mouse_motion(self, event);

  double delta_x = ((double(*)(id, SEL))objc_msgSend)(event, mbw_sel("scrollingDeltaX"));
  double delta_y = ((double(*)(id, SEL))objc_msgSend)(event, mbw_sel("scrollingDeltaY"));
  mbw_bool_t precise = ((mbw_bool_t(*)(id, SEL))objc_msgSend)(
    event, mbw_sel("hasPreciseScrollingDeltas"));
  int delta_kind = MBW_SCROLL_DELTA_LINE;
  if (precise) {
    double scale_factor = mbw_view_scale_factor(self, window);
    delta_x *= scale_factor;
    delta_y *= scale_factor;
    delta_kind = MBW_SCROLL_DELTA_PIXEL;
  }
  mbw_window_queue_mouse_wheel(
    window,
    delta_kind,
    delta_x,
    delta_y,
    mbw_window_scroll_phase(event));
}

static void mbw_content_view_flags_changed(id self, SEL _cmd, id event) {
  (void)_cmd;
  mbw_window_t *window = mbw_view_window(self);
  if (!window || !event) {
    return;
  }
  int scancode = (int)((mbw_nsinteger_t(*)(id, SEL))objc_msgSend)(
    event, mbw_sel("keyCode"));
  int previous_modifiers = window->modifiers_state;
  int next_modifiers = mbw_event_modifiers_state(event);
  uint8_t text_with_all_modifiers[MBW_KEY_TEXT_CAP];
  uint8_t text_ignoring_modifiers[MBW_KEY_TEXT_CAP];
  uint8_t text_without_modifiers[MBW_KEY_TEXT_CAP];
  int text_with_all_modifiers_len = mbw_event_nsstring_utf8(
    event,
    "characters",
    text_with_all_modifiers,
    MBW_KEY_TEXT_CAP);
  int text_ignoring_modifiers_len = mbw_event_nsstring_utf8(
    event,
    "charactersIgnoringModifiers",
    text_ignoring_modifiers,
    MBW_KEY_TEXT_CAP);
  int text_without_modifiers_len = mbw_modifierless_char_from_scancode(
    scancode,
    text_without_modifiers,
    MBW_KEY_TEXT_CAP);
  if (text_without_modifiers_len <= 0) {
    text_without_modifiers_len = mbw_copy_utf8_slice(
      text_ignoring_modifiers,
      text_ignoring_modifiers_len,
      text_without_modifiers,
      MBW_KEY_TEXT_CAP);
  }
  if (
    scancode == 0x38 ||
    scancode == 0x3C ||
    scancode == 0x3B ||
    scancode == 0x3E ||
    scancode == 0x3A ||
    scancode == 0x3D ||
    scancode == 0x37 ||
    scancode == 0x36) {
    mbw_window_queue_keyboard_input(
      window,
      scancode,
      mbw_modifier_active_for_scancode(event, scancode)
        ? MBW_ELEMENT_STATE_PRESSED
        : MBW_ELEMENT_STATE_RELEASED,
      next_modifiers,
      0,
      text_with_all_modifiers,
      text_with_all_modifiers_len,
      text_ignoring_modifiers,
      text_ignoring_modifiers_len,
      text_without_modifiers,
      text_without_modifiers_len);
  }
  if (next_modifiers != previous_modifiers) {
    window->modifiers_state = next_modifiers;
    mbw_window_queue_modifiers_changed(window, next_modifiers);
  }
}

static void mbw_window_delegate_did_resize(id self, SEL _cmd, id notification) {
  (void)_cmd;
  (void)notification;
  mbw_window_t *window = mbw_delegate_window(self);
  if (!window) {
    return;
  }
  window->pending_surface_resized = 1;
}

static mbw_bool_t mbw_window_delegate_should_close(id self, SEL _cmd, id notification) {
  (void)_cmd;
  (void)notification;
  mbw_window_t *window = mbw_delegate_window(self);
  if (!window) {
    return NO;
  }
  if (window->allow_close) {
    window->allow_close = 0;
    return YES;
  }
  window->pending_close_requested = 1;
  return NO;
}

static void mbw_window_delegate_will_close(id self, SEL _cmd, id notification) {
  (void)_cmd;
  (void)notification;
  mbw_window_t *window = mbw_delegate_window(self);
  if (!window) {
    return;
  }
  window->should_close = 1;
  window->pending_destroyed = 1;
}

static void mbw_window_delegate_did_become_key(id self, SEL _cmd, id notification) {
  (void)_cmd;
  (void)notification;
  mbw_window_t *window = mbw_delegate_window(self);
  if (!window) {
    return;
  }
  window->focused = 1;
  window->pending_focus_value = 1;
  window->pending_focused_changed = 1;
}

static void mbw_window_delegate_did_resign_key(id self, SEL _cmd, id notification) {
  (void)_cmd;
  (void)notification;
  mbw_window_t *window = mbw_delegate_window(self);
  if (!window) {
    return;
  }
  if (window->modifiers_state != 0) {
    window->modifiers_state = 0;
    mbw_window_queue_modifiers_changed(window, 0);
  }
  window->focused = 0;
  window->pending_focus_value = 0;
  window->pending_focused_changed = 1;
}

static Class mbw_get_window_delegate_class(void) {
  if (g_window_delegate_class) {
    return g_window_delegate_class;
  }

  Class existing = objc_getClass("MBWWindowDelegate");
  if (existing) {
    g_window_delegate_class = existing;
    return existing;
  }

  Class ns_object = objc_getClass("NSObject");
  if (!ns_object) {
    return Nil;
  }

  Class delegate_class = objc_allocateClassPair(ns_object, "MBWWindowDelegate", 0);
  if (!delegate_class) {
    return Nil;
  }

  if (!class_addIvar(
        delegate_class,
        "mbwWindow",
        sizeof(void *),
        (uint8_t)__alignof__(void *),
        "^v")) {
    return Nil;
  }

  class_addMethod(
    delegate_class,
    mbw_sel("windowShouldClose:"),
    (IMP)mbw_window_delegate_should_close,
    "c@:@");
  class_addMethod(
    delegate_class,
    mbw_sel("windowDidResize:"),
    (IMP)mbw_window_delegate_did_resize,
    "v@:@");
  class_addMethod(
    delegate_class,
    mbw_sel("windowDidBecomeKey:"),
    (IMP)mbw_window_delegate_did_become_key,
    "v@:@");
  class_addMethod(
    delegate_class,
    mbw_sel("windowDidResignKey:"),
    (IMP)mbw_window_delegate_did_resign_key,
    "v@:@");
  class_addMethod(
    delegate_class,
    mbw_sel("windowWillClose:"),
    (IMP)mbw_window_delegate_will_close,
    "v@:@");
  objc_registerClassPair(delegate_class);
  g_window_delegate_class = delegate_class;
  return delegate_class;
}

static Class mbw_get_content_view_class(void) {
  if (g_content_view_class) {
    return g_content_view_class;
  }

  Class existing = objc_getClass("MBWContentView");
  if (existing) {
    g_content_view_class = existing;
    return existing;
  }

  Class ns_view = objc_getClass("NSView");
  if (!ns_view) {
    return Nil;
  }

  Class view_class = objc_allocateClassPair(ns_view, "MBWContentView", 0);
  if (!view_class) {
    return Nil;
  }

  if (!class_addIvar(
        view_class,
        "mbwWindow",
        sizeof(void *),
        (uint8_t)__alignof__(void *),
        "^v")) {
    return Nil;
  }
  if (!class_addIvar(
        view_class,
        "mbwTrackingArea",
        sizeof(void *),
        (uint8_t)__alignof__(void *),
        "^v")) {
    return Nil;
  }

  class_addMethod(
    view_class,
    mbw_sel("isFlipped"),
    (IMP)mbw_content_view_is_flipped,
    "c@:");
  class_addMethod(
    view_class,
    mbw_sel("acceptsFirstResponder"),
    (IMP)mbw_content_view_accepts_first_responder,
    "c@:");
  class_addMethod(
    view_class,
    mbw_sel("insertText:replacementRange:"),
    (IMP)mbw_content_view_insert_text,
    "v@:@{_NSRange=QQ}{_NSRange=QQ}");
  class_addMethod(
    view_class,
    mbw_sel("insertText:"),
    (IMP)mbw_content_view_insert_text_legacy,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("setMarkedText:selectedRange:replacementRange:"),
    (IMP)mbw_content_view_set_marked_text,
    "v@:@{_NSRange=QQ}{_NSRange=QQ}");
  class_addMethod(
    view_class,
    mbw_sel("setMarkedText:selectedRange:"),
    (IMP)mbw_content_view_set_marked_text_legacy,
    "v@:@{_NSRange=QQ}");
  class_addMethod(
    view_class,
    mbw_sel("unmarkText"),
    (IMP)mbw_content_view_unmark_text,
    "v@:");
  class_addMethod(
    view_class,
    mbw_sel("hasMarkedText"),
    (IMP)mbw_content_view_has_marked_text,
    "c@:");
  class_addMethod(
    view_class,
    mbw_sel("markedRange"),
    (IMP)mbw_content_view_marked_range,
    "{_NSRange=QQ}@:");
  class_addMethod(
    view_class,
    mbw_sel("selectedRange"),
    (IMP)mbw_content_view_selected_range,
    "{_NSRange=QQ}@:");
  class_addMethod(
    view_class,
    mbw_sel("validAttributesForMarkedText"),
    (IMP)mbw_content_view_valid_attributes_for_marked_text,
    "@@:");
  class_addMethod(
    view_class,
    mbw_sel("attributedSubstringForProposedRange:actualRange:"),
    (IMP)mbw_content_view_attributed_substring_for_proposed_range,
    "@@:{_NSRange=QQ}^{_NSRange=QQ}");
  class_addMethod(
    view_class,
    mbw_sel("characterIndexForPoint:"),
    (IMP)mbw_content_view_character_index_for_point,
    "Q@:{_NSPoint=dd}");
  class_addMethod(
    view_class,
    mbw_sel("firstRectForCharacterRange:actualRange:"),
    (IMP)mbw_content_view_first_rect_for_character_range,
    "{_NSRect={_NSPoint=dd}{_NSSize=dd}}@:{_NSRange=QQ}^{_NSRange=QQ}");
  class_addMethod(
    view_class,
    mbw_sel("viewDidMoveToWindow"),
    (IMP)mbw_content_view_view_did_move_to_window,
    "v@:");
  class_addMethod(
    view_class,
    mbw_sel("keyDown:"),
    (IMP)mbw_content_view_key_down,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("keyUp:"),
    (IMP)mbw_content_view_key_up,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("mouseDown:"),
    (IMP)mbw_content_view_mouse_down,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("mouseUp:"),
    (IMP)mbw_content_view_mouse_up,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("rightMouseDown:"),
    (IMP)mbw_content_view_right_mouse_down,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("rightMouseUp:"),
    (IMP)mbw_content_view_right_mouse_up,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("otherMouseDown:"),
    (IMP)mbw_content_view_other_mouse_down,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("otherMouseUp:"),
    (IMP)mbw_content_view_other_mouse_up,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("mouseMoved:"),
    (IMP)mbw_content_view_mouse_moved,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("mouseDragged:"),
    (IMP)mbw_content_view_mouse_dragged,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("rightMouseDragged:"),
    (IMP)mbw_content_view_right_mouse_dragged,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("otherMouseDragged:"),
    (IMP)mbw_content_view_other_mouse_dragged,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("mouseEntered:"),
    (IMP)mbw_content_view_mouse_entered,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("mouseExited:"),
    (IMP)mbw_content_view_mouse_exited,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("scrollWheel:"),
    (IMP)mbw_content_view_scroll_wheel,
    "v@:@");
  class_addMethod(
    view_class,
    mbw_sel("flagsChanged:"),
    (IMP)mbw_content_view_flags_changed,
    "v@:@");

  objc_registerClassPair(view_class);
  g_content_view_class = view_class;
  return view_class;
}

static id mbw_make_nsstring(const char *utf8) {
  if (!utf8) {
    utf8 = "";
  }
  Class ns_string_class = objc_getClass("NSString");
  if (!ns_string_class) {
    return nil;
  }
  return ((id(*)(id, SEL, const char *))objc_msgSend)(
    (id)ns_string_class, mbw_sel("stringWithUTF8String:"), utf8);
}

static bool mbw_bootstrap_app(void) {
  if (g_bootstrap_done) {
    return g_bootstrap_ok;
  }
  g_bootstrap_done = true;

  Class app_class = objc_getClass("NSApplication");
  if (!app_class) {
    return false;
  }
  id app = ((id(*)(id, SEL))objc_msgSend)((id)app_class, mbw_sel("sharedApplication"));
  if (!app) {
    return false;
  }
  ((void(*)(id, SEL, long))objc_msgSend)(app, mbw_sel("setActivationPolicy:"), 0L);
  mbw_msg_void(app, "finishLaunching");
  ((void(*)(id, SEL, mbw_bool_t))objc_msgSend)(
    app, mbw_sel("activateIgnoringOtherApps:"), YES);

  g_ns_app = app;
  g_bootstrap_ok = true;
  return true;
}

static void mbw_update_all_windows(void) {
  for (size_t i = 0; i < g_windows_len; ++i) {
    if (g_windows[i]) {
      mbw_update_window_state(g_windows[i]);
    }
  }
}

static bool mbw_is_proxy_wake_event(id event) {
  if (!event) {
    return false;
  }
  mbw_nsuint_t event_type =
    ((mbw_nsuint_t(*)(id, SEL))objc_msgSend)(event, mbw_sel("type"));
  if (event_type != MBW_NSEVENT_TYPE_APPLICATION_DEFINED) {
    return false;
  }
  short subtype = ((short(*)(id, SEL))objc_msgSend)(event, mbw_sel("subtype"));
  return subtype == MBW_PROXY_WAKE_EVENT_SUBTYPE;
}

static void mbw_post_proxy_wake_event(void) {
  if (!g_ns_app) {
    return;
  }

  Class event_class = objc_getClass("NSEvent");
  if (!event_class) {
    return;
  }

  mbw_point_t location = {0.0, 0.0};
  id wake_event =
    ((id(*)(id, SEL, mbw_nsuint_t, mbw_point_t, mbw_nsuint_t, double, mbw_nsinteger_t, id, short, mbw_nsinteger_t, mbw_nsinteger_t))objc_msgSend)(
      (id)event_class,
      mbw_sel("otherEventWithType:location:modifierFlags:timestamp:windowNumber:context:subtype:data1:data2:"),
      MBW_NSEVENT_TYPE_APPLICATION_DEFINED,
      location,
      0UL,
      0.0,
      0L,
      nil,
      MBW_PROXY_WAKE_EVENT_SUBTYPE,
      0L,
      0L);
  if (wake_event) {
    ((void(*)(id, SEL, id, mbw_bool_t))objc_msgSend)(
      g_ns_app,
      mbw_sel("postEvent:atStart:"),
      wake_event,
      NO);
  }
}

static bool mbw_pump_app_events(id initial_until_date) {
  if (!mbw_bootstrap_app() || !g_ns_app) {
    return false;
  }

  id date_class = (id)objc_getClass("NSDate");
  id distant_past = date_class ? mbw_msg_id(date_class, "distantPast") : nil;
  id runloop_mode = mbw_default_runloop_mode();
  bool saw_event = false;

  while (true) {
    id until_date = saw_event ? distant_past : initial_until_date;
    id event =
      ((id(*)(id, SEL, mbw_nsuint_t, id, id, mbw_bool_t))objc_msgSend)(
        g_ns_app,
        mbw_sel("nextEventMatchingMask:untilDate:inMode:dequeue:"),
        (mbw_nsuint_t)~(mbw_nsuint_t)0,
        until_date,
        runloop_mode,
        YES);
    if (!event) {
      break;
    }
    saw_event = true;
    if (!mbw_is_proxy_wake_event(event)) {
      mbw_nsuint_t event_type =
        ((mbw_nsuint_t(*)(id, SEL))objc_msgSend)(event, mbw_sel("type"));
      mbw_nsuint_t modifier_flags =
        ((mbw_nsuint_t(*)(id, SEL))objc_msgSend)(event, mbw_sel("modifierFlags"));
      if (
        event_type == MBW_NSEVENT_TYPE_KEY_UP &&
        (modifier_flags & MBW_NSEVENT_MODIFIER_COMMAND) != 0) {
        id key_window = mbw_msg_id(g_ns_app, "keyWindow");
        if (key_window) {
          ((void(*)(id, SEL, id))objc_msgSend)(key_window, mbw_sel("sendEvent:"), event);
        }
      } else {
        ((void(*)(id, SEL, id))objc_msgSend)(g_ns_app, mbw_sel("sendEvent:"), event);
      }
    }
  }

  mbw_msg_void(g_ns_app, "updateWindows");
  mbw_update_all_windows();
  return saw_event;
}

static int mbw_window_theme_kind(mbw_window_t *window) {
  if (!window || !window->window) {
    return MBW_THEME_UNKNOWN;
  }
  id appearance =
    ((id(*)(id, SEL))objc_msgSend)((id)window->window, mbw_sel("effectiveAppearance"));
  if (!appearance) {
    return MBW_THEME_UNKNOWN;
  }
  id name = ((id(*)(id, SEL))objc_msgSend)(appearance, mbw_sel("name"));
  if (!name) {
    return MBW_THEME_UNKNOWN;
  }
  const char *utf8 = ((const char *(*)(id, SEL))objc_msgSend)(name, mbw_sel("UTF8String"));
  if (utf8 && strstr(utf8, "Dark")) {
    return MBW_THEME_DARK;
  }
  return MBW_THEME_LIGHT;
}

static int mbw_window_occluded(mbw_window_t *window) {
  if (!window || !window->window) {
    return 0;
  }
  mbw_nsuint_t occlusion_state =
    ((mbw_nsuint_t(*)(id, SEL))objc_msgSend)((id)window->window, mbw_sel("occlusionState"));
  return (occlusion_state & MBW_NSWINDOW_OCCLUSION_STATE_VISIBLE) == 0 ? 1 : 0;
}

static void mbw_window_position(mbw_window_t *window, int *x, int *y) {
  if (!x || !y) {
    return;
  }
  *x = 0;
  *y = 0;
  if (!window || !window->window) {
    return;
  }
  mbw_rect_t frame =
    ((mbw_rect_t(*)(id, SEL))objc_msgSend)((id)window->window, mbw_sel("frame"));
  double main_screen_height = CGDisplayBounds(CGMainDisplayID()).size.height;
  double scale_factor = window->scale_factor > 0.0 ? window->scale_factor : 1.0;
  *x = (int)(frame.origin.x * scale_factor + 0.5);
  *y = (int)((main_screen_height - frame.size.height - frame.origin.y) * scale_factor + 0.5);
}

static void mbw_update_window_state(mbw_window_t *window) {
  if (!window || !window->window) {
    return;
  }

  mbw_bool_t is_visible = ((mbw_bool_t(*)(id, SEL))objc_msgSend)(
    (id)window->window, mbw_sel("isVisible"));
  window->visible = is_visible ? 1 : 0;
  mbw_bool_t is_focused = ((mbw_bool_t(*)(id, SEL))objc_msgSend)(
    (id)window->window, mbw_sel("isKeyWindow"));
  if (!window->pending_focused_changed) {
    window->focused = is_focused ? 1 : 0;
  }
  mbw_bool_t is_miniaturized = ((mbw_bool_t(*)(id, SEL))objc_msgSend)(
    (id)window->window, mbw_sel("isMiniaturized"));
  window->minimized = is_miniaturized ? 1 : 0;
  mbw_bool_t is_zoomed = ((mbw_bool_t(*)(id, SEL))objc_msgSend)(
    (id)window->window, mbw_sel("isZoomed"));
  window->maximized = is_zoomed ? 1 : 0;
  mbw_nsuint_t style_mask = ((mbw_nsuint_t(*)(id, SEL))objc_msgSend)(
    (id)window->window, mbw_sel("styleMask"));
  window->fullscreen =
    (style_mask & MBW_NSWINDOW_STYLE_MASK_FULLSCREEN) != 0 ? 1 : 0;

  window->scale_factor = ((double(*)(id, SEL))objc_msgSend)(
    (id)window->window, mbw_sel("backingScaleFactor"));
  if (window->scale_factor <= 0.0) {
    window->scale_factor = 1.0;
  }
  int next_theme_kind = mbw_window_theme_kind(window);
  int next_occluded = mbw_window_occluded(window);
  int next_x = 0;
  int next_y = 0;
  mbw_window_position(window, &next_x, &next_y);
  if (!window->pending_theme_changed) {
    window->theme_kind = next_theme_kind;
  }
  if (!window->pending_occluded_changed) {
    window->occluded = next_occluded;
  }
  if (!window->pending_moved) {
    window->x = next_x;
    window->y = next_y;
  }

  id content_view = window->content_view
    ? (id)window->content_view
    : mbw_msg_id((id)window->window, "contentView");
  if (content_view) {
    window->content_view = (void *)content_view;
    mbw_rect_t bounds =
      ((mbw_rect_t(*)(id, SEL))objc_msgSend)(content_view, mbw_sel("bounds"));
    int width = (int)(bounds.size.width * window->scale_factor + 0.5);
    int height = (int)(bounds.size.height * window->scale_factor + 0.5);
    mbw_apply_surface_constraints(window, &width, &height);
    window->width = width;
    window->height = height;
  }

  if (!window->pending_scale_factor_changed) {
    if (window->reported_scale_factor <= 0.0) {
      window->reported_scale_factor = window->scale_factor;
    } else if (window->scale_factor != window->reported_scale_factor) {
      window->reported_scale_factor = window->scale_factor;
      window->pending_scale_factor_changed = 1;
      window->pending_scale_factor = window->scale_factor;
      window->pending_scale_width = window->width;
      window->pending_scale_height = window->height;
    }
  }

  if (!window->pending_moved) {
    if (!window->reported_position_valid) {
      window->reported_x = window->x;
      window->reported_y = window->y;
      window->reported_position_valid = 1;
    } else if (window->x != window->reported_x || window->y != window->reported_y) {
      window->reported_x = window->x;
      window->reported_y = window->y;
      window->pending_moved = 1;
      window->pending_move_x = window->x;
      window->pending_move_y = window->y;
    }
  }

  if (!window->pending_theme_changed) {
    if (window->reported_theme_kind == MBW_THEME_UNKNOWN) {
      window->reported_theme_kind = window->theme_kind;
    } else if (
      window->theme_kind != MBW_THEME_UNKNOWN &&
      window->theme_kind != window->reported_theme_kind) {
      window->reported_theme_kind = window->theme_kind;
      window->pending_theme_changed = 1;
      window->pending_theme_kind = window->theme_kind;
    }
  }

  if (!window->pending_occluded_changed) {
    if (window->reported_occluded < 0) {
      window->reported_occluded = window->occluded;
    } else if (window->occluded != window->reported_occluded) {
      window->reported_occluded = window->occluded;
      window->pending_occluded_changed = 1;
      window->pending_occluded = window->occluded;
    }
  }

  if (window->width != window->reported_width || window->height != window->reported_height) {
    window->reported_width = window->width;
    window->reported_height = window->height;
    window->pending_surface_resized = 1;
  }
}
#endif

#if !defined(__APPLE__)
static void mbw_window_queue_pointer_moved(mbw_window_t *window, double x, double y) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_POINTER_MOVED,
    .x = x,
    .y = y,
    .pointer_source = MBW_POINTER_SOURCE_MOUSE,
  };
  (void)mbw_push_input_event(window, &event);
}

static void mbw_window_queue_pointer_entered(mbw_window_t *window, double x, double y) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_POINTER_ENTERED,
    .x = x,
    .y = y,
    .pointer_kind = MBW_POINTER_KIND_MOUSE,
  };
  (void)mbw_push_input_event(window, &event);
}

static void mbw_window_queue_pointer_left(mbw_window_t *window, double x, double y) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_POINTER_LEFT,
    .x = x,
    .y = y,
    .pointer_kind = MBW_POINTER_KIND_MOUSE,
  };
  (void)mbw_push_input_event(window, &event);
}

static void mbw_window_queue_pointer_button(
  mbw_window_t *window,
  int state,
  double x,
  double y,
  int button
) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_POINTER_BUTTON,
    .x = x,
    .y = y,
    .state = state,
    .button = button,
  };
  (void)mbw_push_input_event(window, &event);
}

static void mbw_window_queue_mouse_wheel(
  mbw_window_t *window,
  int delta_kind,
  double delta_x,
  double delta_y,
  int phase
) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_MOUSE_WHEEL,
    .scroll_delta_kind = delta_kind,
    .delta_x = delta_x,
    .delta_y = delta_y,
    .phase = phase,
  };
  (void)mbw_push_input_event(window, &event);
}

static void mbw_window_queue_ime(
  mbw_window_t *window,
  int ime_kind,
  const uint8_t *text,
  int text_len,
  int cursor_start,
  int cursor_end
) {
  mbw_input_event_t event = {
    .kind = MBW_INPUT_EVENT_IME,
    .ime_kind = ime_kind,
    .ime_text_len = 0,
    .ime_cursor_start = cursor_start,
    .ime_cursor_end = cursor_end,
  };
  event.ime_text_len = mbw_copy_utf8_slice(
    text,
    text_len,
    event.ime_text,
    MBW_KEY_TEXT_CAP);
  (void)mbw_push_input_event(window, &event);
}
#endif

bool mbw_backend_available(void) {
#if defined(__APPLE__)
  return true;
#else
  return false;
#endif
}

void mbw_event_loop_reset_proxy(void) {
  atomic_store_explicit(&g_pending_proxy_wake_up, 0, memory_order_release);
}

bool mbw_event_loop_peek_proxy_wake_up(void) {
  return atomic_load_explicit(&g_pending_proxy_wake_up, memory_order_acquire) != 0;
}

bool mbw_event_loop_take_proxy_wake_up(void) {
  return atomic_exchange_explicit(&g_pending_proxy_wake_up, 0, memory_order_acq_rel) != 0;
}

void mbw_event_loop_wake_up(void) {
  atomic_store_explicit(&g_pending_proxy_wake_up, 1, memory_order_release);
#if defined(__APPLE__)
  mbw_post_proxy_wake_event();
#endif
}

static int64_t mbw_now_ms(void) {
  if (g_now_ms_override_for_test >= 0) {
    return g_now_ms_override_for_test;
  }
#if defined(__APPLE__) || defined(__linux__)
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return (int64_t)ts.tv_sec * 1000 + (int64_t)(ts.tv_nsec / 1000000);
#else
  return 0;
#endif
}

int64_t mbw_runtime_now_ms(void) {
  return mbw_now_ms();
}

void mbw_runtime_now_ms_set_for_test(int64_t ms) {
  g_now_ms_override_for_test = ms;
}

void mbw_runtime_now_ms_clear_for_test(void) {
  g_now_ms_override_for_test = -1;
}

void mbw_sleep_millis(int ms) {
  if (ms <= 0) {
    return;
  }
  if (g_now_ms_override_for_test >= 0) {
    g_now_ms_override_for_test += (int64_t)ms;
    return;
  }
  usleep((useconds_t)ms * 1000U);
}

bool mbw_event_loop_wait_millis(int timeout_ms) {
  if (mbw_event_loop_peek_proxy_wake_up()) {
    return false;
  }

  if (g_now_ms_override_for_test >= 0) {
    if (timeout_ms < 0) {
      g_now_ms_override_for_test += 1;
      return false;
    }
    g_now_ms_override_for_test += (int64_t)timeout_ms;
    return true;
  }

#if defined(__APPLE__)
  if (!mbw_bootstrap_app() || !g_ns_app) {
    if (timeout_ms < 0) {
      usleep(1000U);
      return false;
    }
    if (timeout_ms > 0) {
      usleep((useconds_t)timeout_ms * 1000U);
    }
    return true;
  }

  Class date_class = objc_getClass("NSDate");
  id until_date = nil;
  if (date_class) {
    if (timeout_ms < 0) {
      until_date = mbw_msg_id((id)date_class, "distantFuture");
    } else {
      until_date =
        ((id(*)(id, SEL, double))objc_msgSend)(
          (id)date_class,
          mbw_sel("dateWithTimeIntervalSinceNow:"),
          (double)timeout_ms / 1000.0);
    }
  }
  return !mbw_pump_app_events(until_date);
#else
  if (timeout_ms < 0) {
    usleep(1000U);
    return false;
  }
  if (timeout_ms > 0) {
    usleep((useconds_t)timeout_ms * 1000U);
  }
  return true;
#endif
}

int mbw_window_create_utf8(
  int width,
  int height,
  bool visible,
  bool active,
  bool resizable,
  bool decorated,
  const uint8_t *title,
  uint64_t title_len
) {
  mbw_window_t *window = (mbw_window_t *)calloc(1, sizeof(mbw_window_t));
  if (!window) {
    return 0;
  }

  window->id = g_next_window_id++;
  window->width = mbw_clamp_size(width);
  window->height = mbw_clamp_size(height);
  window->x = 0;
  window->y = 0;
  window->scale_factor = 1.0;
  window->reported_scale_factor = 0.0;
  window->reported_position_valid = 0;
  window->reported_x = 0;
  window->reported_y = 0;
  window->pending_moved = 0;
  window->pending_move_x = 0;
  window->pending_move_y = 0;
  window->should_close = 0;
  window->allow_close = 0;
  window->pending_close_requested = 0;
  window->pending_destroyed = 0;
  window->pending_focused_changed = 0;
  window->focused = (visible && active) ? 1 : 0;
  window->maximized = 0;
  window->minimized = 0;
  window->fullscreen = 0;
  window->pending_focus_value = 0;
  window->theme_kind = MBW_THEME_UNKNOWN;
  window->reported_theme_kind = MBW_THEME_UNKNOWN;
  window->pending_theme_changed = 0;
  window->pending_theme_kind = MBW_THEME_UNKNOWN;
  window->occluded = 0;
  window->reported_occluded = -1;
  window->pending_occluded_changed = 0;
  window->pending_occluded = 0;
  window->pending_scale_factor_changed = 0;
  window->pending_scale_factor = 1.0;
  window->pending_scale_width = window->width;
  window->pending_scale_height = window->height;
  window->pending_surface_resized = 0;
  window->pending_redraw_requested = 0;
  window->reported_width = window->width;
  window->reported_height = window->height;
  window->min_width = 1;
  window->min_height = 1;
  window->max_width = 0;
  window->max_height = 0;
  window->resize_increment_width = 0;
  window->resize_increment_height = 0;
  window->modifiers_state = 0;
  window->ime_marked_active = 0;
  window->ime_cursor_start = -1;
  window->ime_cursor_end = -1;
  window->ime_allowed = 1;
  window->ime_purpose = MBW_IME_PURPOSE_NORMAL;
  window->ime_cursor_area_x = 0;
  window->ime_cursor_area_y = 0;
  window->ime_cursor_area_width = 1;
  window->ime_cursor_area_height = 1;
  window->visible = visible ? 1 : 0;
  window->resizable = resizable ? 1 : 0;
  window->content_protected = 0;
  window->decorated = decorated ? 1 : 0;
  window->close_button_enabled = 1;
  window->minimize_button_enabled = 1;
  window->maximize_button_enabled = 1;
  window->blur = 0;
  window->transparent = 0;
  window->window_level = MBW_WINDOW_LEVEL_NORMAL;
  window->queued_input_events = NULL;
  window->queued_input_events_len = 0;
  window->queued_input_events_cap = 0;
  window->current_input_event.kind = MBW_INPUT_EVENT_NONE;

#if defined(__APPLE__)
  if (mbw_bootstrap_app()) {
    Class window_class = objc_getClass("NSWindow");
    if (window_class) {
      id allocated = mbw_msg_id((id)window_class, "alloc");
      mbw_rect_t rect = {
        .origin = {0.0, 0.0},
        .size = {(double)window->width, (double)window->height},
      };
      mbw_nsuint_t style_mask = 0;
      if (decorated) {
        style_mask |= (1UL << 0) | (1UL << 1) | (1UL << 2);
      }
      if (resizable) {
        style_mask |= (1UL << 3);
      }
      id ns_window =
        ((id(*)(id, SEL, mbw_rect_t, mbw_nsuint_t, mbw_nsuint_t, mbw_bool_t))objc_msgSend)(
          allocated,
          mbw_sel("initWithContentRect:styleMask:backing:defer:"),
          rect,
          style_mask,
          2UL,
          NO);
      if (ns_window) {
        ((void(*)(id, SEL, mbw_bool_t))objc_msgSend)(
          ns_window, mbw_sel("setReleasedWhenClosed:"), NO);
        char *title_utf8 = mbw_copy_utf8(title, title_len);
        id ns_title = mbw_make_nsstring(
          title_utf8 && title_utf8[0] != '\0' ? title_utf8 : "winit window");
        if (ns_title) {
          ((void(*)(id, SEL, id))objc_msgSend)(ns_window, mbw_sel("setTitle:"), ns_title);
        }
        if (title_utf8) {
          free(title_utf8);
        }
        id content_view = nil;
        Class content_view_class = mbw_get_content_view_class();
        if (content_view_class) {
          id allocated_view = mbw_msg_id((id)content_view_class, "alloc");
          if (allocated_view) {
            id current_content_view = mbw_msg_id(ns_window, "contentView");
            mbw_rect_t content_rect = current_content_view
              ? ((mbw_rect_t(*)(id, SEL))objc_msgSend)(
                  current_content_view,
                  mbw_sel("bounds"))
              : rect;
            content_view =
              ((id(*)(id, SEL, mbw_rect_t))objc_msgSend)(
                allocated_view,
                mbw_sel("initWithFrame:"),
                content_rect);
            if (content_view) {
              object_setInstanceVariable(content_view, "mbwWindow", window);
              ((void(*)(id, SEL, id))objc_msgSend)(
                ns_window,
                mbw_sel("setContentView:"),
                content_view);
              ((void(*)(id, SEL, mbw_bool_t))objc_msgSend)(
                ns_window,
                mbw_sel("setAcceptsMouseMovedEvents:"),
                YES);
              (void)((mbw_bool_t(*)(id, SEL, id))objc_msgSend)(
                ns_window,
                mbw_sel("makeFirstResponder:"),
                content_view);
            }
          }
        }
        mbw_msg_void(ns_window, "center");
        if (visible) {
          if (active) {
            ((void(*)(id, SEL, id))objc_msgSend)(
              ns_window, mbw_sel("makeKeyAndOrderFront:"), nil);
          } else {
            ((void(*)(id, SEL, id))objc_msgSend)(
              ns_window, mbw_sel("orderFront:"), nil);
          }
        } else {
          ((void(*)(id, SEL, id))objc_msgSend)(ns_window, mbw_sel("orderOut:"), nil);
        }
        window->window = (void *)ns_window;
        window->content_view = content_view
          ? (void *)content_view
          : (void *)mbw_msg_id(ns_window, "contentView");
        Class delegate_class = mbw_get_window_delegate_class();
        if (delegate_class) {
          id delegate = mbw_msg_id((id)delegate_class, "new");
          if (delegate) {
            object_setInstanceVariable(delegate, "mbwWindow", window);
            ((void(*)(id, SEL, id))objc_msgSend)(
              ns_window, mbw_sel("setDelegate:"), delegate);
            window->delegate = (void *)delegate;
          }
        }
        mbw_update_window_state(window);
      }
    }
  }
#else
  (void)title;
  (void)title_len;
#endif

  mbw_push_window(window);
  return window->id;
}

void mbw_window_poll(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
#if defined(__APPLE__)
  Class date_class = objc_getClass("NSDate");
  id distant_past = date_class ? mbw_msg_id((id)date_class, "distantPast") : nil;
  (void)window;
  (void)mbw_pump_app_events(distant_past);
#endif
}

int mbw_window_width(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->width : 0;
}

int mbw_window_height(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->height : 0;
}

int mbw_window_resize_increment_width(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->resize_increment_width : 0;
}

int mbw_window_resize_increment_height(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->resize_increment_height : 0;
}

int mbw_window_x(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->x : 0;
}

int mbw_window_y(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->y : 0;
}

void mbw_window_set_position(int window_id, int x, int y) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }

  int target_x = x;
  int target_y = y;
#if defined(__APPLE__)
  if (window->window) {
    double scale_factor = window->scale_factor > 0.0 ? window->scale_factor : 1.0;
    mbw_rect_t frame =
      ((mbw_rect_t(*)(id, SEL))objc_msgSend)((id)window->window, mbw_sel("frame"));
    double main_screen_height = CGDisplayBounds(CGMainDisplayID()).size.height;
    mbw_point_t origin = {
      .x = (double)x / scale_factor,
      .y = main_screen_height - frame.size.height - ((double)y / scale_factor),
    };
    ((void(*)(id, SEL, mbw_point_t))objc_msgSend)(
      (id)window->window,
      mbw_sel("setFrameOrigin:"),
      origin);
    mbw_window_position(window, &target_x, &target_y);
  }
#endif
  window->x = target_x;
  window->y = target_y;
  window->pending_moved = 1;
  window->pending_move_x = target_x;
  window->pending_move_y = target_y;
  window->reported_position_valid = 1;
  window->reported_x = target_x;
  window->reported_y = target_y;
}

int mbw_window_theme(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->theme_kind : MBW_THEME_UNKNOWN;
}

double mbw_window_scale_factor(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->scale_factor : 1.0;
}

bool mbw_window_should_close(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->should_close != 0 : true;
}

bool mbw_window_take_close_requested(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window || !window->pending_close_requested) {
    return false;
  }
  window->pending_close_requested = 0;
  return true;
}

bool mbw_window_take_moved(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window || !window->pending_moved) {
    return false;
  }
  window->pending_moved = 0;
  return true;
}

int mbw_window_pending_move_x(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->pending_move_x : 0;
}

int mbw_window_pending_move_y(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->pending_move_y : 0;
}

bool mbw_window_take_destroyed(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window || !window->pending_destroyed) {
    return false;
  }
  window->pending_destroyed = 0;
  return true;
}

bool mbw_window_take_focused_changed(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window || !window->pending_focused_changed) {
    return false;
  }
  window->pending_focused_changed = 0;
  return true;
}

bool mbw_window_pending_focused(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->pending_focus_value != 0 : false;
}

bool mbw_window_has_focus(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->focused != 0 : false;
}

bool mbw_window_visible(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->visible != 0 : false;
}

bool mbw_window_resizable(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->resizable != 0 : false;
}

bool mbw_window_content_protected(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->content_protected != 0 : false;
}

bool mbw_window_is_occluded(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->occluded != 0 : false;
}

bool mbw_window_minimized(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->minimized != 0 : false;
}

bool mbw_window_maximized(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->maximized != 0 : false;
}

bool mbw_window_fullscreen(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->fullscreen != 0 : false;
}

bool mbw_window_decorated(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->decorated != 0 : false;
}

bool mbw_window_close_button_enabled(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->close_button_enabled != 0 : false;
}

bool mbw_window_minimize_button_enabled(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->minimize_button_enabled != 0 : false;
}

bool mbw_window_maximize_button_enabled(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->maximize_button_enabled != 0 : false;
}

bool mbw_window_blur(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->blur != 0 : false;
}

bool mbw_window_transparent(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->transparent != 0 : false;
}

int mbw_window_level(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->window_level : MBW_WINDOW_LEVEL_NORMAL;
}

bool mbw_window_ime_allowed(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->ime_allowed != 0 : false;
}

int mbw_window_ime_purpose(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->ime_purpose : MBW_IME_PURPOSE_NORMAL;
}

int mbw_window_ime_cursor_area_x(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->ime_cursor_area_x : 0;
}

int mbw_window_ime_cursor_area_y(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->ime_cursor_area_y : 0;
}

int mbw_window_ime_cursor_area_width(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->ime_cursor_area_width : 1;
}

int mbw_window_ime_cursor_area_height(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->ime_cursor_area_height : 1;
}

bool mbw_window_take_scale_factor_changed(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window || !window->pending_scale_factor_changed) {
    return false;
  }
  window->pending_scale_factor_changed = 0;
  return true;
}

double mbw_window_pending_scale_factor(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->pending_scale_factor : 1.0;
}

int mbw_window_pending_scale_width(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->pending_scale_width : 0;
}

int mbw_window_pending_scale_height(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->pending_scale_height : 0;
}

bool mbw_window_take_theme_changed(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window || !window->pending_theme_changed) {
    return false;
  }
  window->pending_theme_changed = 0;
  return true;
}

int mbw_window_pending_theme(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->pending_theme_kind : MBW_THEME_UNKNOWN;
}

bool mbw_window_take_occluded_changed(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window || !window->pending_occluded_changed) {
    return false;
  }
  window->pending_occluded_changed = 0;
  return true;
}

bool mbw_window_pending_occluded(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->pending_occluded != 0 : false;
}

bool mbw_window_take_input_event(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window || window->queued_input_events_len == 0) {
    return false;
  }
  window->current_input_event = window->queued_input_events[0];
  if (window->queued_input_events_len > 1) {
    memmove(
      window->queued_input_events,
      window->queued_input_events + 1,
      (window->queued_input_events_len - 1) * sizeof(mbw_input_event_t));
  }
  window->queued_input_events_len -= 1;
  return true;
}

static moonbit_bytes_t mbw_make_bytes_from_slice(const uint8_t *src, int len) {
  if (!src || len <= 0) {
    return moonbit_make_bytes_raw(0);
  }
  moonbit_bytes_t out = moonbit_make_bytes_raw((int32_t)len);
  if (!out) {
    return moonbit_make_bytes_raw(0);
  }
  memcpy(out, src, (size_t)len);
  return out;
}

int mbw_window_input_event_kind(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.kind : MBW_INPUT_EVENT_NONE;
}

double mbw_window_input_event_x(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.x : 0.0;
}

double mbw_window_input_event_y(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.y : 0.0;
}

int mbw_window_input_event_state(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.state : MBW_ELEMENT_STATE_NONE;
}

int mbw_window_input_event_button(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.button : -1;
}

int mbw_window_input_event_pointer_source(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.pointer_source : MBW_POINTER_SOURCE_UNKNOWN;
}

int mbw_window_input_event_pointer_kind(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.pointer_kind : MBW_POINTER_KIND_UNKNOWN;
}

int mbw_window_input_event_scroll_delta_kind(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.scroll_delta_kind : MBW_SCROLL_DELTA_NONE;
}

double mbw_window_input_event_scroll_delta_x(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.delta_x : 0.0;
}

double mbw_window_input_event_scroll_delta_y(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.delta_y : 0.0;
}

int mbw_window_input_event_phase(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.phase : MBW_TOUCH_PHASE_NONE;
}

int mbw_window_input_event_modifiers(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.modifiers : 0;
}

int mbw_window_input_event_scancode(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.scancode : 0;
}

bool mbw_window_input_event_repeat(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.repeat != 0 : false;
}

moonbit_bytes_t mbw_window_input_event_text_with_all_modifiers(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return moonbit_make_bytes_raw(0);
  }
  return mbw_make_bytes_from_slice(
    window->current_input_event.text_with_all_modifiers,
    window->current_input_event.text_with_all_modifiers_len);
}

moonbit_bytes_t mbw_window_input_event_text_ignoring_modifiers(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return moonbit_make_bytes_raw(0);
  }
  return mbw_make_bytes_from_slice(
    window->current_input_event.text_ignoring_modifiers,
    window->current_input_event.text_ignoring_modifiers_len);
}

moonbit_bytes_t mbw_window_input_event_text_without_modifiers(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return moonbit_make_bytes_raw(0);
  }
  return mbw_make_bytes_from_slice(
    window->current_input_event.text_without_modifiers,
    window->current_input_event.text_without_modifiers_len);
}

int mbw_window_input_event_ime_kind(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.ime_kind : MBW_IME_EVENT_NONE;
}

moonbit_bytes_t mbw_window_input_event_ime_text(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return moonbit_make_bytes_raw(0);
  }
  return mbw_make_bytes_from_slice(
    window->current_input_event.ime_text,
    window->current_input_event.ime_text_len);
}

int mbw_window_input_event_ime_cursor_start(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.ime_cursor_start : -1;
}

int mbw_window_input_event_ime_cursor_end(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->current_input_event.ime_cursor_end : -1;
}

bool mbw_window_take_surface_resized(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window || !window->pending_surface_resized) {
    return false;
  }
  window->pending_surface_resized = 0;
  return true;
}

bool mbw_window_take_redraw_requested(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window || !window->pending_redraw_requested) {
    return false;
  }
  window->pending_redraw_requested = 0;
  return true;
}

void mbw_window_request_redraw(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->pending_redraw_requested = 1;
}

void mbw_window_set_surface_size(int window_id, int width, int height) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }

  mbw_apply_surface_constraints(window, &width, &height);
  window->width = width;
  window->height = height;
  window->reported_width = width;
  window->reported_height = height;
  window->pending_surface_resized = 1;
#if defined(__APPLE__)
  if (window->window) {
    double scale_factor = window->scale_factor > 0.0 ? window->scale_factor : 1.0;
    mbw_size_t logical_size = {
      .width = (double)width / scale_factor,
      .height = (double)height / scale_factor,
    };
    ((void(*)(id, SEL, mbw_size_t))objc_msgSend)(
      (id)window->window, mbw_sel("setContentSize:"), logical_size);
  }
#endif
}

void mbw_window_set_surface_resize_increments(int window_id, int width, int height) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }

  if (width <= 0 || height <= 0) {
    window->resize_increment_width = 0;
    window->resize_increment_height = 0;
  } else {
    window->resize_increment_width = mbw_clamp_size(width);
    window->resize_increment_height = mbw_clamp_size(height);
  }
#if defined(__APPLE__)
  if (window->window) {
    double scale_factor = window->scale_factor > 0.0 ? window->scale_factor : 1.0;
    mbw_size_t increments = {
      .width = window->resize_increment_width > 0
        ? (double)window->resize_increment_width / scale_factor
        : 1.0,
      .height = window->resize_increment_height > 0
        ? (double)window->resize_increment_height / scale_factor
        : 1.0,
    };
    ((void(*)(id, SEL, mbw_size_t))objc_msgSend)(
      (id)window->window, mbw_sel("setResizeIncrements:"), increments);
  }
#endif
}

void mbw_window_set_min_surface_size(int window_id, int width, int height) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }

  if (width <= 0 || height <= 0) {
    window->min_width = 1;
    window->min_height = 1;
  } else {
    window->min_width = mbw_clamp_size(width);
    window->min_height = mbw_clamp_size(height);
  }
  if (window->max_width > 0 && window->max_width < window->min_width) {
    window->max_width = window->min_width;
  }
  if (window->max_height > 0 && window->max_height < window->min_height) {
    window->max_height = window->min_height;
  }
#if defined(__APPLE__)
  if (window->window) {
    double scale_factor = window->scale_factor > 0.0 ? window->scale_factor : 1.0;
    mbw_size_t min_size = {
      .width = (double)window->min_width / scale_factor,
      .height = (double)window->min_height / scale_factor,
    };
    mbw_size_t max_size = {
      .width = window->max_width > 0
        ? (double)window->max_width / scale_factor
        : 10000000.0,
      .height = window->max_height > 0
        ? (double)window->max_height / scale_factor
        : 10000000.0,
    };
    ((void(*)(id, SEL, mbw_size_t))objc_msgSend)(
      (id)window->window, mbw_sel("setContentMinSize:"), min_size);
    ((void(*)(id, SEL, mbw_size_t))objc_msgSend)(
      (id)window->window, mbw_sel("setContentMaxSize:"), max_size);
  }
#endif
  mbw_window_set_surface_size(window_id, window->width, window->height);
}

void mbw_window_set_max_surface_size(int window_id, int width, int height) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }

  if (width <= 0 || height <= 0) {
    window->max_width = 0;
    window->max_height = 0;
  } else {
    window->max_width = mbw_clamp_size(width);
    window->max_height = mbw_clamp_size(height);
    if (window->max_width < window->min_width) {
      window->max_width = window->min_width;
    }
    if (window->max_height < window->min_height) {
      window->max_height = window->min_height;
    }
  }
#if defined(__APPLE__)
  if (window->window) {
    double scale_factor = window->scale_factor > 0.0 ? window->scale_factor : 1.0;
    mbw_size_t min_size = {
      .width = (double)window->min_width / scale_factor,
      .height = (double)window->min_height / scale_factor,
    };
    mbw_size_t max_size = {
      .width = window->max_width > 0
        ? (double)window->max_width / scale_factor
        : 10000000.0,
      .height = window->max_height > 0
        ? (double)window->max_height / scale_factor
        : 10000000.0,
    };
    ((void(*)(id, SEL, mbw_size_t))objc_msgSend)(
      (id)window->window, mbw_sel("setContentMinSize:"), min_size);
    ((void(*)(id, SEL, mbw_size_t))objc_msgSend)(
      (id)window->window, mbw_sel("setContentMaxSize:"), max_size);
  }
#endif
  mbw_window_set_surface_size(window_id, window->width, window->height);
}

void mbw_window_close(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window || window->should_close) {
    return;
  }
#if defined(__APPLE__)
  if (window->window) {
    window->allow_close = 1;
    ((void(*)(id, SEL))objc_msgSend)((id)window->window, mbw_sel("close"));
    return;
  }
#endif
  window->should_close = 1;
  window->pending_destroyed = 1;
}

void mbw_test_window_queue_close_requested(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window || window->should_close) {
    return;
  }
  window->pending_close_requested = 1;
}

void mbw_test_window_queue_focused(int window_id, bool focused) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  if (!focused && window->modifiers_state != 0) {
    window->modifiers_state = 0;
    mbw_window_queue_modifiers_changed(window, 0);
  }
  window->focused = focused ? 1 : 0;
  window->pending_focus_value = focused ? 1 : 0;
  window->pending_focused_changed = 1;
}

void mbw_test_window_queue_moved(int window_id, int x, int y) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  int actual_x = 0;
  int actual_y = 0;
  mbw_window_position(window, &actual_x, &actual_y);
  window->pending_moved = 1;
  window->pending_move_x = x;
  window->pending_move_y = y;
  window->reported_position_valid = 1;
  window->reported_x = actual_x;
  window->reported_y = actual_y;
}

void mbw_test_window_queue_scale_factor_changed(
  int window_id,
  double scale_factor,
  int width,
  int height
) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->pending_scale_factor_changed = 1;
  window->pending_scale_factor = scale_factor > 0.0 ? scale_factor : 1.0;
  window->scale_factor = window->pending_scale_factor;
  window->reported_scale_factor = window->pending_scale_factor;
  window->pending_scale_width = mbw_clamp_size(width);
  window->pending_scale_height = mbw_clamp_size(height);
}

void mbw_test_window_queue_theme_changed(int window_id, int theme_kind) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  if (theme_kind != MBW_THEME_LIGHT && theme_kind != MBW_THEME_DARK) {
    theme_kind = MBW_THEME_UNKNOWN;
  }
  int actual_theme = mbw_window_theme_kind(window);
  window->theme_kind = theme_kind;
  window->pending_theme_changed = 1;
  window->pending_theme_kind = theme_kind;
  window->reported_theme_kind = actual_theme;
}

void mbw_test_window_queue_occluded(int window_id, bool occluded) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  int actual_occluded = mbw_window_occluded(window);
  window->occluded = occluded ? 1 : 0;
  window->pending_occluded_changed = 1;
  window->pending_occluded = window->occluded;
  window->reported_occluded = actual_occluded;
}

void mbw_test_window_queue_pointer_moved(int window_id, double x, double y) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  mbw_window_queue_pointer_moved(window, x, y);
}

void mbw_test_window_queue_pointer_entered(int window_id, double x, double y) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  mbw_window_queue_pointer_entered(window, x, y);
}

void mbw_test_window_queue_pointer_left(int window_id, double x, double y) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  mbw_window_queue_pointer_left(window, x, y);
}

void mbw_test_window_queue_pointer_button(
  int window_id,
  int state,
  double x,
  double y,
  int button
) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  mbw_window_queue_pointer_button(window, state, x, y, button);
}

void mbw_test_window_queue_mouse_wheel(
  int window_id,
  int delta_kind,
  double delta_x,
  double delta_y,
  int phase
) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  mbw_window_queue_mouse_wheel(window, delta_kind, delta_x, delta_y, phase);
}

void mbw_test_window_queue_modifiers_changed(int window_id, int modifiers) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->modifiers_state = modifiers;
  mbw_window_queue_modifiers_changed(window, modifiers);
}

void mbw_test_window_queue_keyboard_input(
  int window_id,
  int scancode,
  int state,
  bool repeat,
  int modifiers
) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->modifiers_state = modifiers;
  mbw_window_queue_keyboard_input(
    window,
    scancode,
    state,
    modifiers,
    repeat ? 1 : 0,
    NULL,
    0,
    NULL,
    0,
    NULL,
    0);
}

void mbw_test_window_queue_keyboard_input_with_text(
  int window_id,
  int scancode,
  int state,
  bool repeat,
  int modifiers,
  const uint8_t *text_with_all_modifiers,
  int text_with_all_modifiers_len,
  const uint8_t *text_ignoring_modifiers,
  int text_ignoring_modifiers_len
) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->modifiers_state = modifiers;
  mbw_window_queue_keyboard_input(
    window,
    scancode,
    state,
    modifiers,
    repeat ? 1 : 0,
    text_with_all_modifiers,
    text_with_all_modifiers_len,
    text_ignoring_modifiers,
    text_ignoring_modifiers_len,
    text_ignoring_modifiers,
    text_ignoring_modifiers_len);
}

void mbw_test_window_queue_ime_preedit(
  int window_id,
  const uint8_t *text,
  int text_len,
  int cursor_start,
  int cursor_end
) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  if (!window->ime_marked_active) {
    mbw_window_queue_ime(window, MBW_IME_EVENT_ENABLED, NULL, 0, -1, -1);
  }
  window->ime_marked_active = 1;
  window->ime_cursor_start = cursor_start;
  window->ime_cursor_end = cursor_end;
  mbw_window_queue_ime(
    window,
    MBW_IME_EVENT_PREEDIT,
    text,
    text_len,
    cursor_start,
    cursor_end);
}

void mbw_test_window_queue_ime_commit(int window_id, const uint8_t *text, int text_len) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->ime_marked_active = 0;
  window->ime_cursor_start = -1;
  window->ime_cursor_end = -1;
  mbw_window_queue_ime(window, MBW_IME_EVENT_COMMIT, text, text_len, -1, -1);
}

void mbw_test_window_queue_ime_disabled(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->ime_marked_active = 0;
  window->ime_cursor_start = -1;
  window->ime_cursor_end = -1;
  mbw_window_queue_ime(window, MBW_IME_EVENT_DISABLED, NULL, 0, -1, -1);
}

bool mbw_test_window_ime_allowed(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->ime_allowed != 0 : false;
}

int mbw_test_window_ime_cursor_area_x(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->ime_cursor_area_x : 0;
}

int mbw_test_window_ime_cursor_area_y(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->ime_cursor_area_y : 0;
}

int mbw_test_window_ime_cursor_area_width(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->ime_cursor_area_width : 0;
}

int mbw_test_window_ime_cursor_area_height(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->ime_cursor_area_height : 0;
}

int mbw_test_window_ime_purpose(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  return window ? window->ime_purpose : MBW_IME_PURPOSE_NORMAL;
}

void mbw_test_window_queue_destroyed(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->should_close = 1;
  window->pending_destroyed = 1;
}

void mbw_window_set_title_utf8(int window_id, const uint8_t *title, uint64_t title_len) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
#if defined(__APPLE__)
  if (window->window) {
    char *title_utf8 = mbw_copy_utf8(title, title_len);
    id ns_title = mbw_make_nsstring(title_utf8 ? title_utf8 : "");
    if (ns_title) {
      ((void(*)(id, SEL, id))objc_msgSend)((id)window->window, mbw_sel("setTitle:"), ns_title);
    }
    if (title_utf8) {
      free(title_utf8);
    }
  }
#else
  (void)title;
  (void)title_len;
#endif
}

void mbw_window_set_visible(int window_id, bool visible) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->visible = visible ? 1 : 0;
#if defined(__APPLE__)
  if (window->window) {
    if (visible) {
      ((void(*)(id, SEL, id))objc_msgSend)(
        (id)window->window, mbw_sel("makeKeyAndOrderFront:"), nil);
    } else {
      ((void(*)(id, SEL, id))objc_msgSend)((id)window->window, mbw_sel("orderOut:"), nil);
    }
  }
#endif
}

void mbw_window_set_resizable(int window_id, bool resizable) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->resizable = resizable ? 1 : 0;
#if defined(__APPLE__)
  if (window->window) {
    mbw_nsuint_t style_mask = 0;
    if (window->decorated) {
      style_mask |= (1UL << 0) | (1UL << 1) | (1UL << 2);
    }
    if (window->resizable) {
      style_mask |= (1UL << 3);
    }
    ((void(*)(id, SEL, mbw_nsuint_t))objc_msgSend)(
      (id)window->window, mbw_sel("setStyleMask:"), style_mask);
  }
#endif
  mbw_window_set_enabled_buttons(
    window_id,
    window->close_button_enabled != 0,
    window->minimize_button_enabled != 0,
    window->maximize_button_enabled != 0);
}

void mbw_window_set_decorations(int window_id, bool decorated) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->decorated = decorated ? 1 : 0;
#if defined(__APPLE__)
  if (window->window) {
    mbw_nsuint_t style_mask = 0;
    if (window->decorated) {
      style_mask |= (1UL << 0) | (1UL << 1) | (1UL << 2);
    }
    if (window->resizable) {
      style_mask |= (1UL << 3);
    }
    ((void(*)(id, SEL, mbw_nsuint_t))objc_msgSend)(
      (id)window->window, mbw_sel("setStyleMask:"), style_mask);
  }
#endif
  mbw_window_set_enabled_buttons(
    window_id,
    window->close_button_enabled != 0,
    window->minimize_button_enabled != 0,
    window->maximize_button_enabled != 0);
}

void mbw_window_set_enabled_buttons(
  int window_id,
  bool close,
  bool minimize,
  bool maximize
) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->close_button_enabled = close ? 1 : 0;
  window->minimize_button_enabled = minimize ? 1 : 0;
  window->maximize_button_enabled = maximize ? 1 : 0;
#if defined(__APPLE__)
  if (window->window) {
    id close_button = ((id(*)(id, SEL, mbw_nsinteger_t))objc_msgSend)(
      (id)window->window, mbw_sel("standardWindowButton:"), MBW_NSWINDOW_BUTTON_CLOSE);
    id minimize_button = ((id(*)(id, SEL, mbw_nsinteger_t))objc_msgSend)(
      (id)window->window, mbw_sel("standardWindowButton:"), MBW_NSWINDOW_BUTTON_MINIMIZE);
    id maximize_button = ((id(*)(id, SEL, mbw_nsinteger_t))objc_msgSend)(
      (id)window->window, mbw_sel("standardWindowButton:"), MBW_NSWINDOW_BUTTON_MAXIMIZE);
    if (close_button) {
      ((void(*)(id, SEL, mbw_bool_t))objc_msgSend)(
        close_button,
        mbw_sel("setEnabled:"),
        window->close_button_enabled ? YES : NO);
    }
    if (minimize_button) {
      ((void(*)(id, SEL, mbw_bool_t))objc_msgSend)(
        minimize_button,
        mbw_sel("setEnabled:"),
        window->minimize_button_enabled ? YES : NO);
    }
    if (maximize_button) {
      ((void(*)(id, SEL, mbw_bool_t))objc_msgSend)(
        maximize_button,
        mbw_sel("setEnabled:"),
        window->maximize_button_enabled ? YES : NO);
    }
  }
#endif
}

void mbw_window_focus(int window_id) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window || window->should_close) {
    return;
  }
  window->focused = 1;
  window->pending_focus_value = 1;
  window->pending_focused_changed = 1;
#if defined(__APPLE__)
  if (window->window && window->visible) {
    ((void(*)(id, SEL, id))objc_msgSend)(
      (id)window->window,
      mbw_sel("makeKeyAndOrderFront:"),
      nil);
  }
#endif
}

void mbw_window_set_minimized(int window_id, bool minimized) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->minimized = minimized ? 1 : 0;
#if defined(__APPLE__)
  if (window->window) {
    if (minimized) {
      ((void(*)(id, SEL, id))objc_msgSend)(
        (id)window->window,
        mbw_sel("miniaturize:"),
        nil);
    } else {
      ((void(*)(id, SEL, id))objc_msgSend)(
        (id)window->window,
        mbw_sel("deminiaturize:"),
        nil);
    }
  }
#endif
}

void mbw_window_set_maximized(int window_id, bool maximized) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->maximized = maximized ? 1 : 0;
#if defined(__APPLE__)
  if (window->window) {
    mbw_bool_t is_zoomed = ((mbw_bool_t(*)(id, SEL))objc_msgSend)(
      (id)window->window,
      mbw_sel("isZoomed"));
    if ((is_zoomed ? 1 : 0) != window->maximized) {
      ((void(*)(id, SEL, id))objc_msgSend)(
        (id)window->window,
        mbw_sel("zoom:"),
        nil);
    }
  }
#endif
}

void mbw_window_set_fullscreen(int window_id, bool fullscreen) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  int target = fullscreen ? 1 : 0;
  window->fullscreen = target;
#if defined(__APPLE__)
  if (window->window) {
    mbw_nsuint_t style_mask = ((mbw_nsuint_t(*)(id, SEL))objc_msgSend)(
      (id)window->window,
      mbw_sel("styleMask"));
    int actual = (style_mask & MBW_NSWINDOW_STYLE_MASK_FULLSCREEN) != 0 ? 1 : 0;
    if (actual != target) {
      ((void(*)(id, SEL, id))objc_msgSend)(
        (id)window->window,
        mbw_sel("toggleFullScreen:"),
        nil);
    }
  }
#endif
}

void mbw_window_set_transparent(int window_id, bool transparent) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->transparent = transparent ? 1 : 0;
#if defined(__APPLE__)
  if (window->window) {
    int use_clear_background = (window->transparent || window->blur) ? 1 : 0;
    ((void(*)(id, SEL, mbw_bool_t))objc_msgSend)(
      (id)window->window,
      mbw_sel("setOpaque:"),
      use_clear_background ? NO : YES);
    Class ns_color_class = objc_getClass("NSColor");
    if (ns_color_class) {
      id background_color = use_clear_background
        ? ((id(*)(id, SEL))objc_msgSend)(
            (id)ns_color_class,
            mbw_sel("clearColor"))
        : ((id(*)(id, SEL))objc_msgSend)(
            (id)ns_color_class,
            mbw_sel("windowBackgroundColor"));
      if (background_color) {
        ((void(*)(id, SEL, id))objc_msgSend)(
          (id)window->window,
          mbw_sel("setBackgroundColor:"),
          background_color);
      }
    }
  }
#endif
}

void mbw_window_set_blur(int window_id, bool blur) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->blur = blur ? 1 : 0;
#if defined(__APPLE__)
  if (window->window) {
    int use_clear_background = (window->transparent || window->blur) ? 1 : 0;
    ((void(*)(id, SEL, mbw_bool_t))objc_msgSend)(
      (id)window->window,
      mbw_sel("setOpaque:"),
      use_clear_background ? NO : YES);
    Class ns_color_class = objc_getClass("NSColor");
    if (ns_color_class) {
      id background_color = use_clear_background
        ? ((id(*)(id, SEL))objc_msgSend)(
            (id)ns_color_class,
            mbw_sel("clearColor"))
        : ((id(*)(id, SEL))objc_msgSend)(
            (id)ns_color_class,
            mbw_sel("windowBackgroundColor"));
      if (background_color) {
        ((void(*)(id, SEL, id))objc_msgSend)(
          (id)window->window,
          mbw_sel("setBackgroundColor:"),
          background_color);
      }
    }
  }
#endif
}

void mbw_window_set_window_level(int window_id, int level) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  int next_level = MBW_WINDOW_LEVEL_NORMAL;
  if (level == MBW_WINDOW_LEVEL_ALWAYS_ON_TOP) {
    next_level = MBW_WINDOW_LEVEL_ALWAYS_ON_TOP;
  } else if (level == MBW_WINDOW_LEVEL_ALWAYS_ON_BOTTOM) {
    next_level = MBW_WINDOW_LEVEL_ALWAYS_ON_BOTTOM;
  }
  window->window_level = next_level;
#if defined(__APPLE__)
  if (window->window) {
    ((void(*)(id, SEL, mbw_nsinteger_t))objc_msgSend)(
      (id)window->window,
      mbw_sel("setLevel:"),
      mbw_native_window_level(next_level));
  }
#endif
}

void mbw_window_set_theme(int window_id, int theme) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }

  int next_theme = MBW_THEME_UNKNOWN;
  if (theme == MBW_THEME_LIGHT) {
    next_theme = MBW_THEME_LIGHT;
  } else if (theme == MBW_THEME_DARK) {
    next_theme = MBW_THEME_DARK;
  }

#if defined(__APPLE__)
  if (window->window) {
    id appearance = nil;
    if (next_theme == MBW_THEME_LIGHT || next_theme == MBW_THEME_DARK) {
      Class appearance_class = objc_getClass("NSAppearance");
      if (appearance_class) {
        const char *appearance_name = next_theme == MBW_THEME_DARK
          ? "NSAppearanceNameDarkAqua"
          : "NSAppearanceNameAqua";
        id ns_appearance_name = mbw_make_nsstring(appearance_name);
        if (ns_appearance_name) {
          appearance = ((id(*)(id, SEL, id))objc_msgSend)(
            (id)appearance_class,
            mbw_sel("appearanceNamed:"),
            ns_appearance_name);
        }
      }
    }
    ((void(*)(id, SEL, id))objc_msgSend)(
      (id)window->window,
      mbw_sel("setAppearance:"),
      appearance);
    int actual_theme = mbw_window_theme_kind(window);
    if (actual_theme != MBW_THEME_UNKNOWN) {
      next_theme = actual_theme;
    }
  }
#endif

  window->theme_kind = next_theme;
  window->reported_theme_kind = next_theme;
  window->pending_theme_changed = 0;
  window->pending_theme_kind = next_theme;
}

void mbw_window_set_content_protected(int window_id, bool content_protected) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->content_protected = content_protected ? 1 : 0;
#if defined(__APPLE__)
  if (window->window) {
    ((void(*)(id, SEL, mbw_nsuint_t))objc_msgSend)(
      (id)window->window,
      mbw_sel("setSharingType:"),
      window->content_protected
        ? MBW_NSWINDOW_SHARING_NONE
        : MBW_NSWINDOW_SHARING_READ_ONLY);
  }
#endif
}

void mbw_window_set_ime_purpose(int window_id, int purpose) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  int next_purpose = MBW_IME_PURPOSE_NORMAL;
  if (purpose == MBW_IME_PURPOSE_PASSWORD) {
    next_purpose = MBW_IME_PURPOSE_PASSWORD;
  } else if (purpose == MBW_IME_PURPOSE_TERMINAL) {
    next_purpose = MBW_IME_PURPOSE_TERMINAL;
  }
  window->ime_purpose = next_purpose;
}

void mbw_window_set_ime_allowed(int window_id, bool allowed) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  int next_allowed = allowed ? 1 : 0;
  if (window->ime_allowed == next_allowed) {
    return;
  }
  window->ime_allowed = next_allowed;
  if (!window->ime_allowed) {
    if (window->ime_marked_active) {
      mbw_window_queue_ime(window, MBW_IME_EVENT_DISABLED, NULL, 0, -1, -1);
    }
    window->ime_marked_active = 0;
    window->ime_cursor_start = -1;
    window->ime_cursor_end = -1;
  }
#if defined(__APPLE__)
  if (window->content_view) {
    id input_context = ((id(*)(id, SEL))objc_msgSend)(
      (id)window->content_view,
      mbw_sel("inputContext"));
    if (input_context) {
      ((void(*)(id, SEL))objc_msgSend)(
        input_context,
        mbw_sel("invalidateCharacterCoordinates"));
      if (!window->ime_allowed) {
        ((void(*)(id, SEL))objc_msgSend)(
          input_context,
          mbw_sel("discardMarkedText"));
      }
    }
  }
#endif
}

void mbw_window_set_ime_cursor_area(
  int window_id,
  int x,
  int y,
  int width,
  int height
) {
  mbw_window_t *window = mbw_find_window(window_id);
  if (!window) {
    return;
  }
  window->ime_cursor_area_x = x;
  window->ime_cursor_area_y = y;
  window->ime_cursor_area_width = mbw_clamp_size(width);
  window->ime_cursor_area_height = mbw_clamp_size(height);
#if defined(__APPLE__)
  if (window->content_view) {
    id input_context = ((id(*)(id, SEL))objc_msgSend)(
      (id)window->content_view,
      mbw_sel("inputContext"));
    if (input_context) {
      ((void(*)(id, SEL))objc_msgSend)(
        input_context,
        mbw_sel("invalidateCharacterCoordinates"));
    }
  }
#endif
}
