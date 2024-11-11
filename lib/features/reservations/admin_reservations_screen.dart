import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/new_reservations_button.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/admin_reservations_list.dart';
import 'package:proyecto_gimnasio_esquel/models/participant.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/reservations_service.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_dialog.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  final ReservationsService _reservationsService = ReservationsService();

  // Muestra modal para crear una reserva
  void _showReservationDialog() async {
    final Reservation? newReservation = await showDialog<Reservation>(
      context: context,
      builder: (BuildContext context) {
        return const ReservationDialog();
      },
    );

    if (newReservation != null) {
      try {
        await _reservationsService.createReservation(
          newReservation.fromDate,
          newReservation.toDate,
          newReservation.places,
          className: newReservation.className,
          instructorId: newReservation.instructorId, // Agrega el ID del instructor
          confirmed: 0,
          pending: 0,
          occupiedPlaces: 0,
          status: 0,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.reservationCreated)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorReservation}$e')),
        );
      }
    }
  }

  // TODO: Poder confirmar a un usuario, lo que se puede hacer es a participant agregar el userReservation, para pasarselo al service, y que la confirme o cambiar el metodo del service
  // Muestra a los participantes de una reserva
  void _showParticipantsDialog(Reservation reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Participantes de la reserva'),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: StreamBuilder<List<Participant>>(
              stream: _reservationsService.getParticipants(reservation.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.isNotEmpty) {
                  final participants = snapshot.data!;
                  return ListView.builder(
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final participant = participants[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: participant
                                  .user.profileImageUrl.isNotEmpty
                              ? NetworkImage(participant.user.profileImageUrl)
                              : null,
                          radius: 20,
                          child: participant.user.profileImageUrl.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(participant.user.name),
                        subtitle: Text('Estado: ${participant.status}'),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No hay participantes.'));
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Maneja la opcion del popup seleccionada
  void _handleReservationsOption(String option, Reservation reservation) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminReservas),
        centerTitle: true,
      ),
      body: Column(children: [
        NewReservationButton(onPressed: _showReservationDialog),
        Expanded(
          child: AdminReservationsList(
              reservationsStream: _reservationsService.getReservations(),
              onOptionSelected: (value, reservation) {
                _handleReservationsOption(value, reservation);
              },
              onShowParticipants: (reservation) {
                _showParticipantsDialog(reservation);
              }),
        ),
      ]),
    );
  }
}