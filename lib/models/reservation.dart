import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final Timestamp date;
  final int status;
  final String name;
  final String instructorId;
  final int capacity;
  List<Participant> participants = [];

  Reservation(
      {required this.id,
      required this.date,
      required this.status,
      required this.name,
      required this.instructorId,
      required this.capacity,
      required this.participants});

  factory Reservation.fromFirestore(String id, Map<String, dynamic> data) {
    return Reservation(
      id: id,
      date: data['date'] as Timestamp,
      status: data['status'] as int,
      name: data['name'] as String,
      instructorId: data['instructorId'] as String,
      capacity: data['capacity'] as int,
      participants: [],
    );
  }

  bool get isPending => status == 0;
  bool get isConfirmed => status == 1;
  bool get isCancelled => status == 2;
  bool get isDeleted => status == 3;

  DateTime get reservationDate => date.toDate();
}

class Participant {
  final String name;
  final String status;

  Participant({
    required this.name,
    required this.status,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
    };
  }
}
