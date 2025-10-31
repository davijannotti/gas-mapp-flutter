class Client {
  int id;
  String? email;
  String? name;
  String? password;

  Client({
    required this.id,
    this.email,
    this.name,
    this.password,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] != null
          ? (json['id'] is int
              ? json['id']
              : int.tryParse(json['id'].toString()) ?? 0)
          : 0,
      email: json['email'],
      name: json['name'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id
    };
  }
}