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
        // The user canceled the sign-in
        return;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      // --- HANDOFF FOR YOUR FRIEND ---
      // TODO: Send this 'idToken' to your backend to exchange for a Keycloak token.
      // Your friend's code will go here. For example:
      /*
      final response = await http.post(
        Uri.parse('YOUR_BACKEND_ENDPOINT/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': idToken}),
      );

      if (response.statusCode == 200) {
        final keycloakToken = json.decode(response.body)['access_token'];
        // Store the token securely and update the app state
      } else {
        // Handle login error with the backend
        _googleSignIn.signOut();
      }
      */
      // For now, we'll just print the token for verification.
      debugPrint('Google ID Token: $idToken');
      // --- END OF HANDOFF ---

    } catch (error) {
      debugPrint('Error signing in: $error');
    }
  }

  Future<void> signOut() {
    // TODO: Your friend should also consider implementing a call to the backend
    // to invalidate the Keycloak session if necessary.
    return _googleSignIn.signOut();
  }
}
