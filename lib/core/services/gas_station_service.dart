import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gas_station.dart';

class GasStationService {
  final String baseUrl = 'https://gasmapp-backend-fork-production.up.railway.app/gasstations';

  // --- NEW: Authentication Headers ---
  Map<String, String> _getAuthHeaders() {
    final username = 'admin';
    final password = 'admin';
    // Encode the username and password in Base64
    final credentials = base64Encode(utf8.encode('$username:$password'));

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $credentials',
    };
  }

  Future<List<GasStation>> getGasStations() async {
    // Add headers to the request
    final response = await http.get(Uri.parse(baseUrl), headers: _getAuthHeaders());
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GasStation.fromJson(json)).toList();
    } else {
      throw Exception('Fail to load gas stations: ${response.statusCode}');
    }
  }

  Future<List<GasStation>> getNearbyStations(double lat, double lng) async {
    final url = Uri.parse('$baseUrl/nearby?lat=$lat&lng=$lng');

    // Add headers to the request
    final response = await http.get(url, headers: _getAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GasStation.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar postos: ${response.statusCode}');
    }
  }

  Future<GasStation> getGasStationById(int id) async {
    // Add headers to the request
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: _getAuthHeaders());

    if (response.statusCode == 200) {
      return GasStation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('GasStation not found: ${response.statusCode}');
    }
  }

  Future<GasStation> createGasStation(GasStation gasStation) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      // Use the helper method for headers
      headers: _getAuthHeaders(),
      body: jsonEncode(gasStation.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return GasStation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create gas station: ${response.statusCode}');
    }
  }

  Future<void> updateGasStation(GasStation gasStation) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${gasStation.id}'),
      // Use the helper method for headers
      headers: _getAuthHeaders(),
      body: jsonEncode(gasStation.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update gas station: ${response.statusCode}');
    }
  }

  Future<void> deleteGasStation(int id) async {
    // Add headers to the request
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: _getAuthHeaders());

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete gas station: ${response.statusCode}');
    }
  }
}
