#ifndef _WIN32
#error "native_window.c is only for Windows"
#endif

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <moonbit.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <shellscalingapi.h>

typedef void (*mbw_window_event_trampoline_t)(void *closure, int32_t kind,
                                              int32_t raw_id, int32_t arg0,
                                              int32_t arg1, int32_t arg2,
                                              double argd);
typedef void (*mbw_input_event_trampoline_t)(void *closure, int32_t raw_id,
                                             int32_t kind, uint64_t wparam,
                                             int64_t lparam);
typedef int32_t (*mbw_sync_query_trampoline_t)(void *closure, int32_t raw_id,
                                               int32_t kind, int32_t arg0);

static mbw_window_event_trampoline_t g_window_event_trampoline = NULL;
static void *g_window_event_closure = NULL;
static mbw_input_event_trampoline_t g_input_event_trampoline = NULL;
static void *g_input_event_closure = NULL;
static mbw_sync_query_trampoline_t g_sync_query_trampoline = NULL;
static void *g_sync_query_closure = NULL;

static const wchar_t *g_class_name = L"MBWWindowClass";
static ATOM g_class_atom = 0;
static HINSTANCE g_hinstance = NULL;
static HWND g_msg_window = NULL;
static DWORD g_main_thread_id = 0;
static BOOL g_class_registered = FALSE;

#define MBW_WM_PROXY_WAKEUP (WM_USER + 0x100)

typedef struct {
  int32_t raw_id;
} MBWWindowState;

