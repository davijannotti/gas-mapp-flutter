import 'dart:convert';
import 'package:flutter_app/core/models/gas_station.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/price.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/client.dart';
import '../models/fuel.dart';
import '../models/client.dart';
import '../models/gas_station.dart';
import 'auth_helper.dart';

class PriceService {
  final String baseUrl = '${ApiConfig.baseUrl}/prices';

  Future<void> createPrice({
    required Fuel fuel,
    required Client client,
    required double priceValue,
  }) async {
    final body = {
      'fuel': fuel.toJson(),
      'client': client.toJson(),
      'price': priceValue,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: createAuthHeaders(),
      body: jsonEncode(body),
    );
    debugPrint('create price req body ${json.encode(body)}');

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Failed to create price');
    }
  }
}