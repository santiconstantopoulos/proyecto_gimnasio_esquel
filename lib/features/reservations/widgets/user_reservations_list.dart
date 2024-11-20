import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/user_reservations_popup_menu.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/reservations_service.dart';

class UserReservationsList extends StatelessWidget {
  final Stream<List<Reservation>> reservationsStream;
  final ReservationsService _reservationsService;
  final Function(String, Reservation) onOptionSelected;

  UserReservationsList({
    super.key,
    required this.reservationsStream,
    required this.onOptionSelected,
    ReservationsService? reservationsService,
  }) : _reservationsService = reservationsService ?? ReservationsService();

  Future<Color> _getReservationStatusColor(String reservationId) async {
    final userReservationStatus =
        await _reservationsService.getUserReservationStatus(reservationId);

    switch (userReservationStatus) {
      case 1: // Confirmado
        return Colors.green;
      case 0: // Pendiente
        return Colors.yellow;
      case 2: // Cancelado
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Reservation>>(
      stream: reservationsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final reservations = snapshot.data!;
          return Expanded(
            child: ListView.builder(
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                final fromDateFormatted = DateFormat('dd MMMM yyyy HH:mm')
                    .format(reservation.fromDate.toDate().toLocal());
                final toDateFormatted = DateFormat('dd MMMM yyyy HH:mm')
                    .format(reservation.toDate.toDate().toLocal());

                return FutureBuilder<Color>(
                  future: _getReservationStatusColor(reservation.id),
                  builder: (context, colorSnapshot) {
                    final statusColor = colorSnapshot.data ?? Colors.grey;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 70,
                            color: statusColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reservation.className,
                                ),
                                Text(
                                  'Desde: $fromDateFormatted - Hasta: $toDateFormatted\n'
                                  'Lugares: ${reservation.places} - Ocupados: ${reservation.confirmed} - Pendientes: ${reservation.pending}',
                                ),
                              ],
                            ),
                          ),
                          UserReservationsPopupMenu(
                            reservation: reservation,
                            onOptionSelected: (value, reservation) {
                              onOptionSelected(value, reservation);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
