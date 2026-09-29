import 'package:flutter/services.dart';

/// Centralized haptic feedback. Every tap in the app should go through here.
abstract final class Haptics {
  static void light() => HapticFeedback.lightImpact();

  static void medium() => HapticFeedback.mediumImpact();

  static void selection() => HapticFeedback.selectionClick();

  static VoidCallback? wrap(VoidCallback? callback) {
    if (callback == null) return null;
    return () {
      light();
      callback();
    };
  }
}
