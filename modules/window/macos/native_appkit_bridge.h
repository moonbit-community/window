#import <AppKit/AppKit.h>
#import <ApplicationServices/ApplicationServices.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <moonbit.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <stdint.h>

#include <dlfcn.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>

typedef void (*mbw_window_event_trampoline_t)(void *closure, int32_t kind, int32_t raw_id,
                                              int32_t arg0, int32_t arg1, int32_t arg2,
                                              double argd);
typedef void (*mbw_input_event_trampoline_t)(
    void *closure, int32_t raw_id, int32_t kind, int32_t event_type, double x, double y,
    int32_t state, int32_t button, int32_t modifier_flags, int32_t scancode, int32_t repeat,
    int32_t pointer_source, int32_t pointer_kind, int32_t scroll_delta_kind, double delta_x,
    double delta_y, int32_t phase, uint64_t text_with_all_modifiers,
    uint64_t text_ignoring_modifiers, uint64_t text_without_modifiers);
typedef void (*mbw_text_input_event_trampoline_t)(void *closure, int32_t raw_id, int32_t kind,
                                                  int32_t state, uint64_t text_handle,
                                                  int32_t cursor_start, int32_t cursor_end,
                                                  uint64_t path_handle);
typedef void (*mbw_device_event_trampoline_t)(void *closure, int32_t kind, int32_t button,
                                              double delta_x, double delta_y);
typedef void (*mbw_drag_event_trampoline_t)(void *closure, int32_t raw_id, int32_t kind,
                                            double x, double y, int32_t has_position,
                                            uint64_t path_cstr);
typedef int32_t (*mbw_sync_query_trampoline_t)(void *closure, int32_t raw_id, int32_t kind,
                                               uint64_t arg0);
typedef void (*mbw_menu_action_trampoline_t)(void *closure, int32_t action_id);
typedef void (*mbw_lifecycle_trampoline_t)(void *closure, int32_t kind);
typedef void (*mbw_send_event_impl_t)(id self, SEL _cmd, NSEvent *event);
typedef struct MBWObjcOwnedObjectHandle MBWObjcOwnedObjectHandle;

MBWObjcOwnedObjectHandle *mbw_objc_owned_object_adopt(id object);

MOONBIT_FFI_EXPORT
MBWObjcOwnedObjectHandle *mbw_objc_wrap_owned_object(uint64_t object_handle);

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
  MBW_SYNC_QUERY_DRAG_ACCEPT = 100,
};

void mbw_call_window_event_trampoline(int32_t kind, int32_t raw_id, int32_t arg0, int32_t arg1,
                                      int32_t arg2, double argd);
void mbw_call_input_event_trampoline(
    int32_t raw_id, int32_t kind, int32_t event_type, double x, double y, int32_t state,
    int32_t button, int32_t modifier_flags, int32_t scancode, int32_t repeat,
    int32_t pointer_source, int32_t pointer_kind, int32_t scroll_delta_kind, double delta_x,
    double delta_y, int32_t phase, uint64_t text_with_all_modifiers,
    uint64_t text_ignoring_modifiers, uint64_t text_without_modifiers);
void mbw_call_text_input_event_trampoline(int32_t raw_id, int32_t kind, int32_t state,
                                          uint64_t text_handle, int32_t cursor_start,
                                          int32_t cursor_end, uint64_t path_handle);
void mbw_call_device_event_trampoline(int32_t kind, int32_t button, double delta_x,
                                      double delta_y);
void mbw_call_drag_event_trampoline(int32_t raw_id, int32_t kind, double x, double y,
                                    int32_t has_position, uint64_t path_cstr);
int32_t mbw_sync_query(int32_t raw_id, int32_t kind, uint64_t arg0, int32_t default_value);
void mbw_call_lifecycle_trampoline(mbw_lifecycle_trampoline_t trampoline, void *closure,
                                   int32_t callback_kind);
void mbw_ensure_app_initialized(void);
