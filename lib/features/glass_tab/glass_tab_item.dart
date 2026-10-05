import 'package:flutter/widgets.dart';

/// One tab in [GlassTabShell].
class GlassTabItem {
  const GlassTabItem({
    required this.label,
    required this.icon,
    required this.sfSymbol,
  });

  final String label;
  final IconData icon;

  /// SF Symbol name for native [CNTabBar] on iOS (e.g. `house.fill`).
  final String sfSymbol;
}
