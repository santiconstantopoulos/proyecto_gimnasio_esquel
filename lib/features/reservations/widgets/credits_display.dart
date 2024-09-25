import 'package:flutter/material.dart';

class CreditsDisplay extends StatelessWidget {
  final Stream<int> creditsStream;

  const CreditsDisplay({super.key, required this.creditsStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: creditsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final int credits = snapshot.data ?? 0;
        return SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: Colors.grey.shade400,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.credit_card, size: 30, color: Colors.grey.shade700),
                const SizedBox(width: 10),
                Text(
                  'Créditos disponibles: $credits',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
