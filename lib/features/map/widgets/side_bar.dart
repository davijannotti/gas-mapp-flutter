import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/services/auth_service.dart';
import './google_login_button.dart';

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final AuthService _authService = AuthService();
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _authService.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: _currentUser != null ? _buildLoggedInView(_currentUser!) : _buildLoggedOutView(),
    );
  }

  Widget _buildLoggedInView(GoogleSignInAccount user) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(
            user.displayName ?? 'User Name',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          accountEmail: Text(user.email),
          currentAccountPicture: GoogleUserCircleAvatar(
            identity: user,
          ),
          decoration: const BoxDecoration(color: Colors.teal),
        ),
        ListTile(
          leading: const Icon(Icons.bar_chart),
          title: const Text('Statistics'),
          onTap: () {
            // TODO: Navigate to user statistics screen
            Navigator.pop(context);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () => _authService.signOut(),
        ),
      ],
    );
  }

  Widget _buildLoggedOutView() {
    return Column(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.teal),
          child: Center(
            child: Text(
              'GasMapp',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GoogleLoginButton(onPressed: () => _authService.signIn()),
      ],
    );
  }
}
