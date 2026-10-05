# Vera Design (vendored)

Project360 keeps a **copy** of Vera Design here so you never need a sibling
`../vera_design` folder or a separate checkout to run the app.

## One-time setup (on a machine that has Vera Design)

From the Project360 root:

```bash
./tool/vendor_vera_design.sh /path/to/vera_design
./tool/vendor_glass_tab.sh /path/to/vera_app
flutter run -d "iPhone 17"
```

Example on Junaid’s Mac:

```bash
./tool/vendor_vera_design.sh ~/Desktop/Cursor/vera_design
```

The script copies sources and assets into this directory, hoists
`cupertino_native` to `packages/cupertino_native` (so it matches Project360’s
glass-tab dependency), turns on the real Vera UI in previews, and runs
`flutter pub get`.

## Commit the vendored tree

After the script succeeds, commit `packages/vera_design/` so teammates and CI
get the same UI without cloning Vera separately:

```bash
git add packages/vera_design lib/generated/vera_vendored.dart pubspec.yaml pubspec.lock lib/features/pitch/pitch_router_vera.dart lib/features/pitch/home_module_gate_vera.dart
git commit -m "Vendor Vera Design into packages/vera_design"
git push
```

Once that is in GitHub, Project360 is fully independent of the Vera repository.

## Before vendoring

If this folder only contains this README, previews use simplified screens under
`lib/features/bank/` (floating tab bar, different home layout).
