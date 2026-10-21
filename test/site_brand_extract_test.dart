import 'package:flutter_test/flutter_test.dart';
import 'package:project360/app/theme/brand.dart';
import 'package:project360/features/pitch/site_brand_extract.dart';

const _page = 'https://www.bank.example/welcome/';

const _fullPage = '''
<!doctype html>
<html>
<head>
  <title>Ignored title</title>
  <meta property="og:site_name" content="Northwind Bank">
  <meta name="theme-color" content="#0B5FFF">
  <meta name="msapplication-TileColor" content="#111111">
  <meta property="og:image" content="/og.png">
  <link rel="apple-touch-icon" sizes="120x120" href="/touch-120.png">
  <link rel="apple-touch-icon" sizes="180x180" href="/touch-180.png?x=1&amp;y=2">
  <link rel="icon" sizes="16x16" href="/fav-16.png">
  <link rel="icon" sizes="32x32" href="/fav-32.png">
  <link rel="stylesheet" href="https://cdn.example/remote.css">
  <link rel="stylesheet" href="/local.css">
  <style>
    :root {
      --background: #F4F6F8;
      --text: #102033;
      --accent: #E2A100;
      --primary: #FF00AA;
    }
    a { color: #0B5FFF; }
  </style>
</head>
</html>
''';

void main() {
  final page = Uri.parse(_page);

  test('prefers apple-touch-icon, theme-color, and named surfaces', () {
    final brand = extractSiteBrand(html: _fullPage, pageUrl: page);

    expect(brand.name, 'Northwind Bank');
    expect(brand.host, 'bank.example');
    expect(brand.logoUrl, 'https://www.bank.example/touch-180.png?x=1&y=2');
    expect(brand.primary?.toARGB32(), 0xFF0B5FFF);
    expect(brand.background?.toARGB32(), 0xFFF4F6F8);
    expect(brand.text?.toARGB32(), 0xFF102033);
    expect(brand.accent?.toARGB32(), 0xFFE2A100);

    final mapped = brand.toBrand()!;
    final colors = mapped.resolve();
    expect(mapped.id, Brand.websiteId);
    expect(colors.accent.toARGB32(), 0xFF0B5FFF);
    expect(colors.background.toARGB32(), 0xFFF4F6F8);
    expect(colors.textPrimary.toARGB32(), 0xFF102033);
    expect(colors.accentSecondary.toARGB32(), 0xFFE2A100);
    expect(
      colors.cardSurface.toARGB32(),
      isNot(veraBrand.resolve().cardSurface.toARGB32()),
    );
  });

  test('og:image wins when there is no apple touch icon', () {
    const html = '''
      <meta property="og:image" content="icons/og.png">
      <link rel="icon" sizes="64x64" href="/fav.png">
      <meta name="theme-color" content="#0B5FFF">
    ''';
    final brand = extractSiteBrand(html: html, pageUrl: page);
    expect(brand.logoUrl, 'https://www.bank.example/welcome/icons/og.png');
  });

  test('largest favicon is used when touch and og images are absent', () {
    const html = '''
      <link rel="icon" href="/fav.ico">
      <link rel="shortcut icon" sizes="32x32" href="/fav-32.png">
      <link rel="icon" sizes="16x16" href="/fav-16.png">
      <meta name="theme-color" content="#0B5FFF">
    ''';
    final brand = extractSiteBrand(html: html, pageUrl: page);
    expect(brand.logoUrl, 'https://www.bank.example/fav-32.png');
  });

  test('a grey theme-color falls through to a chromatic tile colour', () {
    const html = '''
      <meta name="theme-color" content="#ffffff">
      <meta name="msapplication-TileColor" content="#0A3D91">
    ''';
    final brand = extractSiteBrand(html: html, pageUrl: page);
    expect(brand.primary?.toARGB32(), 0xFF0A3D91);
    expect(brand.name, 'Bank');
  });

  test('css primary is used when the page declares no meta colour', () {
    const html = '''
      <style>:root { --color-primary: #117ACA; }</style>
    ''';
    final brand = extractSiteBrand(html: html, pageUrl: page);
    expect(brand.primary?.toARGB32(), 0xFF117ACA);
  });

  test('linked css can supply the accent', () {
    const html = '<meta name="theme-color" content="#0B5FFF">';
    final brand = extractSiteBrand(
      html: html,
      pageUrl: page,
      css: ':root { --accent: #E2A100; }',
    );
    expect(brand.accent?.toARGB32(), 0xFFE2A100);
  });

  test('inline styles supply a small palette when nothing is named', () {
    const html = '''
      <body style="background-color: #F7F4EF; color: #1A1A1A">
        <div style="color:#CC3344"></div>
        <div style="color:#CC3344"></div>
      </body>
    ''';
    final brand = extractSiteBrand(html: html, pageUrl: page);
    expect(brand.primary?.toARGB32(), 0xFFCC3344);
    expect(brand.background?.toARGB32(), 0xFFF7F4EF);
    expect(brand.text?.toARGB32(), 0xFF1A1A1A);
    expect(brand.accent, isNull);
  });

  test('unusable surfaces are left for the derived tokens', () {
    const html = '''
      <meta name="theme-color" content="#0B5FFF">
      <style>
        :root {
          --background: #0B5FFF;
          --text: #FFFFFF;
          --accent: #0B5FFF;
        }
      </style>
    ''';
    final brand = extractSiteBrand(html: html, pageUrl: page);
    expect(brand.primary?.toARGB32(), 0xFF0B5FFF);
    expect(brand.background, isNull);
    expect(brand.text, isNull);
    expect(brand.accent, isNull);
    expect(brand.toBrand()!.resolve().background.toARGB32(), 0xFFFAFAFA);
  });

  test('a transparent theme-color is ignored', () {
    const html = '''
      <meta name="theme-color" content="#0B5FFF00">
      <meta name="msapplication-TileColor" content="#0A3D91">
    ''';
    final brand = extractSiteBrand(html: html, pageUrl: page);
    expect(brand.primary?.toARGB32(), 0xFF0A3D91);
  });

  test('three-digit hex expands', () {
    const html = '<meta name="theme-color" content="#abc">';
    final brand = extractSiteBrand(html: html, pageUrl: page);
    expect(brand.primary?.toARGB32(), 0xFFAABBCC);
  });

  test('stylesheet links prefer the page host', () {
    final hrefs = stylesheetHrefs(_fullPage, page, limit: 1);
    expect(hrefs.single.toString(), 'https://www.bank.example/local.css');
  });

  test('a page with no colour does not become a brand', () {
    final brand = extractSiteBrand(html: '<html></html>', pageUrl: page);
    expect(brand.primary, isNull);
    expect(brand.toBrand(), isNull);
  });
}
