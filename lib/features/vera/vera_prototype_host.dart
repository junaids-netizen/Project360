import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/features/vera/brand_vera_colors.dart';
import 'package:vera_design/app/app.dart';
import 'package:vera_design/app/router.dart';
import 'package:vera_design/app/theme/vera_colors_scope.dart';

/// Embeds the full Vera tabbed app with the active Project360 brand palette.
class VeraCardPrototypeHost extends StatefulWidget {
  const VeraCardPrototypeHost({super.key});

  @override
  State<VeraCardPrototypeHost> createState() => _VeraCardPrototypeHostState();
}

class _VeraCardPrototypeHostState extends State<VeraCardPrototypeHost> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _router ??= createVeraFullAppRouter();
  }

  @override
  Widget build(BuildContext context) {
    final brandColors = context.brand;

    return VeraColorsScope(
      colors: veraColorsFromBrand(brandColors),
      child: VeraDesignApp(router: _router!),
    );
  }
}
