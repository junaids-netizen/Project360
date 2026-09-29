import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/haptics.dart';
import 'package:project360/core/mock_data.dart';
import 'package:project360/core/widgets/vera_assets.dart';

class VeraCardFace extends StatefulWidget {
  const VeraCardFace({
    super.key,
    this.height = 120,
    this.revealed = true,
    this.showBrand = true,
    this.showCvv = false,
    this.frozen = false,
    this.onSettings,
  });

  final double height;
  final bool revealed;
  final bool showBrand;
  final bool showCvv;
  final bool frozen;
  final VoidCallback? onSettings;

  @override
  State<VeraCardFace> createState() => _VeraCardFaceState();
}

class _VeraCardFaceState extends State<VeraCardFace>
    with SingleTickerProviderStateMixin {
  late final AnimationController _freeze;
  late final Animation<double> _frostGrow;
  late final Animation<double> _frostOpacity;
  late final Animation<double> _details;
  late final Animation<double> _last4;
  late final Animation<double> _banner;

  /// CVV and expiry stay masked until the eye is tapped. Independent of
  /// [VeraCardFace.revealed], which only controls the card number.
  bool _secretsRevealed = false;

  @override
  void initState() {
    super.initState();
    _freeze = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
      reverseDuration: const Duration(milliseconds: 620),
    );
    _frostGrow = CurvedAnimation(
      parent: _freeze,
      curve: const Interval(0.0, 0.82, curve: Curves.easeOutCubic),
      reverseCurve: Curves.easeIn,
    );
    _frostOpacity = CurvedAnimation(
      parent: _freeze,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );
    _details = CurvedAnimation(
      parent: _freeze,
      curve: const Interval(0.08, 0.42, curve: Curves.easeOut),
      reverseCurve: const Interval(0.45, 1.0, curve: Curves.easeIn),
    );
    _last4 = CurvedAnimation(
      parent: _freeze,
      curve: const Interval(0.28, 0.62, curve: Curves.easeOut),
      reverseCurve: const Interval(0.35, 0.75, curve: Curves.easeIn),
    );
    _banner = CurvedAnimation(
      parent: _freeze,
      curve: const Interval(0.42, 1.0, curve: Curves.easeOutCubic),
      reverseCurve: const Interval(0.0, 0.55, curve: Curves.easeIn),
    );
    if (widget.frozen) _freeze.value = 1;
  }

  @override
  void didUpdateWidget(covariant VeraCardFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.frozen == oldWidget.frozen) return;
    if (widget.frozen) {
      _secretsRevealed = false;
      _freeze.forward();
    } else {
      _freeze.reverse();
    }
  }

  void _toggleSecrets() {
    Haptics.selection();
    setState(() => _secretsRevealed = !_secretsRevealed);
  }

  @override
  void dispose() {
    _freeze.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final panStyle = TextStyle(
      fontFamily: VeraTypography.geistMono,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 20 / 16,
      letterSpacing: -0.32,
      color: colors.onColor(colors.cardSurface),
    );

    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(VeraRadii.card),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: _freeze,
        builder: (context, _) {
          final grow = _frostGrow.value;
          final frost = _frostOpacity.value;
          final hideDetails = _details.value;
          final last4 = _last4.value;
          final banner = _banner.value;

          return Stack(
            children: [
              Positioned(
                left: -67,
                top: -30,
                child: Opacity(
                  opacity: 0.10,
                  child: Image.asset(
                    VeraAssets.cardPattern,
                    width: 204,
                    height: 204,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Opacity(
                opacity: 1 - hideDetails,
                child: IgnorePointer(
                  ignoring: hideDetails > 0.6,
                  child: _CardDetails(
                    revealed: widget.revealed,
                    secretsRevealed: _secretsRevealed,
                    onToggleSecrets: _toggleSecrets,
                    showBrand: widget.showBrand,
                    showCvv: widget.showCvv,
                    onSettings: widget.onSettings,
                    panStyle: panStyle,
                  ),
                ),
              ),
              if (frost > 0)
                Opacity(
                  opacity: 0.22 * frost,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: colors.frostOverlay,
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              if (grow > 0) _FrostBloom(progress: grow, opacity: 0.5 * frost),
              if (last4 > 0)
                Positioned(
                  left: 16,
                  top: 16,
                  child: Opacity(
                    opacity: last4,
                    child: Text(
                      '• • • •  ${MockData.cardLast4}',
                      style: panStyle,
                    ),
                  ),
                ),
              if (banner > 0)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: Opacity(
                    opacity: banner,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - banner)),
                      child: const _FrozenBanner(),
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

class _CardDetails extends StatelessWidget {
  const _CardDetails({
    required this.revealed,
    required this.secretsRevealed,
    required this.onToggleSecrets,
    required this.showBrand,
    required this.showCvv,
    required this.onSettings,
    required this.panStyle,
  });

  final bool revealed;
  final bool secretsRevealed;
  final VoidCallback onToggleSecrets;
  final bool showBrand;
  final bool showCvv;
  final VoidCallback? onSettings;
  final TextStyle panStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, showBrand ? 12 : 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const VeraSvg(VeraAssets.logo, width: 44, height: 16),
              if (showBrand) ...[
                const SizedBox(width: 11),
                Container(
                  width: 1,
                  height: 29,
                  color: context.brand.cardDivider,
                ),
                const SizedBox(width: 11),
                const VeraSvg(
                  VeraAssets.mastercard,
                  width: 32,
                  height: 26,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onSettings,
                  child: const VeraSvg(VeraAssets.settings, size: 16),
                ),
                const SizedBox(width: 16),
              ] else
                const Spacer(),
              GestureDetector(
                onTap: onToggleSecrets,
                behavior: HitTestBehavior.opaque,
                child: Opacity(
                  opacity: secretsRevealed ? 1 : 0.6,
                  child: const VeraSvg(VeraAssets.eye, size: 16),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          revealed
                              ? '${MockData.cardFirst4} 4012 8859 ${MockData.cardLast4}'
                              : '${MockData.cardFirst4} •••• •••• ${MockData.cardLast4}',
                          maxLines: 1,
                          style: panStyle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const VeraSvg(VeraAssets.copy, size: 16),
                  ],
                ),
              ),
              if (showCvv) ...[
                _SecretValue(
                  masked: '•••',
                  value: MockData.cardCvv,
                  revealed: secretsRevealed,
                  style: panStyle,
                ),
                const SizedBox(width: 16),
              ],
              _SecretValue(
                masked: '••/••',
                value: MockData.cardExpiry,
                revealed: secretsRevealed,
                style: panStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Crossfades between the masked and real value. The monospace PAN style keeps
/// both strings the same width, so nothing reflows mid-fade.
class _SecretValue extends StatelessWidget {
  const _SecretValue({
    required this.masked,
    required this.value,
    required this.revealed,
    required this.style,
  });

  final String masked;
  final String value;
  final bool revealed;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Text(
        revealed ? value : masked,
        key: ValueKey(revealed),
        style: style,
      ),
    );
  }
}

class _FrostBloom extends StatelessWidget {
  const _FrostBloom({required this.progress, required this.opacity});

  final double progress;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final bloom = context.brand.frostBloom;
    return Opacity(
      opacity: opacity,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          return RadialGradient(
            center: const Alignment(0.92, -1.15),
            radius: 0.18 + progress * 2.15,
            colors: bloom,
            stops: const [0.0, 0.58, 1.0],
          ).createShader(bounds);
        },
        child: Transform.scale(
          scale: 1.14 - 0.14 * progress,
          alignment: const Alignment(0.8, -0.9),
          child: Image.asset(
            VeraAssets.frostTexture,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: const Alignment(0.15, -0.2),
          ),
        ),
      ),
    );
  }
}

class _FrozenBanner extends StatelessWidget {
  const _FrozenBanner();

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Row(
      children: [
        const VeraSvg(VeraAssets.frozenBadge, size: 20),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            'Card frozen. Recurring charges continue.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: VeraTypography.geist,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 22 / 16,
              letterSpacing: -0.32,
              color: colors.onColor(colors.cardSurface),
            ),
          ),
        ),
      ],
    );
  }
}

