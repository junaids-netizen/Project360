import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/features/pitch/pitch_builder_screen.dart';
import 'package:project360/features/pitch/pitch_modules.dart';

void main() {
  testWidgets('Builder previews only the modules left on', (tester) async {
    List<PitchModule>? opened;
    await tester.pumpWidget(
      BrandScope(
        controller: BrandController(),
        child: MaterialApp(
          home: PitchBuilderScreen(onPreview: (_, modules) => opened = modules),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Build an app'), findsOneWidget);
    expect(find.text('Card management'), findsOneWidget);
    expect(find.text('Rewards'), findsOneWidget);
    expect(find.text('Preview app'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('pitch-toggle-rewards')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pitch-toggle-notifications')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pitch-preview')));
    await tester.pumpAndSettle();

    expect(opened, [PitchModule.home, PitchModule.card, PitchModule.settings]);
  });

  testWidgets('Home toggle does not drop home from the preview', (
    tester,
  ) async {
    List<PitchModule>? opened;
    await tester.pumpWidget(
      BrandScope(
        controller: BrandController(),
        child: MaterialApp(
          home: PitchBuilderScreen(onPreview: (_, modules) => opened = modules),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('pitch-toggle-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pitch-preview')));
    await tester.pumpAndSettle();

    expect(opened?.first, PitchModule.home);
    expect(opened, pitchModuleOrder);
  });
}
