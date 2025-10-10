class Evaluation {
  int id;
  int priceId;
  int trust;
  DateTime date;

  Evaluation({
    required this.id,
    required this.priceId,
    required this.trust,
    required this.date,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'],
      priceId: json['fuelId'],
      trust: json['trust'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'priceId': priceId,
      'trust': trust,
      'date': date,
    };
  }
}
