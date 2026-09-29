import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project360/app/theme/brand.dart';
import 'package:project360/app/theme/brand_colors.dart';

/// The Figma palette this prototype was drawn against, before theming existed.
///
/// Deriving Vera's own colours from its seed has to land on these exact values,
/// otherwise introducing the brand layer quietly restyled the design it was
/// supposed to leave alone.
const Map<String, int> _figmaPalette = {
  'textPrimary': 0xFF0B0037,
  'textSecondary': 0xA60B0037,
  'textTertiary': 0x400B0037,
  'headerPrimary': 0xFF121212,
  'white': 0xFFFFFFFF,
  'background': 0xFFFAFAFA,
  'border': 0xFFF0F0F0,
  'surfaceMuted': 0xFFF8F8F9,
  'borderMuted': 0xFFE7E8EA,
  'cardSurface': 0xFF2F1A5D,
  'navActive': 0xFF150051,
  'badge': 0xFFCC4B0E,
  'accent': 0xFF7D5EF9,
  'accentSecondary': 0xFF00B9D6,
  'success': 0xFF006328,
  'warning': 0xFFE06C00,
  'danger': 0xFFCC4B0E,
  'cardShadow': 0x99F2F2F2,
  'sliderThumb': 0xFF2F1569,
};

const Map<String, List<int>> _figmaRamps = {
  'darkGradient': [0xFF291063, 0xFF7B54D3, 0xFFBDB0DC],
  'buttonGradient': [0xFF291063, 0xFF8458E8, 0xFFA68CE4],
  'progressGradient': [0xFFCEB7FF, 0xFF6020DB],
  'pointsGlow': [0xFF38ACFF, 0xFF94A6FF, 0xFF4838FF],
};

void main() {
  final colors = veraBrand.resolve();

  Map<String, Color> flat() => {
    'textPrimary': colors.textPrimary,
    'textSecondary': colors.textSecondary,
    'textTertiary': colors.textTertiary,
    'headerPrimary': colors.headerPrimary,
    'white': colors.white,
    'background': colors.background,
    'border': colors.border,
    'surfaceMuted': colors.surfaceMuted,
    'borderMuted': colors.borderMuted,
    'cardSurface': colors.cardSurface,
    'navActive': colors.navActive,
    'badge': colors.badge,
    'accent': colors.accent,
    'accentSecondary': colors.accentSecondary,
    'success': colors.success,
    'warning': colors.warning,
    'danger': colors.danger,
    'cardShadow': colors.cardShadow,
    'sliderThumb': colors.sliderThumb,
  };

  Map<String, List<Color>> ramps() => {
    'darkGradient': colors.darkGradient,
    'buttonGradient': colors.buttonGradient,
    'progressGradient': colors.progressGradient,
    'pointsGlow': colors.pointsGlow,
  };

  test('Vera derives back to its original Figma palette', () {
    flat().forEach((name, color) {
      expect(
        color.toARGB32(),
        _figmaPalette[name],
        reason: '$name drifted from the Figma value',
      );
    });
  });

  test('Vera derives back to its original Figma gradients', () {
    ramps().forEach((name, ramp) {
      expect(
        ramp.map((c) => c.toARGB32()).toList(),
        _figmaRamps[name],
        reason: '$name drifted from the Figma ramp',
      );
    });
  });

  test('ink on an accent fill stays legible for any brand', () {
    for (final brand in brandPresets) {
      final resolved = brand.resolve();
      final ink = resolved.onColor(resolved.accent);
      final contrast = (ink.computeLuminance() + 0.05) /
          (resolved.accent.computeLuminance() + 0.05);
      final ratio = contrast < 1 ? 1 / contrast : contrast;
      expect(
        ratio,
        greaterThan(3.0),
        reason: '${brand.name} accent does not carry its chosen ink',
      );
    }
  });

  test('neutrals and status colours do not follow the brand', () {
    for (final brand in brandPresets) {
      final resolved = brand.resolve();
      expect(resolved.background, colors.background);
      expect(resolved.border, colors.border);
      expect(resolved.success, colors.success);
      expect(resolved.danger, colors.danger);
    }
  });

  test('a light brand seed still yields a dark, legible card', () {
    final pale = BrandColors.fromSeed(const Color(0xFFFFE27A));
    expect(pale.cardSurface.computeLuminance(), lessThan(0.2));
    expect(pale.onColor(pale.cardSurface), pale.white);
  });
}
