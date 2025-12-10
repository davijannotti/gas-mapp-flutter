import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/map/screens/home_page.dart';
import 'core/services/auth_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthHelper.loadToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GasMapp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: AuthHelper.accessToken != null ? const HomePage() : const LoginScreen(),
    );
  }
}
