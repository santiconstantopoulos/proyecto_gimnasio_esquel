import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/reservations_service.dart';

class UserReservationsPopupMenu extends StatefulWidget {
  final Reservation reservation;
  final Function(String, Reservation) onOptionSelected;

  const UserReservationsPopupMenu({
    super.key,
    required this.reservation,
    required this.onOptionSelected,
  });

  @override
  _UserReservationsPopupMenuState createState() =>
      _UserReservationsPopupMenuState();
}

class _UserReservationsPopupMenuState extends State<UserReservationsPopupMenu> {
  int? reservationStatus;
  final ReservationsService _reservationsService = ReservationsService();

  @override
  void initState() {
    super.initState();
    _loadReservationStatus();
  }

  Future<void> _loadReservationStatus() async {
    final status = await _reservationsService
        .getUserReservationStatus(widget.reservation.id);
    setState(() {
      reservationStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        widget.onOptionSelected(value, widget.reservation);
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry<String>> options = [];

        if (reservationStatus == null || reservationStatus == 2) {
          options.add(
            const PopupMenuItem<String>(
              value: 'schedule',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Agendarse a reserva'),
                ],
              ),
            ),
          );
        }

        if (reservationStatus != null && reservationStatus != 2) {
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

        return options;
      },
    );
  }
}
