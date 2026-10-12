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
# Boot path is Xcode only: `xcrun simctl` plus Simulator.app opened by full
# bundle path. `open -a Simulator` is not used; that name is often unregistered
# because Simulator.app lives inside Xcode. This script does not call
# `flutter emulators`, `flutter devices`, or Flutter Device Hub. Those go
# through Flutter's device daemon, which tries to discover and boot the
# simulator itself and can hang on sim loading.
#
# tmux is optional. When `tmux` is on PATH, or at /opt/homebrew/bin/tmux or
# /usr/local/bin/tmux, Flutter stays in the tmux session. When it is missing,
# Simulator.app still opens and `flutter run -d <udid>` runs in this terminal.

set -euo pipefail

BRANCH="${1:-cursor/fix-home-screen-884e}"
PROJECT_DIR="${PROJECT360_DIR:-${HOME}/Desktop/Cursor/Project360-360}"
TMUX_SESSION="${PROJECT360_TMUX_SESSION:-project360-iphone17}"
IOS_SIM_NAME="${IOS_SIM_NAME:-iPhone 17}"
BOOT_TIMEOUT_SECS=60
TMUX_CONF="${TMUX_CONF:-/exec-daemon/tmux.portal.conf}"
TMUX_BIN=""
SIMULATOR_APP=""

simctl_missing_error() {
  echo "xcrun simctl was not found. Install Xcode and open it once so simctl works." >&2
  exit 1
}

simulator_app_missing_error() {
  echo "Simulator.app was not found. Open Xcode once and install the iOS Simulator runtime (Xcode → Settings → Platforms)." >&2
  exit 1
}

# Exact device-name match against simctl text. The line must start with
# "<name> (" so "iPhone 17" does not select "iPhone 17 Pro". When several
# runtimes list the same name, the last one wins (simctl prints newer
# runtimes later).
udid_from_device_list() {
  local name="$1"
  local list_output="$2"
  local line trimmed prefix rest udid="" any=0
  if [[ -z "$name" ]]; then
    echo "IOS_SIM_NAME is empty." >&2
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
    echo "No available simulator named exactly \"${name}\"." >&2
    echo "\"${name}\" is matched as a whole device name, so it does not select a longer name such as \"${name} Pro\"." >&2
    echo "Available iPhone simulators:" >&2
    while IFS= read -r line; do
      trimmed="${line#"${line%%[![:space:]]*}"}"
      if [[ "$trimmed" == iPhone\ * ]]; then
        echo "  ${trimmed}" >&2
        any=1
      fi
    done <<< "$list_output"
    if [[ "$any" -eq 0 ]]; then
      echo "  (none)" >&2
    fi
    echo "Install that simulator in Xcode → Settings → Platforms, or set IOS_SIM_NAME to one of the names above." >&2
    return 1
  fi
  if [[ ! "$udid" =~ ^[0-9A-Fa-f]{8}-([0-9A-Fa-f]{4}-){3}[0-9A-Fa-f]{12}$ ]]; then
    echo "Resolved an unexpected id for \"${name}\": ${udid}" >&2
    return 1
  fi
  printf '%s\n' "$udid"
}

resolve_sim_udid() {
  local name="$1"
  local list_output
  if ! list_output="$(xcrun simctl list devices available)"; then
    echo "xcrun simctl list devices available failed. Install Xcode and open it once so simctl works." >&2
    return 1
  fi
  udid_from_device_list "$name" "$list_output"
}

# Simulator.app is not registered as the bare name "Simulator". It ships
# inside the active Xcode developer directory.
resolve_simulator_app() {
  local developer_dir="" candidate=""
  developer_dir="$(xcode-select -p 2>/dev/null || true)"
  if [[ -n "$developer_dir" && -d "${developer_dir}/Applications/Simulator.app" ]]; then
    printf '%s\n' "${developer_dir}/Applications/Simulator.app"
    return 0
  fi
  if [[ -d "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" ]]; then
    printf '%s\n' "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"
    return 0
  fi
  if command -v mdfind >/dev/null 2>&1; then
    # Read the first hit without a pipefail `head` pipeline (SIGPIPE).
    while IFS= read -r candidate; do
      if [[ -n "$candidate" && -d "$candidate" ]]; then
        printf '%s\n' "$candidate"
        return 0
      fi
    done < <(mdfind 'kMDItemCFBundleIdentifier == com.apple.iphonesimulator' 2>/dev/null || true)
  fi
  return 1
}

# PATH first, then the Homebrew prefixes macOS shells often leave off PATH.
# Returns 0 and sets TMUX_BIN when a binary is found.
resolve_tmux_bin() {
  local candidate
  if command -v tmux >/dev/null 2>&1; then
    TMUX_BIN="$(command -v tmux)"
    return 0
  fi
  for candidate in /opt/homebrew/bin/tmux /usr/local/bin/tmux; do
    if [[ -f "$candidate" && -x "$candidate" ]]; then
      TMUX_BIN="$candidate"
      return 0
    fi
  done
  TMUX_BIN=""
  return 1
}

tmux_cmd() {
  if [[ -z "$TMUX_BIN" ]]; then
    echo "tmux binary was not resolved." >&2
    return 127
  fi
  if [[ -f "$TMUX_CONF" ]]; then
    "$TMUX_BIN" -f "$TMUX_CONF" "$@"
  else
    "$TMUX_BIN" "$@"
  fi
}

require_xcode_simulator() {
  if ! command -v xcrun >/dev/null 2>&1 || ! xcrun --find simctl >/dev/null 2>&1; then
    simctl_missing_error
  fi
  SIMULATOR_APP="$(resolve_simulator_app)" || simulator_app_missing_error
  if [[ ! -d "$SIMULATOR_APP" ]]; then
    simulator_app_missing_error
  fi
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

  if [[ -z "$SIMULATOR_APP" || ! -d "$SIMULATOR_APP" ]]; then
    simulator_app_missing_error
  fi
  echo "==> open -a \"${SIMULATOR_APP}\" --args -CurrentDeviceUDID ${udid}"
  open -a "$SIMULATOR_APP" --args -CurrentDeviceUDID "$udid"

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

  # Simulator.app is already open. A missing tmux must not unwind that boot.
  if resolve_tmux_bin; then
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
  else
    echo "tmux was not found so Flutter is starting in this terminal."
    echo "==> flutter run -d ${udid}"
    exec flutter run -d "$udid"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
