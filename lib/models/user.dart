class User {
  final String id;
  final String name;
  final String profileImageUrl;
  final String qrCode;

  User({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.qrCode,
  });

  // Factory para crear un User desde Firestore
  factory User.fromFirestore(String id, Map<String, dynamic> data) {
    return User(
      id: id,
      name: data['name'] ?? 'Sin nombre',
      profileImageUrl: data['profile_image_url'] ?? '',
      qrCode: data['qrCode'] ?? '',
    );
  }
}