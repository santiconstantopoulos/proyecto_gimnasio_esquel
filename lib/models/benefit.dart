class Benefit {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int discount;
  final String? paymentInformation;

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