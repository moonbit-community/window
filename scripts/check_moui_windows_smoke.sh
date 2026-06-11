#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
. "$ROOT/scripts/ci_host.sh"

fail() {
  printf 'MoUI Windows smoke check failed: %s\n' "$1" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: scripts/check_moui_windows_smoke.sh [--run]

Without --run, build and statically verify the Windows MoUI smoke artifact on a
Windows host. With --run, launch the built Win32 executable and require it to
  print the surface, HWND, resize, redraw, pointer, keyboard key/text, ready,
  destroyed, and finished sentinel lines.
EOF
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "missing file $path"
}

require_text() {
  local path="$1"
  local text="$2"
  rg -q --fixed-strings "$text" "$path" ||
    fail "$path does not contain expected text: $text"
}

run_runtime_verifier() {
  local output_file="$1"
  bash scripts/check_moui_runtime_log.sh windows "$output_file" >/dev/null
}

run_runtime_smoke() {
  local exe="$1"
  local output_file timeout_sec pid status
  timeout_sec="${WINDOW_MOUI_WINDOWS_SMOKE_TIMEOUT_SEC:-15}"
  output_file="$(mktemp "${TMPDIR:-/tmp}/moui-windows-smoke.XXXXXX")"
  trap 'rm -f "${output_file:-}"' EXIT
  set +e
  "$exe" >"$output_file" 2>&1 &
  pid=$!
  status=0
  for ((i = 0; i < timeout_sec * 10; i += 1)); do
    if ! kill -0 "$pid" 2>/dev/null; then
      wait "$pid"
      status=$?
      break
    fi
    sleep 0.1
  done
  if kill -0 "$pid" 2>/dev/null; then
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
    set -e
    printf '%s\n' "$(cat "$output_file")"
    fail "runtime smoke timed out after ${timeout_sec}s"
  fi
  set -e
  cat "$output_file"
  [[ "$status" -eq 0 ]] || fail "runtime exited with status $status"
  run_runtime_verifier "$output_file"
  rm -f "$output_file"
  trap - EXIT
}

run_mode=0
case "${1:-}" in
  "")
    ;;
  --run)
    run_mode=1
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    fail "unknown argument $1"
    ;;
esac

actual_host="$(detect_window_actual_host)"
host="$(detect_window_ci_host)"
if [[ "$host" != "windows" ]]; then
  if [[ "$run_mode" == "1" ]]; then
    fail "Windows runtime smoke requires a Windows host; detected $actual_host"
  fi
  printf 'Skipping MoUI Windows smoke check on %s host\n' "$host"
  exit 0
fi

pkg="examples/moui_windows_smoke"
main="$pkg/main.mbt"
manifest="$pkg/moon.pkg"
stub="$pkg/input_native.c"
exe="_build/native/debug/build/examples/moui_windows_smoke/moui_windows_smoke.exe"

moon build "$pkg" --target native >/dev/null

require_file "$main"
require_file "$manifest"
require_file "$stub"
require_file "$exe"
require_text "$manifest" '"native-stub": [ "input_native.c" ]'
require_text "$stub" "mbw_moui_windows_smoke_send_input"
require_text "$main" "window.window_handle()"
require_text "$main" "window.display_handle()"
require_text "$main" "window.rwh_06_display_handle()"
require_text "$main" "window.rwh_06_window_handle()"
require_text "$main" "display != (0 : Int).to_uint64()"
require_text "$main" "raw_display == display"
require_text "$main" "raw_window == hwnd"
require_text "$main" "window.surface_size()"
require_text "$main" "window.scale_factor()"
require_text "$main" "window.available_monitors()"
require_text "$main" "window.primary_monitor()"
require_text "$main" "window.current_monitor()"
require_text "$main" "monitor.native_id()"
require_text "$main" "primary_id=0x"
require_text "$main" "current_id=0x"
require_text "$main" "self.saw_monitor = log_monitor_probe(window)"
require_text "$main" "window.set_cursor_icon(Text)"
require_text "$main" "window.cursor()"
require_text "$main" "self.saw_cursor = log_cursor_probe(window)"
require_text "$main" "cursor=\{self.saw_cursor}"
require_text "$main" "window.request_ime_update(Enable(enable))"
require_text "$main" "window.request_ime_update(Update(update_data))"
require_text "$main" "window.request_ime_update(Disable)"
require_text "$main" "window.ime_capabilities()"
require_text "$main" "window.ime_hints()"
require_text "$main" "window.ime_purpose()"
require_text "$main" "with_hint_and_purpose"
require_text "$main" "window.ime_surrounding_text()"
require_text "$main" "window.ime_cursor_area_position()"
require_text "$main" "window.ime_cursor_area_size()"
require_text "$main" "MOUIWindowsSmoke: ime probe enabled=\{enabled} hint="
require_text "$main" "window.pre_present_notify()"
require_text "$main" "native_send_input"
require_text "$main" "PointerMoved"
require_text "$main" "KeyboardInput"
require_text "$main" "MOUIWindowsSmoke: keyboard key="
require_text "$main" "Ime(Commit(text))"
require_text "$main" "MOUIWindowsSmoke: ready"
require_text "$main" "window.drop()"
require_text "$main" "MOUIWindowsSmoke: destroy requested"
require_text "$main" "Destroyed"
require_text "$main" "SurfaceResized"
require_text "$main" "RedrawRequested"

if [[ "$run_mode" == "1" ]]; then
  run_runtime_smoke "$exe"
  printf 'MoUI Windows runtime smoke passed: %s\n' "$exe"
else
  printf 'MoUI Windows smoke build check passed: %s\n' "$exe"
fi
