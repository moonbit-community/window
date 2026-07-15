#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NATIVE="$ROOT/macos/native_appkit_main_thread.m"
FFI="$ROOT/macos/ffi.mbt"
WINDOW_APPKIT="$ROOT/macos/window_appkit.mbt"
WINDOW_HIGH_LEVEL=(
  "$ROOT/macos/window.mbt"
  "$ROOT/macos/window_creation.mbt"
  "$ROOT/macos/window_delegate.mbt"
  "$ROOT/macos/window_fullscreen.mbt"
)

for seam in "$WINDOW_APPKIT" \
  "$ROOT/macos/window_creation.mbt" \
  "$ROOT/macos/window_fullscreen.mbt"; do
  if [[ ! -f "$seam" ]]; then
    echo "required Window architecture seam is missing: $seam" >&2
    exit 1
  fi
done

raw_objc_violations="$(rg -n \
  'appkit_objc_msg_send|objc_runtime_selector_handle' \
  "${WINDOW_HIGH_LEVEL[@]}" || true)"
if [[ -n "$raw_objc_violations" ]]; then
  echo "high-level Window modules must not send raw Objective-C messages:" >&2
  echo "$raw_objc_violations" >&2
  exit 1
fi

native_adapter_violations="$(rg -n '^fn native_window_' \
  "${WINDOW_HIGH_LEVEL[@]}" || true)"
if [[ -n "$native_adapter_violations" ]]; then
  echo "native_window adapters must remain in window_appkit.mbt:" >&2
  echo "$native_adapter_violations" >&2
  exit 1
fi

public_adapter_violations="$(rg -n '^pub fn ' "$WINDOW_APPKIT" || true)"
if [[ -n "$public_adapter_violations" ]]; then
  echo "window_appkit.mbt must remain an internal adapter:" >&2
  echo "$public_adapter_violations" >&2
  exit 1
fi

if [[ -e "$ROOT/macos/window_threading.mbt" ]]; then
  echo "Window methods must keep dispatch and implementation in one definition" >&2
  exit 1
fi

mirrored_methods="$(rg -n '^(pub )?fn Window::[A-Za-z0-9_]+_on_main\(' \
  "$ROOT/macos" -g '*.mbt' || true)"
if [[ -n "$mirrored_methods" ]]; then
  echo "Window methods must not use one-to-one _on_main mirrors:" >&2
  echo "$mirrored_methods" >&2
  exit 1
fi

dispatch_violations="$(perl -0777 -ne '
  while (m{(^///\|.*?)(?=^///\||\z)}msg) {
    $block = $1;
    next unless $block =~ /^pub fn Window::([A-Za-z0-9_]+)/m;
    $name = $1;
    next if $name =~ /^(Window|id|rwh_06_display_handle|display_handle)$/;
    $count = () = $block =~ /self\.maybe_wait_on_main(?:_result)?\(/g;
    print "$ARGV: Window::$name has $count main-thread dispatch calls\n"
      unless $count == 1;
  }
' "$ROOT"/macos/*.mbt)"
if [[ -n "$dispatch_violations" ]]; then
  echo "every thread-bound public Window method must dispatch exactly once:" >&2
  echo "$dispatch_violations" >&2
  exit 1
fi

if ! grep -Fq 'pthread_main_np()' "$NATIVE" \
  || ! grep -Fq 'dispatch_sync_f(dispatch_get_main_queue()' "$NATIVE"; then
  echo "native Window dispatcher must run directly on main and sync from workers" >&2
  exit 1
fi

if ! grep -Fq '#borrow(call_closure, callback)' "$FFI"; then
  echo "main-thread FFI trampoline and callback must both be borrowed" >&2
  exit 1
fi

callback_bridge="$(sed -n \
  '/static void mbw_invoke_main_thread_call/,/^}/p' "$NATIVE")"
if [[ "$(grep -c 'moonbit_incref(call->closure);' <<<"$callback_bridge")" != "1" ]] \
  || [[ "$(grep -c 'moonbit_decref(call->closure);' <<<"$callback_bridge")" != "1" ]]; then
  echo "main-thread callback bridge must locally pin the borrowed closure" >&2
  exit 1
fi

bridge_order="$(printf '%s\n' "$callback_bridge" \
  | grep -nE 'moonbit_(incref|decref)|call->trampoline' \
  | cut -d: -f2-)"
expected_order=$'    moonbit_incref(call->closure);\n    call->trampoline(call->closure);\n    moonbit_decref(call->closure);'
if [[ "$bridge_order" != "$expected_order" ]]; then
  echo "main-thread callback bridge must incref immediately around the trampoline call" >&2
  exit 1
fi

echo "Window thread-boundary check passed"
