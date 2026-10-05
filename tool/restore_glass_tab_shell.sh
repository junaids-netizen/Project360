#!/usr/bin/env bash
# Fix a bad vendor run that replaced Project360's pitch GlassTabShell.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
git fetch origin cursor/cloud-agent-1791174872384-nm2h0 2>/dev/null || true
git checkout origin/cursor/cloud-agent-1791174872384-nm2h0 -- \
  lib/features/glass_tab/glass_tab_shell.dart \
  lib/features/glass_tab/glass_tab_item.dart \
  lib/main.dart \
  lib/features/glass_tab/native_glass_availability.dart \
  lib/features/glass_tab/native_glass_availability_stub.dart \
  2>/dev/null || git checkout -- \
  lib/features/glass_tab/glass_tab_shell.dart \
  lib/features/glass_tab/glass_tab_item.dart \
  lib/main.dart \
  lib/features/glass_tab/native_glass_availability.dart \
  lib/features/glass_tab/native_glass_availability_stub.dart
echo "Restored Project360 glass tab + main.dart. Re-run ./tool/vendor_glass_tab.sh if needed."
