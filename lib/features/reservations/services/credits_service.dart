import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proyecto_gimnasio_esquel/features/login/services/auth_service.dart';
import 'package:proyecto_gimnasio_esquel/services/log_service.dart';

class CreditsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final LogService _logService = LogService();

  // Obtiene los créditos, si no existe el documento lo crea
  Stream<int> getCredits() async* {
    String userId = _authService.userId;
    DocumentReference<Map<String, dynamic>> creditsDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('credits')
        .doc('available_credits');

    DocumentSnapshot<Map<String, dynamic>> snapshot = await creditsDoc.get();

    if (!snapshot.exists) {
      await creditsDoc.set({
        'credit': 0,
      });
      snapshot = await creditsDoc.get();

      await _logService.createUserLog(
          'Documento de créditos creado para el usuario $userId',
          'info',
          'credits_service');
    }

    yield* creditsDoc.snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        return data?['credit'] ?? 0;
      } else {
        return 0;
      }
    });
  }

  // Consume créditos
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

      await _logService.createUserLog(
          'Créditos consumidos: $creditsToConsume', 'info', 'credits_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al consumir créditos: $e', 'error', 'credits_service');
      throw Exception('Error al consumir créditos: $e');
    }
  }

  // Retorna créditos
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

      await _logService.createUserLog(
          'Créditos retornados: $creditsToReturn', 'info', 'credits_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al retornar créditos: $e', 'error', 'credits_service');
      throw Exception('Error al retornar créditos: $e');
    }
  }
}
