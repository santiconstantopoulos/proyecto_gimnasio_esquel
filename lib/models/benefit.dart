class Benefit {
  final String id; // ID del beneficio
  final String title; // Título del beneficio
  final String description; // Descripción del beneficio
  final String imageUrl; // URL de la imagen del beneficio
  final int discount; // Descuento del beneficio
  final String? paymentInformation; // Información de pago (opcional)

  Benefit({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.discount,
    this.paymentInformation,
  });

  factory Benefit.fromFirestore(String id, Map<String, dynamic> data) {
    return Benefit(
      id: id,
      title: data['title'],
      description: data['description'],
      imageUrl: data['imageUrl'],
      discount: data['discount'],
      paymentInformation: data['paymentInformation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'discount': discount,
      'paymentInformation': paymentInformation,
    };
  }
}