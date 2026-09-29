import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project360/app/theme/brand.dart';
import 'package:project360/app/theme/brand_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final northgate = brandPresets.firstWhere((b) => b.id == 'northgate');

  test('defaults to Vera when nothing was ever selected', () async {
    SharedPreferences.setMockInitialValues({});
    expect((await BrandController.restore()).id, veraBrand.id);
  });

  test('selecting a preset persists it for the next launch', () async {
    SharedPreferences.setMockInitialValues({});
    BrandController().select(northgate);
    // select() writes without blocking the frame it was called on.
    await Future<void>.delayed(Duration.zero);

    expect((await BrandController.restore()).id, northgate.id);
  });

  test('a custom colour survives a relaunch', () async {
    SharedPreferences.setMockInitialValues({});
    const seed = Color(0xFF1188CC);
    BrandController().select(Brand.custom(seed));
    await Future<void>.delayed(Duration.zero);

    final restored = await BrandController.restore();
    expect(restored.id, Brand.customId);
    expect(restored.seed.toARGB32(), seed.toARGB32());
  });

  test('an unknown saved brand falls back to Vera', () async {
    SharedPreferences.setMockInitialValues({'flutter.brand.id': 'gone'});
    expect((await BrandController.restore()).id, veraBrand.id);
  });

  test('selecting notifies listeners once', () {
    var notifications = 0;
    final controller = BrandController()..addListener(() => notifications++);

    controller.select(northgate);
    expect(notifications, 1);
    expect(controller.brand.id, northgate.id);

    // Re-selecting the active brand should not churn the whole tree.
    controller.select(northgate);
    expect(notifications, 1);
  });
}
