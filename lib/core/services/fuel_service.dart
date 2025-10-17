import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fuel.dart';
import 'auth_helper.dart';

class FuelService {
  final String baseUrl = 'https://gasmapp-backend-production.up.railway.app/fuels';

  // Busca combustível por ID
  Future<Fuel> getFuelById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: createAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return Fuel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fuel not found (${response.statusCode})');
    }
  }

  // Cria combustível
  Future<Fuel> createFuel(Fuel fuel) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: createAuthHeaders(),
      body: jsonEncode(fuel.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Fuel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create Fuel (${response.statusCode})\n${response.body}');
    }
  }

  // Busca combustível pelo nome e posto, retorna null se não existir
  Future<Fuel?> getFuelByName(int gasStationId, String fuelName) async {
    // Aqui estou assumindo que o backend permite filtrar por query params
    final url = Uri.parse('$baseUrl?gasStationId=$gasStationId&name=$fuelName');
    final response = await http.get(url, headers: createAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print(data);
      if (data.isNotEmpty) {
        return Fuel.fromJson(data.first); // pega o primeiro resultado
      } else {
        return null; // não encontrou
      }
    } else {
      throw Exception('Failed to get fuel by name (${response.statusCode})\n${response.body}');
    }
  }
}
