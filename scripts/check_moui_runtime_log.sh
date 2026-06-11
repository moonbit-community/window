#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() {
  printf 'MoUI runtime log check failed: %s\n' "$1" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage: scripts/check_moui_runtime_log.sh [--linux-input <strict|pending-ok>] <linux|windows> <logfile>

Validate a captured Linux or Windows MoUI runtime smoke transcript without
rerunning the native executable. Use this after collecting matching-host logs
from Linux Wayland/Weston or Windows Win32 CI before recording evidence. Linux
logs require strict pointer/keyboard input by default; use pending-ok only for
the core Linux smoke path where input automation is intentionally separate.
EOF
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "missing log file $path"
}

require_output() {
  local output="$1"
  local text="$2"
  [[ "$output" == *"$text"* ]] ||
    fail "log did not contain expected text: $text"
}

reject_output() {
  local output="$1"
  local text="$2"
  if [[ "$output" == *"$text"* ]]; then
    fail "log contained forbidden text: $text"
  fi
}

reject_prefixed_failure_lines() {
  local output="$1"
  local prefix="$2"
  local line
  while IFS= read -r line; do
    if [[ "$line" == "$prefix:"* && "$line" == *"failed"* ]]; then
      fail "log contained $prefix failure line: $line"
    fi
  done <<<"$output"
}

require_output_order() {
  local output="$1"
  local first="$2"
  local second="$3"
  local saw_first=0
  local line
  while IFS= read -r line; do
    if [[ "$saw_first" == "0" && "$line" == "$first"* ]]; then
      saw_first=1
      continue
    fi
    if [[ "$saw_first" == "1" && "$line" == "$second"* ]]; then
      return 0
    fi
  done <<<"$output"
  fail "log did not contain $first before $second"
}

require_exact_output_order() {
  local output="$1"
  local first="$2"
  local second="$3"
  local saw_first=0
  local line
  while IFS= read -r line; do
    if [[ "$saw_first" == "0" && "$line" == "$first" ]]; then
      saw_first=1
      continue
    fi
    if [[ "$saw_first" == "1" && "$line" == "$second" ]]; then
      return 0
    fi
  done <<<"$output"
  fail "log did not contain exact line $first before exact line $second"
}

first_matching_line() {
  local output="$1"
  local needle="$2"
  local line
  while IFS= read -r line; do
    if [[ "$line" == "$needle"* ]]; then
      printf '%s\n' "$line"
      return 0
    fi
  done <<<"$output"
  fail "log did not contain a line with: $needle"
}

require_single_matching_line() {
  local output="$1"
  local needle="$2"
  local count=0
  local line
  while IFS= read -r line; do
    if [[ "$line" == "$needle"* ]]; then
      count=$((count + 1))
    fi
  done <<<"$output"
  if [[ "$count" -ne 1 ]]; then
    fail "log must contain exactly one line with $needle, got $count"
  fi
}

require_single_prefixed_line() {
  local output="$1"
  local prefix="$2"
  require_single_matching_line "$output" "$prefix"
  first_matching_line "$output" "$prefix"
}

require_single_exact_line() {
  local output="$1"
  local expected="$2"
  local count=0
  local line
  while IFS= read -r line; do
    if [[ "$line" == "$expected" ]]; then
      count=$((count + 1))
    fi
  done <<<"$output"
  if [[ "$count" -ne 1 ]]; then
    fail "log must contain exactly one line equal to $expected, got $count"
  fi
}

require_last_prefixed_line() {
  local output="$1"
  local prefix="$2"
  local expected="$3"
  local last=""
  local line
  while IFS= read -r line; do
    if [[ "$line" == "$prefix:"* ]]; then
      last="$line"
    fi
  done <<<"$output"
  if [[ "$last" != "$expected" ]]; then
    fail "last $prefix line must be $expected, got $last"
  fi
}

extract_token_field() {
  local line="$1"
  local field="$2"
  local token value="" count=0
  for token in $line; do
    if [[ "$token" == "$field="* ]]; then
      value="${token#"$field="}"
      count=$((count + 1))
    fi
  done
  if [[ "$count" -eq 0 ]]; then
    fail "missing field $field in line: $line"
  fi
  if [[ "$count" -ne 1 ]]; then
    fail "duplicate field $field in line: $line"
  fi
  printf '%s\n' "$value"
}

