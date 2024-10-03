import 'package:flutter/material.dart';

class ProfileName extends StatelessWidget {
  final bool isEditing;
  final String userName;
  final TextEditingController nameController;

  const ProfileName({
    super.key,
    required this.isEditing,
    required this.userName,
    required this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    return isEditing
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Editar nombre',
                border: OutlineInputBorder(),
              ),
            ),
          )
        : Text(
            userName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          );
  }
}
