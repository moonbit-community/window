#ifdef _WIN32

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#ifndef WINVER
#define WINVER 0x0A00
#elif WINVER < 0x0A00
#undef WINVER
#define WINVER 0x0A00
#endif

#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0A00
#elif _WIN32_WINNT < 0x0A00
#undef _WIN32_WINNT
#define _WIN32_WINNT 0x0A00
#endif

#include <moonbit.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <windows.h>
#include <imm.h>

#ifndef WM_DPICHANGED
#define WM_DPICHANGED 0x02E0
#endif

#ifndef DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
typedef HANDLE DPI_AWARENESS_CONTEXT;
#define DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2                         \
  ((DPI_AWARENESS_CONTEXT)-4)
#endif

WINUSERAPI BOOL WINAPI
SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT dpi_context);

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

typedef HIMC(WINAPI *mbw_imm_get_context_t)(HWND);
typedef BOOL(WINAPI *mbw_imm_release_context_t)(HWND, HIMC);
typedef LONG(WINAPI *mbw_imm_get_composition_string_t)(HIMC, DWORD, LPVOID, DWORD);

static HMODULE g_imm32 = NULL;
static mbw_imm_get_context_t g_imm_get_context = NULL;
static mbw_imm_release_context_t g_imm_release_context = NULL;
static mbw_imm_get_composition_string_t g_imm_get_composition_string = NULL;

typedef struct {
  int32_t raw_id;
} MBWWindowState;

static MBWWindowState *mbw_window_state(HWND hwnd) {
  if (!hwnd) {
    return NULL;
  }
  return (MBWWindowState *)GetWindowLongPtrW(hwnd, GWLP_USERDATA);
}

static int32_t mbw_publish_window_state(HWND hwnd, MBWWindowState *state) {
  SetLastError(0);
  LONG_PTR previous = SetWindowLongPtrW(hwnd, GWLP_USERDATA, (LONG_PTR)state);
  return previous != 0 || GetLastError() == 0;
}

static void mbw_clear_window_state(HWND hwnd) {
  MBWWindowState *state = mbw_window_state(hwnd);
  if (!state) {
    return;
  }
  SetWindowLongPtrW(hwnd, GWLP_USERDATA, 0);
  free(state);
}

static int32_t mbw_load_imm32(void) {
  if (g_imm32 && g_imm_get_context && g_imm_release_context &&
      g_imm_get_composition_string) {
    return 1;
  }
  HMODULE imm32 = LoadLibraryW(L"imm32.dll");
  if (!imm32) {
    return 0;
  }
  mbw_imm_get_context_t get_context =
      (mbw_imm_get_context_t)GetProcAddress(imm32, "ImmGetContext");
  mbw_imm_release_context_t release_context =
      (mbw_imm_release_context_t)GetProcAddress(imm32, "ImmReleaseContext");
  mbw_imm_get_composition_string_t get_composition_string =
      (mbw_imm_get_composition_string_t)GetProcAddress(
          imm32, "ImmGetCompositionStringW");
  if (!get_context || !release_context || !get_composition_string) {
    FreeLibrary(imm32);
    g_imm32 = NULL;
    g_imm_get_context = NULL;
    g_imm_release_context = NULL;
    g_imm_get_composition_string = NULL;
    return 0;
  }
  g_imm32 = imm32;
  g_imm_get_context = get_context;
  g_imm_release_context = release_context;
  g_imm_get_composition_string = get_composition_string;
  return 1;
}

static char *mbw_wide_to_utf8_alloc(const wchar_t *wide, int32_t wide_len,
                                    int32_t *out_len) {
  *out_len = 0;
  if (!wide || wide_len <= 0) {
    return NULL;
  }
  int32_t len =
      WideCharToMultiByte(CP_UTF8, 0, wide, wide_len, NULL, 0, NULL, NULL);
  if (len <= 0) {
    return NULL;
  }
  char *utf8 = (char *)malloc((size_t)len);
  if (!utf8) {
    return NULL;
  }
  int32_t written =
      WideCharToMultiByte(CP_UTF8, 0, wide, wide_len, utf8, len, NULL, NULL);
  if (written <= 0) {
    free(utf8);
    return NULL;
  }
  *out_len = written;
  return utf8;
}

