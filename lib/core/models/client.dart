class Client {
  int id;
  String email;
  String name;
  String password;

  Client({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'password': password,
    };
  }
}
