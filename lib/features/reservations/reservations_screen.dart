import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';

import 'package:proyecto_gimnasio_esquel/features/reservations/models/reservarion.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/services/credits_service.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/services/reservations_service.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/credits_display.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/new_reservation_button.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservation_dialog.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_header.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_list.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final ReservationsService _reservationsService = ReservationsService();
  final CreditsService _creditService = CreditsService();

  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
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
        await _reservationsService.createReservation(reservationDateTime);
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

  void _handleConfirmReservation(Reservation reservation) async {
    try {
      final credits = await _creditService.getCredits().first;

      if (credits <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.errorCreditsReservation),
          ),
        );
        return;
      }

      await _reservationsService.confirmReservation(reservation);
      await _creditService.consumeCredits(1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.reservaConfirmada)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.errorAlConfirmar}$e')),
      );
    }
  }

  void _handleCancelReservation(Reservation reservation) async {
    Timestamp reservationTime = reservation.date;
    DateTime now = DateTime.now();

    if (reservation.isPending) {
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
    } else if (reservation.isConfirmed) {
      DateTime reservationDateTime = reservationTime.toDate();

      if (reservationDateTime.isAfter(now.add(const Duration(minutes: 30)))) {
        try {
          await _reservationsService.cancelReservation(reservation);
          await _creditService.returnCredits(1);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(AppStrings.reservaCanceladaConRetorno)),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppStrings.errorAlCancelar}$e')),
          );
        }
      } else if (reservationDateTime.isAfter(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.notCancelReservation30)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.notCancelReservationOutDate)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.notCancel)),
      );
    }
  }

  void _handleDeleteReservation(Reservation reservation) async {
    Timestamp reservationTime = reservation.date;
    DateTime now = DateTime.now();
    DateTime reservationDateTime = reservationTime.toDate();

    if (reservation.isPending || reservation.isCancelled) {
      // Pendiente o Cancelada
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
    } else if (reservation.isConfirmed) {
      // Confirmada
      if (reservationDateTime.isAfter(now.add(const Duration(minutes: 30)))) {
        // Faltan más de 30 minutos
        try {
          await _reservationsService.deleteReservation(reservation);
          await _creditService.returnCredits(1);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(AppStrings.reservaEliminadaConRetorno)),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppStrings.errorAlEliminar}$e')),
          );
        }
      } else if (reservationDateTime.isAfter(now)) {
        // Faltan menos de 30 minutos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.notDeleteReservation30)),
        );
      } else {
        // Ya pasó la fecha de la reserva
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
    }
  }

  void _handleReservationsOption(String value, Reservation reservation) {
    if (value == 'confirm') {
      _handleConfirmReservation(reservation);
    } else if (value == 'cancel') {
      _handleCancelReservation(reservation);
    } else if (value == 'delete') {
      _handleDeleteReservation(reservation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.reservas),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CreditsDisplay(creditsStream: _creditService.getCredits()),
            const SizedBox(height: 20),
            NewReservationButton(onPressed: _showReservationDialog),
            const SizedBox(height: 20),
            const ReservationsHeader(),
            const SizedBox(height: 10),
            ReservationsList(
              reservationsStream: _reservationsService.getReservations(),
              onOptionSelected: (value, reservation) {
                _handleReservationsOption(value, reservation);
              },
            ),
          ],
        ),
      ),
    );
  }
}
