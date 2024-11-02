// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/new_reservations_button.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_list_admin.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/reservations_service.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_dialog.dart';

class ReservationsScreenAdmin extends StatefulWidget {
  const ReservationsScreenAdmin({super.key});

  @override
  State<ReservationsScreenAdmin> createState() =>
      _ReservationsScreenAdminState();
}

class _ReservationsScreenAdminState extends State<ReservationsScreenAdmin> {
  final ReservationsService _reservationsService = ReservationsService();

  @override
  void dispose() {
    super.dispose();
  }

  void _handleCancelReservation(Reservation reservation) async {
    try {
      await _reservationsService.cancelReservation(reservation);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.reservaCancelada)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.errorAlCancelar}$e')),
      );
    }
  }

  void _handleDeleteReservation(Reservation reservation) async {
    try {
      await _reservationsService.deleteReservation(reservation);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.reservaEliminada)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.errorAlEliminar}$e')),
      );
    }
  }

  void _handleUpdateReservation(Reservation reservation) async {
    try {
      await _reservationsService.updateReservation(
        reservation,
        className: reservation.name,
        instructorId: reservation.instructorId,
        capacity: reservation.capacity,
        participants: reservation.participants,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.reservaActualizada)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.errorAlActualizar}$e')),
      );
    }
  }

  void _handleReservationsOption(String value, Reservation reservation) {
    if (value == 'cancel') {
      _handleCancelReservation(reservation);
    } else if (value == 'delete') {
      _handleDeleteReservation(reservation);
    } else if (value == 'edit') {
      _handleUpdateReservation(reservation);
    }
  }

  void _showReservationDialog() async {
    final DateTime? reservationDateTime = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return const ReservationDialog();
      },
    );

    if (reservationDateTime != null) {
      try {
        await _reservationsService.createReservation(
          reservationDateTime,
          name: '', 
          instructorId: '', 
          capacity: 0,
          participants: [], 
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.reservationCreated)),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorReservation}$e')),
        );
      }
    }
  }

  // Muestra participantes de una reserva
  void _showParticipantsDialog(Reservation reservation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Participantes de la reserva'),
          content: SizedBox(
            height: 300, // Ajusta la altura si es necesario
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminReservas),
        centerTitle: true,
      ),
      body: Column(children: [
        NewReservationButton(onPressed: _showReservationDialog),
        ReservationsListAdmin(
          reservationsStream: _reservationsService.getAllUserReservations(),
          onOptionSelected: (value, reservation) {
            _handleReservationsOption(value, reservation);
          },
          onShowParticipants: _showParticipantsDialog,
        ),
      ]),
    );
  }
}