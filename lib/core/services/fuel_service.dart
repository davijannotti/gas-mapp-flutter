import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fuel.dart';
import '../models/gas_station.dart';
import 'auth_helper.dart';

class FuelService {
  final String baseUrl = 'https://gasmapp-backend-production.up.railway.app/fuels';
  final String gasStationsUrl = 'https://gasmapp-backend-production.up.railway.app/gasstations';

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


  Future<Fuel?> getFuelByName(int gasStationId, String fuelName) async {
    final url = Uri.parse('$gasStationsUrl/$gasStationId');
    final response = await http.get(url, headers: createAuthHeaders());

    if (response.statusCode == 200) {

      final json = jsonDecode(response.body);
      final gasStation = GasStation.fromJson(json);


      try{
        return gasStation.fuel.firstWhere(
              (f) => f.name.toLowerCase() == fuelName.toLowerCase(),
        );
      } catch (e) {
        return null;
      }



    } else {
      throw Exception(
        'Failed to get gas station ($gasStationId): ${response.statusCode}\n${response.body}',
      );
    }
  }
}
