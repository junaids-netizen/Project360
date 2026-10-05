#!/usr/bin/env bash
#
# Copy glass-tab handoff + cupertino_native into Project360.
#
# Pass either:
#   - vera_design repo root (handoff lives at handoff/glass-tab/)
#   - handoff/glass-tab/ directory itself

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INPUT="${1:-}"

if [[ -z "$INPUT" ]]; then
  echo "Usage: $0 /path/to/vera_design | /path/to/vera_design/handoff/glass-tab" >&2
  echo "Example: $0 ~/Desktop/Cursor/vera_design" >&2
  exit 1
fi

resolve_handoff() {
  local base="$1"
  if [[ -f "$base/AGENT.md" ]]; then
    echo "$base"
    return 0
  fi
  if [[ -f "$base/handoff/glass-tab/AGENT.md" ]]; then
    echo "$base/handoff/glass-tab"
    return 0
  fi
  return 1
}

HANDOFF="$(resolve_handoff "$INPUT")" || {
  echo "Missing handoff bundle (expected AGENT.md under handoff/glass-tab/): $INPUT" >&2
  exit 1
}

# vera_design root: parent of handoff/glass-tab, or grandparent if INPUT was handoff dir
if [[ -f "$INPUT/AGENT.md" ]]; then
  VERA_ROOT="$(cd "$INPUT/../.." && pwd)"
else
  VERA_ROOT="$(cd "$INPUT" && pwd)"
fi

CN_SRC="$VERA_ROOT/packages/cupertino_native"
if [[ ! -f "$CN_SRC/pubspec.yaml" && -f "$ROOT/packages/cupertino_native/pubspec.yaml" ]]; then
  echo "Using existing packages/cupertino_native (already hoisted by vendor_vera_design.sh)"
  CN_SRC="$ROOT/packages/cupertino_native"
fi

if [[ ! -f "$CN_SRC/pubspec.yaml" ]]; then
  echo "Missing cupertino_native (expected $VERA_ROOT/packages/cupertino_native)." >&2
  echo "Run ./tool/vendor_vera_design.sh first, or copy cupertino_native into packages/." >&2
  exit 1
fi

DEST_GLASS="$ROOT/lib/features/glass_tab"
mkdir -p "$DEST_GLASS"

echo "Copying glass-tab handoff from $HANDOFF"
cp "$HANDOFF/glass_tab_shell.dart" "$DEST_GLASS/glass_tab_shell.dart"
if [[ -d "$HANDOFF/dart" ]]; then
  rsync -a "$HANDOFF/dart/" "$DEST_GLASS/"
fi
cp "$HANDOFF/AGENT.md" "$DEST_GLASS/AGENT.md"

if [[ "$CN_SRC" != "$ROOT/packages/cupertino_native" ]]; then
  echo "Copying cupertino_native from $CN_SRC"
  rsync -a --delete \
    --exclude .git \
    --exclude build \
    --exclude .dart_tool \
    "$CN_SRC/" "$ROOT/packages/cupertino_native/"
else
  echo "Skipping cupertino_native copy (Project360 already has hoisted package)."
fi

if [[ -d "$HANDOFF/ios" ]]; then
  echo "Copying iOS glue to ios/Runner/GlassTabHandoff/"
  DEST_IOS="$ROOT/ios/Runner/GlassTabHandoff"
  mkdir -p "$DEST_IOS"
  rsync -a "$HANDOFF/ios/" "$DEST_IOS/"
  echo ""
  echo "Review ios/Runner/GlassTabHandoff/ and wire AppDelegate + Xcode per AGENT.md."
fi

cd "$ROOT"
flutter pub get

echo ""
echo "Done. Run on iPhone 17+, hot restart (R) after vendor if the app was already running."