extract_hex_field() {
  local line="$1"
  local field="$2"
  local value
  value="$(extract_token_field "$line" "$field")"
  if [[ ! "$value" =~ ^0[xX][0-9A-Fa-f]+$ ]]; then
    fail "field $field must be a hex value in line: $line"
  fi
  value="${value#0x}"
  value="${value#0X}"
  printf '0x%s\n' "$value"
}

normalize_hex() {
  local value="$1"
  value="${value#0x}"
  value="${value#0X}"
  value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
  while [[ "${#value}" -gt 1 && "${value:0:1}" == "0" ]]; do
    value="${value#0}"
  done
  if [[ -z "$value" ]]; then
    value="0"
  fi
  printf '%s\n' "$value"
}

require_nonzero_hex() {
  local label="$1"
  local value="$2"
  if [[ "$(normalize_hex "$value")" == "0" ]]; then
    fail "$label must be nonzero, got $value"
  fi
}

extract_int_field() {
  local line="$1"
  local field="$2"
  local value
  value="$(extract_token_field "$line" "$field")"
  if [[ ! "$value" =~ ^[0-9]+$ ]]; then
    fail "field $field must be an integer in line: $line"
  fi
  printf '%s\n' "$value"
}

extract_size_width() {
  local line="$1"
  local value
  value="$(extract_token_field "$line" "size")"
  if [[ ! "$value" =~ ^[0-9]+x[0-9]+$ ]]; then
    fail "field size must be WIDTHxHEIGHT in line: $line"
  fi
  printf '%s\n' "${value%x*}"
}

extract_size_height() {
  local line="$1"
  local value
  value="$(extract_token_field "$line" "size")"
  if [[ ! "$value" =~ ^[0-9]+x[0-9]+$ ]]; then
    fail "field size must be WIDTHxHEIGHT in line: $line"
  fi
  printf '%s\n' "${value#*x}"
}

