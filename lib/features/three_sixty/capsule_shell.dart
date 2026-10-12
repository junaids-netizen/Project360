import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
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

    final frame = MediaQuery.sizeOf(context).width.clamp(0.0, 480.0);
    final labelMax = (frame - 168).clamp(72.0, 240.0);

    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    ThreeSixtyAssets.avatar,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const Spacer(),
                VeraSvg(
                  VeraAssets.bell,
                  size: 22,
                  color: colors.headerPrimary,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CapsuleBrandMark(color: colors.accent, size: 30),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: labelMax),
                  child: Text(
                    brand.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: VeraTypography.geist,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 26 / 20,
                      letterSpacing: -0.4,
                      color: colors.headerPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Two overlapping circles. Both discs use [color] (the active accent); the
/// lens where they cross is a darker shade of that same colour.
class CapsuleBrandMark extends StatelessWidget {
  const CapsuleBrandMark({super.key, required this.color, this.size = 30});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CapsuleBrandMarkPainter(color),
    );
  }
}

class _CapsuleBrandMarkPainter extends CustomPainter {
  _CapsuleBrandMarkPainter(this.color);

  final Color color;

  // Centres from assets/images/360/logomark.svg (29.333 view box).
  static const double _box = 29.3334;
  static const double _radius = 10.4762;
  static const double _front = 10.4762;
  static const double _back = 18.8572;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final r = s * (_radius / _box);
    final front = Offset(s * (_front / _box), s * (_front / _box));
    final back = Offset(s * (_back / _box), s * (_back / _box));
    final fill = Paint()..color = color;
    canvas.drawCircle(front, r, fill);
    canvas.drawCircle(back, r, fill);
    final lens = Paint()
      ..color = Color.lerp(color, const Color(0xFF000000), 0.5)!;
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: front, radius: r)),
    );
    canvas.drawCircle(back, r, lens);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CapsuleBrandMarkPainter oldDelegate) =>
      oldDelegate.color != color;
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
