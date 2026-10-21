import 'package:flutter/material.dart';
import 'package:project360/app/theme/brand.dart';
import 'package:project360/features/pitch/bank_url.dart';

/// Logo and colours read from one bank page.
///
/// [primary] is the brand seed. Its hue still drives the card, buttons, and
/// nav. [background], [text], and [accent] map onto the page background, ink,
/// and secondary accent when they can sit in the light pitch without wiping
/// out contrast. Otherwise they stay null and the derived tokens remain.
class ExtractedSiteBrand {
  const ExtractedSiteBrand({
    required this.name,
    required this.host,
    this.logoUrl,
    this.primary,
    this.background,
    this.text,
    this.accent,
  });

  final String name;
  final String host;
  final String? logoUrl;
  final Color? primary;
  final Color? background;
  final Color? text;
  final Color? accent;

  Brand? toBrand() {
    final seed = primary;
    if (seed == null) return null;
    return Brand.website(
      name: name,
      seed: seed,
      logoUrl: logoUrl,
      sourceHost: host,
      background: background,
      text: text,
      accent: accent,
    );
  }
}

/// Pulls a brand out of HTML. [css] is the text of linked stylesheets the
/// caller already fetched — this function does not touch the network.
ExtractedSiteBrand extractSiteBrand({
  required String html,
  required Uri pageUrl,
  String css = '',
}) {
  final metas = _elements(html, 'meta');
  final links = _elements(html, 'link');
  final styleText = _stripCssComments('${_embeddedStyles(html)}\n$css');
  final variables = _cssVariables(styleText);
  final counts = _colorCounts(styleText);

  final primary =
      _preferredMeta(metas, 'theme-color') ??
      _preferredMeta(metas, 'msapplication-tilecolor') ??
      _first(variables.primary, _isChromatic) ??
      _firstCounted(counts, _isChromatic);

  Color? background;
  Color? text;
  Color? accent;
  if (primary != null) {
    background = _namedOrCounted(
      variables.background,
      counts,
      (color) => _usableBackground(color) && !_same(color, primary),
    );
    final surface = background ?? veraBrand.resolve().background;
    final page = background;
    text = _namedOrCounted(variables.text, counts, (color) {
      if (!_usableText(color, surface) || _same(color, primary)) return false;
      if (page != null && _same(color, page)) return false;
      return true;
    });
    accent = _namedOrCounted(
      variables.accent,
      counts,
      (color) => _usableAccent(color, primary),
    );
  }

  return ExtractedSiteBrand(
    name: _siteName(metas, pageUrl),
    host: displayHost(pageUrl),
    logoUrl: _logoUrl(links, metas, pageUrl),
    primary: primary,
    background: background,
    text: text,
    accent: accent,
  );
}

/// Stylesheet targets, same host first, in document order within each group.
List<Uri> stylesheetHrefs(String html, Uri pageUrl, {int limit = 2}) {
  final same = <Uri>[];
  final other = <Uri>[];
  for (final link in _elements(html, 'link')) {
    final rel = _tokens(link.attrs['rel']);
    if (!rel.contains('stylesheet')) continue;
    final href = _resolve(pageUrl, link.attrs['href']);
    if (href == null) continue;
    if (href.host.toLowerCase() == pageUrl.host.toLowerCase()) {
      same.add(href);
    } else {
      other.add(href);
    }
  }
  return [...same, ...other].take(limit).toList();
}

const Color _white = Color.fromARGB(255, 255, 255, 255);

class _El {
  const _El(this.attrs);
  final Map<String, String> attrs;
}

class _Roles {
  const _Roles({
    required this.primary,
    required this.background,
    required this.text,
    required this.accent,
  });

  final List<Color> primary;
  final List<Color> background;
  final List<Color> text;
  final List<Color> accent;
}

class _Counted {
  _Counted(this.color, this.index);
  final Color color;
  final int index;
  int n = 0;
}

