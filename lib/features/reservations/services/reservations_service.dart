import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proyecto_gimnasio_esquel/features/reservations/models/reservarion.dart';
import 'package:proyecto_gimnasio_esquel/features/login/services/auth_service.dart';

class ReservationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Stream<List<Reservation>> getReservations() {
    return _firestore
        .collection('users')
        .doc(_authService.userId)
        .collection('reservations')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reservation.fromFirestore(doc.data()))
            .toList());
  }

  Future<void> saveReservation(DateTime dateTime) async {
    try {
      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('reservations')
          .add({
        'date': Timestamp.fromDate(dateTime),
        'status': 1,
      });
    } catch (e) {
      throw Exception('Error al guardar la reserva: $e');
    }
  }

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
}
