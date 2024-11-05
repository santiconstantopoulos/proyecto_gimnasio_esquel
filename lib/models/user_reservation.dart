import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/models/user.dart';

class UserReservation {
  final String id;
  final int status;
  final String reservationId;
  final Reservation reservation;
  final String userId;
  final User user;
  final bool isDeleted;
  final Timestamp createdDate;

  UserReservation(
      {required this.id,
      required this.status,
      required this.reservationId,
      required this.reservation,
      required this.userId,
      required this.user,
      required this.isDeleted,
      required this.createdDate});

  factory UserReservation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserReservation(
        id: doc.id,
        status: data['status'] as int,
        reservationId: data['reservation_id'] as String,
        reservation: Reservation.fromFirestore(
            data['reservation_id'], data['reservation']),
        userId: data['user_id'] as String,
        user: User.fromFirestore(data['user_id'], data['user']),
        isDeleted: data['is_deleted'] as bool,
        createdDate: data['created_date'] as Timestamp);
  }

  bool get isPending => status == 0;
  bool get isConfirmed => status == 1;
  bool get isCancelled => status == 2;
}