extract_scale_field() {
  local line="$1"
  local value
  value="$(extract_token_field "$line" "scale")"
  if [[ ! "$value" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    fail "field scale must be a decimal in line: $line"
  fi
  printf '%s\n' "$value"
}

require_positive_int() {
  local label="$1"
  local value="$2"
  [[ "$value" =~ ^[0-9]+$ ]] || fail "$label must be a positive integer, got $value"
  if [[ "$value" -le 0 ]]; then
    fail "$label must be positive, got $value"
  fi
}

require_positive_decimal() {
  local label="$1"
  local value="$2"
  [[ "$value" =~ ^[0-9]+([.][0-9]+)?$ ]] || fail "$label must be a positive number, got $value"
  awk -v value="$value" 'BEGIN { exit !(value + 0 > 0) }' ||
    fail "$label must be positive, got $value"
}

require_equal_hex() {
  local label="$1"
  local left="$2"
  local right="$3"
  if [[ "$(normalize_hex "$left")" != "$(normalize_hex "$right")" ]]; then
    fail "$label mismatch: $left != $right"
  fi
}

require_current_monitor_id() {
  local output="$1"
  local prefix="$2"
  local line count primary_id current_id
  line="$(require_single_prefixed_line "$output" "$prefix: monitors count=")"
  count="$(extract_int_field "$line" "count")"
  require_positive_int "$prefix monitor count" "$count"
  [[ "$line" == *"primary=true"* ]] ||
    fail "$prefix monitor line did not report primary=true: $line"
  primary_id="$(extract_hex_field "$line" "primary_id")"
  require_nonzero_hex "$prefix primary_id" "$primary_id"
  [[ "$line" == *"current=true"* ]] ||
    fail "$prefix monitor line did not report current=true: $line"
  current_id="$(extract_hex_field "$line" "current_id")"
  require_nonzero_hex "$prefix current_id" "$current_id"
}

require_surface_probe() {
  local output="$1"
  local prefix="$2"
  local line width height scale
  line="$(require_single_prefixed_line "$output" "$prefix: surface size=")"
  width="$(extract_size_width "$line")"
  height="$(extract_size_height "$line")"
  scale="$(extract_scale_field "$line")"
  require_positive_int "$prefix surface width" "$width"
  require_positive_int "$prefix surface height" "$height"
  require_positive_decimal "$prefix surface scale" "$scale"
}

require_positive_size_line() {
  local label="$1"
  local line="$2"
  local width height
  width="$(extract_size_width "$line")"
  height="$(extract_size_height "$line")"
  require_positive_int "$label width" "$width"
  require_positive_int "$label height" "$height"
}

require_resize_delivery() {
  local output="$1"
  local prefix="$2"
  local request_line line width height
  request_line="$(require_single_prefixed_line "$output" "$prefix: resize requested size=")"
  require_positive_size_line "$prefix resize request" "$request_line"
  line="$(first_matching_line "$output" "$prefix: resize size=")"
  width="$(extract_size_width "$line")"
  height="$(extract_size_height "$line")"
  require_positive_int "$prefix resize width" "$width"
  require_positive_int "$prefix resize height" "$height"
  require_output_order "$output" "$prefix: resize requested" "$prefix: resize size="
}

require_pointer_probe() {
  local output="$1"
  local prefix="$2"
  local line x y
  line="$(first_matching_line "$output" "$prefix: pointer")"
  x="$(extract_int_field "$line" "x")"
  y="$(extract_int_field "$line" "y")"
  [[ "$x" =~ ^[0-9]+$ ]] || fail "$prefix pointer x must be a nonnegative integer, got $x"
  [[ "$y" =~ ^[0-9]+$ ]] || fail "$prefix pointer y must be a nonnegative integer, got $y"
}

require_ready_after_evidence() {
  local output="$1"
  local prefix="$2"
  local ready="$prefix: ready"
  local evidence
  shift 2
  for evidence in "$@"; do
    require_output_order "$output" "$evidence" "$ready"
  done
}

require_linux_observed_input_evidence() {
  local output="$1"
  if [[ "$output" != *"MOUILinuxSmoke: pointer"* ]]; then
    fail "Linux ready input=observed requires pointer and keyboard evidence"
  fi
  require_single_exact_line "$output" "MOUILinuxSmoke: keyboard text=a"
  require_pointer_probe "$output" "MOUILinuxSmoke"
  require_output_order "$output" "MOUILinuxSmoke: pointer" \
    "MOUILinuxSmoke: ready input=observed"
  require_exact_output_order "$output" "MOUILinuxSmoke: keyboard text=a" \
    "MOUILinuxSmoke: ready input=observed"
}

require_linux_ready_input_state() {
  local output="$1"
  local line
  require_single_matching_line "$output" "MOUILinuxSmoke: ready input="
  line="$(first_matching_line "$output" "MOUILinuxSmoke: ready input=")"
  case "$line" in
    "MOUILinuxSmoke: ready input=observed")
      require_linux_observed_input_evidence "$output"
      return 0
      ;;
    "MOUILinuxSmoke: ready input=pending")
      if [[ "$linux_input_mode" == "pending-ok" ]]; then
        return 0
      fi
      ;;
  esac
  fail "Linux ready input state must be observed in strict mode or observed/pending in pending-ok mode: $line"
}

