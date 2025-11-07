import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/evaluation.dart';
import 'auth_helper.dart';
import '../models/client.dart';
import '../models/price.dart';

class EvaluationService {
  final String baseUrl = '${ApiConfig.baseUrl}/evaluations';

  Future<void> createEvaluation({
    required Client client,
    required Price price,
    required bool trust,
}) async {
    final body = {
      'client': client.toJson(),
      'price': price.toJson(),
      'trust': trust,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: createAuthHeaders(),
      body: jsonEncode(body),
    );
    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Falha ao criar avaliação');
    }
  }

  Future<Map<String, Map<String, int>>> getEvaluationsbyGasStation(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trust-by-gasstation/$id'),
      headers: createAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      final Map<String, Map<String, int>> result = {};

      decoded.forEach((fuelName, rawData) {
        final data = rawData as Map<String, dynamic>? ?? {};
        final likes = (data['likes'] as num?)?.toInt() ?? 0;
        final dislikes = (data['dislikes'] as num?)?.toInt() ?? 0;
        result[fuelName] = {'likes': likes, 'dislikes': dislikes};
      });

      return result;
    } else {
      debugPrint('Erro ao buscar avaliações: ${response.statusCode} ${response.body}');
      throw Exception('Falha ao buscar avaliações');
    }
  }

  Future<Map<String, Map<String, int>>> getEvaluationsbyPrice(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trust-by-price/$id'),
      headers: createAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      final Map<String, Map<String, int>> result = {};

      decoded.forEach((fuelName, rawData) {
        final data = rawData as Map<String, dynamic>? ?? {};
        final likes = (data['likes'] as num?)?.toInt() ?? 0;
        final dislikes = (data['dislikes'] as num?)?.toInt() ?? 0;
        result[fuelName] = {'likes': likes, 'dislikes': dislikes};
      });

      return result;
    } else {
      debugPrint('Erro ao buscar avaliações: ${response.statusCode} ${response.body}');
      throw Exception('Falha ao buscar avaliações');
    }
  }

}