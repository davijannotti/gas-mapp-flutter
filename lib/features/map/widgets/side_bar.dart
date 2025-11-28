import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Como os serviços de autenticação serão implementados posteriormente,
    // exibimos as opções para fazer login ou se registrar.
    // A visualização pode ser atualizada posteriormente para mostrar um estado de login.
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
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
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Login'),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer primeiro
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Registrar-se'),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer primeiro
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
