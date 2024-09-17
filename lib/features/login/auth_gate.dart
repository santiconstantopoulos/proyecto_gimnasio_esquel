import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

import 'package:proyecto_gimnasio_esquel/features/home/home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Proyecto Reserva de Gimnasios"),
        actions: [
          // Botón de 3 puntos
          PopupMenuButton<int>(
            onSelected: (item) {
              switch (item) {
                case 0:
                  // Mostrar sidebar
                  _showSidebar(context);
                  break;
                case 1:
                  // Cerrar sesión
                  _signOut(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: Text('Ayuda'),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SignInScreen(
              providers: [
                EmailAuthProvider(),
                GoogleProvider(
                    clientId:
                        "1092870181448-enq21pikqoqk2ipndi45fqkejtj51he2.apps.googleusercontent.com"),
              ],
              // headerBuilder: (context, constraints, shrinkOffset) {
              //   return Padding(
              //     padding: const EdgeInsets.all(20),
              //     child: AspectRatio(
              //       aspectRatio: 1,
              //       child: Image.asset('assets/image.png'),
              //     ),
              //   );
              // },
              subtitleBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: action == AuthAction.signIn
                      ? const Text(
                          'Bienvenido a Gym App, por favor inicie sesión!')
                      : const Text(
                          'Bienvenido a Gym App, por favor registrese!'),
                );
              },
              footerBuilder: (context, action) {
                return const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Ingresando, estás de acuerdo con los términos y condiciones.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              },
            );
          }

          return const HomeScreen();
        },
      ),
    );
  }

  void _showSidebar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sidebar abierta')),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }
}
