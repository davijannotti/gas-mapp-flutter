import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/price.dart';

class PriceService {
  final String baseUrl = 'http://localhost:8080/gasStations/id/prices';

  Future<Price> getPriceById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Price.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Price not found');
    }
  }

  Future<Price> createPrice(Price gasStation) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(gasStation.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Price.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create price');
    }
  }

}
