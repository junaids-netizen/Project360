import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project360/app/app.dart';
import 'package:project360/app/theme/brand.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/features/three_sixty/capsule_app.dart';

void main() {
  testWidgets('360 section appears on index', (tester) async {
    await tester.pumpWidget(
      Project360App(controller: BrandController()),
    );
    await tester.pumpAndSettle();

    expect(find.text('360'), findsOneWidget);
    expect(find.text('Capsule app'), findsOneWidget);
    expect(find.text('Credit Health'), findsWidgets);
  });

  testWidgets('My Cards screen shows key copy under brand scope', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BrandScope(
          controller: BrandController(veraBrand),
          child: const CapsuleApp(initialTab: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recent transactions'), findsOneWidget);
    expect(find.text('Pay now'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('View statements'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('View statements'), findsOneWidget);
    expect(find.text('My Cards'), findsWidgets);
    expect(find.text('Due amount'), findsOneWidget);
  });

  testWidgets('Manage opens manage card screen', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BrandScope(
          controller: BrandController(veraBrand),
          child: const CapsuleApp(initialTab: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Manage').first);
    await tester.pumpAndSettle();

    expect(find.text('Manage card'), findsOneWidget);
    expect(find.text('Freeze card'), findsOneWidget);
    expect(find.text('Replace card'), findsOneWidget);
    expect(find.text('Change PIN'), findsOneWidget);
    expect(find.text('Manage digital wallets'), findsOneWidget);
    expect(find.text('View account details'), findsOneWidget);
  });
}
