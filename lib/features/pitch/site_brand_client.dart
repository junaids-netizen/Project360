import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:project360/features/pitch/site_brand_extract.dart';

/// Why a pitch could not read a bank site.
enum SiteBrandIssue {
  /// DNS, timeout, TLS, or a non-success status that is not a block.
  unreachable,

  /// The origin refused the client (401, 403, 429, 451).
  blocked,
}

class SiteBrandException implements Exception {
  const SiteBrandException(this.issue);

  final SiteBrandIssue issue;
}

/// Fetches a public page and the first stylesheets it links.
///
/// iOS, Android, and desktop use dart:io, so they can read a bank origin
/// directly. Flutter web goes through the browser and fails when the site
/// does not send Access-Control-Allow-Origin. That limit is the browser's;
/// this client does not try to route around it.
class SiteBrandClient {
  // Named `client` for callers. An initializing formal would publish `_client`.
  // ignore: prefer_initializing_formals
  SiteBrandClient({http.Client? client}) : _client = client;

  final http.Client? _client;

  static const Duration _overall = Duration(seconds: 15);
  static const Duration _perRequest = Duration(seconds: 8);
  static const int _maxBytes = 1500000;
  static const int _maxCss = 100000;

  static const String _userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 '
      'Mobile/15E148 Safari/604.1';

  Future<ExtractedSiteBrand> load(Uri url) async {
    final client = _client ?? http.Client();
    final close = _client == null;
    final started = DateTime.now();
    try {
      final page = await _fetch(client, url, _budget(started));
      final issue = _issueForStatus(page.status);
      if (issue != null) throw SiteBrandException(issue);

      final css = StringBuffer();
      for (final href in stylesheetHrefs(page.body, page.url)) {
        try {
          final sheet = await _fetch(client, href, _budget(started));
          if (sheet.status < 200 || sheet.status >= 300) continue;
          final text = sheet.body;
          css.writeln(
            text.length > _maxCss ? text.substring(0, _maxCss) : text,
          );
        } catch (_) {
          // A stylesheet that fails does not fail the page.
        }
      }
      return extractSiteBrand(
        html: page.body,
        pageUrl: page.url,
        css: css.toString(),
      );
    } on SiteBrandException {
      rethrow;
    } on TimeoutException {
      throw const SiteBrandException(SiteBrandIssue.unreachable);
    } on http.ClientException {
      throw const SiteBrandException(SiteBrandIssue.unreachable);
    } catch (_) {
      throw const SiteBrandException(SiteBrandIssue.unreachable);
    } finally {
      if (close) client.close();
    }
  }

  Duration _budget(DateTime started) {
    final left = _overall - DateTime.now().difference(started);
    if (left < const Duration(milliseconds: 200)) {
      throw TimeoutException('site brand fetch');
    }
    return left < _perRequest ? left : _perRequest;
  }

  Future<({int status, String body, Uri url})> _fetch(
    http.Client client,
    Uri url,
    Duration budget,
  ) async {
    final request = http.Request('GET', url)
      ..followRedirects = true
      ..maxRedirects = 5
      ..headers.addAll({
        'User-Agent': _userAgent,
        'Accept': 'text/html,application/xhtml+xml,text/css;q=0.9,*/*;q=0.8',
      });
    final streamed = await client.send(request).timeout(budget);
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in streamed.stream.timeout(budget)) {
      bytes.add(chunk);
      if (bytes.length >= _maxBytes) break;
    }
    return (
      status: streamed.statusCode,
      body: utf8.decode(bytes.takeBytes(), allowMalformed: true),
      url: streamed.request?.url ?? url,
    );
  }
}

SiteBrandIssue? _issueForStatus(int status) {
  if (status >= 200 && status < 300) return null;
  if (status == 401 || status == 403 || status == 429 || status == 451) {
    return SiteBrandIssue.blocked;
  }
  return SiteBrandIssue.unreachable;
}
