#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM_ROOT="$ROOT/winit-reference"
OUT_DIR="${OUT_DIR:-$ROOT/_build/example-transcripts}"
TIMEOUT_SECS="${TIMEOUT_SECS:-12}"

mkdir -p "$OUT_DIR/raw" "$OUT_DIR/norm" "$OUT_DIR/diff"

examples=(
  application
  child_window
  control_flow
  dnd
  ime
  pump_events
  run_on_demand
  window
  x11_embed
)

normalize_transcript() {
  local input="$1"
  local output="$2"
  perl -pe 's/\x1b\[[0-9;]*[A-Za-z]//g' "$input" \
    | sed -E '/^[[:space:]]*(Compiling|Finished|Running)([[:space:]]|$)/d' \
    | sed -E '/^[[:space:]]*(Blocking|Updating|Downloading|Checking)([[:space:]]|$)/d' \
    | sed -E '/^Finished\. moon:/d' \
    | sed -E '/^Warning: Some diagnostics could not be rendered/d' \
    | sed -E "/^thread 'main'.*panicked at/d" \
    | sed -E '/^note: run with `RUST_BACKTRACE=1`/d' \
    | sed -E 's/^[0-9T:+\.-]+[[:space:]]+(TRACE|DEBUG|INFO|WARN|ERROR)[[:space:]]+[^:]+:[[:space:]]*//' \
    | sed -E 's/id=[0-9]+/id=<ID>/g' \
    | sed -E 's/Window(=| )\{?[0-9]+\}?/Window\1<ID>/g' \
    | sed -E 's/WindowId\([0-9]+\)/WindowId(<ID>)/g' \
    | sed -E 's/0x[0-9a-fA-F]+/<HEX>/g' \
    | sed -E '/^[[:space:]]*$/d' \
    > "$output"
}

run_capture() {
  local cmd="$1"
  local out="$2"
  set +e
  timeout "$TIMEOUT_SECS" bash -lc "$cmd" >"$out" 2>&1
  set -e
  # We deliberately keep output even when command exits non-zero (for example:
  # timeout, intentional panic in unsupported-platform examples, or early exit).
  return 0
}

failures=0

for example in "${examples[@]}"; do
  upstream_raw="$OUT_DIR/raw/upstream-$example.log"
  moon_raw="$OUT_DIR/raw/moon-$example.log"
  upstream_norm="$OUT_DIR/norm/upstream-$example.norm"
  moon_norm="$OUT_DIR/norm/moon-$example.norm"
  diff_out="$OUT_DIR/diff/$example.diff"

  run_capture "cd \"$UPSTREAM_ROOT\" && cargo run -p winit --example \"$example\"" "$upstream_raw"
  run_capture "cd \"$ROOT\" && moon run \"examples/$example\" --target native" "$moon_raw"

  normalize_transcript "$upstream_raw" "$upstream_norm"
  normalize_transcript "$moon_raw" "$moon_norm"

  if ! diff -u "$upstream_norm" "$moon_norm" >"$diff_out"; then
    failures=$((failures + 1))
    echo "transcript mismatch: $example"
    echo "  diff: $diff_out"
  else
    rm -f "$diff_out"
    echo "transcript match: $example"
  fi
done

if [[ "$failures" -ne 0 ]]; then
  echo "example transcript check failed: $failures mismatch(es)"
  exit 1
fi

echo "example transcript check passed"
