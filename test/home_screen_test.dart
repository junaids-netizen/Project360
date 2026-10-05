import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project360/app/app.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/features/home/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home header stays below the status bar', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BrandScope(
        controller: BrandController(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Back'), findsOneWidget);
    expect(find.textContaining('Sandeep'), findsNothing);

    final back = tester.widget<Text>(find.text('Back'));
    expect(back.style?.decoration, isNot(TextDecoration.underline));

    final texts = find.byType(Text);
    for (final element in texts.evaluate()) {
      final top = tester.getTopLeft(find.byWidget(element.widget)).dy;
      expect(
        top,
        greaterThanOrEqualTo(59),
        reason: '${(element.widget as Text).data} overlaps the status bar',
      );
    }

    expect(find.text('Current Balance'), findsOneWidget);
    expect(find.text('Available Credit'), findsOneWidget);
    expect(find.text('4,500'), findsOneWidget);
    expect(find.text('15,550'), findsOneWidget);
    expect(find.text('Pay now'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Delta Airlines'), findsOneWidget);
    expect(find.text('-\$542.89'), findsWidgets);
    expect(find.text('+\$542.89'), findsWidgets);
    expect(find.text('Refund Amazon'), findsOneWidget);
  });

  testWidgets('Vera app opens the home screen from the launcher', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(Project360App(controller: BrandController()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Vera app'), 200);
    await tester.tap(find.text('Vera app'));
    await tester.pumpAndSettle();

    expect(find.text('Pay now'), findsOneWidget);
    expect(find.text('Current Balance'), findsOneWidget);
    expect(find.textContaining('Sandeep'), findsNothing);
  });
}
