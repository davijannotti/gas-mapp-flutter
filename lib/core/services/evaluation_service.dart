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
      headers: createAuthHeaders(),
      body: jsonEncode(evaluation.toJson()),
    );
    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 201) {
      return Evaluation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao criar avaliação');
    }
  }
}