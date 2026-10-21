import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/mock_data_capsule.dart';
import 'package:project360/core/widgets/three_sixty_assets.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/features/three_sixty/capsule_shell.dart';

/// Credit Health gauge score green (Figma 32/Semi Bold on node 46:6077).
const Color _scoreInk = Color(0xFF008556);
const Color _gaugeGlow = Color(0xFF7FDB69);
const Color _chartGreen = Color(0xFF62A348);
const Color _mutedInk = Color(0xFF8E8E8E);
const Color _faintInk = Color(0xFFA3A3A3);
const Color _gridLine = Color(0xFFF0F0F0);
const Color _chartGrid = Color(0xFFE8E8E8);

class CreditHealthScreen extends StatefulWidget {
  const CreditHealthScreen({super.key});

  @override
  State<CreditHealthScreen> createState() => _CreditHealthScreenState();
}

class _CreditHealthScreenState extends State<CreditHealthScreen> {
  var _timeframeIndex = 2;
  var _dialClaimExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final bottom = MediaQuery.paddingOf(context).bottom + capsuleTabClearance;
    final chartSeries =
        MockDataCapsule.chartSeriesForTimeframeIndex(_timeframeIndex);
    final delta = chartSeries.delta;
    final gaugeScore = _dialClaimExpanded
        ? MockDataCapsule.creditClaimDialScore
        : chartSeries.latestScore;

