#!/usr/bin/env bash
#
# Pull latest agent branch and relaunch Flutter on the iPhone simulator (Mac only).
#
# Usage:
#   ./scripts/relaunch_ios_sim.sh [branch]
#   PROJECT360_DIR=~/Desktop/Cursor/Project360-360 ./scripts/relaunch_ios_sim.sh
#
# Defaults: branch cursor/fix-home-screen-884e, tmux session project360-iphone17,
# device "iPhone 17".

set -euo pipefail

BRANCH="${1:-cursor/fix-home-screen-884e}"
PROJECT_DIR="${PROJECT360_DIR:-${HOME}/Desktop/Cursor/Project360-360}"
TMUX_SESSION="${PROJECT360_TMUX_SESSION:-project360-iphone17}"
FLUTTER_DEVICE="${PROJECT360_DEVICE:-iPhone 17}"
TMUX_CONF="${TMUX_CONF:-/exec-daemon/tmux.portal.conf}"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script must run on macOS (iOS Simulator)." >&2
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter not found in PATH." >&2
  exit 1
fi

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux not found in PATH." >&2
  exit 1
fi

if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "Project directory not found: $PROJECT_DIR" >&2
  echo "Set PROJECT360_DIR to your checkout (e.g. ~/Desktop/Cursor/Project360-360)." >&2
  exit 1
fi

tmux_cmd() {
  if [[ -f "$TMUX_CONF" ]]; then
    tmux -f "$TMUX_CONF" "$@"
  else
    tmux "$@"
  fi
}

cd "$PROJECT_DIR"

echo "==> Fetch and pull origin/$BRANCH in $PROJECT_DIR"
git fetch origin
git pull origin "$BRANCH"

echo "==> flutter pub get"
flutter pub get

if tmux_cmd has-session -t "=$TMUX_SESSION" 2>/dev/null; then
  echo "==> Stopping prior Flutter run in tmux session $TMUX_SESSION"
  tmux_cmd send-keys -t "$TMUX_SESSION:0.0" C-c
  sleep 1
  tmux_cmd kill-session -t "$TMUX_SESSION"
fi

echo "==> Starting flutter run -d \"$FLUTTER_DEVICE\" in tmux session $TMUX_SESSION"
tmux_cmd new-session -d -s "$TMUX_SESSION" -c "$PROJECT_DIR" -- \
  "${SHELL:-bash}" -lc "flutter run -d \"$FLUTTER_DEVICE\""

echo "Done. Attach with: tmux attach -t $TMUX_SESSION"
