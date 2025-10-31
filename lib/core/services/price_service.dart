import 'dart:convert';
import 'package:flutter_app/core/models/gas_station.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/price.dart';
import '../models/fuel.dart';
import '../models/client.dart';
import '../models/gas_station.dart';
import 'auth_helper.dart';
import 'fuel_service.dart';

class PriceService {
  final String baseUrl = 'https://gasmapp-backend-production.up.railway.app/prices';
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
      throw Exception('Falha ao criar preço (${response.statusCode})
${response.body}');
    }
  }

  Future<void> uploadPriceImage(File imageFile) async{
    final url = Uri.parse(baseUrl);
    final request = http.MultipartRequest('POST', url);
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path,),
    );

    request.headers.addAll(
      createAuthHeaders(),
    );

    final response = await request.send();

    if(response.statusCode == 200){
      print('Upload Completed');
    } else {
      print('Upload Failed Status: ${response.statusCode}');
    }
  }
}
