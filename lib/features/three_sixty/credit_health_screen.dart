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
      child: Align(
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
                style: context.type.h3.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: VeraSpacing.s8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  MockDataCapsule.creditSubline,
                  textAlign: TextAlign.center,
                  style: context.type.p1,
                ),
              ),
              const SizedBox(height: VeraSpacing.s24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: VeraSpacing.s8),
                child: _TimeframeSelector(
                  selectedIndex: _timeframeIndex,
                  onSelected: (i) => setState(() => _timeframeIndex = i),
                ),
              ),
              const SizedBox(height: VeraSpacing.s8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: VeraSpacing.page),
                child: _ScoreChart(score: MockDataCapsule.creditScore),
              ),
              const SizedBox(height: VeraSpacing.s16),
              Center(
                child: VeraSvg(
                  ThreeSixtyAssets.transunionLogo,
                  width: 120,
                  height: 24,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
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
    final t = ((score - min) / (max - min)).clamp(0.0, 1.0);

    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.35,
            child: VeraSvg(
              ThreeSixtyAssets.gaugeTrack,
              width: 225,
              height: 225,
              color: colors.borderMuted,
            ),
          ),
          CustomPaint(
            size: const Size(225, 225),
            painter: _ScoreArcPainter(
              progress: t,
              track: colors.success.withValues(alpha: 0.12),
              fill: colors.success,
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
                  Icon(Icons.arrow_drop_up, color: colors.success, size: 16),
                  Icon(
                    Icons.arrow_drop_down,
                    color: colors.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 48,
            bottom: 36,
            child: Text('$min', style: context.type.p2),
          ),
          Positioned(
            right: 48,
            bottom: 36,
            child: Text('$max', style: context.type.p2),
          ),
        ],
      ),
    );
  }
}

class _ScoreArcPainter extends CustomPainter {
  _ScoreArcPainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  final double progress;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const stroke = 14.0;
    const start = math.pi * 0.75;
    const sweep = math.pi * 1.5;

    final rect = Rect.fromCircle(center: center, radius: size.width / 2 - stroke);
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep, false, trackPaint);

    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, start, sweep * progress, false, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _ScoreArcPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      track != oldDelegate.track ||
      fill != oldDelegate.fill;
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
                        ? colors.headerPrimary
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
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(
              12,
              (_) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0.5),
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: colors.borderMuted.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 28),
              child: VeraSvg(
                ThreeSixtyAssets.creditHealthWave,
                color: colors.success,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 48,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              color: colors.success,
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
