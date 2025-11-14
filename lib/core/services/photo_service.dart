import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PhotoService {
  final String baseUrl = 'http://172.18.190.16:5000/upload'; // AJUSTE AQUI

  Future<List<dynamic>> uploadPhoto(File image, int stationId) async {
    final uri = Uri.parse('$baseUrl?stationId=$stationId');

    final request = http.MultipartRequest("POST", uri);

    // NÃO TEM AUTENTICAÇÃO NESSE ENDPOINT
    request.headers.addAll({
      "Content-Type": "multipart/form-data",
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'imagem', // NOME CERTO para o Flask
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode != 200) {
      throw Exception(
        'Erro ao enviar foto: ${streamedResponse.statusCode}\n$responseBody',
      );
    }

    return jsonDecode(responseBody); // Flask retorna lista de objetos
  }
}
