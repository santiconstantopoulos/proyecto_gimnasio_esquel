import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/admin_reservations_popup_menu.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';

class AdminReservationsList extends StatelessWidget {
  final Stream<List<Reservation>> reservationsStream;
  final Function(String, Reservation) onOptionSelected;
  final Function(Reservation) onShowParticipants;

  const AdminReservationsList({
    super.key,
    required this.reservationsStream,
    required this.onOptionSelected,
    required this.onShowParticipants,
  });

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

                return ListTile(
                  title: Text('Reserva de ${reservation.className}'),
                  subtitle: Text(
                    'Desde: $fromDateFormatted - Hasta: $toDateFormatted\n'
                    'Lugares: ${reservation.places} - Ocupados: ${reservation.confirmed} - Pendientes: ${reservation.pending}',
                  ),
                  trailing: AdminReservationPopupMenu(
                    reservation: reservation,
                    onOptionSelected: (value, reservation) {
                      onOptionSelected(value, reservation);
                    },
                  ),
                  onTap: () {
                    onShowParticipants(reservation);
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
