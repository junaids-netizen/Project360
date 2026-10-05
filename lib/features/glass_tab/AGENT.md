# Glass tab handoff (Project360)

Project360 uses the Vera **`handoff/glass-tab/`** bundle for Build an app preview tabs
and (after vendoring) real **Liquid Glass** on iOS 26+.

## Copy from Vera (Mac)

From the **Vera app** repo root (not `vera_design`):

```bash
./tool/vendor_glass_tab.sh /path/to/vera_app
flutter pub get
cd ios && pod install && cd ..
```

That script copies:

- `handoff/glass-tab/glass_tab_shell.dart` → `lib/features/glass_tab/glass_tab_shell.dart`
- `handoff/glass-tab/dart/` → `lib/features/glass_tab/` (availability, haptics, bounce)
- `handoff/glass-tab/ios/` → merged under `ios/Runner/`
- `packages/cupertino_native/` → `packages/cupertino_native/` (as-is)

## Bootstrap (required)

`lib/main.dart` must call `NativeGlassAvailability.initialize()` before `runApp`,
then set `CupertinoNative.useNativeViews` from the result. Without this, iOS shows
the gray capsule fallback even on supported devices.

## Pitch wiring

- Bank demo: `createPitchRouterBank` → `GlassTabShell` + `_PitchPreviewChrome`
- Vendored Vera: `pitch_router_vera.impl.dart` → same shell (dynamic tab count)

Do not fake Liquid Glass with `BackdropFilter` only — use the handoff native path or
the documented gray capsule fallback.
