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
}
