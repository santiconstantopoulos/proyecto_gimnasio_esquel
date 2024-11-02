import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_popup_menu.dart';

class ReservationsListAdmin extends StatelessWidget {
  final Stream<List<Reservation>> reservationsStream;
  final Function(String, Reservation) onOptionSelected;
  final Function(Reservation) onShowParticipants;

  const ReservationsListAdmin({
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
                return ListTile(
                  title: Text(reservation.name),
                  subtitle: Text(
                      '${reservation.date.toDate().toLocal().toString()} - ${reservation.instructorId}'),
                  trailing: ReservationPopupMenu(
                    reservation: reservation,
                    onOptionSelected: onOptionSelected,
                  ),
                  onTap: () {
                    onShowParticipants(reservation);
                  }, 
                );
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}