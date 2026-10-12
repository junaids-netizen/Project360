import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_colors.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/mock_data_capsule.dart';
import 'package:project360/core/widgets/three_sixty_assets.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/features/home/bank_format.dart';
import 'package:project360/features/three_sixty/capsule_shell.dart';
import 'package:project360/features/three_sixty/manage_card_screen.dart';

/// Figma **Family Hub** section (`208:11570`), primary frame `29:10784`.
class FamilyHubScreen extends StatefulWidget {
  const FamilyHubScreen({super.key});

  @override
  State<FamilyHubScreen> createState() => _FamilyHubScreenState();
}

class _FamilyHubScreenState extends State<FamilyHubScreen> {
  var _selectedMember = 0;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + capsuleTabClearance;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              const CapsuleHeader(),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FamilyRail(
                      selectedIndex: _selectedMember,
                      onSelected: (i) {
                        Haptics.selection();
                        setState(() => _selectedMember = i);
                      },
                    ),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.only(
                          left: VeraSpacing.s16,
                          right: VeraSpacing.page,
                          bottom: bottom,
                        ),
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        children: [
                          const SizedBox(height: VeraSpacing.s16),
                          _FamilyCardFace(
                            memberName: MockDataCapsule
                                .familyMembers[_selectedMember]
                                .name,
                          ),
                          const SizedBox(height: VeraSpacing.s16),
                          const _FamilyBalanceBar(),
                          const SizedBox(height: VeraSpacing.s8),
                          const _FamilyTransactionsSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FamilyRail extends StatelessWidget {
  const _FamilyRail({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _itemHeight = 61.0;
  static const _gap = 24.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final members = MockDataCapsule.familyMembers;
    final indicatorTop = 16 + selectedIndex * (_itemHeight + _gap);

    return SizedBox(
      width: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.white,
              border: Border(right: BorderSide(color: colors.borderMuted)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  for (var i = 0; i < members.length; i++) ...[
                    if (i > 0) const SizedBox(height: _gap),
                    _FamilyRailItem(
                      label: members[i].name,
                      avatarAsset: members[i].avatarAsset,
                      selected: i == selectedIndex,
                      onTap: () => onSelected(i),
                    ),
                  ],
                  const SizedBox(height: _gap),
                  _FamilyRailAdd(onTap: () => Haptics.light()),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: indicatorTop,
            child: Container(
              width: 4,
              height: _itemHeight,
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyRailItem extends StatelessWidget {
  const _FamilyRailItem({
    required this.label,
    required this.avatarAsset,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String avatarAsset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final ink = selected ? colors.accent : colors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                avatarAsset,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: VeraTypography.geist,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 12,
                height: 15 / 12,
                color: ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyRailAdd extends StatelessWidget {
  const _FamilyRailAdd({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
              ),
              child: VeraSvg(
                ThreeSixtyAssets.iconPlus,
                width: 24,
                height: 24,
                color: colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: VeraTypography.geist,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                height: 15 / 12,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyCardFace extends StatelessWidget {
  const _FamilyCardFace({required this.memberName});

  final String memberName;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(VeraRadii.card),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: () {
                Haptics.light();
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const ManageCardScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Manage card',
                  style: TextStyle(
                    fontFamily: VeraTypography.geist,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 16 / 12,
                    color: colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: colors.white, width: 2),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                BrandScope.of(context).brand.name.toUpperCase(),
                style: TextStyle(
                  fontFamily: VeraTypography.geist,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                  height: 24 / 16,
                  letterSpacing: 0.64,
                  color: colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: VeraSvg(
              ThreeSixtyAssets.visaWordmark,
              width: 64,
              height: 20,
              color: colors.white,
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memberName.toUpperCase(),
                  style: TextStyle(
                    fontFamily: VeraTypography.geist,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: 1.92,
                    color: colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '••••',
                      style: TextStyle(
                        fontFamily: VeraTypography.geist,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 1.6,
                        color: colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      MockDataCapsule.cardLast4,
                      style: TextStyle(
                        fontFamily: VeraTypography.geist,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: 1.6,
                        color: colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    VeraSvg(VeraAssets.eye, size: 18, color: colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyBalanceBar extends StatelessWidget {
  const _FamilyBalanceBar();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final used = MockDataCapsule.familyUsed;
    final available = MockDataCapsule.familyAvailable;
    final total = used + available;
    final usedFraction = used / total;
    final usedBar = colors.progressGradient.first;
    final availableBar = colors.success;

    return Column(
      children: [
        Row(
          children: [
            _LegendDot(color: usedBar),
            const SizedBox(width: 4),
            Text(
              'Used',
              style: context.type.h4.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            VeraSvg(
              ThreeSixtyAssets.chevronRightSm,
              size: 16,
              color: colors.textPrimary,
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${groupedInt(used.round())}',
              style: context.type.h1.copyWith(
                fontSize: 28,
                height: 36 / 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _LegendDot(color: availableBar),
            const SizedBox(width: 4),
            Text(
              '\$${groupedInt(available.round())} Available',
              style: context.type.p2,
            ),
          ],
        ),
        const SizedBox(height: VeraSpacing.s8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                Expanded(
                  flex: (usedFraction * 1000).round().clamp(1, 999),
                  child: ColoredBox(color: usedBar),
                ),
                Expanded(
                  flex: ((1 - usedFraction) * 1000).round().clamp(1, 999),
                  child: ColoredBox(color: availableBar),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: VeraSpacing.s8),
        _ProcessingPaymentStrip(colors: colors),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      color: color,
    );
  }
}

class _ProcessingPaymentStrip extends StatelessWidget {
  const _ProcessingPaymentStrip({required this.colors});

  final BrandColors colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.paymentStripBorder),
        ),
        image: const DecorationImage(
          image: AssetImage(ThreeSixtyAssets.paymentStripBg),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 9, 6, 9),
        child: Row(
          children: [
            VeraSvg(
              ThreeSixtyAssets.iconPaymentCoin,
              width: 14,
              height: 15,
              color: colors.textPrimary,
            ),
            const SizedBox(width: 7),
            Text(
              '\$${groupedInt(MockDataCapsule.familyPaymentAmount.round())} payment',
              style: context.type.p2,
            ),
            const Spacer(),
            _TxnStatusBadge(
              label: 'PROCESSING',
              foreground: colors.warning,
              background: colors.warning.withValues(alpha: 0.04),
              icon: ThreeSixtyAssets.iconHourglass,
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyTransactionsSection extends StatelessWidget {
  const _FamilyTransactionsSection();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: VeraSpacing.s8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Recent transactions',
                  style: context.type.h4.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                'SEE ALL',
                style: context.type.p2.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  height: 12 / 10,
                  letterSpacing: 0.2,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        for (final txn in MockDataCapsule.familyTransactions)
          _FamilyTxnRow(txn: txn),
      ],
    );
  }
}

class _FamilyTxnRow extends StatelessWidget {
  const _FamilyTxnRow({required this.txn});

  final CapsuleTransaction txn;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final amount = groupedInt(txn.amount.round());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VeraSpacing.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.67),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: colors.textPrimary, width: 1.2),
                borderRadius: BorderRadius.circular(6.67),
              ),
              child: Image.asset(
                ThreeSixtyAssets.merchantUber,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: VeraSpacing.s16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.merchant, style: context.type.h4),
                Row(
                  children: [
                    Text(txn.date, style: context.type.p2),
                    Text(
                      ' • ',
                      style: context.type.p2.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        height: 12 / 10,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(txn.time, style: context.type.p2),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$$amount', style: context.type.h4),
              if (txn.status != null) ...[
                const SizedBox(height: 4),
                _TxnStatusBadge.fromStatus(context, txn.status!),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TxnStatusBadge extends StatelessWidget {
  const _TxnStatusBadge({
    required this.label,
    required this.foreground,
    required this.background,
    required this.icon,
  });

  factory _TxnStatusBadge.fromStatus(
    BuildContext context,
    CapsuleTxnStatus status,
  ) {
    final colors = context.brand;
    return switch (status) {
      CapsuleTxnStatus.pending => _TxnStatusBadge(
          label: 'PENDING',
          foreground: colors.info,
          background: colors.info.withValues(alpha: 0.04),
          icon: ThreeSixtyAssets.iconHourglass,
        ),
      CapsuleTxnStatus.declined => _TxnStatusBadge(
          label: 'DECLINED',
          foreground: colors.danger,
          background: colors.danger.withValues(alpha: 0.04),
          icon: ThreeSixtyAssets.iconCircleOff,
        ),
    };
  }

  final String label;
  final Color foreground;
  final Color background;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          VeraSvg(icon, width: 10, height: 10, color: foreground),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: VeraTypography.geist,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              height: 12 / 10,
              letterSpacing: 0.2,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
