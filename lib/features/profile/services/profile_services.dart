import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proyecto_gimnasio_esquel/features/login/services/auth_service.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile() async {
    String userId = _authService.userId;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('profile_data')
        .get();
  }

  Future<void> updateUserProfile(
      {required String name, required String profileImageUrl}) async {
    String userId = _authService.userId;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('profile')
        .doc('profile_data')
        .update({
      'name': name,
      'profile_image_url': profileImageUrl,
    });
  }
}
