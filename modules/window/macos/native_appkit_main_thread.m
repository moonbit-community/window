#import "native_appkit_bridge.h"

#import <dispatch/dispatch.h>

typedef void (*mbw_main_thread_trampoline_t)(void *closure);

typedef struct {
  mbw_main_thread_trampoline_t trampoline;
  void *closure;
} MBWMainThreadCall;

static void mbw_invoke_main_thread_call(void *raw_call) {
  MBWMainThreadCall *call = (MBWMainThreadCall *)raw_call;
  @autoreleasepool {
    // A borrowed closure must be pinned while a native trampoline calls MoonBit.
    moonbit_incref(call->closure);
    call->trampoline(call->closure);
    moonbit_decref(call->closure);
  }
}

MOONBIT_FFI_EXPORT
void mbw_run_on_main(mbw_main_thread_trampoline_t trampoline, void *closure) {
  if (trampoline == NULL || closure == NULL) {
    return;
  }
  MBWMainThreadCall call = {
      .trampoline = trampoline,
      .closure = closure,
  };
  // The stack context and borrowed closure remain alive until dispatch_sync_f returns.
  if (pthread_main_np() != 0) {
    mbw_invoke_main_thread_call(&call);
  } else {
    dispatch_sync_f(dispatch_get_main_queue(), &call, mbw_invoke_main_thread_call);
  }
}
