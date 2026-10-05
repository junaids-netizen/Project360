#!/usr/bin/env bash
# Hot restart a running `flutter run` (same terminal session).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
if [[ -n "${FLUTTER_TMUX_SESSION:-}" ]]; then
  tmux -f /exec-daemon/tmux.portal.conf send-keys -t "${FLUTTER_TMUX_SESSION}:0.0" 'R' C-m 2>/dev/null || true
  echo "Sent hot restart (R) to tmux session ${FLUTTER_TMUX_SESSION}."
else
  echo "Start flutter run in this terminal, then press R after each change."
  echo "Or: FLUTTER_TMUX_SESSION=flutter-web ./tool/reload_app.sh"
fi
