#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WINDOW_ROOT="$ROOT/modules/window"
EVENT_LOOP="$WINDOW_ROOT/macos/event_loop.mbt"

entry_count="$(rg -c '^pub fn\[A : ApplicationHandler\] EventLoop::(try_run_app_on_demand|try_pump_app_events|try_run_app)\b' "$EVENT_LOOP")"
if [[ "$entry_count" != "3" ]]; then
  echo "expected exactly three AppKit event-loop run entry points, found $entry_count" >&2
  exit 1
fi

violations="$(perl -0777 -ne '
  while (m{(^///\|.*?)(?=^///\||\z)}msg) {
    $block = $1;
    next unless $block =~ /^pub fn(?:\[[^\]]+\])? EventLoop::(try_run_app_on_demand|try_pump_app_events|try_run_app)\b/m;
    $name = $1;
    $count = () = $block =~ /ensure_event_loop_run_thread\(\)/g;
    print "EventLoop::$name has $count runtime thread checks\n"
      unless $count == 1;
  }
' "$EVENT_LOOP")"

if [[ -n "$violations" ]]; then
  echo "every AppKit event-loop run entry point must check the runtime thread:" >&2
  echo "$violations" >&2
  exit 1
fi

echo "Event-loop thread-boundary check passed"
