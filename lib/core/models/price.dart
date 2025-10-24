import 'client.dart';
import 'fuel.dart';

class Price {
  final int? id;
  final Fuel fuel;
  final Client client;
  final DateTime? date;
  final double price;

  Price({
    this.id,
    required this.fuel,
    required this.client,
    this.date,
    required this.price,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      id: json['id'] != null
          ? (json['id'] is int
              ? json['id']
              : int.tryParse(json['id'].toString()))
          : null,
      fuel: Fuel.fromJson(json['fuel']),
      client: Client.fromJson(json['client']),
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
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
