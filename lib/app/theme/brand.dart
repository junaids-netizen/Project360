import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_colors.dart';

/// A brand is the one colour a bank actually hands over, plus a name and a
/// logo to show in the pitch. Everything else is derived.
@immutable
class Brand {
  const Brand({
    required this.id,
    required this.name,
    required this.seed,
    this.saturationScale = 1.0,
    this.logoAsset,
  });

  /// A brand dialled in live during a demo, rather than one saved as a preset.
  factory Brand.custom(Color seed) =>
      Brand(id: customId, name: 'Custom', seed: seed);

  static const String customId = 'custom';

  final String id;
  final String name;
  final Color seed;

  /// Single-colour SVG in `assets/images/banks/`. The picker tints it, and the
  /// card draws it next to [name]. Null draws a monogram of [name] instead.
  final String? logoAsset;

  /// Pulls every derived shade towards grey. Banks with a muted identity —
  /// navy, slate, forest — look overcooked at Vera's intensity.
  final double saturationScale;

  BrandColors resolve() =>
      BrandColors.fromSeed(seed, saturationScale: saturationScale);
}

/// The Vera house brand. Its seed reproduces the original Figma palette
/// exactly, so nothing about the prototype's appearance changed when theming
/// was introduced.
const Brand veraBrand = Brand(
  id: 'vera',
  name: 'Vera',
  seed: Color(0xFF7D5EF9),
  logoAsset: 'assets/images/banks/vera.svg',
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
/// is across the table: an `id`, a `name`, a `seed`, and a logo SVG.
const List<Brand> brandPresets = [
  veraBrand,
  Brand(
    id: 'northgate',
    name: 'Northgate',
    seed: Color(0xFFE01A2B),
    logoAsset: 'assets/images/banks/northgate.svg',
  ),
  Brand(
    id: 'meridian',
    name: 'Meridian',
    seed: Color(0xFFFFB000),
    logoAsset: 'assets/images/banks/meridian.svg',
  ),
  Brand(
    id: 'harbour',
    name: 'Harbour Trust',
    seed: Color(0xFF00857C),
    logoAsset: 'assets/images/banks/harbour.svg',
  ),
  Brand(
    id: 'sterling',
    name: 'Sterling',
    seed: Color(0xFF1B4CA8),
    saturationScale: 0.82,
    logoAsset: 'assets/images/banks/sterling.svg',
  ),
];
