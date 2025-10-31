import 'client.dart';
import 'fuel.dart';
import 'gas_station.dart'; // ADDED THIS IMPORT
import 'package:flutter/foundation.dart';

class Price {
  final int? id;
  final Fuel fuel;
  final Client client;
  final DateTime? date;
  final double? price;

  Price({
    this.id,
    required this.fuel,
    required this.client,
    this.date,
    required this.price,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    debugPrint('Price.fromJson received: $json');
    debugPrint('Price.fromJson - json[\'fuel\']: ${json['fuel']}');
    debugPrint('Price.fromJson - json[\'client\']: ${json['client']}');

    // Handle fuel
    final fuelData = json['fuel'];
    final Fuel parsedFuel = fuelData != null
        ? Fuel.fromJson(fuelData)
        : Fuel(
            id: null, // Fuel.id is nullable
            name: 'Combustível Desconhecido',
            gasStation: GasStation(id: null, name: 'Posto Desconhecido', latitude: 0.0, longitude: 0.0), // GasStation.id is nullable
          );

    // Handle client
    final clientData = json['client'];
    final Client parsedClient = clientData != null
        ? Client.fromJson(clientData)
        : Client(id: 0, email: 'desconhecido@example.com', name: 'Cliente Desconhecido', password: ''); // Client.id is int, so use 0

    return Price(
      id: json['id'] != null
          ? (json['id'] is int
              ? json['id']
              : int.tryParse(json['id'].toString()))
          : null,
      fuel: parsedFuel,
      client: parsedClient,
      date: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'fuel': {'id': fuel.id},
      'client': {'id': client.id},
    };
  }
}