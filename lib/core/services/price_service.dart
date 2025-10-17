import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/price.dart';
import '../models/fuel.dart';
import 'auth_helper.dart';
import 'fuel_service.dart';

class PriceService {
  final String baseUrl = 'https://gasmapp-backend-fork-production.up.railway.app/prices';
  final FuelService fuelService = FuelService();

  Future<Price> createPrice({
    required int gasStationId,
    required String fuelName,
    required int clientId,
    required double priceValue,
  }) async {
    Fuel? fuel = await fuelService.getFuelByName(gasStationId, fuelName);

    if (fuel == null) {
      final newFuel = Fuel(
        gasStationId: gasStationId,
        name: fuelName,
        price: null,
      );
      fuel = await fuelService.createFuel(newFuel);
    }

    final price = Price(
      fuelId: fuel.id ?? 0,
      clientId: 1,
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
      throw Exception('Failed to create price (${response.statusCode})\n${response.body}');
    }
  }
}
