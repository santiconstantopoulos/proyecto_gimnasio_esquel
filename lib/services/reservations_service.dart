import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proyecto_gimnasio_esquel/features/reservations/models/reservarion.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';
import 'package:proyecto_gimnasio_esquel/services/log_service.dart';

class ReservationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final LogService _logService = LogService();

  // Obtiene las reservaciones
  Stream<List<Reservation>> getReservations() {
    return _firestore
        .collection('users')
        .doc(_authService.userId)
        .collection('reservations')
        .where('status', whereIn: [0, 1, 2])
        .orderBy('date', descending: false)
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

  // Crea una reservación
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

      await _logService.createUserLog('Reserva creada para la fecha $dateTime',
          'info', 'reservations_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al crear la reserva: $e', 'error', 'reservations_service');
      throw Exception('Error al guardar la reserva: $e');
    }
  }

  // Confirma una reservación
  Future<void> confirmReservation(Reservation reservation) async {
    try {
      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('reservations')
          .doc(reservation.id)
          .update({'status': 1});

      await _logService.createUserLog('Reserva ${reservation.id} confirmada',
          'info', 'reservations_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al confirmar la reserva ${reservation.id}: $e',
          'error',
          'reservations_service');
      throw Exception('Error al confirmar la reserva: $e');
    }
  }

  // Cancela una reservación
  Future<void> cancelReservation(Reservation reservation) async {
    try {
      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('reservations')
          .doc(reservation.id)
          .update({'status': 2});

      await _logService.createUserLog('Reserva ${reservation.id} cancelada',
          'info', 'reservations_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al cancelar la reserva ${reservation.id}: $e',
          'error',
          'reservations_service');
      throw Exception('Error al cancelar la reserva: $e');
    }
  }

  // Elimina una reservación
  Future<void> deleteReservation(Reservation reservation) async {
    try {
      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('reservations')
          .doc(reservation.id)
          .update({'status': 3});

      await _logService.createUserLog('Reserva ${reservation.id} eliminada',
          'info', 'reservations_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al eliminar la reserva ${reservation.id}: $e',
          'error',
          'reservations_service');
      throw Exception('Error al eliminar la reserva: $e');
    }
  }
}
