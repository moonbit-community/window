#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

moon check
moon check --warn-list +73
moon test core
moon test dpi
moon test --build-only
moon build
scripts/check_examples_build.sh
scripts/check_ffi_surface.sh

if [[ "${RUN_EXAMPLE_TRANSCRIPTS:-0}" == "1" ]]; then
  scripts/check_example_transcripts.sh
fi
