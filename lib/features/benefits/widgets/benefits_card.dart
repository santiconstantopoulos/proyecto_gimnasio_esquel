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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            benefit.imageUrl,
            height: 150,
            fit: BoxFit.cover,
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