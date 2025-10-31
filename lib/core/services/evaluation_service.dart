import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/evaluation.dart';

class EvaluationService {
  final String baseUrl = '${ApiConfig.baseUrl}/evaluations';

  Future<List<Evaluation>> getEvaluations() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Evaluation.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar avaliações');
    }
  }

  Future<Evaluation> getEvaluationById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Evaluation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Avaliação não encontrada');
    }
  }

  Future<Evaluation> createEvaluation(Evaluation evaluation) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(evaluation.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Evaluation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao criar avaliação');
    }
  }

  Future<void> updateEvaluation(Evaluation evaluation) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${evaluation.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(evaluation.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar avaliação');
    }
  }

  Future<void> deleteEvaluation(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Falha ao deletar avaliação');
    }
  }
}
