#!/usr/bin/env bash
#
# Fails if a colour is written literally anywhere outside lib/app/theme/.
#
# Every literal outside the theme directory is a pixel that will stay Vera
# purple when the app is switched to a bank's brand, so this is the guard that
# keeps the white-label system honest as new screens are added.

set -uo pipefail

cd "$(dirname "$0")/.."

# Colors.transparent is the absence of a colour, not a brand decision.
matches=$(rg --line-number --color=never \
  'Color\(0x|Colors\.[a-z]' \
  lib \
  --glob '!lib/app/theme/**' \
  | rg -v 'Colors\.transparent' || true)

if [ -n "$matches" ]; then
  echo "Hardcoded colours found outside lib/app/theme/:"
  echo
  echo "$matches"
  echo
  echo "Move these into BrandColors so they follow the active brand."
  exit 1
fi

echo "No hardcoded colours outside lib/app/theme/."
