import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_colors.dart';

/// A brand is the one colour a bank actually hands over, plus a name to show
/// in the picker. Everything else is derived.
///
/// A website pitch can also carry a logo and the light background, ink, and
/// supporting accent read off the page. Presets leave those empty, so the
/// pitch tokens stay on the seed derivation.
@immutable
class Brand {
  const Brand({
    required this.id,
    required this.name,
    required this.seed,
    this.saturationScale = 1.0,
    this.logoUrl,
    this.sourceHost,
    this.background,
    this.text,
    this.accent,
  });

  /// A brand dialled in live during a demo, rather than one saved as a preset.
  factory Brand.custom(Color seed) =>
      Brand(id: customId, name: 'Custom', seed: seed);

  /// Colours and logo taken from a bank website during a pitch.
  ///
  /// [seed] is the primary brand colour ([BrandColors.accent]). A muted seed
  /// — low saturation, the navy and slate case — uses the same 0.82 scale as
  /// the Sterling preset so derived shades do not go neon.
  factory Brand.website({
    required String name,
    required Color seed,
    String? logoUrl,
    String? sourceHost,
    Color? background,
    Color? text,
    Color? accent,
  }) {
    final muted = HSLColor.fromColor(seed).saturation < 0.55;
    return Brand(
      id: websiteId,
      name: name,
      seed: seed,
      saturationScale: muted ? 0.82 : 1,
      logoUrl: logoUrl,
      sourceHost: sourceHost,
      background: background,
      text: text,
      accent: accent,
    );
  }

  static const String customId = 'custom';
  static const String websiteId = 'website';

  final String id;
  final String name;
  final Color seed;

  /// Pulls every derived shade towards grey. Banks with a muted identity —
  /// navy, slate, forest — look overcooked at Vera's intensity.
  final double saturationScale;

  /// Absolute logo from the bank site. Null keeps the bundled wordmark.
  final String? logoUrl;

  /// Host the pitch was read from, without a leading www.
  final String? sourceHost;

  /// Light page background from the site. Null keeps the neutral token.
  final Color? background;

  /// Dark ink from the site. Null keeps the seed-derived text.
  final Color? text;

  /// Supporting accent from the site. Null keeps the derived secondary accent.
  /// The primary brand colour is [seed].
  final Color? accent;

  BrandColors resolve() => BrandColors.fromSeed(
    seed,
    saturationScale: saturationScale,
    background: background,
    textPrimary: text,
    accentSecondary: accent,
  );

  bool sameAs(Brand other) =>
      id == other.id &&
      name == other.name &&
      seed == other.seed &&
      saturationScale == other.saturationScale &&
      logoUrl == other.logoUrl &&
      sourceHost == other.sourceHost &&
      background == other.background &&
      text == other.text &&
      accent == other.accent;
}

/// The Vera house brand. Its seed reproduces the original Figma palette
/// exactly, so nothing about the prototype's appearance changed when theming
/// was introduced.
const Brand veraBrand = Brand(
  id: 'vera',
  name: 'Vera',
  seed: Color(0xFF7D5EF9),
);

/// The full hue wheel, for the custom-colour strip in the brand picker. Not a
/// brand token — it is the input surface a brand gets chosen from.
const List<Color> hueSpectrum = [
  Color(0xFFFF0000),
  Color(0xFFFFFF00),
  Color(0xFF00FF00),
  Color(0xFF00FFFF),
  Color(0xFF0000FF),
  Color(0xFFFF00FF),
  Color(0xFFFF0000),
];

/// Sample banks to switch between in a pitch. Replace or extend with whoever
/// is across the table.
const List<Brand> brandPresets = [
  veraBrand,
  Brand(id: 'northgate', name: 'Northgate', seed: Color(0xFFE01A2B)),
  Brand(id: 'meridian', name: 'Meridian', seed: Color(0xFFFFB000)),
  Brand(id: 'harbour', name: 'Harbour Trust', seed: Color(0xFF00857C)),
  Brand(
    id: 'sterling',
    name: 'Sterling',
    seed: Color(0xFF1B4CA8),
    saturationScale: 0.82,
  ),
];

/// Offline stand-in when a bank site cannot be fetched during a pitch.
/// Not listed in [brandPresets] — only the pitch screen offers it.
const Brand pitchDemoBrand = Brand(
  id: 'pitch-demo',
  name: 'Demo bank',
  seed: Color(0xFF0B3D91),
  saturationScale: 0.9,
);
