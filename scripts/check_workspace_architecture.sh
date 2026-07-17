#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WINDOW="$ROOT/modules/window"
WINDOWING="$ROOT/modules/windowing"

if [[ ! -f "$ROOT/moon.work" ]] \
  || ! grep -Fq '"./modules/window"' "$ROOT/moon.work" \
  || ! grep -Fq '"./modules/windowing"' "$ROOT/moon.work"; then
  echo "moon.work must contain both modules under modules/" >&2
  exit 1
fi

if [[ -e "$ROOT/moon.mod" ]]; then
  echo "the workspace root must not also be a MoonBit module" >&2
  exit 1
fi

for file in \
  "$WINDOW/moon.mod" \
  "$WINDOWING/moon.mod" \
  "$WINDOWING/moon.pkg" \
  "$WINDOWING/handle.mbt" \
  "$WINDOWING/raw_handle.mbt"; do
  if [[ ! -f "$file" ]]; then
    echo "missing workspace module file: $file" >&2
    exit 1
  fi
done

if ! grep -Fq '"Milky2018/windowing@' "$WINDOW/moon.mod"; then
  echo "window must declare its windowing module dependency" >&2
  exit 1
fi

if rg -q '"Milky2018/window(?:/|@)' "$WINDOWING" \
  -g 'moon.mod' -g 'moon.pkg'; then
  echo "windowing must not depend on window" >&2
  exit 1
fi

legacy_public_handles="$(rg -n \
  '^pub fn (Window|EventLoop|ActiveEventLoop)::rwh_06' \
  "$WINDOW/macos" -g '*.mbt' || true)"
if [[ -n "$legacy_public_handles" ]]; then
  echo "legacy rwh_06 integer handle methods must not be public:" >&2
  echo "$legacy_public_handles" >&2
  exit 1
fi

integer_handle_surface="$(rg -n \
  '^pub fn (Window::window_handle|Window::display_handle|EventLoop::display_handle|ActiveEventLoop::display_handle).*UInt64' \
  "$WINDOW/macos/pkg.generated.mbti" || true)"
if [[ -n "$integer_handle_surface" ]]; then
  echo "public window/display handle methods must use windowing types:" >&2
  echo "$integer_handle_surface" >&2
  exit 1
fi

for implementation in \
  'pub impl @windowing.WindowHandleProvider for Window' \
  'pub impl @windowing.HasWindowHandle for Window' \
  'pub impl @windowing.DisplayHandleProvider for Window' \
  'pub impl @windowing.HasDisplayHandle for Window' \
  'pub impl @windowing.HasDisplayHandle for EventLoop' \
  'pub impl @windowing.HasDisplayHandle for ActiveEventLoop'; do
  if ! rg -Fq "$implementation" "$WINDOW/macos"; then
    echo "missing windowing implementation: $implementation" >&2
    exit 1
  fi
done

echo "Workspace architecture check passed"