static LRESULT CALLBACK mbw_wnd_proc(HWND hwnd, UINT msg, WPARAM wparam,
                                     LPARAM lparam) {
  MBWWindowState *state =
      (MBWWindowState *)GetWindowLongPtrW(hwnd, GWLP_USERDATA);

  if (msg == WM_NCCREATE) {
    CREATESTRUCTW *cs = (CREATESTRUCTW *)lparam;
    MBWWindowState *new_state = (MBWWindowState *)calloc(1, sizeof(MBWWindowState));
    if (new_state) {
      new_state->raw_id = 0;
      SetWindowLongPtrW(hwnd, GWLP_USERDATA, (LONG_PTR)new_state);
    }
    return DefWindowProcW(hwnd, msg, wparam, lparam);
  }

  if (msg == WM_DESTROY) {
    if (state) {
      if (g_window_event_trampoline && g_window_event_closure) {
        g_window_event_trampoline(g_window_event_closure, 2, state->raw_id, 0,
                                  0, 0, 0.0);
      }
      SetWindowLongPtrW(hwnd, GWLP_USERDATA, 0);
      free(state);
    }
    return 0;
  }

  if (state && g_window_event_trampoline && g_window_event_closure) {
    switch (msg) {
    case WM_CLOSE:
      g_window_event_trampoline(g_window_event_closure, 1, state->raw_id, 0,
                                0, 0, 0.0);
      return 0;

    case WM_SIZE: {
      int32_t width = LOWORD(lparam);
      int32_t height = HIWORD(lparam);
      int32_t size_kind = (int32_t)wparam;
      g_window_event_trampoline(g_window_event_closure, 3, state->raw_id,
                                width, height, size_kind, 0.0);
      return 0;
    }

    case WM_MOVE: {
      int32_t x = (int32_t)(short)LOWORD(lparam);
      int32_t y = (int32_t)(short)HIWORD(lparam);
      g_window_event_trampoline(g_window_event_closure, 4, state->raw_id, x,
                                y, 0, 0.0);
      return 0;
    }

    case WM_PAINT: {
      PAINTSTRUCT ps;
      BeginPaint(hwnd, &ps);
      EndPaint(hwnd, &ps);
      g_window_event_trampoline(g_window_event_closure, 5,
                                state->raw_id, 0, 0, 0, 0.0);
      return 0;
    }

    case WM_ACTIVATE: {
      int32_t active = LOWORD(wparam);
      int32_t minimized = HIWORD(wparam);
      g_window_event_trampoline(g_window_event_closure, 6, state->raw_id,
                                active, minimized, 0, 0.0);
      return 0;
    }

    case WM_ERASEBKGND:
      return 1;

    case WM_GETMINMAXINFO: {
      if (g_sync_query_trampoline && g_sync_query_closure) {
        int32_t result = g_sync_query_trampoline(
            g_sync_query_closure, state->raw_id, 1, 0);
        if (result) {
          MINMAXINFO *mmi = (MINMAXINFO *)lparam;
          int32_t min_w = g_sync_query_trampoline(
              g_sync_query_closure, state->raw_id, 2, 0);
          int32_t min_h = g_sync_query_trampoline(
              g_sync_query_closure, state->raw_id, 3, 0);
          int32_t max_w = g_sync_query_trampoline(
              g_sync_query_closure, state->raw_id, 4, 0);
          int32_t max_h = g_sync_query_trampoline(
              g_sync_query_closure, state->raw_id, 5, 0);
          if (min_w > 0 || min_h > 0) {
            if (min_w > 0) mmi->ptMinTrackSize.x = min_w;
            if (min_h > 0) mmi->ptMinTrackSize.y = min_h;
          }
          if (max_w > 0 || max_h > 0) {
            if (max_w > 0) mmi->ptMaxTrackSize.x = max_w;
            if (max_h > 0) mmi->ptMaxTrackSize.y = max_h;
          }
        }
      }
      return 0;
    }

    case WM_DPICHANGED: {
      int32_t new_dpi_x = LOWORD(wparam);
      int32_t new_dpi_y = HIWORD(wparam);
      double scale = (double)new_dpi_x / 96.0;
      g_window_event_trampoline(g_window_event_closure, 40, state->raw_id,
                                new_dpi_x, new_dpi_y, 0, scale);
      RECT *suggested = (RECT *)lparam;
      SetWindowPos(hwnd, NULL, suggested->left, suggested->top,
                   suggested->right - suggested->left,
                   suggested->bottom - suggested->top,
                   SWP_NOZORDER | SWP_NOACTIVATE);
      return 0;
    }

    case WM_SETTINGCHANGE: {
      if (wparam == 0 && lparam) {
        const wchar_t *section = (const wchar_t *)lparam;
        if (wcsicmp(section, L"ImmersiveColorSet") == 0 ||
            wcsicmp(section, L"Software\\Microsoft\\Windows\\CurrentVersion\\"
                             L"Themes\\Personalize") == 0) {
          g_window_event_trampoline(g_window_event_closure, 41,
                                    state->raw_id, 0, 0, 0, 0.0);
        }
      }
      return DefWindowProcW(hwnd, msg, wparam, lparam);
    }

    case WM_SETCURSOR: {
      if (LOWORD(lparam) == HTCLIENT) {
        if (g_sync_query_trampoline && g_sync_query_closure) {
          g_sync_query_trampoline(g_sync_query_closure, state->raw_id, 10, 0);
        }
        return TRUE;
      }
      return DefWindowProcW(hwnd, msg, wparam, lparam);
    }

    default:
      break;
    }
  }

  if (state && g_input_event_trampoline && g_input_event_closure) {
    switch (msg) {
    case WM_MOUSEMOVE:
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 10,
                               wparam, lparam);
      return 0;

    case WM_MOUSELEAVE:
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 11, 0,
                               lparam);
      return 0;

    case WM_LBUTTONDOWN:
      SetCapture(hwnd);
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 12,
                               wparam, lparam);
      return 0;

    case WM_LBUTTONUP:
      ReleaseCapture();
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 13,
                               wparam, lparam);
      return 0;

    case WM_RBUTTONDOWN:
      SetCapture(hwnd);
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 14,
                               wparam, lparam);
      return 0;

    case WM_RBUTTONUP:
      ReleaseCapture();
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 15,
                               wparam, lparam);
      return 0;

    case WM_MBUTTONDOWN:
      SetCapture(hwnd);
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 16,
                               wparam, lparam);
      return 0;

    case WM_MBUTTONUP:
      ReleaseCapture();
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 17,
                               wparam, lparam);
      return 0;

    case WM_XBUTTONDOWN:
      SetCapture(hwnd);
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 18,
                               wparam, lparam);
      return 0;

    case WM_XBUTTONUP:
      ReleaseCapture();
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 19,
                               wparam, lparam);
      return 0;

    case WM_MOUSEWHEEL:
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 20,
                               wparam, lparam);
      return 0;

    case WM_MOUSEHWHEEL:
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 21,
                               wparam, lparam);
      return 0;

    case WM_KEYDOWN:
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 30,
                               wparam, lparam);
      return 0;

    case WM_KEYUP:
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 31,
                               wparam, lparam);
      return 0;

    case WM_SYSKEYDOWN:
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 32,
                               wparam, lparam);
      return 0;

    case WM_SYSKEYUP:
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 33,
                               wparam, lparam);
      return 0;

    case WM_CHAR:
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 34,
                               wparam, lparam);
      return 0;

    default:
      break;
    }
  }

  if (msg == MBW_WM_PROXY_WAKEUP) {
    return 0;
  }

  return DefWindowProcW(hwnd, msg, wparam, lparam);
}

