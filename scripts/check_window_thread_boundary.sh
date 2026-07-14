#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FACADE="$ROOT/macos/window_threading.mbt"
WINDOW="$ROOT/macos/window.mbt"
NATIVE="$ROOT/macos/native_appkit_main_thread.m"

unexpected_files="$(rg -n '^pub fn Window::' "$ROOT/macos" -g '*.mbt' \
  -g '!window_threading.mbt' -g '!window.mbt' || true)"
if [[ -n "$unexpected_files" ]]; then
  echo "public Window methods must use the main-thread facade:" >&2
  echo "$unexpected_files" >&2
  exit 1
fi

unexpected_window="$(rg -n '^pub fn Window::' "$WINDOW" \
  | grep -Ev 'Window::(Window|id|rwh_06_display_handle|display_handle)\(' || true)"
if [[ -n "$unexpected_window" ]]; then
  echo "thread-bound Window methods must move behind window_threading.mbt:" >&2
  echo "$unexpected_window" >&2
  exit 1
fi

public_count="$(rg -c '^pub fn Window::' "$FACADE")"
dispatch_count="$(rg -c 'self\.maybe_wait_on_main(_result)?\(' "$FACADE")"
if [[ "$public_count" != "$dispatch_count" ]]; then
  echo "every public Window facade method must synchronously dispatch to main" >&2
  echo "public methods: $public_count, dispatch calls: $dispatch_count" >&2
  exit 1
fi

if ! grep -Fq 'pthread_main_np()' "$NATIVE" \
  || ! grep -Fq 'dispatch_sync_f(dispatch_get_main_queue()' "$NATIVE"; then
  echo "native Window dispatcher must run directly on main and sync from workers" >&2
  exit 1
fi

echo "Window thread-boundary check passed"
