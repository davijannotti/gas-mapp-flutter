import 'gas_station.dart'; // Adicione a importação para o modelo GasStation
import 'price.dart';

class Fuel {
  final int? id;
  final GasStation gasStation; // Alterado de gasStationId para GasStation
  final String name;
  final DateTime? date;
  final Price? price;

  Fuel({
    this.id,
    required this.gasStation, // Construtor agora requer um objeto GasStation
    required this.name,
    this.date,
    this.price,
  });

  // Factory para criar uma instância a partir de um JSON
  factory Fuel.fromJson(Map<String, dynamic> json) {
    // Verifica se o campo 'gasStation' existe e não é nulo antes de criar o objeto
    if (json['gasStation'] == null) {
      throw Exception('Dados do posto de gasolina ausentes no JSON');
    }

    return Fuel(
      id: json['id'],
      gasStation: GasStation.fromJson(json['gasStation']), // Converte o JSON aninhado
      name: json['name'] ?? 'Sem nome',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      price: json['price'] != null ? Price.fromJson(json['price']) : null,
    );
  }

  // Método para converter a instância em um JSON
  Map<String, dynamic> toJson() {
    // O backend espera um objeto aninhado para o posto
    return {
      'name': name,
      'gasStation': gasStation.toJson(), // Converte o objeto GasStation em JSON
    };
    // Note que os campos 'id', 'date' e 'price' não são enviados na criação,
    // pois são gerenciados pelo backend.
  }
}