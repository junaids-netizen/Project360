/// Normalises what someone pastes into the pitch field.
///
/// A bare host becomes https. http is upgraded, because the pitch asks for
/// an https site and bank origins redirect there anyway. Anything that is
/// not a website — a word, a file path, a script URL — is rejected.
Uri? parseBankUrl(String input) {
  var raw = input.trim();
  if (raw.isEmpty) return null;
  while (raw.endsWith('.') || raw.endsWith(',') || raw.endsWith(';')) {
    raw = raw.substring(0, raw.length - 1).trim();
  }
  if (raw.isEmpty) return null;
  if (raw.startsWith('//')) {
    raw = 'https:$raw';
  } else if (!raw.contains('://')) {
    raw = 'https://$raw';
  }

  final uri = Uri.tryParse(raw);
  if (uri == null) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  if (!_usableHost(uri.host)) return null;
  if (uri.scheme == 'http') return uri.replace(scheme: 'https');
  return uri;
}

/// Host shown in the pitch, without a leading www.
String displayHost(Uri uri) {
  final host = uri.host.toLowerCase();
  if (host.startsWith('www.')) return host.substring(4);
  return host;
}

bool _usableHost(String host) {
  if (host.isEmpty || host.contains(' ')) return false;
  final parts = host.split('.');
  if (parts.length < 2) return false;
  return parts.every((part) => part.isNotEmpty);
}