MOONBIT_FFI_EXPORT
int32_t mbw_register_window_class(void) {
  if (g_class_registered) {
    return 1;
  }
  g_hinstance = GetModuleHandleW(NULL);
  if (!g_hinstance) {
    return 0;
  }

  WNDCLASSEXW wc = {0};
  wc.cbSize = sizeof(WNDCLASSEXW);
  wc.style = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
  wc.lpfnWndProc = mbw_wnd_proc;
  wc.hInstance = g_hinstance;
  wc.hCursor = LoadCursorW(NULL, MAKEINTRESOURCEW(32512));
  wc.hIcon = LoadIconW(NULL, MAKEINTRESOURCEW(32512));
  wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
  wc.lpszClassName = g_class_name;

  g_class_atom = RegisterClassExW(&wc);
  if (!g_class_atom) {
    return 0;
  }
  g_class_registered = TRUE;
  return 1;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_create_msg_window(void) {
  g_msg_window = CreateWindowExW(0, g_class_name, L"", 0, 0, 0, 0, 0,
                                 HWND_MESSAGE, NULL, g_hinstance, NULL);
  g_main_thread_id = GetCurrentThreadId();
  return (uint64_t)g_msg_window;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_create_window(int32_t width, int32_t height, uint64_t ex_style,
                           uint64_t style, int32_t x, int32_t y,
                           uint64_t parent_hwnd) {
  HWND parent = (parent_hwnd != 0) ? (HWND)parent_hwnd : NULL;
  HWND hwnd = CreateWindowExW(
      (DWORD)ex_style, g_class_name, L"", (DWORD)style, x, y, width, height,
      parent, NULL, g_hinstance, NULL);
  return (uint64_t)hwnd;
}

MOONBIT_FFI_EXPORT
void mbw_set_window_raw_id(uint64_t hwnd, int32_t raw_id) {
  MBWWindowState *state =
      (MBWWindowState *)GetWindowLongPtrW((HWND)hwnd, GWLP_USERDATA);
  if (state) {
    state->raw_id = raw_id;
  }
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_window_raw_id(uint64_t hwnd) {
  MBWWindowState *state =
      (MBWWindowState *)GetWindowLongPtrW((HWND)hwnd, GWLP_USERDATA);
  if (state) {
    return state->raw_id;
  }
  return -1;
}

MOONBIT_FFI_EXPORT
void mbw_destroy_window(uint64_t hwnd) {
  DestroyWindow((HWND)hwnd);
}

MOONBIT_FFI_EXPORT
void mbw_install_window_event_callback(
    mbw_window_event_trampoline_t trampoline, void *closure) {
  if (g_window_event_closure != NULL) {
    moonbit_decref(g_window_event_closure);
  }
  g_window_event_trampoline = trampoline;
  g_window_event_closure = closure;
}

MOONBIT_FFI_EXPORT
void mbw_install_input_event_callback(mbw_input_event_trampoline_t trampoline,
                                      void *closure) {
  if (g_input_event_closure != NULL) {
    moonbit_decref(g_input_event_closure);
  }
  g_input_event_trampoline = trampoline;
  g_input_event_closure = closure;
}

MOONBIT_FFI_EXPORT
void mbw_install_sync_query_callback(mbw_sync_query_trampoline_t trampoline,
                                     void *closure) {
  if (g_sync_query_closure != NULL) {
    moonbit_decref(g_sync_query_closure);
  }
  g_sync_query_trampoline = trampoline;
  g_sync_query_closure = closure;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_message(uint8_t *msg_buf, uint64_t hwnd, uint32_t min_msg,
                        uint32_t max_msg) {
  return (int32_t)GetMessageW((MSG *)msg_buf, (HWND)hwnd, min_msg, max_msg);
}

MOONBIT_FFI_EXPORT
int32_t mbw_peek_message(uint8_t *msg_buf, uint64_t hwnd, uint32_t min_msg,
                         uint32_t max_msg, uint32_t remove_msg) {
  return (int32_t)PeekMessageW((MSG *)msg_buf, (HWND)hwnd, min_msg, max_msg,
                               remove_msg);
}

MOONBIT_FFI_EXPORT
int32_t mbw_translate_message(uint8_t *msg_buf) {
  return (int32_t)TranslateMessage((MSG *)msg_buf);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_dispatch_message(uint8_t *msg_buf) {
  return (uint64_t)DispatchMessageW((MSG *)msg_buf);
}

MOONBIT_FFI_EXPORT
int32_t mbw_post_thread_message(uint32_t thread_id, uint32_t msg,
                                uint64_t wparam, int64_t lparam) {
  return (int32_t)PostThreadMessageW(thread_id, msg, (WPARAM)wparam,
                                     (LPARAM)lparam);
}

MOONBIT_FFI_EXPORT
void mbw_post_quit_message(int32_t exit_code) {
  PostQuitMessage(exit_code);
}

MOONBIT_FFI_EXPORT
uint32_t mbw_get_current_thread_id(void) {
  return GetCurrentThreadId();
}

MOONBIT_FFI_EXPORT
uint64_t mbw_get_module_handle(void) {
  return (uint64_t)GetModuleHandleW(NULL);
}

MOONBIT_FFI_EXPORT
int32_t mbw_set_window_text(uint64_t hwnd, moonbit_bytes_t text) {
  int32_t text_len = (int32_t)Moonbit_array_length(text);
  int32_t wchars_len = MultiByteToWideChar(CP_UTF8, 0, (LPCSTR)text, text_len, NULL, 0);
  wchar_t *wtext = (wchar_t *)malloc((wchars_len + 1) * sizeof(wchar_t));
  if (!wtext) return 0;
  MultiByteToWideChar(CP_UTF8, 0, (LPCSTR)text, text_len, wtext, wchars_len);
  wtext[wchars_len] = 0;
  int32_t result = (int32_t)SetWindowTextW((HWND)hwnd, wtext);
  free(wtext);
  return result;
}

MOONBIT_FFI_EXPORT
int32_t mbw_set_window_pos(uint64_t hwnd, uint64_t insert_after, int32_t x,
                           int32_t y, int32_t width, int32_t height,
                           uint64_t flags) {
  return (int32_t)SetWindowPos((HWND)hwnd, (HWND)insert_after, x, y, width,
                               height, (UINT)flags);
}

MOONBIT_FFI_EXPORT
int32_t mbw_show_window(uint64_t hwnd, int32_t cmd) {
  return (int32_t)ShowWindow((HWND)hwnd, cmd);
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_window_rect_left(uint64_t hwnd) {
  RECT rect;
  if (GetWindowRect((HWND)hwnd, &rect)) {
    return rect.left;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_window_rect_top(uint64_t hwnd) {
  RECT rect;
  if (GetWindowRect((HWND)hwnd, &rect)) {
    return rect.top;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_window_rect_right(uint64_t hwnd) {
  RECT rect;
  if (GetWindowRect((HWND)hwnd, &rect)) {
    return rect.right;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_window_rect_bottom(uint64_t hwnd) {
  RECT rect;
  if (GetWindowRect((HWND)hwnd, &rect)) {
    return rect.bottom;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_client_rect_left(uint64_t hwnd) {
  RECT rect;
  if (GetClientRect((HWND)hwnd, &rect)) {
    return rect.left;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_client_rect_top(uint64_t hwnd) {
  RECT rect;
  if (GetClientRect((HWND)hwnd, &rect)) {
    return rect.top;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_client_rect_right(uint64_t hwnd) {
  RECT rect;
  if (GetClientRect((HWND)hwnd, &rect)) {
    return rect.right;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_client_rect_bottom(uint64_t hwnd) {
  RECT rect;
  if (GetClientRect((HWND)hwnd, &rect)) {
    return rect.bottom;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_client_to_screen_x(uint64_t hwnd, int32_t x, int32_t y) {
  POINT pt = {x, y};
  if (ClientToScreen((HWND)hwnd, &pt)) {
    return pt.x;
  }
  return x;
}

MOONBIT_FFI_EXPORT
int32_t mbw_client_to_screen_y(uint64_t hwnd, int32_t x, int32_t y) {
  POINT pt = {x, y};
  if (ClientToScreen((HWND)hwnd, &pt)) {
    return pt.y;
  }
  return y;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_key_state(int32_t vk) {
  return (GetKeyState(vk) & 0x8000) != 0 ? 1 : 0;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_set_window_long_ptr(uint64_t hwnd, int32_t index,
                                 uint64_t value) {
  return (uint64_t)SetWindowLongPtrW((HWND)hwnd, index, (LONG_PTR)value);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_get_window_long_ptr(uint64_t hwnd, int32_t index) {
  return (uint64_t)GetWindowLongPtrW((HWND)hwnd, index);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_def_window_proc(uint64_t hwnd, uint32_t msg, uint64_t wparam,
                             int64_t lparam) {
  return (uint64_t)DefWindowProcW((HWND)hwnd, msg, (WPARAM)wparam,
                                  (LPARAM)lparam);
}

MOONBIT_FFI_EXPORT
int32_t mbw_invalidate_rect(uint64_t hwnd, int32_t erase) {
  return (int32_t)InvalidateRect((HWND)hwnd, NULL, erase);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_set_cursor(uint64_t cursor) {
  return (uint64_t)SetCursor((HCURSOR)cursor);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_load_cursor(uint64_t instance, uint64_t cursor_name) {
  return (uint64_t)LoadCursorW((HINSTANCE)instance, (LPCWSTR)cursor_name);
}

MOONBIT_FFI_EXPORT
int32_t mbw_clip_cursor(int32_t left, int32_t top, int32_t right,
                        int32_t bottom) {
  RECT rect;
  rect.left = left;
  rect.top = top;
  rect.right = right;
  rect.bottom = bottom;
  return (int32_t)ClipCursor(&rect);
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_cursor_pos(int32_t *x, int32_t *y) {
  POINT pt;
  int32_t result = (int32_t)GetCursorPos(&pt);
  if (result) {
    *x = pt.x;
    *y = pt.y;
  }
  return result;
}

MOONBIT_FFI_EXPORT
int32_t mbw_set_cursor_pos(int32_t x, int32_t y) {
  return (int32_t)SetCursorPos(x, y);
}

MOONBIT_FFI_EXPORT
int32_t mbw_set_process_dpi_awareness_context(uint64_t value) {
  typedef BOOL(WINAPI * SetProcessDpiAwarenessContext_t)(HANDLE);
  HMODULE user32 = GetModuleHandleW(L"user32.dll");
  if (!user32) {
    return 0;
  }
  SetProcessDpiAwarenessContext_t fn =
      (SetProcessDpiAwarenessContext_t)GetProcAddress(
          user32, "SetProcessDpiAwarenessContext");
  if (!fn) {
    return 0;
  }
  return (int32_t)fn((HANDLE)value);
}

MOONBIT_FFI_EXPORT
uint32_t mbw_get_dpi_for_window(uint64_t hwnd) {
  typedef UINT(WINAPI * GetDpiForWindow_t)(HWND);
  HMODULE user32 = GetModuleHandleW(L"user32.dll");
  if (!user32) {
    return 96;
  }
  GetDpiForWindow_t fn =
      (GetDpiForWindow_t)GetProcAddress(user32, "GetDpiForWindow");
  if (!fn) {
    return 96;
  }
  return fn((HWND)hwnd);
}

MOONBIT_FFI_EXPORT
uint32_t mbw_msg_wait_for_multiple_objects_ex(uint32_t count,
                                              uint64_t *handles,
                                              uint32_t timeout_ms,
                                              uint32_t mask, uint32_t flags) {
  return MsgWaitForMultipleObjectsEx(
      count, (const HANDLE *)handles, timeout_ms, mask, flags);
}

MOONBIT_FFI_EXPORT
int32_t mbw_is_iconic(uint64_t hwnd) {
  return (int32_t)IsIconic((HWND)hwnd);
}

MOONBIT_FFI_EXPORT
int32_t mbw_is_zoomed(uint64_t hwnd) {
  return (int32_t)IsZoomed((HWND)hwnd);
}

MOONBIT_FFI_EXPORT
int32_t mbw_is_window_visible(uint64_t hwnd) {
  return (int32_t)IsWindowVisible((HWND)hwnd);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_get_foreground_window(void) {
  return (uint64_t)GetForegroundWindow();
}

MOONBIT_FFI_EXPORT
int32_t mbw_set_foreground_window(uint64_t hwnd) {
  return (int32_t)SetForegroundWindow((HWND)hwnd);
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_window_placement_show_cmd(uint64_t hwnd) {
  WINDOWPLACEMENT wp = {0};
  wp.length = sizeof(WINDOWPLACEMENT);
  if (GetWindowPlacement((HWND)hwnd, &wp)) {
    return (int32_t)wp.showCmd;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_get_window_long_style(uint64_t hwnd) {
  return (uint64_t)GetWindowLongPtrW((HWND)hwnd, GWL_STYLE);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_get_window_long_ex_style(uint64_t hwnd) {
  return (uint64_t)GetWindowLongPtrW((HWND)hwnd, GWL_EXSTYLE);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_set_window_long_style(uint64_t hwnd, uint64_t style) {
  return (uint64_t)SetWindowLongPtrW((HWND)hwnd, GWL_STYLE, (LONG_PTR)style);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_set_window_long_ex_style(uint64_t hwnd, uint64_t ex_style) {
  return (uint64_t)SetWindowLongPtrW((HWND)hwnd, GWL_EXSTYLE,
                                     (LONG_PTR)ex_style);
}

MOONBIT_FFI_EXPORT
int32_t mbw_adjust_window_rect_ex(int32_t *left, int32_t *top,
                                  int32_t *right, int32_t *bottom,
                                  uint64_t style, int32_t menu,
                                  uint64_t ex_style) {
  RECT rect = {*left, *top, *right, *bottom};
  int32_t result = (int32_t)AdjustWindowRectEx(&rect, (DWORD)style, menu,
                                                (DWORD)ex_style);
  if (result) {
    *left = rect.left;
    *top = rect.top;
    *right = rect.right;
    *bottom = rect.bottom;
  }
  return result;
}

MOONBIT_FFI_EXPORT
void mbw_release_capture(void) { ReleaseCapture(); }

MOONBIT_FFI_EXPORT
uint64_t mbw_send_message(uint64_t hwnd, uint32_t msg, uint64_t wparam,
                          int64_t lparam) {
  return (uint64_t)SendMessageW((HWND)hwnd, msg, (WPARAM)wparam,
                                (LPARAM)lparam);
}

MOONBIT_FFI_EXPORT
int64_t mbw_get_window_thread_process_id(uint64_t hwnd, uint32_t *pid) {
  DWORD process_id = 0;
  DWORD thread_id = GetWindowThreadProcessId((HWND)hwnd, &process_id);
  if (pid != NULL) {
    *pid = (uint32_t)process_id;
  }
  return (int64_t)thread_id;
}

MOONBIT_FFI_EXPORT
int32_t mbw_screen_to_client(uint64_t hwnd, int32_t *x, int32_t *y) {
  POINT pt = {*x, *y};
  int32_t result = (int32_t)ScreenToClient((HWND)hwnd, &pt);
  if (result) {
    *x = pt.x;
    *y = pt.y;
  }
  return result;
}

MOONBIT_FFI_EXPORT
int32_t mbw_client_to_screen(uint64_t hwnd, int32_t *x, int32_t *y) {
  POINT pt = {*x, *y};
  int32_t result = (int32_t)ClientToScreen((HWND)hwnd, &pt);
  if (result) {
    *x = pt.x;
    *y = pt.y;
  }
  return result;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_keyboard_state(uint8_t *key_state) {
  return (int32_t)GetKeyboardState(key_state);
}

MOONBIT_FFI_EXPORT
uint32_t mbw_map_virtual_key(uint32_t code, uint32_t map_type) {
  return MapVirtualKeyW(code, map_type);
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_key_name_text(int64_t lparam, uint16_t *buf, int32_t size) {
  return (int32_t)GetKeyNameTextW(lparam, buf, size);
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_system_metrics(int32_t index) {
  return GetSystemMetrics(index);
}

MOONBIT_FFI_EXPORT
int32_t mbw_track_mouse_event(uint64_t hwnd, uint32_t flags) {
  TRACKMOUSEEVENT tme = {0};
  tme.cbSize = sizeof(TRACKMOUSEEVENT);
  tme.dwFlags = flags;
  tme.hwndTrack = (HWND)hwnd;
  return (int32_t)TrackMouseEvent(&tme);
}

MOONBIT_FFI_EXPORT
double mbw_getDoubleClickTime(void) {
  return (double)GetDoubleClickTime();
}

MOONBIT_FFI_EXPORT
int32_t mbw_system_parameters_info(uint32_t action, uint32_t param,
                                   void *data, uint32_t win_ini) {
  return (int32_t)SystemParametersInfoW(action, param, data, win_ini);
}

MOONBIT_FFI_EXPORT
int32_t mbw_read_registry_dword(const uint16_t *key_path,
                                const uint16_t *value_name,
                                uint32_t *out_value) {
  HKEY key;
  LONG result = RegOpenKeyExW(HKEY_CURRENT_USER, key_path, 0, KEY_READ, &key);
  if (result != ERROR_SUCCESS) {
    return 0;
  }
  DWORD data;
  DWORD data_size = sizeof(DWORD);
  result = RegQueryValueExW(key, value_name, NULL, NULL, (LPBYTE)&data,
                            &data_size);
  RegCloseKey(key);
  if (result == ERROR_SUCCESS) {
    *out_value = data;
    return 1;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_process_one_message(uint64_t hwnd, uint32_t min_msg,
                                uint32_t max_msg, uint32_t remove_msg) {
  MSG msg;
  int32_t has_msg = (int32_t)PeekMessageW(&msg, (HWND)hwnd, min_msg, max_msg,
                                           remove_msg);
  if (has_msg) {
    TranslateMessage(&msg);
    DispatchMessageW(&msg);
  }
  return has_msg;
}

MOONBIT_FFI_EXPORT
int32_t mbw_wait_and_process_message(uint64_t hwnd, uint32_t min_msg,
                                     uint32_t max_msg) {
  MSG msg;
  int32_t result = (int32_t)GetMessageW(&msg, (HWND)hwnd, min_msg, max_msg);
  if (result > 0) {
    TranslateMessage(&msg);
    DispatchMessageW(&msg);
  }
  return result;
}

MOONBIT_FFI_EXPORT
int32_t mbw_wait_timeout_and_process(uint32_t timeout_ms) {
  DWORD result = MsgWaitForMultipleObjectsEx(0, NULL, timeout_ms, QS_ALLEVENTS,
                                             MWMO_INPUTAVAILABLE);
  if (result == WAIT_TIMEOUT) {
    return 0;
  }
  MSG msg;
  while (PeekMessageW(&msg, NULL, 0, 0, PM_REMOVE)) {
    TranslateMessage(&msg);
    DispatchMessageW(&msg);
  }
  return 1;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t mbw_read_registry_utf8(const uint16_t *key_path,
                                        const uint16_t *value_name) {
  HKEY key;
  LONG result = RegOpenKeyExW(HKEY_CURRENT_USER, key_path, 0, KEY_READ, &key);
  if (result != ERROR_SUCCESS) {
    return moonbit_make_bytes(0, 0);
  }
  DWORD data_size = 0;
  result = RegQueryValueExW(key, value_name, NULL, NULL, NULL, &data_size);
  if (result != ERROR_SUCCESS || data_size == 0) {
    RegCloseKey(key);
    return moonbit_make_bytes(0, 0);
  }
  DWORD *data = (DWORD *)malloc(data_size);
  result = RegQueryValueExW(key, value_name, NULL, NULL, (LPBYTE)data,
                            &data_size);
  RegCloseKey(key);
  if (result != ERROR_SUCCESS) {
    free(data);
    return moonbit_make_bytes(0, 0);
  }
  int32_t out = (int32_t)data[0];
  free(data);
  moonbit_bytes_t bytes = moonbit_make_bytes(4, 0);
  bytes[0] = (uint8_t)(out & 0xFF);
  bytes[1] = (uint8_t)((out >> 8) & 0xFF);
  bytes[2] = (uint8_t)((out >> 16) & 0xFF);
  bytes[3] = (uint8_t)((out >> 24) & 0xFF);
  return bytes;
}
