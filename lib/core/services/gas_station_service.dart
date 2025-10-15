import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gas_station.dart';

class GasStationService {
  final String baseUrl = 'http://localhost:8080/gasStations';

  Future<List<GasStation>> getGasStations() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GasStation.fromJson(json)).toList();
    } else {
      throw Exception('Fail to load gas stations');
    }
  }

  Future<GasStation> getGasStationById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return GasStation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('GasStation not found');
    }
  }

  Future<GasStation> createGasStation(GasStation gasStation) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(gasStation.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return GasStation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create gas station');
    }
  }

  Future<void> updateGasStation(GasStation gasStation) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${gasStation.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(gasStation.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update gas station');
    }
  }

  Future<void> deleteGasStation(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete gas station');
    }
  }
}
