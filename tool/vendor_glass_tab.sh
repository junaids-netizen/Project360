#!/usr/bin/env bash
#
# Optional: copy iOS handoff glue from vera_design. Project360 glass tabs use
# packages/cupertino_native (CNTabBar) in lib/features/glass_tab/glass_tab_shell.dart —
# do not overwrite that file.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INPUT="${1:-}"

if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 /path/to/vera_design" >&2
  exit 1
fi

if [[ -f "$INPUT/handoff/glass-tab/AGENT.md" ]]; then
  HANDOFF="$INPUT/handoff/glass-tab"
elif [[ -f "$INPUT/AGENT.md" ]]; then
  HANDOFF="$INPUT"
else
  echo "No handoff/glass-tab/AGENT.md under $INPUT — skipping iOS glue only." >&2
  exit 0
fi

if [[ -d "$HANDOFF/ios" ]]; then
  DEST_IOS="$ROOT/ios/Runner/GlassTabHandoff"
  mkdir -p "$DEST_IOS"
  cp -a "$HANDOFF/ios/." "$DEST_IOS/"
  echo "Copied iOS handoff to ios/Runner/GlassTabHandoff/ — wire AppDelegate if AGENT.md says so."
fi

echo "Glass tabs are implemented in lib/features/glass_tab/glass_tab_shell.dart (CNTabBar)."
echo "cupertino_native is vendored under packages/cupertino_native — commit with Project360."
