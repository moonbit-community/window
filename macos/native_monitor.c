#include <CoreGraphics/CoreGraphics.h>
#include <CoreFoundation/CoreFoundation.h>
#include <stdint.h>
#include <stdlib.h>

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

uint64_t mbw_find_display_mode_handle(uint32_t display_id, int32_t width, int32_t height,
                                      int32_t bit_depth, int32_t refresh_rate_millihertz) {
  (void)bit_depth;
  if (display_id == 0 || width <= 0 || height <= 0) {
    return 0;
  }

  CFArrayRef modes =
      CGDisplayCopyAllDisplayModes((CGDirectDisplayID)display_id, NULL);
  if (modes == NULL) {
    return 0;
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
  return (uint64_t)(uintptr_t)matched;
}

uint64_t mbw_copy_current_display_mode_handle(uint32_t display_id) {
  if (display_id == 0) {
    return 0;
  }
  CGDisplayModeRef mode =
      CGDisplayCopyDisplayMode((CGDirectDisplayID)display_id);
  return (uint64_t)(uintptr_t)mode;
}

void mbw_release_display_mode_handle(uint64_t mode_handle) {
  if (mode_handle == 0) {
    return;
  }
  CGDisplayModeRef mode =
      (CGDisplayModeRef)(uintptr_t)mode_handle;
  CFRelease(mode);
}

int32_t mbw_capture_display(uint32_t display_id) {
  if (display_id == 0) {
    return 0;
  }
  CGError err = CGDisplayCapture((CGDirectDisplayID)display_id);
  return err == kCGErrorSuccess ? 1 : 0;
}

int32_t mbw_set_display_mode_handle(uint32_t display_id, uint64_t mode_handle) {
  if (display_id == 0 || mode_handle == 0) {
    return 0;
  }
  CGDisplayModeRef mode =
      (CGDisplayModeRef)(uintptr_t)mode_handle;
  CGError err = CGDisplaySetDisplayMode((CGDirectDisplayID)display_id, mode, NULL);
  return err == kCGErrorSuccess ? 1 : 0;
}

int32_t mbw_release_display_capture(uint32_t display_id) {
  if (display_id == 0) {
    return 0;
  }
  CGError err = CGDisplayRelease((CGDirectDisplayID)display_id);
  return err == kCGErrorSuccess ? 1 : 0;
}
