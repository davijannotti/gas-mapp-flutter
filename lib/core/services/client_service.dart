import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/client.dart';
import 'auth_helper.dart';

class ClientService {
  final String baseUrl = '${ApiConfig.baseUrl}/clients';

  Future<Client> getClientById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: createAuthHeaders(),
    );
    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return Client.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Cliente não encontrado');
    }
  }
}