import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/gas_station.dart';
import 'auth_helper.dart';

class GasStationService {
  final String baseUrl = '${ApiConfig.baseUrl}/gasstations';

  Future<List<GasStation>> getGasStations() async {
    // Add headers to the request
    final response = await http.get(Uri.parse(baseUrl), headers: createAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GasStation.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar postos de gasolina: ${response.statusCode}');
    }
  }

  Future<List<GasStation>> getNearbyStations(double lat, double lng) async {
    final url = Uri.parse('$baseUrl/nearby?latitude=$lat&longitude=$lng&delta=1');

    // Add headers to the request
    final response = await http.get(url, headers: createAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GasStation.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar postos: ${response.statusCode}');
    }
  }

  Future<GasStation> getGasStationById(int id) async {
    // Add headers to the request
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: createAuthHeaders());

    if (response.statusCode == 200) {
      return GasStation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Posto de gasolina não encontrado: ${response.statusCode}');
    }
  }

  Future<GasStation> createGasStation(GasStation gasStation) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      // Use the helper method for headers
      headers: createAuthHeaders(),
      body: jsonEncode(gasStation.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return GasStation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao criar posto de gasolina: ${response.statusCode}');
    }
  }

  Future<void> updateGasStation(GasStation gasStation) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${gasStation.id}'),
      // Use the helper method for headers
      headers: createAuthHeaders(),
      body: jsonEncode(gasStation.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar posto de gasolina: ${response.statusCode}');
    }
  }

  Future<void> deleteGasStation(int id) async {
    // Add headers to the request
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: createAuthHeaders());

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Falha ao deletar posto de gasolina: ${response.statusCode}');
    }
  }
}
