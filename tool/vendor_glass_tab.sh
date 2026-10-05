#!/usr/bin/env bash
#
# Copy Vera's glass-tab handoff and cupertino_native into Project360.
# Argument is the Vera *app* repo root (contains handoff/glass-tab/).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERA_APP="${1:-}"

if [[ -z "$VERA_APP" ]]; then
  echo "Usage: $0 /path/to/vera_app" >&2
  exit 1
fi

HANDOFF="$VERA_APP/handoff/glass-tab"
CN_SRC="$VERA_APP/packages/cupertino_native"

if [[ ! -f "$HANDOFF/AGENT.md" ]]; then
  echo "Missing handoff bundle: $HANDOFF/AGENT.md" >&2
  exit 1
fi

if [[ ! -f "$CN_SRC/pubspec.yaml" ]]; then
  echo "Missing package: $CN_SRC/pubspec.yaml" >&2
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

echo "Copying cupertino_native from $CN_SRC"
rsync -a --delete \
  --exclude .git \
  --exclude build \
  --exclude .dart_tool \
  "$CN_SRC/" "$ROOT/packages/cupertino_native/"

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
