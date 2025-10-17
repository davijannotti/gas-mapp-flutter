import 'dart:convert';

Map<String, String> createAuthHeaders() {
  const username = 'admin';
  const password = 'admin';
  final credentials = base64Encode(utf8.encode('$username:$password'));

  return {
    'Content-Type': 'application/json',
    'Authorization': 'Basic $credentials',
  };
}
