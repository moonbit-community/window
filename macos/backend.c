#include <stdbool.h>
#include <stdatomic.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>

#if defined(__APPLE__)
#include <objc/message.h>
#include <objc/runtime.h>
#endif

typedef struct mbw_window {
  int id;
  int width;
  int height;
  double scale_factor;
  int should_close;
  int pending_close_requested;
  int pending_surface_resized;
  int pending_redraw_requested;
  int reported_width;
  int reported_height;
  int visible;
  int resizable;
#if defined(__APPLE__)
  void *window;
  void *content_view;
#endif
} mbw_window_t;

static mbw_window_t **g_windows = NULL;
static size_t g_windows_len = 0;
static size_t g_windows_cap = 0;
static int g_next_window_id = 1;
static atomic_int g_pending_proxy_wake_up = 0;

static int mbw_clamp_size(int value) {
  return value <= 0 ? 1 : value;
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

#ifndef YES
#define YES ((mbw_bool_t)1)
#endif

#ifndef NO
#define NO ((mbw_bool_t)0)
#endif

static bool g_bootstrap_done = false;
static bool g_bootstrap_ok = false;
static id g_ns_app = nil;

static SEL mbw_sel(const char *name) {
  return sel_registerName(name);
}

static id mbw_msg_id(id obj, const char *sel_name) {
  return ((id(*)(id, SEL))objc_msgSend)(obj, mbw_sel(sel_name));
}

static void mbw_msg_void(id obj, const char *sel_name) {
  ((void(*)(id, SEL))objc_msgSend)(obj, mbw_sel(sel_name));
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

static void mbw_update_window_state(mbw_window_t *window) {
  if (!window || !window->window) {
    return;
  }

  mbw_bool_t is_visible = ((mbw_bool_t(*)(id, SEL))objc_msgSend)(
    (id)window->window, mbw_sel("isVisible"));
  window->visible = is_visible ? 1 : 0;
  if (!is_visible && !window->should_close) {
    window->should_close = 1;
    window->pending_close_requested = 1;
  }

  window->scale_factor = ((double(*)(id, SEL))objc_msgSend)(
    (id)window->window, mbw_sel("backingScaleFactor"));
  if (window->scale_factor <= 0.0) {
    window->scale_factor = 1.0;
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
    window->width = mbw_clamp_size(width);
    window->height = mbw_clamp_size(height);
  }

  if (window->width != window->reported_width || window->height != window->reported_height) {
    window->reported_width = window->width;
    window->reported_height = window->height;
    window->pending_surface_resized = 1;
  }
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

bool mbw_event_loop_take_proxy_wake_up(void) {
  return atomic_exchange_explicit(&g_pending_proxy_wake_up, 0, memory_order_acq_rel) != 0;
}

void mbw_event_loop_wake_up(void) {
  atomic_store_explicit(&g_pending_proxy_wake_up, 1, memory_order_release);
}

void mbw_sleep_millis(int ms) {
  if (ms <= 0) {
    return;
  }
  usleep((useconds_t)ms * 1000U);
}

int mbw_window_create_utf8(
  int width,
  int height,
  bool visible,
  bool resizable,
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
  window->scale_factor = 1.0;
  window->should_close = 0;
  window->pending_close_requested = 0;
  window->pending_surface_resized = 0;
  window->pending_redraw_requested = 0;
  window->reported_width = window->width;
  window->reported_height = window->height;
  window->visible = visible ? 1 : 0;
  window->resizable = resizable ? 1 : 0;

#if defined(__APPLE__)
  if (mbw_bootstrap_app()) {
    Class window_class = objc_getClass("NSWindow");
    if (window_class) {
      id allocated = mbw_msg_id((id)window_class, "alloc");
      mbw_rect_t rect = {
        .origin = {0.0, 0.0},
        .size = {(double)window->width, (double)window->height},
      };
      mbw_nsuint_t style_mask = (1UL << 0) | (1UL << 1) | (1UL << 2);
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
        mbw_msg_void(ns_window, "center");
        if (visible) {
          ((void(*)(id, SEL, id))objc_msgSend)(
            ns_window, mbw_sel("makeKeyAndOrderFront:"), nil);
        } else {
          ((void(*)(id, SEL, id))objc_msgSend)(ns_window, mbw_sel("orderOut:"), nil);
        }
        window->window = (void *)ns_window;
        window->content_view = (void *)mbw_msg_id(ns_window, "contentView");
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
  if (!mbw_bootstrap_app() || !g_ns_app) {
    return;
  }
  id date_class = (id)objc_getClass("NSDate");
  id distant_past = date_class ? mbw_msg_id(date_class, "distantPast") : nil;
  id runloop_mode = mbw_make_nsstring("kCFRunLoopDefaultMode");
  while (true) {
    id event =
      ((id(*)(id, SEL, mbw_nsuint_t, id, id, mbw_bool_t))objc_msgSend)(
        g_ns_app,
        mbw_sel("nextEventMatchingMask:untilDate:inMode:dequeue:"),
        (mbw_nsuint_t)~(mbw_nsuint_t)0,
        distant_past,
        runloop_mode,
        YES);
    if (!event) {
      break;
    }
    ((void(*)(id, SEL, id))objc_msgSend)(g_ns_app, mbw_sel("sendEvent:"), event);
  }
  mbw_msg_void(g_ns_app, "updateWindows");
  mbw_update_window_state(window);
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
    mbw_nsuint_t style_mask =
      ((mbw_nsuint_t(*)(id, SEL))objc_msgSend)((id)window->window, mbw_sel("styleMask"));
    if (resizable) {
      style_mask |= (1UL << 3);
    } else {
      style_mask &= ~(1UL << 3);
    }
    ((void(*)(id, SEL, mbw_nsuint_t))objc_msgSend)(
      (id)window->window, mbw_sel("setStyleMask:"), style_mask);
  }
#endif
}
