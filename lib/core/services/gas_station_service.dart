import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/gas_station.dart';
import 'auth_helper.dart';

class GasStationService {
  final String baseUrl = '${ApiConfig.baseUrl}/gasstations';

  Future<List<GasStation>> getNearbyStations(double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('$baseUrl/nearby?latitude=$latitude&longitude=$longitude&delta=1&timestamp=${DateTime.now().millisecondsSinceEpoch}'),
      headers: createAuthHeaders(),
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
}
