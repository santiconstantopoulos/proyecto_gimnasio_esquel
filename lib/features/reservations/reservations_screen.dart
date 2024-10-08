// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          const SnackBar(content: Text('Reserva creada exitosamente.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la reserva: $e')),
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
            content: Text(
                'No tienes créditos suficientes para confirmar la reserva.'),
          ),
        );
        return;
      }

      await _reservationsService.confirmReservation(reservation);
      await _creditService.consumeCredits(1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva confirmada y crédito consumido')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar la reserva: $e')),
      );
    }
  }

  void _handleCancelReservation(Reservation reservation) async {
    Timestamp reservationTime = reservation.date;
    DateTime now = DateTime.now();

    if (reservationTime
        .toDate()
        .isAfter(now.add(const Duration(minutes: 30)))) {
      try {
        await _reservationsService.cancelReservation(reservation);
        await _creditService.returnCredits(1);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Reserva cancelada y créditos devueltos')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cancelar la reserva: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'No se puede cancelar la reserva, faltan menos de 30 minutos')),
      );
    }
  }

  void _handleDeleteReservation(Reservation reservation) async {
    Timestamp reservationTime = reservation.date;
    DateTime now = DateTime.now();

    if (reservation.status == 1 &&
        reservationTime
            .toDate()
            .isAfter(now.add(const Duration(minutes: 30)))) {
      try {
        await _reservationsService.deleteReservation(reservation);
        await _creditService.returnCredits(1);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Reserva eliminada y créditos devueltos')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la reserva: $e')),
        );
      }
    } else if (reservation.status != 1) {
      try {
        await _reservationsService.deleteReservation(reservation);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva eliminada')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la reserva: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'No se puede eliminar la reserva, faltan menos de 30 minutos')),
      );
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
        title: const Text('Reservas'),
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
