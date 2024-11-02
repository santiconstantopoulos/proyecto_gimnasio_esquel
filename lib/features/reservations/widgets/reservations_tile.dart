import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_popup_menu.dart';

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
            .format(reservation.reservationDate),
      ),
      subtitle: Text(
        reservation.isConfirmed
            ? 'Confirmada'
            : reservation.isCancelled
                ? 'Cancelada'
                : 'Eliminada',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            reservation.isConfirmed
                ? Icons.check_circle
                : (reservation.isCancelled
                    ? Icons.cancel
                    : Icons.delete),
            color: reservation.isConfirmed
                ? Colors.green
                : (reservation.isCancelled ? Colors.red : Colors.grey),
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