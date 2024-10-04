import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/profile/profile_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/login/auth_gate.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: NetworkImage('https://picsum.photos/200'), // Reemplaza con la URL de la imagen del usuario
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: const Text('Santiago Joaquin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: const Text('Mi perfil', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            
          ),
          // Resto de las opciones del menú
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar Sesión'),
                  onTap: () {
                    // Muestra un diálogo de confirmación
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('¿Estás seguro?'),
                          content: const Text('¿Deseas cerrar sesión?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Cierra el diálogo
                              },
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Llama a signOut desde AuthGate
                                await const AuthGate()._signOut(context);
                                // Después de cerrar sesión, vuelve a AuthGate
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AuthGate()),
                                  (route) => false,
                                );
                              },
                              child: const Text('Cerrar Sesión'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on AuthGate {
  _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

  }
}
