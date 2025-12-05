import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_helper.dart';

class AuthService {
  final String baseUrl = '${ApiConfig.baseUrl}/auth';

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    debugPrint("Login status: ${response.statusCode}");
    debugPrint("Login body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      if (token != null) {
        await AuthHelper.saveToken(token);
        return true;
      }
    }

    return false;
  }

  Future<void> logout() async {
    await AuthHelper.clearToken();
  }
}
