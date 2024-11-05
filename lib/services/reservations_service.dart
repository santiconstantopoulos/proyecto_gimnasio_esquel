import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/models/user.dart';
import 'package:proyecto_gimnasio_esquel/models/user_reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';
import 'package:proyecto_gimnasio_esquel/services/log_service.dart';

class ReservationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final LogService _logService = LogService();

  // Obtiene las reservas del usuario
  Stream<List<UserReservation>> getUserReservations() {
    return _firestore
        .collection('user_reservations')
        .where('user_id', isEqualTo: _authService.userId)
        .where('status', whereIn: [0, 1, 2])
        .orderBy('created_date', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isEmpty) {
            return <UserReservation>[];
          } else {
            List<UserReservation> userReservations = [];
            for (var doc in snapshot.docs) {
              var data = doc.data();
              String reservationId = data['reservation_id'] as String;
              String userId = data['user_id'] as String;

              var reservationDoc = await _firestore
                  .collection('reservations')
                  .doc(reservationId)
                  .get();

              Reservation? reservation;
              if (reservationDoc.exists) {
                reservation = Reservation.fromFirestore(
                  reservationDoc.id,
                  reservationDoc.data()!,
                );
              }

              var userProfileDoc = await _firestore
                  .collection('users')
                  .doc(userId)
                  .collection('profile')
                  .doc('profile_data')
                  .get();

              User? user;
              if (userProfileDoc.exists) {
                user = User.fromFirestore(
                    userProfileDoc.id, userProfileDoc.data()!);
              }

              if (reservation != null && user != null) {
                UserReservation userReservation = UserReservation(
                    id: doc.id,
                    status: data['status'] as int,
                    reservationId: reservationId,
                    reservation: reservation,
                    userId: userId,
                    user: user,
                    isDeleted: data['is_deleted'] as bool,
                    createdDate: data['created_date'] as Timestamp);

                userReservations.add(userReservation);
              }
            }
            return userReservations;
          }
        });
  }

  // El usuario se agenda a una reserva
  Future<void> scheduleUserReservation(String reservationId) async {
    try {
      await _firestore.collection('user_reservations').add({
        'user_id': _authService.userId,
        'reservation_id': reservationId,
        'status': 0,
        'is_deleted': false,
        'created_date': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('No se pudo agendar la reserva. Intente nuevamente.');
    }
  }

  // El usario cancela su reserva
  Future<void> cancelUserReservation(UserReservation userReservation) async {
    try {
      await _firestore
          .collection('user_reservations')
          .doc(userReservation.id)
          .update({'status': 2});

      await _logService.createUserLog(
          'Reserva de usuario ${userReservation.id} cancelada',
          'info',
          'reservations_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al cancelar la reserva de usuario ${userReservation.id}: $e',
          'error',
          'reservations_service');
      throw Exception('Error al cancelar la reserva de usuario: $e');
    }
  }

  // El usuario elimina una reserva (no se lista)
  Future<void> deleteUserReservation(UserReservation userReservation) async {
    try {
      await _firestore
          .collection('user_reservations')
          .doc(userReservation.id)
          .update({'is_deleted': true});

      await _logService.createUserLog(
          'Reserva de usuario ${userReservation.id} marcada como eliminada',
          'info',
          'reservations_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al eliminar la reserva de usuario ${userReservation.id}: $e',
          'error',
          'reservations_service');
      throw Exception('Error al eliminar la reserva de usuario: $e');
    }
  }

  // Obtiene todas las reservas
  Stream<List<Reservation>> getReservations() {
    return _firestore.collection('reservations').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reservation.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  // El admin crea una reserva
  Future<void> createReservation(
      Timestamp fromDate, Timestamp toDate, int places) async {
    try {
      await _firestore.collection('reservations').add({
        'from_date': fromDate,
        'to_date': toDate,
        'places': places,
        'occupied_places': 0,
        'status': 0,
        'instructor_id': '', // ID del instructor, si se aplica
        'created_date': Timestamp.now(),
      });

      await _logService.createUserLog(
          'Reserva creada desde $fromDate hasta $toDate con $places lugares',
          'info',
          'reservations_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al crear la reserva: $e', 'error', 'reservations_service');
      throw Exception('Error al crear la reserva: $e');
    }
  }

  // El admin confirma una reserva de un usurio
  Future<void> confirmUserReservation(UserReservation reservation) async {
    try {
      await _firestore
          .collection('user_reservations')
          .doc(reservation.id)
          .update({'status': 1}); // confirmado

      await _logService.createUserLog(
          'Reserva de usuario ${reservation.id} confirmada',
          'info',
          'reservations_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al confirmar la reserva de usuario ${reservation.id}: $e',
          'error',
          'reservations_service');
      throw Exception('Error al confirmar la reserva de usuario: $e');
    }
  }

  // El admin elimina una reserva
  Future<void> deleteReservation(Reservation reservation) async {
    try {
      await _firestore
          .collection('reservations')
          .doc(reservation.id)
          .update({'is_deleted': true});

      await _logService.createUserLog(
          'Reserva ${reservation.id} marcada como eliminada',
          'info',
          'reservations_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al eliminar la reserva ${reservation.id}: $e',
          'error',
          'reservations_service');
      throw Exception('Error al eliminar la reserva: $e');
    }
  }
}
