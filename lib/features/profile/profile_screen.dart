import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:proyecto_gimnasio_esquel/features/profile/services/profile_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  String userName = "Cargando..."; // Placeholder mientras carga el perfil
  String profileImageUrl = ""; // Placeholder para la imagen del perfil

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Obtiene el perfil del usuario desde Firestore
      DocumentSnapshot<Map<String, dynamic>> profileData =
          await _profileService.getUserProfile();

      // Extrae el nombre y la URL de la imagen de perfil de los datos
      setState(() {
        userName = profileData.data()?['name'] ?? 'Usuario desconocido';
        profileImageUrl = profileData.data()?['profile_image_url'] ??
            'https://picsum.photos/200';
      });
    } catch (e) {
      setState(() {
        userName = "Error al cargar perfil";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Muestra la imagen de perfil
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            const SizedBox(height: 20),
            // Muestra el nombre del usuario
            Text(
              userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Botón para editar el perfil
            ElevatedButton(
              onPressed: () {
                // Lógica para editar el perfil
              },
              child: const Text('Editar perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
