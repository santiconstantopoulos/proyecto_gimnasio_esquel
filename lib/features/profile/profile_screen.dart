import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
const ProfileScreen({Key? key}) : super(key: key);


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
            // Agrega la imagen de perfil
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://picsum.photos/200'), // Reemplaza con la URL de la imagen del perfil
            ),
            const SizedBox(height: 20),
            // Agrega el nombre del usuario
            const Text(
              'Santiago Joaquin', // Reemplaza con el nombre del usuario
            ),
            const SizedBox(height: 20),
            // Agrega los campos de edición de perfil
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