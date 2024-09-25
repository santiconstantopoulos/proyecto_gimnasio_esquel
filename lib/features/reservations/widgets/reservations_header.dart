import 'package:flutter/material.dart';

class ReservationsHeader extends StatelessWidget {
  const ReservationsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tus Reservas',
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}
