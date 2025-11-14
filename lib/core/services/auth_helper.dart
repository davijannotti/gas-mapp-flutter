import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthHelper {
  static final _storage = FlutterSecureStorage();
  static String? accessToken; // Token fica na memória

  /// Carrega o token salvo no Secure Storage para a memória
  static Future<void> loadToken() async {
    accessToken = await _storage.read(key: 'access_token');
  }

  static Future<void> saveToken(String token) async {
    accessToken = token;
    await _storage.write(key: 'access_token', value: token);
  }

  Map<String, String> createAuthHeadersNOVO() {
    final token = AuthHelper.accessToken;

    if (token == null) {
      return {
        'Content-Type': 'application/json',
      };
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> createAuthHeaders() {
    const username = 'admin';
    const password = 'admin';
    final credentials = base64Encode(utf8.encode('$username:$password'));

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $credentials',
    };
  }

}
