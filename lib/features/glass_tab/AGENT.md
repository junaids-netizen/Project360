# Glass tab handoff (Project360)

Project360 uses the **`handoff/glass-tab/`** bundle inside **vera_design** for Build an app
preview tabs and (after vendoring) real **Liquid Glass** on iOS 26+.

## Copy from vera_design (Mac)

Handoff path on Junaid’s machine:

`/Users/junaids/Desktop/Cursor/vera_design/handoff/glass-tab/`

From Project360 root:

```bash
./tool/vendor_vera_design.sh ~/Desktop/Cursor/vera_design
./tool/vendor_glass_tab.sh ~/Desktop/Cursor/vera_design
cd ios && pod install && cd ..
flutter run -d "iPhone 17"
```

Or vendor only the handoff (if Vera Design is already copied):

```bash
./tool/vendor_glass_tab.sh ~/Desktop/Cursor/vera_design/handoff/glass-tab
```

That script copies:

- `glass_tab_shell.dart` → `lib/features/glass_tab/glass_tab_shell.dart`
- `dart/` → `lib/features/glass_tab/` (availability, haptics, bounce)
- `ios/` → `ios/Runner/GlassTabHandoff/` (wire AppDelegate per handoff AGENT.md)
- `packages/cupertino_native/` → `packages/cupertino_native/` (unless already hoisted)

## Bootstrap (required)

`lib/main.dart` calls `NativeGlassAvailability.initialize()` before `runApp`, then sets
`CupertinoNative.useNativeViews`. Without this, iOS shows the gray capsule fallback even on
supported devices.

## Pitch wiring

- Bank demo and vendored Vera pitch routers use `GlassTabShell` + `PitchPreviewChrome`.

Do not fake Liquid Glass with `BackdropFilter` only — use the handoff native path or the
documented gray capsule fallback.
