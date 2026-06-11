# Shared host detection for local and CI validation scripts.

detect_window_actual_host() {
  case "$(uname -s 2>/dev/null || printf unknown)" in
    Darwin)
      printf 'macos\n'
      ;;
    Linux)
      printf 'linux\n'
      ;;
    MINGW*|MSYS*|CYGWIN*)
      printf 'windows\n'
      ;;
    *)
      if [[ "${OS:-}" == "Windows_NT" ]]; then
        printf 'windows\n'
      else
        printf 'none\n'
      fi
      ;;
  esac
}

detect_window_ci_host() {
  local actual_host
  actual_host="$(detect_window_actual_host)"

  case "${WINDOW_CI_HOST:-}" in
    "")
      printf '%s\n' "$actual_host"
      ;;
    none)
      printf 'none\n'
      ;;
    macos|linux|windows)
      if [[ "$WINDOW_CI_HOST" != "$actual_host" ]]; then
        printf 'WINDOW_CI_HOST=%s does not match detected host %s; run native smoke on a matching host or use WINDOW_CI_HOST=none to skip native builds\n' "$WINDOW_CI_HOST" "$actual_host" >&2
        return 2
      fi
      printf '%s\n' "$WINDOW_CI_HOST"
      ;;
    *)
      printf 'Invalid WINDOW_CI_HOST=%s (expected macos, linux, windows, or none)\n' "$WINDOW_CI_HOST" >&2
      return 2
      ;;
  esac
}
