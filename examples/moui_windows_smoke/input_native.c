#include <moonbit.h>
#include <stdint.h>

#ifdef _WIN32
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <windows.h>

static LPARAM mbw_moui_windows_smoke_point_lparam(int32_t x, int32_t y) {
  return (LPARAM)(((uint32_t)y << 16) | ((uint32_t)x & 0xFFFFu));
}

MOONBIT_FFI_EXPORT
int32_t mbw_moui_windows_smoke_send_input(uint64_t raw_hwnd) {
  HWND hwnd = (HWND)(uintptr_t)raw_hwnd;
  if (!IsWindow(hwnd)) {
    return 0;
  }

  ShowWindow(hwnd, SW_SHOWNORMAL);
  SetForegroundWindow(hwnd);
  SetFocus(hwnd);
  SetWindowPos(hwnd, NULL, 0, 0, 400, 240,
               SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE);

  LPARAM point = mbw_moui_windows_smoke_point_lparam(48, 64);
  PostMessageW(hwnd, WM_SIZE, SIZE_RESTORED, MAKELPARAM(400, 240));
  PostMessageW(hwnd, WM_MOUSEMOVE, 0, point);
  PostMessageW(hwnd, WM_LBUTTONDOWN, MK_LBUTTON, point);
  PostMessageW(hwnd, WM_LBUTTONUP, 0, point);
  PostMessageW(hwnd, WM_KEYDOWN, (WPARAM)'A', (LPARAM)0x001E0001);
  PostMessageW(hwnd, WM_KEYUP, (WPARAM)'A', (LPARAM)0xC01E0001);
  InvalidateRect(hwnd, NULL, FALSE);
  return 1;
}
#else
MOONBIT_FFI_EXPORT
int32_t mbw_moui_windows_smoke_send_input(uint64_t raw_hwnd) {
  (void)raw_hwnd;
  return 0;
}
#endif
