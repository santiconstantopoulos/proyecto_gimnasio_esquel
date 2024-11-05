import 'package:proyecto_gimnasio_esquel/models/user.dart';

class Participant {
  final User user;
  final String status;

  Participant({
    required this.user,
    required this.status,
  });
  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'status': status,
    };
  }
}
