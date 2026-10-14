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
  static const String _nameKey = 'brand.name';
  static const String _logoKey = 'brand.logo';
  static const String _hostKey = 'brand.host';
  static const String _backgroundKey = 'brand.background';
  static const String _textKey = 'brand.text';
  static const String _accentKey = 'brand.accent';

  BrandTheme _theme;

  BrandTheme get theme => _theme;
  Brand get brand => _theme.brand;

  void select(Brand brand) {
    if (_theme.brand.sameAs(brand)) return;
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
      if (id == Brand.websiteId) {
        final seed = prefs.getInt(_seedKey);
        if (seed == null) return veraBrand;
        return Brand.website(
          name: prefs.getString(_nameKey) ?? 'Bank',
          seed: Color(seed),
          logoUrl: prefs.getString(_logoKey),
          sourceHost: prefs.getString(_hostKey),
          background: _readColor(prefs.getInt(_backgroundKey)),
          text: _readColor(prefs.getInt(_textKey)),
          accent: _readColor(prefs.getInt(_accentKey)),
        );
      }
      return brandPresets.firstWhere(
        (brand) => brand.id == id,
        orElse: () => veraBrand,
      );
    } catch (_) {
      return veraBrand;
    }
  }

  static Color? _readColor(int? argb) => argb == null ? null : Color(argb);

  static Future<void> _writeColor(
    SharedPreferences prefs,
    String key,
    Color? color,
  ) {
    if (color == null) return prefs.remove(key);
    return prefs.setInt(key, color.toARGB32());
  }

  static Future<void> _writeString(
    SharedPreferences prefs,
    String key,
    String? value,
  ) {
    if (value == null || value.isEmpty) return prefs.remove(key);
    return prefs.setString(key, value);
  }

  static Future<void> _persist(Brand brand) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_idKey, brand.id);
      await prefs.setInt(_seedKey, brand.seed.toARGB32());
      if (brand.id == Brand.websiteId) {
        await _writeString(prefs, _nameKey, brand.name);
        await _writeString(prefs, _logoKey, brand.logoUrl);
        await _writeString(prefs, _hostKey, brand.sourceHost);
        await _writeColor(prefs, _backgroundKey, brand.background);
        await _writeColor(prefs, _textKey, brand.text);
        await _writeColor(prefs, _accentKey, brand.accent);
      } else {
        await prefs.remove(_nameKey);
        await prefs.remove(_logoKey);
        await prefs.remove(_hostKey);
        await prefs.remove(_backgroundKey);
        await prefs.remove(_textKey);
        await prefs.remove(_accentKey);
      }
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
