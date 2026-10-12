# Scripts

## Relaunch iOS Simulator after a Cloud Agent push

Cloud agents run on Linux and cannot start the iOS Simulator. After an agent finishes and pushes to your branch, run this on your **Mac** from any directory:

```bash
chmod +x ~/Desktop/Cursor/Project360-360/scripts/relaunch_ios_sim.sh   # once
~/Desktop/Cursor/Project360-360/scripts/relaunch_ios_sim.sh
```

Defaults:

| Setting | Default |
|--------|---------|
| Branch | `cursor/fix-home-screen-884e` |
| Project dir | `~/Desktop/Cursor/Project360-360` (`PROJECT360_DIR`) |
| tmux session | `project360-iphone17` |
| Simulator | `iPhone 17` (`PROJECT360_DEVICE`) |

Examples:

```bash
# Different worktree
PROJECT360_DIR=~/Desktop/Cursor/Project360 ./scripts/relaunch_ios_sim.sh main

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
