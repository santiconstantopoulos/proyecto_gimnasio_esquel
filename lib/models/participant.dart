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
