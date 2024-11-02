// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_list.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/reservations_service.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/credits_display.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/new_reservations_button.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_header.dart';

import '../../services/credits_service.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final ReservationsService _reservationsService = ReservationsService();
  final CreditsService _creditService = CreditsService();

  // Variable para controlar la vista actual (lista o calendario)
  bool _showCalendar = false;

  @override
  void dispose() {
    super.dispose();
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

  void _handleConfirmReservation(Reservation reservation) async {
    try {
      await _reservationsService.confirmReservation(reservation);
      // ignore: duplicate_ignore
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.reservaConfirmada)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.errorAlConfirmar}$e')),
      );
    }
  }

  void _handleDeleteReservation(Reservation reservation) async {
    Timestamp reservationTime = reservation.date;
    DateTime now = DateTime.now();
    DateTime reservationDateTime = reservationTime.toDate();

//TODO: Revisar esta logica ya quedo deprecated por los cambios
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
    if (value == 'cancel') {
      _handleCancelReservation(reservation);
    } else if (value == 'delete') {
      _handleDeleteReservation(reservation);
    }
  }

//TODO: Eliminar esto, solo podríamos apuntarnos a una reserva ya creada, no podemos crear desde el lado del usuario
  // Muestra el diálogo de creación de reserva
  void _showReservationDialog() async {
    // ... (Igual que en `ReservationsScreenAdmin`)
  }

  // Cambia la vista entre lista y calendario
  void _toggleView() {
    setState(() {
      _showCalendar = !_showCalendar;
    });
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
            CreditsDisplay(creditsStream: _creditService.getUserCredits()),
            const SizedBox(height: 20),
            NewReservationButton(onPressed: _showReservationDialog),
            const SizedBox(height: 20),
            const ReservationsHeader(),
            const SizedBox(height: 10),
            // Botón para cambiar la vista
            ElevatedButton(
              onPressed: _toggleView,
              child: Text(
                _showCalendar ? 'Ver Lista' : 'Ver Calendario',
              ),
            ),
            const SizedBox(height: 10),
            // Muestra la vista de lista o calendario
            _showCalendar
                ? const Center(
                    child: Text('Calendario'),
                  )
                : ReservationsList(
                    reservationsStream:
                        _reservationsService.getUserReservations(),
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
