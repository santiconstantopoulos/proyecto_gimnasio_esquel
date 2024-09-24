import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:proyecto_gimnasio_esquel/features/reservations/models/reservarion.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservation_popup_menu.dart';

class ReservationTile extends StatelessWidget {
  final Reservation reservation;
  final Function(String, Reservation) onOptionSelected;

  const ReservationTile({
    super.key,
    required this.reservation,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        DateFormat('dd-MM-yyyy - HH:mm')
            .format(reservation.date.toDate().toLocal()),
      ),
      subtitle: Text(
        reservation.status == 0
            ? 'Pendiente de Confirmación'
            : reservation.status == 1
                ? 'Confirmada'
                : 'Cancelada',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            reservation.status == 1
                ? Icons.check_circle
                : (reservation.status == 0
                    ? Icons.hourglass_empty
                    : Icons.cancel),
            color: reservation.status == 1
                ? Colors.green
                : (reservation.status == 0 ? Colors.orange : Colors.red),
          ),
          const SizedBox(width: 8),
          ReservationPopupMenu(
            reservation: reservation,
            onOptionSelected: onOptionSelected,
          ),
        ],
      ),
    );
  }
}
