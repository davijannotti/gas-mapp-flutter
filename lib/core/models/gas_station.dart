import 'fuel.dart';

class GasStation {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  List<Fuel> fuel;

  GasStation({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.fuel,
  });

  factory GasStation.fromJson(Map<String, dynamic> json) {
    return GasStation(
      id: json['id'],
      name: json['name'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      fuel: (json['fuel'] as List)
          .map((c) => Fuel.fromJson(c))
          .toList(),
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
