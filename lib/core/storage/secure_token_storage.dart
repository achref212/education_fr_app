import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists and retrieves the JWT access token using encrypted storage.
class SecureTokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const String _tokenKey = 'access_token';

  final FlutterSecureStorage _storage;

  Future<String?> getAccessToken() => _storage.read(key: _tokenKey);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearAccessToken() => _storage.delete(key: _tokenKey);

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
