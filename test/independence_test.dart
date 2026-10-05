import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/features/pitch/pitch_modules.dart';
import 'package:project360/features/pitch/pitch_preview_host.dart';

void main() {
  test('checkout does not path-depend on a sibling package', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('vera_design'), isFalse);
    expect(pubspec.contains('../'), isFalse);

    final lock = File('pubspec.lock').readAsStringSync();
    expect(lock.contains('vera_design'), isFalse);
    expect(lock.contains('cupertino_native'), isFalse);

    final hits = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final source = file.readAsStringSync();
      if (source.contains('package:vera_design') ||
          source.contains('../vera_design')) {
        hits.add(file.path);
      }
    }
    expect(hits, isEmpty);
  });

  testWidgets('full preview is the in-repo bank app', (tester) async {
    await tester.pumpWidget(
      BrandScope(
        controller: BrandController(),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => openPitchPreview(context, pitchModuleOrder),
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Current Balance'), findsOneWidget);
    expect(find.text('Pay now'), findsOneWidget);
    expect(find.text('Rewards'), findsWidgets);
    expect(find.byKey(const Key('preview-back')), findsOneWidget);

    await tester.tap(find.text('Card').first);
    await tester.pumpAndSettle();
    expect(find.text('Freeze card'), findsOneWidget);

    await tester.tap(find.byKey(const Key('preview-back')));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
    expect(find.text('Current Balance'), findsNothing);
  });

  testWidgets('card-only preview still builds without the sibling package', (
    tester,
  ) async {
    await tester.pumpWidget(
      BrandScope(
        controller: BrandController(),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => openPitchPreview(context, const [
                    PitchModule.home,
                    PitchModule.card,
                  ]),
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Current Balance'), findsOneWidget);
    expect(find.text('Card'), findsWidgets);
    expect(find.text('Freeze card'), findsNothing);
  });
}
