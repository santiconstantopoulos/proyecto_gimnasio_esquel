// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/login/auth_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/login/services/auth_service.dart';
import 'package:proyecto_gimnasio_esquel/features/profile/profile_screen.dart';
import 'package:proyecto_gimnasio_esquel/features/profile/services/profile_services.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  String userName = "Cargando...";
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> profileData =
          await _profileService.getUserProfile();

      String? fetchedProfileImageUrl = profileData.data()?['profile_image_url'];

      if (fetchedProfileImageUrl == null || fetchedProfileImageUrl.isEmpty) {
        final Reference defaultImageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/default_avatar.jpg');
        fetchedProfileImageUrl = await defaultImageRef.getDownloadURL();
      }

      setState(() {
        userName = profileData.data()?['name'] ?? 'Usuario desconocido';
        profileImageUrl = fetchedProfileImageUrl!;
      });
    } catch (e) {
      setState(() {
        userName = "Error al cargar perfil $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                  CircleAvatar(
                    backgroundImage:
                        NetworkImage(profileImageUrl), // Imagen predeterminada
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
                        child: Text(userName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
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
                        child: const Text('Mi perfil',
                            style: TextStyle(fontSize: 16)),
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
                                Navigator.of(context)
                                    .pop(); // Cierra el diálogo
                              },
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Llama a signOut desde AuthGate
                                await _authService.signOut();
                                // Después de cerrar sesión, vuelve a AuthGate
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AuthScreen()),
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
