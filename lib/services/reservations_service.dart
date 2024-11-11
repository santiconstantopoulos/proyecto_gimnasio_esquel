import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/models/participant.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/models/user.dart';
import 'package:proyecto_gimnasio_esquel/models/user_reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';
import 'package:proyecto_gimnasio_esquel/services/log_service.dart';

class ReservationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final LogService _logService = LogService();

  // Obtiene todas las reservas
  Stream<List<Reservation>> getReservations() {
    return _firestore
        .collection('reservations')
        .orderBy('from_date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Reservation.fromFirestore(doc.id, doc.data());
      }).toList();
    });
  }

  // Obtiene a los participantes de una reserva
  Stream<List<Participant>> getParticipants(String reservationId) async* {
    try {
      final userReservationsSnapshot = await _firestore
          .collection('user_reservations')
          .where('reservation_id', isEqualTo: reservationId)
          .where('is_deleted', isEqualTo: false)
          .get();

      List<Participant> participants = [];

      for (var doc in userReservationsSnapshot.docs) {
        String userId = doc['user_id'];
        String status = doc['status'] == 0
            ? 'Pendiente'
            : doc['status'] == 1
                ? 'Confirmado'
                : 'Cancelado';

        final profileSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('profile')
            .doc('profile_data')
            .get();

        if (profileSnapshot.exists) {
          final user = User.fromFirestore(userId, profileSnapshot.data()!);
          participants.add(Participant(user: user, status: status));
        }
      }

      yield participants;
    } catch (e) {
      yield* Stream.error('Error al obtener los participantes: $e');
    }
  }

  // El admin crea una reserva
  Future<void> createReservation(
      Timestamp fromDate, Timestamp toDate, int places, {
    String? className,
    required String instructorId, required int confirmed, required int pending, required int status, required int occupiedPlaces,
  }) async {
    try {
      await _firestore.collection('reservations').add({
        'from_date': fromDate,
        'to_date': toDate,
        'places': places,
        'confirmed': 0,
        'pending': 0,
        'occupied_places': 0,
        'status': 0,
        'instructor_id': instructorId,
        'className': className,
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
      await _firestore.runTransaction((transaction) async {
        DocumentReference reservationRef =
            _firestore.collection('reservations').doc(reservationId);

        DocumentSnapshot reservationSnapshot =
            await transaction.get(reservationRef);

        if (!reservationSnapshot.exists) {
          throw Exception('La reserva no existe.');
        }

        int currentPending = reservationSnapshot['pending'] as int;
        int totalPlaces = reservationSnapshot['places'] as int;

        QuerySnapshot existingReservationSnapshot = await _firestore
            .collection('user_reservations')
            .where('reservation_id', isEqualTo: reservationId)
            .where('user_id', isEqualTo: _authService.userId)
            .where('status', isNotEqualTo: 2)
            .limit(1)
            .get();

        if (existingReservationSnapshot.docs.isNotEmpty) {
          throw Exception('El usuario ya está agendado a esta reserva.');
        }

        if (currentPending >= totalPlaces) {
          throw Exception('No hay lugares disponibles para esta reserva.');
        }

        transaction.update(reservationRef, {
          'pending': currentPending + 1,
        });

        transaction.set(_firestore.collection('user_reservations').doc(), {
          'user_id': _authService.userId,
          'reservation_id': reservationId,
          'status': 0, // Estatus de "pendiente"
          'is_deleted': false,
          'is_periodic': false,
          'created_date': Timestamp.now(),
        });
      });
    } catch (e) {
      print(e);
      throw Exception('No se pudo agendar la reserva. Intente nuevamente.');
    }
  }

  // El admin confirma una reserva de un usurio
  Future<void> confirmUserReservation(UserReservation reservation) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference userReservationRef =
            _firestore.collection('user_reservations').doc(reservation.id);

        DocumentSnapshot userReservationSnapshot =
            await transaction.get(userReservationRef);

        if (!userReservationSnapshot.exists) {
          throw Exception('La reserva del usuario no existe.');
        }

        int status = userReservationSnapshot['status'];
        DocumentReference reservationRef = _firestore
            .collection('reservations')
            .doc(reservation.reservationId);
        DocumentSnapshot reservationSnapshot =
            await transaction.get(reservationRef);

        int currentPending = reservationSnapshot['pending'] as int;
        int currentConfirmed = reservationSnapshot['confirmed'] as int;

        if (status == 0) {
          transaction.update(reservationRef, {
            'pending': currentPending - 1,
            'confirmed': currentConfirmed + 1,
          });
        }

        transaction.update(userReservationRef, {'status': 1}); // confirmado
      });
    } catch (e) {
      throw Exception('Error al confirmar la reserva de usuario: $e');
    }
  }

  // El usuario cancela su reserva
  Future<void> cancelUserReservation(String reservationId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference reservationRef =
            _firestore.collection('reservations').doc(reservationId);

        DocumentSnapshot reservationSnapshot =
            await transaction.get(reservationRef);

        if (!reservationSnapshot.exists) {
          throw Exception('La reserva no existe.');
        }

        int currentPending = reservationSnapshot['pending'] as int;
        int currentConfirmed = reservationSnapshot['confirmed'] as int;

        QuerySnapshot userReservationSnapshot = await _firestore
            .collection('user_reservations')
            .where('reservation_id', isEqualTo: reservationId)
            .where('user_id', isEqualTo: _authService.userId)
            .limit(1)
            .get();

        if (userReservationSnapshot.docs.isEmpty) {
          throw Exception('La reserva del usuario no se encuentra.');
        }

        if (currentPending > 0) {
          transaction.update(reservationRef, {
            'pending': currentPending - 1,
          });
        } else if (currentConfirmed > 0) {
          transaction.update(reservationRef, {
            'confirmed': currentConfirmed - 1,
          });
        }

        transaction.update(userReservationSnapshot.docs.first.reference, {
          'status': 2, // Cancelado
        });
      });
    } catch (e) {
      throw Exception('No se pudo cancelar la reserva. Intente nuevamente.');
    }
  }
}