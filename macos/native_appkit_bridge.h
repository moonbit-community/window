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
#include <stdlib.h>
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
typedef int32_t (*mbw_sync_query_trampoline_t)(void *closure, int32_t raw_id, int32_t kind,
                                               uint64_t arg0);
typedef void (*mbw_lifecycle_trampoline_t)(void *closure, int32_t kind);
typedef void (*mbw_send_event_impl_t)(id self, SEL _cmd, NSEvent *event);

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
void mbw_call_input_event_trampoline(int32_t raw_id, int32_t kind, uint64_t event_handle);
void mbw_call_text_input_event_trampoline(int32_t raw_id, int32_t kind, uint64_t event_handle,
                                          int32_t state, uint64_t text_handle,
                                          int32_t cursor_start, int32_t cursor_end,
                                          uint64_t path_handle);
void mbw_call_device_event_trampoline(uint64_t event_handle);
int32_t mbw_sync_query(int32_t raw_id, int32_t kind, uint64_t arg0, int32_t default_value);
void mbw_call_lifecycle_trampoline(mbw_lifecycle_trampoline_t trampoline, void *closure,
                                   int32_t callback_kind);
void mbw_ensure_app_initialized(void);
