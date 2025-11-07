import 'price.dart';
import 'client.dart';
import 'fuel.dart';
import 'gas_station.dart';
import 'package:flutter/foundation.dart';

class Evaluation {
  final int? id;
  final Price price;
  final Client client;
  final bool trust;
  final DateTime? date;

  Evaluation({
    this.id,
    required this.price,
    required this.trust,
    required this.client,
    this.date,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    debugPrint('Evaluation.fromJson received: $json');

    // Handle price
    final priceData = json['price'];
    final Price parsedPrice = priceData != null
        ? Price.fromJson(priceData)
        : Price(
      id: null,
      price: 0.0,
      fuel: Fuel(
        id: null,
        name: 'Combustível Desconhecido',
        gasStation: GasStation(
          id: null,
          name: 'Posto Desconhecido',
          latitude: 0.0,
          longitude: 0.0,
        ),
      ),
      client: Client(
        id: null,
        email: 'Email Desconhecido',
        name: 'Cliente Desconhecido',
        password: '',
      ),
    );

    // Handle client
    final clientData = json['client'];
    final Client parsedClient = clientData != null
        ? Client.fromJson(clientData)
        : Client(
      id: null,
      email: 'Email Desconhecido',
      name: 'Cliente Desconhecido',
      password: '',
    );

    return Evaluation(
      id: json['id'] != null
          ? (json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()))
          : null,
      price: parsedPrice,
      trust: json['trust'] ?? false,
      client: parsedClient,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': {'id': price.id},
      'client': {'id': client.id},
      'trust': trust,
    };
  }
}
