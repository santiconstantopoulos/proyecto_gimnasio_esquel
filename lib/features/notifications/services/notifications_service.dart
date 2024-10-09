import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/features/login/services/auth_service.dart';
import 'package:proyecto_gimnasio_esquel/services/log_service.dart';

class NotificationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final LogService _logService = LogService();

  // Obtiene las notificaciones del usuario
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      String userId = _authService.userId;

      CollectionReference<Map<String, dynamic>> notificationsCollection =
          _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications');

      QuerySnapshot<Map<String, dynamic>> snapshot =
          await notificationsCollection.get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      await _logService.createUserLog('Error al cargar las notificaciones: $e',
          'error', 'notifications_service');
      throw Exception('Error al cargar las notificaciones: $e');
    }
  }

  // Crea una notificación
  Future<void> createNotification(String title, String message) async {
    try {
      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('notifications')
          .add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _logService.createUserLog(
          'Notificación creada para ${_authService.userId} con título "$title"',
          'info',
          'notifications_service');
    } catch (e) {
      await _logService.createUserLog('Error al crear la notificación: $e',
          'error', 'notifications_service');
      throw Exception('Error crear la notificación: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      String userId = _authService.userId;

      DocumentReference<Map<String, dynamic>> notificationDoc = _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId);

      await notificationDoc.delete();

      await _logService.createUserLog(
          'Notificación con ID $notificationId eliminada para $userId',
          'info',
          'notifications_service');
    } catch (e) {
      await _logService.createUserLog('Error al eliminar la notificación: $e',
          'error', 'notifications_service');
      throw Exception('Error al eliminar la notificación: $e');
    }
  }
}
