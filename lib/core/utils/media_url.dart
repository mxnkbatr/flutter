import 'package:sacred_app/core/api/api_config.dart';

/// API origin without `/api` suffix — for `/uploads/...` static files.
String get apiOrigin {
  final uri = Uri.parse(ApiConfig.baseUrl);
  return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
}

/// Rewrites localhost/relative upload paths so images load on physical devices.
String resolveMediaUrl(String? url) {
  if (url == null || url.isEmpty) return '';

  if (url.startsWith('/')) {
    return '$apiOrigin$url';
  }

  if (!url.startsWith('http')) return url;

  final uri = Uri.tryParse(url);
  if (uri == null) return url;

  const localHosts = {'localhost', '127.0.0.1', '10.0.2.2'};
  if (!localHosts.contains(uri.host)) return url;

  final apiUri = Uri.parse(apiOrigin);
  return uri
      .replace(
        scheme: apiUri.scheme,
        host: apiUri.host,
        port: apiUri.hasPort ? apiUri.port : null,
      )
      .toString();
}
