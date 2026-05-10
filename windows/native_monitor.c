#ifndef _WIN32
#error "native_monitor.c is only for Windows"
#endif

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <moonbit.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>

typedef struct {
  HMONITOR handle;
  RECT rect;
  RECT work_rect;
  wchar_t name[128];
  double scale_factor;
} MBWMonitorInfo;

static MBWMonitorInfo *g_monitors = NULL;
static int32_t g_monitor_count = 0;

typedef struct {
  uint32_t width;
  uint32_t height;
  uint32_t bit_depth;
  uint32_t refresh_rate;
} MBWVideoMode;

static BOOL CALLBACK mbw_enum_monitors_callback(HMONITOR hmonitor, HDC hdc,
                                                LPRECT rect,
                                                LPARAM lparam) {
  MONITORINFOEXW info = {0};
  info.cbSize = sizeof(MONITORINFOEXW);
  if (!GetMonitorInfoW(hmonitor, (LPMONITORINFO)&info)) {
    return TRUE;
  }

  MBWMonitorInfo *new_monitors = (MBWMonitorInfo *)realloc(
      g_monitors, (g_monitor_count + 1) * sizeof(MBWMonitorInfo));
  if (!new_monitors) {
    return FALSE;
  }
  g_monitors = new_monitors;

  MBWMonitorInfo *mi = &g_monitors[g_monitor_count];
  mi->handle = hmonitor;
  mi->rect = info.rcMonitor;
  mi->work_rect = info.rcWork;
  wcscpy(mi->name, info.szDevice);
  mi->name[127] = 0;

  typedef HRESULT(WINAPI * GetDpiForMonitor_t)(HMONITOR, UINT, UINT *, UINT *);
  HMODULE shcore = LoadLibraryW(L"shcore.dll");
  if (shcore) {
    GetDpiForMonitor_t fn = (GetDpiForMonitor_t)GetProcAddress(
        shcore, "GetDpiForMonitor");
    if (fn) {
      UINT dpi_x, dpi_y;
      fn(hmonitor, 2, &dpi_x, &dpi_y);
      mi->scale_factor = (double)dpi_x / 96.0;
    } else {
      mi->scale_factor = 1.0;
    }
    FreeLibrary(shcore);
  } else {
    mi->scale_factor = (double)rect->right / (double)info.rcWork.right;
    if (mi->scale_factor < 1.0) mi->scale_factor = 1.0;
  }

  g_monitor_count++;
  return TRUE;
}

MOONBIT_FFI_EXPORT
int32_t mbw_enum_monitors(void) {
  if (g_monitors) {
    free(g_monitors);
    g_monitors = NULL;
  }
  g_monitor_count = 0;
  EnumDisplayMonitors(NULL, NULL, mbw_enum_monitors_callback, 0);
  return g_monitor_count;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_monitor_handle_at(int32_t index) {
  if (index < 0 || index >= g_monitor_count) return 0;
  return (uint64_t)g_monitors[index].handle;
}

MOONBIT_FFI_EXPORT
int32_t mbw_monitor_rect_left_at(int32_t index) {
  if (index < 0 || index >= g_monitor_count) return 0;
  return g_monitors[index].rect.left;
}

MOONBIT_FFI_EXPORT
int32_t mbw_monitor_rect_top_at(int32_t index) {
  if (index < 0 || index >= g_monitor_count) return 0;
  return g_monitors[index].rect.top;
}

MOONBIT_FFI_EXPORT
int32_t mbw_monitor_rect_width_at(int32_t index) {
  if (index < 0 || index >= g_monitor_count) return 0;
  return g_monitors[index].rect.right - g_monitors[index].rect.left;
}

MOONBIT_FFI_EXPORT
int32_t mbw_monitor_rect_height_at(int32_t index) {
  if (index < 0 || index >= g_monitor_count) return 0;
  return g_monitors[index].rect.bottom - g_monitors[index].rect.top;
}

MOONBIT_FFI_EXPORT
double mbw_monitor_scale_factor_at(int32_t index) {
  if (index < 0 || index >= g_monitor_count) return 1.0;
  return g_monitors[index].scale_factor;
}

MOONBIT_FFI_EXPORT
int32_t mbw_monitor_name_len_at(int32_t index) {
  if (index < 0 || index >= g_monitor_count) return 0;
  return (int32_t)wcslen(g_monitors[index].name);
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t mbw_monitor_name_bytes_at(int32_t index) {
  if (index < 0 || index >= g_monitor_count) {
    return moonbit_make_bytes(0, 0);
  }
  int32_t name_len = (int32_t)wcslen(g_monitors[index].name);
  int32_t utf8_len = WideCharToMultiByte(CP_UTF8, 0,
                                          g_monitors[index].name, name_len,
                                          NULL, 0, NULL, NULL);
  moonbit_bytes_t bytes = moonbit_make_bytes(utf8_len, 0);
  WideCharToMultiByte(CP_UTF8, 0, g_monitors[index].name, name_len,
                      (LPSTR)bytes, utf8_len, NULL, NULL);
  return bytes;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_primary_monitor_handle(void) {
  HMONITOR primary = MonitorFromPoint((POINT){0, 0}, MONITOR_DEFAULTTOPRIMARY);
  return (uint64_t)primary;
}

MOONBIT_FFI_EXPORT
int32_t mbw_enum_display_modes(uint64_t hmonitor) {
  return 0;
}