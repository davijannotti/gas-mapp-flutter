import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/client.dart';

class ClientService {
  final String baseUrl = '${ApiConfig.baseUrl}/clients';

  Future<List<Client>> getClients() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Client.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar clientes');
    }
  }

  Future<Client> getClientById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

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

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Client.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao criar cliente');
    }
  }

  Future<void> updateClient(Client client) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${client.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(client.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar cliente');
    }
  }

  Future<void> deleteClient(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Falha ao deletar cliente');
    }
  }
}
