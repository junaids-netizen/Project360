import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/core/widgets/bank_logo.dart';
import 'package:project360/core/widgets/vera_assets.dart';
import 'package:project360/features/builder/app_module.dart';

/// The mark beside a module row and in the preview tab bar.
class ModuleIcon extends StatelessWidget {
  const ModuleIcon({
    super.key,
    required this.module,
    required this.color,
    this.size = 22,
  });

  final AppModule module;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (module == AppModule.home) {
      return BankLogo(
        brand: BrandScope.of(context).brand,
        size: size,
        color: color,
      );
    }
    final asset = switch (module) {
      AppModule.rewards => 'assets/images/modules/rewards.svg',
      AppModule.card => 'assets/images/modules/card.svg',
      AppModule.notifications => VeraAssets.bell,
      AppModule.settings => 'assets/images/modules/settings.svg',
      AppModule.home => '',
    };
    return VeraSvg(asset, size: size, color: color);
  }
}
