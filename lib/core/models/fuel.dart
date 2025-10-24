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
    // If gasStation is null or missing, create a default GasStation
    final gasStationData = json['gasStation'];
    final GasStation parsedGasStation = gasStationData != null
        ? GasStation.fromJson(gasStationData)
        : GasStation(id: null, name: 'Unknown', latitude: 0.0, longitude: 0.0); // Provide a default GasStation

    return Fuel(
      id: json['id'],
      gasStation: parsedGasStation, // Use the parsed or default GasStation
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
      'gasStation': {'id': gasStation.id}, // Changed to send only the ID
    };
    // Note que os campos 'id', 'date' e 'price' não são enviados na criação,
    // pois são gerenciados pelo backend.
  }
}