check_linux_log() {
  local output="$1"
  local handles_line wl_display wl_surface xdg_surface xdg_toplevel
  reject_output "$output" "MOUIWindowsSmoke:"
  reject_prefixed_failure_lines "$output" "MOUILinuxSmoke"
  require_surface_probe "$output" "MOUILinuxSmoke"
  require_output "$output" "MOUILinuxSmoke: handles wl_display=0x"
  require_output "$output" "wl_surface=0x"
  require_output "$output" "xdg_surface=0x"
  require_output "$output" "xdg_toplevel=0x"
  handles_line="$(require_single_prefixed_line "$output" "MOUILinuxSmoke: handles wl_display=0x")"
  wl_display="$(extract_hex_field "$handles_line" "wl_display")"
  wl_surface="$(extract_hex_field "$handles_line" "wl_surface")"
  xdg_surface="$(extract_hex_field "$handles_line" "xdg_surface")"
  xdg_toplevel="$(extract_hex_field "$handles_line" "xdg_toplevel")"
  require_nonzero_hex "MOUILinuxSmoke wl_display" "$wl_display"
  require_nonzero_hex "MOUILinuxSmoke wl_surface" "$wl_surface"
  require_nonzero_hex "MOUILinuxSmoke xdg_surface" "$xdg_surface"
  require_nonzero_hex "MOUILinuxSmoke xdg_toplevel" "$xdg_toplevel"
  require_single_exact_line "$output" "MOUILinuxSmoke: present result=0"
  require_output "$output" "MOUILinuxSmoke: monitors count="
  require_output "$output" "primary="
  require_output "$output" "primary_id=0x"
  require_output "$output" "current=true"
  require_output "$output" "current_id=0x"
  require_current_monitor_id "$output" "MOUILinuxSmoke"
  require_single_exact_line "$output" "MOUILinuxSmoke: cursor Icon(Text)"
  require_single_exact_line "$output" "MOUILinuxSmoke: ime probe enabled=true hint=true surrounding=true cursor=true updated=true updated_hint=true updated_cursor=true disabled=true"
  require_resize_delivery "$output" "MOUILinuxSmoke"
  require_output "$output" "MOUILinuxSmoke: redraw pre_present_notify"
  require_ready_after_evidence "$output" "MOUILinuxSmoke" \
    "MOUILinuxSmoke: surface size=" \
    "MOUILinuxSmoke: handles wl_display=0x" \
    "MOUILinuxSmoke: present result=0" \
    "MOUILinuxSmoke: monitors count=" \
    "MOUILinuxSmoke: cursor Icon(Text)" \
    "MOUILinuxSmoke: ime probe enabled=true" \
    "MOUILinuxSmoke: resize size=" \
    "MOUILinuxSmoke: redraw pre_present_notify"
  if [[ "$linux_input_mode" == "strict" ]]; then
    require_pointer_probe "$output" "MOUILinuxSmoke"
    require_single_exact_line "$output" "MOUILinuxSmoke: keyboard text=a"
  fi
  require_linux_ready_input_state "$output"
  require_output "$output" "MOUILinuxSmoke: destroy requested"
  require_output "$output" "MOUILinuxSmoke: destroyed"
  require_output "$output" "MOUILinuxSmoke: finished"
  require_single_exact_line "$output" "MOUILinuxSmoke: destroy requested"
  require_single_exact_line "$output" "MOUILinuxSmoke: destroyed"
  require_single_exact_line "$output" "MOUILinuxSmoke: finished"
  require_output_order "$output" "MOUILinuxSmoke: ready" "MOUILinuxSmoke: destroy requested"
  require_output_order "$output" "MOUILinuxSmoke: destroy requested" "MOUILinuxSmoke: destroyed"
  require_output_order "$output" "MOUILinuxSmoke: destroyed" "MOUILinuxSmoke: finished"
  require_last_prefixed_line "$output" "MOUILinuxSmoke" "MOUILinuxSmoke: finished"
  reject_output "$output" "MOUILinuxSmoke: failed"
}

