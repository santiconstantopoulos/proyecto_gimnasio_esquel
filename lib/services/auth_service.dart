import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtiene el usuario actual
  User? get currentUser => _firebaseAuth.currentUser;

  // Obtiene el ID del usuario actual
  String get userId => currentUser?.uid ?? 'unknown_user';

  // Obtiene el tipo de usuario
  Future<int> _getUserType() async {
    String userId = this.userId;

    try {
      DocumentReference<Map<String, dynamic>> profileDoc =
          _firestore.collection('admins').doc(userId);

      DocumentSnapshot<Map<String, dynamic>> adminDoc = await profileDoc.get();
      print(adminDoc.exists);
      return adminDoc.exists ? 0 : 1;
    } catch (e) {
      throw Exception('Error al obtener el tipo de usuario: $e');
    }
  }

  // Determina si es administrador
  Future<bool> get isAdmin async => (await _getUserType()) == 0;

  // Determina si es usuario normal
  Future<bool> get isUser async => (await _getUserType()) == 1;

  // Desloguea al usuario
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