    return ColoredBox(
      color: colors.white,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const Positioned(
              top: 56,
              left: 0,
              right: 0,
              height: 280,
              child: IgnorePointer(child: CustomPaint(painter: _GraphPaperPainter())),
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
                    _ScoreGauge(
                      score: gaugeScore,
                      onCenterTap: () => setState(
                        () => _dialClaimExpanded = !_dialClaimExpanded,
                      ),
                    ),
                    const SizedBox(height: VeraSpacing.s12),
                    Text(
                      _dialClaimExpanded
                          ? MockDataCapsule.creditClaimHeadline
                          : MockDataCapsule.creditHeadline,
                      textAlign: TextAlign.center,
                      style: context.type.h2.copyWith(
                        fontSize: 20,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: colors.headerPrimary,
                      ),
                    ),
                    const SizedBox(height: VeraSpacing.s8),
                    Center(
                      child: SizedBox(
                        width: _dialClaimExpanded ? 339 : 230,
                        child: Text(
                          _dialClaimExpanded
                              ? MockDataCapsule.creditClaimSubline
                              : 'Your credit score has ${delta >= 0 ? 'increased' : 'decreased'} by '
                                    '${delta.abs()} points over '
                                    '${MockDataCapsule.scoreTimeframes[_timeframeIndex].toLowerCase()}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: VeraTypography.geist,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 20 / 14,
                            color: _mutedInk,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: VeraSpacing.s24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _TimeframeSelector(
                        selectedIndex: _timeframeIndex,
                        onSelected: (i) => setState(() => _timeframeIndex = i),
                      ),
                    ),
                    const SizedBox(height: VeraSpacing.s16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _ScoreChart(timeframeIndex: _timeframeIndex),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GraphPaperPainter extends CustomPainter {
  const _GraphPaperPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _gridLine
      ..strokeWidth = 1;
    const step = 32.0;
    for (var x = step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = step; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Figma Credit Health gauge (node 46:6038) — 225×225 dial geometry.
abstract final class _GaugeFigma {
  static const canvasW = 225.0;
  static const canvasH = 228.0;

  /// 300 mark (7 o'clock) through 850 (5 o'clock), clockwise over the top.
  static const startAngle = 122 * math.pi / 180;
  static const totalSweep = 293 * math.pi / 180;

  /// Angular span of the exported progress wedge at score 784.
  static const referenceScore = 784;
  static const progressWedgeSweep = 184 * math.pi / 180;

  static const progressInset = 5.0;
  static const progressSize = 215.0;
  static const progressHub = Offset(
    progressInset + progressSize / 2,
    progressInset + progressSize / 2,
  );

  static double wedgeSweepRadians(int score) {
    final min = MockDataCapsule.creditScoreMin;
    final max = MockDataCapsule.creditScoreMax;
    final clamped = score.clamp(min, max);
    if (clamped <= referenceScore) {
      final t = (clamped - min) / (referenceScore - min);
      return progressWedgeSweep * t;
    }
    final t = (clamped - referenceScore) / (max - referenceScore);
    return progressWedgeSweep + (totalSweep - progressWedgeSweep) * t;
  }

  static Offset progressTip(int score, {double radiusScale = 0.93}) {
    final angle = startAngle + wedgeSweepRadians(score);
    final r = (progressSize / 2) * radiusScale;
    return progressHub + Offset(r * math.cos(angle), r * math.sin(angle));
  }
}

class _ScoreGauge extends StatelessWidget {
  const _ScoreGauge({
    required this.score,
    required this.onCenterTap,
  });

  final int score;
  final VoidCallback onCenterTap;

  @override
  Widget build(BuildContext context) {
    final min = MockDataCapsule.creditScoreMin;
    final max = MockDataCapsule.creditScoreMax;
    const glowW = 20.595;
    const glowH = 26.676;
    final glowLeft = score == _GaugeFigma.referenceScore
        ? 162.356
        : _GaugeFigma.progressTip(score).dx - glowW / 2;
    final glowTop = score == _GaugeFigma.referenceScore
        ? 39.554
        : _GaugeFigma.progressTip(score).dy - glowH / 2;

    return Center(
      child: SizedBox(
        width: _GaugeFigma.canvasW,
        height: _GaugeFigma.canvasH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Layer: outer track (Ellipse 271)
            const VeraSvg(
              ThreeSixtyAssets.gaugeTrack,
              width: _GaugeFigma.canvasW,
              height: _GaugeFigma.canvasW,
            ),
            // Layer: mint background arc (Ellipse 274)
            const Positioned(
              top: 0,
              left: 0,
              child: VeraSvg(
                ThreeSixtyAssets.gaugeArc,
                width: _GaugeFigma.canvasW,
                height: 205.558,
                fit: BoxFit.fill,
              ),
            ),
            // Layer: gradient progress wedge (Ellipse 275), clipped to score
            Positioned(
              left: _GaugeFigma.progressInset,
              top: _GaugeFigma.progressInset,
              width: _GaugeFigma.progressSize,
              height: _GaugeFigma.progressSize,
              child: ClipPath(
                clipper: _GaugeWedgeClipper(
                  center: _GaugeFigma.progressHub,
                  startAngle: _GaugeFigma.startAngle,
                  sweepAngle: _GaugeFigma.wedgeSweepRadians(score),
                ),
                child: const VeraSvg(
                  ThreeSixtyAssets.gaugeProgress,
                  width: _GaugeFigma.progressSize,
                  height: _GaugeFigma.progressSize,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // Layer: leading-edge glow (Rectangle 3)
            Positioned(
              left: glowLeft,
              top: glowTop,
              child: Container(
                width: glowW,
                height: glowH,
                decoration: const BoxDecoration(
                  color: _gaugeGlow,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
            // Layer: tick marks (Ellipse 273 strokes @ 10%)
            const Positioned(
              left: 38,
              top: 38,
              width: 148,
              height: 118,
              child: Opacity(
                opacity: 0.1,
                child: Image(
                  image: AssetImage(ThreeSixtyAssets.gaugeTicksMain),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const Positioned(
              left: 88.26,
              top: 161.27,
              width: 68.311,
              height: 26.734,
              child: Opacity(
                opacity: 0.1,
                child: Image(
                  image: AssetImage(ThreeSixtyAssets.gaugeTicksBottomLeft),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const Positioned(
              left: 67.43,
              top: 161.27,
              width: 9.683,
              height: 12.751,
              child: Opacity(
                opacity: 0.1,
                child: Image(
                  image: AssetImage(ThreeSixtyAssets.gaugeTicksBottomCenter),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            // Layer: center hub (Ellipse 272) — tap toggles claim report state
            Positioned(
              left: 52,
              top: 53,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onCenterTap,
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const VeraSvg(
                        ThreeSixtyAssets.gaugeCenter,
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      Positioned(
                        left: 30,
                        top: 35,
                        width: 61,
                        child: Text(
                          '$score',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: VeraTypography.geist,
                            fontWeight: FontWeight.w600,
                            fontSize: 32,
                            height: 38 / 32,
                            color: _scoreInk,
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 43,
                        top: 79,
                        child: VeraSvg(
                          ThreeSixtyAssets.gaugeArrowUp,
                          width: 16,
                          height: 16,
                        ),
                      ),
                      const Positioned(
                        left: 61,
                        top: 91,
                        child: VeraSvg(
                          ThreeSixtyAssets.gaugeArrowDown,
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 25,
              top: 209,
              child: Text(
                '$min',
                style: const TextStyle(
                  fontFamily: VeraTypography.geist,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 16 / 12,
                  color: _mutedInk,
                ),
              ),
            ),
            Positioned(
              left: 180,
              top: 212,
              child: Text(
                '$max',
                style: const TextStyle(
                  fontFamily: VeraTypography.geist,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  height: 16 / 12,
                  color: _mutedInk,
                ),
              ),
            ),
            const Positioned(
              left: 81,
              top: 189,
              child: VeraSvg(
                ThreeSixtyAssets.transunionLogo,
                width: 61.272,
                height: 16,
                color: _mutedInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugeWedgeClipper extends CustomClipper<Path> {
  const _GaugeWedgeClipper({
    required this.center,
    required this.startAngle,
    required this.sweepAngle,
  });

  final Offset center;
  final double startAngle;
  final double sweepAngle;

  @override
  Path getClip(Size size) {
    if (sweepAngle <= 0) {
      return Path();
    }
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: size.longestSide),
        startAngle,
        sweepAngle,
        false,
      )
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _GaugeWedgeClipper oldClipper) =>
      oldClipper.startAngle != startAngle ||
      oldClipper.sweepAngle != sweepAngle ||
      oldClipper.center != center;
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
      height: 36,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.navSurface,
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
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? colors.headerPrimary : Colors.transparent,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Text(
                    MockDataCapsule.scoreTimeframes[i],
                    style: TextStyle(
                      fontFamily: VeraTypography.geist,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      height: 16 / 12,
                      color: i == selectedIndex ? colors.white : _mutedInk,
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

class _ScoreChart extends StatefulWidget {
  const _ScoreChart({required this.timeframeIndex});

  final int timeframeIndex;

  @override
  State<_ScoreChart> createState() => _ScoreChartState();
}

class _ScoreChartState extends State<_ScoreChart>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 420);

  late final AnimationController _zoom;
  late int _fromIndex;
  late int _toIndex;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.timeframeIndex;
    _toIndex = widget.timeframeIndex;
    _zoom = AnimationController(vsync: this, duration: _duration);
  }

  @override
  void didUpdateWidget(covariant _ScoreChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeframeIndex == widget.timeframeIndex) return;
    _fromIndex = oldWidget.timeframeIndex;
    _toIndex = widget.timeframeIndex;
    _zoom.forward(from: 0);
  }

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetSeries = MockDataCapsule.chartSeriesForTimeframeIndex(
      widget.timeframeIndex,
    );
    final fromSeries = MockDataCapsule.chartSeriesForTimeframeIndex(_fromIndex);
    final toSeries = MockDataCapsule.chartSeriesForTimeframeIndex(_toIndex);

    return SizedBox(
      height: 168,
      child: AnimatedBuilder(
        animation: _zoom,
        builder: (context, _) {
          final t = Curves.easeInOutCubic.transform(_zoom.value);
          final fromMonths = MockDataCapsule.monthsForTimeframeIndex(_fromIndex);
          final toMonths = MockDataCapsule.monthsForTimeframeIndex(_toIndex);
          final monthsBack = fromMonths + (toMonths - fromMonths) * t;
          final ySpanMonths = math.max(fromMonths, toMonths).toDouble();

          return Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight;
                    final viewport = _ChartViewport.months(
                      monthsBack: monthsBack,
                      ySpanMonths: ySpanMonths,
                      history: MockDataCapsule.creditScoreHistory,
                      anchor: MockDataCapsule.creditScoreAnchorMonth,
                    );
                    final last = viewport.unitPoints.last;
                    final badge = _chartPoint(last, width, height);
                    return ClipRect(
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          CustomPaint(
                            size: Size(width, height),
                            painter: _HistoryChartPainter(
                              unitPoints: viewport.unitPoints,
                            ),
                          ),
                          Positioned(
                            left: badge.dx - 18,
                            top: badge.dy - 10,
                            child: Container(
                              width: 36,
                              height: 20,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _chartGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${targetSeries.latestScore}',
                                style: const TextStyle(
                                  fontFamily: VeraTypography.geist,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  height: 1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 12,
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 1 - t,
                      child: _AxisLabelsRow(labels: fromSeries.axisLabels),
                    ),
                    Opacity(
                      opacity: t,
                      child: _AxisLabelsRow(labels: toSeries.axisLabels),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AxisLabelsRow extends StatelessWidget {
  const _AxisLabelsRow({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final month in labels)
          Expanded(
            child: Text(
              month,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: VeraTypography.geist,
                fontWeight: FontWeight.w400,
                fontSize: 10,
                height: 12 / 10,
                color: _faintInk,
              ),
            ),
          ),
      ],
    );
  }
}

/// Maps monthly history into chart space for an animated time window.
class _ChartViewport {
  _ChartViewport._({required this.unitPoints});

  final List<Offset> unitPoints;

  factory _ChartViewport.months({
    required double monthsBack,
    required double ySpanMonths,
    required List<CreditScorePoint> history,
    required DateTime anchor,
  }) {
    final span = monthsBack.clamp(1, history.length.toDouble());
    final ySpan = ySpanMonths.clamp(1, history.length.toDouble());
    final visible = history.where((p) {
      final before = _monthsBeforeAnchor(p.month, anchor);
      return before >= 0 && before <= span;
    }).toList();

    if (visible.length < 2) {
      return _ChartViewport._(
        unitPoints: const [Offset(0, 0.5), Offset(1, 0.5)],
      );
    }

    final yWindow = history.where((p) {
      final before = _monthsBeforeAnchor(p.month, anchor);
      return before >= 0 && before <= ySpan;
    });
    var minScore = yWindow.map((p) => p.score).reduce(math.min);
    var maxScore = yWindow.map((p) => p.score).reduce(math.max);
    if (minScore == maxScore) {
      minScore -= 20;
      maxScore += 20;
    } else {
      final pad = ((maxScore - minScore) * 0.12).round().clamp(8, 40);
      minScore -= pad;
      maxScore += pad;
    }

    final points = <Offset>[
      for (final p in visible)
        Offset(
          1 - _monthsBeforeAnchor(p.month, anchor) / span,
          1 - (p.score - minScore) / (maxScore - minScore),
        ),
    ];

    return _ChartViewport._(unitPoints: points);
  }

  static int _monthsBeforeAnchor(DateTime month, DateTime anchor) {
    return (anchor.year - month.year) * 12 + (anchor.month - month.month);
  }
}

Offset _chartPoint(Offset unit, double width, double height) {
  const topPad = 14.0;
  const bottomPad = 16.0;
  return Offset(
    unit.dx * width,
    topPad + unit.dy * (height - topPad - bottomPad),
  );
}

class _HistoryChartPainter extends CustomPainter {
  const _HistoryChartPainter({required this.unitPoints});

  final List<Offset> unitPoints;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = _chartGrid
      ..strokeWidth = 1;
    for (var i = 0; i <= 12; i++) {
      final x = size.width * i / 12;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    canvas.drawLine(Offset(0, size.height - 0.5), Offset(size.width, size.height - 0.5), grid);

    final path = Path();
    for (var i = 0; i < unitPoints.length; i++) {
      final p = _chartPoint(unitPoints[i], size.width, size.height);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = _chartGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.butt
        ..strokeJoin = StrokeJoin.miter,
    );
  }

  @override
  bool shouldRepaint(covariant _HistoryChartPainter oldDelegate) =>
      oldDelegate.unitPoints != unitPoints;
}
