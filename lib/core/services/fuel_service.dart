import 'dart:convert';
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
      body: jsonEncode(fuel.toJson()),
    );
    print("RESPOSTA DO CREATE FUEL");
    print(response.body);
    print(fuel.toJson());

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Fuel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao criar Combustível (${response.statusCode})\n${response.body}');
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