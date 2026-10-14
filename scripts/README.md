# Scripts

## Relaunch iOS Simulator after a Cloud Agent push

Cloud agents run on Linux and cannot start the iOS Simulator. After an agent finishes and pushes to your branch, run this on your **Mac** from any directory:

```bash
chmod +x ~/Desktop/Cursor/Project360-360/scripts/relaunch_ios_sim.sh   # once
~/Desktop/Cursor/Project360-360/scripts/relaunch_ios_sim.sh
```

The script boots the simulator from Xcode first, then Flutter only attaches to that device:

1. `xcrun simctl list devices available` resolves the simulator name (default `iPhone 18 Pro`, override with `IOS_SIM_NAME`) to a UDID. The name must match exactly, including spaces: `iPhone 18 Pro` does not select `iPhone 18` or `iPhone 18 Pro Max`. If that device is missing, the script says so and lists the available iPhone simulators.
2. `xcrun simctl boot <udid>` boots it. An already-booted device (`current state: Booted`) is left alone.
3. Simulator.app is opened from the Xcode developer directory, not with `open -a Simulator` (that name lookup fails when the app is only registered inside Xcode). The script tries, in order:
   - `$(xcode-select -p)/Applications/Simulator.app`
   - `/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app`
   - `mdfind 'kMDItemCFBundleIdentifier == com.apple.iphonesimulator'`
   Then `open -a "<that .app path>" --args -CurrentDeviceUDID <udid>`. If none of those bundles exist, it stops before `flutter run` and tells you to open Xcode once and install the iOS Simulator runtime (Xcode → Settings → Platforms).
4. The script waits until `xcrun simctl list devices` shows that UDID as `Booted` (about 60 seconds).
5. `flutter pub get`, then `flutter run -d <udid>` (the UDID, not the device name).
   - When `tmux` is on PATH, or at `/opt/homebrew/bin/tmux` or `/usr/local/bin/tmux`, the run stays in tmux session `project360-ios-sim`. Older copies of this script used `project360-iphone17`; this script does not kill that session. Stop a leftover one with `tmux kill-session -t project360-iphone17`.
   - When tmux is missing, the script has already booted Simulator from Xcode. It prints `tmux was not found so Flutter is starting in this terminal.` and runs `flutter run -d <udid>` in the current terminal. A missing tmux does not stop Simulator.app from opening.

It does not call `flutter emulators`, `flutter devices`, or Flutter Device Hub.

### Why Device Hub stalls on sim loading

`flutter run -d "iPhone 18 Pro"` passes a **name**. Flutter starts its device daemon (the same discovery path Device Hub uses) to enumerate simulators and, when that device is shut down, boot it. The daemon's simctl discovery/boot call often never returns: CoreSimulator blocks, Device Hub stays on Loading, and `flutter run` never attaches.

This script does not ask the daemon to boot anything. Xcode's `simctl` and Simulator.app bring the device up first. Flutter is started only after that UDID is already `Booted`, and it is given the UDID so it attaches to the running simulator.

If `simctl` is missing, the script stops and tells you to install Xcode and open it once so simctl works. If Simulator.app is missing, it stops before `flutter run` and tells you to open Xcode once and install the iOS Simulator runtime (Xcode → Settings → Platforms).

Defaults:

| Setting | Default |
|--------|---------|
| Branch | `cursor/fix-home-screen-884e` |
| Project dir | `~/Desktop/Cursor/Project360-360` (`PROJECT360_DIR`) |
| tmux session | `project360-ios-sim` when tmux is installed (`PROJECT360_TMUX_SESSION` overrides); otherwise Flutter runs in this terminal |
| Simulator | `iPhone 18 Pro` (`IOS_SIM_NAME`) |

Examples:

```bash
# Different worktree and simulator
PROJECT360_DIR=~/Desktop/Cursor/Project360 IOS_SIM_NAME="iPhone 16" ./scripts/relaunch_ios_sim.sh main

# Watch logs when tmux is installed
tmux attach -t project360-ios-sim
```

Without tmux, the same script boots the simulator and leaves `flutter run` in the terminal you launched it from. Attach is only for the tmux path.

Recommended worktree if your main checkout has local WIP that blocks `git pull`:

```bash
cd ~/Desktop/Cursor
git clone https://github.com/junaids-netizen/project360.git Project360-360
cd Project360-360
git fetch origin && git checkout cursor/fix-home-screen-884e
```

Then use `Project360-360` as `PROJECT360_DIR` (or as the default path in the script).

**Automation note:** GitHub Actions on Linux cannot drive the Mac Simulator. A self-hosted Mac worker could run this script on push, but that requires your own hook (e.g. launchd, Shortcuts, or a Cursor automation that SSHs to your Mac). The manual flow above is the supported path from this repo.
