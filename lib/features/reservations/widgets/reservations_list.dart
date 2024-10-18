import 'package:flutter/material.dart';

import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservation_tile.dart';

class ReservationsList extends StatelessWidget {
  final Stream<List<Reservation>> reservationsStream;
  final Function(String, Reservation) onOptionSelected;

  const ReservationsList({
    super.key,
    required this.reservationsStream,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<List<Reservation>>(
        stream: reservationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final reservations = snapshot.data ?? [];
          if (reservations.isEmpty) {
            return const Center(
              child: Text('No tienes reservas'),
            );
          }
          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return ReservationTile(
                reservation: reservation,
                onOptionSelected: onOptionSelected,
              );
            },
          );
        },
      ),
    );
  }
}
