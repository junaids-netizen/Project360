import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project360/app/theme/brand.dart';
import 'package:project360/app/theme/brand_colors.dart';
import 'package:project360/app/theme/vera_typography.dart';

/// Everything the UI needs to render one brand.
///
/// Later phases add `radii` and `assets` here. Because screens already reach
/// through this object rather than through constants, that is a new field
/// rather than another migration.
@immutable
class BrandTheme {
  factory BrandTheme(Brand brand) {
    final colors = brand.resolve();
    return BrandTheme._(brand, colors, VeraTextStyles(colors));
  }

  const BrandTheme._(this.brand, this.colors, this.text);

  final Brand brand;
  final BrandColors colors;
  final VeraTextStyles text;
}

/// Holds the active brand and rebuilds the app when it changes.
class BrandController extends ChangeNotifier {
  BrandController([Brand initial = veraBrand]) : _theme = BrandTheme(initial);

  static const String _idKey = 'brand.id';
  static const String _seedKey = 'brand.seed';

  BrandTheme _theme;

  BrandTheme get theme => _theme;
  Brand get brand => _theme.brand;

  void select(Brand brand) {
    if (brand.id == _theme.brand.id && brand.seed == _theme.brand.seed) return;
    _theme = BrandTheme(brand);
    notifyListeners();
    unawaited(_persist(brand));
  }

  /// Launch straight into a brand, bypassing whatever was last selected:
  /// `flutter run --dart-define=BRAND=northgate`. Handy for walking into a
  /// meeting already in the right colours, and for deterministic screenshots.
  static const String _startupBrand = String.fromEnvironment('BRAND');

  /// Reads the brand chosen in the last session, so relaunching mid-pitch does
  /// not drop back to Vera purple in front of the room.
  static Future<Brand> restore() async {
    if (_startupBrand.isNotEmpty) {
      return brandPresets.firstWhere(
        (brand) => brand.id == _startupBrand,
        orElse: () => veraBrand,
      );
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString(_idKey);
      if (id == null) return veraBrand;
      if (id == Brand.customId) {
        final seed = prefs.getInt(_seedKey);
        return seed == null ? veraBrand : Brand.custom(Color(seed));
      }
      return brandPresets.firstWhere(
        (brand) => brand.id == id,
        orElse: () => veraBrand,
      );
    } catch (_) {
      return veraBrand;
    }
  }

  static Future<void> _persist(Brand brand) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_idKey, brand.id);
      await prefs.setInt(_seedKey, brand.seed.toARGB32());
    } catch (_) {
      // A demo tool that cannot write preferences should still run.
    }
  }
}

/// Provides the active [BrandTheme] to the whole tree.
///
/// Sits above `MaterialApp` so `ThemeData` is rebuilt along with every screen.
class BrandScope extends InheritedNotifier<BrandController> {
  const BrandScope({
    super.key,
    required BrandController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Subscribes the calling widget to brand changes. Use inside `build`.
  static BrandController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BrandScope>();
    assert(scope != null, 'No BrandScope found above this widget.');
    return scope!.notifier!;
  }

  /// Reads the controller without subscribing. Use from callbacks.
  static BrandController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<BrandScope>();
    assert(scope != null, 'No BrandScope found above this widget.');
    return scope!.notifier!;
  }
}

extension BrandContext on BuildContext {
  /// Colours of the active brand.
  BrandColors get brand => BrandScope.of(this).theme.colors;

  /// Type ramp of the active brand.
  VeraTextStyles get type => BrandScope.of(this).theme.text;
}
