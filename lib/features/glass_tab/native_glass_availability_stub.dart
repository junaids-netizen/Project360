import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Whether native Liquid Glass tab chrome can be used on this device.
class NativeGlassAvailability {
  NativeGlassAvailability._();

  static bool _initialized = false;
  static bool _available = false;

  static bool get isAvailable => _available;

  /// Call before [runApp]. Handoff uses [Future<void>]; use [isAvailable] after.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb || !Platform.isIOS) {
      _available = false;
      return;
    }

    _available = false;
  }
}
