class Price {
  final int? id;
  final int fuelId;
  final int clientId;
  final DateTime? date;
  final double price;

  Price({
    this.id,
    required this.fuelId,
    required this.clientId,
    this.date,
    required this.price,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString() ?? ''),
      fuelId: json['fuel']?['id'] is int ? json['fuel']['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      clientId: json['client']?['id'] is int ? json['client']['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'fuel': {'id': fuelId},
      'client': {'id': clientId},
    };
  }
}
