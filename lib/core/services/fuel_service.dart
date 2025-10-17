import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fuel.dart';

class FuelService {
  final String baseUrl = 'https://gasmapp-backend-fork-production.up.railway.app/fuels';

  Future<Fuel> getFuelById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Fuel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Fuel not found');
    }
  }

  Future<Fuel> createFuel(Fuel fuel) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(fuel.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Fuel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create Fuel');
    }
  }

}