List<_El> _elements(String html, String name) {
  final tags = RegExp('<$name\\b([^>]*)>', caseSensitive: false);
  final attr = RegExp(
    "([\\w:-]+)\\s*=\\s*(?:\"([^\"]*)\"|'([^']*)'|([^\\s\"'>]+))",
    caseSensitive: false,
  );
  final out = <_El>[];
  for (final match in tags.allMatches(html)) {
    final raw = match.group(1) ?? '';
    final attrs = <String, String>{};
    for (final found in attr.allMatches(raw)) {
      final key = found.group(1)!.toLowerCase();
      final value = (found.group(2) ?? found.group(3) ?? found.group(4) ?? '')
          .replaceAll('&amp;', '&');
      attrs[key] = value;
    }
    out.add(_El(attrs));
  }
  return out;
}

String _embeddedStyles(String html) {
  final buf = StringBuffer();
  final blocks = RegExp(
    r'<style\b[^>]*>([\s\S]*?)</style>',
    caseSensitive: false,
  );
  for (final match in blocks.allMatches(html)) {
    buf.writeln(match.group(1));
  }
  final inline = RegExp(
    "style\\s*=\\s*(?:\"([^\"]*)\"|'([^']*)')",
    caseSensitive: false,
  );
  for (final match in inline.allMatches(html)) {
    buf.writeln(match.group(1) ?? match.group(2));
  }
  return buf.toString();
}

String _stripCssComments(String css) {
  return css
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), ' ')
      .replaceAll(RegExp(r'<!--[\s\S]*?-->'), ' ');
}

_Roles _cssVariables(String css) {
  final primary = <Color>[];
  final background = <Color>[];
  final text = <Color>[];
  final accent = <Color>[];
  final decl = RegExp(
    r'--([A-Za-z_][\w-]*)\s*:\s*(#[0-9A-Fa-f]{3,8}|rgba?\([^;)]*\))',
    caseSensitive: false,
  );
  for (final match in decl.allMatches(css)) {
    final color = _parseCssColor(match.group(2));
    if (color == null) continue;
    switch (_role(match.group(1)!)) {
      case _CssRole.primary:
        primary.add(color);
      case _CssRole.background:
        background.add(color);
      case _CssRole.text:
        text.add(color);
      case _CssRole.accent:
        accent.add(color);
      case _CssRole.none:
        break;
    }
  }
  return _Roles(
    primary: primary,
    background: background,
    text: text,
    accent: accent,
  );
}

enum _CssRole { primary, background, text, accent, none }

_CssRole _role(String name) {
  final parts = name.toLowerCase().split(RegExp(r'[-_]'));
  bool has(String part) => parts.contains(part);
  if (has('border') || has('shadow') || has('outline')) return _CssRole.none;
  if (has('background') || has('bg') || (has('surface') && !has('card'))) {
    return _CssRole.background;
  }
  if ((has('text') || has('foreground') || has('ink')) &&
      !has('secondary') &&
      !has('muted') &&
      !has('tertiary')) {
    return _CssRole.text;
  }
  if (has('accent') || has('secondary')) return _CssRole.accent;
  if ((has('primary') || has('brand')) && !has('foreground')) {
    return _CssRole.primary;
  }
  return _CssRole.none;
}

List<_Counted> _colorCounts(String css) {
  final map = <int, _Counted>{};
  var index = 0;
  void add(Color? color) {
    if (color == null) return;
    final key = color.toARGB32();
    final existing = map[key];
    if (existing == null) {
      map[key] = _Counted(color, index)..n = 1;
    } else {
      existing.n += 1;
    }
    index++;
  }

  final hex = RegExp(r'#([0-9A-Fa-f]{8}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})\b');
  for (final match in hex.allMatches(css)) {
    add(_parseCssColor(match.group(0)));
  }
  final rgb = RegExp(
    r'rgba?\(\s*(\d{1,3})(?:\s*,\s*|\s+)(\d{1,3})(?:\s*,\s*|\s+)(\d{1,3})',
    caseSensitive: false,
  );
  for (final match in rgb.allMatches(css)) {
    add(_fromRgb(match.group(1), match.group(2), match.group(3)));
  }
  final list = map.values.toList()
    ..sort((a, b) {
      final byCount = b.n.compareTo(a.n);
      if (byCount != 0) return byCount;
      return a.index.compareTo(b.index);
    });
  return list;
}

