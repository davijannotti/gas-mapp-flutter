import 'fuel.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

class GasStation {
  final int? id;
  final String? name;
  final double? latitude;
  final double? longitude;
  final List<Fuel>? fuel;


  GasStation({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
    this.fuel,
  });

  GasStation copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    List<Fuel>? fuel,
  }) {
    return GasStation(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fuel: fuel ?? this.fuel,
    );
  }

  factory GasStation.fromJson(Map<String, dynamic> json) {
    // debugPrint('GasStation.fromJson received: $json'); // Debug print removed
    return GasStation(
      id: json['id'] != null
          ? (json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()))
          : null,

      name: json['name'] ?? 'Sem nome',
      latitude: (json['latitude'] != null)
          ? (json['latitude'] as num).toDouble()
          : 0.0,
      longitude: (json['longitude'] != null)
          ? (json['longitude'] as num).toDouble()
          : 0.0,

      fuel: (json['fuels'] as List<dynamic>?) // This is where Fuel.fromJson is called
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
    };
  }
}