static char *mbw_copy_ime_string_utf8(HWND hwnd, DWORD kind, int32_t *out_len) {
  *out_len = 0;
  if (!mbw_load_imm32()) {
    return NULL;
  }
  HIMC himc = g_imm_get_context(hwnd);
  if (!himc) {
    return NULL;
  }
  LONG byte_len = g_imm_get_composition_string(himc, kind, NULL, 0);
  if (byte_len <= 0) {
    g_imm_release_context(hwnd, himc);
    return NULL;
  }
  wchar_t *wide = (wchar_t *)malloc((size_t)byte_len + sizeof(wchar_t));
  if (!wide) {
    g_imm_release_context(hwnd, himc);
    return NULL;
  }
  LONG copied =
      g_imm_get_composition_string(himc, kind, wide, (DWORD)byte_len);
  g_imm_release_context(hwnd, himc);
  if (copied <= 0) {
    free(wide);
    return NULL;
  }
  int32_t wide_len = (int32_t)(copied / (LONG)sizeof(wchar_t));
  wide[wide_len] = 0;
  char *utf8 = mbw_wide_to_utf8_alloc(wide, wide_len, out_len);
  free(wide);
  return utf8;
}

static void mbw_queue_ime_text(HWND hwnd, MBWWindowState *state, int32_t kind,
                               DWORD composition_kind) {
  if (!g_input_event_trampoline || !g_input_event_closure) {
    return;
  }
  int32_t text_len = 0;
  char *text = mbw_copy_ime_string_utf8(hwnd, composition_kind, &text_len);
  if (!text || text_len <= 0) {
    if (text) {
      free(text);
    }
    return;
  }
  g_input_event_trampoline(g_input_event_closure, state->raw_id, kind,
                           (uint64_t)(uintptr_t)text, (int64_t)text_len);
}

