import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/core/widgets/vera_assets.dart';

/// The mark for one bank.
///
/// Presets point at a single-colour SVG in `assets/images/banks/`. Anything
/// without a file — a colour dialled in live — falls back to a monogram of
/// [Brand.name], so the pitch still has something to show.
class BankLogo extends StatelessWidget {
  const BankLogo({
    super.key,
    required this.brand,
    this.size = 24,
    this.color,
  });

  final Brand brand;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? context.brand.textPrimary;
    final asset = brand.logoAsset;
    if (asset == null) {
      final letter = brand.name.isEmpty
          ? '?'
          : brand.name.substring(0, 1).toUpperCase();
      return SizedBox(
        width: size,
        height: size,
        child: FittedBox(
          child: Text(
            letter,
            style: TextStyle(
              fontFamily: VeraTypography.geist,
              fontWeight: FontWeight.w700,
              height: 1,
              color: tint,
            ),
          ),
        ),
      );
    }
    return VeraSvg(asset, size: size, color: tint);
  }
}

/// Logo plus the bank's name, in the ink of whatever surface it sits on.
///
/// This is the identity on the card. It reads [BrandScope], so choosing a
/// different logo in the picker renames it without the card knowing which
/// bank that was.
class BankNameLockup extends StatelessWidget {
  const BankNameLockup({super.key, required this.color, this.markSize = 16});

  final Color color;
  final double markSize;

  @override
  Widget build(BuildContext context) {
    final brand = BrandScope.of(context).brand;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BankLogo(brand: brand, size: markSize, color: color),
        SizedBox(width: markSize * 0.4),
        Text(
          brand.name,
          key: const ValueKey('bank-name'),
          maxLines: 1,
          style: TextStyle(
            fontFamily: VeraTypography.geist,
            fontWeight: FontWeight.w600,
            fontSize: markSize * 0.875,
            height: 1.1,
            letterSpacing: -0.2,
            color: color,
          ),
        ),
      ],
    );
  }
}
