import 'fuel.dart';

class GasStation {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final List<Fuel> fuel;

  GasStation({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.fuel,
  });

  factory GasStation.fromJson(Map<String, dynamic> json) {
    return GasStation(
      // Converte id para int, mesmo que seja string ou null
      id: json['id'] != null
          ? (json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()))
          : null,

      // Para campos obrigatórios, usa valor padrão caso venha null
      name: json['name'] ?? 'Sem nome',
      latitude: (json['latitude'] != null)
          ? (json['latitude'] as num).toDouble()
          : 0.0,
      longitude: (json['longitude'] != null)
          ? (json['longitude'] as num).toDouble()
          : 0.0,

      // Lista de fuel segura: null vira lista vazia
      fuel: (json['fuel'] as List<dynamic>?)
          ?.map((c) => Fuel.fromJson(c))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'fuel': fuel.map((c) => c.toJson()).toList(),
    };
  }
}
