import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  String get userId => currentUser?.uid ?? 'unknown_user';

  Future<int> _getUserType() async {
    try {
      DocumentReference docRef = _firestore.collection('users').doc(userId);

      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        String rol = docSnapshot['rol'];

        return rol == 'admin' ? 0 : 1;
      } else {
        throw Exception(
            'El documento del usuario no existe o no contiene el campo rol');
      }
    } catch (e) {
      throw Exception('Error al obtener el tipo de usuario: $e');
    }
  }

  Future<bool> get isAdmin async => (await _getUserType()) == 0;

  Future<bool> get isUser async => (await _getUserType()) == 1;

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