class VeraBalanceBar extends StatelessWidget {
  const VeraBalanceBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(VeraRadii.card),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: _SplitAmount(
                    whole: '4,500',
                    cents: '.88',
                    large: true,
                  ),
                ),
              ),
              SizedBox(width: 8),
              FittedBox(
                alignment: Alignment.centerRight,
                fit: BoxFit.scaleDown,
                child: _SplitAmount(
                  whole: '15,550',
                  cents: '.88',
                  large: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 4,
              child: Row(
                children: [
                  SizedBox(
                    width: 123,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors.progressGradient,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(child: ColoredBox(color: colors.border)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Current Balance',
                  style: context.type.p1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  'Available Credit',
                  style: context.type.p1,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplitAmount extends StatelessWidget {
  const _SplitAmount({
    required this.whole,
    required this.cents,
    required this.large,
  });

  final String whole;
  final String cents;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final dollar = TextStyle(
      fontFamily: VeraTypography.denton,
      fontWeight: FontWeight.w700,
      fontSize: large ? 30 : 16,
      height: 1,
      color: colors.textPrimary.withValues(alpha: 0.5),
    );
    final mainStyle = TextStyle(
      fontFamily: VeraTypography.denton,
      fontWeight: FontWeight.w700,
      fontSize: large ? 40 : 24,
      height: large ? 40 / 40 : 1,
    );
    final centsStyle = TextStyle(
      fontFamily: VeraTypography.denton,
      fontWeight: FontWeight.w200,
      fontSize: large ? 21 : 13,
      height: 1,
      color: colors.textSecondary,
    );

    Widget amount = Text(
      whole,
      style: mainStyle.copyWith(
        color: large ? colors.white : colors.textPrimary,
      ),
    );
    Widget dollarMark = Text('\$', style: dollar);
    if (large) {
      ShaderMask shade(Widget child) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors.darkGradient,
          stops: const [0.1875, 0.856, 0.968],
        ).createShader(bounds),
        child: child,
      );
      amount = shade(amount);
      dollarMark = Opacity(
        opacity: 0.5,
        child: shade(
          Text('\$', style: dollar.copyWith(color: colors.white)),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        dollarMark,
        const SizedBox(width: 2),
        amount,
        Padding(
          padding: EdgeInsets.only(bottom: large ? 4 : 2),
          child: Text(cents, style: centsStyle),
        ),
      ],
    );
  }
}
