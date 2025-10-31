import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<GoogleSignInAccount?> get onCurrentUserChanged => _googleSignIn.onCurrentUserChanged;

  AuthService() {
    _googleSignIn.signInSilently();
  }

  Future<void> signIn() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // O usuário cancelou o login
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      // --- ENTREGA PARA SEU AMIGO ---
      // TODO: Envie este 'idToken' para o seu backend para trocar por um token Keycloak.
      // O código do seu amigo irá aqui. Por exemplo:
      /*
      final response = await http.post(
        Uri.parse('YOUR_BACKEND_ENDPOINT/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': idToken}),
      );

      if (response.statusCode == 200) {
        final keycloakToken = json.decode(response.body)['access_token'];
        // Armazene o token com segurança e atualize o estado do aplicativo
      } else {
        // Lidar com erro de login com o backend
        _googleSignIn.signOut();
      }
      */
      // Por enquanto, vamos apenas imprimir o token para verificação.
      debugPrint('Token de ID do Google: $idToken');
      // --- FIM DA ENTREGA ---

    } catch (error) {
      debugPrint('Erro ao fazer login: $error');
    }
  }

  Future<void> signOut() {
    // TODO: Seu amigo também deve considerar implementar uma chamada para o backend
    // para invalidar a sessão do Keycloak, se necessário.
    return _googleSignIn.signOut();
  }
}
