import 'package:flutter/widgets.dart';

/// One tab in [GlassTabShell].
class GlassTabItem {
  const GlassTabItem({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}
