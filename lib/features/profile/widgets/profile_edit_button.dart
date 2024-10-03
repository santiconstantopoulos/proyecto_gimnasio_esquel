import 'package:flutter/material.dart';

class ProfileEditButton extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const ProfileEditButton({
    super.key,
    required this.isEditing,
    required this.onSave,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isEditing ? onSave : onEdit,
          child: Text(isEditing ? 'Guardar cambios' : 'Editar perfil'),
        ),
        if (isEditing)
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancelar'),
          ),
      ],
    );
  }
}
