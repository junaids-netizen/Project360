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

  test('a website brand keeps its logo and surfaces', () async {
    SharedPreferences.setMockInitialValues({});
    final brand = Brand.website(
      name: 'Northwind',
      seed: const Color(0xFF0B5FFF),
      logoUrl: 'https://bank.example/touch-180.png',
      background: const Color(0xFFF4F6F8),
      text: const Color(0xFF102033),
      accent: const Color(0xFFE2A100),
      sourceHost: 'bank.example',
    );
    BrandController().select(brand);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final restored = await BrandController.restore();
    expect(restored.sameAs(brand), isTrue);
  });

  test('a new logo on the same website brand notifies', () {
    SharedPreferences.setMockInitialValues({});
    var notifications = 0;
    final controller = BrandController()..addListener(() => notifications++);
    final first = Brand.website(
      name: 'Northwind',
      seed: const Color(0xFF0B5FFF),
      logoUrl: 'https://bank.example/a.png',
    );
    final second = Brand.website(
      name: 'Northwind',
      seed: const Color(0xFF0B5FFF),
      logoUrl: 'https://bank.example/b.png',
    );

    controller.select(first);
    controller.select(first);
    expect(notifications, 1);
    controller.select(second);
    expect(notifications, 2);
    expect(controller.brand.logoUrl, 'https://bank.example/b.png');
  });

  test('a muted website seed lowers saturation and a vivid one does not', () {
    expect(
      Brand.website(
        name: 'Navy',
        seed: const Color(0xFF1B3A4B),
      ).saturationScale,
      0.82,
    );
    expect(
      Brand.website(
        name: 'Blue',
        seed: const Color(0xFF117ACA),
      ).saturationScale,
      1,
    );
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
