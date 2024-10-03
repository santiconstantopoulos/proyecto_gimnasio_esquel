import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proyecto_gimnasio_esquel/features/reservations/models/reservarion.dart';
import 'package:proyecto_gimnasio_esquel/features/login/services/auth_service.dart';

class ReservationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Obtiene las reservaciones
  Stream<List<Reservation>> getReservations() {
    return _firestore
        .collection('users')
        .doc(_authService.userId)
        .collection('reservations')
        .where('status', whereIn: [0, 1, 2])
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return <Reservation>[];
          } else {
            return snapshot.docs
                .map((doc) => Reservation.fromFirestore(doc.id, doc.data()))
                .toList();
          }
        });
  }

  // Crea una reservacion
  Future<void> createReservation(DateTime dateTime) async {
    try {
      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('reservations')
          .add({
        'date': Timestamp.fromDate(dateTime),
        'status': 0,
      });
    } catch (e) {
      throw Exception('Error al guardar la reserva: $e');
    }
  }

  // Confirma una reservacion
  Future<void> confirmReservation(Reservation reservation) async {
    try {
      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('reservations')
          .doc(reservation.id)
          .update({'status': 1});
    } catch (e) {
      throw Exception('Error al confirmar la reserva: $e');
    }
  }

  // Cancela una reservacion
  Future<void> cancelReservation(Reservation reservation) async {
    try {
      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('reservations')
          .doc(reservation.id)
          .update({'status': 2});
    } catch (e) {
      throw Exception('Error al cancelar la reserva: $e');
    }
  }

  // Elimina una reservacion
  Future<void> deleteReservation(Reservation reservation) async {
    try {
      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('reservations')
          .doc(reservation.id)
          .update({'status': 3});
    } catch (e) {
      throw Exception('Error al eliminar la reserva: $e');
    }
  }
}
