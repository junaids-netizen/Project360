import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project360/app/app.dart';
import 'package:project360/app/theme/brand.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/core/widgets/vera_primitives.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Build an app opens from the index', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(Project360App(controller: BrandController()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Build an app'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Choose what this bank gets. Home stays on;\n'
        'everything else is a module.',
      ),
      findsOneWidget,
    );
    expect(find.text('Modules'), findsOneWidget);
    expect(find.text('Preview app'), findsOneWidget);
    expect(find.text('Vera'), findsWidgets);

    expect(
      tester.widget<VeraToggle>(find.byKey(const ValueKey('module-home'))).on,
      isTrue,
    );
    expect(
      tester
          .widget<VeraToggle>(find.byKey(const ValueKey('module-rewards')))
          .on,
      isFalse,
    );
    expect(
      tester.widget<VeraToggle>(find.byKey(const ValueKey('module-card'))).on,
      isTrue,
    );
  });

  testWidgets('Home stays on and other modules toggle', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(Project360App(controller: BrandController()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Build an app'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('module-home')));
    await tester.pump();
    expect(
      tester.widget<VeraToggle>(find.byKey(const ValueKey('module-home'))).on,
      isTrue,
    );

    await tester.tap(find.byKey(const ValueKey('module-rewards')));
    await tester.pump();
    expect(
      tester
          .widget<VeraToggle>(find.byKey(const ValueKey('module-rewards')))
          .on,
      isTrue,
    );

    await tester.tap(find.byKey(const ValueKey('module-card')));
    await tester.pump();
    expect(
      tester.widget<VeraToggle>(find.byKey(const ValueKey('module-card'))).on,
      isFalse,
    );
  });

  testWidgets('preview shows only the modules that are on', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(Project360App(controller: BrandController()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Build an app'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('module-rewards')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('preview-app')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('preview-tab-home')), findsOneWidget);
    expect(find.byKey(const ValueKey('preview-tab-rewards')), findsOneWidget);
    expect(find.byKey(const ValueKey('preview-tab-card')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('preview-tab-notifications')),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('preview-tab-settings')), findsNothing);
    expect(find.text('Vera'), findsWidgets);
  });

  testWidgets('the builder shows the chosen bank name', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final harbour = brandPresets.firstWhere((brand) => brand.id == 'harbour');
    await tester.pumpWidget(
      Project360App(controller: BrandController(harbour)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Build an app'));
    await tester.pumpAndSettle();

    expect(find.text('Harbour Trust'), findsOneWidget);
  });
}
