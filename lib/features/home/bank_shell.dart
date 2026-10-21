import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/features/home/account_screen.dart';
import 'package:project360/features/home/card_screen.dart';
import 'package:project360/features/home/home_screen.dart';
import 'package:project360/features/home/rewards_screen.dart';

/// Clearance so scrolling content finishes above the floating tab bar.
const double bankTabClearance = 112;

/// The four TestFlight tabs. Screens are the existing card, list, and
/// type pieces composed the way the build already ships them.
class BankApp extends StatefulWidget {
  const BankApp({super.key});

  @override
  State<BankApp> createState() => _BankAppState();
}

class _BankAppState extends State<BankApp> {
  int _index = 0;

  void _go(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colors.background,
        body: Stack(
          children: [
            IndexedStack(
              index: _index,
              children: [
                HomeScreen(onOpenRewards: () => _go(1)),
                const RewardsScreen(),
                const CardScreen(),
                const AccountScreen(),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _TabBar(index: _index, onSelected: _go),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.index, required this.onSelected});

  final int index;
  final ValueChanged<int> onSelected;

  static const _items = [
    (icon: VeraAssets.tabHome, label: 'Home'),
    (icon: VeraAssets.tabRewards, label: 'Rewards'),
    (icon: VeraAssets.tabCard, label: 'Card'),
    (icon: VeraAssets.tabAccount, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.white,
          borderRadius: BorderRadius.circular(VeraRadii.pill),
          boxShadow: [
            BoxShadow(
              color: colors.chromeShadow,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _Tab(
                    icon: _items[i].icon,
                    label: _items[i].label,
                    selected: i == index,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 56,
        decoration: BoxDecoration(
          color: selected ? colors.navSelection : Colors.transparent,
          borderRadius: BorderRadius.circular(VeraRadii.pill),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VeraSvg(icon, size: 22, color: colors.navActive),
            const SizedBox(height: 2),
            Text(label, style: context.type.tab),
          ],
        ),
      ),
    );
  }
}

class BankSectionHeader extends StatelessWidget {
  const BankSectionHeader({
    super.key,
    required this.title,
    this.suffix,
    this.showChevron = false,
    this.onTap,
  });

  final String title;
  final String? suffix;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Flexible(
              child: Text(
                title,
                style: context.type.h3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 4),
              Text(
                suffix!,
                style: context.type.h3.copyWith(
                  color: colors.textPrimary.withValues(alpha: 0.5),
                ),
              ),
            ],
            const Spacer(),
            if (showChevron) const VeraSvg(VeraAssets.chevron, size: 24),
          ],
        ),
      ),
    );
  }
}
