import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/features/pitch/pitch_modules.dart';
import 'package:project360/features/pitch/pitch_preview_host.dart';

void main() {
  test('checkout does not depend on a sibling vera_design folder', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('../vera_design'), isFalse);

    final lock = File('pubspec.lock');
    if (lock.existsSync()) {
      final lockText = lock.readAsStringSync();
      expect(lockText.contains('../vera_design'), isFalse);
    }

    final hits = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (file.path.contains('.template')) continue;
      final source = file.readAsStringSync();
      if (source.contains('../vera_design')) hits.add(file.path);
    }
    expect(hits, isEmpty);
  });

  testWidgets('full preview opens and returns to the builder', (tester) async {
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
    expect(find.byKey(const Key('preview-back')), findsOneWidget);

    await tester.tap(find.byKey(const Key('preview-back')));
    await tester.pumpAndSettle();

    expect(find.text('open'), findsOneWidget);
    expect(find.text('Current Balance'), findsNothing);
  });
}
