import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_colors.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_metrics.dart';

/// Flat colour token ids for swatch grids (brand gallery + design system).
enum BrandColorToken {
  accent,
  accentSecondary,
  cardSurface,
  navActive,
  sliderThumb,
  frostTint,
  letterbox,
  textPrimary,
  textSecondary,
  textTertiary,
  headerPrimary,
  toastInk,
  sliderValueInk,
  white,
  background,
  border,
  surfaceMuted,
  borderMuted,
  navSurface,
  navSelection,
  badge,
  success,
  warning,
  danger;

  Color resolve(BrandColors c) => switch (this) {
    BrandColorToken.accent => c.accent,
    BrandColorToken.accentSecondary => c.accentSecondary,
    BrandColorToken.cardSurface => c.cardSurface,
    BrandColorToken.navActive => c.navActive,
    BrandColorToken.sliderThumb => c.sliderThumb,
    BrandColorToken.frostTint => c.frostTint,
    BrandColorToken.letterbox => c.letterbox,
    BrandColorToken.textPrimary => c.textPrimary,
    BrandColorToken.textSecondary => c.textSecondary,
    BrandColorToken.textTertiary => c.textTertiary,
    BrandColorToken.headerPrimary => c.headerPrimary,
    BrandColorToken.toastInk => c.toastInk,
    BrandColorToken.sliderValueInk => c.sliderValueInk,
    BrandColorToken.white => c.white,
    BrandColorToken.background => c.background,
    BrandColorToken.border => c.border,
    BrandColorToken.surfaceMuted => c.surfaceMuted,
    BrandColorToken.borderMuted => c.borderMuted,
    BrandColorToken.navSurface => c.navSurface,
    BrandColorToken.navSelection => c.navSelection,
    BrandColorToken.badge => c.badge,
    BrandColorToken.success => c.success,
    BrandColorToken.warning => c.warning,
    BrandColorToken.danger => c.danger,
  };
}

enum BrandGradientToken {
  dark,
  button,
  progress,
  pointsGlow,
  programGlow,
  wordmark;

  List<Color> resolve(BrandColors c) => switch (this) {
    BrandGradientToken.dark => c.darkGradient,
    BrandGradientToken.button => c.buttonGradient,
    BrandGradientToken.progress => c.progressGradient,
    BrandGradientToken.pointsGlow => c.pointsGlow,
    BrandGradientToken.programGlow => c.programGlow,
    BrandGradientToken.wordmark => c.wordmarkGradient,
  };
}

class BrandTokenHeading extends StatelessWidget {
  const BrandTokenHeading(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: VeraSpacing.s24,
        bottom: VeraSpacing.s8,
      ),
      child: Text(label, style: context.type.h3),
    );
  }
}

class BrandColorSwatchGrid extends StatelessWidget {
  const BrandColorSwatchGrid({super.key, required this.entries});

  final Map<String, BrandColorToken> entries;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final entry in entries.entries)
          SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: entry.value.resolve(colors),
                    borderRadius: BorderRadius.circular(VeraRadii.card),
                    border: Border.all(color: colors.border),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.key,
                  style: context.type.p2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class BrandGradientRampRow extends StatelessWidget {
  const BrandGradientRampRow({
    super.key,
    required this.label,
    required this.token,
  });

  final String label;
  final BrandGradientToken token;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: context.type.p2),
          ),
          Expanded(
            child: Container(
              height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: token.resolve(colors)),
                borderRadius: BorderRadius.circular(VeraRadii.card),
                border: Border.all(color: colors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
