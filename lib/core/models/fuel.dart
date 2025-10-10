class Fuel {
  int id;
  int gasStationId;
  String name;
  DateTime date;

  Fuel({
    required this.id,
    required this.gasStationId,
    required this.name,
    required this.date
  });

  factory Fuel.fromJson(Map<String, dynamic> json) {
    return Fuel(
      id: json['id'],
      gasStationId: json['gasStationId'],
      name: json['name'],
      date: json['date']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gasStationId': gasStationId,
      'name': name,
      'date': date,
    };
  }
}
