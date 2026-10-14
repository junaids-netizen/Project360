import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:project360/features/pitch/site_brand_client.dart';

void main() {
  const page = 'https://bank.example/';
  const html = '''
    <meta property="og:site_name" content="Northwind">
    <meta name="theme-color" content="#0B5FFF">
    <link rel="apple-touch-icon" href="/touch.png">
    <link rel="stylesheet" href="/brand.css">
  ''';

  test('reads the page and a linked stylesheet', () async {
    final client = SiteBrandClient(
      client: MockClient((request) async {
        expect(request.headers['user-agent'], contains('Safari'));
        if (request.url.path.endsWith('.css')) {
          return http.Response(':root { --accent: #E2A100; }', 200);
        }
        return http.Response(html, 200);
      }),
    );

    final brand = await client.load(Uri.parse(page));
    expect(brand.name, 'Northwind');
    expect(brand.primary?.toARGB32(), 0xFF0B5FFF);
    expect(brand.logoUrl, 'https://bank.example/touch.png');
    expect(brand.accent?.toARGB32(), 0xFFE2A100);
  });

  test('a stylesheet failure still returns the page brand', () async {
    final client = SiteBrandClient(
      client: MockClient((request) async {
        if (request.url.path.endsWith('.css')) {
          throw http.ClientException('nope', request.url);
        }
        return http.Response(html, 200);
      }),
    );

    final brand = await client.load(Uri.parse(page));
    expect(brand.primary?.toARGB32(), 0xFF0B5FFF);
    expect(brand.accent, isNull);
  });

  test('403 is a block and 500 is unreachable', () async {
    Future<void> expectIssue(int status, SiteBrandIssue issue) async {
      final client = SiteBrandClient(
        client: MockClient((request) async => http.Response('no', status)),
      );
      expect(
        client.load(Uri.parse(page)),
        throwsA(
          isA<SiteBrandException>().having(
            (error) => error.issue,
            'issue',
            issue,
          ),
        ),
      );
    }

    await expectIssue(403, SiteBrandIssue.blocked);
    await expectIssue(500, SiteBrandIssue.unreachable);
  });
}