static LRESULT CALLBACK mbw_wnd_proc(HWND hwnd, UINT msg, WPARAM wparam,
                                     LPARAM lparam) {
  MBWWindowState *state = mbw_window_state(hwnd);

  if (msg == WM_NCCREATE) {
    CREATESTRUCTW *cs = (CREATESTRUCTW *)lparam;
    MBWWindowState *new_state =
        (MBWWindowState *)calloc(1, sizeof(MBWWindowState));
    if (!new_state) {
      return FALSE;
    }
    new_state->raw_id =
        cs ? (int32_t)(intptr_t)cs->lpCreateParams : 0;
    if (!mbw_publish_window_state(hwnd, new_state)) {
      free(new_state);
      return FALSE;
    }
    return TRUE;
  }

  if (msg == WM_DESTROY) {
    if (state) {
      if (g_window_event_trampoline && g_window_event_closure) {
        g_window_event_trampoline(g_window_event_closure, 2, state->raw_id, 0,
                                  0, 0, 0.0);
      }
      mbw_clear_window_state(hwnd);
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
      RECT *suggested = (RECT *)lparam;
      int32_t suggested_width = 0;
      int32_t suggested_height = 0;
      if (suggested) {
        suggested_width = suggested->right - suggested->left;
        suggested_height = suggested->bottom - suggested->top;
      }
      g_window_event_trampoline(g_window_event_closure, 40, state->raw_id,
                                suggested_width, suggested_height, 0, scale);
      if (suggested) {
        SetWindowPos(hwnd, NULL, suggested->left, suggested->top,
                     suggested_width, suggested_height,
                     SWP_NOZORDER | SWP_NOACTIVATE);
      }
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

    case WM_IME_STARTCOMPOSITION:
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 35, 0, 0);
      return 0;

    case WM_IME_COMPOSITION:
      if ((lparam & GCS_RESULTSTR) != 0) {
        mbw_queue_ime_text(hwnd, state, 37, GCS_RESULTSTR);
      } else if ((lparam & GCS_COMPSTR) != 0) {
        mbw_queue_ime_text(hwnd, state, 36, GCS_COMPSTR);
      }
      return 0;

    case WM_IME_ENDCOMPOSITION:
      g_input_event_trampoline(g_input_event_closure, state->raw_id, 36, 0, 0);
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
uint64_t mbw_hinstance_handle(void) {
  if (!g_hinstance) {
    g_hinstance = GetModuleHandleW(NULL);
  }
  return (uint64_t)g_hinstance;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_create_msg_window(void) {
  if (!mbw_register_window_class()) {
    g_msg_window = NULL;
    g_main_thread_id = 0;
    return 0;
  }
  HWND msg_window = CreateWindowExW(0, g_class_name, L"", 0, 0, 0, 0, 0,
                                    HWND_MESSAGE, NULL, g_hinstance, NULL);
  if (!msg_window) {
    g_msg_window = NULL;
    g_main_thread_id = 0;
    return 0;
  }
  g_msg_window = msg_window;
  g_main_thread_id = GetCurrentThreadId();
  return (uint64_t)g_msg_window;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_create_window(int32_t width, int32_t height, uint64_t ex_style,
                           uint64_t style, int32_t x, int32_t y,
                           uint64_t parent_hwnd, int32_t raw_id) {
  if (!mbw_register_window_class()) {
    return 0;
  }
  HWND parent = (parent_hwnd != 0) ? (HWND)parent_hwnd : NULL;
  HWND hwnd = CreateWindowExW(
      (DWORD)ex_style, g_class_name, L"", (DWORD)style, x, y, width, height,
      parent, NULL, g_hinstance, (LPVOID)(intptr_t)raw_id);
  MBWWindowState *state = mbw_window_state(hwnd);
  if (!hwnd || !state || state->raw_id != raw_id) {
    mbw_clear_window_state(hwnd);
    if (hwnd) {
      DestroyWindow(hwnd);
    }
    return 0;
  }
  return (uint64_t)hwnd;
}

MOONBIT_FFI_EXPORT
void mbw_set_window_raw_id(uint64_t hwnd, int32_t raw_id) {
  MBWWindowState *state = mbw_window_state((HWND)hwnd);
  if (state) {
    state->raw_id = raw_id;
  }
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_window_raw_id(uint64_t hwnd) {
  MBWWindowState *state = mbw_window_state((HWND)hwnd);
  if (state) {
    return state->raw_id;
  }
  return -1;
}

MOONBIT_FFI_EXPORT
void mbw_destroy_window(uint64_t hwnd) {
  HWND window = (HWND)hwnd;
  if (!window) {
    return;
  }
  DestroyWindow(window);
  if (window == g_msg_window) {
    g_msg_window = NULL;
    g_main_thread_id = 0;
  }
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
moonbit_bytes_t mbw_consume_utf8_text(uint64_t ptr, int32_t len) {
  if (ptr == 0 || len <= 0) {
    return moonbit_make_bytes(0, 0);
  }
  char *text = (char *)(uintptr_t)ptr;
  moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
  memcpy(bytes, text, (size_t)len);
  free(text);
  return bytes;
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
int32_t mbw_enable_modern_dpi_awareness(void) {
  return (int32_t)SetProcessDpiAwarenessContext(
      DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
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

#else

#include <moonbit.h>
#include <stdint.h>

typedef void (*mbw_window_event_trampoline_t)(void *closure, int32_t kind,
                                              int32_t raw_id, int32_t arg0,
                                              int32_t arg1, int32_t arg2,
                                              double argd);
typedef void (*mbw_input_event_trampoline_t)(void *closure, int32_t raw_id,
                                             int32_t kind, uint64_t wparam,
                                             int64_t lparam);
typedef int32_t (*mbw_sync_query_trampoline_t)(void *closure, int32_t raw_id,
                                               int32_t kind, int32_t arg0);

MOONBIT_FFI_EXPORT
int32_t mbw_register_window_class(void) { return 0; }

MOONBIT_FFI_EXPORT
uint64_t mbw_hinstance_handle(void) { return 0; }

MOONBIT_FFI_EXPORT
uint64_t mbw_create_msg_window(void) { return 0; }

MOONBIT_FFI_EXPORT
uint64_t mbw_create_window(int32_t width, int32_t height, uint64_t ex_style,
                           uint64_t style, int32_t x, int32_t y,
                           uint64_t parent_hwnd, int32_t raw_id) {
  (void)width;
  (void)height;
  (void)ex_style;
  (void)style;
  (void)x;
  (void)y;
  (void)parent_hwnd;
  (void)raw_id;
  return 0;
}

MOONBIT_FFI_EXPORT
void mbw_set_window_raw_id(uint64_t hwnd, int32_t raw_id) {
  (void)hwnd;
  (void)raw_id;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_window_raw_id(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
void mbw_destroy_window(uint64_t hwnd) { (void)hwnd; }

MOONBIT_FFI_EXPORT
void mbw_install_window_event_callback(
    mbw_window_event_trampoline_t trampoline, void *closure) {
  (void)trampoline;
  (void)closure;
}

MOONBIT_FFI_EXPORT
void mbw_install_input_event_callback(mbw_input_event_trampoline_t trampoline,
                                      void *closure) {
  (void)trampoline;
  (void)closure;
}

MOONBIT_FFI_EXPORT
void mbw_install_sync_query_callback(mbw_sync_query_trampoline_t trampoline,
                                     void *closure) {
  (void)trampoline;
  (void)closure;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_message(uint8_t *msg_buf, uint64_t hwnd, uint32_t min_msg,
                        uint32_t max_msg) {
  (void)msg_buf;
  (void)hwnd;
  (void)min_msg;
  (void)max_msg;
  return -1;
}

MOONBIT_FFI_EXPORT
int32_t mbw_peek_message(uint8_t *msg_buf, uint64_t hwnd, uint32_t min_msg,
                         uint32_t max_msg, uint32_t remove_msg) {
  (void)msg_buf;
  (void)hwnd;
  (void)min_msg;
  (void)max_msg;
  (void)remove_msg;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_translate_message(uint8_t *msg_buf) {
  (void)msg_buf;
  return 0;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_dispatch_message(uint8_t *msg_buf) {
  (void)msg_buf;
  return 0;
}

MOONBIT_FFI_EXPORT
void mbw_post_quit_message(int32_t exit_code) { (void)exit_code; }

MOONBIT_FFI_EXPORT
int32_t mbw_process_one_message(uint64_t hwnd, uint32_t min_msg,
                                uint32_t max_msg, uint32_t remove_msg) {
  (void)hwnd;
  (void)min_msg;
  (void)max_msg;
  (void)remove_msg;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_wait_and_process_message(uint64_t hwnd, uint32_t min_msg,
                                     uint32_t max_msg) {
  (void)hwnd;
  (void)min_msg;
  (void)max_msg;
  return -1;
}

MOONBIT_FFI_EXPORT
int32_t mbw_wait_timeout_and_process(uint32_t timeout_ms) {
  (void)timeout_ms;
  return 0;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t mbw_read_registry_utf8(const uint16_t *key_path,
                                       const uint16_t *value_name) {
  (void)key_path;
  (void)value_name;
  return moonbit_make_bytes(0, 0);
}

MOONBIT_FFI_EXPORT
int32_t mbw_post_thread_message(uint32_t thread_id, uint32_t msg,
                                uint64_t wparam, int64_t lparam) {
  (void)thread_id;
  (void)msg;
  (void)wparam;
  (void)lparam;
  return 0;
}

MOONBIT_FFI_EXPORT
uint32_t mbw_get_current_thread_id(void) { return 0; }

MOONBIT_FFI_EXPORT
uint64_t mbw_get_module_handle(void) { return 0; }

MOONBIT_FFI_EXPORT
int32_t mbw_set_window_text(uint64_t hwnd, moonbit_bytes_t text) {
  (void)hwnd;
  (void)text;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_set_window_pos(uint64_t hwnd, uint64_t insert_after, int32_t x,
                           int32_t y, int32_t width, int32_t height,
                           uint64_t flags) {
  (void)hwnd;
  (void)insert_after;
  (void)x;
  (void)y;
  (void)width;
  (void)height;
  (void)flags;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_show_window(uint64_t hwnd, int32_t cmd) {
  (void)hwnd;
  (void)cmd;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_window_rect_left(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_window_rect_top(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_window_rect_right(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_window_rect_bottom(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_client_rect_left(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_client_rect_top(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_client_rect_right(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_client_rect_bottom(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_client_to_screen_x(uint64_t hwnd, int32_t x, int32_t y) {
  (void)hwnd;
  (void)y;
  return x;
}

MOONBIT_FFI_EXPORT
int32_t mbw_client_to_screen_y(uint64_t hwnd, int32_t x, int32_t y) {
  (void)hwnd;
  (void)x;
  return y;
}

MOONBIT_FFI_EXPORT
int32_t mbw_client_to_screen(uint64_t hwnd, int32_t *x, int32_t *y) {
  (void)hwnd;
  (void)x;
  (void)y;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_key_state(int32_t vk) {
  (void)vk;
  return 0;
}

MOONBIT_FFI_EXPORT
moonbit_bytes_t mbw_consume_utf8_text(uint64_t ptr, int32_t len) {
  (void)ptr;
  (void)len;
  return moonbit_make_bytes(0, 0);
}

MOONBIT_FFI_EXPORT
uint64_t mbw_set_window_long_ptr(uint64_t hwnd, int32_t index,
                                 uint64_t value) {
  (void)hwnd;
  (void)index;
  return value;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_get_window_long_ptr(uint64_t hwnd, int32_t index) {
  (void)hwnd;
  (void)index;
  return 0;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_def_window_proc(uint64_t hwnd, uint32_t msg, uint64_t wparam,
                             int64_t lparam) {
  (void)hwnd;
  (void)msg;
  (void)wparam;
  (void)lparam;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_invalidate_rect(uint64_t hwnd, int32_t erase) {
  (void)hwnd;
  (void)erase;
  return 0;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_set_cursor(uint64_t cursor) { return cursor; }

MOONBIT_FFI_EXPORT
uint64_t mbw_load_cursor(uint64_t instance, uint64_t cursor_name) {
  (void)instance;
  (void)cursor_name;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_clip_cursor(int32_t left, int32_t top, int32_t right,
                        int32_t bottom) {
  (void)left;
  (void)top;
  (void)right;
  (void)bottom;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_cursor_pos(int32_t *x, int32_t *y) {
  if (x != 0) {
    *x = 0;
  }
  if (y != 0) {
    *y = 0;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_set_cursor_pos(int32_t x, int32_t y) {
  (void)x;
  (void)y;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_enable_modern_dpi_awareness(void) { return 0; }

MOONBIT_FFI_EXPORT
uint32_t mbw_get_dpi_for_window(uint64_t hwnd) {
  (void)hwnd;
  return 96;
}

MOONBIT_FFI_EXPORT
uint32_t mbw_msg_wait_for_multiple_objects_ex(uint32_t count,
                                              uint64_t *handles,
                                              uint32_t timeout_ms,
                                              uint32_t mask, uint32_t flags) {
  (void)count;
  (void)handles;
  (void)timeout_ms;
  (void)mask;
  (void)flags;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_is_iconic(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_is_zoomed(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_is_window_visible(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_get_foreground_window(void) { return 0; }

MOONBIT_FFI_EXPORT
int32_t mbw_set_foreground_window(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_window_placement_show_cmd(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_get_window_long_style(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_get_window_long_ex_style(uint64_t hwnd) {
  (void)hwnd;
  return 0;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_set_window_long_style(uint64_t hwnd, uint64_t style) {
  (void)hwnd;
  return style;
}

MOONBIT_FFI_EXPORT
uint64_t mbw_set_window_long_ex_style(uint64_t hwnd, uint64_t ex_style) {
  (void)hwnd;
  return ex_style;
}

MOONBIT_FFI_EXPORT
int32_t mbw_adjust_window_rect_ex(int32_t *left, int32_t *top,
                                  int32_t *right, int32_t *bottom,
                                  uint64_t style, int32_t menu,
                                  uint64_t ex_style) {
  (void)left;
  (void)top;
  (void)right;
  (void)bottom;
  (void)style;
  (void)menu;
  (void)ex_style;
  return 0;
}

MOONBIT_FFI_EXPORT
void mbw_release_capture(void) {}

MOONBIT_FFI_EXPORT
uint64_t mbw_send_message(uint64_t hwnd, uint32_t msg, uint64_t wparam,
                          int64_t lparam) {
  (void)hwnd;
  (void)msg;
  (void)wparam;
  (void)lparam;
  return 0;
}

MOONBIT_FFI_EXPORT
int64_t mbw_get_window_thread_process_id(uint64_t hwnd, uint32_t *pid) {
  (void)hwnd;
  if (pid != 0) {
    *pid = 0;
  }
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_screen_to_client(uint64_t hwnd, int32_t *x, int32_t *y) {
  (void)hwnd;
  (void)x;
  (void)y;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_keyboard_state(uint8_t *key_state) {
  (void)key_state;
  return 0;
}

MOONBIT_FFI_EXPORT
uint32_t mbw_map_virtual_key(uint32_t code, uint32_t map_type) {
  (void)map_type;
  return code;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_key_name_text(int64_t lparam, uint16_t *buf, int32_t size) {
  (void)lparam;
  (void)buf;
  (void)size;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_get_system_metrics(int32_t index) {
  (void)index;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_track_mouse_event(uint64_t hwnd, uint32_t flags) {
  (void)hwnd;
  (void)flags;
  return 0;
}

MOONBIT_FFI_EXPORT
double mbw_getDoubleClickTime(void) { return 0.0; }

MOONBIT_FFI_EXPORT
int32_t mbw_system_parameters_info(uint32_t action, uint32_t param,
                                   void *data, uint32_t win_ini) {
  (void)action;
  (void)param;
  (void)data;
  (void)win_ini;
  return 0;
}

MOONBIT_FFI_EXPORT
int32_t mbw_read_registry_dword(const uint16_t *key_path,
                                const uint16_t *value_name,
                                uint32_t *out_value) {
  (void)key_path;
  (void)value_name;
  if (out_value != 0) {
    *out_value = 0;
  }
  return 0;
}

#endif
