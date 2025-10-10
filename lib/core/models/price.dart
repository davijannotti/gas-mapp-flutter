class Price {
  int id;
  int fuelId;
  DateTime date;
  double price;

  Price({
    required this.id,
    required this.fuelId,
    required this.date,
    required this.price,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      id: json['id'],
      fuelId: json['fuelId'],
      date: json['date'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fuelId': fuelId,
      'date': date,
      'price': price,
    };
  }
}
