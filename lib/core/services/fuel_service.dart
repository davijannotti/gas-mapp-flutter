import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/fuel.dart';
import '../models/gas_station.dart';
import 'auth_helper.dart';

class FuelService {
  final String baseUrl = '${ApiConfig.baseUrl}/fuels';
  final String gasStationsUrl = '${ApiConfig.baseUrl}/gasstations';

  Future<Fuel> getFuelById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: createAuthHeaders(),
    );
    debugPrint(' get fuel id Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return Fuel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Combustível não encontrado (${response.statusCode})');
    }
  }

  Future<Fuel> createFuel(Fuel fuel) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: createAuthHeaders(),
      body: json.encode(fuel.toJson()),
    );
    debugPrint('create fuel req body ${json.encode(fuel.toJson())}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 201) {
      return Fuel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to create fuel');
    }
  }


  Future<Fuel?> getFuelByName(GasStation gasStation, String fuelName) async {
    try{
      return gasStation.fuel?.firstWhere(
            (f) => f.name.toLowerCase() == fuelName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
