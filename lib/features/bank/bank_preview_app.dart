import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/app/theme/vera_typography.dart';

/// Hosts a pitch or Vera preview router inside the active brand.
///
/// This is the whole app shell. It does not load a second package.
class BankPreviewApp extends StatelessWidget {
  const BankPreviewApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final colors = context.brand;
    final text = context.type;

    return MaterialApp.router(
      routerConfig: router,
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
    );
  }
}
