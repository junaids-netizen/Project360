# Project360

A DIY custom-branded banking app builder. Switch bank brands live from a seed colour, inspect every derived token, and preview core UI primitives on one screen.

Forked from the white-label branding system in [Vera Design](https://github.com/junaids-netizen/Vera-Design).

## Run

```bash
flutter pub get
flutter run
```

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

Edit `lib/app/theme/brand.dart` — add a `Brand` to `brandPresets` with `id`, `name`, `seed` colour, and `logoAsset`. Drop a single-colour SVG in `assets/images/banks/`. The pitch builder lists that logo in the brand picker and writes the bank's name on the card.

## Repo

https://github.com/junaids-netizen/Project360
