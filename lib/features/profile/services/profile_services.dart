import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proyecto_gimnasio_esquel/features/login/services/auth_service.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Obtiene la informacion de perfil, si no existe crea una por default
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile() async {
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
    }

    return profileSnapshot;
  }

  // Actualiza el nombre de usuario
  Future<void> updateUserName(String newName) async {
    String userId = _authService.userId;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('profile_data')
        .update({'name': newName});
  }

  // Actualiza la imagen de perfil
  Future<void> updateUserProfileImage(String imageUrl) async {
    String userId = _authService.userId;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('profile_data')
        .update({
      'profile_image_url': imageUrl,
    });
  }
}
