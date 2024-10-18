import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_list.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/reservations_service.dart';

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

  void _handleReservationsOption(String value, Reservation reservation) {
    if (value == 'cancel') {
      _handleCancelReservation(reservation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.adminReservas),
        centerTitle: true,
      ),
      body: Column(children: [
        ReservationsList(
          reservationsStream: _reservationsService.getAllUserReservations(),
          onOptionSelected: (value, reservation) {
            _handleReservationsOption(value, reservation);
          },
        ),
      ]),
    );
  }
}