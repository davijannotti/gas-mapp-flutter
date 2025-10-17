import 'price.dart';

class Fuel {
  final int? id;          // gerado pelo backend
  final int gasStationId;
  final String name;
  final DateTime? date;   // gerado pelo backend
  final Price? price;     // pode ser null se ainda não tiver preço

  Fuel({
    this.id,
    required this.gasStationId,
    required this.name,
    this.date,
    this.price,
  });

  factory Fuel.fromJson(Map<String, dynamic> json) {
    return Fuel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      gasStationId: json['gasStationId'] is int
          ? json['gasStationId']
          : int.tryParse(json['gasStationId']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? 'Sem nome',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      price: json['price'] != null ? Price.fromJson(json['price']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'gasStationId': gasStationId,
      'name': name,
    };

    if (price != null) {
      data['price'] = price!.toJson();
    }

    return data;
  }
}
