# Project360

A DIY custom-branded banking app builder. Switch bank brands live from a seed colour, inspect every derived token, and preview core UI primitives on one screen.

Forked from the white-label branding system in [Vera Design](https://github.com/junaids-netizen/Vera-Design).

## Run

This checkout is self-contained: no sibling `../vera_design` folder.

```bash
flutter pub get
flutter run
```

To use the **real Vera Design UI** (same screens as the Vera product) inside
previews, vendor a copy into this repo once:

```bash
./tool/vendor_vera_design.sh /path/to/vera_design
# or from Git:
./tool/vendor_vera_design.sh https://github.com/rishi-zeta/VeraDesign.git
```

Then commit `packages/vera_design/` so the team never needs the Vera repo
checkout again. See [packages/vera_design/README.md](packages/vera_design/README.md).

Tap **info** in the toolbar to open the brand picker (presets + custom hue/intensity).

Optional startup brand:

```bash
flutter run --dart-define=BRAND=northgate
```

## Quality checks

```bash
./tool/check_tokens.sh   # no hardcoded colours outside lib/app/theme/
flutter analyze
flutter test
```

## Add a bank preset

Edit `lib/app/theme/brand.dart` — add a `Brand` to `brandPresets` with `id`, `name`, and `seed` colour.

## Repo

https://github.com/junaids-netizen/Project360
