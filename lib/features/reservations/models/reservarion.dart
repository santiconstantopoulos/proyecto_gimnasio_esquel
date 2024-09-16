import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final Timestamp date;
  final int status;

  Reservation({required this.date, required this.status});

  factory Reservation.fromFirestore(Map<String, dynamic> data) {
    return Reservation(
      date: data['date'] as Timestamp,
      status: data['status'] as int,
    );
  }
}
