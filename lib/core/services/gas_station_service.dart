import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/gas_station.dart';
import 'auth_helper.dart';

class GasStationService {
  final String baseUrl = '${ApiConfig.baseUrl}/gasstations';

  Future<List<GasStation>> getGasStations() async {
    // Add headers to the request
    final response = await http.get(Uri.parse(baseUrl), headers: AuthHelper().createAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => GasStation.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar postos de gasolina: ${response.statusCode}');
    }
  }

  Future<List<GasStation>> getNearbyStations(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('$baseUrl/nearby?latitude=$latitude&longitude=$longitude&delta=1&timestamp=${DateTime.now().millisecondsSinceEpoch}'),
      headers: AuthHelper().createAuthHeaders(),
    );
    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => GasStation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load nearby gas stations');
    }
  }

  Future<GasStation> getGasStationById(int id) async {
    // Add headers to the request
    final response = await http.get(Uri.parse('$baseUrl/$id'), headers: AuthHelper().createAuthHeaders());

    if (response.statusCode == 200) {
      return GasStation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Posto de gasolina não encontrado: ${response.statusCode}');
    }
  }

  Future<List<GasStation>> getGasStationCheapest(double lat, double log, String fuel_type) async{
    final url = Uri.parse('$baseUrl/cheapest?latitude=$lat&longitude=$log&delta=1&fuelType=$fuel_type');

    final response = await http.get(url, headers: AuthHelper().createAuthHeaders());

    if(response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => GasStation.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar posto mais barato: ${response.statusCode}');
    }
  }
}
