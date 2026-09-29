import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_typography.dart';
import 'package:project360/features/brand/brand_gallery_screen.dart';

class Project360App extends StatelessWidget {
  const Project360App({super.key, required this.controller});

  final BrandController controller;

  @override
  Widget build(BuildContext context) {
    return BrandScope(
      controller: controller,
      child: Builder(builder: _buildApp),
    );
  }

  Widget _buildApp(BuildContext context) {
    final colors = context.brand;
    final text = context.type;

    return MaterialApp(
      title: 'Project360',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: VeraTypography.geist,
        textTheme: text.textTheme,
        scaffoldBackgroundColor: colors.background,
        colorScheme: ColorScheme.light(
          primary: colors.textPrimary,
          onPrimary: colors.white,
          surface: colors.white,
          onSurface: colors.textPrimary,
        ),
      ),
      home: const BrandGalleryScreen(),
    );
  }
}
