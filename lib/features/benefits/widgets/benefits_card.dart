import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/models/benefit.dart';

class BenefitCard extends StatelessWidget {
  final Benefit benefit;
  final Function? onEdit;
  final Function? onDelete;

  const BenefitCard({
    Key? key,
    required this.benefit,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Image.network(
              benefit.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(child: Icon(Icons.error));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  benefit.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '${benefit.discount}% de descuento',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (benefit.paymentInformation != null)
                  const SizedBox(height: 8),
                if (benefit.paymentInformation != null)
                  Text(
                    benefit.paymentInformation!,
                    style: const TextStyle(fontSize: 12),
                  ),
                if (onEdit != null || onDelete != null)
                  const SizedBox(height: 8),
                if (onEdit != null || onDelete != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          onPressed: () => onEdit!(),
                          icon: const Icon(Icons.edit),
                        ),
                      if (onDelete != null)
                        IconButton(
                          onPressed: () => onDelete!(),
                          icon: const Icon(Icons.delete),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}