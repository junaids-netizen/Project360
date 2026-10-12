#!/usr/bin/env bash
#
# Pull latest agent branch, boot the iPhone simulator from Xcode, then attach
# Flutter to that already-booted device (Mac only).
#
# Usage:
#   ./scripts/relaunch_ios_sim.sh [branch]
#   PROJECT360_DIR=~/Desktop/Cursor/Project360-360 ./scripts/relaunch_ios_sim.sh
#   IOS_SIM_NAME="iPhone 16" ./scripts/relaunch_ios_sim.sh
#
# Defaults: branch cursor/fix-home-screen-884e, tmux session project360-iphone17,
# simulator name "iPhone 17" (IOS_SIM_NAME).
#
# Boot path is Xcode only: `xcrun simctl` plus Simulator.app. This script does
# not call `flutter emulators`, `flutter devices`, or Flutter Device Hub. Those
# go through Flutter's device daemon, which tries to discover and boot the
# simulator itself and can hang on sim loading.

set -euo pipefail

BRANCH="${1:-cursor/fix-home-screen-884e}"
PROJECT_DIR="${PROJECT360_DIR:-${HOME}/Desktop/Cursor/Project360-360}"
TMUX_SESSION="${PROJECT360_TMUX_SESSION:-project360-iphone17}"
IOS_SIM_NAME="${IOS_SIM_NAME:-iPhone 17}"
BOOT_TIMEOUT_SECS=60
TMUX_CONF="${TMUX_CONF:-/exec-daemon/tmux.portal.conf}"

xcode_setup_error() {
  echo "Simulator.app is missing. Install Xcode and open it once so simctl works." >&2
  exit 1
}

# Exact device-name match against `xcrun simctl list devices available`.
# "iPhone 17" must not select "iPhone 17 Pro". When several runtimes list the
# same name, the last one wins (simctl prints newer runtimes later).
resolve_sim_udid() {
  local name="$1"
  local list_output line trimmed prefix rest udid=""
  if [[ -z "$name" ]]; then
    echo "IOS_SIM_NAME is empty." >&2
    return 1
  fi
  if ! list_output="$(xcrun simctl list devices available)"; then
    echo "xcrun simctl list devices available failed. Install Xcode and open it once so simctl works." >&2
    return 1
  fi
  prefix="${name} ("
  while IFS= read -r line; do
    trimmed="${line#"${line%%[![:space:]]*}"}"
    if [[ "$trimmed" == "$prefix"* ]]; then
      rest="${trimmed#"$prefix"}"
      udid="${rest%%)*}"
    fi
  done <<< "$list_output"
  if [[ -z "$udid" ]]; then
    echo "No available simulator named \"${name}\"." >&2
    echo "Install that simulator in Xcode, or set IOS_SIM_NAME to a name from:" >&2
    echo "  xcrun simctl list devices available" >&2
    return 1
  fi
  if [[ ! "$udid" =~ ^[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}$ ]]; then
    echo "Resolved an unexpected id for \"${name}\": ${udid}" >&2
    return 1
  fi
  printf '%s\n' "$udid"
}

tmux_cmd() {
  if [[ -f "$TMUX_CONF" ]]; then
    tmux -f "$TMUX_CONF" "$@"
  else
    tmux "$@"
  fi
}

require_xcode_simulator() {
  local developer_dir=""
  if ! command -v xcrun >/dev/null 2>&1 || ! xcrun --find simctl >/dev/null 2>&1; then
    xcode_setup_error
  fi
  developer_dir="$(xcode-select -p 2>/dev/null || true)"
  if [[ -n "$developer_dir" && -d "${developer_dir}/Applications/Simulator.app" ]]; then
    return 0
  fi
  if [[ -d "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" ]]; then
    return 0
  fi
  xcode_setup_error
}

wait_until_booted() {
  local udid="$1"
  local deadline line
  deadline=$((SECONDS + BOOT_TIMEOUT_SECS))
  while (( SECONDS < deadline )); do
    # Match UDID and Booted on the same simctl line. Avoid grep -q in a
    # pipefail pipeline: grep can exit early and turn a real match into SIGPIPE.
    while IFS= read -r line; do
      if [[ "$line" == *"$udid"*"(Booted)"* ]]; then
        return 0
      fi
    done < <(xcrun simctl list devices 2>/dev/null || true)
    sleep 1
  done
  echo "Timed out after ${BOOT_TIMEOUT_SECS}s waiting for ${udid} to show Booted in \`xcrun simctl list devices\`." >&2
  return 1
}

boot_with_xcode() {
  local udid="$1"
  local boot_log
  boot_log="$(mktemp "${TMPDIR:-/tmp}/project360-sim-boot.XXXXXX")"
  echo "==> xcrun simctl boot ${udid}"
  if ! xcrun simctl boot "$udid" >"$boot_log" 2>&1; then
    if grep -q "current state: Booted" "$boot_log"; then
      echo "    Already booted."
    elif grep -q "current state: Booting" "$boot_log"; then
      echo "    Already booting; waiting until Booted."
    else
      cat "$boot_log" >&2
      rm -f "$boot_log"
      return 1
    fi
  fi
  rm -f "$boot_log"

  echo "==> open -a Simulator --args -CurrentDeviceUDID ${udid}"
  open -a Simulator --args -CurrentDeviceUDID "$udid"

  echo "==> Waiting until ${udid} is Booted (timeout ${BOOT_TIMEOUT_SECS}s)"
  wait_until_booted "$udid"
}

main() {
  local udid

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

  require_xcode_simulator

  if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Project directory not found: $PROJECT_DIR" >&2
    echo "Set PROJECT360_DIR to your checkout (e.g. ~/Desktop/Cursor/Project360-360)." >&2
    exit 1
  fi

  cd "$PROJECT_DIR"

  echo "==> Fetch and pull origin/$BRANCH in $PROJECT_DIR"
  git fetch origin
  git pull origin "$BRANCH"

  echo "==> Resolving \"${IOS_SIM_NAME}\" with xcrun simctl list devices available"
  udid="$(resolve_sim_udid "$IOS_SIM_NAME")" || exit 1
  echo "==> Simulator UDID ${udid}"

  boot_with_xcode "$udid"

  echo "==> flutter pub get"
  flutter pub get

  if tmux_cmd has-session -t "=$TMUX_SESSION" 2>/dev/null; then
    echo "==> Stopping prior Flutter run in tmux session $TMUX_SESSION"
    tmux_cmd send-keys -t "$TMUX_SESSION:0.0" C-c
    sleep 1
    tmux_cmd kill-session -t "$TMUX_SESSION"
  fi

  echo "==> Starting flutter run -d ${udid} in tmux session $TMUX_SESSION"
  tmux_cmd new-session -d -s "$TMUX_SESSION" -c "$PROJECT_DIR" -- \
    "${SHELL:-bash}" -lc "flutter run -d \"${udid}\""

  echo "Done. Attach with: tmux attach -t $TMUX_SESSION"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
