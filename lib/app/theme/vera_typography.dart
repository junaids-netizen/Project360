import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_colors.dart';

/// Font families. Brand-independent for now; per-bank typefaces would become
/// another field on [BrandTheme] rather than a change to any call site.
abstract final class VeraTypography {
  static const String geist = 'Geist';
  static const String geistMono = 'Geist Mono';
  static const String denton = 'Denton';
}

/// The type ramp resolved against one brand's colours.
///
/// These are built per brand rather than held as `const`, because every style
/// carries ink that has to follow the active brand. Letting the styles go
/// colourless and inherit from `DefaultTextStyle` would appear to work but
/// would silently flatten the secondary and tertiary greys into primary ink.
@immutable
class VeraTextStyles {
  VeraTextStyles(BrandColors colors)
      : h1 = TextStyle(
          fontFamily: VeraTypography.geist,
          fontWeight: FontWeight.w500,
          fontSize: 32,
          height: 40 / 32,
          letterSpacing: -0.64,
          color: colors.textPrimary,
        ),
        h2 = TextStyle(
          fontFamily: VeraTypography.geist,
          fontWeight: FontWeight.w500,
          fontSize: 24,
          height: 40 / 24,
          letterSpacing: -0.48,
          color: colors.headerPrimary,
        ),
        h3 = TextStyle(
          fontFamily: VeraTypography.geist,
          fontWeight: FontWeight.w500,
          fontSize: 18,
          height: 1.6,
          letterSpacing: -0.36,
          color: colors.textPrimary,
        ),
        h4 = TextStyle(
          fontFamily: VeraTypography.geist,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          height: 22 / 16,
          letterSpacing: -0.32,
          color: colors.textPrimary,
        ),
        p1 = TextStyle(
          fontFamily: VeraTypography.geist,
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 22 / 14,
          color: colors.textSecondary,
        ),
        p2 = TextStyle(
          fontFamily: VeraTypography.geist,
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 16 / 12,
          color: colors.textSecondary,
        ),
        tab = TextStyle(
          fontFamily: VeraTypography.geist,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          height: 12 / 10,
          letterSpacing: -0.1,
          color: colors.navActive,
        ),
        button = TextStyle(
          fontFamily: VeraTypography.geist,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 22 / 14,
          letterSpacing: -0.28,
          color: colors.white,
        );

  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle p1;
  final TextStyle p2;
  final TextStyle tab;
  final TextStyle button;

  TextTheme get textTheme => TextTheme(
    displayLarge: h1,
    headlineMedium: h2,
    titleLarge: h3,
    titleMedium: h4,
    bodyMedium: p1,
    bodySmall: p2,
    labelLarge: button,
  );
}
