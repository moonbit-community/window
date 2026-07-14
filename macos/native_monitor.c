#include <CoreGraphics/CoreGraphics.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreVideo/CoreVideo.h>
#include <ApplicationServices/ApplicationServices.h>
#include <moonbit.h>
#include <pthread.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct {
  CFTypeRef object;
} MBWCfObjectHandle;

static void mbw_cf_object_handle_release_object(MBWCfObjectHandle *handle) {
  if (handle == NULL || handle->object == NULL) {
    return;
  }
  CFRelease(handle->object);
  handle->object = NULL;
}

static void mbw_cf_object_handle_finalize(void *ptr) {
  mbw_cf_object_handle_release_object((MBWCfObjectHandle *)ptr);
}

static MBWCfObjectHandle *mbw_cf_object_handle_create(CFTypeRef object) {
  MBWCfObjectHandle *handle = (MBWCfObjectHandle *)moonbit_make_external_object(
      mbw_cf_object_handle_finalize, sizeof(MBWCfObjectHandle));
  handle->object = object;
  return handle;
}

MOONBIT_FFI_EXPORT
MBWCfObjectHandle *mbw_cg_display_create_uuid_from_display_id(uint32_t display_id) {
  CFUUIDRef uuid = CGDisplayCreateUUIDFromDisplayID((CGDirectDisplayID)display_id);
  return mbw_cf_object_handle_create(uuid);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_cf_object_handle(MBWCfObjectHandle *handle) {
  if (handle == NULL || handle->object == NULL) {
    return 0;
  }
  return (uint64_t)(uintptr_t)handle->object;
}

MOONBIT_FFI_EXPORT
void mbw_cf_object_release(MBWCfObjectHandle *handle) {
  mbw_cf_object_handle_release_object(handle);
}

static uint64_t mbw_cf_uuid_half(MBWCfObjectHandle *handle, int32_t offset) {
  if (handle == NULL || handle->object == NULL ||
      CFGetTypeID(handle->object) != CFUUIDGetTypeID()) {
    return 0;
  }
  CFUUIDBytes bytes = CFUUIDGetUUIDBytes((CFUUIDRef)handle->object);
  const uint8_t values[16] = {
      bytes.byte0,  bytes.byte1,  bytes.byte2,  bytes.byte3,
      bytes.byte4,  bytes.byte5,  bytes.byte6,  bytes.byte7,
      bytes.byte8,  bytes.byte9,  bytes.byte10, bytes.byte11,
      bytes.byte12, bytes.byte13, bytes.byte14, bytes.byte15,
  };
  uint64_t value = 0;
  for (int32_t index = offset; index < offset + 8; index++) {
    value = (value << 8) | values[index];
  }
  return value;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_cf_uuid_high(MBWCfObjectHandle *handle) {
  return mbw_cf_uuid_half(handle, 0);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_cf_uuid_low(MBWCfObjectHandle *handle) {
  return mbw_cf_uuid_half(handle, 8);
}

MOONBIT_FFI_EXPORT
int32_t mbw_cg_active_display_count(void) {
  uint32_t count = 0;
  CGError err = CGGetActiveDisplayList(0, NULL, &count);
  if (err != kCGErrorSuccess) {
    return 0;
  }
  if (count > INT32_MAX) {
    return INT32_MAX;
  }
  return (int32_t)count;
}

MOONBIT_FFI_EXPORT
uint32_t mbw_cg_active_display_id_at(int32_t index) {
  if (index < 0) {
    return 0;
  }
  uint32_t count = 0;
  CGError err = CGGetActiveDisplayList(0, NULL, &count);
  if (err != kCGErrorSuccess || (uint32_t)index >= count || count == 0) {
    return 0;
  }

  CGDirectDisplayID *displays =
      (CGDirectDisplayID *)malloc(sizeof(CGDirectDisplayID) * count);
  if (displays == NULL) {
    return 0;
  }

  uint32_t actual = 0;
  err = CGGetActiveDisplayList(count, displays, &actual);
  uint32_t display_id = 0;
  if (err == kCGErrorSuccess && (uint32_t)index < actual) {
    display_id = (uint32_t)displays[index];
  }

  free(displays);
  return display_id;
}

MOONBIT_FFI_EXPORT
int32_t mbw_cg_display_bounds_x(uint32_t display_id) {
  CGRect bounds = CGDisplayBounds((CGDirectDisplayID)display_id);
  return (int32_t)bounds.origin.x;
}

MOONBIT_FFI_EXPORT
int32_t mbw_cg_display_bounds_y(uint32_t display_id) {
  CGRect bounds = CGDisplayBounds((CGDirectDisplayID)display_id);
  return (int32_t)bounds.origin.y;
}

MOONBIT_FFI_EXPORT
double mbw_cg_display_bounds_height(uint32_t display_id) {
  CGRect bounds = CGDisplayBounds((CGDirectDisplayID)display_id);
  return (double)bounds.size.height;
}

static int32_t mbw_display_mode_bit_depth_ref(CGDisplayModeRef mode) {
  // `CGDisplayModeCopyPixelEncoding` is deprecated and no direct replacement is
  // provided for per-mode bit-depth queries. In practice, modern macOS display
  // modes are effectively 32-bit.
  (void)mode;
  return 32;
}

typedef struct {
  CGDisplayModeRef mode;
} MBWDisplayModeHandle;

typedef struct {
  CFArrayRef modes;
} MBWDisplayModeListHandle;

static void mbw_display_mode_handle_release_mode(MBWDisplayModeHandle *handle) {
  if (handle == NULL || handle->mode == NULL) {
    return;
  }
  CGDisplayModeRelease(handle->mode);
  handle->mode = NULL;
}

static void mbw_display_mode_handle_finalize(void *ptr) {
  mbw_display_mode_handle_release_mode((MBWDisplayModeHandle *)ptr);
}

static MBWDisplayModeHandle *mbw_display_mode_handle_create(CGDisplayModeRef mode) {
  MBWDisplayModeHandle *handle = (MBWDisplayModeHandle *)moonbit_make_external_object(
      mbw_display_mode_handle_finalize, sizeof(MBWDisplayModeHandle));
  handle->mode = mode;
  return handle;
}

static void mbw_display_mode_list_release_modes(MBWDisplayModeListHandle *handle) {
  if (handle == NULL || handle->modes == NULL) {
    return;
  }
  CFRelease(handle->modes);
  handle->modes = NULL;
}

static void mbw_display_mode_list_finalize(void *ptr) {
  mbw_display_mode_list_release_modes((MBWDisplayModeListHandle *)ptr);
}

static MBWDisplayModeListHandle *mbw_display_mode_list_create(CFArrayRef modes) {
  MBWDisplayModeListHandle *handle =
      (MBWDisplayModeListHandle *)moonbit_make_external_object(
          mbw_display_mode_list_finalize, sizeof(MBWDisplayModeListHandle));
  handle->modes = modes;
  return handle;
}

MOONBIT_FFI_EXPORT
MBWDisplayModeHandle *mbw_find_display_mode_handle(uint32_t display_id, int32_t width,
                                                   int32_t height, int32_t bit_depth,
                                                   int32_t refresh_rate_millihertz) {
  if (display_id == 0 || width <= 0 || height <= 0) {
    return mbw_display_mode_handle_create(NULL);
  }

  CFArrayRef modes =
      CGDisplayCopyAllDisplayModes((CGDirectDisplayID)display_id, NULL);
  if (modes == NULL) {
    return mbw_display_mode_handle_create(NULL);
  }

  double target_refresh =
      refresh_rate_millihertz > 0 ? ((double)refresh_rate_millihertz) / 1000.0 : 0.0;
  CFIndex count = CFArrayGetCount(modes);
  CGDisplayModeRef matched = NULL;
  for (CFIndex i = 0; i < count; i++) {
    CGDisplayModeRef mode =
        (CGDisplayModeRef)CFArrayGetValueAtIndex(modes, i);
    if (mode == NULL) {
      continue;
    }
    size_t mode_width = CGDisplayModeGetPixelWidth(mode);
    size_t mode_height = CGDisplayModeGetPixelHeight(mode);
    if ((int32_t)mode_width != width || (int32_t)mode_height != height) {
      continue;
    }
    if (bit_depth > 0 && bit_depth == 32) {
      int32_t mode_bit_depth = mbw_display_mode_bit_depth_ref(mode);
      if (mode_bit_depth > 0 && mode_bit_depth != bit_depth) {
        continue;
      }
    }
    if (refresh_rate_millihertz > 0) {
      double hz = CGDisplayModeGetRefreshRate(mode);
      if (hz > 0.0) {
        double delta = hz - target_refresh;
        if (delta < 0.0) {
          delta = -delta;
        }
        if (delta > 0.5) {
          continue;
        }
      }
    }
    matched = mode;
    CFRetain(matched);
    break;
  }

  CFRelease(modes);
  return mbw_display_mode_handle_create(matched);
}

MOONBIT_FFI_EXPORT
MBWDisplayModeHandle *mbw_copy_current_display_mode_handle(uint32_t display_id) {
  if (display_id == 0) {
    return mbw_display_mode_handle_create(NULL);
  }
  CGDisplayModeRef mode =
      CGDisplayCopyDisplayMode((CGDirectDisplayID)display_id);
  return mbw_display_mode_handle_create(mode);
}

MOONBIT_FFI_EXPORT
MBWDisplayModeListHandle *mbw_copy_display_mode_list(uint32_t display_id) {
  CFArrayRef modes = NULL;
  if (display_id != 0) {
    modes = CGDisplayCopyAllDisplayModes((CGDirectDisplayID)display_id, NULL);
  }
  return mbw_display_mode_list_create(modes);
}

MOONBIT_FFI_EXPORT
int32_t mbw_display_mode_list_count(MBWDisplayModeListHandle *handle) {
  if (handle == NULL || handle->modes == NULL) {
    return 0;
  }
  CFIndex count = CFArrayGetCount(handle->modes);
  if (count <= 0) {
    return 0;
  }
  if (count > INT32_MAX) {
    return INT32_MAX;
  }
  return (int32_t)count;
}

MOONBIT_FFI_EXPORT
MBWDisplayModeHandle *mbw_display_mode_list_mode_at(
    MBWDisplayModeListHandle *handle, int32_t index) {
  if (handle == NULL || handle->modes == NULL || index < 0) {
    return mbw_display_mode_handle_create(NULL);
  }
  CFIndex count = CFArrayGetCount(handle->modes);
  if ((CFIndex)index >= count) {
    return mbw_display_mode_handle_create(NULL);
  }
  CGDisplayModeRef mode =
      (CGDisplayModeRef)CFArrayGetValueAtIndex(handle->modes, (CFIndex)index);
  if (mode != NULL) {
    CFRetain(mode);
  }
  return mbw_display_mode_handle_create(mode);
}

MOONBIT_FFI_EXPORT
void mbw_release_display_mode_list(MBWDisplayModeListHandle *handle) {
  mbw_display_mode_list_release_modes(handle);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_display_mode_identity(MBWDisplayModeHandle *mode_handle) {
  if (mode_handle == NULL || mode_handle->mode == NULL) {
    return 0;
  }
  return (uint64_t)(uintptr_t)mode_handle->mode;
}

MOONBIT_FFI_EXPORT
int32_t mbw_display_mode_is_valid(MBWDisplayModeHandle *mode_handle) {
  return mode_handle != NULL && mode_handle->mode != NULL ? 1 : 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_display_mode_width(MBWDisplayModeHandle *mode_handle) {
  if (mode_handle == NULL || mode_handle->mode == NULL) {
    return 0;
  }
  size_t width = CGDisplayModeGetPixelWidth(mode_handle->mode);
  if (width > INT32_MAX) {
    return INT32_MAX;
  }
  return (int32_t)width;
}

MOONBIT_FFI_EXPORT
int32_t mbw_display_mode_height(MBWDisplayModeHandle *mode_handle) {
  if (mode_handle == NULL || mode_handle->mode == NULL) {
    return 0;
  }
  size_t height = CGDisplayModeGetPixelHeight(mode_handle->mode);
  if (height > INT32_MAX) {
    return INT32_MAX;
  }
  return (int32_t)height;
}

MOONBIT_FFI_EXPORT
int32_t mbw_display_mode_bit_depth(MBWDisplayModeHandle *mode_handle) {
  if (mode_handle == NULL || mode_handle->mode == NULL) {
    return 0;
  }
  return mbw_display_mode_bit_depth_ref(mode_handle->mode);
}

MOONBIT_FFI_EXPORT
int32_t mbw_display_mode_refresh_rate_millihertz(MBWDisplayModeHandle *mode_handle) {
  if (mode_handle == NULL || mode_handle->mode == NULL) {
    return 0;
  }
  double hz = CGDisplayModeGetRefreshRate(mode_handle->mode);
  if (hz <= 0.0) {
    return 0;
  }
  double millihertz = hz * 1000.0;
  if (millihertz > (double)INT32_MAX) {
    return INT32_MAX;
  }
  return (int32_t)(millihertz + 0.5);
}

static int32_t mbw_refresh_rate_millihertz_from_cvtime(int32_t time_scale,
                                                       int64_t time_value) {
  if (time_scale <= 0 || time_value <= 0) {
    return 0;
  }
  int64_t numerator = (int64_t)time_scale * 1000;
  int64_t millihertz = numerator / time_value;
  int64_t remainder = numerator % time_value;
  int64_t rounding_threshold = time_value / 2 + time_value % 2;
  if (remainder >= rounding_threshold) {
    millihertz += 1;
  }
  if (millihertz <= 0) {
    return 0;
  }
  if (millihertz > INT32_MAX) {
    return INT32_MAX;
  }
  return (int32_t)millihertz;
}

MOONBIT_FFI_EXPORT
int32_t mbw_test_refresh_rate_millihertz_from_cvtime(int32_t time_scale,
                                                      int32_t time_value) {
  return mbw_refresh_rate_millihertz_from_cvtime(time_scale, time_value);
}

MOONBIT_FFI_EXPORT
int32_t mbw_display_refresh_rate_millihertz(uint32_t display_id) {
  if (display_id == 0) {
    return 0;
  }

  CVDisplayLinkRef display_link = NULL;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  CVReturn result =
      CVDisplayLinkCreateWithCGDisplay((CGDirectDisplayID)display_id, &display_link);
  if (result != kCVReturnSuccess || display_link == NULL) {
    return 0;
  }

  CVTime time = CVDisplayLinkGetNominalOutputVideoRefreshPeriod(display_link);
  CVDisplayLinkRelease(display_link);
#pragma clang diagnostic pop

  if ((time.flags & kCVTimeIsIndefinite) != 0 || time.timeScale <= 0 || time.timeValue <= 0) {
    return 0;
  }

  return mbw_refresh_rate_millihertz_from_cvtime(time.timeScale, time.timeValue);
}

typedef struct {
  uint32_t display_id;
  int32_t completed;
  int32_t ran_off_main_thread;
} MBWDisplayRefreshRateThreadProbe;

// White-box test hook; MoonBit callbacks must not run on a foreign thread.
static void *mbw_probe_display_refresh_rate_off_main(void *raw_probe) {
  MBWDisplayRefreshRateThreadProbe *probe = (MBWDisplayRefreshRateThreadProbe *)raw_probe;
  probe->ran_off_main_thread = pthread_main_np() == 0;
  (void)mbw_display_refresh_rate_millihertz(probe->display_id);
  probe->completed = 1;
  return NULL;
}

MOONBIT_FFI_EXPORT
int32_t mbw_test_display_refresh_rate_off_main(uint32_t display_id) {
  MBWDisplayRefreshRateThreadProbe probe = {
      .display_id = display_id,
      .completed = 0,
      .ran_off_main_thread = 0,
  };
  pthread_t thread;
  if (pthread_create(&thread, NULL, mbw_probe_display_refresh_rate_off_main, &probe) != 0) {
    return 0;
  }
  if (pthread_join(thread, NULL) != 0) {
    return 0;
  }
  return probe.completed && probe.ran_off_main_thread;
}

MOONBIT_FFI_EXPORT
void mbw_release_display_mode_handle(MBWDisplayModeHandle *mode_handle) {
  mbw_display_mode_handle_release_mode(mode_handle);
}

MOONBIT_FFI_EXPORT
int32_t mbw_capture_display(uint32_t display_id) {
  if (display_id == 0) {
    return 0;
  }
  CGError err = CGDisplayCapture((CGDirectDisplayID)display_id);
  return err == kCGErrorSuccess ? 1 : 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_set_display_mode_handle(uint32_t display_id, MBWDisplayModeHandle *mode_handle) {
  if (display_id == 0 || mode_handle == NULL || mode_handle->mode == NULL) {
    return 0;
  }
  CGError err = CGDisplaySetDisplayMode((CGDirectDisplayID)display_id, mode_handle->mode, NULL);
  return err == kCGErrorSuccess ? 1 : 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_release_display_capture(uint32_t display_id) {
  if (display_id == 0) {
    return 0;
  }
  CGError err = CGDisplayRelease((CGDirectDisplayID)display_id);
  return err == kCGErrorSuccess ? 1 : 0;
}
