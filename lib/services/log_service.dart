import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';

class LogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Crea un log de un usuario
  Future<void> createUserLog(String message, String type, String origin) async {
    try {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyyMMdd_HHmmss').format(now);
      String docName = '${formattedDate}_$origin';

      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('logs')
          .doc(docName)
          .set({
        'message': message,
        'type': type, // "info", "warning", "error"
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al crear el log: $e');
    }
  }
}
