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
      headers: AuthHelper().createAuthHeaders(),
    );
    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return Client.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Cliente não encontrado');
    }
  }

  Future<Client> createClient(Client client) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(client.toJson()),
    );

    debugPrint('Create Client status: ${response.statusCode}');
    debugPrint('Create Client body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Client.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao criar cliente: ${response.body}');
    }
  }


}