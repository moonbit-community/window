// System menu bar support for macOS.

#import "native_appkit_bridge.h"
#import <objc/runtime.h>

static mbw_menu_action_trampoline_t g_menu_action_trampoline = NULL;
static void *g_menu_action_closure = NULL;
static id g_menu_action_target = nil;
static const char kMBWMenuActionIdKey;

@interface MBWMenuActionTarget : NSObject
- (void)handleMenuAction:(id)sender;
@end

@implementation MBWMenuActionTarget

- (void)handleMenuAction:(id)sender {
  if (g_menu_action_trampoline == NULL || g_menu_action_closure == NULL) {
    return;
  }
  NSNumber *action_id = objc_getAssociatedObject(sender, &kMBWMenuActionIdKey);
  void *closure = g_menu_action_closure;
  moonbit_incref(closure);
  g_menu_action_trampoline(closure, action_id ? [action_id intValue] : -1);
  moonbit_decref(closure);
}

@end

MOONBIT_FFI_EXPORT
void mbw_install_menu_action_callback(mbw_menu_action_trampoline_t trampoline, void *closure) {
  if (g_menu_action_closure != NULL) {
    moonbit_decref(g_menu_action_closure);
  }
  g_menu_action_trampoline = trampoline;
  g_menu_action_closure = closure;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_create_menu_action_target(void) {
  if (g_menu_action_target == nil) {
    g_menu_action_target = [[MBWMenuActionTarget alloc] init];
  }
  return (uint64_t)(uintptr_t)g_menu_action_target;
}

MOONBIT_FFI_EXPORT
void mbw_set_menu_item_action_id(uint64_t item_handle, int32_t action_id) {
  id item = (__bridge id)(void *)item_handle;
  objc_setAssociatedObject(item, &kMBWMenuActionIdKey,
                           @(action_id), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
