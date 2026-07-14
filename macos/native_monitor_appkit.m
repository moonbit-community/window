#import "native_appkit_bridge.h"

#import <dispatch/dispatch.h>

typedef struct {
  CGDirectDisplayID display_id;
  double scale_factor;
} MBWMonitorScaleFactorContext;

static BOOL mbw_display_ids_have_same_uuid(CGDirectDisplayID lhs, CGDirectDisplayID rhs) {
  CFUUIDRef lhs_uuid = CGDisplayCreateUUIDFromDisplayID(lhs);
  CFUUIDRef rhs_uuid = CGDisplayCreateUUIDFromDisplayID(rhs);
  BOOL equal = lhs_uuid != NULL && rhs_uuid != NULL && CFEqual(lhs_uuid, rhs_uuid);
  if (lhs_uuid != NULL) {
    CFRelease(lhs_uuid);
  }
  if (rhs_uuid != NULL) {
    CFRelease(rhs_uuid);
  }
  return equal;
}

static void mbw_query_monitor_scale_factor(void *raw_context) {
  MBWMonitorScaleFactorContext *context = (MBWMonitorScaleFactorContext *)raw_context;
  @autoreleasepool {
    for (NSScreen *screen in [NSScreen screens]) {
      NSNumber *screen_number = [[screen deviceDescription] objectForKey:@"NSScreenNumber"];
      if (screen_number == nil) {
        continue;
      }
      CGDirectDisplayID screen_id = (CGDirectDisplayID)[screen_number unsignedIntValue];
      if (mbw_display_ids_have_same_uuid(context->display_id, screen_id)) {
        context->scale_factor = (double)[screen backingScaleFactor];
        return;
      }
    }
  }
}

double mbw_monitor_backing_scale_factor(uint32_t display_id) {
  MBWMonitorScaleFactorContext context = {
      .display_id = (CGDirectDisplayID)display_id,
      .scale_factor = 0.0,
  };
  if (pthread_main_np() != 0) {
    mbw_query_monitor_scale_factor(&context);
  } else {
    dispatch_sync_f(dispatch_get_main_queue(), &context, mbw_query_monitor_scale_factor);
  }
  return context.scale_factor;
}
