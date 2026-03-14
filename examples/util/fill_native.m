#import <AppKit/AppKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <moonbit.h>
#import <stdint.h>

MOONBIT_FFI_EXPORT
void mbw_examples_fill_window_with_color(uint64_t raw_view_handle, uint64_t color) {
  if (raw_view_handle == 0) {
    return;
  }
  NSView *view = (__bridge NSView *)(void *)raw_view_handle;
  if (view == nil) {
    return;
  }

  double a = ((double)((color >> 24) & 0xFF)) / 255.0;
  double r = ((double)((color >> 16) & 0xFF)) / 255.0;
  double g = ((double)((color >> 8) & 0xFF)) / 255.0;
  double b = ((double)(color & 0xFF)) / 255.0;

  view.wantsLayer = YES;
  NSColor *ns_color = [NSColor colorWithSRGBRed:r green:g blue:b alpha:a];
  view.layer.backgroundColor = ns_color.CGColor;
  [view setNeedsDisplay:YES];
}

MOONBIT_FFI_EXPORT
int64_t mbw_examples_now_millis(void) {
  return (int64_t)(CFAbsoluteTimeGetCurrent() * 1000.0);
}
