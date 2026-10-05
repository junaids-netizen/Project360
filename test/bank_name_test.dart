import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project360/app/app.dart';
import 'package:project360/app/theme/brand.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/core/widgets/vera_card.dart';
import 'package:project360/features/brand/brand_gallery_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every preset bank has a distinct name and a logo asset', () async {
    final ids = <String>{};
    final names = <String>{};
    for (final brand in brandPresets) {
      expect(brand.name.trim(), isNotEmpty, reason: brand.id);
      expect(brand.logoAsset, isNotNull, reason: brand.id);
      expect(ids.add(brand.id), isTrue, reason: 'duplicate id ${brand.id}');
      expect(
        names.add(brand.name),
        isTrue,
        reason: 'duplicate name ${brand.name}',
      );
      final data = await rootBundle.load(brand.logoAsset!);
      expect(data.lengthInBytes, greaterThan(0), reason: brand.logoAsset);
    }
  });

  testWidgets('the card name follows the chosen bank', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = BrandController();
    await tester.pumpWidget(
      BrandScope(
        controller: controller,
        child: const MaterialApp(
          home: Scaffold(body: Center(child: VeraCardFace())),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Vera'), findsOneWidget);

    final harbour = brandPresets.firstWhere((brand) => brand.id == 'harbour');
    controller.select(harbour);
    await tester.pump();

    expect(find.text('Harbour Trust'), findsOneWidget);
    expect(find.text('Vera'), findsNothing);
  });

  testWidgets('choosing a bank logo renames the pitch', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(Project360App(controller: BrandController()));
    await tester.pumpAndSettle();

    expect(find.text('Vera'), findsOneWidget);

    await tester.tap(find.text('Brand'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('bank-logo-northgate')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Northgate'), findsOneWidget);
    expect(find.text('Vera'), findsNothing);
  });

  testWidgets('tapping the card name opens the logo picker', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(Project360App(controller: BrandController()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Brand studio'));
    await tester.pumpAndSettle();

    final cardName = find.byKey(const ValueKey('bank-name'));
    await tester.scrollUntilVisible(
      cardName,
      400,
      scrollable: find.descendant(
        of: find.byType(BrandGalleryScreen),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(cardName);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('bank-logo-sterling')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('bank-logo-sterling')));
    await tester.pumpAndSettle();

    expect(find.text('Sterling'), findsWidgets);
  });
}
