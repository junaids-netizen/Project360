import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/mock_data_capsule.dart';
import 'package:project360/core/widgets/three_sixty_assets.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/features/three_sixty/capsule_shell.dart';

class CreditHealthScreen extends StatefulWidget {
  const CreditHealthScreen({super.key});

  @override
  State<CreditHealthScreen> createState() => _CreditHealthScreenState();
}

class _CreditHealthScreenState extends State<CreditHealthScreen> {
  var _timeframeIndex = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final bottom = MediaQuery.paddingOf(context).bottom + capsuleTabClearance;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 330,
            child: IgnorePointer(
              child: Row(
                children: [
                  Expanded(
                    child: Opacity(
                      opacity: 0.5,
                      child: Transform.rotate(
                        angle: math.pi,
                        child: Transform.flip(
                          flipY: true,
                          child: Image.asset(
                            ThreeSixtyAssets.creditHealthBgTile,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Opacity(
                      opacity: 0.5,
                      child: Transform.rotate(
                        angle: math.pi,
                        child: Transform.flip(
                          flipY: true,
                          child: Image.asset(
                            ThreeSixtyAssets.creditHealthBgTile,
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                padding: EdgeInsets.only(bottom: bottom),
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                children: [
                  const CapsuleHeader(),
                  const SizedBox(height: VeraSpacing.s8),
                  _ScoreGauge(score: MockDataCapsule.creditScore),
                  const SizedBox(height: VeraSpacing.s16),
                  Text(
                    MockDataCapsule.creditHeadline,
                    textAlign: TextAlign.center,
                    style: context.type.h2.copyWith(
                      fontSize: 20,
                      height: 24 / 20,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: VeraSpacing.s8),
                  Center(
                    child: SizedBox(
                      width: 227,
                      child: Text(
                        MockDataCapsule.creditSubline,
                        textAlign: TextAlign.center,
                        style: context.type.p1.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: VeraSpacing.s24),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VeraSpacing.s8,
                    ),
                    child: _TimeframeSelector(
                      selectedIndex: _timeframeIndex,
                      onSelected: (i) => setState(() => _timeframeIndex = i),
                    ),
                  ),
                  const SizedBox(height: VeraSpacing.s8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: VeraSpacing.page,
                    ),
                    child: _ScoreChart(score: MockDataCapsule.creditScore),
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

class _ScoreGauge extends StatelessWidget {
  const _ScoreGauge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final min = MockDataCapsule.creditScoreMin;
    final max = MockDataCapsule.creditScoreMax;

    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Opacity(
            opacity: 0.5,
            child: VeraSvg(
              ThreeSixtyAssets.gaugeTrack,
              width: 225,
              height: 225,
            ),
          ),
          VeraSvg(
            ThreeSixtyAssets.gaugeArc,
            width: 225,
            height: 205.558,
          ),
          VeraSvg(
            ThreeSixtyAssets.gaugeProgress,
            width: 215,
            height: 195.802,
          ),
          Positioned(
            bottom: 52,
            child: VeraSvg(
              ThreeSixtyAssets.transunionLogo,
              width: 61,
              height: 16,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontFamily: VeraTypography.geist,
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                  height: 38 / 32,
                  color: colors.success,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VeraSvg(
                    ThreeSixtyAssets.gaugeArrowUp,
                    width: 14,
                    height: 12,
                    color: colors.success,
                  ),
                  const SizedBox(width: 4),
                  VeraSvg(
                    ThreeSixtyAssets.gaugeArrowDown,
                    width: 14,
                    height: 12,
                    color: colors.borderMuted,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 48,
            bottom: 36,
            child: Text(
              '$min',
              style: context.type.p2.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Positioned(
            right: 48,
            bottom: 36,
            child: Text(
              '$max',
              style: context.type.p2.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeframeSelector extends StatelessWidget {
  const _TimeframeSelector({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.borderMuted.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          for (var i = 0; i < MockDataCapsule.scoreTimeframes.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? colors.textPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    MockDataCapsule.scoreTimeframes[i],
                    style: TextStyle(
                      fontFamily: VeraTypography.geist,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 16 / 12,
                      color: i == selectedIndex
                          ? colors.white
                          : colors.textSecondary,
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

class _ScoreChart extends StatelessWidget {
  const _ScoreChart({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return SizedBox(
      height: 173,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 135,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.borderMuted.withValues(alpha: 0.85)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                13,
                (index) => Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: colors.borderMuted.withValues(
                            alpha: index == 0 || index == 12 ? 1.0 : 0.7,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 23,
            height: 59,
            child: VeraSvg(
              ThreeSixtyAssets.creditHealthWave,
              color: colors.success,
            ),
          ),
          Positioned(
            right: 0,
            top: 48,
            child: ColoredBox(
              color: colors.success,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Text(
                  '$score',
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
            left: 6,
            right: 0,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final m in MockDataCapsule.scoreChartMonths)
                  Text(
                    m,
                    style: TextStyle(
                      fontFamily: VeraTypography.geist,
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      height: 12 / 10,
                      letterSpacing: 0.2,
                      color: colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
