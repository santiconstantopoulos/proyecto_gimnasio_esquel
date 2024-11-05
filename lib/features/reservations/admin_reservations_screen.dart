import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/new_reservations_button.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/admin_reservations_list.dart';
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

  //TODO: Agregar logica para ver participantes, confirmar y cancelar reservas de usuarios
  //TODO: Considedar usar una unica lista de reservas, ver si el usuario es admin o no y mostrar las opciones correspondiente
  //TODO: Modificar los metodos del sevicio en base a estos cambios
  //TODO: El admin reservation popup menu tendria que mostrar la opcion de agendarse o cancelar dependiendo si ya esta agendado en una reserva

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

  void _showParticipantsDialog(Reservation reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Participantes de la reserva'),
          content: SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: reservation.participants.length,
              itemBuilder: (context, index) {
                final participant = reservation.participants[index];
                return ListTile(
                  title: Text(participant.name),
                  subtitle: Text('Estado: ${participant.status}'),
                );
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
            onShowParticipants: _showParticipantsDialog,
          ),
        ),
      ]),
    );
  }
}
