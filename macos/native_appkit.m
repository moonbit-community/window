#import "native_appkit_bridge.h"

MOONBIT_FFI_EXPORT
moonbit_bytes_t mbw_objc_copy_utf8_bytes(uint64_t object_handle) {
  if (object_handle == 0) {
    moonbit_bytes_t empty = moonbit_make_bytes(0, 0);
    return empty;
  }
  id object = (__bridge id)(void *)(uintptr_t)object_handle;
  if (object == nil || ![object respondsToSelector:@selector(UTF8String)]) {
    moonbit_bytes_t empty = moonbit_make_bytes(0, 0);
    return empty;
  }
  const char *utf8 = ((const char *(*)(id, SEL))objc_msgSend)(object, @selector(UTF8String));
  if (utf8 == NULL) {
    utf8 = "";
  }
  size_t len = strlen(utf8);
  moonbit_bytes_t bytes = moonbit_make_bytes((int32_t)len, 0);
  if (len > 0) {
    memcpy(bytes, utf8, len);
  }
  return bytes;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t mbw_copy_utf8_cstr_bytes(uint64_t cstr_handle) {
  if (cstr_handle == 0) {
    return moonbit_make_bytes(0, 0);
  }
  const char *utf8 = (const char *)(uintptr_t)cstr_handle;
  size_t len = strlen(utf8);
  moonbit_bytes_t bytes = moonbit_make_bytes((int32_t)len, 0);
  if (len > 0) {
    memcpy(bytes, utf8, len);
  }
  return bytes;
}

MOONBIT_FFI_EXPORT
double mbw_cgfloat_max(void) {
  return (double)CGFLOAT_MAX;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_appkit_window_level(int32_t kind) {
  switch (kind) {
  case 1:
    return (uint64_t)(int64_t)NSFloatingWindowLevel;
  case 2:
    return (uint64_t)(int64_t)(NSNormalWindowLevel - 1);
  default:
    return (uint64_t)(int64_t)NSNormalWindowLevel;
  }
}

MOONBIT_FFI_EXPORT
int32_t mbw_cgs_set_window_background_blur_radius(int32_t window_number, int32_t radius) {
  typedef int32_t (*mbw_cgs_main_connection_id_t)(void);
  typedef int32_t (*mbw_cgs_set_blur_t)(int32_t, int32_t, int32_t);

  mbw_cgs_main_connection_id_t main_connection =
      (mbw_cgs_main_connection_id_t)dlsym(RTLD_DEFAULT, "CGSMainConnectionID");
  mbw_cgs_set_blur_t set_blur = (mbw_cgs_set_blur_t)dlsym(
      RTLD_DEFAULT, "CGSSetWindowBackgroundBlurRadius");
  if (main_connection == NULL || set_blur == NULL) {
    return 0;
  }

  int32_t result = set_blur(main_connection(), window_number, radius);
  return result == 0 ? 1 : 0;
}

typedef struct {
  NSCursor *cursor;
} MBWCustomCursorHandle;

struct MBWObjcOwnedObjectHandle {
  id object;
};

@interface MBWOwnedObjectReleaser : NSObject {
@public
  id object;
}
- (instancetype)initWithOwnedObject:(id)object;
- (void)mbwReleaseOwnedObject;
@end

@implementation MBWOwnedObjectReleaser

- (instancetype)initWithOwnedObject:(id)ownedObject {
  self = [super init];
  if (self != nil) {
    object = ownedObject;
  }
  return self;
}

- (void)mbwReleaseOwnedObject {
  [object release];
  object = nil;
  [self release];
}

@end

static void mbw_release_appkit_object_on_main(id object) {
  if (object == nil) {
    return;
  }
  if (pthread_main_np() != 0) {
    [object release];
  } else {
    MBWOwnedObjectReleaser *releaser =
        [[MBWOwnedObjectReleaser alloc] initWithOwnedObject:object];
    if (releaser == nil) {
      [object release];
      return;
    }
    [releaser performSelectorOnMainThread:@selector(mbwReleaseOwnedObject)
                               withObject:nil
                            waitUntilDone:NO];
  }
}

static void mbw_objc_owned_object_release_object(MBWObjcOwnedObjectHandle *handle) {
  if (handle == NULL || handle->object == nil) {
    return;
  }
  id object = handle->object;
  handle->object = nil;
  mbw_release_appkit_object_on_main(object);
}

static void mbw_objc_owned_object_finalize(void *ptr) {
  mbw_objc_owned_object_release_object((MBWObjcOwnedObjectHandle *)ptr);
}

MBWObjcOwnedObjectHandle *mbw_objc_owned_object_adopt(id object) {
  MBWObjcOwnedObjectHandle *handle =
      (MBWObjcOwnedObjectHandle *)moonbit_make_external_object(
          mbw_objc_owned_object_finalize, sizeof(MBWObjcOwnedObjectHandle));
  handle->object = object;
  return handle;
}

MOONBIT_FFI_EXPORT
MBWObjcOwnedObjectHandle *mbw_objc_wrap_owned_object(uint64_t object_handle) {
  return mbw_objc_owned_object_adopt((__bridge id)(void *)(uintptr_t)object_handle);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_objc_owned_object_handle(MBWObjcOwnedObjectHandle *handle) {
  if (handle == NULL || handle->object == nil) {
    return 0;
  }
  return (uint64_t)(void *)handle->object;
}

MOONBIT_FFI_EXPORT
void mbw_objc_owned_object_release(MBWObjcOwnedObjectHandle *handle) {
  mbw_objc_owned_object_release_object(handle);
}

static void mbw_custom_cursor_handle_finalize(void *ptr) {
  MBWCustomCursorHandle *handle = (MBWCustomCursorHandle *)ptr;
  if (handle == NULL || handle->cursor == nil) {
    return;
  }
  mbw_release_appkit_object_on_main(handle->cursor);
  handle->cursor = nil;
}

static MBWCustomCursorHandle *mbw_custom_cursor_handle_create(NSCursor *cursor) {
  MBWCustomCursorHandle *handle = (MBWCustomCursorHandle *)moonbit_make_external_object(
      mbw_custom_cursor_handle_finalize, sizeof(MBWCustomCursorHandle));
  handle->cursor = cursor;
  return handle;
}

enum {
  MBW_CUSTOM_CURSOR_MAX_DIMENSION = 2048,
  MBW_CUSTOM_CURSOR_BYTES_PER_PIXEL = 4,
};

static BOOL mbw_custom_cursor_rgba_layout_is_valid(
    int32_t rgba_len, int32_t width, int32_t height, int32_t hotspot_x,
    int32_t hotspot_y, size_t *expected_len, NSInteger *bytes_per_row) {
  if (rgba_len < 0 || width <= 0 || height <= 0 ||
      width > MBW_CUSTOM_CURSOR_MAX_DIMENSION ||
      height > MBW_CUSTOM_CURSOR_MAX_DIMENSION || hotspot_x < 0 ||
      hotspot_x >= width || hotspot_y < 0 || hotspot_y >= height) {
    return NO;
  }

  size_t width_size = (size_t)width;
  size_t height_size = (size_t)height;
  if (width_size > SIZE_MAX / MBW_CUSTOM_CURSOR_BYTES_PER_PIXEL) {
    return NO;
  }
  size_t row_size = width_size * MBW_CUSTOM_CURSOR_BYTES_PER_PIXEL;
  if (row_size > (size_t)INTPTR_MAX || height_size > SIZE_MAX / row_size) {
    return NO;
  }
  size_t total_size = row_size * height_size;
  if (total_size > INT32_MAX || (size_t)rgba_len != total_size) {
    return NO;
  }

  *expected_len = total_size;
  *bytes_per_row = (NSInteger)row_size;
  return YES;
}

MOONBIT_FFI_EXPORT
int32_t mbw_test_custom_cursor_rgba_layout_is_valid(
    int32_t rgba_len, int32_t width, int32_t height, int32_t hotspot_x,
    int32_t hotspot_y) {
  size_t expected_len = 0;
  NSInteger bytes_per_row = 0;
  return mbw_custom_cursor_rgba_layout_is_valid(
             rgba_len, width, height, hotspot_x, hotspot_y, &expected_len,
             &bytes_per_row)
             ? 1
             : 0;
}

MOONBIT_FFI_EXPORT
MBWCustomCursorHandle *mbw_custom_cursor_create_rgba(const uint8_t *rgba, int32_t rgba_len,
                                                    int32_t width, int32_t height,
                                                    int32_t hotspot_x, int32_t hotspot_y) {
  size_t expected_len = 0;
  NSInteger bytes_per_row = 0;
  if (rgba == NULL || !mbw_custom_cursor_rgba_layout_is_valid(
                          rgba_len, width, height, hotspot_x, hotspot_y,
                          &expected_len, &bytes_per_row)) {
    return mbw_custom_cursor_handle_create(nil);
  }

  NSBitmapImageRep *rep =
      [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                               pixelsWide:width
                                               pixelsHigh:height
                                            bitsPerSample:8
                                          samplesPerPixel:4
                                                 hasAlpha:YES
                                                 isPlanar:NO
                                           colorSpaceName:NSDeviceRGBColorSpace
                                             bitmapFormat:0
                                              bytesPerRow:bytes_per_row
                                             bitsPerPixel:32];
  if (rep == nil || [rep bitmapData] == NULL) {
    [rep release];
    return mbw_custom_cursor_handle_create(nil);
  }
  memcpy([rep bitmapData], rgba, expected_len);

  NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize((CGFloat)width, (CGFloat)height)];
  if (image == nil) {
    [rep release];
    return mbw_custom_cursor_handle_create(nil);
  }
  [image addRepresentation:rep];
  [rep release];

  NSCursor *cursor = [[NSCursor alloc]
      initWithImage:image
            hotSpot:NSMakePoint((CGFloat)hotspot_x, (CGFloat)hotspot_y)];
  [image release];
  if (cursor == nil) {
    return mbw_custom_cursor_handle_create(nil);
  }

  return mbw_custom_cursor_handle_create(cursor);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_custom_cursor_objc_handle(MBWCustomCursorHandle *cursor_handle) {
  if (cursor_handle == NULL || cursor_handle->cursor == nil) {
    return 0;
  }
  return (uint64_t)(void *)cursor_handle->cursor;
}

MOONBIT_FFI_EXPORT
int32_t mbw_cg_warp_mouse_cursor_position(double x, double y) {
  CGPoint point = CGPointMake((CGFloat)x, (CGFloat)y);
  CGError warp_err = CGWarpMouseCursorPosition(point);
  return (int32_t)warp_err;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_objc_get_class(const char *name) {
  if (name == NULL) {
    return 0;
  }
  return (uint64_t)(uintptr_t)objc_getClass(name);
}

MOONBIT_FFI_EXPORT
void mbw_objc_release(uint64_t object_handle) {
  if (object_handle == 0) {
    return;
  }
  id object = (__bridge id)(void *)(uintptr_t)object_handle;
  if (object == nil) {
    return;
  }
  mbw_release_appkit_object_on_main(object);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_objc_sel_register_name(const char *name) {
  if (name == NULL) {
    return 0;
  }
  SEL selector = sel_registerName(name);
  if (selector == NULL) {
    return 0;
  }
  return (uint64_t)(uintptr_t)sel_getName(selector);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_objc_msg_send_u64(uint64_t target_handle, uint64_t selector_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  uint64_t (*send_fn)(id, SEL) = (uint64_t(*)(id, SEL))objc_msgSend;
  return send_fn(target, selector);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_objc_msg_send_u64_bytes(uint64_t target_handle, uint64_t selector_handle,
                                     const char *arg0) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  uint64_t (*send_fn)(id, SEL, const char *) = (uint64_t(*)(id, SEL, const char *))objc_msgSend;
  return send_fn(target, selector, arg0 == NULL ? "" : arg0);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_objc_msg_send_u64_u64(uint64_t target_handle, uint64_t selector_handle,
                                   uint64_t arg0) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  uint64_t (*send_fn)(id, SEL, uint64_t) = (uint64_t(*)(id, SEL, uint64_t))objc_msgSend;
  return send_fn(target, selector, arg0);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_objc_msg_send_u64_u64_u64(uint64_t target_handle, uint64_t selector_handle,
                                       uint64_t arg0, uint64_t arg1) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  uint64_t (*send_fn)(id, SEL, uint64_t, uint64_t) =
      (uint64_t(*)(id, SEL, uint64_t, uint64_t))objc_msgSend;
  return send_fn(target, selector, arg0, arg1);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void(uint64_t target_handle, uint64_t selector_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  void (*send_fn)(id, SEL) = (void (*)(id, SEL))objc_msgSend;
  send_fn(target, selector);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_u64(uint64_t target_handle, uint64_t selector_handle, uint64_t arg0) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  void (*send_fn)(id, SEL, uint64_t) = (void (*)(id, SEL, uint64_t))objc_msgSend;
  send_fn(target, selector, arg0);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_i32(uint64_t target_handle, uint64_t selector_handle, int32_t arg0) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  void (*send_fn)(id, SEL, int32_t) = (void (*)(id, SEL, int32_t))objc_msgSend;
  send_fn(target, selector, arg0);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_rect_u64(uint64_t target_handle, uint64_t selector_handle, double x,
                                     double y, double width, double height, uint64_t arg1) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  NSRect arg0 = NSMakeRect((CGFloat)x, (CGFloat)y, (CGFloat)width, (CGFloat)height);
  id arg1_obj = (__bridge id)(void *)(uintptr_t)arg1;
  void (*send_fn)(id, SEL, NSRect, id) = (void (*)(id, SEL, NSRect, id))objc_msgSend;
  send_fn(target, selector, arg0, arg1_obj);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_rect_bool(uint64_t target_handle, uint64_t selector_handle, double x,
                                      double y, double width, double height, int32_t arg1) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  NSRect arg0 = NSMakeRect((CGFloat)x, (CGFloat)y, (CGFloat)width, (CGFloat)height);
  BOOL arg1_bool = arg1 ? YES : NO;
  void (*send_fn)(id, SEL, NSRect, BOOL) = (void (*)(id, SEL, NSRect, BOOL))objc_msgSend;
  send_fn(target, selector, arg0, arg1_bool);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_objc_msg_send_u64_i32_double_double_i32_u64_i32_i32_u64(
    uint64_t target_handle, uint64_t selector_handle, int32_t arg0, double arg1, double arg2,
    int32_t arg3, uint64_t arg4, int32_t arg5, int32_t arg6, uint64_t arg7) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  id arg4_obj = (__bridge id)(void *)(uintptr_t)arg4;
  id (*send_fn)(id, SEL, int32_t, double, double, int32_t, id, int32_t, int32_t, uint64_t) =
      (id (*)(id, SEL, int32_t, double, double, int32_t, id, int32_t, int32_t, uint64_t))objc_msgSend;
  id result = send_fn(target, selector, arg0, arg1, arg2, arg3, arg4_obj, arg5, arg6, arg7);
  if (result == nil) {
    return 0;
  }
  return (uint64_t)(uintptr_t)(__bridge void *)result;
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_size(uint64_t target_handle, uint64_t selector_handle, double width,
                                 double height) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  NSSize arg0 = NSMakeSize((CGFloat)width, (CGFloat)height);
  void (*send_fn)(id, SEL, NSSize) = (void (*)(id, SEL, NSSize))objc_msgSend;
  send_fn(target, selector, arg0);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_point(uint64_t target_handle, uint64_t selector_handle, double x,
                                  double y) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  NSPoint arg0 = NSMakePoint((CGFloat)x, (CGFloat)y);
  void (*send_fn)(id, SEL, NSPoint) = (void (*)(id, SEL, NSPoint))objc_msgSend;
  send_fn(target, selector, arg0);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_u64_u64(uint64_t target_handle, uint64_t selector_handle,
                                    uint64_t arg0, uint64_t arg1) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  void (*send_fn)(id, SEL, uint64_t, uint64_t) =
      (void (*)(id, SEL, uint64_t, uint64_t))objc_msgSend;
  send_fn(target, selector, arg0, arg1);
}

MOONBIT_FFI_EXPORT
void mbw_objc_msg_send_void_bool(uint64_t target_handle, uint64_t selector_handle, int32_t arg0) {
  if (target_handle == 0 || selector_handle == 0) {
    return;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  void (*send_fn)(id, SEL, BOOL) = (void (*)(id, SEL, BOOL))objc_msgSend;
  send_fn(target, selector, arg0 ? YES : NO);
}

MOONBIT_FFI_EXPORT
int32_t mbw_objc_msg_send_bool(uint64_t target_handle, uint64_t selector_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  BOOL (*send_fn)(id, SEL) = (BOOL(*)(id, SEL))objc_msgSend;
  return send_fn(target, selector) ? 1 : 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_objc_msg_send_bool_u64(uint64_t target_handle, uint64_t selector_handle,
                                   uint64_t arg0) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  BOOL (*send_fn)(id, SEL, uint64_t) = (BOOL(*)(id, SEL, uint64_t))objc_msgSend;
  return send_fn(target, selector, arg0) ? 1 : 0;
}

MOONBIT_FFI_EXPORT
int64_t mbw_objc_msg_send_i64(uint64_t target_handle, uint64_t selector_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  int64_t (*send_fn)(id, SEL) = (int64_t(*)(id, SEL))objc_msgSend;
  return send_fn(target, selector);
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_double(uint64_t target_handle, uint64_t selector_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0.0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  double (*send_fn)(id, SEL) = (double(*)(id, SEL))objc_msgSend;
  return send_fn(target, selector);
}

static BOOL mbw_objc_msg_send_value_no_args(uint64_t target_handle, uint64_t selector_handle,
                                            void *out_value, size_t out_size) {
  if (target_handle == 0 || selector_handle == 0 || out_value == NULL || out_size == 0) {
    return NO;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  if (target == nil) {
    return NO;
  }
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  if (selector == NULL) {
    return NO;
  }
  NSMethodSignature *signature = [target methodSignatureForSelector:selector];
  if (signature == nil || [signature numberOfArguments] != 2) {
    return NO;
  }
  NSUInteger return_length = [signature methodReturnLength];
  if (return_length == 0 || return_length > out_size) {
    return NO;
  }
  memset(out_value, 0, out_size);
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
  [invocation setTarget:target];
  [invocation setSelector:selector];
  [invocation invoke];
  [invocation getReturnValue:out_value];
  return YES;
}

static BOOL mbw_objc_msg_send_value_rect_arg(uint64_t target_handle, uint64_t selector_handle,
                                             NSRect arg0, void *out_value, size_t out_size) {
  if (target_handle == 0 || selector_handle == 0 || out_value == NULL || out_size == 0) {
    return NO;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  if (target == nil) {
    return NO;
  }
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  if (selector == NULL) {
    return NO;
  }
  NSMethodSignature *signature = [target methodSignatureForSelector:selector];
  if (signature == nil || [signature numberOfArguments] != 3) {
    return NO;
  }
  NSUInteger return_length = [signature methodReturnLength];
  if (return_length == 0 || return_length > out_size) {
    return NO;
  }
  memset(out_value, 0, out_size);
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
  [invocation setTarget:target];
  [invocation setSelector:selector];
  [invocation setArgument:&arg0 atIndex:2];
  [invocation invoke];
  [invocation getReturnValue:out_value];
  return YES;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_x(uint64_t target_handle, uint64_t selector_handle) {
  NSRect rect = NSZeroRect;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &rect, sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.origin.x;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_y(uint64_t target_handle, uint64_t selector_handle) {
  NSRect rect = NSZeroRect;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &rect, sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.origin.y;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_width(uint64_t target_handle, uint64_t selector_handle) {
  NSRect rect = NSZeroRect;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &rect, sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.size.width;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_height(uint64_t target_handle, uint64_t selector_handle) {
  NSRect rect = NSZeroRect;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &rect, sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.size.height;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_x_rect(uint64_t target_handle, uint64_t selector_handle, double x,
                                     double y, double width, double height) {
  NSRect rect = NSZeroRect;
  NSRect arg0 = NSMakeRect((CGFloat)x, (CGFloat)y, (CGFloat)width, (CGFloat)height);
  if (!mbw_objc_msg_send_value_rect_arg(target_handle, selector_handle, arg0, &rect,
                                        sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.origin.x;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_y_rect(uint64_t target_handle, uint64_t selector_handle, double x,
                                     double y, double width, double height) {
  NSRect rect = NSZeroRect;
  NSRect arg0 = NSMakeRect((CGFloat)x, (CGFloat)y, (CGFloat)width, (CGFloat)height);
  if (!mbw_objc_msg_send_value_rect_arg(target_handle, selector_handle, arg0, &rect,
                                        sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.origin.y;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_rect_height_rect(uint64_t target_handle, uint64_t selector_handle,
                                          double x, double y, double width, double height) {
  NSRect rect = NSZeroRect;
  NSRect arg0 = NSMakeRect((CGFloat)x, (CGFloat)y, (CGFloat)width, (CGFloat)height);
  if (!mbw_objc_msg_send_value_rect_arg(target_handle, selector_handle, arg0, &rect,
                                        sizeof(rect))) {
    return 0.0;
  }
  return (double)rect.size.height;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_size_width(uint64_t target_handle, uint64_t selector_handle) {
  NSSize size = NSZeroSize;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &size, sizeof(size))) {
    return 0.0;
  }
  return (double)size.width;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_size_height(uint64_t target_handle, uint64_t selector_handle) {
  NSSize size = NSZeroSize;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &size, sizeof(size))) {
    return 0.0;
  }
  return (double)size.height;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_point_x(uint64_t target_handle, uint64_t selector_handle) {
  NSPoint point = NSZeroPoint;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &point, sizeof(point))) {
    return 0.0;
  }
  return (double)point.x;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_point_y(uint64_t target_handle, uint64_t selector_handle) {
  NSPoint point = NSZeroPoint;
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &point, sizeof(point))) {
    return 0.0;
  }
  return (double)point.y;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_point_x_point_u64(uint64_t target_handle, uint64_t selector_handle,
                                           double x, double y, uint64_t arg1_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0.0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  NSPoint arg0 = NSMakePoint((CGFloat)x, (CGFloat)y);
  id arg1 = arg1_handle == 0 ? nil : (__bridge id)(void *)(uintptr_t)arg1_handle;
  NSPoint (*send_fn)(id, SEL, NSPoint, id) = (NSPoint(*)(id, SEL, NSPoint, id))objc_msgSend;
  NSPoint point = send_fn(target, selector, arg0, arg1);
  return (double)point.x;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_point_y_point_u64(uint64_t target_handle, uint64_t selector_handle,
                                           double x, double y, uint64_t arg1_handle) {
  if (target_handle == 0 || selector_handle == 0) {
    return 0.0;
  }
  id target = (__bridge id)(void *)(uintptr_t)target_handle;
  const char *selector_name = (const char *)(uintptr_t)selector_handle;
  SEL selector = sel_registerName(selector_name);
  NSPoint arg0 = NSMakePoint((CGFloat)x, (CGFloat)y);
  id arg1 = arg1_handle == 0 ? nil : (__bridge id)(void *)(uintptr_t)arg1_handle;
  NSPoint (*send_fn)(id, SEL, NSPoint, id) = (NSPoint(*)(id, SEL, NSPoint, id))objc_msgSend;
  NSPoint point = send_fn(target, selector, arg0, arg1);
  return (double)point.y;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_edge_insets_top(uint64_t target_handle, uint64_t selector_handle) {
  NSEdgeInsets insets = NSEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &insets,
                                       sizeof(insets))) {
    return 0.0;
  }
  return (double)insets.top;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_edge_insets_left(uint64_t target_handle, uint64_t selector_handle) {
  NSEdgeInsets insets = NSEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &insets,
                                       sizeof(insets))) {
    return 0.0;
  }
  return (double)insets.left;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_edge_insets_bottom(uint64_t target_handle, uint64_t selector_handle) {
  NSEdgeInsets insets = NSEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &insets,
                                       sizeof(insets))) {
    return 0.0;
  }
  return (double)insets.bottom;
}

MOONBIT_FFI_EXPORT
double mbw_objc_msg_send_edge_insets_right(uint64_t target_handle, uint64_t selector_handle) {
  NSEdgeInsets insets = NSEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
  if (!mbw_objc_msg_send_value_no_args(target_handle, selector_handle, &insets,
                                       sizeof(insets))) {
    return 0.0;
  }
  return (double)insets.right;
}
