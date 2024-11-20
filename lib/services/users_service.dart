import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/models/user.dart';
import 'package:proyecto_gimnasio_esquel/services/log_service.dart';

class UsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LogService _logService = LogService();

  Future<List<User>> getUsers() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();

      List<User> users = [];

      for (var doc in usersSnapshot.docs) {
        final profileSnapshot =
            await doc.reference.collection('profile').doc('profile_data').get();

        if (profileSnapshot.exists) {
          final userData = profileSnapshot.data()!;
          final user = User.fromFirestore(doc.id, userData);
          users.add(user);
        }
      }

      return users;
    } catch (e) {
      await _logService.createUserLog(
          'Error al cargar los usuarios: $e', 'error', 'users_service');
      throw Exception('Error al cargar los usuarios: $e');
    }
  }
}
