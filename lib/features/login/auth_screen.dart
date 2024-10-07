// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/home/home.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthGateState createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gym Desarrollo App"),
        centerTitle: true,
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
              subtitleBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: action == AuthAction.signIn
                      ? const Text(
                          'Bienvenido a Gym App, por favor inicie sesión!')
                      : const Text(
                          'Bienvenido a Gym App, por favor regístrese!'),
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

  _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }
}
