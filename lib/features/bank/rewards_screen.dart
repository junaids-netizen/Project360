import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/mock_data.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/bank/bank_format.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final ink = colors.onColor(colors.pointsGlow[1]);
    final bottom = bankTabBottomInset(MediaQuery.paddingOf(context).bottom);

    return ColoredBox(
      color: colors.background,
      child: ListView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottom),
        children: [
          Text('Rewards', style: context.type.h2),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(VeraRadii.card),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors.pointsGlow,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MockData.programName,
                  style: context.type.h3.copyWith(color: ink),
                ),
                Text(
                  MockData.programSubtitle,
                  style: context.type.p1.copyWith(
                    color: ink.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${MockData.rewardsPoints}',
                  style: TextStyle(
                    fontFamily: VeraTypography.denton,
                    fontWeight: FontWeight.w700,
                    fontSize: 48,
                    height: 1,
                    color: ink,
                  ),
                ),
                Text('points', style: context.type.p1.copyWith(color: ink)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const VeraSectionTitle(title: 'This statement'),
          VeraCapsule(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                for (final txn in MockData.rewardsStatement)
                  _PointsRow(txn: txn),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsRow extends StatelessWidget {
  const _PointsRow({required this.txn});

  final VeraTransaction txn;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final points = txn.points ?? 0;
    final earned = points >= 0;
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          VeraSvg(
            earned ? VeraAssets.rewardsEarned : VeraAssets.rewardsRedeemed,
            size: 24,
            color: colors.textPrimary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txn.title, style: context.type.h4),
                Text(txn.date, style: context.type.p2),
              ],
            ),
          ),
          Text(
            '${earned ? '+' : ''}$points',
            style: context.type.h4.copyWith(
              color: earned ? colors.success : colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
