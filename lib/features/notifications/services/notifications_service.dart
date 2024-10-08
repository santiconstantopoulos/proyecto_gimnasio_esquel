import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/features/login/services/auth_service.dart';

class NotificationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Obtiene las notificaciones del usuario
  Future<List<Map<String, dynamic>>> getNotifications() async {
    String userId = _authService.userId;

    CollectionReference<Map<String, dynamic>> notificationsCollection =
        _firestore.collection('users').doc(userId).collection('notifications');

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await notificationsCollection.get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Error al cargar las notificaciones: $e');
    }
  }

  // Crea una notificación
  Future<void> createNotification(String title, String message) async {
    String userId = _authService.userId;

    CollectionReference<Map<String, dynamic>> notificationsCollection =
        _firestore.collection('users').doc(userId).collection('notifications');

    try {
      await notificationsCollection.add({
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al crear la notificacion: $e');
    }
  }

  // Elimina una notificación
  Future<void> deleteNotification(String notificationId) async {
    String userId = _authService.userId;

    DocumentReference<Map<String, dynamic>> notificationDoc = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId);

    try {
      await notificationDoc.delete();
    } catch (e) {
      throw Exception('Error al eliminar la notificacion: $e');
    }
  }
}
