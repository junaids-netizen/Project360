/// Product modules a bank can turn on for a pitch.
///
/// [home] is always part of the preview. The rest are optional and default on
/// so a full app is one tap, and a card-only bank is a few switches.
enum PitchModule { home, rewards, card, notifications, settings }

/// Tab and route order. Home, then rewards, card, notifications, settings.
const List<PitchModule> pitchModuleOrder = [
  PitchModule.home,
  PitchModule.rewards,
  PitchModule.card,
  PitchModule.notifications,
  PitchModule.settings,
];

extension PitchModuleDetails on PitchModule {
  /// Path segment under the preview router. Settings is the Account tab.
  String get path => switch (this) {
    PitchModule.home => 'home',
    PitchModule.rewards => 'rewards',
    PitchModule.card => 'card',
    PitchModule.notifications => 'notifications',
    PitchModule.settings => 'account',
  };

  String get tabLabel => switch (this) {
    PitchModule.home => 'Home',
    PitchModule.rewards => 'Rewards',
    PitchModule.card => 'Card',
    PitchModule.notifications => 'Notifications',
    PitchModule.settings => 'Account',
  };

  String get rowLabel => switch (this) {
    PitchModule.home => 'Home',
    PitchModule.rewards => 'Rewards',
    PitchModule.card => 'Card management',
    PitchModule.notifications => 'Notifications',
    PitchModule.settings => 'Settings',
  };

  String get rowDescription => switch (this) {
    PitchModule.home =>
      'Balances, transactions, and the card face. Always included.',
    PitchModule.rewards => 'Points, redeem, and the rewards home',
    PitchModule.card => 'Physical card, freeze, wallets, and activation',
    PitchModule.notifications => 'Inbox and account messages',
    PitchModule.settings => 'Profile, security, and account preferences',
  };
}

/// In-memory module switches for one pitch. Not persisted.
class PitchSelection {
  PitchSelection.initial()
    : _optional = {
        PitchModule.rewards,
        PitchModule.card,
        PitchModule.notifications,
        PitchModule.settings,
      };

  final Set<PitchModule> _optional;

  bool enabled(PitchModule module) =>
      module == PitchModule.home || _optional.contains(module);

  /// Home cannot be turned off.
  void toggle(PitchModule module) {
    if (module == PitchModule.home) return;
    if (!_optional.add(module)) _optional.remove(module);
  }

  /// Modules that should appear as tabs, in [pitchModuleOrder].
  List<PitchModule> get previewModules =>
      pitchModuleOrder.where(enabled).toList();
}

/// Home-row labels that open a module which is not in [enabled].
///
/// Home uses these strings on the rows that leave Home. The preview
/// hides those rows and redirects their routes back to `/home`.
Set<String> hiddenHomeShortcutLabels(Set<PitchModule> enabled) {
  return {
    if (!enabled.contains(PitchModule.rewards)) 'Rewards',
    if (!enabled.contains(PitchModule.card)) 'Card',
    if (!enabled.contains(PitchModule.settings)) 'Account',
    if (!enabled.contains(PitchModule.notifications)) 'Inbox',
    if (!enabled.contains(PitchModule.notifications)) 'Notifications',
  };
}

/// Whether [path] may open in a preview that only includes [enabled].
///
/// Home, pay, and other home-owned flows stay available. Tabs and the
/// settings / inbox / card stacks that belong to a switched-off module do not.
bool pitchAllowsPath(Set<PitchModule> enabled, String path) {
  final normalized = path.isEmpty ? '/' : path;
  if (normalized == '/' || normalized == '/home') return true;
  if (normalized.startsWith('/3-tabs')) return false;

  bool has(PitchModule module) =>
      module == PitchModule.home || enabled.contains(module);

  if (normalized == '/rewards' || normalized.startsWith('/rewards/')) {
    return has(PitchModule.rewards);
  }
  if (normalized == '/card' || normalized.startsWith('/card/')) {
    return has(PitchModule.card);
  }
  if (normalized == '/notifications' ||
      normalized.startsWith('/notifications/') ||
      normalized == '/inbox' ||
      normalized.startsWith('/inbox/')) {
    return has(PitchModule.notifications);
  }
  if (normalized == '/account' ||
      normalized.startsWith('/account/') ||
      normalized.startsWith('/settings')) {
    return has(PitchModule.settings);
  }
  return true;
}
