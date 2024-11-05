import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/models/participant.dart';

class Reservation {
  final String id;
  final int status;
  final Timestamp fromDate;
  final Timestamp toDate;
  final String instructorId;
  final int occupiedPlaces;
  final int places;
  final List<Participant> participants = [];

  Reservation(
      {required this.id,
      required this.status,
      required this.fromDate,
      required this.toDate,
      required this.instructorId,
      required this.occupiedPlaces,
      required this.places});

  factory Reservation.fromFirestore(String id, Map<String, dynamic> data) {
    return Reservation(
      id: id,
      status: data['status'] as int,
      fromDate: data['from_date'] as Timestamp,
      toDate: data['to_date'] as Timestamp,
      instructorId: data['instructor_id'] as String,
      occupiedPlaces: data['occupied_places'] as int,
      places: data['places'] as int,
    );
  }
}
