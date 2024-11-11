import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/models/participant.dart';

class Reservation {
  final String id;
  final int status;
  final Timestamp fromDate;
  final Timestamp toDate;
  final String instructorId;
  final int places;
  final int confirmed;
  final int pending;
  final String className;
  final List<Participant> participants = [];

  Reservation({
    required this.id,
    required this.status,
    required this.fromDate,
    required this.toDate,
    required this.instructorId,
    required this.places,
    required this.confirmed,
    required this.pending,
    required this.className
  });

  factory Reservation.fromFirestore(String id, Map<String, dynamic> data) {
    return Reservation(
        id: id,
        status: data['status'] as int,
        fromDate: data['from_date'] as Timestamp,
        toDate: data['to_date'] as Timestamp,
        instructorId: data['instructor_id'] as String,
        places: data['places'] as int,
        confirmed: data['confirmed'] as int,
        pending: data['pending'],
        className: data['className']);
  }
}
