import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';



class AuthService {

  final String baseUrl = '${ApiConfig.baseUrl}/auth';

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _storage = const FlutterSecureStorage();

  Stream<GoogleSignInAccount?> get onCurrentUserChanged => _googleSignIn.onCurrentUserChanged;

  AuthService() {
    _googleSignIn.signInSilently();
  }

  Future<void> signIn() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      debugPrint('Google ID Token: $idToken');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        debugPrint('Keycloak Token: $accessToken');
      } else {
        debugPrint('Login error: ${response.statusCode}');
        _googleSignIn.signOut();
      }
    } catch (error) {
      debugPrint('Erro ao fazer login: $error');
    }
  }

  Future<void> signOut() async{
    try {
      await _googleSignIn.signOut();

      await _storage.delete(key: 'access_token');

      try {
        final token = await _storage.read(key: 'access_token');
        if (token != null){
          await http.post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );
        }
      } catch (_) {
        //ignorar por enquanto
      }


    } catch (e) {
      print('Error Loging Out');
    }
  }
}
