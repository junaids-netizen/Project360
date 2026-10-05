#!/usr/bin/env bash
# Fix a bad vendor run that replaced Project360's pitch GlassTabShell.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
git checkout -- lib/features/glass_tab/glass_tab_shell.dart lib/features/glass_tab/glass_tab_item.dart
echo "Restored Project360 glass_tab_shell.dart. Re-run ./tool/vendor_glass_tab.sh if needed."
