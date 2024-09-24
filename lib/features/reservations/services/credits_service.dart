import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proyecto_gimnasio_esquel/features/login/services/auth_service.dart';

class CreditsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Stream<int> getCredits() {
    return _firestore
        .collection('users')
        .doc(_authService.userId)
        .collection('credits')
        .doc('available_credits')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        return data?['credit'] ?? 0;
      } else {
        return 0;
      }
    });
  }

  Future<int> getSnapshotCredits() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_authService.userId)
        .collection('credits')
        .doc('available_credits')
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      return data?['credit'] ?? 0;
    } else {
      return 0;
    }
  }

  Future<void> consumeCredits(int creditsToConsume) async {
    try {
      DocumentReference docRef = _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('credits')
          .doc('available_credits');

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('No se encontraron créditos disponibles');
        }

        final data = snapshot.data() as Map<String, dynamic>;

        final currentCredits = data['credit'] ?? 0;
        if (currentCredits < creditsToConsume) {
          throw Exception('No tienes suficientes créditos');
        }

        transaction.update(docRef, {
          'credit': currentCredits - creditsToConsume,
        });
      });
    } catch (e) {
      throw Exception('Error al consumir créditos: $e');
    }
  }

  Future<void> returnCredits(int creditsToReturn) async {
    try {
      DocumentReference docRef = _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('credits')
          .doc('available_credits');

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(docRef);
        if (!snapshot.exists) {
          throw Exception('No se encontraron créditos disponibles');
        }

        final data = snapshot.data() as Map<String, dynamic>;

        final currentCredits = data['credit'] ?? 0;

        transaction.update(docRef, {
          'credit': currentCredits + creditsToReturn,
        });
      });
    } catch (e) {
      throw Exception('Error al retornar créditos: $e');
    }
  }
}
