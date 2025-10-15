import 'dart:ui';

import 'price.dart';

class Fuel {
  int id;
  int gasStationId;
  String name;
  DateTime date;
  Price price;

  Fuel({
    required this.id,
    required this.gasStationId,
    required this.name,
    required this.date,
    required this.price,
  });

  factory Fuel.fromJson(Map<String, dynamic> json) {
    return Fuel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      gasStationId: json['gasStationId'] is int ? json['gasStationId'] : int.parse(json['gasStationId'].toString()),
      name: json['name'],
      date: DateTime.parse(json['date']),
      price: Price.fromJson(json['price'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gasStationId': gasStationId,
      'name': name,
      'date': date,
      'price': price,
    };
  }
}
