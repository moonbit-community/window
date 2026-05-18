#import "native_appkit_bridge.h"

static mbw_window_event_trampoline_t g_window_event_trampoline = NULL;
static void *g_window_event_closure = NULL;
static mbw_input_event_trampoline_t g_input_event_trampoline = NULL;
static void *g_input_event_closure = NULL;
static mbw_text_input_event_trampoline_t g_text_input_event_trampoline = NULL;
static void *g_text_input_event_closure = NULL;
static mbw_device_event_trampoline_t g_device_event_trampoline = NULL;
static void *g_device_event_closure = NULL;
static mbw_drag_event_trampoline_t g_drag_event_trampoline = NULL;
static void *g_drag_event_closure = NULL;
static mbw_sync_query_trampoline_t g_sync_query_trampoline = NULL;
static void *g_sync_query_closure = NULL;
static mbw_send_event_impl_t g_original_send_event_impl = NULL;
static BOOL g_app_initialized = NO;

void mbw_call_window_event_trampoline(int32_t kind, int32_t raw_id, int32_t arg0, int32_t arg1,
                                      int32_t arg2, double argd) {
  if (g_window_event_trampoline == NULL || g_window_event_closure == NULL) {
    return;
  }
  void *closure = g_window_event_closure;
  moonbit_incref(closure);
  g_window_event_trampoline(closure, kind, raw_id, arg0, arg1, arg2, argd);
  moonbit_decref(closure);
}

void mbw_call_input_event_trampoline(
    int32_t raw_id, int32_t kind, int32_t event_type, double x, double y, int32_t state,
    int32_t button, int32_t modifier_flags, int32_t scancode, int32_t repeat,
    int32_t pointer_source, int32_t pointer_kind, int32_t scroll_delta_kind, double delta_x,
    double delta_y, int32_t phase, uint64_t text_with_all_modifiers,
    uint64_t text_ignoring_modifiers, uint64_t text_without_modifiers) {
  if (g_input_event_trampoline == NULL || g_input_event_closure == NULL) {
    return;
  }
  void *closure = g_input_event_closure;
  moonbit_incref(closure);
  g_input_event_trampoline(closure, raw_id, kind, event_type, x, y, state, button,
                           modifier_flags, scancode, repeat, pointer_source, pointer_kind,
                           scroll_delta_kind, delta_x, delta_y, phase, text_with_all_modifiers,
                           text_ignoring_modifiers, text_without_modifiers);
  moonbit_decref(closure);
}

void mbw_call_text_input_event_trampoline(int32_t raw_id, int32_t kind, int32_t state,
                                          uint64_t text_handle, int32_t cursor_start,
                                          int32_t cursor_end, uint64_t path_handle) {
  if (g_text_input_event_trampoline == NULL || g_text_input_event_closure == NULL) {
    return;
  }
  void *closure = g_text_input_event_closure;
  moonbit_incref(closure);
  g_text_input_event_trampoline(closure, raw_id, kind, state, text_handle, cursor_start,
                                cursor_end, path_handle);
  moonbit_decref(closure);
}

void mbw_call_device_event_trampoline(int32_t kind, int32_t button, double delta_x,
                                      double delta_y) {
  if (g_device_event_trampoline == NULL || g_device_event_closure == NULL) {
    return;
  }
  void *closure = g_device_event_closure;
  moonbit_incref(closure);
  g_device_event_trampoline(closure, kind, button, delta_x, delta_y);
  moonbit_decref(closure);
}

void mbw_call_drag_event_trampoline(int32_t raw_id, int32_t kind, double x, double y,
                                    int32_t has_position, uint64_t path_cstr) {
  if (g_drag_event_trampoline == NULL || g_drag_event_closure == NULL) {
    return;
  }
  void *closure = g_drag_event_closure;
  moonbit_incref(closure);
  g_drag_event_trampoline(closure, raw_id, kind, x, y, has_position, path_cstr);
  moonbit_decref(closure);
}

int32_t mbw_sync_query(int32_t raw_id, int32_t kind, uint64_t arg0, int32_t default_value) {
  if (raw_id <= 0 || g_sync_query_trampoline == NULL || g_sync_query_closure == NULL) {
    return default_value;
  }
  void *closure = g_sync_query_closure;
  moonbit_incref(closure);
  int32_t result = g_sync_query_trampoline(closure, raw_id, kind, arg0);
  moonbit_decref(closure);
  return result;
}

void mbw_call_lifecycle_trampoline(mbw_lifecycle_trampoline_t trampoline, void *closure,
                                   int32_t callback_kind) {
  if (trampoline == NULL || closure == NULL) {
    return;
  }
  moonbit_incref(closure);
  trampoline(closure, callback_kind);
  moonbit_decref(closure);
}

void mbw_ensure_app_initialized(void) {
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
  switch (event.type) {
  case NSEventTypeMouseMoved:
  case NSEventTypeLeftMouseDragged:
  case NSEventTypeRightMouseDragged:
  case NSEventTypeOtherMouseDragged:
    if (event.deltaX != 0.0 || event.deltaY != 0.0) {
      mbw_call_device_event_trampoline(1, 0, (double)event.deltaX, (double)event.deltaY);
    }
    break;
  case NSEventTypeLeftMouseDown:
  case NSEventTypeRightMouseDown:
  case NSEventTypeOtherMouseDown:
    mbw_call_device_event_trampoline(2, (int32_t)event.buttonNumber, 0.0, 0.0);
    break;
  case NSEventTypeLeftMouseUp:
  case NSEventTypeRightMouseUp:
  case NSEventTypeOtherMouseUp:
    mbw_call_device_event_trampoline(3, (int32_t)event.buttonNumber, 0.0, 0.0);
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
void mbw_install_drag_event_callback(mbw_drag_event_trampoline_t trampoline, void *closure) {
  if (g_drag_event_closure != NULL) {
    moonbit_decref(g_drag_event_closure);
  }
  g_drag_event_trampoline = trampoline;
  g_drag_event_closure = closure;
}

MOONBIT_FFI_EXPORT
void mbw_install_sync_query_callback(mbw_sync_query_trampoline_t trampoline, void *closure) {
  if (g_sync_query_closure != NULL) {
    moonbit_decref(g_sync_query_closure);
  }
  g_sync_query_trampoline = trampoline;
  g_sync_query_closure = closure;
}

MOONBIT_FFI_EXPORT
void mbw_override_send_event(void) {
  mbw_ensure_app_initialized();
  mbw_override_send_event_for_application([NSApplication sharedApplication], YES);
}
