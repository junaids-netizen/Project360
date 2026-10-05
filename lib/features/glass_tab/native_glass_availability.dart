import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Whether native Liquid Glass tab chrome can be used on this device.
///
/// Replaced by Vera handoff when [tool/vendor_glass_tab.sh] runs.
class NativeGlassAvailability {
  NativeGlassAvailability._();

  static bool _initialized = false;
  static bool _available = false;

  static bool get isAvailable => _available;

  /// Call before [runApp]. Returns whether native glass tab chrome is available.
  static Future<bool> initialize() async {
    if (_initialized) return _available;
    _initialized = true;

    if (kIsWeb || !Platform.isIOS) {
      _available = false;
      return _available;
    }

    // Real implementation probes iOS 26+ via method channel after vendor.
    _available = false;
    return _available;
  }
}
