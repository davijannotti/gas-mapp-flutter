import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthHelper {
  static final _storage = FlutterSecureStorage();
  static String? accessToken;

  static Future<void> loadToken() async {
    accessToken = await _storage.read(key: 'access_token');
  }

  static Future<void> saveToken(String token) async {
    accessToken = token;
    await _storage.write(key: 'access_token', value: token);
  }

  static Future<void> clearToken() async {
    accessToken = null;
    await _storage.delete(key: 'access_token');
  }

  Map<String, String> createAuthHeaders() {
    final token = AuthHelper.accessToken;

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