Color? _parseCssColor(String? raw) {
  if (raw == null) return null;
  final text = raw.trim();
  if (text.startsWith('#')) return _parseHex(text);
  if (text.toLowerCase().startsWith('rgb')) return _parseRgbFunction(text);
  return null;
}

Color? _parseHex(String text) {
  var hex = text.substring(1);
  if (hex.length == 3) {
    hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
  } else if (hex.length == 8) {
    final alpha = int.tryParse(hex.substring(6), radix: 16);
    if (alpha == null || alpha < 128) return null;
    hex = hex.substring(0, 6);
  } else if (hex.length != 6) {
    return null;
  }
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return null;
  return _fromRgb(
    '${(value >> 16) & 255}',
    '${(value >> 8) & 255}',
    '${value & 255}',
  );
}

Color? _parseRgbFunction(String text) {
  final match = RegExp(
    r'rgba?\(\s*(\d{1,3})(?:\s*,\s*|\s+)(\d{1,3})(?:\s*,\s*|\s+)(\d{1,3})',
    caseSensitive: false,
  ).firstMatch(text);
  if (match == null) return null;
  return _fromRgb(match.group(1), match.group(2), match.group(3));
}

Color? _fromRgb(String? r, String? g, String? b) {
  final red = int.tryParse(r ?? '');
  final green = int.tryParse(g ?? '');
  final blue = int.tryParse(b ?? '');
  if (red == null || green == null || blue == null) return null;
  if (red > 255 || green > 255 || blue > 255) return null;
  return Color.fromARGB(255, red, green, blue);
}

Color? _preferredMeta(List<_El> metas, String name) {
  final wanted = name.toLowerCase();
  final tags = metas.where((tag) {
    final metaName = (tag.attrs['name'] ?? tag.attrs['property'] ?? '')
        .toLowerCase();
    return metaName == wanted;
  }).toList();
  final ordered = <_El>[
    ...tags.where((tag) => (tag.attrs['media'] ?? '').trim().isEmpty),
    ...tags.where(
      (tag) => (tag.attrs['media'] ?? '').toLowerCase().contains('light'),
    ),
    ...tags,
  ];
  for (final tag in ordered) {
    final color = _parseCssColor(tag.attrs['content']);
    if (color != null && _isChromatic(color)) return color;
  }
  return null;
}

String? _metaContent(List<_El> metas, String key) {
  final wanted = key.toLowerCase();
  for (final tag in metas) {
    final name = (tag.attrs['property'] ?? tag.attrs['name'] ?? '')
        .toLowerCase();
    if (name != wanted) continue;
    final content = tag.attrs['content']?.trim();
    if (content != null && content.isNotEmpty) return content;
  }
  return null;
}

String _siteName(List<_El> metas, Uri pageUrl) {
  return _clean(_metaContent(metas, 'og:site_name')) ??
      _clean(_metaContent(metas, 'application-name')) ??
      _clean(_metaContent(metas, 'apple-mobile-web-app-title')) ??
      _nameFromHost(pageUrl.host);
}

String? _clean(String? raw) {
  if (raw == null) return null;
  final text = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (text.isEmpty) return null;
  if (text.length <= 40) return text;
  return text.substring(0, 40).trim();
}

String _nameFromHost(String host) {
  var label = host.toLowerCase();
  if (label.startsWith('www.')) label = label.substring(4);
  label = label.split('.').first;
  if (label.isEmpty) return 'Bank';
  return label[0].toUpperCase() + label.substring(1);
}

String? _logoUrl(List<_El> links, List<_El> metas, Uri page) {
  final apple = <_El>[];
  final icons = <_El>[];
  for (final link in links) {
    final rel = _tokens(link.attrs['rel']);
    if (rel.contains('apple-touch-icon') ||
        rel.contains('apple-touch-icon-precomposed')) {
      apple.add(link);
    } else if (rel.contains('mask-icon')) {
      continue;
    } else if (rel.contains('icon') || rel.contains('shortcut')) {
      icons.add(link);
    }
  }
  final touch = _bestIcon(apple, page);
  if (touch != null) return touch;
  final og = _resolve(
    page,
    _metaContent(metas, 'og:image') ??
        _metaContent(metas, 'og:image:secure_url'),
  );
  if (og != null) return og.toString();
  return _bestIcon(icons, page);
}

