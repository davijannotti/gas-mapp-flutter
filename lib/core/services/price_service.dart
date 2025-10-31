import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/price.dart';
import '../models/fuel.dart';
import '../models/client.dart';
import '../models/gas_station.dart';
import 'auth_helper.dart';
import 'fuel_service.dart';

class PriceService {
  final String baseUrl = '${ApiConfig.baseUrl}/prices';
  final FuelService fuelService = FuelService();

  Future<Price> createPrice({
    required Fuel fuel,
    required Client client,
    required double priceValue,
  }) async {
    final price = Price(
      fuel: fuel,
      client: client,
      price: priceValue,
    );

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: createAuthHeaders(),
      body: jsonEncode(price.toJson()),
    );



    if (response.statusCode == 201 || response.statusCode == 200) {
      return Price.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao criar preço (${response.statusCode}) ${response.body}');
    }
  }
}
