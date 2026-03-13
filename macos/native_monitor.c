#include <CoreGraphics/CoreGraphics.h>
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
