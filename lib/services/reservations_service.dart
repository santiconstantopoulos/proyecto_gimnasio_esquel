import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/models/participant.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/models/user.dart';
import 'package:proyecto_gimnasio_esquel/models/user_reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';
import 'package:proyecto_gimnasio_esquel/services/log_service.dart';
import 'package:proyecto_gimnasio_esquel/services/notifications_service.dart';

class ReservationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final LogService _logService = LogService();
  final NotificationsService _notificationsService = NotificationsService();

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
    Timestamp fromDate,
    Timestamp toDate,
    int places, {
    String? className,
    required String instructorId,
    required int confirmed,
    required int pending,
    required int status,
  }) async {
    try {
      await _firestore.collection('reservations').add({
        'from_date': fromDate,
        'to_date': toDate,
        'places': places,
        'confirmed': 0,
        'pending': 0,
        'status': 0,
        'instructor_id': instructorId,
        'class_name': className,
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
  Future<void> deleteReservation(String reservationId) async {
    try {
      await _firestore
          .collection('reservations')
          .doc(reservationId)
          .update({'is_deleted': true});

      await _logService.createUserLog(
          'Reserva $reservationId marcada como eliminada',
          'info',
          'reservations_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al eliminar la reserva $reservationId: $e',
          'error',
          'reservations_service');
      throw Exception('Error al eliminar la reserva: $e');
    }
  }

  // Obtiene las reservas del usuario (user_reservations)
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
      DocumentReference reservationRef =
          _firestore.collection('reservations').doc(reservationId);
      DocumentSnapshot reservationSnapshot = await reservationRef.get();

      if (!reservationSnapshot.exists) {
        throw Exception('La reserva no existe.');
      }

      int currentPending = reservationSnapshot['pending'] as int;
      int totalPlaces = reservationSnapshot['places'] as int;
      int currentConfirmed = reservationSnapshot['confirmed'] as int;

      QuerySnapshot existingReservationSnapshot = await _firestore
          .collection('user_reservations')
          .where('reservation_id', isEqualTo: reservationId)
          .where('user_id', isEqualTo: _authService.userId)
          .limit(1)
          .get();

      bool isConfirmed = currentConfirmed < totalPlaces;
      if (existingReservationSnapshot.docs.isNotEmpty) {
        if (existingReservationSnapshot.docs.first['status'] != 2) {
          throw Exception('El usuario ya está agendado a esta reserva.');
        }

        await existingReservationSnapshot.docs.first.reference.update({
          'status': isConfirmed ? 1 : 0, // Confirmado o en espera
          'created_date': Timestamp.now(),
        });

        await reservationRef.update({
          isConfirmed ? 'confirmed' : 'pending':
              isConfirmed ? currentConfirmed + 1 : currentPending + 1,
        });
      } else {
        await _firestore.collection('user_reservations').add({
          'user_id': _authService.userId,
          'reservation_id': reservationId,
          'status': isConfirmed ? 1 : 0,
          'is_deleted': false,
          'is_periodic': false,
          'created_date': Timestamp.now(),
        });

        await reservationRef.update({
          isConfirmed ? 'confirmed' : 'pending':
              isConfirmed ? currentConfirmed + 1 : currentPending + 1,
        });
      }

      String notificationMessage = isConfirmed
          ? 'Tu reserva ha sido confirmada exitosamente.'
          : 'Estás en lista de espera para la reserva. Te notificaremos si se confirma tu lugar.';
      await _notificationsService.createNotificationForUser(
        _authService.userId,
        'Reserva Agendada',
        notificationMessage,
      );
    } catch (e) {
      throw Exception('No se pudo agendar la reserva. Intente nuevamente.');
    }
  }

  // Obtiene el estado de la reserva del usuario
  Future<int?> getUserReservationStatus(String reservationId) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('user_reservations')
        .where('reservation_id', isEqualTo: reservationId)
        .where('user_id', isEqualTo: _authService.userId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['status'] as int;
    }
    return null;
  }

  // El admin confirma una reserva de un usuario
  Future<void> confirmUserReservation(UserReservation reservation) async {
    try {
      DocumentReference userReservationRef =
          _firestore.collection('user_reservations').doc(reservation.id);
      DocumentSnapshot userReservationSnapshot = await userReservationRef.get();

      if (!userReservationSnapshot.exists) {
        throw Exception('La reserva del usuario no existe.');
      }

      int status = userReservationSnapshot['status'];
      DocumentReference reservationRef =
          _firestore.collection('reservations').doc(reservation.reservationId);
      DocumentSnapshot reservationSnapshot = await reservationRef.get();

      int currentPending = reservationSnapshot['pending'] as int;
      int currentConfirmed = reservationSnapshot['confirmed'] as int;

      if (status == 0) {
        await reservationRef.update({
          'pending': currentPending - 1,
          'confirmed': currentConfirmed + 1,
        });

        await _notificationsService.createNotificationForUser(
            reservation.userId,
            'Reserva Confirmada',
            'Tu reserva ha sido confirmada exitosamente.');
      }

      await userReservationRef.update({'status': 1}); // confirmado
    } catch (e) {
      throw Exception('Error al confirmar la reserva de usuario: $e');
    }
  }

  // El usuario cancela su reserva
  Future<void> cancelUserReservation(String reservationId) async {
    try {
      DocumentReference reservationRef =
          _firestore.collection('reservations').doc(reservationId);
      DocumentSnapshot reservationSnapshot = await reservationRef.get();

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

      DocumentSnapshot userReservationDoc = userReservationSnapshot.docs.first;
      int userReservationStatus = userReservationDoc['status'];
      if (userReservationStatus != 0 && userReservationStatus != 1) {
        throw Exception(
            'Solo se pueden cancelar reservas pendientes o confirmadas.');
      }

      if (userReservationStatus == 0 && currentPending > 0) {
        await reservationRef.update({
          'pending': currentPending - 1,
        });
        currentPending -= 1;
      } else if (userReservationStatus == 1 && currentConfirmed > 0) {
        await reservationRef.update({
          'confirmed': currentConfirmed - 1,
        });
        currentConfirmed -= 1;
      }

      await userReservationDoc.reference.update({
        'status': 2, // Cancelado
      });

      QuerySnapshot pendingReservations = await _firestore
          .collection('user_reservations')
          .where('reservation_id', isEqualTo: reservationId)
          .where('status', isEqualTo: 0) // Solo pendientes
          .orderBy('created_date')
          .limit(1)
          .get();

      if (pendingReservations.docs.isNotEmpty) {
        DocumentReference firstPendingReservationRef =
            pendingReservations.docs.first.reference;

        await firstPendingReservationRef.update({
          'status': 1, // Confirmado
        });

        await reservationRef.update({
          'pending': currentPending - 1,
          'confirmed': currentConfirmed + 1,
        });

        String confirmedUserId = pendingReservations.docs.first['user_id'];
        await _notificationsService.createNotificationForUser(
            confirmedUserId,
            'Reserva Confirmada',
            'Tu reserva ha sido confirmada debido a una cancelación de otro usuario.');
      }
    } catch (e) {
      throw Exception('No se pudo cancelar la reserva. Intente nuevamente. $e');
    }
  }

  // Obtiene la reserva de un usuario por su código QR
  Future<Reservation?> getReservationByQrCode(String qrCode) async {
    try {
      // Obtén la información del usuario a partir del código QR
      // (Asumiendo que el código QR es el ID del usuario)
      final userDoc = await _firestore
          .collection('users')
          .doc(qrCode)
          .collection('profile')
          .doc('profile_data')
          .get();

      if (!userDoc.exists) {
        return null;
      }

      final userReservationsSnapshot = await _firestore
          .collection('user_reservations')
          .where('user_id', isEqualTo: qrCode)
          .where('status', isEqualTo: 1) // Confirmada
          .orderBy('created_date', descending: true)
          .limit(1)
          .get();

      if (userReservationsSnapshot.docs.isEmpty) {
        return null;
      }
      final userReservationDoc = userReservationsSnapshot.docs.first;
      final reservationId = userReservationDoc['reservation_id'];

      final reservationDoc =
          await _firestore.collection('reservations').doc(reservationId).get();

      if (reservationDoc.exists) {
        return Reservation.fromFirestore(
          reservationDoc.id,
          reservationDoc.data()!,
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
