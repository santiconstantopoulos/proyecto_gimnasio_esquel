import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtiene el usuario actual
  User? get currentUser => _firebaseAuth.currentUser;

  // Obtiene el ID del usuario actual
  String get userId => currentUser?.uid ?? 'unknown_user';

  //TODO: crear documentos y colecciones necesarias
}
