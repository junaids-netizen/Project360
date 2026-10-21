import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/mock_data.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:project360/features/home/bank_format.dart';
import 'package:project360/features/home/bank_shell.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + bankTabClearance;

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              VeraSpacing.page,
              VeraSpacing.s8,
              VeraSpacing.page,
              bottom,
            ),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              Text(
                'Rewards',
                textAlign: TextAlign.center,
                style: context.type.h3,
              ),
              const SizedBox(height: VeraSpacing.s16),
              const _PointsCard(),
              const SizedBox(height: VeraSpacing.s8),
              const _ProgramHeader(),
              const _ProgramCard(),
              const SizedBox(height: VeraSpacing.s8),
              const BankSectionHeader(title: 'Activity', showChevron: true),
              const _ActivityList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final points = groupedInt(MockData.rewardsPoints);
    final number = TextStyle(
      fontFamily: VeraTypography.geist,
      fontWeight: FontWeight.w600,
      fontSize: 36,
      height: 1.1,
      letterSpacing: -0.72,
      color: colors.darkGradient[1],
    );

    return VeraCapsule(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: points, style: number),
                      TextSpan(
                        text: ' points',
                        style: number.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 28,
                          color: colors.darkGradient.last,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: VeraSpacing.s8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: Haptics.wrap(() {}),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Redeem now', style: context.type.h4),
                      const SizedBox(width: 2),
                      const VeraSvg(VeraAssets.chevron, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const VeraSvg(VeraAssets.rewardsSparkle, size: 56),
        ],
      ),
    );
  }
}

class _ProgramHeader extends StatelessWidget {
  const _ProgramHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Text('Program', style: context.type.h3),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: Haptics.wrap(() {}),
            child: Row(
              children: [
                Text(
                  'Change',
                  style: context.type.h4.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(width: 2),
                VeraSvg(VeraAssets.chevron, size: 20, color: colors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VeraRadii.card),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            for (final color in colors.programGlow) color.withValues(alpha: 0.28),
          ],
        ),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MockData.programName,
                  style: TextStyle(
                    fontFamily: VeraTypography.denton,
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                    height: 1,
                    color: colors.headerPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(MockData.programSubtitle, style: context.type.p1),
              ],
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Rate(label: 'Purchases'),
              SizedBox(height: VeraSpacing.s12),
              _Rate(label: 'Payments'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Rate extends StatelessWidget {
  const _Rate({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('1x', style: context.type.h4),
            const SizedBox(width: 4),
            const VeraSvg(VeraAssets.rewardsSparkle, size: 16),
          ],
        ),
        Text(label, style: context.type.p2),
      ],
    );
  }
}

class _ActivityList extends StatelessWidget {
  const _ActivityList();

  @override
  Widget build(BuildContext context) {
    return VeraCapsule(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        children: [
          for (final txn in MockData.rewardsStatement) _ActivityRow(txn: txn),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.txn});

  final VeraTransaction txn;

  @override
  Widget build(BuildContext context) {
    final points = txn.points ?? 0;
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          const VeraSvg(VeraAssets.rewardsSparkle, size: 28),
          const SizedBox(width: VeraSpacing.s12),
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
          Text('$points', style: context.type.h4),
        ],
      ),
    );
  }
}
