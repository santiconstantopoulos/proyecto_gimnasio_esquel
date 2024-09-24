import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/models/reservarion.dart';

class ReservationPopupMenu extends StatelessWidget {
  final Reservation reservation;
  final Function(String, Reservation) onOptionSelected;

  const ReservationPopupMenu({
    super.key,
    required this.reservation,
    required this.onOptionSelected,
  });

  //TODO: motrar opciones dependiendo del estado actual y la fecha, ej: no mostrar opcion de confirmar reserva si ya se paso la fecha
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        onOptionSelected(value, reservation);
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: 'confirm',
            child: Row(
              children: [
                Icon(Icons.check, color: Colors.green),
                SizedBox(width: 8),
                Text('Confirmar reserva'),
              ],
            ),
          ),
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
        ];
      },
    );
  }
}
