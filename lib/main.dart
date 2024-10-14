import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:proyecto_gimnasio_esquel/features/login/auth_screen.dart';
import 'package:proyecto_gimnasio_esquel/styles/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gimnasio Esquel',
      theme: AppTheme.appTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthScreen(),
    );
  }
}
