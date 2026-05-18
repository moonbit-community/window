#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

while IFS= read -r pkg; do
  example="${pkg%/moon.pkg}"
  if rg -q '"is-main"[[:space:]]*:[[:space:]]*true' "$pkg"; then
    moon run --build-only "$example" --target native
  fi
done < <(find examples -name moon.pkg -maxdepth 2 -print | sort)
