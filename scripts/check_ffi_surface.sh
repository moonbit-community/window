#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ALLOWLIST="$ROOT/docs/ffi-export-allowlist.txt"
WRAPPER_ALLOWLIST="$ROOT/docs/ffi-native-wrapper-allowlist.txt"

if [[ ! -f "$ALLOWLIST" ]]; then
  echo "missing allowlist: $ALLOWLIST" >&2
  exit 1
fi

if [[ ! -f "$WRAPPER_ALLOWLIST" ]]; then
  echo "missing wrapper allowlist: $WRAPPER_ALLOWLIST" >&2
  exit 1
fi

extract_exports() {
  perl -ne '
    if(/MOONBIT_FFI_EXPORT/){$w=1;next}
    if($w){
      next if /^\s*$/;
      if(/(mbw_[A-Za-z0-9_]+)\s*\(/){print "$1\n"; $w=0}
    }
  ' "$ROOT/macos/native_appkit.m" "$ROOT/macos/native_monitor.c" | sort -u
}

current_exports="$(extract_exports)"

if printf '%s\n' "$current_exports" | rg -q '^mbw_input_event_payload_'; then
  echo "found forbidden payload export symbol(s):" >&2
  printf '%s\n' "$current_exports" | rg '^mbw_input_event_payload_' >&2
  exit 1
fi

if rg -q 'native_input_event_payload_' "$ROOT/macos/ffi.mbt"; then
  echo "found forbidden payload binding(s) in macos/ffi.mbt" >&2
  rg -n 'native_input_event_payload_' "$ROOT/macos/ffi.mbt" >&2
  exit 1
fi

new_exports="$(comm -13 "$ALLOWLIST" <(printf '%s\n' "$current_exports") || true)"
if [[ -n "$new_exports" ]]; then
  echo "found newly introduced native export symbol(s):" >&2
  printf '%s\n' "$new_exports" >&2
  echo "update docs/ffi-export-allowlist.txt only after explicit review" >&2
  exit 1
fi

removed_exports="$(comm -23 "$ALLOWLIST" <(printf '%s\n' "$current_exports") || true)"
if [[ -n "$removed_exports" ]]; then
  echo "allowlist contains missing export symbol(s):" >&2
  printf '%s\n' "$removed_exports" >&2
  echo "sync docs/ffi-export-allowlist.txt with current native exports" >&2
  exit 1
fi

current_wrappers="$(
  perl -ne 'print "$1\n" if /^fn (native_[A-Za-z0-9_]+)\s*\(/' \
    "$ROOT/macos/ffi.mbt" | sort -u
)"

new_wrappers="$(comm -13 "$WRAPPER_ALLOWLIST" <(printf '%s\n' "$current_wrappers") || true)"
if [[ -n "$new_wrappers" ]]; then
  echo "found newly introduced native wrapper function(s) in macos/ffi.mbt:" >&2
  printf '%s\n' "$new_wrappers" >&2
  echo "ffi.mbt should keep only primitive bindings; update wrapper allowlist only after explicit review" >&2
  exit 1
fi

echo "FFI surface check passed"