check_windows_log() {
  local output="$1"
  local handle_line hwnd hinstance raw_display raw_window
  reject_output "$output" "MOUILinuxSmoke:"
  reject_prefixed_failure_lines "$output" "MOUIWindowsSmoke"
  require_surface_probe "$output" "MOUIWindowsSmoke"
  require_output "$output" "MOUIWindowsSmoke: handle hwnd=0x"
  require_output "$output" "hinstance=0x"
  require_output "$output" "raw_display=0x"
  require_output "$output" "raw_window=0x"
  handle_line="$(require_single_prefixed_line "$output" "MOUIWindowsSmoke: handle hwnd=0x")"
  hwnd="$(extract_hex_field "$handle_line" "hwnd")"
  hinstance="$(extract_hex_field "$handle_line" "hinstance")"
  raw_display="$(extract_hex_field "$handle_line" "raw_display")"
  raw_window="$(extract_hex_field "$handle_line" "raw_window")"
  require_nonzero_hex "MOUIWindowsSmoke hwnd" "$hwnd"
  require_nonzero_hex "MOUIWindowsSmoke hinstance" "$hinstance"
  require_equal_hex "MOUIWindowsSmoke raw_display identity" "$raw_display" "$hinstance"
  require_equal_hex "MOUIWindowsSmoke raw_window identity" "$raw_window" "$hwnd"
  require_output "$output" "MOUIWindowsSmoke: monitors count="
  require_output "$output" "primary="
  require_output "$output" "primary_id=0x"
  require_output "$output" "current=true"
  require_output "$output" "current_id=0x"
  require_current_monitor_id "$output" "MOUIWindowsSmoke"
  require_single_exact_line "$output" "MOUIWindowsSmoke: cursor Icon(Text)"
  require_single_exact_line "$output" "MOUIWindowsSmoke: ime probe enabled=true hint=true surrounding=true cursor=true updated=true updated_hint=true updated_cursor=true disabled=true"
  require_resize_delivery "$output" "MOUIWindowsSmoke"
  require_output "$output" "MOUIWindowsSmoke: redraw pre_present_notify"
  require_pointer_probe "$output" "MOUIWindowsSmoke"
  require_single_exact_line "$output" "MOUIWindowsSmoke: keyboard key=a"
  require_single_exact_line "$output" "MOUIWindowsSmoke: ime text=a"
  require_output "$output" "MOUIWindowsSmoke: ready"
  require_single_exact_line "$output" "MOUIWindowsSmoke: ready"
  require_ready_after_evidence "$output" "MOUIWindowsSmoke" \
    "MOUIWindowsSmoke: surface size=" \
    "MOUIWindowsSmoke: handle hwnd=0x" \
    "MOUIWindowsSmoke: monitors count=" \
    "MOUIWindowsSmoke: cursor Icon(Text)" \
    "MOUIWindowsSmoke: ime probe enabled=true hint=true" \
    "MOUIWindowsSmoke: resize size=" \
    "MOUIWindowsSmoke: redraw pre_present_notify" \
    "MOUIWindowsSmoke: pointer"
  require_output_order "$output" "MOUIWindowsSmoke: pointer" \
    "MOUIWindowsSmoke: ready"
  require_exact_output_order "$output" "MOUIWindowsSmoke: keyboard key=a" \
    "MOUIWindowsSmoke: ready"
  require_exact_output_order "$output" "MOUIWindowsSmoke: ime text=a" \
    "MOUIWindowsSmoke: ready"
  require_output "$output" "MOUIWindowsSmoke: destroy requested"
  require_output "$output" "MOUIWindowsSmoke: destroyed"
  require_output "$output" "MOUIWindowsSmoke: finished"
  require_single_exact_line "$output" "MOUIWindowsSmoke: destroy requested"
  require_single_exact_line "$output" "MOUIWindowsSmoke: destroyed"
  require_single_exact_line "$output" "MOUIWindowsSmoke: finished"
  require_output_order "$output" "MOUIWindowsSmoke: ready" "MOUIWindowsSmoke: destroy requested"
  require_output_order "$output" "MOUIWindowsSmoke: destroy requested" "MOUIWindowsSmoke: destroyed"
  require_output_order "$output" "MOUIWindowsSmoke: destroyed" "MOUIWindowsSmoke: finished"
  require_last_prefixed_line "$output" "MOUIWindowsSmoke" "MOUIWindowsSmoke: finished"
  reject_output "$output" "MOUIWindowsSmoke: failed"
}

linux_input_mode="strict"
while [[ "${1:-}" == --* ]]; do
  case "$1" in
    --linux-input)
      [[ "$#" -ge 2 ]] || fail "--linux-input requires a value"
      linux_input_mode="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      fail "unknown option $1"
      ;;
  esac
done

case "$linux_input_mode" in
  strict|pending-ok)
    ;;
  *)
    fail "invalid --linux-input $linux_input_mode (expected strict or pending-ok)"
    ;;
esac

backend="${1:-}"
logfile="${2:-}"
case "$backend" in
  -h|--help|"")
    usage
    exit 0
    ;;
  linux|windows)
    ;;
  *)
    usage >&2
    fail "unknown backend $backend"
    ;;
esac

if [[ -z "$logfile" ]]; then
  usage >&2
  fail "missing logfile"
fi

require_file "$logfile"
output="$(sed 's/\r$//' "$logfile")"
case "$backend" in
  linux)
    check_linux_log "$output"
    ;;
  windows)
    check_windows_log "$output"
    ;;
esac

printf 'MoUI %s runtime log check passed: %s\n' "$backend" "$logfile"
