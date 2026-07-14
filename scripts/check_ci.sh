#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

moon fmt --check
moon check
moon check --warn-list +73
moon test --release
moon build
scripts/check_examples_build.sh
scripts/check_ffi_surface.sh
scripts/check_event_loop_thread_boundary.sh
scripts/check_monitor_thread_boundary.sh
scripts/check_window_thread_boundary.sh

if [[ "${RUN_EXAMPLE_TRANSCRIPTS:-0}" == "1" ]]; then
  scripts/check_example_transcripts.sh
fi