String? _bestIcon(List<_El> tags, Uri page) {
  String? winner;
  var size = -1;
  for (final tag in tags) {
    final url = _resolve(page, tag.attrs['href']);
    if (url == null) continue;
    final edge = _iconEdge(tag);
    if (winner == null || edge > size) {
      winner = url.toString();
      size = edge;
    }
  }
  return winner;
}

int _iconEdge(_El tag) {
  final sizes = tag.attrs['sizes'] ?? '';
  var best = 0;
  for (final match in RegExp(r'(\d+)\s*[xX]\s*(\d+)').allMatches(sizes)) {
    final width = int.tryParse(match.group(1)!) ?? 0;
    final height = int.tryParse(match.group(2)!) ?? 0;
    final edge = width > height ? width : height;
    if (edge > best) best = edge;
  }
  if (best > 0) return best;
  if (sizes.trim().toLowerCase() == 'any') return 180;
  final href = (tag.attrs['href'] ?? '').toLowerCase().split('?').first;
  if (href.endsWith('.svg')) return 128;
  if (href.endsWith('.png') ||
      href.endsWith('.jpg') ||
      href.endsWith('.jpeg') ||
      href.endsWith('.webp') ||
      href.endsWith('.gif')) {
    return 32;
  }
  return 16;
}

Set<String> _tokens(String? rel) {
  return (rel ?? '')
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toSet();
}

Uri? _resolve(Uri page, String? href) {
  if (href == null) return null;
  final cleaned = href.trim();
  if (cleaned.isEmpty) return null;
  final lower = cleaned.toLowerCase();
  if (lower.startsWith('data:') ||
      lower.startsWith('javascript:') ||
      lower.startsWith('blob:')) {
    return null;
  }
  final ref = Uri.tryParse(cleaned);
  if (ref == null) return null;
  final resolved = page.resolveUri(ref);
  if (resolved.scheme != 'http' && resolved.scheme != 'https') return null;
  if (resolved.host.isEmpty) return null;
  return resolved;
}

Color? _first(List<Color> colors, bool Function(Color) ok) {
  for (final color in colors) {
    if (ok(color)) return color;
  }
  return null;
}

Color? _firstCounted(List<_Counted> counts, bool Function(Color) ok) {
  for (final counted in counts) {
    if (ok(counted.color)) return counted.color;
  }
  return null;
}

/// A declared role wins over a colour tally. If the page named a background
/// (or text, or accent) and that colour cannot sit in the pitch, leave the
/// derived token alone instead of promoting some other hex on the page.
Color? _namedOrCounted(
  List<Color> named,
  List<_Counted> counts,
  bool Function(Color) ok,
) {
  if (named.isNotEmpty) return _first(named, ok);
  return _firstCounted(counts, ok);
}

bool _same(Color a, Color b) => a.toARGB32() == b.toARGB32();

bool _isChromatic(Color color) {
  final hsl = HSLColor.fromColor(color);
  return hsl.saturation >= 0.15 &&
      hsl.lightness >= 0.08 &&
      hsl.lightness <= 0.92;
}

bool _usableBackground(Color color) =>
    HSLColor.fromColor(color).lightness >= 0.86;

bool _usableText(Color color, Color surface) {
  if (HSLColor.fromColor(color).lightness > 0.32) return false;
  if (_contrast(color, surface) < 3) return false;
  return _contrast(color, _white) >= 4;
}

bool _usableAccent(Color color, Color primary) {
  if (!_isChromatic(color) || _same(color, primary)) return false;
  return _hueDelta(color, primary) >= 18;
}

double _hueDelta(Color a, Color b) {
  final delta = (HSLColor.fromColor(a).hue - HSLColor.fromColor(b).hue).abs();
  return delta > 180 ? 360 - delta : delta;
}

double _contrast(Color a, Color b) {
  final left = a.computeLuminance();
  final right = b.computeLuminance();
  final hi = left > right ? left : right;
  final lo = left > right ? right : left;
  return (hi + 0.05) / (lo + 0.05);
}
