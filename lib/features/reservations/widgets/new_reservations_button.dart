import 'package:flutter/material.dart';

class NewReservationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NewReservationButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Hacer Nueva Reserva'),
    );
  }
}
