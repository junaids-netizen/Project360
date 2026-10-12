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

  testWidgets('Credit Health tab shows score gauge and chart copy', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: BrandScope(
          controller: BrandController(veraBrand),
          child: const CapsuleApp(initialTab: 2),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Credit Health'), findsWidgets);
    expect(find.text('Perfect run'), findsOneWidget);
    expect(
      find.text('Your credit score has increased by 25 points'),
      findsOneWidget,
    );
    expect(find.text('784'), findsWidgets);
    expect(find.text('300'), findsOneWidget);
    expect(find.text('850'), findsOneWidget);
    expect(find.text('1Y'), findsOneWidget);
  });

  testWidgets('Family Hub tab shows member rail and balance', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: BrandScope(
          controller: BrandController(veraBrand),
          child: const CapsuleApp(initialTab: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Family Hub'), findsWidgets);
    expect(find.text('ZACK'), findsOneWidget);
    expect(find.text('Rachel'), findsOneWidget);
    expect(find.text('Used'), findsOneWidget);
    expect(find.text('Manage card'), findsOneWidget);
    expect(find.text('PENDING'), findsOneWidget);
    expect(find.text('DECLINED'), findsOneWidget);
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
