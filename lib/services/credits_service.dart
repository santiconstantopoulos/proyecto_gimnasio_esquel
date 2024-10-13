import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';
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

  // Consume créditos del usuario logueado
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

  // Retorna créditos al usuario logueado
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

  // Agrega créditos a un usuario (admin)
  Future<void> addCredits(String userId, int creditsToAdd) async {
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
        'Créditos agregados: $creditsToAdd',
        'info',
        'credits_service',
      );
    } catch (e) {
      await _logService.createUserLog(
        'Error al agregar créditos: $e',
        'error',
        'credits_service',
      );
      throw Exception('Error al agregar créditos: $e');
    }
  }
}
