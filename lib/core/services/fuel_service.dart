import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fuel.dart';
import 'auth_helper.dart';

class FuelService {
  final String baseUrl = 'https://gasmapp-backend-fork-production.up.railway.app/fuels';
  final String gasStationsUrl = 'https://gasmapp-backend-fork-production.up.railway.app/gasstations';

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
    // Busca os dados completos do posto pelo ID
    final url = Uri.parse('$gasStationsUrl/$gasStationId');
    final response = await http.get(url, headers: createAuthHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Verifica se o JSON contém a lista de combustíveis
      if (data.containsKey('fuels') && data['fuels'] is List) {
        final List<dynamic> fuels = data['fuels'];

        // Procura o combustível pelo nome (ignorando maiúsculas/minúsculas)
        final fuel = fuels.firstWhere(
              (f) => (f['name'] as String).toLowerCase() == fuelName.toLowerCase(),
          orElse: () => null,
        );

        if (fuel != null) {
          return Fuel.fromJson(fuel);
        }
      }

      // Se não encontrou o combustível ou não havia lista de fuels
      return null;
    } else {
      throw Exception(
        'Failed to get gas station ($gasStationId): ${response.statusCode}\n${response.body}',
      );
    }
  }
}
