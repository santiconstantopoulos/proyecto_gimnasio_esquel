import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';
import 'package:proyecto_gimnasio_esquel/services/log_service.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final LogService _logService = LogService();

  // Obtiene la información de perfil, si no existe crea una por defecto
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile() async {
    try {
      String userId = _authService.userId;

      DocumentReference<Map<String, dynamic>> profileDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('profile_data');

      DocumentSnapshot<Map<String, dynamic>> profileSnapshot =
          await profileDoc.get();

      if (!profileSnapshot.exists) {
        await profileDoc.set({
          'name': 'Nuevo usuario',
          'profile_image_url': 'https://example.com/default_avatar.jpg',
        });

        profileSnapshot = await profileDoc.get();

        await _logService.createUserLog(
            'Perfil creado para el usuario $userId', 'info', 'profile_service');
      }

      return profileSnapshot;
    } catch (e) {
      await _logService.createUserLog(
          'Error al obtener la información de perfil: $e',
          'error',
          'profile_service');
      throw Exception('Error al obtener la información de perfil: $e');
    }
  }

  // Actualiza el nombre de usuario
  Future<void> updateUserName(String newName) async {
    try {
      String userId = _authService.userId;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('profile_data')
          .update({'name': newName});

      await _logService.createUserLog(
          'Nombre de usuario actualizado para $userId',
          'info',
          'profile_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al actualizar el nombre de usuario: $e',
          'error',
          'profile_service');
      throw Exception('Error al actualizar el nombre de usuario: $e');
    }
  }

  // Actualiza la imagen de perfil
  Future<void> updateUserProfileImage(String imageUrl) async {
    try {
      String userId = _authService.userId;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('profile_data')
          .update({'profile_image_url': imageUrl});

      await _logService.createUserLog(
          'Imagen de perfil actualizada para $userId',
          'info',
          'profile_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al actualizar la imagen de perfil: $e',
          'error',
          'profile_service');
      throw Exception('Error al actualizar la imagen de perfil: $e');
    }
  }
}
