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
const Color _insightBodyInk = Color(0xFF808080);
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
    const bottom = capsuleTabScrollGap;
    final chartSeries =
        MockDataCapsule.chartSeriesForTimeframeIndex(_timeframeIndex);
    final delta = chartSeries.delta;
    final gaugeScore = _dialClaimExpanded
        ? MockDataCapsule.creditClaimDialScore
        : chartSeries.latestScore;

    const heroHeight = 56.0 + VeraSpacing.s8 + _GaugeFigma.canvasH;

    return ColoredBox(
      color: colors.white,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                SizedBox(
                  height: heroHeight,
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      const Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(painter: _GraphPaperPainter()),
                        ),
                      ),
                      Column(
                        children: [
                          const CapsuleHeader(),
                          const SizedBox(height: VeraSpacing.s8),
                          _ScoreGauge(
                            score: gaugeScore,
                            onCenterTap: () => setState(
                              () => _dialClaimExpanded = !_dialClaimExpanded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: bottom),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    children: [
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
                    const SizedBox(height: VeraSpacing.s24),
                      const _InsightsForYouSection(),
                      const _CreditHealthDisclaimer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightsForYouSection extends StatelessWidget {
  const _InsightsForYouSection();

  static const _rowTitleStyle = TextStyle(
    fontFamily: VeraTypography.geist,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 20 / 14,
    color: Color(0xFF222222),
  );

  static const _rowBodyStyle = TextStyle(
    fontFamily: VeraTypography.geist,
    fontWeight: FontWeight.w500,
    fontSize: 12,
    height: 16 / 12,
    color: _insightBodyInk,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final insights = MockDataCapsule.creditInsights;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            height: 48,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Insights for you',
                      style: TextStyle(
                        fontFamily: VeraTypography.geist,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 24 / 16,
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: VeraSvg(VeraAssets.chevron, size: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
        for (var i = 0; i < insights.length; i++) ...[
          _InsightRow(
            insight: insights[i],
            titleStyle: _rowTitleStyle,
            bodyStyle: _rowBodyStyle,
          ),
          if (i < insights.length - 1)
            Padding(
              padding: const EdgeInsets.only(left: 56, right: VeraSpacing.s16),
              child: Divider(height: 1, thickness: 1, color: colors.borderMuted),
            ),
        ],
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.insight,
    required this.titleStyle,
    required this.bodyStyle,
  });

  final CreditInsight insight;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            ThreeSixtyAssets.insightIcon,
            width: 56,
            height: 56,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(insight.body, style: bodyStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditHealthDisclaimer extends StatelessWidget {
  const _CreditHealthDisclaimer();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MockDataCapsule.creditVantageDisclaimer,
            style: context.type.p2.copyWith(color: _insightBodyInk),
          ),
          const SizedBox(height: 19),
          Text.rich(
            TextSpan(
              style: context.type.p2.copyWith(color: colors.textPrimary),
              children: [
                const TextSpan(
                  text: 'Want to learn more about credit scores? ',
                ),
                TextSpan(
                  text: 'Visit FAQs',
                  style: context.type.p2.copyWith(
                    color: colors.textPrimary,
                    decoration: TextDecoration.underline,
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
  static const startAngle = 124.5 * math.pi / 180;
  static const totalSweep = 289.5 * math.pi / 180;

  /// Angular span of the exported progress wedge at score 784.
  static const referenceScore = 784;
  static const progressWedgeSweep = 181.7 * math.pi / 180;

  static const progressInset = 5.0;
  static const progressSize = 215.0;

  /// Hub + score + arrows (nodes 46:6076–46:6086).
  static const hubLeft = 52.0;
  static const hubTop = 53.0;
  static const hubSize = 120.0;
  static const scoreLeft = 82.0;
  // Figma places the text box at y=88 in Inter; Geist sits ~1.3pt higher in
  // the same box, so it is nudged down to land the digits on Figma's.
  static const scoreTop = 89.3;
  static const scoreWidth = 61.0;
  static const arrowWidth = 13.8564;
  static const arrowHeight = 12.0;
  static const arrowUpLeft = 96.07;
  static const arrowUpTop = 132.0;
  static const arrowDownLeft = 114.0;
  static const arrowDownTop = 132.0;

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
              fit: BoxFit.fill,
            ),
            // Layer: mint background arc (Ellipse 274). Its export is cropped
            // to 225×205.558, so it must keep that height or it stretches.
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
            // Layer: gradient progress (Ellipse 275)
            Positioned(
              top: 0,
              left: 0,
              width: _GaugeFigma.canvasW,
              height: _GaugeFigma.canvasW,
              child: CustomPaint(
                painter: _GaugeProgressPainter(
                  sweepRadians: _GaugeFigma.wedgeSweepRadians(score),
                ),
              ),
            ),
            // Layer: tick marks (Ellipse 273)
            const Positioned(
              top: 0,
              left: 0,
              width: _GaugeFigma.canvasW,
              height: _GaugeFigma.canvasW,
              child: IgnorePointer(
                child: CustomPaint(painter: _GaugeTicksPainter()),
              ),
            ),
            // Layer: needle (Rectangle 3)
            Positioned(
              top: 0,
              left: 0,
              width: _GaugeFigma.canvasW,
              height: _GaugeFigma.canvasW,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GaugeNeedlePainter(
                    angle: _GaugeFigma.startAngle +
                        _GaugeFigma.wedgeSweepRadians(score),
                  ),
                ),
              ),
            ),
            // Layer: center hub (Ellipse 272, feDropShadow dy=4 blur=5 α=8%)
            Positioned(
              left: _GaugeFigma.hubLeft,
              top: _GaugeFigma.hubTop,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onCenterTap,
                child: Container(
                  width: _GaugeFigma.hubSize,
                  height: _GaugeFigma.hubSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE6E6E6)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        // Flutter sigma = 0.577 × radius + 0.5; 7.8 → σ 5.
                        blurRadius: 7.8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: _GaugeFigma.scoreLeft,
              top: _GaugeFigma.scoreTop,
              width: _GaugeFigma.scoreWidth,
              child: IgnorePointer(
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
            ),
            const Positioned(
              left: _GaugeFigma.arrowUpLeft,
              top: _GaugeFigma.arrowUpTop,
              child: IgnorePointer(
                child: VeraSvg(
                  ThreeSixtyAssets.gaugeArrowUp,
                  width: _GaugeFigma.arrowWidth,
                  height: _GaugeFigma.arrowHeight,
                ),
              ),
            ),
            Positioned(
              left: _GaugeFigma.arrowDownLeft,
              top: _GaugeFigma.arrowDownTop,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: math.pi,
                  child: const VeraSvg(
                    ThreeSixtyAssets.gaugeArrowDown,
                    width: _GaugeFigma.arrowWidth,
                    height: _GaugeFigma.arrowHeight,
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

const Offset _gaugeHub = Offset(_GaugeFigma.canvasW / 2, _GaugeFigma.canvasW / 2);

/// Pie-slice progress (Ellipse 275) in the Figma 225×225 dial space; it sits
/// 5pt inside the mint arc, so a sliver of mint shows beyond the fill.
class _GaugeProgressPainter extends CustomPainter {
  const _GaugeProgressPainter({required this.sweepRadians});

  final double sweepRadians;

  static const _hub = _gaugeHub;
  static const _outerRadius = _GaugeFigma.progressSize / 2;

  // gauge_progress.svg gradient runs (172,16) → (40,102.5) in its own
  // coordinates, which share the origin and scale of the 215pt progress box.
  static const _gradBox = _GaugeFigma.progressSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (sweepRadians <= 0) {
      return;
    }

    final arcRect = Rect.fromCircle(center: _hub, radius: _outerRadius);
    final wedge = Path()
      ..moveTo(_hub.dx, _hub.dy)
      ..arcTo(arcRect, _GaugeFigma.startAngle, sweepRadians, false)
      ..close();

    final gradRect = Rect.fromLTWH(
      _GaugeFigma.progressInset,
      _GaugeFigma.progressInset,
      _GaugeFigma.progressSize,
      _GaugeFigma.progressSize,
    );
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment(
          (172 / _gradBox) * 2 - 1,
          (16 / _gradBox) * 2 - 1,
        ),
        end: Alignment(
          (40 / _gradBox) * 2 - 1,
          (102.5 / _gradBox) * 2 - 1,
        ),
        colors: const [Color(0xFF0C7C1E), Color(0xFF7FDB69)],
      ).createShader(gradRect);

    canvas.drawPath(wedge, fill);
  }

  @override
  bool shouldRepaint(covariant _GaugeProgressPainter oldDelegate) =>
      oldDelegate.sweepRadians != sweepRadians;
}

/// 15 radial ticks every 18°, from 144° round to 36° (0° points right),
/// drawn over both the fill and the mint track. Inner ends run under the hub.
class _GaugeTicksPainter extends CustomPainter {
  const _GaugeTicksPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1F222222)
      ..strokeWidth = 1;
    for (var k = -7; k <= 7; k++) {
      final a = (270 + 18 * k) * math.pi / 180;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(_gaugeHub + dir * 55, _gaugeHub + dir * 73.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugeTicksPainter oldDelegate) => false;
}

/// Needle (Rectangle 3): a thin round-ended radial bar on the leading edge of
/// the progress wedge, sitting mostly inside the fill. Its inner end runs
/// under the hub, so only the outer ~28pt shows.
class _GaugeNeedlePainter extends CustomPainter {
  const _GaugeNeedlePainter({required this.angle});

  final double angle;

  static const _width = 3.2;
  static const _innerRadius = 50.0;
  static const _outerRadius = 86.4;
  static const _insetFromEdge = 0.9;

  @override
  void paint(Canvas canvas, Size size) {
    final dir = Offset(math.cos(angle), math.sin(angle));
    final back = Offset(math.sin(angle), -math.cos(angle)) * _insetFromEdge;
    canvas.drawLine(
      _gaugeHub + dir * _innerRadius + back,
      _gaugeHub + dir * _outerRadius + back,
      Paint()
        ..color = _gaugeGlow
        ..strokeWidth = _width
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeNeedlePainter oldDelegate) =>
      oldDelegate.angle != angle;
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
