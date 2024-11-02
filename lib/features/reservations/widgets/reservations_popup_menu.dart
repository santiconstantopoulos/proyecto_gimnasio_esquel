import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';

class ReservationPopupMenu extends StatelessWidget {
  final Reservation reservation;
  final Function(String, Reservation) onOptionSelected;

  const ReservationPopupMenu({
    super.key,
    required this.reservation,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        onOptionSelected(value, reservation);
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> options = [];

        if (!reservation.isCancelled && !reservation.isDeleted) {
          options.add(
            const PopupMenuItem<String>(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Cancelar reserva'),
                ],
              ),
            ),
          );
        }

        if (!reservation.isDeleted) {
          options.add(
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('Eliminar reserva'),
                ],
              ),
            ),
          );
        }

        return options;
      },
    );
  }
}