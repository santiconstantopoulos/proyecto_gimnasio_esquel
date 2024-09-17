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
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la reserva: $e')),
        );
      }
    }
  }

  void _handleReservationsOption(String value, Reservation reservation) {
    // logica para las opciones de las reservas
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Créditos del usuario
            StreamBuilder<int>(
              stream: _reservationsService.getCredits(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final int credits = snapshot.data ?? 0;
                return SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: Colors.grey.shade400,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card,
                            size: 30, color: Colors.grey.shade700),
                        const SizedBox(width: 10),
                        Text(
                          'Créditos disponibles: $credits',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Botón para hacer nueva reserva
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

            // Lista de reservas
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
                  if (reservations.isEmpty) {
                    return const Center(
                      child: Text('No tienes reservas'),
                    );
                  }
                  return ListView.builder(
                    itemCount: reservations.length,
                    itemBuilder: (context, index) {
                      final reservation = reservations[index];
                      return ListTile(
                        title: Text(
                          DateFormat('dd-MM-yyyy - HH:mm')
                              .format(reservation.date.toDate().toLocal()),
                        ),
                        subtitle: Text(
                          reservation.status == 0
                              ? 'Pendiente de Confirmación'
                              : reservation.status == 1
                                  ? 'Confirmada'
                                  : 'Cancelada',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              reservation.status == 1
                                  ? Icons.check_circle
                                  : (reservation.status == 0
                                      ? Icons.hourglass_empty
                                      : Icons.cancel),
                              color: reservation.status == 1
                                  ? Colors.green
                                  : (reservation.status == 0
                                      ? Colors.orange
                                      : Colors.red),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                _handleReservationsOption(value, reservation);
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem<String>(
                                    value: 'confirm',
                                    child: Row(
                                      children: [
                                        Icon(Icons.check, color: Colors.green),
                                        SizedBox(width: 8),
                                        Text('Confirmar reserva'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'cancel',
                                    child: Row(
                                      children: [
                                        Icon(Icons.cancel, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Cancelar reserva'),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
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
