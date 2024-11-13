import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';

class ReservationDialog extends StatefulWidget {
  const ReservationDialog({super.key});

  @override
  ReservationDialogState createState() => ReservationDialogState();
}

class ReservationDialogState extends State<ReservationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _durationController = TextEditingController();
  final _placesController = TextEditingController();
  final _classNameController = TextEditingController();
  DateTime? _selectedStartDate;

  @override
  void dispose() {
    _classNameController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _durationController.dispose();
    _placesController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        _selectedStartDate = DateTime(
          _selectedStartDate?.year ?? now.year,
          _selectedStartDate?.month ?? now.month,
          _selectedStartDate?.day ?? now.day,
          picked.hour,
          picked.minute,
        );
        _timeController.text = picked.format(context);
      });
    }
  }

  void _saveReservation() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedStartDate != null) {
        int durationHours = int.tryParse(_durationController.text) ?? 1;
        final toDate = _selectedStartDate!.add(Duration(hours: durationHours));

        final reservation = Reservation(
          id: '',
          status: 1,
          fromDate: Timestamp.fromDate(_selectedStartDate!),
          toDate: Timestamp.fromDate(toDate),
          instructorId: 'instructorId',
          places: int.tryParse(_placesController.text) ?? 1,
          confirmed: 0,
          pending: 0,
          className: _classNameController.text,
        );
        Navigator.of(context).pop(reservation);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona una fecha y hora válidas'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Reserva'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _classNameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la Clase',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nombre de la clase';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Fecha de Inicio',
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
                labelText: 'Hora de Inicio',
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
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duración (horas)',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la duración';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _placesController,
              decoration: const InputDecoration(
                labelText: 'Número de Lugares',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el número de lugares';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
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
  }
}
