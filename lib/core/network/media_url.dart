import 'api_constants.dart';

String resolveMediaUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  final uri = Uri.tryParse(url);
  if (uri != null && uri.hasScheme) return url;
  final base = ApiConstants.baseUrl.replaceFirst(RegExp(r'/$'), '');
  return '$base${url.startsWith('/') ? '' : '/'}$url';
}
