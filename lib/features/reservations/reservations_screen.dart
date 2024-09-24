// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:proyecto_gimnasio_esquel/features/reservations/models/reservarion.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/services/credits_service.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/services/reservations_service.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/credits_display.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/new_reservation_button.dart';
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

  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  DateTime? _selectedDateTime;

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDateTime) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime?.hour ?? 0,
          _selectedDateTime?.minute ?? 0,
        );
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime?.year ?? DateTime.now().year,
          _selectedDateTime?.month ?? DateTime.now().month,
          _selectedDateTime?.day ?? DateTime.now().day,
          picked.hour,
          picked.minute,
        );
        _timeController.text = picked.format(context);
      });
    }
  }

  void _showReservationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nueva Reserva'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectDate,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la fecha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _timeController,
                  decoration: InputDecoration(
                    labelText: 'Hora',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.access_time),
                      onPressed: _selectTime,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la hora';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: _createReservation,
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _createReservation() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fecha y hora no seleccionadas')),
        );
        return;
      }

      try {
        await _reservationsService.createReservation(_selectedDateTime!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva guardada exitosamente')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la reserva: $e')),
        );
      }
    }
  }

  void _handleReservationsOption(String value, Reservation reservation) async {
    if (value == 'confirm') {
      final creditsStream = _creditService.getCredits();
      creditsStream.listen((credits) async {
        if (credits <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'No tienes créditos suficientes para confirmar la reserva.')),
          );
          return;
        }

        try {
          await _reservationsService.confirmReservation(reservation);
          await _creditService.consumeCredits(1);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Reserva confirmada y crédito consumido')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al confirmar la reserva: $e')),
          );
        }
      });
    } else if (value == 'cancel') {
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
    } else if (value == 'delete') {
      Timestamp reservationTime = reservation.date;
      DateTime now = DateTime.now();

      if (reservation.status == 1) {
        if (reservationTime
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'No se puede eliminar la reserva, faltan menos de 30 minutos')),
          );
        }
      } else {
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas'),
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
