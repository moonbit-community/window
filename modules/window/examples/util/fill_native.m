#import <AppKit/AppKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <moonbit.h>
#import <stdint.h>

static inline NSColor *mbw_examples_color_from_argb(uint64_t color) {
  double a = ((double)((color >> 24) & 0xFF)) / 255.0;
  double r = ((double)((color >> 16) & 0xFF)) / 255.0;
  double g = ((double)((color >> 8) & 0xFF)) / 255.0;
  double b = ((double)(color & 0xFF)) / 255.0;
  return [NSColor colorWithSRGBRed:r green:g blue:b alpha:a];
}

static NSString *const MBW_EXAMPLES_SAFE_AREA_IDENTIFIER = @"mbw_examples_safe_area";

static inline NSView *mbw_examples_find_safe_area_view(NSView *view) {
  for (NSView *subview in view.subviews) {
    if ([subview.identifier isEqualToString:MBW_EXAMPLES_SAFE_AREA_IDENTIFIER]) {
      return subview;
    }
  }
  return nil;
}

MOONBIT_FFI_EXPORT
void mbw_examples_fill_window_with_color(uint64_t raw_view_handle, uint64_t color) {
  if (raw_view_handle == 0) {
    return;
  }
  NSView *view = (__bridge NSView *)(void *)raw_view_handle;
  if (view == nil) {
    return;
  }

  view.wantsLayer = YES;
  NSColor *ns_color = mbw_examples_color_from_argb(color);
  view.layer.backgroundColor = ns_color.CGColor;
  NSView *safe_area_view = mbw_examples_find_safe_area_view(view);
  if (safe_area_view != nil) {
    [safe_area_view removeFromSuperview];
  }
  [view setNeedsDisplay:YES];
}

MOONBIT_FFI_EXPORT
void mbw_examples_fill_window_with_safe_area(uint64_t raw_view_handle, uint64_t inner_color,
                                             uint64_t outer_color, int32_t left, int32_t top,
                                             int32_t right, int32_t bottom, int32_t width,
                                             int32_t height, double scale_factor) {
  if (raw_view_handle == 0) {
    return;
  }
  NSView *view = (__bridge NSView *)(void *)raw_view_handle;
  if (view == nil) {
    return;
  }

  view.wantsLayer = YES;
  if (view.layer == nil) {
    return;
  }

  view.layer.backgroundColor = mbw_examples_color_from_argb(outer_color).CGColor;

  NSView *safe_area_view = mbw_examples_find_safe_area_view(view);
  if (safe_area_view == nil) {
    safe_area_view = [[NSView alloc] initWithFrame:NSZeroRect];
    safe_area_view.identifier = MBW_EXAMPLES_SAFE_AREA_IDENTIFIER;
    safe_area_view.wantsLayer = YES;
    [view addSubview:safe_area_view];
  } else {
    safe_area_view.wantsLayer = YES;
  }

  double scale = scale_factor > 0.0 ? scale_factor : 1.0;
  double x = ((double)left) / scale;
  double y = view.isFlipped ? ((double)top) / scale : ((double)bottom) / scale;
  double w = ((double)(width - left - right)) / scale;
  double h = ((double)(height - top - bottom)) / scale;
  if (w < 0.0) {
    w = 0.0;
  }
  if (h < 0.0) {
    h = 0.0;
  }

  safe_area_view.layer.backgroundColor = mbw_examples_color_from_argb(inner_color).CGColor;
  safe_area_view.frame = NSMakeRect(x, y, w, h);

  [view setNeedsDisplay:YES];
}

MOONBIT_FFI_EXPORT
int64_t mbw_examples_now_millis(void) {
  return (int64_t)(CFAbsoluteTimeGetCurrent() * 1000.0);
}
