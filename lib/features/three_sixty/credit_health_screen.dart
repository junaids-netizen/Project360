import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/mock_data_capsule.dart';
import 'package:project360/core/widgets/three_sixty_assets.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/features/three_sixty/capsule_shell.dart';

/// Credit-score illustration greens from the Credit Health frame.
///
/// [BrandColors.success] stays the status green for the rest of the app, but
/// it is a much darker forest than this gauge, score, and history line.
const Color _scoreInk = Color(0xFF50805B);
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

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final bottom = MediaQuery.paddingOf(context).bottom + capsuleTabClearance;

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
                    _ScoreGauge(score: MockDataCapsule.creditScore),
                    const SizedBox(height: VeraSpacing.s12),
                    Text(
                      MockDataCapsule.creditHeadline,
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
                        width: 230,
                        child: Text(
                          MockDataCapsule.creditSubline,
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
                      child: _ScoreChart(score: MockDataCapsule.creditScore),
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

class _GaugeMetrics {
  _GaugeMetrics(Size size)
      : cx = size.width / 2,
        outer = math.min(size.width * 0.284, 116) {
    stroke = outer * 0.46;
    whiteR = outer * 0.56;
    cy = outer + 4;
  }

  final double cx;
  final double outer;
  late final double stroke;
  late final double whiteR;
  late final double cy;

  static const startTurns = 122 * math.pi / 180;
  static const sweepTurns = 293 * math.pi / 180;

  Offset tip(double angle, {double radiusScale = 1}) {
    final r = outer * radiusScale;
    return Offset(cx + r * math.cos(angle), cy + r * math.sin(angle));
  }
}

class _ScoreGauge extends StatelessWidget {
  const _ScoreGauge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final min = MockDataCapsule.creditScoreMin;
    final max = MockDataCapsule.creditScoreMax;

    return SizedBox(
      height: 250,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final m = _GaugeMetrics(Size(constraints.maxWidth, constraints.maxHeight));
          final leftTip = m.tip(_GaugeMetrics.startTurns);
          final rightTip = m.tip(_GaugeMetrics.startTurns + _GaugeMetrics.sweepTurns);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _CreditGaugePainter(m),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: m.cy - 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(
                        fontFamily: VeraTypography.geist,
                        fontWeight: FontWeight.w600,
                        fontSize: 36,
                        height: 1,
                        color: _scoreInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const VeraSvg(
                          ThreeSixtyAssets.gaugeArrowUp,
                          width: 10,
                          height: 8,
                          color: _scoreInk,
                        ),
                        const SizedBox(width: 3),
                        Transform.rotate(
                          angle: math.pi,
                          child: const VeraSvg(
                            ThreeSixtyAssets.gaugeArrowDown,
                            width: 10,
                            height: 8,
                            color: Color(0xFFD0D0D0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: m.cy + m.whiteR + 6,
                child: const Center(
                  child: VeraSvg(
                    ThreeSixtyAssets.transunionLogo,
                    width: 68,
                    height: 18,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
              ),
              Positioned(
                left: leftTip.dx - 36,
                top: leftTip.dy + 6,
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
                left: rightTip.dx - 2,
                top: rightTip.dy + 6,
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
            ],
          );
        },
      ),
    );
  }
}

class _CreditGaugePainter extends CustomPainter {
  const _CreditGaugePainter(this.metrics);

  final _GaugeMetrics metrics;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(metrics.cx, metrics.cy);
    final ringRadius = metrics.outer - metrics.stroke / 2;
    final rect = Rect.fromCircle(center: center, radius: ringRadius);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = metrics.stroke
      ..strokeCap = StrokeCap.butt
      ..shader = SweepGradient(
        startAngle: _GaugeMetrics.startTurns,
        endAngle: _GaugeMetrics.startTurns + _GaugeMetrics.sweepTurns,
        colors: const [
          Color(0xFFB7E08C),
          Color(0xFF8FCB62),
          Color(0xFF6FA34C),
          Color(0xFF568C3A),
          Color(0xFF4C8634),
          Color(0xFFD7F3C8),
          Color(0xFFEFFBE8),
        ],
        stops: const [0.0, 0.18, 0.38, 0.52, 0.60, 0.70, 1.0],
      ).createShader(rect);

    canvas.drawArc(rect, _GaugeMetrics.startTurns, _GaugeMetrics.sweepTurns, false, arc);

    final tick = Paint()
      ..color = const Color(0x66FFFFFF)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    const ticks = 34;
    for (var i = 0; i < ticks; i++) {
      final t = _GaugeMetrics.startTurns +
          _GaugeMetrics.sweepTurns * (i / (ticks - 1));
      final inner = metrics.outer - metrics.stroke + 3;
      final outer = inner + 9;
      canvas.drawLine(
        Offset(center.dx + inner * math.cos(t), center.dy + inner * math.sin(t)),
        Offset(center.dx + outer * math.cos(t), center.dy + outer * math.sin(t)),
        tick,
      );
    }

    final shadow = Paint()
      ..color = const Color(0x1A000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(center.translate(0, 10), metrics.whiteR, shadow);
    canvas.drawCircle(center, metrics.whiteR, Paint()..color = const Color(0xFFFFFFFF));
  }

  @override
  bool shouldRepaint(covariant _CreditGaugePainter oldDelegate) =>
      oldDelegate.metrics.outer != metrics.outer ||
      oldDelegate.metrics.cx != metrics.cx;
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

/// Twelve vertices of the history polyline, in the frame's viewBox.
/// X is the fraction across the twelve month columns (the trailing grid
/// line is the right edge, with no vertex on it). Y is top-to-bottom.
const List<Offset> _historyPoints = [
  Offset(0 / 12, 30.0125 / 61.9483),
  Offset(1 / 12, 15.0125 / 61.9483),
  Offset(2 / 12, 28.0125 / 61.9483),
  Offset(3 / 12, 15.0125 / 61.9483),
  Offset(4 / 12, 60.258 / 61.9483),
  Offset(5 / 12, 23.0125 / 61.9483),
  Offset(6 / 12, 28.0125 / 61.9483),
  Offset(7 / 12, 1.51255 / 61.9483),
  Offset(8 / 12, 48.1578 / 61.9483),
  Offset(9 / 12, 19.1578 / 61.9483),
  Offset(10 / 12, 57.5125 / 61.9483),
  Offset(11 / 12, 3.98567 / 61.9483),
];

class _ScoreChart extends StatelessWidget {
  const _ScoreChart({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                final last = _historyPoints.last;
                final point = _chartPoint(last, width, height);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomPaint(
                      size: Size(width, height),
                      painter: const _HistoryChartPainter(),
                    ),
                    Positioned(
                      left: point.dx - 18,
                      top: point.dy - 10,
                      child: Container(
                        width: 36,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _chartGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$score',
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
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final month in MockDataCapsule.scoreChartMonths)
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
          ),
        ],
      ),
    );
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
  const _HistoryChartPainter();

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
    for (var i = 0; i < _historyPoints.length; i++) {
      final p = _chartPoint(_historyPoints[i], size.width, size.height);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
