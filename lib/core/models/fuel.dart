import 'gas_station.dart';
import 'price.dart';
import 'package:flutter/foundation.dart';

class Fuel {
  final int? id;
  final GasStation gasStation;
  final String name;
  final DateTime? date;
  final Price? price;

  Fuel({
    this.id,
    required this.gasStation,
    required this.name,
    this.date,
    this.price,
  });

  factory Fuel.fromJson(Map<String, dynamic> json) {
    final gasStationData = json['gasStation'];
    final GasStation parsedGasStation = gasStationData != null
        ? GasStation.fromJson(gasStationData)
        : GasStation(id: null, name: 'Desconhecido', latitude: 0.0, longitude: 0.0);

    Price? latestPrice;
    if (json['prices'] is List && (json['prices'] as List).isNotEmpty) {
      List<dynamic> pricesJson = json['prices'] as List<dynamic>;

      pricesJson.sort((a, b) {
        final DateTime dateA = DateTime.parse(a['createdAt']);
        final DateTime dateB = DateTime.parse(b['createdAt']);
        return dateB.compareTo(dateA);
      });

      latestPrice = Price.fromJson(pricesJson.first);
    }

    return Fuel(
      id: json['id'] != null
          ? (json['id'] is int
              ? json['id']
              : int.tryParse(json['id'].toString()))
          : null,
      gasStation: parsedGasStation,
      name: json['name'] ?? 'Sem nome',
      date: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      price: latestPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gasStation': gasStation.toJson(),
    };
  }
}
