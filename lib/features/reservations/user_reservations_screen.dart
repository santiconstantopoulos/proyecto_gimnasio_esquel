import 'package:flutter/material.dart';
import 'package:proyecto_gimnasio_esquel/features/app_strings.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/user_reservations_list.dart';
import 'package:proyecto_gimnasio_esquel/models/reservation.dart';
import 'package:proyecto_gimnasio_esquel/services/reservations_service.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/credits_display.dart';
import 'package:proyecto_gimnasio_esquel/features/reservations/widgets/reservations_header.dart';
import '../../services/credits_service.dart';

class UserReservationsScreen extends StatefulWidget {
  const UserReservationsScreen({super.key});

  @override
  State<UserReservationsScreen> createState() => _UserReservationsScreenState();
}

class _UserReservationsScreenState extends State<UserReservationsScreen> {
  final ReservationsService _reservationsService = ReservationsService();
  final CreditsService _creditService = CreditsService();

  bool _showCalendar = false;

  //TODO: Agregar logica para agendarse a una reserva, tanto los admins como los usuarios ven las reservas, la diferencia esta en las opciones
  //TODO: Considedar usar una unica lista de reservas, ver si el usuario es admin o no y mostrar las opciones correspondiente
  //TODO: Modificar los metodos del sevicio en base a estos cambios
  //TODO: El user reservation popup menu tendria que mostrar la opcion de agendarse o cancelar dependiendo si ya esta agendado en una reserva

  void _handleScheduleUserReservation(Reservation reservation) async {
    //logica para agendarse a una reserva
    print('agendarse');
    print(reservation);
  }

  void _handleCancelUserReservation(Reservation reservation) async {
    //logica para agendarse a una reserva
    print('cancelar');
    print(reservation);
  }

  void _handleUserReservationsOption(String value, Reservation reservation) {
    if (value == 'schedule') {
      _handleScheduleUserReservation(reservation);
    } else if (value == 'cancel') {
      _handleCancelUserReservation(reservation);
    }
  }

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
            const ReservationsHeader(),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _toggleView,
              child: Text(
                _showCalendar ? 'Ver Lista' : 'Ver Calendario',
              ),
            ),
            const SizedBox(height: 10),
            _showCalendar
                ? const Center(
                    child: Text('Calendario'),
                  )
                : UserReservationsList(
                    reservationsStream: _reservationsService.getReservations(),
                    onOptionSelected: (value, reservation) {
                      _handleUserReservationsOption(value, reservation);
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
