#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MONITOR="$ROOT/macos/monitor.mbt"

extract_block() {
  local pattern="$1"
  awk -v pattern="$pattern" '
    $0 ~ pattern { capture = 1 }
    capture && seen && /^\/\/\/\|$/ { exit }
    capture { print; seen = 1 }
  ' "$MONITOR"
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

refresh_fallback="$(extract_block '^fn native_display_refresh_rate_millihertz')"
available_modes="$(extract_block '^fn available_display_video_modes')"
current_mode="$(extract_block '^fn current_display_video_mode')"
provider_modes="$(extract_block 'MacosMonitorHandleProvider with fn video_modes')"

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

require_no_appkit "native_display_refresh_rate_millihertz" "$refresh_fallback"
require_no_appkit "available_display_video_modes" "$available_modes"
require_no_appkit "current_display_video_mode" "$current_mode"
require_no_appkit "MacosMonitorHandleProvider::video_modes" "$provider_modes"

echo "Monitor thread-boundary check passed"
