#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MONITOR="$ROOT/macos/monitor.mbt"
FFI="$ROOT/macos/ffi.mbt"
NATIVE_APPKIT="$ROOT/macos/native_monitor_appkit.m"

extract_block() {
  local pattern="$1"
  local file="${2:-$MONITOR}"
  awk -v pattern="$pattern" '
    $0 ~ pattern { capture = 1 }
    capture && seen && /^\/\/\/\|$/ { exit }
    capture { print; seen = 1 }
  ' "$file"
}

require_contains() {
  local block_name="$1"
  local block="$2"
  local expected="$3"
  if ! grep -Fq "$expected" <<<"$block"; then
    echo "$block_name must call $expected" >&2
    exit 1
  fi
}

require_no_appkit() {
  local block_name="$1"
  local block="$2"
  if grep -Eq 'NSScreen|native_monitor_ns_screen|appkit_objc|objc_runtime' <<<"$block"; then
    echo "$block_name must not access AppKit from the caller thread" >&2
    exit 1
  fi
}

require_no_objc_primitives() {
  local block_name="$1"
  local block="$2"
  if grep -Eq 'appkit_objc_msg_send|objc_runtime|objc_nsstring' <<<"$block"; then
    echo "$block_name must delegate AppKit work to the native main-thread helper" >&2
    exit 1
  fi
}

refresh_fallback="$(extract_block '^fn native_display_refresh_rate_millihertz')"
available_modes="$(extract_block '^fn available_display_video_modes')"
current_mode="$(extract_block '^fn current_display_video_mode')"
provider_modes="$(extract_block 'MacosMonitorHandleProvider with fn video_modes')"
ns_screen="$(extract_block '^fn native_monitor_ns_screen')"
ffi_ns_screen="$(extract_block \
  '^extern "C" fn native_monitor_copy_ns_screen' "$FFI")"

require_contains \
  "native_display_refresh_rate_millihertz" \
  "$refresh_fallback" \
  "native_monitor_display_refresh_rate_millihertz"
require_contains \
  "available_display_video_modes" \
  "$available_modes" \
  "native_display_refresh_rate_millihertz"
require_contains \
  "current_display_video_mode" \
  "$current_mode" \
  "native_display_refresh_rate_millihertz"
require_contains \
  "MacosMonitorHandleProvider::video_modes" \
  "$provider_modes" \
  "available_display_video_modes"
require_contains \
  "native_monitor_ns_screen" \
  "$ns_screen" \
  "native_monitor_copy_ns_screen"

require_no_appkit "native_display_refresh_rate_millihertz" "$refresh_fallback"
require_no_appkit "available_display_video_modes" "$available_modes"
require_no_appkit "current_display_video_mode" "$current_mode"
require_no_appkit "MacosMonitorHandleProvider::video_modes" "$provider_modes"
require_no_objc_primitives "native_monitor_ns_screen" "$ns_screen"

if grep -Fq 'appkit_objc_wrap_owned_object' <<<"$ns_screen"; then
  echo "native_monitor_ns_screen must receive an owned external object directly from FFI" >&2
  exit 1
fi

require_contains \
  "native_monitor_copy_ns_screen FFI" \
  "$ffi_ns_screen" \
  ') -> NativeObjcObject = "mbw_monitor_copy_ns_screen"'

if ! grep -Fq \
  'MBWObjcOwnedObjectHandle *mbw_monitor_copy_ns_screen(uint32_t display_id)' \
  "$NATIVE_APPKIT"; then
  echo "native NSScreen lookup must return the external-object owner type" >&2
  exit 1
fi

if ! grep -Fq \
  'return mbw_objc_owned_object_adopt(context.screen);' \
  "$NATIVE_APPKIT"; then
  echo "native NSScreen lookup must adopt the retained object without integer conversion" >&2
  exit 1
fi

if ! grep -Fq \
  'dispatch_sync_f(dispatch_get_main_queue(), &context, mbw_copy_monitor_ns_screen);' \
  "$NATIVE_APPKIT"; then
  echo "NSScreen lookup must synchronously dispatch to the AppKit main thread" >&2
  exit 1
fi

echo "Monitor thread-boundary check passed"
