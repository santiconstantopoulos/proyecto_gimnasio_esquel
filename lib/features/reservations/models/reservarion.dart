import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final Timestamp date;
  final int status;

  Reservation({
    required this.id,
    required this.date,
    required this.status,
  });

  factory Reservation.fromFirestore(String id, Map<String, dynamic> data) {
    return Reservation(
      id: id,
      date: data['date'] as Timestamp,
      status: data['status'] as int,
    );
  }

  bool get isPending => status == 0;
  bool get isConfirmed => status == 1;
  bool get isCancelled => status == 2;
  bool get isDeleted => status == 3;

  DateTime get reservationDate => date.toDate();
}
