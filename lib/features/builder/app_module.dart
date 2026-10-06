/// A piece of the banking app a pitch can include or leave out.
///
/// Home is not optional: the card face and balances are the product. Every
/// other module is a switch on the Build an app screen.
enum AppModule {
  home(
    label: 'Home',
    detail: 'Balances, transactions, and the card face. Always included.',
    tabLabel: 'Home',
    locked: true,
  ),
  rewards(
    label: 'Rewards',
    detail: 'Points, redeem, and the rewards home',
    tabLabel: 'Rewards',
  ),
  card(
    label: 'Card management',
    detail: 'Physical card, freeze, wallets, and activation',
    tabLabel: 'Card',
  ),
  notifications(
    label: 'Notifications',
    detail: 'Inbox and account messages',
    tabLabel: 'Inbox',
  ),
  settings(
    label: 'Settings',
    detail: 'Profile, security, and account preferences',
    tabLabel: 'Settings',
  );

  const AppModule({
    required this.label,
    required this.detail,
    required this.tabLabel,
    this.locked = false,
  });

  final String label;
  final String detail;
  final String tabLabel;
  final bool locked;

  /// What a new pitch starts with: home, plus card management.
  static const Set<AppModule> initial = {home, card};
}
