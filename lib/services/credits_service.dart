import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';
import 'package:proyecto_gimnasio_esquel/services/log_service.dart';

class CreditsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final LogService _logService = LogService();

  Stream<int> getUserCredits() async* {
    String userId = _authService.userId;
    DocumentReference<Map<String, dynamic>> creditsDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('credits')
        .doc('available_credits');

    DocumentSnapshot<Map<String, dynamic>> snapshot = await creditsDoc.get();

    if (!snapshot.exists) {
      await creditsDoc.set({'credit': 0});
      await _logService.createUserLog(
        'Documento de créditos creado para el usuario $userId',
        'info',
        'credits_service',
      );
    }

    yield* creditsDoc.snapshots().map((snapshot) {
      final data = snapshot.data();
      return data?['credit'] ?? 0;
    });
  }

  Future<void> consumeCredits(int creditsToConsume) async {
    try {
      String userId = _authService.userId;
      DocumentReference docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('credits')
          .doc('available_credits');

      DocumentSnapshot snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception('No se encontraron créditos disponibles');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentCredits = data['credit'] ?? 0;

      if (currentCredits < creditsToConsume) {
        throw Exception('No tienes suficientes créditos');
      }

      await docRef.update({
        'credit': currentCredits - creditsToConsume,
      });

      await _logService.createUserLog(
        'Créditos consumidos: $creditsToConsume',
        'info',
        'credits_service',
      );
    } catch (e) {
      await _logService.createUserLog(
        'Error al consumir créditos: $e',
        'error',
        'credits_service',
      );
      throw Exception('Error al consumir créditos: $e');
    }
  }

  Future<void> consumeCreditsForUser(
      String userId, int creditsToConsume) async {
    try {
      DocumentReference docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('credits')
          .doc('available_credits');

      DocumentSnapshot snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception(
            'No se encontraron créditos disponibles para este usuario');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentCredits = data['credit'] ?? 0;

      if (currentCredits < creditsToConsume) {
        throw Exception('El usuario no tiene suficientes créditos');
      }

      await docRef.update({
        'credit': currentCredits - creditsToConsume,
      });

      await _logService.createUserLog(
        'Créditos consumidos para el usuario $userId: $creditsToConsume',
        'info',
        'credits_service',
      );
    } catch (e) {
      await _logService.createUserLog(
        'Error al consumir créditos para el usuario $userId: $e',
        'error',
        'credits_service',
      );
      throw Exception('Error al consumir créditos para el usuario: $e');
    }
  }

  Future<void> returnCredits(int creditsToReturn) async {
    try {
      String userId = _authService.userId;
      DocumentReference docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('credits')
          .doc('available_credits');

      DocumentSnapshot snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception('No se encontraron créditos disponibles');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentCredits = data['credit'] ?? 0;

      await docRef.update({
        'credit': currentCredits + creditsToReturn,
      });

      await _logService.createUserLog(
        'Créditos retornados: $creditsToReturn',
        'info',
        'credits_service',
      );
    } catch (e) {
      await _logService.createUserLog(
        'Error al retornar créditos: $e',
        'error',
        'credits_service',
      );
      throw Exception('Error al retornar créditos: $e');
    }
  }

  Future<void> addCreditsToUser(String userId, int creditsToAdd) async {
    try {
      DocumentReference docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('credits')
          .doc('available_credits');

      DocumentSnapshot snapshot = await docRef.get();
      if (!snapshot.exists) {
        throw Exception('No se encontraron créditos disponibles');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final currentCredits = data['credit'] ?? 0;

      await docRef.update({
        'credit': currentCredits + creditsToAdd,
      });

      await _logService.createUserLog(
        'Créditos agregados: $creditsToAdd a usuario: $userId',
        'info',
        'credits_service',
      );
    } catch (e) {
      await _logService.createUserLog(
        'Error al agregar créditos a usuario: $userId: $e',
        'error',
        'credits_service',
      );
      throw Exception('Error al agregar créditos: $e');
    }
  }
}
