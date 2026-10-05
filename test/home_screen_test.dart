import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project360/app/app.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/features/home/bank_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home matches the shipped tab layout', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BrandScope(
        controller: BrandController(),
        child: const MaterialApp(home: BankApp()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Back'), findsNothing);
    expect(find.textContaining('Sandeep'), findsNothing);

    for (final element in find.byType(Text).evaluate()) {
      final top = tester.getTopLeft(find.byWidget(element.widget)).dy;
      expect(
        top,
        greaterThanOrEqualTo(59),
        reason: '${(element.widget as Text).data} overlaps the status bar',
      );
    }

    expect(find.text('Current Balance'), findsOneWidget);
    expect(find.text('Available Credit'), findsOneWidget);
    expect(find.text('4,501'), findsOneWidget);
    expect(find.text('15,551'), findsOneWidget);
    expect(find.text('Payment due'), findsOneWidget);
    expect(find.text('Min Due'), findsOneWidget);
    expect(find.text('Pay now'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Amazon'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Rewards'), findsWidgets);
    expect(find.text('Card'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);

    await tester.tap(find.text('Rewards').last);
    await tester.pumpAndSettle();
    expect(find.text('Redeem now'), findsOneWidget);
    expect(find.text('Omni'), findsOneWidget);
    expect(find.text('Universal Rewards'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);

    await tester.tap(find.text('Card'));
    await tester.pumpAndSettle();
    expect(find.text('Manage card'), findsOneWidget);
    expect(find.text('Activate Physical Card'), findsOneWidget);
    expect(find.text('Freeze card'), findsOneWidget);
    expect(find.text('Set Cash advance PIN'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.text('Sandeep Sachdeva'), findsOneWidget);
    expect(find.text('Joined Jan 2024'), findsOneWidget);
    expect(find.text('Communication preferences'), findsOneWidget);
    expect(find.text('Legal and Support'), findsOneWidget);
    expect(find.text('Contact us'), findsOneWidget);

    final nameTop = tester.getTopLeft(find.text('Sandeep Sachdeva')).dy;
    expect(nameTop, greaterThanOrEqualTo(59));
  });

  testWidgets('Vera app opens the home screen from the launcher', (
    tester,
  ) async {
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
    expect(find.text('Back'), findsNothing);
  });
}
