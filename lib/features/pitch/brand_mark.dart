import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/core/widgets/vera_assets.dart';

/// The active brand's logo, or the bundled mark when the pitch has none.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    required this.width,
    required this.height,
    required this.fallback,
    this.tint,
  });

  final double width;
  final double height;
  final String fallback;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final url = BrandScope.of(context).brand.logoUrl;
    if (url == null || url.isEmpty) {
      return VeraSvg(fallback, width: width, height: height, color: tint);
    }
    return pitchNetworkLogo(
      url,
      width: width,
      height: height,
      fallback: fallback,
      tint: tint,
    );
  }
}

/// Raster logo fetched from a bank site.
///
/// The pitch screen can pass its own builder in tests so they never open a
/// socket. A failed image falls back to the bundled mark.
Widget pitchNetworkLogo(
  String url, {
  double width = 44,
  double height = 22,
  String fallback = VeraAssets.logo,
  Color? tint,
}) {
  return Image.network(
    url,
    width: width,
    height: height,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.medium,
    semanticLabel: 'Bank logo',
    errorBuilder: (context, error, stackTrace) =>
        VeraSvg(fallback, width: width, height: height, color: tint),
    loadingBuilder: (context, child, progress) {
      if (progress == null) return child;
      return SizedBox(width: width, height: height);
    },
  );
}
