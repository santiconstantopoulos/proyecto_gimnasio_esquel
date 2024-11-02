import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/auth_service.dart';
import 'package:proyecto_gimnasio_esquel/services/log_service.dart';
import 'package:rxdart/rxdart.dart';

class ReservationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final LogService _logService = LogService();

  Stream<List<Reservation>> getUserReservations() {
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

  Stream<List<Reservation>> getAllUserReservations() async* {
    final StreamController<List<Reservation>> controller = StreamController();

    final usersSnapshot = await _firestore.collection('users').get();

    final List<Stream<List<Reservation>>> userReservationStreams = [];

    for (var userDoc in usersSnapshot.docs) {
      final userReservationsStream = userDoc.reference
          .collection('reservations')
          .where('status', whereIn: [0, 1, 2])
          .orderBy('date', descending: false)
          .snapshots()
          .map((reservationsSnapshot) {
            return reservationsSnapshot.docs.map((doc) {
              return Reservation.fromFirestore(doc.id, doc.data());
            }).toList();
          });

      userReservationStreams.add(userReservationsStream);
    }

    yield* Rx.combineLatest<List<Reservation>, List<Reservation>>(
      userReservationStreams,
      (List<List<Reservation>> userReservationLists) {
        List<Reservation> combinedReservations = [];
        for (var userRes in userReservationLists) {
          combinedReservations.addAll(userRes);
        }
        return combinedReservations;
      },
    );

    controller.onCancel = () {
      controller.close();
    };
  }

  Future<void> createReservation(DateTime dateTime,
      {required String name,
      required String instructorId,
      required int capacity,
      required List<Participant> participants}) async {
    try {
      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('reservations')
          .add({
        'date': Timestamp.fromDate(dateTime),
        'status': 1,
        'name': name,
        'instructorId': instructorId,
        'capacity': capacity,
        'participants':
            participants.map((participant) => participant.toMap()).toList(),
      });

      await _logService.createUserLog('Reserva creada para la fecha $dateTime',
          'info', 'reservations_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al crear la reserva: $e', 'error', 'reservations_service');
      throw Exception('Error al guardar la reserva: $e');
    }
  }

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

  Future<void> updateReservation(Reservation reservation,
      {required String className,
      required String instructorId,
      required int capacity,
      required List<Participant> participants}) async {
    try {
      await _firestore
          .collection('users')
          .doc(_authService.userId)
          .collection('reservations')
          .doc(reservation.id)
          .update({
        'className': className,
        'instructorId': instructorId,
        'capacity': capacity,
        'participants':
            participants.map((participant) => participant.toMap()).toList(),
      });

      await _logService.createUserLog('Reserva ${reservation.id} actualizada',
          'info', 'reservations_service');
    } catch (e) {
      await _logService.createUserLog(
          'Error al actualizar la reserva ${reservation.id}: $e',
          'error',
          'reservations_service');
      throw Exception('Error al actualizar la reserva: $e');
    }
  }


}
