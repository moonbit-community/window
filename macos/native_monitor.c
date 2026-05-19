#include <CoreGraphics/CoreGraphics.h>
#include <CoreFoundation/CoreFoundation.h>
#include <ApplicationServices/ApplicationServices.h>
#include <moonbit.h>
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

int32_t mbw_cg_display_bounds_x(uint32_t display_id) {
  CGRect bounds = CGDisplayBounds((CGDirectDisplayID)display_id);
  return (int32_t)bounds.origin.x;
}

int32_t mbw_cg_display_bounds_y(uint32_t display_id) {
  CGRect bounds = CGDisplayBounds((CGDirectDisplayID)display_id);
  return (int32_t)bounds.origin.y;
}

double mbw_cg_display_bounds_height(uint32_t display_id) {
  CGRect bounds = CGDisplayBounds((CGDirectDisplayID)display_id);
  return (double)bounds.size.height;
}

double mbw_cg_display_scale_factor(uint32_t display_id) {
  CGRect bounds = CGDisplayBounds((CGDirectDisplayID)display_id);
  double width = bounds.size.width;
  if (width <= 0.0) {
    return 1.0;
  }
  size_t pixel_width = CGDisplayPixelsWide((CGDirectDisplayID)display_id);
  if (pixel_width == 0) {
    return 1.0;
  }
  return ((double)pixel_width) / width;
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

MBWDisplayModeHandle *mbw_copy_current_display_mode_handle(uint32_t display_id) {
  if (display_id == 0) {
    return mbw_display_mode_handle_create(NULL);
  }
  CGDisplayModeRef mode =
      CGDisplayCopyDisplayMode((CGDirectDisplayID)display_id);
  return mbw_display_mode_handle_create(mode);
}

int32_t mbw_copy_display_mode_count(uint32_t display_id) {
  if (display_id == 0) {
    return 0;
  }
  CFArrayRef modes = CGDisplayCopyAllDisplayModes((CGDirectDisplayID)display_id, NULL);
  if (modes == NULL) {
    return 0;
  }
  CFIndex count = CFArrayGetCount(modes);
  CFRelease(modes);
  if (count <= 0) {
    return 0;
  }
  if (count > INT32_MAX) {
    return INT32_MAX;
  }
  return (int32_t)count;
}

MBWDisplayModeHandle *mbw_copy_display_mode_handle_at(uint32_t display_id, int32_t index) {
  if (display_id == 0 || index < 0) {
    return mbw_display_mode_handle_create(NULL);
  }
  CFArrayRef modes = CGDisplayCopyAllDisplayModes((CGDirectDisplayID)display_id, NULL);
  if (modes == NULL) {
    return mbw_display_mode_handle_create(NULL);
  }
  CFIndex count = CFArrayGetCount(modes);
  if ((CFIndex)index >= count) {
    CFRelease(modes);
    return mbw_display_mode_handle_create(NULL);
  }
  CGDisplayModeRef mode = (CGDisplayModeRef)CFArrayGetValueAtIndex(modes, (CFIndex)index);
  if (mode != NULL) {
    CFRetain(mode);
  }
  CFRelease(modes);
  return mbw_display_mode_handle_create(mode);
}

uint64_t mbw_display_mode_identity(MBWDisplayModeHandle *mode_handle) {
  if (mode_handle == NULL || mode_handle->mode == NULL) {
    return 0;
  }
  return (uint64_t)(uintptr_t)mode_handle->mode;
}

int32_t mbw_display_mode_is_valid(MBWDisplayModeHandle *mode_handle) {
  return mode_handle != NULL && mode_handle->mode != NULL ? 1 : 0;
}

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

int32_t mbw_display_mode_bit_depth(MBWDisplayModeHandle *mode_handle) {
  if (mode_handle == NULL || mode_handle->mode == NULL) {
    return 0;
  }
  return mbw_display_mode_bit_depth_ref(mode_handle->mode);
}

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

void mbw_release_display_mode_handle(MBWDisplayModeHandle *mode_handle) {
  mbw_display_mode_handle_release_mode(mode_handle);
}

int32_t mbw_capture_display(uint32_t display_id) {
  if (display_id == 0) {
    return 0;
  }
  CGError err = CGDisplayCapture((CGDirectDisplayID)display_id);
  return err == kCGErrorSuccess ? 1 : 0;
}

int32_t mbw_set_display_mode_handle(uint32_t display_id, MBWDisplayModeHandle *mode_handle) {
  if (display_id == 0 || mode_handle == NULL || mode_handle->mode == NULL) {
    return 0;
  }
  CGError err = CGDisplaySetDisplayMode((CGDirectDisplayID)display_id, mode_handle->mode, NULL);
  return err == kCGErrorSuccess ? 1 : 0;
}

int32_t mbw_release_display_capture(uint32_t display_id) {
  if (display_id == 0) {
    return 0;
  }
  CGError err = CGDisplayRelease((CGDirectDisplayID)display_id);
  return err == kCGErrorSuccess ? 1 : 0;
}
