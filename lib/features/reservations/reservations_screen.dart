// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:proyecto_gimnasio_esquel/features/reservations/models/reservarion.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/services/reservations_service.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final ReservationsService _reservationsService = ReservationsService();

  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  DateTime? _selectedDateTime;

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
        _dateController.text = '${picked.toLocal()}'.split(' ')[0];
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

  void _saveReservation() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fecha y hora no seleccionadas')),
        );
        return;
      }

      try {
        await _reservationsService.saveReservation(_selectedDateTime!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva guardada exitosamente')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la reserva: $e')),
        );
      } finally {
        Navigator.of(context).pop();
      }
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
              onPressed: _saveReservation,
              child: const Text('Guardar'),
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
        title: const Text('Reservas'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showReservationDialog,
              child: const Text('Hacer Nueva Reserva'),
            ),
            const SizedBox(height: 20),
            Text(
              'Tus Reservas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<Reservation>>(
                stream: _reservationsService.getReservations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final reservations = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = reservations[index];
                      return ListTile(
                        title: Text(
                          DateFormat('yyyy-MM-dd - HH:mm').format(reservation
                              .date
                              .toDate()
                              .toLocal()), // Formatea la fecha con horas y minutos
                        ),
                        subtitle: Text('Estado: ${reservation.status}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
