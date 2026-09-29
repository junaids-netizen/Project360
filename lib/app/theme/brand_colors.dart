import 'package:flutter/material.dart';

const Color _black = Color(0xFF000000);
const Color _white = Color(0xFFFFFFFF);

/// The full resolved colour set for one brand.
///
/// Tokens are named for the role they play, not for the colour they happen to
/// be under Vera. `accent` rather than `brandPurple`, `cardSurface` rather than
/// `card`. That is what lets a bank's palette drop in without every screen
/// reading as a lie.
///
/// Everything brand-dependent is derived from a single seed colour by
/// [BrandColors.fromSeed]. Only the seed's *hue* is taken; the saturation and
/// lightness of each derived shade come from Vera's Figma palette. That keeps
/// the contrast relationships the design was drawn with, so a bank whose brand
/// colour is pale yellow still gets a legible dark card and readable ink.
@immutable
class BrandColors {
  const BrandColors._({
    required this.accent,
    required this.accentSecondary,
    required this.cardSurface,
    required this.navActive,
    required this.textPrimary,
    required this.surfaceMuted,
    required this.borderMuted,
    required this.letterbox,
    required this.frostTint,
    required this.sliderThumb,
    required this.darkGradient,
    required this.buttonGradient,
    required this.progressGradient,
    required this.pointsGlow,
  });

  /// Builds a complete palette from the one colour a bank actually gives you.
  ///
  /// [saturationScale] dials every derived shade down for brands whose identity
  /// is muted — a navy or slate bank looks wrong rendered at Vera's intensity.
  factory BrandColors.fromSeed(Color seed, {double saturationScale = 1.0}) {
    final baseHue = HSLColor.fromColor(seed).hue;

    Color shade(double hueShift, double saturation, double lightness) {
      return HSLColor.fromAHSL(
        1,
        (baseHue + hueShift) % 360,
        (saturation * saturationScale).clamp(0.0, 1.0),
        lightness,
      ).toColor();
    }

    return BrandColors._(
      accent: seed,
      accentSecondary: shade(-63.8692, 1.0000, 0.4196),
      cardSurface: shade(6.8060, 0.5630, 0.2333),
      navActive: shade(3.5556, 1.0000, 0.1588),
      textPrimary: shade(0.0000, 1.0000, 0.1078),
      surfaceMuted: shade(-12.0000, 0.0769, 0.9745),
      borderMuted: shade(-32.0000, 0.0667, 0.9118),
      letterbox: shade(3.0000, 0.1905, 0.9176),
      frostTint: shade(10.1739, 1.0000, 0.7294),
      sliderThumb: shade(6.5714, 0.6667, 0.2471),
      darkGradient: [
        shade(6.0723, 0.7217, 0.2255),
        shade(6.4252, 0.5907, 0.5784),
        shade(5.7273, 0.3860, 0.7765),
      ],
      buttonGradient: [
        shade(6.0723, 0.7217, 0.2255),
        shade(6.3333, 0.7579, 0.6275),
        shade(5.7273, 0.6197, 0.7216),
      ],
      progressGradient: [
        shade(7.1667, 1.0000, 0.8588),
        shade(8.5348, 0.7450, 0.4922),
      ],
      pointsGlow: [
        shade(-46.9749, 1.0000, 0.6098),
        shade(-22.0935, 1.0000, 0.7902),
        shade(-7.1759, 1.0000, 0.6098),
      ],
    );
  }

  // --- Brand-derived -------------------------------------------------------

  /// The bank's colour, used as-is.
  final Color accent;
  final Color accentSecondary;

  /// Fill behind the card face.
  final Color cardSurface;

  /// Selected tab icon and label, and the "on" state of a toggle.
  final Color navActive;

  final Color textPrimary;

  /// Faint brand-tinted greys used by the payment callout.
  final Color surfaceMuted;
  final Color borderMuted;

  /// Backdrop around the phone frame when running on a wide window.
  final Color letterbox;

  /// Tint of the frozen-card frost overlay.
  final Color frostTint;

  final Color sliderThumb;

  /// Three-stop ramp behind large Denton amounts and the avatar.
  final List<Color> darkGradient;

  /// Three-stop ramp filling the primary button.
  final List<Color> buttonGradient;

  /// Two-stop ramp for the balance progress bar.
  final List<Color> progressGradient;

  /// Blurred glow behind the rewards points card. Sits within ~47 degrees of
  /// the brand hue, so it reads as part of the brand family and follows it.
  final List<Color> pointsGlow;

  Color get textSecondary => textPrimary.withValues(alpha: 0xA6 / 0xFF);
  Color get textTertiary => textPrimary.withValues(alpha: 0x40 / 0xFF);

  /// Frost overlay on a frozen card: a white highlight over the brand tint.
  List<Color> get frostOverlay => [
    frostHighlight,
    frostTint.withValues(alpha: 0x78 / 0xFF),
  ];

  // --- Brand-independent ---------------------------------------------------
  //
  // Neutrals stay neutral across every bank. Status colours stay absolute,
  // because a green that follows the brand hue is no longer a success colour.

  final Color white = _white;
  final Color background = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFF0F0F0);
  final Color headerPrimary = const Color(0xFF121212);

  final Color navSurface = const Color(0xFFF5F5F5);
  final Color navSelection = const Color(0xFFE0E0E0);

  final Color cardShadow = const Color(0x99F2F2F2);

  /// Dimming behind a modal sheet.
  final Color scrim = const Color(0x1F000000);
  final Color buttonShadow = const Color(0x12000000);
  final Color chromeShadow = const Color(0x26000000);
  Color get navShadow => _black.withValues(alpha: 0.12);
  Color get knobShadow => _black.withValues(alpha: 0.25);
  Color get cardDivider => _white.withValues(alpha: 0.21);

  /// Body copy inside the "you've paid so far" callout.
  final Color toastInk = const Color(0xFF1F2F41);

  /// Amount labels flanking the payment slider.
  final Color sliderValueInk = const Color(0x80171717);

  final Color frostHighlight = const Color(0x78FFFFFF);

  /// Radial ramp for the frost bloom sweeping across a freezing card.
  final List<Color> frostBloom = const [
    Color(0xFFFFFFFF),
    Color(0xE6FFFFFF),
    Color(0x00FFFFFF),
  ];

  /// The Omni rewards programme is a third party with its own identity, so its
  /// wordmark and glow keep their colours under every bank.
  final List<Color> wordmarkGradient = const [
    Color(0xFF5F5F5F),
    Color(0xFF000000),
  ];

  final List<Color> programGlow = const [
    Color(0xFFFFB31B),
    Color(0xFFFFA228),
    Color(0xFFFF383B),
  ];

  /// Half-opacity ink for text that will be replaced by a shader anyway; only
  /// its alpha survives the `srcIn` blend.
  final Color shaderInk = const Color(0x80000000);

  final Color badge = const Color(0xFFCC4B0E);
  final Color success = const Color(0xFF006328);
  final Color warning = const Color(0xFFE06C00);
  final Color danger = const Color(0xFFCC4B0E);

  /// Ink that stays legible on [surface]. Guards against banks whose brand
  /// colour is light enough that white text on it disappears.
  Color onColor(Color surface) {
    return surface.computeLuminance() > 0.45 ? textPrimary : white;
  }
}
