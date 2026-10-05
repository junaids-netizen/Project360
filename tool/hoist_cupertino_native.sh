#!/usr/bin/env bash
# One canonical packages/cupertino_native for Project360 + vendored vera_design.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/packages/vera_design"
NESTED_CN="$DEST/packages/cupertino_native"
ROOT_CN="$ROOT/packages/cupertino_native"

if [[ ! -f "$DEST/pubspec.yaml" ]]; then
  echo "Run ./tool/vendor_vera_design.sh first (no packages/vera_design/pubspec.yaml)." >&2
  exit 1
fi

if [[ -f "$NESTED_CN/pubspec.yaml" ]]; then
  echo "Hoisting cupertino_native -> packages/cupertino_native"
  mkdir -p "$ROOT_CN"
  rsync -a "$NESTED_CN/" "$ROOT_CN/"
  rm -rf "$DEST/packages"
else
  echo "No nested packages/vera_design/packages/cupertino_native (already hoisted?)."
fi

python3 - "$DEST/pubspec.yaml" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text()
if "cupertino_native:" not in text:
    print("vera_design pubspec has no cupertino_native — nothing to patch.")
    sys.exit(0)
if "../cupertino_native" in text:
    print("vera_design already uses path ../cupertino_native")
    sys.exit(0)
updated = re.sub(
    r"(cupertino_native:\s*\n\s*path:\s*)(?:\./)?packages/cupertino_native",
    r"\1../cupertino_native",
    text,
)
if updated == text:
    raise SystemExit(
        "Could not patch packages/vera_design/pubspec.yaml — set cupertino_native path to ../cupertino_native manually."
    )
path.write_text(updated)
print("Patched packages/vera_design/pubspec.yaml -> ../cupertino_native")
PY

cd "$ROOT"
flutter pub get
echo "Done."
