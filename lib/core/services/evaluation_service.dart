import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/evaluation.dart';
import 'auth_helper.dart';

class EvaluationService {
  final String baseUrl = '${ApiConfig.baseUrl}/evaluations';


  Future<Evaluation> createEvaluation(Evaluation evaluation) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: AuthHelper().createAuthHeaders(),
      body: jsonEncode(evaluation.toJson()),
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Falha ao criar avaliação');
    }

    return Evaluation.fromJson(jsonDecode(response.body));
  }


  Future<List<Evaluation>> getEvaluationsByGasStation(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/by-gasstation/$id'),
      headers: AuthHelper().createAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => Evaluation.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao buscar avaliações');
    }
  }


  Future<List<Evaluation>> getEvaluationsByPrice(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/by-price/$id'),
      headers: AuthHelper().createAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => Evaluation.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao buscar avaliações');
    }
  }

  Future<Map<String, Map<String, int>>> getTrustSummaryByGasStation(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/trust-by-gasstation/$id'),
      headers: AuthHelper().createAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      final result = <String, Map<String, int>>{};

      decoded.forEach((fuelName, rawData) {
        final map = rawData as Map<String, dynamic>? ?? {};
        result[fuelName] = {
          'likes': (map['likes'] as num?)?.toInt() ?? 0,
          'dislikes': (map['dislikes'] as num?)?.toInt() ?? 0,
        };
      });

      return result;
    } else {
      throw Exception('Falha ao buscar resumo de avaliações');
    }
  }
}
