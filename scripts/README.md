# Scripts

## Relaunch iOS Simulator after a Cloud Agent push

Cloud agents run on Linux and cannot start the iOS Simulator. After an agent finishes and pushes to your branch, run this on your **Mac** from any directory:

```bash
chmod +x ~/Desktop/Cursor/Project360-360/scripts/relaunch_ios_sim.sh   # once
~/Desktop/Cursor/Project360-360/scripts/relaunch_ios_sim.sh
```

The script boots the simulator from Xcode first, then Flutter only attaches to that device:

1. `xcrun simctl list devices available` resolves the simulator name (default `iPhone 17`, override with `IOS_SIM_NAME`) to a UDID.
2. `xcrun simctl boot <udid>` boots it. An already-booted device (`current state: Booted`) is left alone.
3. `open -a Simulator --args -CurrentDeviceUDID <udid>` opens Xcode's Simulator.app (not Flutter's emulator launcher).
4. The script waits until `xcrun simctl list devices` shows that UDID as `Booted` (about 60 seconds).
5. `flutter pub get`, then `flutter run -d <udid>` in tmux session `project360-iphone17`.

It does not call `flutter emulators`, `flutter devices`, or Flutter Device Hub.

### Why Device Hub stalls on sim loading

`flutter run -d "iPhone 17"` passes a **name**. Flutter starts its device daemon (the same discovery path Device Hub uses) to enumerate simulators and, when that device is shut down, boot it. The daemon's simctl discovery/boot call often never returns: CoreSimulator blocks, Device Hub stays on Loading, and `flutter run` never attaches.

This script does not ask the daemon to boot anything. Xcode's `simctl` and Simulator.app bring the device up first. Flutter is started only after that UDID is already `Booted`, and it is given the UDID so it attaches to the running simulator.

If Simulator.app or `simctl` is missing, the script stops and tells you to install Xcode and open it once so simctl works.

Defaults:

| Setting | Default |
|--------|---------|
| Branch | `cursor/fix-home-screen-884e` |
| Project dir | `~/Desktop/Cursor/Project360-360` (`PROJECT360_DIR`) |
| tmux session | `project360-iphone17` |
| Simulator | `iPhone 17` (`IOS_SIM_NAME`) |

Examples:

```bash
# Different worktree and simulator
PROJECT360_DIR=~/Desktop/Cursor/Project360 IOS_SIM_NAME="iPhone 16" ./scripts/relaunch_ios_sim.sh main

# Watch logs
tmux attach -t project360-iphone17
```

Recommended worktree if your main checkout has local WIP that blocks `git pull`:

```bash
cd ~/Desktop/Cursor
git clone https://github.com/junaids-netizen/project360.git Project360-360
cd Project360-360
git fetch origin && git checkout cursor/fix-home-screen-884e
```

Then use `Project360-360` as `PROJECT360_DIR` (or as the default path in the script).

**Automation note:** GitHub Actions on Linux cannot drive the Mac Simulator. A self-hosted Mac worker could run this script on push, but that requires your own hook (e.g. launchd, Shortcuts, or a Cursor automation that SSHs to your Mac). The manual flow above is the supported path from this repo.
