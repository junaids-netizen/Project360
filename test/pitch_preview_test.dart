import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project360/app/app.dart';
import 'package:project360/app/theme/brand.dart';
import 'package:project360/app/theme/brand_theme.dart';
import 'package:project360/features/pitch/pitch_preview_screen.dart';
import 'package:project360/features/pitch/site_brand_client.dart';
import 'package:project360/features/pitch/site_brand_extract.dart';

const _html = '''
<!doctype html>
<html><head>
  <meta property="og:site_name" content="Northwind Bank">
  <meta name="theme-color" content="#0B5FFF">
  <link rel="apple-touch-icon" sizes="180x180" href="/touch-180.png">
  <style>
    :root {
      --background: #F4F6F8;
      --text: #102033;
      --accent: #E2A100;
    }
  </style>
</head></html>
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ExtractedSiteBrand sample() {
    return extractSiteBrand(
      html: _html,
      pageUrl: Uri.parse('https://www.bank.example/'),
    );
  }

  Future<void> pumpPitch(
    WidgetTester tester,
    BrandController controller, {
    SiteBrandLoader? load,
  }) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
    });
    await tester.pumpWidget(
      BrandScope(
        controller: controller,
        child: MaterialApp(
          home: PitchPreviewScreen(
            load: load,
            logoBuilder: (_) => const SizedBox(width: 44, height: 16),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('pitch preview applies the extracted brand', (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final extracted = sample();
    final controller = BrandController();
    var loads = 0;
    await pumpPitch(
      tester,
      controller,
      load: (uri) async {
        loads += 1;
        expect(uri.toString(), 'https://bank.example/welcome');
        return extracted;
      },
    );

    await tester.enterText(
      find.byKey(const Key('pitch-url')),
      'bank.example/welcome',
    );
    await tester.tap(find.text('Apply'));
    await tester.pump();
    await tester.pump();

    expect(loads, 1);
    expect(find.textContaining('Using extracted brand'), findsOneWidget);
    expect(find.textContaining('bank.example'), findsWidgets);
    expect(controller.brand.name, 'Northwind Bank');
    expect(controller.brand.logoUrl, extracted.logoUrl);
    expect(controller.theme.colors.accent.toARGB32(), 0xFF0B5FFF);
    expect(controller.theme.colors.background.toARGB32(), 0xFFF4F6F8);
    expect(controller.theme.colors.textPrimary.toARGB32(), 0xFF102033);
    expect(controller.theme.colors.accentSecondary.toARGB32(), 0xFFE2A100);
    expect(
      controller.theme.colors.cardSurface.toARGB32(),
      isNot(veraBrand.resolve().cardSurface.toARGB32()),
    );
    expect(
      find.byKey(ValueKey<String>('pitch-card:${extracted.logoUrl}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey<String>('pitch-header:${extracted.logoUrl}')),
      findsOneWidget,
    );
    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Northwind Bank'), findsOneWidget);
  });

  testWidgets('a bad url is rejected before any fetch', (tester) async {
    final controller = BrandController();
    var loads = 0;
    await pumpPitch(
      tester,
      controller,
      load: (_) async {
        loads += 1;
        return sample();
      },
    );

    await tester.enterText(find.byKey(const Key('pitch-url')), 'not a url');
    await tester.tap(find.text('Apply'));
    await tester.pump();

    expect(loads, 0);
    expect(find.text('Enter an https website URL.'), findsOneWidget);
    expect(controller.brand.id, veraBrand.id);
    expect(find.text('Use demo brand'), findsNothing);
  });

  testWidgets('a blocked site can fall back to the demo brand', (tester) async {
    final controller = BrandController();
    await pumpPitch(
      tester,
      controller,
      load: (_) async => throw const SiteBrandException(SiteBrandIssue.blocked),
    );

    await tester.enterText(
      find.byKey(const Key('pitch-url')),
      'https://bank.example',
    );
    await tester.tap(find.text('Apply'));
    await tester.pump();
    await tester.pump();

    expect(find.text('That site blocked the request.'), findsOneWidget);
    await tester.tap(find.text('Use demo brand'));
    await tester.pump();

    expect(controller.brand.id, pitchDemoBrand.id);
    expect(
      controller.theme.colors.accent.toARGB32(),
      pitchDemoBrand.seed.toARGB32(),
    );
    expect(find.text('Using demo brand'), findsOneWidget);
  });

  testWidgets('pitch preview opens from the index', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
    });

    await tester.pumpWidget(Project360App(controller: BrandController()));
    await tester.pumpAndSettle();

    expect(find.text('Pitch'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Pitch preview'), 200);
    await tester.tap(find.text('Pitch preview'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('pitch-url')), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
  });
}
