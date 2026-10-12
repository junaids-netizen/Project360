import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/widgets/three_sixty_assets.dart';
import 'package:project360/core/widgets/vera_assets.dart' show VeraAssets, VeraSvg;

/// Scroll padding above the fixed Capsule tab bar (bar + home-indicator gap).
const double capsuleTabClearance = 98;

class CapsuleHeader extends StatelessWidget {
  const CapsuleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final brand = BrandScope.of(context).brand;

    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: VeraSpacing.page),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                ThreeSixtyAssets.avatar,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  VeraSvg(
                    ThreeSixtyAssets.logomark,
                    width: 28,
                    height: 28,
                    color: colors.accent,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      brand.name,
                      style: context.type.h3.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.36,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: VeraSvg(VeraAssets.bell, size: 24, color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class CapsuleTabBar extends StatelessWidget {
  const CapsuleTabBar({
    super.key,
    required this.index,
    required this.onSelected,
  });

  final int index;
  final ValueChanged<int> onSelected;

  static const _items = [
    (icon: ThreeSixtyAssets.tabMyCards, label: 'My Cards'),
    (icon: ThreeSixtyAssets.tabFamilyHub, label: 'Family Hub'),
    (icon: ThreeSixtyAssets.tabCreditHealth, label: 'Credit Health'),
    (icon: ThreeSixtyAssets.tabMerlin, label: 'Merlin'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.white,
            border: Border(top: BorderSide(color: colors.borderMuted)),
          ),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: _CapsuleTab(
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
        ColoredBox(
          color: colors.white,
          child: SizedBox(height: bottom > 0 ? bottom : 8),
        ),
      ],
    );
  }
}

class _CapsuleTab extends StatelessWidget {
  const _CapsuleTab({
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
    final ink = selected ? colors.accent : colors.textSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          VeraSvg(icon, size: 24, color: ink),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: VeraTypography.geist,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              height: 16 / 12,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}

class CapsulePlaceholderScreen extends StatelessWidget {
  const CapsulePlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final bottom = MediaQuery.paddingOf(context).bottom + capsuleTabClearance;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.only(bottom: bottom),
        children: [
          const CapsuleHeader(),
          SizedBox(
            height: 240,
            child: Center(
              child: Text(
                title,
                style: context.type.h2.copyWith(color: colors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
