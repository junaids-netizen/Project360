import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/mock_data_capsule.dart';
import 'package:project360/core/widgets/three_sixty_assets.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_card.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/home/bank_format.dart';
import 'package:project360/features/three_sixty/capsule_shell.dart';
import 'package:project360/features/three_sixty/manage_card_screen.dart';

class MyCardsScreen extends StatelessWidget {
  const MyCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + capsuleTabClearance;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: EdgeInsets.only(bottom: bottom),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: const [
              CapsuleHeader(),
              SizedBox(height: VeraSpacing.s8),
              _CardCarousel(),
              SizedBox(height: VeraSpacing.s16),
              _UsageBar(),
              SizedBox(height: VeraSpacing.s8),
              _PaymentSection(),
              _RecentTransactionsSection(),
              _StatementsRow(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardCarousel extends StatelessWidget {
  const _CardCarousel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: VeraSpacing.page),
        itemCount: 2,
        separatorBuilder: (context, index) =>
            const SizedBox(width: VeraSpacing.s12),
        itemBuilder: (context, index) => const _CapsuleCardFace(),
      ),
    );
  }
}

class _CapsuleCardFace extends StatelessWidget {
  const _CapsuleCardFace();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return Container(
      width: 320,
      height: 180,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VeraSvg(
                ThreeSixtyAssets.logomark,
                width: 30,
                height: 30,
                color: colors.white,
              ),
              const Spacer(),
              VeraSvg(
                ThreeSixtyAssets.visaWordmark,
                width: 64,
                height: 20,
                color: colors.white,
              ),
            ],
          ),
          const Spacer(),
          Text(
            MockDataCapsule.cardholderName,
            style: TextStyle(
              fontFamily: VeraTypography.geist,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '•••• ${MockDataCapsule.cardLast4}',
                style: TextStyle(
                  fontFamily: VeraTypography.geistMono,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 1.2,
                  color: colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 8),
              VeraSvg(VeraAssets.eye, size: 18, color: colors.white),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: Haptics.wrap(() {
                final brandController = BrandScope.read(context);
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => BrandScope(
                      controller: brandController,
                      child: const ManageCardScreen(),
                    ),
                  ),
                );
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(VeraRadii.card),
                ),
                child: Text(
                  'Manage',
                  style: TextStyle(
                    fontFamily: VeraTypography.geist,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageBar extends StatelessWidget {
  const _UsageBar();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final used = MockDataCapsule.amountUsed;
    final available = MockDataCapsule.amountAvailable;
    final total = used + available;
    final usedFraction = used / total;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VeraSpacing.page),
      child: Column(
        children: [
          Row(
            children: [
              _UsageLegend(
                color: colors.accent,
                label: '\$${groupedInt(used.round())} used',
              ),
              const Spacer(),
              _UsageLegend(
                color: colors.success,
                label: '\$${groupedInt(available.round())} available',
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
                    child: ColoredBox(color: colors.accent),
                  ),
                  Expanded(
                    flex: ((1 - usedFraction) * 1000).round().clamp(1, 999),
                    child: CustomPaint(
                      painter: _SuccessHatchPainter(
                        base: colors.success,
                        hatch: colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsageLegend extends StatelessWidget {
  const _UsageLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: context.type.p2),
      ],
    );
  }
}

class _SuccessHatchPainter extends CustomPainter {
  _SuccessHatchPainter({required this.base, required this.hatch});

  final Color base;
  final Color hatch;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = base);
    final line = Paint()
      ..color = hatch
      ..strokeWidth = 1;
    const step = 6.0;
    for (var x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        line,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SuccessHatchPainter oldDelegate) =>
      base != oldDelegate.base || hatch != oldDelegate.hatch;
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection();

  @override
  Widget build(BuildContext context) {
    final dueWhole = groupedInt(MockDataCapsule.dueAmount.round());
    final minDue = groupedInt(MockDataCapsule.minimumDue.round());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: VeraSpacing.page),
      child: VeraCapsule(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Due amount', style: context.type.p2),
                  const SizedBox(height: 4),
                  VeraSplitAmount(
                    whole: dueWhole,
                    cents: '',
                    large: true,
                    showCents: false,
                  ),
                  const SizedBox(height: 4),
                  Text('\$$minDue minimum', style: context.type.p2),
                ],
              ),
            ),
            const SizedBox(width: VeraSpacing.s12),
            _PayNowButton(
              onTap: () {
                Haptics.light();
              },
              badgeLabel: MockDataCapsule.payBadgeLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class _PayNowButton extends StatelessWidget {
  const _PayNowButton({required this.onTap, required this.badgeLabel});

  final VoidCallback onTap;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: -10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colors.badge,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              badgeLabel,
              style: TextStyle(
                fontFamily: VeraTypography.geist,
                fontWeight: FontWeight.w600,
                fontSize: 10,
                height: 12 / 10,
                letterSpacing: 0.2,
                color: colors.white,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 140,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(VeraRadii.card),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors.buttonGradient,
                stops: const [0.0136, 0.7134, 0.985],
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.buttonShadow,
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Pay now',
                  style: context.type.button.copyWith(
                    fontSize: 16,
                    color: colors.onColor(colors.buttonGradient[1]),
                  ),
                ),
                Text(
                  'OR SCHEDULE',
                  style: TextStyle(
                    fontFamily: VeraTypography.geist,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    height: 12 / 10,
                    letterSpacing: 0.4,
                    color: colors.onColor(colors.buttonGradient[1])
                        .withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VeraSectionTitle(
          title: 'Recent transactions',
          trailing: Text(
            'SEE ALL',
            style: context.type.p2.copyWith(
              fontWeight: FontWeight.w600,
              color: context.brand.textSecondary,
            ),
          ),
          showChevron: true,
        ),
        for (final txn in MockDataCapsule.recentTransactions)
          _CapsuleTxnRow(txn: txn),
      ],
    );
  }
}

class _CapsuleTxnRow extends StatelessWidget {
  const _CapsuleTxnRow({required this.txn});

  final CapsuleTransaction txn;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final amount = groupedInt(txn.amount.round());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: VeraSpacing.page,
            vertical: VeraSpacing.s12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  ThreeSixtyAssets.merchantUber,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
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
                        Text(' • ', style: context.type.p2),
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
                  const SizedBox(height: 4),
                  _CashbackBadge(amount: txn.cashback),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 72, right: VeraSpacing.page),
          child: Divider(height: 1, thickness: 1, color: colors.border),
        ),
      ],
    );
  }
}

class _CashbackBadge extends StatelessWidget {
  const _CashbackBadge({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final label = '+${amount.toStringAsFixed(2)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          VeraSvg(
            ThreeSixtyAssets.cashbackDollar,
            size: 10,
            color: colors.success,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: VeraTypography.geist,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              height: 12 / 10,
              letterSpacing: 0.2,
              color: colors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatementsRow extends StatelessWidget {
  const _StatementsRow();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        VeraSpacing.page,
        VeraSpacing.s8,
        VeraSpacing.page,
        VeraSpacing.s16,
      ),
      child: GestureDetector(
        onTap: Haptics.wrap(() {}),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            VeraSvg(
              ThreeSixtyAssets.receiptText,
              size: 24,
              color: colors.textPrimary,
            ),
            const SizedBox(width: VeraSpacing.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('View statements', style: context.type.h4),
                  Text(
                    'Generates on the 6th of each month',
                    style: context.type.p2,
                  ),
                ],
              ),
            ),
            VeraSvg(VeraAssets.chevron, size: 24, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
