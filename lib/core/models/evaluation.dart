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
      id: json['id'] != null
          ? (json['id'] is int
              ? json['id']
              : int.tryParse(json['id'].toString()) ?? 0)
          : 0,
      priceId: json['priceId'] != null
          ? (json['priceId'] is int
              ? json['priceId']
              : int.tryParse(json['priceId'].toString()) ?? 0)
          : 0,
      trust: json['trust'] != null
          ? (json['trust'] is int
              ? json['trust']
              : int.tryParse(json['trust'].toString()) ?? 0)
          : 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'priceId': priceId,
      'trust': trust,
      'date': date.toIso8601String(),
    };
  }
}