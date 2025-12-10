import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/models/client.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_helper.dart';

class AuthService {
  final String baseUrl = '${ApiConfig.baseUrl}/auth';

  Future<Client> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: AuthHelper().createAuthHeaders(),
    );

    debugPrint('Get Me status: ${response.statusCode}');
    debugPrint('Get Me body: ${response.body}');

    if (response.statusCode == 200) {
      return Client.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get user');
    }
  }

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
      String? token;
      try {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          token = data['token'];
        } else if (data is String) {
          token = data;
        }
      } catch (e) {
        // Se falhar ao fazer o parse do JSON, assume que o corpo é o próprio token
        // já que o status code é 200
        token = response.body;
      }

      if (token != null && token.isNotEmpty) {
        await AuthHelper.saveToken(token);
        return true;
      } else {
        throw FormatException('Token não encontrado na resposta: ${response.body}');
      }
    } else {
      debugPrint('Login failed with status: ${response.statusCode}');
      // Tenta extrair mensagem de erro do servidor se for JSON
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map && errorData['message'] != null) {
          throw Exception(errorData['message']);
        }
      } catch (_) {
        // Ignora erro de parse no erro
      }
      // Se não conseguiu extrair mensagem específica, lança erro genérico com o corpo
      throw Exception('Falha no login (${response.statusCode}): ${response.body}');
    }

    return false;
  }

  Future<void> logout() async {
    await AuthHelper.clearToken();
  }
}
